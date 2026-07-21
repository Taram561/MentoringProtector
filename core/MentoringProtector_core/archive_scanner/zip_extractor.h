#pragma once
#include "iextractor.h"

class ZipExtractor : public IExtractor {
public:
    ZipExtractor() = default;
    ~ZipExtractor() override = default;
    bool canHandle(const std::wstring& path) const override;
    ExtractionResult extract(const std::wstring& path, const std::wstring& dest_dir, const ArchiveLimits& limits) override;
private:
    bool hasPkMagic(const std::wstring& path) const;
};