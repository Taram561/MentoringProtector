#pragma once
#include <string>
#include <map>
#include <vector>
#include <cstdint>

namespace stats {

struct DayCounters {
    uint32_t scans = 0, files_scanned = 0, threats_total = 0, threats_scan = 0, threats_realtime = 0, threats_memory = 0, threats_web = 0;
};

class StatsStorage {
public:
    bool load(const std::wstring& path), save(const std::wstring& path);
    DayCounters& dayCounters(const std::string& date_yyyy_mm_dd);
    std::map<std::string, DayCounters> rangeForDays(int days) const;
    void rotate(int keep_days);
    const std::map<std::string, DayCounters>& allDays() const { return days_; }
    static constexpr int kMaxRetentionDays = 90;
    void setLastFlushIso(const std::string& iso) { last_flush_iso_ = iso; }
    const std::string& lastFlushIso() const { return last_flush_iso_; }

private:
    std::map<std::string, DayCounters> days_;
    int format_version_ = 1;
    std::string last_flush_iso_, toJson() const;
    bool fromJson(const std::string& json);

    static std::string todayString();
    static std::string subtractDays(const std::string& date, int days);
    static bool isOlderThan(const std::string& candidate, const std::string& cutoff);
};

}