#pragma once
#include "pch.h"

struct RemovalStep {
    int step_number = 0;
    std::string description;
};
struct ThreatInfo {
    std::string name, display_name, type, description_short, description_full, how_it_spreads, what_it_does, recommended_action, hygiene_category;
    int danger_level = 0;
    std::vector<RemovalStep> removal_steps;
    std::vector<std::string> prevention_tips;
    bool is_found = false;
};
class ThreatDatabase {
public: 
    ThreatDatabase();
    ~ThreatDatabase();
    int loadFromFile(const std::string& json_path);
    ThreatInfo findByName(const std::string& threat_name) const;

    std::vector<ThreatInfo> findByType(const std::string& type) const;
    size_t getCount() const;
    bool isLoaded() const;
    static ThreatInfo createUnknown(const std::string& threat_name);

private:
    std::unordered_map<std::string, ThreatInfo> threats_;
    bool is_loaded_ = false;
    std::string extractJsonString(const std::string& json, const std::string& key) const;
    int extractJsonInt(const std::string& json, const std::string& key) const;
    std::vector<std::string> extractJsonArray(const std::string& json, const std::string& key) const;
    ThreatInfo parseOneThreat(const std::string& json_block) const;
};