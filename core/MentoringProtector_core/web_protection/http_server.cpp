#include "pch.h"
#include "http_server.h"
#include "../json_utils.h"
#include "../nudge/inudge_sink.h"
#include "../nudge/nudge.h"
#include <sstream>
#include <algorithm>
#include <stdexcept>
#include <string_view>

#pragma comment(lib, "ws2_32.lib")

using namespace std;

WebProtectionServer::WebProtectionServer(UrlChecker& checker, INudgeSink* nudge_sink) : checker_(checker), nudge_sink_(nudge_sink) {
    WSADATA wsaData;
    WSAStartup(MAKEWORD(2, 2), &wsaData);
}

WebProtectionServer::~WebProtectionServer() {
    stop();
    WSACleanup();
}

bool WebProtectionServer::start() {
    if (running_.load()) return false;
    listenSocket_ = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (listenSocket_ == INVALID_SOCKET) return false;
    int opt = 1;
    setsockopt(listenSocket_, SOL_SOCKET, SO_REUSEADDR, reinterpret_cast<const char*>(&opt), sizeof(opt));

    sockaddr_in addr{};
    addr.sin_family = AF_INET;
    addr.sin_port = htons(static_cast<u_short>(port_));
    addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);

    if (::bind(listenSocket_, reinterpret_cast<sockaddr*>(&addr), sizeof(addr)) == SOCKET_ERROR) { closesocket(listenSocket_); listenSocket_ = INVALID_SOCKET; return false; }
    if (listen(listenSocket_, SOMAXCONN) == SOCKET_ERROR) { closesocket(listenSocket_); listenSocket_ = INVALID_SOCKET; return false; }

    running_ = true;
    for (int i = 0; i < MAX_WORKER_THREADS; ++i) workers_.emplace_back(&WebProtectionServer::workerFunc, this);
    acceptThread_ = thread(&WebProtectionServer::acceptLoop, this);
    return true;
}

void WebProtectionServer::stop() {
    bool expected = true;
    if (!running_.compare_exchange_strong(expected, false)) return;
    if (listenSocket_ != INVALID_SOCKET) { closesocket(listenSocket_); listenSocket_ = INVALID_SOCKET; }
    queueCV_.notify_all();

    for (auto& w : workers_) if (w.joinable()) w.join();
    workers_.clear();

    if (acceptThread_.joinable()) acceptThread_.join();
}

bool WebProtectionServer::isRunning() const { return running_.load(); }

void WebProtectionServer::acceptLoop() {
    while (running_.load()) {
        sockaddr_in clientAddr{};
        int addrLen = sizeof(clientAddr);

        SOCKET clientSocket = accept(listenSocket_, reinterpret_cast<sockaddr*>(&clientAddr), &addrLen);

        if (clientSocket == INVALID_SOCKET) break;

        { lock_guard<mutex> lock(queueMutex_); taskQueue_.push(clientSocket); }
        queueCV_.notify_one();
    }
}

void WebProtectionServer::workerFunc() {
    while (true) {
        SOCKET sock = INVALID_SOCKET;
        {
            unique_lock<mutex> lock(queueMutex_);
            queueCV_.wait(lock, [this] { return !running_.load() || !taskQueue_.empty(); });
            if (!running_.load() && taskQueue_.empty()) return;
            sock = taskQueue_.front();
            taskQueue_.pop();
        }
        if (sock != INVALID_SOCKET) handleClient(sock);
    }
}

void WebProtectionServer::handleClient(SOCKET clientSocket) {
    DWORD timeout = 2000;
    setsockopt(clientSocket, SOL_SOCKET, SO_RCVTIMEO, reinterpret_cast<const char*>(&timeout), sizeof(timeout));
    setsockopt(clientSocket, SOL_SOCKET, SO_SNDTIMEO, reinterpret_cast<const char*>(&timeout), sizeof(timeout));

    string clientIP = "unknown";
    {
        sockaddr_in peerAddr{};
        int peerLen = sizeof(peerAddr);
        if (getpeername(clientSocket, reinterpret_cast<sockaddr*>(&peerAddr), &peerLen) == 0) { BYTE* ip = reinterpret_cast<BYTE*>(&peerAddr.sin_addr); char ipBuf[16]; snprintf(ipBuf, sizeof(ipBuf), "%d.%d.%d.%d", ip[0], ip[1], ip[2], ip[3]); clientIP = ipBuf; }
    }

    string request;
    request.reserve(4096);
    char buf[4096];

    while (request.size() < 8192) {
        int received = recv(clientSocket, buf, static_cast<int>(sizeof(buf) - 1), 0);
        if (received <= 0) break;
        request.append(buf, received);
        if (request.find("\r\n\r\n") != string::npos) break;
    }

    if (!request.empty()) {
        if (!tryConsumeToken(clientIP)) { string tooMany = buildResponse(429, R"({"error":"Too Many Requests"})"); send(clientSocket, tooMany.c_str(), static_cast<int>(tooMany.size()), 0); closesocket(clientSocket); return; }

        string origin = validateOrigin(getHeader(request, "Origin")), method, path, query;

        if (parseRequestLine(request, method, path, query)) {
            if (path != "/version") { string authHeader = getHeader(request, "Authorization"); if (!mentoring_protector::AuthToken::getInstance().validate(authHeader)) { string forbidden = buildResponse(403, R"({"error":"forbidden"})", ""); send(clientSocket, forbidden.c_str(), static_cast<int>(forbidden.size()), 0); closesocket(clientSocket); return; } }
            string responseBody = routeRequest(method, path, query), httpResponse = buildResponse(200, responseBody, origin);
            send(clientSocket, httpResponse.c_str(), static_cast<int>(httpResponse.size()), 0);
        } else { string err = buildResponse(400, R"({"error":"Bad Request"})", ""); send(clientSocket, err.c_str(), static_cast<int>(err.size()), 0); }
    }

    closesocket(clientSocket);
}

