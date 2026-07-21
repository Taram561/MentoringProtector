#pragma once
#include <mutex>
#include <atomic>
#include <string>
#include "stats_storage.h"

namespace stats {

class StatsRecorder {
public:
    static StatsRecorder& instance();

    enum class Source { kScan, kRealtime, kMemory, kWeb };

    void recordThreat(Source src, uint32_t count = 1);
    void recordScan(uint32_t files_scanned);

    class ScopedSourceOverride {
    public:
        explicit ScopedSourceOverride(Source src);
        ~ScopedSourceOverride();
        ScopedSourceOverride(const ScopedSourceOverride&) = delete;
        ScopedSourceOverride& operator=(const ScopedSourceOverride&) = delete;
    private:
        bool had_prev_;
        Source prev_;
    };

    Source effectiveSource(Source defaultSrc) const;

    std::string getThreatStatsJson(int period_days);
    std::string getScanHistoryJson(int period_days);
    std::string getThreatSourcesJson(int period_days);

    void flush();
    void setStorageFilePathForTest(const std::wstring& path);
    StatsStorage& storageForTest() { return storage_; }
    uint64_t dirtyWritesForTest() const { return dirty_writes_.load(); }
    void resetForTest();

private:
    StatsRecorder();
    ~StatsRecorder() = default;
    StatsRecorder(const StatsRecorder&) = delete;
    StatsRecorder& operator=(const StatsRecorder&) = delete;

    std::mutex mu_;
    StatsStorage storage_;
    std::atomic<uint64_t> dirty_writes_{0};
    std::wstring stats_file_path_;
    bool loaded_ = false;
    static constexpr uint64_t kFlushThreshold = 50;

    std::wstring getStatsFilePath();
    std::string currentDateString();
    void ensureLoadedLocked();
    void flushIfThresholdExceeded();
};

}