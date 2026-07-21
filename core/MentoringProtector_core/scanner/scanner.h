#pragma once
#include "../pch.h"
#include "../signatures/signatures.h"
#include "scan_result.h"
#include "../archive_scanner/archive_scanner.h"
#include "smart_scan_cache.h"
#include "file_hasher.h"

struct ComputerScanProgress {
    bool is_running = false, is_finished = false;
    int files_total = 0, files_scanned = 0, threats_found = 0;
    std::string current_file, current_drive, error;
    std::vector<ScanResult> threats;
};

class Scanner {
public: 
    Scanner();
    ~Scanner();
    bool loadSignatures(const std::string& db_path);
    bool reloadDatabase(const std::string& db_path);
    bool loadThreatDatabase(const std::string& json_path);
    std::string calculateSHA256(const std::string& file_path);
    std::string calculateMD5(const std::string& file_path);
    std::string calculateSHA1(const std::string& file_path);
    ScanResult scanFile(const std::string& file_path);
    bool startComputerScan();
    void stopComputerScan();
    ComputerScanProgress getComputerScanProgress() const;
    void setHeuristicAnalyzer(HeuristicAnalyzer* analyzer);
    void setYaraScanner(YaraScanner* scanner);
    void setArchiveScanner(ArchiveScanner* scanner);
    SmartScanStats getCacheStats() const;
    void invalidateCache();
    void clearCache();

private:
    mutable std::shared_mutex db_reload_mutex_;

    std::unique_ptr<SignatureDatabase> db_;
    std::unique_ptr<ThreatDatabase> db_threat_;
    HeuristicAnalyzer* heuristic_ = nullptr;
    YaraScanner* yara_ = nullptr;
    ArchiveScanner* archive_scanner_ = nullptr;

    mutable std::mutex progress_mutex_;
    ComputerScanProgress progress_;

    std::atomic<bool> scan_stop_flag_{ false };
    std::thread scan_thread_;
    void scanDirectoryRecursive(const std::string& path, int depth = 0);
    bool shouldSkipPath(const std::string& path) const;
    bool shouldRunHeuristic(const std::string& path) const;
    bool shouldRunYara(const std::string& path) const;
    bool isArchiveFile(const std::string& path) const;
    FileHasher hasher_;

    int num_workers_ = 0;
    std::vector<std::thread> worker_threads_;
    std::vector<std::string> file_queue_;
    std::mutex queue_mutex_;
    std::condition_variable queue_cv_;
    std::atomic<bool> pool_running_{ false };

    void scanWorkerLoop();
    void startWorkerPool();
    void stopWorkerPool();

    SmartScanCache scan_cache_;
    TrustedFileReputation trusted_cache_;
    mutable std::mutex exclusions_mutex_;
    std::vector<std::string> user_exclusions_;
    std::string exclusions_file_;

public: bool loadExclusions(const std::string& json_path);
    bool saveExclusions() const;
    std::vector<std::string> getExclusions() const;
    bool addExclusion(const std::string& path);
    bool removeExclusion(const std::string& path);
};