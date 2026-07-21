#include "pch.h"
#include "zip_extractor.h"
#include "../unicode_utils.h"
#include "miniz.h"
#include <filesystem>
#include <fstream>
#include <algorithm>
#include <cstdio>

namespace fs = std::filesystem;
using namespace std;

bool ZipExtractor::hasPkMagic(const wstring& path) const {
    FILE* f = nullptr;
    _wfopen_s(&f, path.c_str(), L"rb");
    if (!f) return false;
    unsigned char magic[4] = {};
    bool ok = (fread(magic, 1, 4, f) == 4) && magic[0] == 0x50 && magic[1] == 0x4B && magic[2] == 0x03 && magic[3] == 0x04;
    fclose(f);
    return ok;
}

bool ZipExtractor::canHandle(const wstring& path) const {
    if (path.size() >= 4) {
        wstring ext = path.substr(path.size() - 4);
        transform(ext.begin(), ext.end(), ext.begin(), ::towlower);
        if (ext == L".zip") return true;
    }
    return hasPkMagic(path);
}

static wstring sanitizeEntryPath(const string& raw_utf8) {
    if (raw_utf8.empty()) return L"";
    wstring s;
    s.reserve(raw_utf8.size());
    for (size_t i = 0; i < raw_utf8.size(); ) {
        unsigned char c = static_cast<unsigned char>(raw_utf8[i]);
        if (c < 0x80) {
            s += static_cast<wchar_t>(c);
            ++i;
        } else if ((c & 0xE0) == 0xC0 && i + 1 < raw_utf8.size()) {
            s += static_cast<wchar_t>(((c & 0x1F) << 6) | (raw_utf8[i+1] & 0x3F));
            i += 2;
        } else if ((c & 0xF0) == 0xE0 && i + 2 < raw_utf8.size()) {
            s += static_cast<wchar_t>(((c & 0x0F) << 12) | ((raw_utf8[i+1] & 0x3F) << 6) | (raw_utf8[i+2] & 0x3F));
            i += 3;
        } else {
            s += L'_';
            ++i;
        }
    }

    for (auto& ch : s) { if (ch == L'/') ch = L'\\'; }

    vector<wstring> parts;
    wstringstream ss(s);
    wstring token;
    while (getline(ss, token, L'\\')) {
        if (token.empty() || token == L"." || token == L"..") continue;
        if (token.size() == 2 && token[1] == L':') continue;
        parts.push_back(token);
    }
    if (parts.empty()) return L"";

    wstring result;
    for (size_t i = 0; i < parts.size(); ++i) {
        if (i > 0) result += L'\\';
        result += parts[i];
    }
    return result;
}

ExtractionResult ZipExtractor::extract(const wstring& path, const wstring& dest_dir, const ArchiveLimits& limits) {
    ExtractionResult res;
    FILE* zf = nullptr;
    _wfopen_s(&zf, path.c_str(), L"rb");
    if (!zf) {
        res.error = "read_error";
        return res;
    }

    mz_zip_archive zip = {};
    if (!mz_zip_reader_init_cfile(&zip, zf, 0, 0)) {
        fclose(zf);
        res.error = "read_error";
        return res;
    }

    mz_uint num_files = mz_zip_reader_get_num_files(&zip);

    if (static_cast<int>(num_files) > limits.max_files) {
        mz_zip_reader_end(&zip);
        fclose(zf);
        res.error = "zip_bomb_count";
        return res;
    }

    uint64_t total_uncomp = 0, total_comp = 0;
    for (mz_uint i = 0; i < num_files; ++i) {
        mz_zip_archive_file_stat st = {};
        if (!mz_zip_reader_file_stat(&zip, i, &st)) continue;
        if (st.m_is_directory) continue;
        total_uncomp += st.m_uncomp_size;
        total_comp += (st.m_comp_size > 0 ? st.m_comp_size : 1);
    }

    if (total_uncomp > limits.max_size_bytes) {
        mz_zip_reader_end(&zip);
        fclose(zf);
        res.error = "zip_bomb_size";
        return res;
    }

    if (total_comp > 0) {
        float ratio = static_cast<float>(total_uncomp) / static_cast<float>(total_comp);
        if (ratio > limits.max_ratio) {
            mz_zip_reader_end(&zip);
            fclose(zf);
            res.error = "zip_bomb_ratio";
            return res;
        }
    }

    for (mz_uint i = 0; i < num_files; ++i) {
        mz_zip_archive_file_stat st = {};
        if (!mz_zip_reader_file_stat(&zip, i, &st)) continue;
        if (st.m_is_directory) continue;
        if (!st.m_is_supported) continue;

        wstring relPath = sanitizeEntryPath(st.m_filename);
        if (relPath.empty()) continue;

        wstring destPath = dest_dir + relPath;

        try {
            fs::create_directories(fs::path(destPath).parent_path());
        } catch (...) {
            continue;
        }

        FILE* df = nullptr;
        _wfopen_s(&df, destPath.c_str(), L"wb");
        if (!df) continue;

        bool ok = mz_zip_reader_extract_to_cfile(&zip, i, df, 0) == MZ_TRUE;
        fclose(df);

        if (ok) {
            ExtractedFile ef;
            ef.inner_path = relPath;
            ef.local_path = destPath;
            ef.original_size = st.m_uncomp_size;
            res.files.push_back(ef);
        }
    }

    mz_zip_reader_end(&zip);
    fclose(zf);
    res.ok = true;
    return res;
}