string WebProtectionServer::routeRequest(const string& method, const string& path, const string& query) {
    if (method == "GET") {
        if (path == "/check") return handleCheck(query);
        if (path == "/nudge") return handleNudge(query);
        if (path == "/status") return handleStatus();
        if (path == "/version") return handleVersion();
    }

    return R"({"error":"Not Found"})";
}

string WebProtectionServer::handleCheck(const string& query) {
    string urlParam = getQueryParam(query, "url");
    if (urlParam.empty()) return R"({"error":"Missing url parameter"})";

    string url = urlDecode(urlParam);
    UrlCheckResult result = checker_.check(url);

    using json_utils::escapeJson;
    using json_utils::boolToJson;

    ostringstream json;
    json << "{" << "\"safe\":" << boolToJson(result.safe) << "," << "\"reason\":\"" << escapeJson(result.reason) << "\"," << "\"score\":" << result.score << "," << "\"domain\":\"" << escapeJson(result.domain) << "\"," << "\"detail\":\"" << escapeJson(result.detail) << "\"," << "\"is_homoglyph\":" << boolToJson(result.is_homoglyph) << "," << "\"impersonated_brand\":\"" << escapeJson(result.impersonated_brand) << "\"," << "\"reasons\":[";

    for (size_t i = 0; i < result.heuristic_reasons.size(); ++i) {
        json << "\"" << escapeJson(result.heuristic_reasons[i]) << "\"";
        if (i + 1 < result.heuristic_reasons.size()) json << ",";
    }
    json << "]}";

    return json.str();
}

string WebProtectionServer::handleNudge(const string& query) {
    string cat = sanitize(urlDecode(getQueryParam(query, "cat")), 512);
    string file = sanitize(urlDecode(getQueryParam(query, "file")), 512);
    string url = sanitize(urlDecode(getQueryParam(query, "url")), 512);

    if (cat.empty() || !nudge_sink_) return R"({"ok":false,"error":"missing_params"})";

    NudgeCategory nc;
    if (cat == "downloaded_exe") nc = NudgeCategory::DownloadedExe;
    else if (cat == "macro_document") nc = NudgeCategory::MacroDocument;
    else if (cat == "suspicious_script") nc = NudgeCategory::SuspiciousScript;
    else return R"({"ok":false,"error":"unknown_cat"})";

    Nudge n;
    n.category = nc;
    n.detail = file;
    n.context = url;
    n.severity = (nc == NudgeCategory::DownloadedExe || nc == NudgeCategory::SuspiciousScript) ? "security" : "info";
    nudge_sink_->emit(n);
    return R"({"ok":true})";
}

string WebProtectionServer::sanitize(string s, size_t cap) {
    if (s.size() > cap) s.resize(cap);
    s.erase(std::remove_if(s.begin(), s.end(), [](unsigned char c){ return c < 0x20 && c != '\t'; }), s.end());
    return s;
}

string WebProtectionServer::handleStatus() const {
    auto& db = PhishingDb::instance();
    ostringstream json;
    json << "{" << "\"running\":true," << "\"threats_loaded\":" << db.threatCount() << "," << "\"safe_domains\":" << db.safeCount() << "," << "\"port\":" << port_ << "," << "\"version\":\"1.0.0\"" << "}";
    return json.str();
}

string WebProtectionServer::handleVersion() const { return R"({"version":"1.0.0","product":"Mentoring Protector"})"; }

string WebProtectionServer::buildResponse(int statusCode, const string& body, const string& allowedOrigin) {
    string statusText = (statusCode == 200) ? "OK" : "Error";

    ostringstream response;
    response << "HTTP/1.1 " << statusCode << " " << statusText << "\r\n" << "Content-Type: application/json; charset=utf-8\r\n" << "Content-Length: " << body.size() << "\r\n";

    if (!allowedOrigin.empty()) { response << "Access-Control-Allow-Origin: " << allowedOrigin << "\r\n" << "Access-Control-Allow-Methods: GET\r\n"; }

    response << "Connection: close\r\n" << "\r\n" << body;

    return response.str();
}

