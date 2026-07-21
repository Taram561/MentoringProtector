#include "pch.h"
#include "yara_scanner.h"
#include "../unicode_utils.h"

using namespace std;

static constexpr int CALLBACK_MSG_RULE_MATCHING = 1;
static constexpr int CALLBACK_MSG_RULE_NOT_MATCHING = 2;
static constexpr int CALLBACK_MSG_SCAN_FINISHED = 3;
static constexpr int CALLBACK_MSG_IMPORT_MODULE = 4;
static constexpr int CALLBACK_MSG_MODULE_IMPORTED = 5;
static constexpr int CALLBACK_CONTINUE = 0;
static constexpr int CALLBACK_ABORT = 1;
static constexpr int CALLBACK_ERROR = 2;
static constexpr int META_TYPE_NULL = 0;
static constexpr int META_TYPE_INTEGER = 1;
static constexpr int META_TYPE_STRING = 2;
static constexpr int META_TYPE_BOOLEAN = 3;

#pragma pack(push, 8)

struct YR_META_COMPAT {
    int32_t type;
    int32_t _pad;
    union {
        int64_t integer;
        char* string;
    };
    const char* identifier;
};

struct YR_RULE_COMPAT {
    int32_t g_flags;
    int32_t num_atoms;
    void* ns;
    const char* identifier;
    const char* tags;
    YR_META_COMPAT* metas;
};

#pragma pack(pop)

struct ScanContext {
    vector<YaraMatch>* matches;
    int total_score;
    string worst_rule;
    int worst_score;
};

YaraScanner::YaraScanner() = default;
YaraScanner::~YaraScanner() { shutdown(); }

bool YaraScanner::initialize(const string& rules_dir) {
    lock_guard<mutex> lock(mutex_);

    if (initialized_) return available_;

    rules_dir_ = rules_dir;

    OutputDebugStringA("[MP][YARA] init step 1: loadLibrary...\n");
    if (!loadLibrary()) { OutputDebugStringA("[MP][YARA] yara.dll not found - YARA engine disabled\n"); initialized_ = true; available_ = false; return false; }
    OutputDebugStringA("[MP][YARA] init step 1: OK\n");
    OutputDebugStringA("[MP][YARA] init step 2: yr_initialize...\n");
    int result = yr_initialize_();
    if (result != 0) { char msg[128]; sprintf_s(msg, "[MP][YARA] yr_initialize failed with code %d\n", result); OutputDebugStringA(msg); FreeLibrary(yara_dll_); yara_dll_ = nullptr; initialized_ = true; available_ = false; return false; }
    OutputDebugStringA("[MP][YARA] init step 2: OK\n");
    OutputDebugStringA("[MP][YARA] init step 3: loading rules...\n");
    rules_count_ = loadCompiledRules(rules_dir);
    if (rules_count_ == 0) { OutputDebugStringA("[MP][YARA] init step 3a: no .yrc, compiling .yar...\n"); rules_count_ = compileRulesFromDir(rules_dir); }

    if (rules_count_ > 0) { char msg[256]; sprintf_s(msg, "[MP][YARA] Loaded %d rules from %s\n", rules_count_, rules_dir.c_str()); OutputDebugStringA(msg); available_ = true; }
    else { OutputDebugStringA("[MP][YARA] No rules loaded - YARA scan will be skipped\n"); available_ = false; }

    initialized_ = true;
    return available_;
}

static const char g_yaraModuleMarker = 0;

