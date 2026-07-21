#pragma once
#include "../pch.h"
#include "phishing_db.h"
#include "url_heuristics.h"
#include <string>

struct UrlCheckResult {
    bool safe = true;
    std::string reason;
    int score = 0;
    std::string domain;
    std::string detail;
    bool is_homoglyph = false;
    std::string impersonated_brand;
    std::vector<std::string> heuristic_reasons;
};

class UrlChecker {
public: explicit UrlChecker(IPhishingDb& db);

    UrlCheckResult check(const std::string& url) const;
    static std::string extractDomain(const std::string& url);
    static bool isHttps(const std::string& url);
    static int heuristicScore(const std::string& url, const std::string& domain);

private: IPhishingDb& db_;
    mentoring_protector::UrlHeuristics advancedHeuristics_;

    static const std::vector<std::string> SUSPICIOUS_KEYWORDS;
    static const std::vector<std::string> SUSPICIOUS_TLDS;
    static const std::vector<std::string> BRAND_TYPOS;

    static std::string threatTypeToString(DomainThreatType type);
};