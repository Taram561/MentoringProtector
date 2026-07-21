#pragma once
#include "../pch.h"
#include "../threat_info/threat_info.h"
#include "../heuristic/heuristic.h"
#include "../yara/yara_scanner.h"

struct ScanResult {
    bool is_infected = false;
    std::string file_path;
    std::string file_hash;
    std::string threat_name;
    std::string threat_type;
    int danger_level = 0;
    ThreatInfo threat_info;
    HeuristicResult heuristic;
    YaraResult yara;
    std::string detection_method;
    std::vector<std::string> engines_triggered;
};