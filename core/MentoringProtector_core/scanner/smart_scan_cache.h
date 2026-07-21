#pragma once
#include <string>
#include <unordered_map>
#include <shared_mutex>
#include <atomic>
#include <windows.h>
#include "../unicode_utils.h"

struct SmartScanCacheEntry {
    uint64_t file_size = 0, last_write_time = 0, creation_time = 0;
    bool was_infected = false;
    std::string threat_name, detection_method;
    int danger_level = 0;
    uint32_t sig_db_version = 0;
};

struct SmartScanStats {
    uint64_t hits = 0, misses = 0, entries = 0, invalidations = 0;
};

class SmartScanCache {
public:
    bool lookup(const std::string& path, SmartScanCacheEntry& out_entry) {
        std::wstring wide_path = unicode_utils::utf8_to_wide(path);
        std::shared_lock<std::shared_mutex> lock(mutex_);

        auto it = cache_.find(path);
        if (it == cache_.end()) { lock.unlock(); misses_.fetch_add(1, std::memory_order_relaxed); return false; }

        const auto& entry = it->second;
        if (entry.sig_db_version != current_db_version_.load(std::memory_order_relaxed)) { lock.unlock(); misses_.fetch_add(1, std::memory_order_relaxed); return false; }

        WIN32_FILE_ATTRIBUTE_DATA attrs;
        if (!GetFileAttributesExW(wide_path.c_str(), GetFileExInfoStandard, &attrs)) { lock.unlock(); misses_.fetch_add(1, std::memory_order_relaxed); return false; }

        ULARGE_INTEGER write_time, creation_time, file_size;
        write_time.LowPart = attrs.ftLastWriteTime.dwLowDateTime;
        write_time.HighPart = attrs.ftLastWriteTime.dwHighDateTime;
        creation_time.LowPart = attrs.ftCreationTime.dwLowDateTime;
        creation_time.HighPart = attrs.ftCreationTime.dwHighDateTime;
        file_size.LowPart = attrs.nFileSizeLow;
        file_size.HighPart = attrs.nFileSizeHigh;

        if (entry.file_size != file_size.QuadPart || entry.last_write_time != write_time.QuadPart || entry.creation_time != creation_time.QuadPart) { lock.unlock(); misses_.fetch_add(1, std::memory_order_relaxed); return false; }

        out_entry = entry;
        lock.unlock();
        hits_.fetch_add(1, std::memory_order_relaxed);
        return true;
    }

    void store(const std::string& path, bool was_infected, const std::string& threat_name, const std::string& detection_method, int danger_level) {
        WIN32_FILE_ATTRIBUTE_DATA attrs;
        std::wstring wide_path = unicode_utils::utf8_to_wide(path);
        if (!GetFileAttributesExW(wide_path.c_str(), GetFileExInfoStandard, &attrs)) return;

        SmartScanCacheEntry entry;
        ULARGE_INTEGER write_time, creation_time, file_size;
        write_time.LowPart = attrs.ftLastWriteTime.dwLowDateTime;
        write_time.HighPart = attrs.ftLastWriteTime.dwHighDateTime;
        creation_time.LowPart = attrs.ftCreationTime.dwLowDateTime;
        creation_time.HighPart = attrs.ftCreationTime.dwHighDateTime;
        file_size.LowPart = attrs.nFileSizeLow;
        file_size.HighPart = attrs.nFileSizeHigh;

        entry.last_write_time = write_time.QuadPart;
        entry.creation_time = creation_time.QuadPart;
        entry.file_size = file_size.QuadPart;
        entry.was_infected = was_infected;
        entry.threat_name = threat_name;
        entry.detection_method = detection_method;
        entry.danger_level = danger_level;
        entry.sig_db_version = current_db_version_.load(std::memory_order_relaxed);

        std::unique_lock<std::shared_mutex> lock(mutex_);
        cache_[path] = std::move(entry);
    }

    void invalidateAll() { current_db_version_.fetch_add(1, std::memory_order_relaxed); invalidations_.fetch_add(1, std::memory_order_relaxed); }
    void setDbVersion(uint32_t version) { current_db_version_.store(version, std::memory_order_relaxed); }

    SmartScanStats getStats() const {
        SmartScanStats stats;
        stats.hits = hits_.load(std::memory_order_relaxed);
        stats.misses = misses_.load(std::memory_order_relaxed);
        stats.invalidations = invalidations_.load(std::memory_order_relaxed);
        std::shared_lock<std::shared_mutex> lock(mutex_);
        stats.entries = cache_.size();
        return stats;
    }

