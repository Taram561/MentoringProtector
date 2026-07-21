#include "pch.h"
#include "motw_reader.h"
#include "../unicode_utils.h"
#include <algorithm>
#include <string>

using namespace std;

namespace motw {
static int readZoneId(const wstring& path) {
    wstring adsPath = path + L":Zone.Identifier:$DATA";
    HANDLE hFile = CreateFileW(adsPath.c_str(), GENERIC_READ, FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE, nullptr, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, nullptr);
    if (hFile == INVALID_HANDLE_VALUE) return -1;

    constexpr DWORD MAX_READ = 4096;
    char buf[MAX_READ + 1] = {};
    DWORD bytesRead = 0;
    BOOL ok = ReadFile(hFile, buf, MAX_READ, &bytesRead, nullptr);
    CloseHandle(hFile);

    if (!ok || bytesRead == 0) return -1;
    buf[bytesRead] = '\0';

    string content(buf, bytesRead);
    auto pos = content.find("ZoneId=");
    if (pos == string::npos) return -1;

    size_t valueStart = pos + 7;
    while (valueStart < content.size() && content[valueStart] == ' ') ++valueStart;
    if (valueStart >= content.size()) return -1;
    char ch = content[valueStart];
    if (ch < '0' || ch > '9') return -1;
    return ch - '0';
}

bool isFromInternet(const wstring& path) {
    int zoneId = readZoneId(path);
    return zoneId >= 3;
}

bool isFromInternet(const string& path_utf8) { return isFromInternet(unicode_utils::utf8_to_wide(path_utf8)); }
}