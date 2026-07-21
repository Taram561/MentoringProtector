#pragma once
#include "pch.h"
#include "../scanner/i_scan_engine.h"

struct YaraMatch {
    std::string rule_name;
    std::string rule_namespace;
    std::vector<std::string> tags;
    std::string meta_author;
    std::string meta_desc;
    std::string meta_severity;
    std::string meta_reference;
    std::vector<std::string> matched_strings;
};

struct YaraResult {
    bool is_threat = false;
    int score = 0;
    std::string threat_name;
    std::vector<YaraMatch> matches;
    int scan_time_ms = 0;
};

class YaraScanner : public IScanEngine {
public: YaraScanner();
    ~YaraScanner();
    ScanEngineResult scan(const std::string& file_path) override;
    std::string name() const override { return "yara"; }
    bool initialize(const std::string& rules_dir);
    YaraResult scanFile(const std::string& file_path);
    bool isAvailable() const override;
    int getRulesCount() const;
    bool reloadRules(const std::string& rules_dir);
    void shutdown();
private:
    bool initialized_ = false;
    bool available_ = false;
    int rules_count_ = 0;
    std::string rules_dir_;
    HMODULE yara_dll_ = nullptr;
    void* compiled_rules_ = nullptr;
    std::mutex mutex_;
    using FnYrInitialize = int (*)();
    using FnYrFinalize = int (*)();
    using FnYrCompilerCreate = int (*)(void** compiler);
    using FnYrCompilerDestroy = void (*)(void* compiler);
    using FnYrCompilerAddFile = int (*)(void* compiler, FILE* file, const char* ns, const char* file_name);
    using FnYrCompilerAddString = int (*)(void* compiler, const char* string, const char* ns);
    using FnYrCompilerGetRules = int (*)(void* compiler, void** rules);
    using FnYrRulesDestroy = int (*)(void* rules);
    using FnYrRulesSave = int (*)(void* rules, const char* path);
    using FnYrRulesLoad = int (*)(const char* path, void** rules);
    using FnYrScannerCreate = int (*)(void* rules, void** scanner);
    using FnYrScannerDestroy = void (*)(void* scanner);
    using FnYrScannerSetTimeout = void (*)(void* scanner, int timeout);
    using FnYrScannerScanFile = int (*)(void* scanner, const char* file_path);
    using FnYrScannerSetCallback = void (*)(void* scanner, void* callback, void* user_data);

    FnYrInitialize yr_initialize_ = nullptr;
    FnYrFinalize yr_finalize_ = nullptr;
    FnYrCompilerCreate yr_compiler_create_ = nullptr;
    FnYrCompilerDestroy yr_compiler_destroy_ = nullptr;
    FnYrCompilerAddFile yr_compiler_add_file_ = nullptr;
    FnYrCompilerAddString yr_compiler_add_string_ = nullptr;
    FnYrCompilerGetRules yr_compiler_get_rules_ = nullptr;
    FnYrRulesDestroy yr_rules_destroy_ = nullptr;
    FnYrRulesSave yr_rules_save_ = nullptr;
    FnYrRulesLoad yr_rules_load_ = nullptr;
    FnYrScannerCreate yr_scanner_create_ = nullptr;
    FnYrScannerDestroy yr_scanner_destroy_ = nullptr;
    FnYrScannerSetTimeout yr_scanner_set_timeout_ = nullptr;
    FnYrScannerScanFile yr_scanner_scan_file_ = nullptr;
    FnYrScannerSetCallback yr_scanner_set_callback_ = nullptr;

    bool loadLibrary();
    int compileRulesFromDir(const std::string& dir_path);
    int loadCompiledRules(const std::string& dir_path);
    static int scanCallback(void* context, int message, void* message_data, void* user_data);
    static int severityToScore(const std::string& severity);
};