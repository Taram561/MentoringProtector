#pragma once
#include "pch.h"
#include "search.h"

struct MemoryScanResult {
    DWORD pid = 0;
    std::string process_name;
    std::string exe_path;
    bool is_threat = false;
    std::string threat_name;
    int matches_count = 0;
    size_t memory_scanned = 0;
    size_t regions_scanned = 0;
    std::string detected_at;
    std::vector<std::string> matched_signatures;
};

struct MemorySignature {
    std::string name;
    std::vector<uint8_t> pattern;
    int danger_level = 0;
};

struct MemoryScanProgress {
    bool is_running = false, is_finished = false;
    int processes_total = 0, processes_scanned = 0, threats_found = 0;
    std::string current_process;
    std::vector<MemoryScanResult> threats;
};

class MemoryScanner {
public: MemoryScanner();
    ~MemoryScanner();

    int loadSignatures(const std::string& path);
    void loadBuiltinSignatures();
    MemoryScanResult scanProcess(DWORD pid);
    bool startFullScan();
    void stopScan();
    MemoryScanProgress getProgress();
    bool isRunning() const { return running_.load(); }

private: std::vector<MemorySignature> signatures_;
    SearchMatcher matcher_;
    std::thread scan_thread_;
    std::atomic<bool> running_{ false };
    std::atomic<bool> thread_running_{ false };
    MemoryScanProgress progress_;
    std::mutex progress_mutex_;
    void buildMatcher();
    void scanAllProcesses();
    std::vector<std::pair<DWORD, std::string>> getProcessList();
    std::string getProcessPath(DWORD pid);
    bool searchMemory(HANDLE hProcess, const MemorySignature& sig);
    std::string getCurrentTime() const;

    bool isReadableRegion(const MEMORY_BASIC_INFORMATION& mbi) const;
    bool isSystemProcess(const std::string& processName) const;
};