#ifndef MP_CHROME_EXT_ORIGIN
#define MP_CHROME_EXT_ORIGIN ""
#endif
#ifndef MP_FIREFOX_EXT_ORIGIN
#define MP_FIREFOX_EXT_ORIGIN ""
#endif

string WebProtectionServer::validateOrigin(const string& origin) {
    const bool isChrome = origin.rfind("chrome-extension://", 0) == 0, isFirefox = origin.rfind("moz-extension://", 0) == 0;
    if (!isChrome && !isFirefox) return "";

    constexpr string_view kChromeOrigin = MP_CHROME_EXT_ORIGIN, kFirefoxOrigin = MP_FIREFOX_EXT_ORIGIN;

    if (isChrome && !kChromeOrigin.empty() && origin != kChromeOrigin) return "";
    if (isFirefox && !kFirefoxOrigin.empty() && origin != kFirefoxOrigin) return "";

    return origin;
}

string WebProtectionServer::urlDecode(const string& encoded) {
    string result;
    result.reserve(encoded.size());

    for (size_t i = 0; i < encoded.size(); ++i) {
        if (encoded[i] == '%' && i + 2 < encoded.size()) {
            string hex = encoded.substr(i + 1, 2);
            try {
                char decoded = static_cast<char>(stoi(hex, nullptr, 16));
                result += decoded;
            } catch (...) { result += '%'; continue; }
            i += 2;
        } else if (encoded[i] == '+') { result += ' '; }
        else { result += encoded[i]; }
    }

    return result;
}

string WebProtectionServer::getQueryParam(const string& query, const string& param) {
    string key = param + "=";
    size_t pos = query.find(key);
    if (pos == string::npos) return "";

    size_t valueStart = pos + key.size();
    size_t valueEnd = query.find('&', valueStart);

    if (valueEnd == string::npos) return query.substr(valueStart);
    return query.substr(valueStart, valueEnd - valueStart);
}

string WebProtectionServer::getHeader(const string& request, const string& headerName) {
    string lineSearch = "\r\n" + headerName + ": ";
    string lineSearchLower = lineSearch;
    transform(lineSearchLower.begin(), lineSearchLower.end(), lineSearchLower.begin(), [](unsigned char c){ return tolower(c); });

    const size_t n = request.size(), m = lineSearchLower.size();
    size_t pos = string::npos;
    for (size_t i = 0; i + m <= n; ++i) {
        bool match = true;
        for (size_t j = 0; j < m && match; ++j) match = (tolower(static_cast<unsigned char>(request[i + j])) == lineSearchLower[j]);
        if (match) { pos = i; break; }
    }
    if (pos == string::npos) return "";

    size_t valueStart = pos + lineSearch.size(), valueEnd = request.find("\r\n", valueStart);
    if (valueEnd == string::npos) valueEnd = request.find("\n", valueStart);
    if (valueEnd == string::npos) valueEnd = request.length();

    return request.substr(valueStart, valueEnd - valueStart);
}

bool WebProtectionServer::parseRequestLine(const string& request, string& method, string& path, string& query) {
    size_t lineEnd = request.find("\r\n");
    string line = (lineEnd != string::npos) ? request.substr(0, lineEnd) : request;

    size_t sp1 = line.find(' ');
    if (sp1 == string::npos) return false;
    size_t sp2 = line.find(' ', sp1 + 1);
    if (sp2 == string::npos) return false;
    method = line.substr(0, sp1);
    string uri = line.substr(sp1 + 1, sp2 - sp1 - 1);

    size_t qPos = uri.find('?');
    if (qPos != string::npos) { path = uri.substr(0, qPos); query = uri.substr(qPos + 1); }
    else { path = uri; query = ""; }
    return !method.empty() && !path.empty();
}

bool WebProtectionServer::tryConsumeToken(const string& clientIP) {
    lock_guard<mutex> lock(rate_mutex_);
    if (rateBuckets_.size() >= RATE_LIMIT_MAX_ENTRIES && rateBuckets_.find(clientIP) == rateBuckets_.end()) {
        auto oldest = rateBuckets_.begin();
        auto oldestTime = oldest->second.lastRefill;
        for (auto it = rateBuckets_.begin(); it != rateBuckets_.end(); ++it) {
            if (it->second.lastRefill < oldestTime) { oldest = it; oldestTime = it->second.lastRefill; }
        }
        rateBuckets_.erase(oldest);
    }
    auto& bucket = rateBuckets_[clientIP];
    auto now = chrono::steady_clock::now();
    double elapsed = chrono::duration<double>(now - bucket.lastRefill).count();
    bucket.lastRefill = now;
    bucket.tokens += elapsed * RATE_LIMIT_REFILL_PER_SEC;
    if (bucket.tokens > RATE_LIMIT_MAX_TOKENS) bucket.tokens = RATE_LIMIT_MAX_TOKENS;

    if (bucket.tokens >= 1.0) { bucket.tokens -= 1.0; return true; }
    return false;
}
