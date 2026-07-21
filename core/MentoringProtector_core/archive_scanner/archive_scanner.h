#pragma once
#include "../pch.h"
#include "../scanner/scan_result.h"
#include "iextractor.h"
#include <functional>
#include <memory>
#include <vector>
#include <string>

class ArchiveScanner {
public:
    using ScanCallback = std::function<ScanResult(const std::string&)>;

    ArchiveScanner() = default;
    ~ArchiveScanner() = default;

    ArchiveScanner(const ArchiveScanner&) = delete;
    ArchiveScanner& operator=(const ArchiveScanner&) = delete;
    void addExtractor(std::unique_ptr<IExtractor> extractor);
    void setScanCallback(ScanCallback cb);
    ScanResult scanArchive(const std::string& archive_path, int depth = 0);
    int getSupportedFormatsMask() const;
    void setBaseExtractionDir(const std::wstring& dir);

private:
    std::vector<std::unique_ptr<IExtractor>> extractors_;
    ScanCallback scan_cb_;
    ArchiveLimits limits_;
    std::wstring base_extraction_dir_;
    std::wstring createTempDir() const;
    void removeTempDir(const std::wstring& path) const;
};