#include "pch.h"
#include "url_checker.h"
#include "../stats/stats_recorder.h"
#include <algorithm>
#include <regex>
#include <cctype>

using namespace std;

const vector<string> UrlChecker::SUSPICIOUS_KEYWORDS = { "login", "signin", "account", "secure", "update", "verify", "confirm", "banking", "paypal", "apple-id", "microsoft", "google-security", "amazon-help", "netflix-billing", "free-gift", "prize", "winner", "lucky", "casino", "crack", "keygen", "serial", "patch", "activator", "download-free", "torrent", "phishing", "malware", "exploit", "ransomware" };

const vector<string> UrlChecker::SUSPICIOUS_TLDS = { ".xyz", ".tk", ".ml", ".ga", ".cf", ".gq", ".top", ".click", ".download", ".work", ".loan", ".party", ".stream", ".science", ".faith" };

const vector<string> UrlChecker::BRAND_TYPOS = { "paypa1", "paypal-", "g00gle", "arnazon", "amazzon", "micros0ft", "app1e", "faceb00k", "vvhatsapp", "sberbank-", "tinkoff-", "tebank-", "gosuslugi-" };

UrlChecker::UrlChecker(IPhishingDb& db) : db_(db) {}

string UrlChecker::extractDomain(const string& url) {
    string u = url;
    size_t schemeEnd = u.find("://");
    if (schemeEnd != string::npos) u = u.substr(schemeEnd + 3);
    for (char c : {'/', '?', '#', ':'}) {
        size_t pos = u.find(c);
        if (pos != string::npos) u = u.substr(0, pos);
    }
    transform(u.begin(), u.end(), u.begin(), [](unsigned char c) { return static_cast<char>(tolower(c)); });
    return u;
}

bool UrlChecker::isHttps(const string& url) { return url.size() >= 8 && url.substr(0, 8) == "https://"; }

int UrlChecker::heuristicScore(const string& url, const string& domain) {
    int score = 0;
    string urlLower = url;
    transform(urlLower.begin(), urlLower.end(), urlLower.begin(), [](unsigned char c) { return static_cast<char>(tolower(c)); });

    if (!isHttps(url)) score += 10;
    static const regex ipPattern(R"(^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$)");
    if (regex_match(domain, ipPattern)) score += 35;
    for (const auto& tld : SUSPICIOUS_TLDS) {
        if (domain.size() >= tld.size() && domain.substr(domain.size() - tld.size()) == tld) { score += 20; break; }
    }
    for (const auto& typo : BRAND_TYPOS) {
        if (urlLower.find(typo) != string::npos) { score += 40; break; }
    }
    int keywordHits = 0;
    for (const auto& keyword : SUSPICIOUS_KEYWORDS) if (urlLower.find(keyword) != string::npos) ++keywordHits;
    score += min(keywordHits * 10, 30);

    int dashCount = static_cast<int>(count(domain.begin(), domain.end(), '-'));
    if (dashCount >= 3) score += 15;
    if (domain.size() > 40) score += 10;
    int dotCount = static_cast<int>(count(domain.begin(), domain.end(), '.'));
    if (dotCount >= 4) score += 15;
    int digitCount = 0;
    for (char c : domain) if (isdigit(static_cast<unsigned char>(c))) ++digitCount;
    if (digitCount >= 3) score += 10;

    return min(score, 100);
}

string UrlChecker::threatTypeToString(DomainThreatType type) {
    switch (type) {
    case DomainThreatType::Phishing: return "phishing";
    case DomainThreatType::Malware: return "malware";
    case DomainThreatType::Scam: return "scam";
    case DomainThreatType::Cryptominer: return "cryptominer";
    case DomainThreatType::Tracking: return "tracking";
    default: return "unknown";
    }
}

UrlCheckResult UrlChecker::check(const string& url) const {
    UrlCheckResult result;
    result.domain = extractDomain(url);
    result.safe = true;
    result.reason = "clean";
    result.score = 0;
    result.detail = "";

    if (url.empty() || result.domain.empty()) return result;

    if (db_.isSafe(result.domain)) { result.safe = true; result.reason = "clean"; result.score = 0; result.detail = "Domain is in trusted list"; return result; }

    if (db_.mightBePhishing(result.domain)) {
        const DomainRecord* threat = db_.findThreat(result.domain);
        if (threat != nullptr) { result.safe = false; result.reason = threatTypeToString(threat->type); result.score = threat->score; result.detail = "Found in threat database (" + threat->source + ")"; stats::StatsRecorder::instance().recordThreat(stats::StatsRecorder::Source::kWeb); return result; }
    }

    int hScore = heuristicScore(url, result.domain);
    auto advanced = advancedHeuristics_.analyze(url);
    hScore = max(hScore, advanced.score);

    if (advanced.is_homoglyph) { result.is_homoglyph = true; result.impersonated_brand = advanced.impersonated_brand; }
    result.heuristic_reasons = advanced.reasons;

    if (hScore >= 50) { result.safe = false; result.reason = "suspicious"; result.score = hScore; result.detail = advanced.reasons.empty() ? "Suspicious URL patterns detected" : advanced.reasons[0]; stats::StatsRecorder::instance().recordThreat(stats::StatsRecorder::Source::kWeb); return result; }
    result.safe = true;
    result.reason = "clean";
    result.score = hScore;
    return result;
}
