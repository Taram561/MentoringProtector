#include "pch.h"
#include "web_protection_exports.h"
#include "phishing_db.h"
#include "url_checker.h"
#include "http_server.h"
#include "auth_token.h"
#include "../json_utils.h"
#include "../nudge/inudge_sink.h"
#include "../exports.h"
#include <memory>

using namespace std;

static INudgeSink* g_wp_nudge_sink = nullptr;

void web_protection_set_nudge_sink(INudgeSink* sink) {
    g_wp_nudge_sink = sink;
}

static string getWpBaseDir() {
    char path[MAX_PATH] = {};
    HMODULE hm = NULL;
    GetModuleHandleExA(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS | GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT, (LPCSTR)&getWpBaseDir, &hm);
    GetModuleFileNameA(hm, path, MAX_PATH);
    string dllDir(path);
    auto pos = dllDir.find_last_of("\\/");
    if (pos != string::npos) dllDir = dllDir.substr(0, pos + 1);

    DWORD attr = GetFileAttributesA((dllDir + "data").c_str());
    if (attr != INVALID_FILE_ATTRIBUTES && (attr & FILE_ATTRIBUTE_DIRECTORY)) return dllDir;

    return "..\\";
}

static unique_ptr<UrlChecker> g_checker;
static unique_ptr<WebProtectionServer> g_server;

int web_protection_start(const char* phishingDbPath, const char* safeListPath) {
    try {
        auto& db = PhishingDb::instance();
        if (phishingDbPath && phishingDbPath[0]) db.loadFromFile(phishingDbPath);
        if (safeListPath && safeListPath[0]) db.loadSafeList(safeListPath);

        mentoring_protector::AuthToken::getInstance().initialize((getWpBaseDir() + "data").c_str());
        g_checker = make_unique<UrlChecker>(db);

        if (isServiceHosting()) return 1;

        g_server = make_unique<WebProtectionServer>(*g_checker, g_wp_nudge_sink);
        return g_server->start() ? 1 : 0;

    } catch (...) { return 0; }
}

void web_protection_stop() { if (g_server) g_server->stop(); }

int web_protection_is_running() {
    bool realtime = false, web = false;
    if (serviceQueryStatus(realtime, web)) return web ? 1 : 0;
    return (g_server && g_server->isRunning()) ? 1 : 0;
}

char* web_protection_check_url(const char* url) {
    if (!url || !g_checker) {
        static const char* empty = R"({"safe":true,"reason":"clean","score":0,"domain":"","detail":""})";
        char* result = new char[strlen(empty) + 1];
        strcpy_s(result, strlen(empty) + 1, empty);
        return result;
    }
    try {
        UrlCheckResult r = g_checker->check(url);

        string json;
        json += "{\"safe\":" + string(json_utils::boolToJson(r.safe)) + ",\"reason\":\"" + json_utils::escapeJson(r.reason) + "\",\"score\":" + to_string(r.score) + ",\"domain\":\"" + json_utils::escapeJson(r.domain) + "\",\"detail\":\"" + json_utils::escapeJson(r.detail) + "\"}";

        char* result = new char[json.size() + 1];
        memcpy(result, json.c_str(), json.size() + 1);
        return result;

    } catch (...) { return nullptr; }
}

int web_protection_threats_count() { return static_cast<int>(PhishingDb::instance().threatCount()); }

int web_protection_reload_db(const char* phishingDbPath) {
    if (!phishingDbPath) return 0;
    return PhishingDb::instance().loadFromFile(phishingDbPath) ? 1 : 0;
}

char* web_protection_get_auth_token() {
    string token = mentoring_protector::AuthToken::getInstance().getToken();
    char* result = new char[token.size() + 1];
    memcpy(result, token.c_str(), token.size() + 1);
    return result;
}

int web_protection_regenerate_token() { return mentoring_protector::AuthToken::getInstance().regenerate() ? 1 : 0; }