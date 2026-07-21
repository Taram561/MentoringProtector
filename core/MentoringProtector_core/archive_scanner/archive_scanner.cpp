#include "pch.h"
#include "archive_scanner.h"
#include "../unicode_utils.h"
#include "../logger/logger.h"
#include <objbase.h>
#include <sstream>
#include <filesystem>
#include <algorithm>

namespace fs = std::filesystem;
using namespace std;

struct TempDirGuard {
    std::wstring path;
    ~TempDirGuard() {
        if (!path.empty()) {
            try { fs::remove_all(path); } catch (...) {}
        }
    }
};

void ArchiveScanner::addExtractor(unique_ptr<IExtractor> extractor) {
    if (extractor) extractors_.push_back(move(extractor));
}

void ArchiveScanner::setScanCallback(ScanCallback cb) {
    scan_cb_ = move(cb);
}

int ArchiveScanner::getSupportedFormatsMask() const {
    int mask = 0;
    for (const auto& ex : extractors_) {
        if (ex->canHandle(L"test.zip")) mask |= 1;
        if (ex->canHandle(L"test.7z")) mask |= 2;
        if (ex->canHandle(L"test.iso")) mask |= 4;
    }
    return mask;
}

ScanResult ArchiveScanner::scanArchive(const string& archive_path, int depth) {
    ScanResult clean;
    clean.file_path = archive_path;
    clean.detection_method = "clean";

    if (depth > limits_.max_depth) return clean;
    if (!scan_cb_) return clean;

    wstring wpath = unicode_utils::utf8_to_wide(archive_path);
    IExtractor* extractor = nullptr;
    for (auto& ex : extractors_) {
        if (ex->canHandle(wpath)) { extractor = ex.get(); break; }
    }
    if (!extractor) return clean;

    wstring tmpDir = createTempDir();
    if (tmpDir.empty()) return clean;
    TempDirGuard guard{ tmpDir };

    ExtractionResult extracted = extractor->extract(wpath, tmpDir, limits_);
    Logger::instance().debug("ArchiveScanner", "extract ok=" + string(extracted.ok ? "1" : "0") + " files=" + to_string(extracted.files.size()) + " error=" + extracted.error + " path=" + archive_path);
    if (!extracted.ok && extracted.files.empty()) return clean;

    ScanResult best = clean;

    for (const auto& ef : extracted.files) {
        string localUtf8 = unicode_utils::wide_to_utf8(ef.local_path);
        if (localUtf8.empty()) continue;

        ScanResult r;
        try { r = scan_cb_(localUtf8); }
        catch (...) { continue; }

        Logger::instance().debug("ArchiveScanner", "scanned inner=" + localUtf8 + " infected=" + string(r.is_infected ? "YES" : "no") + " level=" + to_string(r.danger_level));
        if (r.is_infected && r.danger_level > best.danger_level) {
            best = r;
            string innerUtf8 = unicode_utils::wide_to_utf8(ef.inner_path);
            best.detection_method = "archive_scan";
            if (!innerUtf8.empty()) best.threat_name += " (inside: " + innerUtf8 + ")";
            best.engines_triggered.push_back("archive_scan");
        }
        if (depth < limits_.max_depth) {
            string lower = localUtf8;
            transform(lower.begin(), lower.end(), lower.begin(), ::tolower);
            bool isArchive = lower.size() > 4 && (lower.rfind(".zip") == lower.size() - 4 || lower.rfind(".7z")  == lower.size() - 3 || lower.rfind(".rar") == lower.size() - 4 || lower.rfind(".iso") == lower.size() - 4);
            if (isArchive) {
                ScanResult nested = scanArchive(localUtf8, depth + 1);
                if (nested.is_infected && nested.danger_level > best.danger_level) best = nested;
            }
        }
    }
    return best;
}

void ArchiveScanner::setBaseExtractionDir(const std::wstring& dir) {base_extraction_dir_ = dir;}

wstring ArchiveScanner::createTempDir() const {
    wstring base;
    if (!base_extraction_dir_.empty()) {
        base = base_extraction_dir_;
    } else {
        wchar_t tmpBase[MAX_PATH] = {};
        if (!GetTempPathW(MAX_PATH, tmpBase)) return L"";
        base = wstring(tmpBase) + L"MentoringProtector\\unpack\\";
    }
    GUID guid;
    if (FAILED(CoCreateGuid(&guid))) return L"";

    wchar_t guidStr[40] = {};
    StringFromGUID2(guid, guidStr, 40);

    wstring dir = base + guidStr + L"\\";
    try {
        fs::create_directories(dir);
    } catch (...) {return L"";}
    return dir;
}
void ArchiveScanner::removeTempDir(const std::wstring& path) const {
    if (path.empty()) return;
    try {fs::remove_all(path);} catch (...) {}
}