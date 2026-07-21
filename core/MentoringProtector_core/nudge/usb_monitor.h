#pragma once
#include <Windows.h>
#include <dbt.h>
#include <atomic>
#include <chrono>
#include <mutex>
#include <thread>
#include <unordered_map>
#include "inudge_sink.h"

class UsbMonitor {
public:
    UsbMonitor() = default;
    ~UsbMonitor();

    UsbMonitor(const UsbMonitor&) = delete;
    UsbMonitor& operator=(const UsbMonitor&) = delete;
    void start(INudgeSink* sink);
    void stop();

private:
    void threadMain(HANDLE readyEvent);
    static LRESULT CALLBACK wndProc(HWND hwnd, UINT msg, WPARAM wp, LPARAM lp);
    static char driveLetter(DWORD unitMask);

    std::thread thread_;
    std::atomic<HWND> hwnd_{ nullptr };
    std::atomic<bool> running_{ false };
    INudgeSink* sink_ = nullptr;

    std::mutex dedupMx_;
    std::unordered_map<char, std::chrono::steady_clock::time_point> recentArrivals_;
    static constexpr int DEDUP_SEC = 5;
};