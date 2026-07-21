#pragma once
#include "pch.h"
#include "../scanner/scanner.h"
#include "../heuristic/heuristic.h"
#include "../nudge/inudge_sink.h"

struct FileEvent {
    std::string file_path, action, detected_at, threat_name, verdict, detection_method;
    bool scanned = false, is_threat = false;
    int danger_level = 0, score = 0;
};
struct RealtimeMonitorConfig {
    std::vector<std::string> watch_paths;
    std::vector<std::string> scan_extensions = { ".exe", ".dll", ".scr", ".bat", ".cmd", ".ps1", ".vbs", ".wsf", ".msi", ".com", ".pif", ".zip", ".rar", ".7z", ".iso", ".doc", ".docx", ".xls", ".xlsx", ".pdf", ".js", ".hta", ".lnk", ".docm", ".xlsm", ".pptm", ".dotm", ".xlam" };
    size_t max_file_size = 100 * 1024 * 1024;
    int scan_delay_ms = 500, max_events = 200;
};

class RealtimeMonitor {
public:
    explicit RealtimeMonitor(const RealtimeMonitorConfig& config = {}, Scanner* scanner = nullptr, HeuristicAnalyzer* heuristic = nullptr, INudgeSink* nudge_sink = nullptr);
    ~RealtimeMonitor();

    bool loadResources(const std::string& signatures_path, const std::string& rules_path, const std::string& threat_db_path);
    bool start();
    void stop();
    bool isRunning() const { return running_.load(); }

    std::vector<FileEvent> getAndClearEvents();

    int totalDetected() const { return total_detected_.load(); }
    int threatsFound() const { return threats_found_.load(); }

private: RealtimeMonitorConfig config_;
    Scanner* scanner_ = nullptr;
    HeuristicAnalyzer* heuristic_ = nullptr;
    INudgeSink* nudge_sink_ = nullptr;
    std::unique_ptr<Scanner> owned_scanner_;
    std::unique_ptr<HeuristicAnalyzer> owned_heuristic_;
    std::atomic<bool> running_{ false };
    std::atomic<bool> thread_running_{ false };
    std::vector<std::thread> watch_threads_;
    std::thread scan_thread_;
    std::vector<std::pair<std::string, std::string>> scan_queue_;
    std::mutex queue_mutex_;
    std::condition_variable queue_cv_;
    std::vector<FileEvent> events_;
    std::mutex events_mutex_;
    std::atomic<int> total_detected_{ 0 };
    std::atomic<int> threats_found_{ 0 };
    std::unordered_map<std::string, std::chrono::steady_clock::time_point> recent_files_;
    std::mutex recent_mutex_;
    std::vector<HANDLE> dir_handles_;
    std::mutex handles_mutex_;

    void watchDirectory(const std::string& dirPath);
    void scanWorker();
    void enqueueFile(const std::string& path, const std::string& action);
    FileEvent scanFile(const std::string& path, const std::string& action);
    bool shouldScan(const std::string& path) const;
    std::string getCurrentTime() const;
    std::string getDefaultWatchPaths();
};