    void clear() {
        std::unique_lock<std::shared_mutex> lock(mutex_);
        cache_.clear();
        hits_.store(0, std::memory_order_relaxed);
        misses_.store(0, std::memory_order_relaxed);
    }

private: mutable std::shared_mutex mutex_;
    std::unordered_map<std::string, SmartScanCacheEntry> cache_;
    std::atomic<uint32_t> current_db_version_{1};
    std::atomic<uint64_t> hits_{0}, misses_{0}, invalidations_{0};
};

struct TrustedReputationEntry {
    uint64_t file_size = 0, last_write_time = 0, creation_time = 0;
    bool is_trusted = false;
    std::string signer_name;
};

struct TrustedReputationStats {
    uint64_t hits = 0, misses = 0, entries = 0;
};

class TrustedFileReputation {
public:
    bool lookup(const std::string& path, bool& out_trusted, std::string& out_signer) {
        WIN32_FILE_ATTRIBUTE_DATA attrs;
        std::wstring wide_path = unicode_utils::utf8_to_wide(path);
        if (!GetFileAttributesExW(wide_path.c_str(), GetFileExInfoStandard, &attrs)) { misses_.fetch_add(1, std::memory_order_relaxed); return false; }

        ULARGE_INTEGER wt, ct, fs;
        wt.LowPart = attrs.ftLastWriteTime.dwLowDateTime;
        wt.HighPart = attrs.ftLastWriteTime.dwHighDateTime;
        ct.LowPart = attrs.ftCreationTime.dwLowDateTime;
        ct.HighPart = attrs.ftCreationTime.dwHighDateTime;
        fs.LowPart = attrs.nFileSizeLow;
        fs.HighPart = attrs.nFileSizeHigh;

        std::shared_lock<std::shared_mutex> lock(mutex_);
        auto it = cache_.find(path);
        if (it == cache_.end()) { lock.unlock(); misses_.fetch_add(1, std::memory_order_relaxed); return false; }

        const auto& e = it->second;
        if (e.file_size != fs.QuadPart || e.last_write_time != wt.QuadPart || e.creation_time != ct.QuadPart) { lock.unlock(); misses_.fetch_add(1, std::memory_order_relaxed); return false; }

        out_trusted = e.is_trusted;
        out_signer = e.signer_name;
        lock.unlock();
        hits_.fetch_add(1, std::memory_order_relaxed);
        return true;
    }

    void store(const std::string& path, bool is_trusted, const std::string& signer_name = "") {
        WIN32_FILE_ATTRIBUTE_DATA attrs;
        std::wstring wide_path = unicode_utils::utf8_to_wide(path);
        if (!GetFileAttributesExW(wide_path.c_str(), GetFileExInfoStandard, &attrs)) return;

        TrustedReputationEntry entry;
        ULARGE_INTEGER wt, ct, fs;
        wt.LowPart = attrs.ftLastWriteTime.dwLowDateTime;
        wt.HighPart = attrs.ftLastWriteTime.dwHighDateTime;
        ct.LowPart = attrs.ftCreationTime.dwLowDateTime;
        ct.HighPart = attrs.ftCreationTime.dwHighDateTime;
        fs.LowPart = attrs.nFileSizeLow;
        fs.HighPart = attrs.nFileSizeHigh;

        entry.file_size = fs.QuadPart;
        entry.last_write_time = wt.QuadPart;
        entry.creation_time = ct.QuadPart;
        entry.is_trusted = is_trusted;
        entry.signer_name = signer_name;

        std::unique_lock<std::shared_mutex> lock(mutex_);
        cache_[path] = std::move(entry);
    }

    TrustedReputationStats getStats() const {
        TrustedReputationStats stats;
        stats.hits = hits_.load(std::memory_order_relaxed);
        stats.misses = misses_.load(std::memory_order_relaxed);
        std::shared_lock<std::shared_mutex> lock(mutex_);
        stats.entries = cache_.size();
        return stats;
    }

    void clear() {
        std::unique_lock<std::shared_mutex> lock(mutex_);
        cache_.clear();
        hits_.store(0, std::memory_order_relaxed);
        misses_.store(0, std::memory_order_relaxed);
    }

private: mutable std::shared_mutex mutex_;
    std::unordered_map<std::string, TrustedReputationEntry> cache_;
    std::atomic<uint64_t> hits_{0}, misses_{0};
};
