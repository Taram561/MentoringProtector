#include "pch.h"
#include "stats_storage.h"
#include "../json_utils.h"
#include "../logger/logger.h"
#include <sstream>
#include <iomanip>
#include <fstream>

namespace stats {

using std::string;
using std::wstring;
using std::map;

string StatsStorage::todayString() {
    SYSTEMTIME st;
    GetLocalTime(&st);
    char buf[16];
    sprintf_s(buf, sizeof(buf), "%04d-%02d-%02d", st.wYear, st.wMonth, st.wDay);
    return string(buf);
}
string StatsStorage::subtractDays(const string& date, int days) {
    if (date.size() != 10) return date;
    SYSTEMTIME st = {};
    st.wYear = static_cast<WORD>(atoi(date.substr(0, 4).c_str()));
    st.wMonth = static_cast<WORD>(atoi(date.substr(5, 2).c_str()));
    st.wDay = static_cast<WORD>(atoi(date.substr(8, 2).c_str()));
    st.wHour = 12;
    FILETIME ft;
    if (!SystemTimeToFileTime(&st, &ft)) return date;
    ULARGE_INTEGER uli;
    uli.LowPart = ft.dwLowDateTime;
    uli.HighPart = ft.dwHighDateTime;
    const uint64_t kTicksPerDay = 86400ULL * 10000000ULL;
    uli.QuadPart -= static_cast<uint64_t>(days) * kTicksPerDay;
    ft.dwLowDateTime = uli.LowPart;
    ft.dwHighDateTime = uli.HighPart;
    if (!FileTimeToSystemTime(&ft, &st)) return date;
    char buf[16];
    sprintf_s(buf, sizeof(buf), "%04d-%02d-%02d", st.wYear, st.wMonth, st.wDay);
    return string(buf);
}

bool StatsStorage::isOlderThan(const string& candidate, const string& cutoff) { return candidate < cutoff; }

DayCounters& StatsStorage::dayCounters(const string& date_yyyy_mm_dd) { return days_[date_yyyy_mm_dd]; }

map<string, DayCounters> StatsStorage::rangeForDays(int days) const {
    map<string, DayCounters> result;
    if (days <= 0) return result;
    string today = todayString();
    for (int i = days - 1; i >= 0; --i) {
        string d = (i == 0) ? today : subtractDays(today, i);
        auto it = days_.find(d);
        if (it != days_.end()) result[d] = it->second;
        else result[d] = DayCounters{};
    }
    return result;
}

void StatsStorage::rotate(int keep_days) {
    if (keep_days <= 0) {
        days_.clear();
        return;
    }
    if (keep_days > kMaxRetentionDays) keep_days = kMaxRetentionDays;
    string cutoff = subtractDays(todayString(), keep_days);
    for (auto it = days_.begin(); it != days_.end(); ) {
        if (isOlderThan(it->first, cutoff)) it = days_.erase(it);
        else ++it;
    }
}
string StatsStorage::toJson() const {
    std::ostringstream oss;
    oss << "{\"version\":" << format_version_;
    if (!last_flush_iso_.empty()) oss << ",\"last_flush_iso\":\"" << json_utils::escapeJson(last_flush_iso_) << "\"";
    oss << ",\"days\":{";
    bool first = true;
    for (const auto& [date, c] : days_) {
        if (!first) oss << ",";
        first = false;
        oss << "\"" << json_utils::escapeJson(date) << "\":{" << "\"scans\":" << c.scans << ",\"files_scanned\":" << c.files_scanned << ",\"threats_total\":" << c.threats_total << ",\"threats_scan\":" << c.threats_scan << ",\"threats_realtime\":" << c.threats_realtime << ",\"threats_memory\":" << c.threats_memory << ",\"threats_web\":" << c.threats_web << "}";
    }
    oss << "}}";
    return oss.str();
}

bool StatsStorage::fromJson(const string& json) {
    if (json.empty()) return false;
    int version = json_utils::extractInt(json, "version");
    if (version <= 0) version = 1;
    format_version_ = version;
    last_flush_iso_ = json_utils::extractString(json, "last_flush_iso");
    string daysBlock = json_utils::extractBlock(json, "days");
    if (daysBlock.empty()) return true;
    if (daysBlock.front() == '{') daysBlock.erase(0, 1);
    if (!daysBlock.empty() && daysBlock.back() == '}') daysBlock.pop_back();

    size_t pos = 0;
    while (pos < daysBlock.size()) {
        size_t keyStart = daysBlock.find('"', pos);
        if (keyStart == string::npos) break;
        size_t keyEnd = daysBlock.find('"', keyStart + 1);
        if (keyEnd == string::npos) break;
        string date = daysBlock.substr(keyStart + 1, keyEnd - keyStart - 1);
        size_t braceStart = daysBlock.find('{', keyEnd);
        if (braceStart == string::npos) break;
        int depth = 1;
        size_t i = braceStart + 1;
        while (i < daysBlock.size() && depth > 0) {
            if (daysBlock[i] == '{') depth++;
            else if (daysBlock[i] == '}') depth--;
            if (depth > 0) i++;
        }
        if (depth != 0) break;
        string obj = daysBlock.substr(braceStart, i - braceStart + 1);
        if (date.size() == 10 && date[4] == '-' && date[7] == '-') {
            DayCounters c;
            c.scans = static_cast<uint32_t>(json_utils::extractInt(obj, "scans"));
            c.files_scanned = static_cast<uint32_t>(json_utils::extractInt(obj, "files_scanned"));
            c.threats_total = static_cast<uint32_t>(json_utils::extractInt(obj, "threats_total"));
            c.threats_scan = static_cast<uint32_t>(json_utils::extractInt(obj, "threats_scan"));
            c.threats_realtime = static_cast<uint32_t>(json_utils::extractInt(obj, "threats_realtime"));
            c.threats_memory = static_cast<uint32_t>(json_utils::extractInt(obj, "threats_memory"));
            c.threats_web = static_cast<uint32_t>(json_utils::extractInt(obj, "threats_web"));
            days_[date] = c;
        }
        pos = i + 1;
    }
    return true;
}
bool StatsStorage::load(const wstring& path) {
    days_.clear();
    last_flush_iso_.clear();
    DWORD attr = GetFileAttributesW(path.c_str());
    if (attr == INVALID_FILE_ATTRIBUTES) return false;
    if (attr & FILE_ATTRIBUTE_DIRECTORY) return false;
    HANDLE hFile = CreateFileW(path.c_str(), GENERIC_READ, FILE_SHARE_READ, nullptr, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, nullptr);
    if (hFile == INVALID_HANDLE_VALUE) return false;
    LARGE_INTEGER size;
    if (!GetFileSizeEx(hFile, &size) || size.QuadPart <= 0 || size.QuadPart > 64LL * 1024 * 1024) {
        CloseHandle(hFile);
        return false;
    }
    string buffer(static_cast<size_t>(size.QuadPart), '\0');
    DWORD bytesRead = 0;
    BOOL ok = ReadFile(hFile, buffer.data(), static_cast<DWORD>(buffer.size()), &bytesRead, nullptr);
    CloseHandle(hFile);
    if (!ok) return false;
    buffer.resize(bytesRead);
    return fromJson(buffer);
}

bool StatsStorage::save(const wstring& path) {
    {
        SYSTEMTIME st;
        GetSystemTime(&st);
        char buf[32];
        sprintf_s(buf, sizeof(buf), "%04d-%02d-%02dT%02d:%02d:%02dZ", st.wYear, st.wMonth, st.wDay, st.wHour, st.wMinute, st.wSecond);
        last_flush_iso_ = buf;
    }
    string json = toJson();

    wstring tmp = path + L".tmp";
    HANDLE hFile = CreateFileW(tmp.c_str(), GENERIC_WRITE, 0, nullptr, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, nullptr);
    if (hFile == INVALID_HANDLE_VALUE) {
        LS_LOG_ERROR("StatsStorage", "CreateFileW tmp failed err=" + std::to_string(GetLastError()));
        return false;
    }
    DWORD written = 0;
    BOOL ok = WriteFile(hFile, json.data(), static_cast<DWORD>(json.size()), &written, nullptr);
    if (ok) ok = FlushFileBuffers(hFile);
    CloseHandle(hFile);
    if (!ok || written != json.size()) {
        DeleteFileW(tmp.c_str());
        LS_LOG_ERROR("StatsStorage", "WriteFile tmp failed");
        return false;
    }

    if (!MoveFileExW(tmp.c_str(), path.c_str(), MOVEFILE_REPLACE_EXISTING | MOVEFILE_WRITE_THROUGH)) {
        LS_LOG_ERROR("StatsStorage", "MoveFileExW failed err=" + std::to_string(GetLastError()));
        DeleteFileW(tmp.c_str());
        return false;
    }
    return true;
}

}