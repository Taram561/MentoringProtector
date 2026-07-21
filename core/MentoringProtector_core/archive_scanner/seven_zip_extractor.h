#pragma once
#include "iextractor.h"
#include <windows.h>

class SevenZipExtractor : public IExtractor {
public:
    explicit SevenZipExtractor(const std::wstring& dll_dir);
    ~SevenZipExtractor() override;

    SevenZipExtractor(const SevenZipExtractor&) = delete;
    SevenZipExtractor& operator=(const SevenZipExtractor&) = delete;
    bool canHandle(const std::wstring& path) const override;
    ExtractionResult extract(const std::wstring& path, const std::wstring& dest_dir, const ArchiveLimits& limits) override;
    bool isAvailable() const { return dll_ != nullptr; }

private:
    HMODULE dll_ = nullptr;
    using CreateObjectFunc = HRESULT(WINAPI*)(const GUID*, const GUID*, void**);
    CreateObjectFunc createObject_ = nullptr;
    bool hasExtension(const std::wstring& path, const std::wstring& ext) const;
};