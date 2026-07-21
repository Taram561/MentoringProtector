#pragma once

#include <string>
#include <vector>
#include <unordered_set>
#include <unordered_map>
#include <regex>

namespace mentoring_protector {

struct HeuristicResult {
    int score = 0;
    std::vector<std::string> reasons;
    bool is_homoglyph = false;
    std::string decoded_domain;
    std::string impersonated_brand;
};

class UrlHeuristics {
public: UrlHeuristics();
    HeuristicResult analyze(const std::string& url) const;

private:
    bool hasMixedScripts(const std::string& domain) const;

    std::string decodePunycode(const std::string& encoded) const;
    std::string normalizeHomoglyphs(const std::string& domain) const;
    std::string detectBrandImpersonation(const std::string& normalized_domain) const;

    void checkHomoglyphs(const std::string& domain, HeuristicResult& result) const;
    bool isIPAddress(const std::string& host) const;
    bool isObfuscatedIP(const std::string& host) const;
    void checkIPAddress(const std::string& host, HeuristicResult& result) const;
    void checkSuspiciousTLD(const std::string& domain, HeuristicResult& result) const;
    void checkDomainStructure(const std::string& domain, HeuristicResult& result) const;
    void checkPathPatterns(const std::string& path, HeuristicResult& result) const;
    void checkObfuscation(const std::string& url, HeuristicResult& result) const;

    std::string extractHost(const std::string& url) const;
    std::string extractPath(const std::string& url) const;
    std::string extractTLD(const std::string& domain) const;
    std::string toLower(const std::string& str) const;
    std::unordered_map<uint32_t, char> m_homoglyphMap;
    std::unordered_set<std::string> m_protectedBrands;
    std::unordered_map<std::string, int> m_suspiciousTLDs;
    std::vector<std::string> m_phishingKeywords;

    void initHomoglyphMap();
    void initProtectedBrands();
    void initSuspiciousTLDs();
    void initPhishingKeywords();
};

}