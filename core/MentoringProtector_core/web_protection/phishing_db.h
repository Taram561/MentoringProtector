#pragma once
#include "../pch.h"
#include "bloom_filter.h"
#include <string>
#include <unordered_set>
#include <unordered_map>
#include <vector>
#include <mutex>

enum class DomainThreatType { None = 0, Phishing = 1, Malware = 2, Scam = 3, Cryptominer = 4, Tracking = 5 };

struct DomainRecord {
    std::string domain;
    DomainThreatType type = DomainThreatType::Phishing;
    int score = 0;
    std::string source;
};

class IPhishingDb {
public:
    virtual ~IPhishingDb() = default;
    virtual const DomainRecord* findThreat(const std::string& domain) const = 0;
    virtual bool isSafe(const std::string& domain) const = 0;
    virtual bool mightBePhishing(const std::string& domain) const = 0;
};

class PhishingDb : public IPhishingDb {
public:
    static PhishingDb& instance();
    bool loadFromFile(const std::string& path);
    bool loadSafeList(const std::string& path);
    const DomainRecord* findThreat(const std::string& domain) const;
    bool isSafe(const std::string& domain) const;

    size_t threatCount() const;
    size_t safeCount()   const;

    void addThreat(const DomainRecord& record);
    void addSafe(const std::string& domain);
    bool mightBePhishing(const std::string& domain) const;

    PhishingDb(const PhishingDb&) = delete;
    PhishingDb& operator=(const PhishingDb&) = delete;

private: PhishingDb() = default;
    void rebuildBloomFilter();

    mutable std::mutex mutex_;
    std::unordered_map<std::string, DomainRecord> threats_;
    std::unordered_set<std::string> safeList_;
    mentoring_protector::BloomFilter bloom_{100000, 0.01};

    static std::string normalizeDomain(const std::string& domain);
};