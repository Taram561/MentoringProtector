#pragma once
#include <string>

struct ScanEngineResult {
    bool is_threat = false;
    int score = 0;
    std::string threat_name;
    std::string engine_name;
};

class IScanEngine {
public: virtual ~IScanEngine() = default;
    virtual ScanEngineResult scan(const std::string& file_path) = 0;
    virtual bool isAvailable() const = 0;
    virtual std::string name() const = 0;
};