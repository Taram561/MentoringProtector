#include "pch.h"
#include "phishing_db.h"
#include <fstream>
#include <sstream>
#include <algorithm>
#include <cctype>

using namespace std;

PhishingDb& PhishingDb::instance() {
    static PhishingDb inst;
    return inst;
}

string PhishingDb::normalizeDomain(const string& domain) {
    string d = domain;
    transform(d.begin(), d.end(), d.begin(), [](unsigned char c) { return static_cast<char>(tolower(c)); });
    if (d.substr(0, 4) == "www.") d = d.substr(4);
    if (!d.empty() && d.back() == '/') d.pop_back();
    return d;
}

bool PhishingDb::loadFromFile(const string& path) {
    ifstream file(path);
    if (!file.is_open()) return false;

    lock_guard<mutex> lock(mutex_);
    threats_.clear();
    string line;
    size_t loaded = 0;

    while (getline(file, line)) {
        if (line.empty() || line[0] == '#') continue;
        istringstream ss(line);
        string domain, typeStr, scoreStr, source;
        getline(ss, domain, '\t');
        getline(ss, typeStr, '\t');
        getline(ss, scoreStr, '\t');
        getline(ss, source, '\t');

        if (domain.empty()) continue;

        DomainRecord record;
        record.domain = normalizeDomain(domain);
        record.source = source.empty() ? "Unknown" : source;
        record.score = scoreStr.empty() ? 75 : stoi(scoreStr);

        if (typeStr == "phishing") record.type = DomainThreatType::Phishing;
        else if (typeStr == "malware") record.type = DomainThreatType::Malware;
        else if (typeStr == "scam") record.type = DomainThreatType::Scam;
        else if (typeStr == "cryptominer") record.type = DomainThreatType::Cryptominer;
        else if (typeStr == "tracking") record.type = DomainThreatType::Tracking;
        else record.type = DomainThreatType::Phishing;

        threats_[record.domain] = record;
        ++loaded;
    }
    if (loaded > 0) rebuildBloomFilter();
    return loaded > 0;
}

bool PhishingDb::loadSafeList(const string& path) {
    ifstream file(path);
    if (!file.is_open()) return false;
    lock_guard<mutex> lock(mutex_);
    safeList_.clear();
    string line;
    while (getline(file, line)) {
        if (line.empty() || line[0] == '#') continue;
        safeList_.insert(normalizeDomain(line));
    }
    return !safeList_.empty();
}

const DomainRecord* PhishingDb::findThreat(const string& domain) const {
    lock_guard<mutex> lock(mutex_);
    string norm = normalizeDomain(domain);

    auto it = threats_.find(norm);
    if (it != threats_.end()) return &it->second;

    size_t dot = norm.find('.');
    if (dot != string::npos) {
        string parent = norm.substr(dot + 1);
        it = threats_.find(parent);
        if (it != threats_.end()) return &it->second;
    }
    return nullptr;
}

bool PhishingDb::isSafe(const string& domain) const {
    lock_guard<mutex> lock(mutex_);
    return safeList_.count(normalizeDomain(domain)) > 0;
}

size_t PhishingDb::threatCount() const {
    lock_guard<mutex> lock(mutex_);
    return threats_.size();
}

size_t PhishingDb::safeCount() const {
    lock_guard<mutex> lock(mutex_);
    return safeList_.size();
}

void PhishingDb::addThreat(const DomainRecord& record) {
    lock_guard<mutex> lock(mutex_);
    string norm = normalizeDomain(record.domain);
    threats_[norm] = record;
    bloom_.add(norm);
}

void PhishingDb::addSafe(const string& domain) {
    lock_guard<mutex> lock(mutex_);
    safeList_.insert(normalizeDomain(domain));
}

bool PhishingDb::mightBePhishing(const string& domain) const { return bloom_.mightContain(normalizeDomain(domain)); }

void PhishingDb::rebuildBloomFilter() {
    bloom_.clear();
    for (const auto& [domain, record] : threats_) bloom_.add(domain);
}