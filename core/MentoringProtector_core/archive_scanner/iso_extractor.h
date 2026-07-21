#pragma once
#include "iextractor.h"
#include <windows.h>

class IsoExtractor : public IExtractor {
public:
    IsoExtractor() = default;
    ~IsoExtractor() override = default;

    bool canHandle(const std::wstring& path) const override;
    ExtractionResult extract(const std::wstring& path, const std::wstring& dest_dir, const ArchiveLimits& limits) override;

private:
    bool hasExtension(const std::wstring& path, const std::wstring& ext) const;
    void copyDirRecursive(const std::wstring& src_dir, const std::wstring& dst_dir, ExtractionResult& result, const ArchiveLimits& limits, int& fileCount, uint64_t& totalBytes) const;
};