#pragma once
#include "pch.h"
#include "sandbox_process.h"
#include "sandbox_monitor.h"

enum class SandboxState { Idle, Running, Completed, Cancelled, Error };

struct SandboxRunResult {
    bool success = false;
    std::string error_code;
};

class SandboxManager {
public:
    static SandboxManager& instance();
    ~SandboxManager();

    SandboxManager(const SandboxManager&) = delete;
    SandboxManager& operator=(const SandboxManager&) = delete;

    bool isSupported() const;
    SandboxRunResult run(const std::wstring& filePath, int timeoutSeconds = 60);
    void cancel();
    SandboxState getState() const;
    int getElapsedSeconds() const;
    std::string getReportJson() const;

private:
    SandboxManager() = default;

    mutable std::mutex mtx_;
    SandboxState state_ = SandboxState::Idle;
    std::unique_ptr<SandboxProcess> process_;
    std::unique_ptr<SandboxMonitor> monitor_;
    std::thread watcher_;
    int elapsed_s_ = 0;
    DWORD sandbox_pid_ = 0;
    std::string report_json_;

    void watcherLoop(int timeoutSecs);
    std::string buildReportJson(const std::vector<BehavioralEvent>& events, int riskScore, bool timedOut, int duration) const;
    std::string escapeJson(const std::string& s) const;
};