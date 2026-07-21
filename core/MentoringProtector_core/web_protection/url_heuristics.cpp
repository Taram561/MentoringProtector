#include "pch.h"
#include "url_heuristics.h"
#include <algorithm>
#include <sstream>
#include <cctype>
#include <cmath>
#include <numeric>

using namespace std;
namespace mentoring_protector {

UrlHeuristics::UrlHeuristics() {
    initHomoglyphMap();
    initProtectedBrands();
    initSuspiciousTLDs();
    initPhishingKeywords();
}

HeuristicResult UrlHeuristics::analyze(const string& url) const {
    HeuristicResult result;
    result.score = 0;
    result.is_homoglyph = false;
    string lowerUrl = toLower(url);
    string host = extractHost(lowerUrl), path = extractPath(lowerUrl);
    checkHomoglyphs(host, result);
    checkIPAddress(host, result);
    checkSuspiciousTLD(host, result);
    checkDomainStructure(host, result);
    checkPathPatterns(path, result);
    checkObfuscation(url, result);
    result.score = min(result.score, 100);
    result.score = max(result.score, 0);
    return result;
}

void UrlHeuristics::checkHomoglyphs(const string& domain, HeuristicResult& result) const {
    bool hasPunycode = domain.find("xn--") != string::npos;
    if (hasMixedScripts(domain) || hasPunycode) {
        string normalized = normalizeHomoglyphs(domain);
        string brand = detectBrandImpersonation(normalized);
        if (!brand.empty()) { result.score += 40; result.is_homoglyph = true; result.impersonated_brand = brand; result.decoded_domain = normalized; result.reasons.push_back("Гомоглиф-атака: домен имитирует \"" + brand + "\" используя похожие символы из другого алфавита"); }
        else if (hasMixedScripts(domain)) { result.score += 15; result.reasons.push_back("Домен содержит символы из разных алфавитов (смешанные скрипты)"); }
    }
}

bool UrlHeuristics::hasMixedScripts(const string& domain) const {
    bool hasLatin = false, hasNonLatin = false;
    for (size_t i = 0; i < domain.size(); ++i) {
        unsigned char c = static_cast<unsigned char>(domain[i]);
        if (c < 0x80) { if (isalpha(c)) hasLatin = true; }
        else if (c >= 0xC0) hasNonLatin = true;
        if (hasLatin && hasNonLatin) return true;
    }
    return false;
}

string UrlHeuristics::normalizeHomoglyphs(const string& domain) const {
    string result;
    result.reserve(domain.size());
    for (size_t i = 0; i < domain.size(); ) {
        unsigned char c = static_cast<unsigned char>(domain[i]);
        if (c < 0x80) { result += static_cast<char>(c); ++i; }
        else if (c >= 0xC0 && c < 0xE0 && i + 1 < domain.size()) {
            uint32_t codepoint = (c & 0x1F) << 6 | (static_cast<unsigned char>(domain[i+1]) & 0x3F);
            auto it = m_homoglyphMap.find(codepoint);
            if (it != m_homoglyphMap.end()) result += it->second;
            else { result += domain[i]; result += domain[i+1]; }
            i += 2;
        } else if (c >= 0xE0 && c < 0xF0 && i + 2 < domain.size()) {
            uint32_t codepoint = (c & 0x0F) << 12 | (static_cast<unsigned char>(domain[i+1]) & 0x3F) << 6 | (static_cast<unsigned char>(domain[i+2]) & 0x3F);
            auto it = m_homoglyphMap.find(codepoint);
            if (it != m_homoglyphMap.end()) result += it->second;
            else { result += domain[i]; result += domain[i+1]; result += domain[i+2]; }
            i += 3;
        } else { result += static_cast<char>(c); ++i; }
    }
    return result;
}

string UrlHeuristics::detectBrandImpersonation(const string& normalized_domain) const {
    istringstream ss(normalized_domain);
    string part;
    while (getline(ss, part, '.')) if (m_protectedBrands.count(part) > 0) return part;
    return "";
}

void UrlHeuristics::checkIPAddress(const string& host, HeuristicResult& result) const {
    if (isIPAddress(host)) { result.score += 30; result.reasons.push_back("Используется IP-адрес вместо доменного имени - типичный признак фишинга"); }
    else if (isObfuscatedIP(host)) { result.score += 35; result.reasons.push_back("Используется обфусцированный IP-адрес (hex/decimal/octal)"); }
}

bool UrlHeuristics::isIPAddress(const string& host) const {
    int parts[4] = {0}, count = 0;
    istringstream ss(host);
    string segment;
    while (getline(ss, segment, '.') && count < 4) {
        if (segment.empty() || segment.length() > 3) return false;
        bool allDigits = all_of(segment.begin(), segment.end(), ::isdigit);
        if (!allDigits) return false;
        int val = 0;
        try { val = stoi(segment); } catch (...) { return false; }
        if (val < 0 || val > 255) return false;
        parts[count++] = val;
    }
    if (host.front() == '[' && host.back() == ']') return true;
    return count == 4;
}

bool UrlHeuristics::isObfuscatedIP(const string& host) const {
    if (host.length() > 2 && host[0] == '0' && (host[1] == 'x' || host[1] == 'X')) {
        bool allHex = all_of(host.begin() + 2, host.end(), [](char c) { return isxdigit(c); });
        if (allHex && host.length() <= 10) return true;
    }
    if (all_of(host.begin(), host.end(), ::isdigit) && host.length() >= 7) {
        try {
            unsigned long long val = stoull(host);
            if (val > 16777215ULL && val <= 4294967295ULL) return true;
        } catch (...) {}
    }
    if (host.find('.') != string::npos) {
        istringstream ss(host);
        string seg;
        int octalCount = 0;
        while (getline(ss, seg, '.')) {
            if (seg.length() > 1 && seg[0] == '0' && all_of(seg.begin(), seg.end(), [](char c) { return c >= '0' && c <= '7'; })) octalCount++;
        }
        if (octalCount >= 2) return true;
    }
    return false;
}

void UrlHeuristics::checkSuspiciousTLD(const string& domain, HeuristicResult& result) const {
    string tld = extractTLD(domain);
    auto it = m_suspiciousTLDs.find(tld);
    if (it != m_suspiciousTLDs.end()) { result.score += it->second; result.reasons.push_back("Домен использует подозрительный TLD ." + tld + " - часто используется для фишинга"); }
}

void UrlHeuristics::checkDomainStructure(const string& domain, HeuristicResult& result) const {
    int dotCount = static_cast<int>(count(domain.begin(), domain.end(), '.'));
    if (dotCount > 3) { result.score += 10; result.reasons.push_back("Слишком много поддоменов (" + to_string(dotCount) + ") - типичная маскировка фишинга"); }
    if (domain.length() > 50) { result.score += 5; result.reasons.push_back("Подозрительно длинное доменное имя (" + to_string(domain.length()) + " символов)"); }
    int hyphenCount = static_cast<int>(count(domain.begin(), domain.end(), '-'));
    if (hyphenCount >= 3) { result.score += 10; result.reasons.push_back("Множество дефисов в домене - типичный паттерн фишинга"); }
    for (const auto& brand : m_protectedBrands) {
        if (domain.find(brand) != string::npos && domain != brand) { result.score += 15; result.reasons.push_back("Доменное имя содержит название бренда \"" + brand + "\" но не является его официальным доменом"); break; }
    }
}

void UrlHeuristics::checkPathPatterns(const string& path, HeuristicResult& result) const {
    if (path.empty() || path == "/") return;

    int keywordHits = 0;
    for (const auto& keyword : m_phishingKeywords) if (path.find(keyword) != string::npos) keywordHits++;
    if (keywordHits >= 2) { int bonus = min(keywordHits * 8, 25); result.score += bonus; result.reasons.push_back("Путь URL содержит " + to_string(keywordHits) + " фишинговых ключевых слов"); }

    vector<string> badExtensions = { ".exe", ".msi", ".bat", ".cmd", ".scr", ".pif", ".com", ".vbs", ".js", ".wsf", ".ps1" };
    for (const auto& ext : badExtensions) {
        if (path.length() > ext.length() && path.substr(path.length() - ext.length()) == ext) { result.score += 10; result.reasons.push_back("URL указывает на потенциально опасный файл (*" + ext + ")"); break; }
    }
}

void UrlHeuristics::checkObfuscation(const string& url, HeuristicResult& result) const {
    size_t atPos = url.find('@'), schemeEnd = url.find("://");
    if (atPos != string::npos && schemeEnd != string::npos && atPos > schemeEnd + 3) { result.score += 20; result.reasons.push_back("URL содержит '@' - возможная маскировка реального домена (basic auth trick)"); }
    if (url.find("%25") != string::npos) { result.score += 10; result.reasons.push_back("Обнаружено двойное URL-кодирование - попытка обхода фильтров"); }

    string hostPart = url.substr(0, url.find('/', (schemeEnd != string::npos) ? schemeEnd + 3 : 0));
    if (hostPart.find("%2f") != string::npos || hostPart.find("%2F") != string::npos || hostPart.find("%2e") != string::npos || hostPart.find("%2E") != string::npos) { result.score += 15; result.reasons.push_back("Домен содержит URL-кодированные разделители - обфускация"); }
}

string UrlHeuristics::extractHost(const string& url) const {
    size_t start = url.find("://");
    if (start == string::npos) start = 0; else start += 3;
    size_t at = url.find('@', start);
    if (at != string::npos) start = at + 1;
    size_t end = url.find('/', start);
    if (end == string::npos) end = url.find('?', start);
    if (end == string::npos) end = url.length();
    string host = url.substr(start, end - start);
    size_t colon = host.rfind(':');
    if (colon != string::npos) {
        string port = host.substr(colon + 1);
        if (all_of(port.begin(), port.end(), ::isdigit)) host = host.substr(0, colon);
    }
    return host;
}

string UrlHeuristics::extractPath(const string& url) const {
    size_t start = url.find("://");
    if (start == string::npos) start = 0; else start += 3;
    size_t pathStart = url.find('/', start);
    if (pathStart == string::npos) return "/";
    return url.substr(pathStart);
}

string UrlHeuristics::extractTLD(const string& domain) const {
    size_t lastDot = domain.rfind('.');
    if (lastDot == string::npos || lastDot == domain.length() - 1) return "";
    return domain.substr(lastDot + 1);
}

string UrlHeuristics::toLower(const string& str) const {
    string result = str;
    transform(result.begin(), result.end(), result.begin(), ::tolower);
    return result;
}

void UrlHeuristics::initHomoglyphMap() {
    m_homoglyphMap[0x0430] = 'a'; m_homoglyphMap[0x0435] = 'e'; m_homoglyphMap[0x043E] = 'o';
    m_homoglyphMap[0x0440] = 'p'; m_homoglyphMap[0x0441] = 'c'; m_homoglyphMap[0x0443] = 'y';
    m_homoglyphMap[0x0445] = 'x'; m_homoglyphMap[0x0456] = 'i'; m_homoglyphMap[0x0458] = 'j';
    m_homoglyphMap[0x0455] = 's'; m_homoglyphMap[0x04BB] = 'h'; m_homoglyphMap[0x0432] = 'b';
    m_homoglyphMap[0x043D] = 'h'; m_homoglyphMap[0x0442] = 't';
    m_homoglyphMap[0x03BF] = 'o'; m_homoglyphMap[0x03B1] = 'a'; m_homoglyphMap[0x03B5] = 'e';
    m_homoglyphMap[0x03C1] = 'p'; m_homoglyphMap[0x03C4] = 't'; m_homoglyphMap[0x03BD] = 'v';
    m_homoglyphMap[0x0131] = 'i'; m_homoglyphMap[0x0142] = 'l'; m_homoglyphMap[0x00F8] = 'o';
}

void UrlHeuristics::initProtectedBrands() { m_protectedBrands = { "paypal", "google", "apple", "microsoft", "amazon", "facebook", "instagram", "twitter", "netflix", "whatsapp", "telegram", "linkedin", "dropbox", "github", "outlook", "yahoo", "ebay", "aliexpress", "alibaba", "tiktok", "spotify", "steam", "epic", "riot", "twitch", "discord", "sberbank", "tinkoff", "vtb", "yandex", "mailru", "gosuslugi", "nalog", "mos", "chase", "wellsfargo", "bankofamerica", "citibank", "hsbc", "barclays", "revolut", "wise", "binance", "coinbase", "kraken" }; }

void UrlHeuristics::initSuspiciousTLDs() {
    m_suspiciousTLDs["tk"] = 20; m_suspiciousTLDs["ml"] = 20; m_suspiciousTLDs["ga"] = 20;
    m_suspiciousTLDs["cf"] = 20; m_suspiciousTLDs["gq"] = 20;
    m_suspiciousTLDs["xyz"] = 12; m_suspiciousTLDs["top"] = 12; m_suspiciousTLDs["work"] = 12;
    m_suspiciousTLDs["click"] = 15; m_suspiciousTLDs["link"] = 10; m_suspiciousTLDs["buzz"] = 12;
    m_suspiciousTLDs["icu"] = 15; m_suspiciousTLDs["surf"] = 10; m_suspiciousTLDs["rest"] = 10;
    m_suspiciousTLDs["pw"] = 8; m_suspiciousTLDs["cc"] = 5; m_suspiciousTLDs["ws"] = 5; m_suspiciousTLDs["nu"] = 5;
}

void UrlHeuristics::initPhishingKeywords() { m_phishingKeywords = { "login", "signin", "sign-in", "log-in", "account", "verify", "verification", "secure", "security", "update", "confirm", "confirmation", "banking", "bank", "password", "passwd", "credential", "wallet", "payment", "restore", "recovery", "recover", "suspend", "suspended", "unusual", "unlock", "locked", "limit", "wp-admin", "wp-login", "admin", "cgi-bin", "webscr" }; }

string UrlHeuristics::decodePunycode(const string& encoded) const { return encoded; }
}