bool YaraScanner::loadLibrary() {
    WCHAR dllDir[MAX_PATH] = {};
    HMODULE hSelf = nullptr;
    GetModuleHandleExW(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS | GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT, reinterpret_cast<LPCWSTR>(&g_yaraModuleMarker), &hSelf);
    if (hSelf) { GetModuleFileNameW(hSelf, dllDir, MAX_PATH); wchar_t* lastSlash = wcsrchr(dllDir, L'\\'); if (lastSlash) *(lastSlash + 1) = L'\0'; }

    wstring yaraPath = wstring(dllDir) + L"yara.dll";
    yara_dll_ = LoadLibraryW(yaraPath.c_str());

    if (!yara_dll_) { yaraPath = wstring(dllDir) + L"data\\yara.dll"; yara_dll_ = LoadLibraryW(yaraPath.c_str()); }

    if (!yara_dll_) {
        wstring searchDir = wstring(dllDir);
        for (int i = 0; i < 8 && !yara_dll_; i++) {
            yaraPath = searchDir + L"data\\yara.dll";
            DWORD attr = GetFileAttributesW(yaraPath.c_str());
            if (attr != INVALID_FILE_ATTRIBUTES && !(attr & FILE_ATTRIBUTE_DIRECTORY)) yara_dll_ = LoadLibraryW(yaraPath.c_str());
            size_t pos = searchDir.rfind(L'\\', searchDir.size() - 2);
            if (pos == wstring::npos) break;
            searchDir = searchDir.substr(0, pos + 1);
        }
    }

    if (!yara_dll_) return false;

    #define LOAD_FN(name, type) \
        name##_ = (type)GetProcAddress(yara_dll_, #name); \
        if (!name##_) { FreeLibrary(yara_dll_); yara_dll_ = nullptr; return false; }

    LOAD_FN(yr_initialize, FnYrInitialize)
    LOAD_FN(yr_finalize, FnYrFinalize)
    LOAD_FN(yr_compiler_create, FnYrCompilerCreate)
    LOAD_FN(yr_compiler_destroy, FnYrCompilerDestroy)
    LOAD_FN(yr_compiler_add_file, FnYrCompilerAddFile)
    LOAD_FN(yr_compiler_get_rules, FnYrCompilerGetRules)
    LOAD_FN(yr_rules_destroy, FnYrRulesDestroy)
    LOAD_FN(yr_rules_load, FnYrRulesLoad)
    LOAD_FN(yr_scanner_create, FnYrScannerCreate)
    LOAD_FN(yr_scanner_destroy, FnYrScannerDestroy)
    LOAD_FN(yr_scanner_set_timeout, FnYrScannerSetTimeout)
    LOAD_FN(yr_scanner_scan_file, FnYrScannerScanFile)
    LOAD_FN(yr_scanner_set_callback, FnYrScannerSetCallback)

    yr_compiler_add_string_ = (FnYrCompilerAddString)GetProcAddress(yara_dll_, "yr_compiler_add_string");
    yr_rules_save_ = (FnYrRulesSave)GetProcAddress(yara_dll_, "yr_rules_save");

    #undef LOAD_FN

    return true;
}

int YaraScanner::compileRulesFromDir(const string& dir_path) {
    string search_path = dir_path + "\\*.yar";
    wstring wide_search = unicode_utils::utf8_to_wide(search_path);

    WIN32_FIND_DATAW find_data;
    HANDLE hFind = FindFirstFileW(wide_search.c_str(), &find_data);
    if (hFind == INVALID_HANDLE_VALUE) return 0;

    void* compiler = nullptr;
    if (yr_compiler_create_(&compiler) != 0) { FindClose(hFind); return 0; }

    int files_added = 0;

    do {
        if (find_data.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) continue;

        wstring wide_name(find_data.cFileName);
        string file_name = unicode_utils::wide_to_utf8(wide_name);
        string full_path = dir_path + "\\" + file_name;

        string ns = file_name;
        size_t dot_pos = ns.rfind('.');
        if (dot_pos != string::npos) ns = ns.substr(0, dot_pos);

        if (yr_compiler_add_string_) {
            wstring wide_full = unicode_utils::utf8_to_wide(full_path);
            HANDLE hFile = CreateFileW(wide_full.c_str(), GENERIC_READ, FILE_SHARE_READ, nullptr, OPEN_EXISTING, 0, nullptr);
            if (hFile == INVALID_HANDLE_VALUE) continue;

            DWORD fileSize = GetFileSize(hFile, nullptr);
            if (fileSize == INVALID_FILE_SIZE || fileSize > 10 * 1024 * 1024) { CloseHandle(hFile); continue; }
            string content(fileSize, '\0');
            DWORD bytesRead = 0;
            ReadFile(hFile, &content[0], fileSize, &bytesRead, nullptr);
            CloseHandle(hFile);
            content.resize(bytesRead);

            int errors = yr_compiler_add_string_(compiler, content.c_str(), ns.c_str());
            if (errors == 0) files_added++;
            else { char msg[512]; sprintf_s(msg, "[MP][YARA] Compile errors in %s: %d errors\n", file_name.c_str(), errors); OutputDebugStringA(msg); }
        } else {
            FILE* f = nullptr;
            if (fopen_s(&f, full_path.c_str(), "r") != 0 || !f) continue;

            int errors = yr_compiler_add_file_(compiler, f, ns.c_str(), file_name.c_str());
            fclose(f);
            if (errors == 0) files_added++;
        }

    } while (FindNextFileW(hFind, &find_data));
    FindClose(hFind);

    string community_path = dir_path + "\\community\\*.yar";
    wstring wide_community = unicode_utils::utf8_to_wide(community_path);
    HANDLE hFindCommunity = FindFirstFileW(wide_community.c_str(), &find_data);
    if (hFindCommunity != INVALID_HANDLE_VALUE) {
        do {
            if (find_data.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) continue;

            wstring wide_name(find_data.cFileName);
            string file_name = unicode_utils::wide_to_utf8(wide_name);
            string full_path = dir_path + "\\community\\" + file_name;
            string ns = "community_" + file_name;
            size_t dot_pos = ns.rfind('.');
            if (dot_pos != string::npos) ns = ns.substr(0, dot_pos);

            if (yr_compiler_add_string_) {
                wstring wide_full = unicode_utils::utf8_to_wide(full_path);
                HANDLE hFile = CreateFileW(wide_full.c_str(), GENERIC_READ, FILE_SHARE_READ, nullptr, OPEN_EXISTING, 0, nullptr);
                if (hFile == INVALID_HANDLE_VALUE) continue;

                DWORD fileSize = GetFileSize(hFile, nullptr);
                if (fileSize == INVALID_FILE_SIZE || fileSize > 10 * 1024 * 1024) { CloseHandle(hFile); continue; }
                string content(fileSize, '\0');
                DWORD bytesRead = 0;
                ReadFile(hFile, &content[0], fileSize, &bytesRead, nullptr);
                CloseHandle(hFile);
                content.resize(bytesRead);

                int errors = yr_compiler_add_string_(compiler, content.c_str(), ns.c_str());
                if (errors == 0) files_added++;
                else { char msg[512]; sprintf_s(msg, "[MP][YARA] Compile errors in community/%s: %d\n", file_name.c_str(), errors); OutputDebugStringA(msg); }
            }
        } while (FindNextFileW(hFindCommunity, &find_data));
        FindClose(hFindCommunity);
    }

    if (files_added == 0) { yr_compiler_destroy_(compiler); return 0; }

    void* rules = nullptr;
    if (yr_compiler_get_rules_(compiler, &rules) != 0) { yr_compiler_destroy_(compiler); return 0; }

    if (yr_rules_save_) { string cache_path = dir_path + "\\compiled_rules.yrc"; yr_rules_save_(rules, cache_path.c_str()); }

    compiled_rules_ = rules;
    yr_compiler_destroy_(compiler);
    return files_added;
}

int YaraScanner::loadCompiledRules(const string& dir_path) {
    string yrc_path = dir_path + "\\compiled_rules.yrc";
    wstring wide_path = unicode_utils::utf8_to_wide(yrc_path);
    if (GetFileAttributesW(wide_path.c_str()) == INVALID_FILE_ATTRIBUTES) return 0;

    void* rules = nullptr;
    if (yr_rules_load_(yrc_path.c_str(), &rules) != 0) { OutputDebugStringA("[MP][YARA] Failed to load compiled_rules.yrc\n"); return 0; }
    compiled_rules_ = rules;
    return 1;
}

YaraResult YaraScanner::scanFile(const string& file_path) {
    YaraResult result;
    if (!available_ || !compiled_rules_) return result;
    auto start = chrono::steady_clock::now();

    void* scanner = nullptr;
    { lock_guard<mutex> lock(mutex_); if (yr_scanner_create_(compiled_rules_, &scanner) != 0) return result; }

    yr_scanner_set_timeout_(scanner, 10);
    ScanContext ctx;
    ctx.matches = &result.matches;
    ctx.total_score = 0;
    ctx.worst_score = 0;
    yr_scanner_set_callback_(scanner, (void*)&YaraScanner::scanCallback, &ctx);
    int scan_result = yr_scanner_scan_file_(scanner, file_path.c_str());
    yr_scanner_destroy_(scanner);
    auto end = chrono::steady_clock::now();
    result.scan_time_ms = static_cast<int>(chrono::duration_cast<chrono::milliseconds>(end - start).count());

    if (!result.matches.empty()) { result.is_threat = true; result.score = ctx.total_score; result.threat_name = ctx.worst_rule.empty() ? result.matches[0].rule_name : ctx.worst_rule; }

    return result;
}

int YaraScanner::scanCallback(void* context, int message, void* message_data, void* user_data) {
    if (message == CALLBACK_MSG_SCAN_FINISHED) return CALLBACK_CONTINUE;
    if (message != CALLBACK_MSG_RULE_MATCHING) return CALLBACK_CONTINUE;

    auto* ctx = static_cast<ScanContext*>(user_data);
    if (!ctx || !ctx->matches) return CALLBACK_CONTINUE;

    auto safeAsciiStr = [](const char* ptr, size_t maxLen = 256) -> bool {
        if (!ptr || ptr[0] == '\0') return false;
        for (size_t i = 0; i < maxLen; i++) {
            unsigned char c = static_cast<unsigned char>(ptr[i]);
            if (c == '\0') return true;
            if (c < 0x20 || c > 0x7E) return false;
        }
        return false;
    };

    YaraMatch match;
    try {
        auto* rule = static_cast<YR_RULE_COMPAT*>(message_data);
        if (!rule) { match.rule_name = "YARA.Unknown"; ctx->matches->push_back(match); return CALLBACK_CONTINUE; }

        if (safeAsciiStr(rule->identifier)) match.rule_name = rule->identifier;
        else match.rule_name = "YARA.Rule." + to_string(ctx->matches->size() + 1);

        constexpr int MAX_TAGS = 16;
        if (rule->tags) { const char* tag = rule->tags; for (int ti = 0; *tag != '\0' && ti < MAX_TAGS; ti++) { if (safeAsciiStr(tag, 128)) match.tags.push_back(string(tag)); tag += strnlen(tag, 128) + 1; } }

        constexpr int MAX_METAS = 64;
        if (rule->metas) {
            int mi = 0;
            for (YR_META_COMPAT* m = rule->metas; m->type != META_TYPE_NULL && mi < MAX_METAS; m++, mi++) {
                if (!safeAsciiStr(m->identifier, 128)) continue;
                string key(m->identifier), val;
                if (m->type == META_TYPE_STRING && m->string && safeAsciiStr(m->string, 512)) val = m->string;
                else if (m->type == META_TYPE_INTEGER || m->type == META_TYPE_BOOLEAN) val = to_string(m->integer);

                if (key == "author") match.meta_author = val;
                else if (key == "description" || key == "desc") match.meta_desc = val;
                else if (key == "severity" || key == "threat_level") match.meta_severity = val;
                else if (key == "reference" || key == "url") match.meta_reference = val;
            }
        }

        int score = severityToScore(match.meta_severity.empty() ? "low" : match.meta_severity);
        ctx->total_score += score;
        if (score > ctx->worst_score) { ctx->worst_score = score; ctx->worst_rule = match.rule_name; }

    } catch (...) { match.rule_name = "YARA.Unknown"; }

    ctx->matches->push_back(match);
    return CALLBACK_CONTINUE;
}

int YaraScanner::severityToScore(const string& severity) {
    string lower = severity;
    transform(lower.begin(), lower.end(), lower.begin(), ::tolower);

    if (lower == "critical" || lower == "high") return 80;
    if (lower == "medium" || lower == "moderate") return 50;
    if (lower == "low" || lower == "info") return 25;

    try {
        int val = stoi(severity);
        if (val >= 8) return 80;
        if (val >= 5) return 50;
        if (val >= 1) return 25;
    } catch (...) {}

    return 25;
}

bool YaraScanner::isAvailable() const { return available_; }

ScanEngineResult YaraScanner::scan(const string& file_path) {
    YaraResult yr = scanFile(file_path);
    ScanEngineResult r;
    r.engine_name = "yara";
    r.is_threat = yr.is_threat;
    r.score = yr.score;
    r.threat_name = yr.threat_name;
    return r;
}

int YaraScanner::getRulesCount() const { return rules_count_; }

bool YaraScanner::reloadRules(const string& rules_dir) {
    lock_guard<mutex> lock(mutex_);

    if (!yara_dll_) return false;
    if (compiled_rules_) { yr_rules_destroy_(compiled_rules_); compiled_rules_ = nullptr; }

    rules_dir_ = rules_dir;
    rules_count_ = loadCompiledRules(rules_dir);
    if (rules_count_ == 0) rules_count_ = compileRulesFromDir(rules_dir);

    available_ = (rules_count_ > 0);
    return available_;
}

void YaraScanner::shutdown() {
    lock_guard<mutex> lock(mutex_);

    if (compiled_rules_ && yr_rules_destroy_) { yr_rules_destroy_(compiled_rules_); compiled_rules_ = nullptr; }
    if (yr_finalize_) yr_finalize_();
    if (yara_dll_) { FreeLibrary(yara_dll_); yara_dll_ = nullptr; }

    initialized_ = false;
    available_ = false;
    rules_count_ = 0;
}
