#pragma once
#include "pch.h"
#include "../scanner/scanner.h"
#include "../heuristic/heuristic.h"
#include "../etw_monitor/etw_monitor.h"

struct ProcessAlert {
    DWORD pid = 0;
    std::string process_name, exe_path, file_hash, verdict, threat_name, detection_method, detected_at;
    int suspicion_score = 0, danger_level = 0;
    bool is_blocked = false;
    std::vector<std::string> triggered_rules;
};

struct ProcessAnalyzerConfig {
    int warn_threshold = 60;
    int block_threshold = 0;
    int poll_interval_ms = 2000;
    std::vector<std::string> excluded_paths;
    std::vector<std::string> trusted_processes = { "code.exe", "devenv.exe", "msedge.exe", "chrome.exe", "firefox.exe", "explorer.exe", "taskmgr.exe", "cmd.exe", "powershell.exe", "pwsh.exe", "conhost.exe", "git.exe", "node.exe", "npm.cmd", "python.exe", "python3.exe", "java.exe", "javaw.exe", "dotnet.exe", "msbuild.exe", "cl.exe", "link.exe", "cmake.exe", "ninja.exe", "notepad.exe", "winget.exe", "wt.exe", "svchost.exe", "csrss.exe", "lsass.exe", "services.exe", "spoolsv.exe", "searchhost.exe", "runtimebroker.exe", "applicationframehost.exe", "textinputhost.exe", "systemsettings.exe", "sihost.exe", "smartscreen.exe", "securityhealthservice.exe", "msedgewebview2.exe", "windowsterminal.exe", "slack.exe", "telegram.exe", "discord.exe", "spotify.exe", "steam.exe", "flutter_tester.exe", "dart.exe" };
    bool unknown_only = true;
};
class ProcessAnalyzer {
public:
    ProcessAnalyzer(Scanner* scanner = nullptr, HeuristicAnalyzer* heuristic = nullptr, const ProcessAnalyzerConfig& config = {});
    ~ProcessAnalyzer();
    
    bool startMonitoring();
    void stopMonitoring();
    
    std::vector<ProcessAlert> getAndClearAlerts();
    ProcessAlert analyzeProcess(DWORD pid);

    bool isMonitoring() const { return monitoring_; }
    std::string getMonitoringMode() const;
    std::vector<DllInjectionAlert> getAndClearInjectionAlerts();
    bool loadResources(const std::string& signatures_path, const std::string& rules_path, const std::string& threat_db_path);
    bool terminateProcess(DWORD pid);
    struct AnalysisCacheEntry { ULONGLONG expiry_ms = 0; std::string json; };
    std::unordered_map<DWORD, AnalysisCacheEntry> analysis_cache_;
    std::mutex cache_mutex_;
    static constexpr ULONGLONG kCacheTtlMs = 5000;

private: ProcessAnalyzerConfig config_;
    Scanner* scanner_ = nullptr;
    HeuristicAnalyzer* heuristic_ = nullptr;
    std::unique_ptr<EtwMonitor> etw_monitor_;
    bool use_etw_ = false;
    std::thread monitor_thread_;
    std::atomic<bool> monitoring_{ false };
    std::atomic<bool> thread_running_{ false };
    std::condition_variable cv_stop_;
    std::mutex cv_stop_mutex_;
    std::vector<ProcessAlert> alerts_;
    std::mutex alerts_mutex_;
    std::unordered_set<DWORD> checked_pids_;
    std::mutex pids_mutex_;
    void monitorLoop();
    void onEtwProcessStart(const EtwProcessEvent& event);

    std::vector<std::pair<DWORD, std::string>> getRunningProcesses();
    std::string getProcessExePath(DWORD pid);
    bool isExcluded(const std::string& path) const;
    bool isTrustedProcess(const std::string& processName) const;
    void addAlert(ProcessAlert alert);
    std::string getCurrentTime() const;

public:
    DWORD getProcessParentPid(DWORD pid) const;
    std::string getProcessCmdline(DWORD pid) const;
    struct ModuleInfo { std::string name; uintptr_t base = 0; SIZE_T size = 0; };
    std::vector<ModuleInfo> getProcessModules(DWORD pid) const;
    static std::string verifyProcessSignature(const std::string& exe_path);
};