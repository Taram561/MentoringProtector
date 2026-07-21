#pragma once
#include "pch.h"
#include <atomic>
#include <thread>
#include <mutex>
#include <condition_variable>
#include <vector>
#include <string>
#include <set>

class CrlUpdater {
public: CrlUpdater();
    ~CrlUpdater();

    void start();
    void stop();
    bool isRunning() const;

    struct Stats {
        int urls_found = 0, urls_updated = 0, urls_failed = 0;
        std::string last_update;
    };

    Stats getStats() const;

private:
    std::atomic<bool> running_{ false };
    std::thread worker_thread_;
    mutable std::mutex stats_mutex_;
    std::mutex cv_mutex_;
    std::condition_variable cv_;
    Stats stats_;

    static constexpr int UPDATE_INTERVAL_SEC = 14400;
    void workerLoop();
    void updateCycle();
    std::set<std::string> collectCrlUrls(const std::wstring& directory);
    std::vector<std::string> extractCrlUrlsFromFile(const std::wstring& file_path);
    bool downloadCrl(const std::string& url);
};