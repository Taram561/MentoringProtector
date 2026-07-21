#pragma once
#include "pch.h"
#include <set>

struct BehavioralEvent {
    std::string type;
    std::string target;
    std::string detail;
    std::string timestamp;
};

class SandboxMonitor {
public:
    explicit SandboxMonitor(DWORD sandbox_pid);
    ~SandboxMonitor();
    SandboxMonitor(const SandboxMonitor&) = delete;
    SandboxMonitor& operator=(const SandboxMonitor&) = delete;

    void start();
    void stop();

    std::vector<BehavioralEvent> getEvents() const;
    int  computeRiskScore() const;

private:
    DWORD target_pid_;
    std::atomic<bool> running_{false};
    std::thread poll_thread_;

    mutable std::mutex events_mutex_;
    std::vector<BehavioralEvent> events_;
    std::set<DWORD> known_children_;
    std::set<std::string> known_modules_;

    void pollLoop();
    void checkChildProcesses();
    void checkModules();
    void checkMemory();

    void addEvent(const std::string& type, const std::string& target, const std::string& detail);
    std::string timestamp() const;
    std::string wstrToUtf8(const std::wstring& ws) const;
    bool isSystemPath(const std::string& lower) const;
};