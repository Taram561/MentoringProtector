#include "pch.h"
#include "script_guard.h"
#include "../unicode_utils.h"
#include <algorithm>
#include <array>

using namespace std;

namespace script_guard {

namespace {
constexpr const char* SCRIPT_EXTS[] = { ".ps1", ".vbs", ".hta", ".bat" };

struct Token { const char* pattern; const char* label; };

constexpr Token TOKENS[] = {
    {"invoke-expression", "Invoke-Expression"},
    {"iex ", "IEX"},
    {"downloadstring", "DownloadString"},
    {"downloadfile", "DownloadFile"},
    {"-encodedcommand", "-EncodedCommand"},
    {" -enc ", "-enc"},
    {"frombase64string", "FromBase64String"},
    {"-windowstyle hidden","-WindowStyle Hidden"},
    {"-executionpolicy bypass", "ExecutionPolicy Bypass"},
    {"net.webclient", "Net.WebClient"},
};

constexpr int SUSPICIOUS_THRESHOLD = 2;
constexpr DWORD MAX_READ_BYTES = 1024 * 1024;
constexpr DWORD MAX_FILE_SKIP_BYTES = 10 * 1024 * 1024;

bool isScriptExtension(const std::string& path) {
    if (path.size() < 4) return false;
    auto dotPos = path.rfind('.');
    if (dotPos == string::npos) return false;
    string ext = path.substr(dotPos);
    for (char& c : ext) c = static_cast<char>(tolower(static_cast<unsigned char>(c)));
    for (const char* e : SCRIPT_EXTS) { if (ext == e) return true; }
    return false;
}
string truncate(const string& s, size_t maxLen) {
    if (s.size() <= maxLen) return s;
    return s.substr(0, maxLen - 3) + "...";
}
}

ScriptGuardResult analyze(const std::string& path_utf8) {
    if (!isScriptExtension(path_utf8)) return { false, "" };

    wstring wpath = unicode_utils::utf8_to_wide(path_utf8);
    WIN32_FILE_ATTRIBUTE_DATA attrs = {};
    if (!GetFileAttributesExW(wpath.c_str(), GetFileExInfoStandard, &attrs)) return { false, "" };
    ULONGLONG fileSize = (static_cast<ULONGLONG>(attrs.nFileSizeHigh) << 32) | attrs.nFileSizeLow;
    if (fileSize > MAX_FILE_SKIP_BYTES) return { false, "" };
    HANDLE hFile = CreateFileW(wpath.c_str(), GENERIC_READ, FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE, nullptr, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL | FILE_FLAG_SEQUENTIAL_SCAN, nullptr);
    if (hFile == INVALID_HANDLE_VALUE) return { false, "" };

    DWORD toRead = static_cast<DWORD>(min(static_cast<ULONGLONG>(MAX_READ_BYTES), fileSize));
    string buf(toRead, '\0');
    DWORD bytesRead = 0;
    BOOL ok = ReadFile(hFile, &buf[0], toRead, &bytesRead, nullptr);
    CloseHandle(hFile);

    if (!ok || bytesRead == 0) return { false, "" };
    buf.resize(bytesRead);

    string lower = buf;
    for (char& c : lower) c = static_cast<char>(tolower(static_cast<unsigned char>(c)));

    int matchCount = 0;
    string foundLabels;

    for (const auto& tok : TOKENS) {
        if (lower.find(tok.pattern) != string::npos) {
            ++matchCount;
            if (!foundLabels.empty()) foundLabels += ", ";
            foundLabels += tok.label;
        }
    }
    if (matchCount < SUSPICIOUS_THRESHOLD) return { false, "" };
    return { true, truncate(foundLabels, 200) };
}
}