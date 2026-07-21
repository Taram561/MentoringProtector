#include "pch.h"
#include "stats_recorder.h"
#include "../json_utils.h"
#include "../logger/logger.h"
#include <sstream>

namespace stats {

using std::string;
using std::wstring;
using std::map;
using std::lock_guard;
using std::mutex;

StatsRecorder& StatsRecorder::instance() {
    static StatsRecorder inst;
    return inst;
}

StatsRecorder::StatsRecorder() = default;

namespace {
    thread_local bool g_override_active = false;
    thread_local StatsRecorder::Source g_override_src = StatsRecorder::Source::kScan;
}

StatsRecorder::ScopedSourceOverride::ScopedSourceOverride(Source src): had_prev_(g_override_active), prev_(g_override_src) {
    g_override_active = true;
    g_override_src = src;
}

StatsRecorder::ScopedSourceOverride::~ScopedSourceOverride() {
    if (had_prev_) {
        g_override_active = true;
        g_override_src = prev_;
    } else {
        g_override_active = false;
    }
}

StatsRecorder::Source StatsRecorder::effectiveSource(Source defaultSrc) const { return g_override_active ? g_override_src : defaultSrc; }

wstring StatsRecorder::getStatsFilePath() {
    if (!stats_file_path_.empty()) return stats_file_path_;

    wchar_t path[MAX_PATH] = {};
    HMODULE hm = nullptr;
    if (GetModuleHandleExW(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS | GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT, reinterpret_cast<LPCWSTR>(&StatsRecorder::instance), &hm) && hm != nullptr) {
        GetModuleFileNameW(hm, path, MAX_PATH);
    }
    wstring dir(path);
    auto pos = dir.find_last_of(L"\\/");
    if (pos != wstring::npos) dir = dir.substr(0, pos + 1);
    else dir = L".\\";

    wstring data_dir = dir + L"data";
    DWORD attr = GetFileAttributesW(data_dir.c_str());
    if (attr == INVALID_FILE_ATTRIBUTES || !(attr & FILE_ATTRIBUTE_DIRECTORY)) {
        data_dir = L"..\\data";
        attr = GetFileAttributesW(data_dir.c_str());
        if (attr == INVALID_FILE_ATTRIBUTES) {
            CreateDirectoryW((dir + L"data").c_str(), nullptr);
            data_dir = dir + L"data";
        }
    }
    stats_file_path_ = data_dir + L"\\stats.db";
    return stats_file_path_;
}
string StatsRecorder::currentDateString() {
    SYSTEMTIME st;
    GetLocalTime(&st);
    char buf[16];
    sprintf_s(buf, sizeof(buf), "%04d-%02d-%02d", st.wYear, st.wMonth, st.wDay);
    return string(buf);
}

void StatsRecorder::ensureLoadedLocked() {
    if (loaded_) return;
    wstring path = getStatsFilePath();
    storage_.load(path);
    loaded_ = true;
}
void StatsRecorder::recordThreat(Source src, uint32_t count) {
    {
        lock_guard<mutex> lk(mu_);
        ensureLoadedLocked();
        auto& c = storage_.dayCounters(currentDateString());
        c.threats_total += count;
        switch (src) {
            case Source::kScan: c.threats_scan += count; break;
            case Source::kRealtime: c.threats_realtime += count; break;
            case Source::kMemory: c.threats_memory += count; break;
            case Source::kWeb: c.threats_web += count; break;
        }
    }
    dirty_writes_.fetch_add(1);
    flushIfThresholdExceeded();
}
void StatsRecorder::recordScan(uint32_t files_scanned) {
    {
        lock_guard<mutex> lk(mu_);
        ensureLoadedLocked();
        auto& c = storage_.dayCounters(currentDateString());
        c.scans += 1;
        c.files_scanned += files_scanned;
    }
    dirty_writes_.fetch_add(1);
    flushIfThresholdExceeded();
}
void StatsRecorder::flush() {
    lock_guard<mutex> lk(mu_);
    ensureLoadedLocked();
    storage_.rotate(StatsStorage::kMaxRetentionDays);
    wstring path = getStatsFilePath();
    if (storage_.save(path)) dirty_writes_.store(0);
    else LS_LOG_WARN("StatsRecorder", "flush() save failed - data retained in memory");
}

void StatsRecorder::flushIfThresholdExceeded() { if (dirty_writes_.load() >= kFlushThreshold) flush(); }

static string buildDayJsonForThreats(const string& date, const DayCounters& c) {
    std::ostringstream oss;
    oss << "{\"date\":\"" << json_utils::escapeJson(date) << "\"" << ",\"threats\":" << c.threats_total << ",\"scan\":" << c.threats_scan << ",\"realtime\":" << c.threats_realtime << ",\"memory\":" << c.threats_memory << ",\"web\":" << c.threats_web << "}";
    return oss.str();
}
static string buildDayJsonForScans(const string& date, const DayCounters& c) {
    std::ostringstream oss;
    oss << "{\"date\":\"" << json_utils::escapeJson(date) << "\"" << ",\"scans\":" << c.scans << ",\"files_scanned\":" << c.files_scanned << "}";
    return oss.str();
}
string StatsRecorder::getThreatStatsJson(int period_days) {
    lock_guard<mutex> lk(mu_);
    ensureLoadedLocked();
    if (period_days <= 0) period_days = 1;
    if (period_days > StatsStorage::kMaxRetentionDays) period_days = StatsStorage::kMaxRetentionDays;

    auto range = storage_.rangeForDays(period_days);
    std::ostringstream oss;
    oss << "{\"period_days\":" << period_days << ",\"daily\":[";
    bool first = true;
    uint64_t total = 0;
    for (const auto& [date, c] : range) {
        if (!first) oss << ",";
        first = false;
        oss << buildDayJsonForThreats(date, c);
        total += c.threats_total;
    }
    oss << "],\"total\":" << total << "}";
    return oss.str();
}
string StatsRecorder::getScanHistoryJson(int period_days) {
    lock_guard<mutex> lk(mu_);
    ensureLoadedLocked();
    if (period_days <= 0) period_days = 1;
    if (period_days > StatsStorage::kMaxRetentionDays) period_days = StatsStorage::kMaxRetentionDays;

    auto range = storage_.rangeForDays(period_days);
    std::ostringstream oss;
    oss << "{\"period_days\":" << period_days << ",\"daily\":[";
    bool first = true;
    uint64_t total_scans = 0;
    uint64_t total_files = 0;
    for (const auto& [date, c] : range) {
        if (!first) oss << ",";
        first = false;
        oss << buildDayJsonForScans(date, c);
        total_scans += c.scans;
        total_files += c.files_scanned;
    }
    oss << "],\"total_scans\":" << total_scans << ",\"total_files\":" << total_files << "}";
    return oss.str();
}

string StatsRecorder::getThreatSourcesJson(int period_days) {
    lock_guard<mutex> lk(mu_);
    ensureLoadedLocked();
    if (period_days <= 0) period_days = 1;
    if (period_days > StatsStorage::kMaxRetentionDays) period_days = StatsStorage::kMaxRetentionDays;

    auto range = storage_.rangeForDays(period_days);
    uint64_t scan = 0, rt = 0, mem = 0, web = 0;
    for (const auto& [date, c] : range) {
        scan += c.threats_scan;
        rt += c.threats_realtime;
        mem += c.threats_memory;
        web += c.threats_web;
    }
    uint64_t total = scan + rt + mem + web;
    std::ostringstream oss;
    oss << "{\"period_days\":" << period_days << ",\"scan\":" << scan << ",\"realtime\":" << rt << ",\"memory\":" << mem << ",\"web\":" << web << ",\"total\":" << total << "}";
    return oss.str();
}
void StatsRecorder::setStorageFilePathForTest(const wstring& path) {
    lock_guard<mutex> lk(mu_);
    stats_file_path_ = path;
    loaded_ = false;
    storage_ = StatsStorage{};
    dirty_writes_.store(0);
}
void StatsRecorder::resetForTest() {
    lock_guard<mutex> lk(mu_);
    storage_ = StatsStorage{};
    dirty_writes_.store(0);
    loaded_ = true;
}

}