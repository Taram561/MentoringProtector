#pragma once
#include <string>
#include <vector>
#include <cstdint>

struct ExtractedFile {
    std::wstring inner_path;
    std::wstring local_path;
    uint64_t original_size = 0;
};

struct ExtractionResult {
    bool ok = false;
    std::string error;
    std::vector<ExtractedFile> files;
};

struct ArchiveLimits {
    int max_depth = 3;
    int max_files = 10000;
    uint64_t max_size_bytes = 512ULL * 1024 * 1024;
    float max_ratio = 100.0f;
    int timeout_seconds = 30;
};

class IExtractor {
public:
    virtual ~IExtractor() = default;
    virtual bool canHandle(const std::wstring& path) const = 0;
    virtual ExtractionResult extract(const std::wstring& path, const std::wstring& dest_dir, const ArchiveLimits& limits) = 0;
};