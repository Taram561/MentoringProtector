#include "pch.h"
#include "exports.h"
#include "json_utils.h"
#include "unicode_utils.h"
#include <string_view>
#include "scanner/scanner.h"
#include "quarantine/quarantine.h"
#include "process_analyzer/process_analyzer.h"
#include "vulnerability/vulnerability_scanner.h"
#include "web_protection/web_protection_exports.h"
#include "realtime_monitor/realtime_monitor.h"
#include "memory_scanner/memory_scanner.h"
#include "heuristic/crl_updater.h"
#include "yara/yara_scanner.h"
#include "logger/logger.h"
#include "stats/stats_recorder.h"
#include "sandbox/sandbox_manager.h"
#include "archive_scanner/archive_scanner.h"
#include "archive_scanner/zip_extractor.h"
#include "archive_scanner/seven_zip_extractor.h"
#include "archive_scanner/iso_extractor.h"
#include "nudge/nudge_engine.h"
#include "nudge/tray_notifier.h"
#include "nudge/usb_monitor.h"

#ifndef TRUST_E_REVOCATION_STATUS_UNKNOWN
#define TRUST_E_REVOCATION_STATUS_UNKNOWN static_cast<LONG>(0x800B010BL)
#endif

using namespace std;
using json_utils::escapeJson;
using json_utils::boolToJson;

static string _findDllDir() {
    char path[MAX_PATH] = {};
    HMODULE hm = NULL;
    GetModuleHandleExA(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS | GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT, (LPCSTR)&_findDllDir, &hm);
    GetModuleFileNameA(hm, path, MAX_PATH);
    string dir(path);
    auto pos = dir.find_last_of("\\/");
    if (pos != string::npos) dir = dir.substr(0, pos + 1);
    return dir;
}

static once_flag g_dll_dir_flag;
static string g_dll_dir_value;

static const string& getDllDir() {
    call_once(g_dll_dir_flag, []() {
        string dllDir = _findDllDir();
        DWORD attr = GetFileAttributesA((dllDir + "data").c_str());
        if (attr != INVALID_FILE_ATTRIBUTES && (attr & FILE_ATTRIBUTE_DIRECTORY)) g_dll_dir_value = dllDir;
        else { g_dll_dir_value = "..\\"; }
    });
    return g_dll_dir_value;
}

static once_flag g_dll_dir_w_flag;
static wstring g_dll_dir_w_value;

static const wstring& getDllDirW() {
    call_once(g_dll_dir_w_flag, []() {
        wchar_t path[MAX_PATH] = {};
        HMODULE hm = NULL;
        GetModuleHandleExW(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS | GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT, (LPCWSTR)&_findDllDir, &hm);
        GetModuleFileNameW(hm, path, MAX_PATH);
        wstring dllDir(path);
        auto pos = dllDir.find_last_of(L"\\/");
        if (pos != wstring::npos) dllDir = dllDir.substr(0, pos + 1);

        DWORD attr = GetFileAttributesW((dllDir + L"data").c_str());
        if (attr != INVALID_FILE_ATTRIBUTES && (attr & FILE_ATTRIBUTE_DIRECTORY)) g_dll_dir_w_value = dllDir;
        else { g_dll_dir_w_value = L"..\\"; }
    });
    return g_dll_dir_w_value;
}

static string resultToJson(const ScanResult& result) {
    ostringstream json;

    json << "{" << "\"is_infected\":" << (result.is_infected ? "true" : "false") << "," << "\"file_path\":\"" << escapeJson(result.file_path) << "\"," << "\"file_hash\":\"" << escapeJson(result.file_hash) << "\"," << "\"threat_name\":\"" << escapeJson(result.threat_name) << "\"," << "\"threat_type\":\"" << escapeJson(result.threat_type) << "\"," << "\"danger_level\":" << result.danger_level << "," << "\"detection_method\":\"" << escapeJson(result.detection_method) << "\"," << "\"engines_triggered\":[";
    for (size_t i = 0; i < result.engines_triggered.size(); ++i) {
        if (i > 0) json << ",";
        json << "\"" << escapeJson(result.engines_triggered[i]) << "\"";
    }
    json << "]";

    if (result.is_infected) {
        const ThreatInfo& ti = result.threat_info;
        json << "," << "\"display_name\":\"" << escapeJson(ti.display_name) << "\"," << "\"description_short\":\"" << escapeJson(ti.description_short) << "\"," << "\"description_full\":\"" << escapeJson(ti.description_full) << "\"," << "\"how_it_spreads\":\"" << escapeJson(ti.how_it_spreads) << "\"," << "\"what_it_does\":\"" << escapeJson(ti.what_it_does) << "\"," << "\"recommended_action\":\"" << escapeJson(ti.recommended_action) << "\"," << "\"hygiene_category\":\"" << escapeJson(ti.hygiene_category) << "\",";

        json << "\"removal_steps\":[";
        for (size_t i = 0; i < ti.removal_steps.size(); i++) {
            json << "\"" << escapeJson(ti.removal_steps[i].description) << "\"";
            if (i < ti.removal_steps.size() - 1) json << ",";
        }
        json << "],";

        json << "\"prevention_tips\":[";
        for (size_t i = 0; i < ti.prevention_tips.size(); i++) {
            json << "\"" << escapeJson(ti.prevention_tips[i]) << "\"";
            if (i < ti.prevention_tips.size() - 1) json << ",";
        }
        json << "]";
    }

    const HeuristicResult& hr = result.heuristic;
    if (hr.analyzed) {
        json << "," << "\"heuristic_score\":" << hr.suspicion_score << "," << "\"heuristic_verdict\":\"" << escapeJson(hr.verdict) << "\"," << "\"heuristic_danger\":" << hr.danger_level << "," << "\"entropy\":" << hr.entropy << "," << "\"is_pe_file\":" << (hr.is_pe_file ? "true" : "false") << "," << "\"is_packed\":" << (hr.is_packed ? "true" : "false") << "," << "\"has_signature\":" << (hr.has_signature ? "true" : "false") << "," << "\"signer_name\":\"" << escapeJson(hr.signature.signer_name) << "\"," << "\"signer_issuer\":\"" << escapeJson(hr.signature.issuer) << "\"," << "\"signature_expiry\":\"" << escapeJson(hr.signature.expiry_date) << "\"," << "\"signature_thumbprint\":\"" << escapeJson(hr.signature.thumbprint) << "\"," << "\"is_revoked\":" << (hr.signature.is_revoked ? "true" : "false") << "," << "\"revocation_status\":\"" << escapeJson(hr.signature.revocation_status) << "\",";

        json << "\"triggered_rules\":[";
        for (size_t i = 0; i < hr.triggered_rules.size(); i++) {
            json << "\"" << escapeJson(hr.triggered_rules[i]) << "\"";
            if (i < hr.triggered_rules.size() - 1) json << ",";
        }
        json << "],";

        json << "\"suspicious_imports\":[";
        for (size_t i = 0; i < hr.suspicious_imports.size(); i++) {
            json << "\"" << escapeJson(hr.suspicious_imports[i]) << "\"";
            if (i < hr.suspicious_imports.size() - 1) json << ",";
        }
        json << "],";

        json << "\"suspicious_strings\":[";
        for (size_t i = 0; i < hr.suspicious_strings.size(); i++) {
            json << "\"" << escapeJson(hr.suspicious_strings[i]) << "\"";
            if (i < hr.suspicious_strings.size() - 1) json << ",";
        }
        json << "]";
    }

    const YaraResult& yr = result.yara;
    if (!yr.matches.empty()) {
        json << "," << "\"yara_score\":" << yr.score << "," << "\"yara_scan_time_ms\":" << yr.scan_time_ms << "," << "\"yara_matches\":[";

        for (size_t i = 0; i < yr.matches.size(); i++) {
            const YaraMatch& m = yr.matches[i];
            json << "{"
                << "\"rule_name\":\"" << escapeJson(m.rule_name) << "\"," << "\"rule_namespace\":\"" << escapeJson(m.rule_namespace) << "\"," << "\"meta_author\":\"" << escapeJson(m.meta_author) << "\"," << "\"meta_desc\":\"" << escapeJson(m.meta_desc) << "\"," << "\"meta_severity\":\"" << escapeJson(m.meta_severity) << "\"," << "\"meta_reference\":\"" << escapeJson(m.meta_reference) << "\"," << "\"tags\":[";
            for (size_t t = 0; t < m.tags.size(); t++) {
                json << "\"" << escapeJson(m.tags[t]) << "\"";
                if (t < m.tags.size() - 1) json << ",";
            }
            json << "],\"matched_strings\":[";
            for (size_t s = 0; s < m.matched_strings.size(); s++) {
                json << "\"" << escapeJson(m.matched_strings[s]) << "\"";
                if (s < m.matched_strings.size() - 1) json << ",";
            }
            json << "]}";
            if (i < yr.matches.size() - 1) json << ",";
        }
        json << "]";
    }
    json << "}";
    return json.str();
}

static char* stringToCharPtr(const string& str) {
    char* result = new char[str.length() + 1];
    strcpy_s(result, str.length() + 1, str.c_str());
    return result;
}

static Scanner* g_scanner = nullptr;
static HeuristicAnalyzer g_heuristic;
static ThreatDatabase g_threat_db;
static ArchiveScanner g_archive_scanner;
static QuarantineManager* g_quarantine_ptr = nullptr;
static QuarantineManager& getQuarantine() {if (!g_quarantine_ptr) g_quarantine_ptr = new QuarantineManager((getDllDir() + "quarantine").c_str()); return *g_quarantine_ptr;}
static unique_ptr<ProcessAnalyzer> g_process_analyzer;
static unique_ptr<RealtimeMonitor> g_realtime_monitor;
static NudgeEngine g_nudge_engine;
static TrayNotifier g_tray_notifier;
static UsbMonitor g_usb_monitor;
static MemoryScanner g_memory_scanner;
static CrlUpdater g_crl_updater;
static YaraScanner g_yara;
static atomic<bool> g_yara_init_done{ false };
static atomic<bool> g_initialized{ false };
static bool g_pa_initialized = false;
static bool g_rt_initialized = false;
static once_flag g_init_flag;

static void initializeCore() {
    call_once(g_init_flag, []() {
        try {
            auto base = getDllDir();
            Logger::instance().info("Core", "initializeCore: base=" + base);
            g_scanner = new Scanner();
            auto sigPath = base + "data\\signatures.msdb";
            Logger::instance().info("Core", "Loading signatures: " + sigPath);
            bool sigOk = g_scanner->loadSignatures(sigPath.c_str());
            Logger::instance().info("Core", string("Signatures load result=") + (sigOk ? "OK" : "FAIL"));
            g_scanner->loadThreatDatabase((base + "data\\threat_database.json").c_str());
            g_heuristic.loadRules((base + "data\\heuristic_rules.json").c_str());
            g_scanner->setHeuristicAnalyzer(&g_heuristic);

            g_scanner->loadExclusions((base + "data\\exclusions.json").c_str());

            g_archive_scanner.addExtractor(make_unique<ZipExtractor>());
            wstring dllDirW = unicode_utils::utf8_to_wide(base);
            g_archive_scanner.addExtractor(make_unique<SevenZipExtractor>(dllDirW));
            g_archive_scanner.addExtractor(make_unique<IsoExtractor>());
            g_archive_scanner.setScanCallback([](const string& path) -> ScanResult {
                if (!g_scanner) { ScanResult r; r.detection_method = "clean"; return r; }
                return g_scanner->scanFile(path);
            });
            g_archive_scanner.setBaseExtractionDir(getDllDirW() + L"tmp\\unpack\\");
            g_scanner->setArchiveScanner(&g_archive_scanner);

            g_process_analyzer = make_unique<ProcessAnalyzer>(g_scanner, &g_heuristic);
            g_realtime_monitor = make_unique<RealtimeMonitor>(RealtimeMonitorConfig{}, g_scanner, &g_heuristic, &g_nudge_engine);
            g_usb_monitor.start(&g_nudge_engine);
            g_tray_notifier.start();
            web_protection_set_nudge_sink(&g_nudge_engine);

            g_initialized = true;
            g_pa_initialized = false;
            g_rt_initialized = false;
            Logger::instance().info("Core", "initializeCore OK, g_initialized=true");
        }
        catch (const exception& e) {
            Logger::instance().error("Core", string("initializeCore exception: ") + e.what());
            OutputDebugStringA("[MP] initializeCore exception: ");
            OutputDebugStringA(e.what());
            OutputDebugStringA("\n");
        }
        catch (...) {
            Logger::instance().error("Core", "initializeCore unknown exception");
            OutputDebugStringA("[MP] initializeCore unknown exception\n");
        }
    });
}

#define MP_GUARD_SCANNER(fail_return) initializeCore(); if (!g_initialized.load() || !g_scanner)  return stringToCharPtr(std::string(fail_return));      

BOOL APIENTRY DllMain(HMODULE hModule, DWORD ul_reason_for_call, LPVOID lpReserved) {
    switch (ul_reason_for_call) {
    case DLL_PROCESS_ATTACH:
        SetDefaultDllDirectories(LOAD_LIBRARY_SEARCH_DEFAULT_DIRS);
        break;

    case DLL_PROCESS_DETACH:
        g_usb_monitor.stop();
        g_tray_notifier.stop();
        g_yara.shutdown();
        g_crl_updater.stop();
        if (g_process_analyzer) g_process_analyzer->stopMonitoring();
        web_protection_stop();
        try { stats::StatsRecorder::instance().flush(); } catch (...) {}
        break;

    case DLL_THREAD_ATTACH: case DLL_THREAD_DETACH: break;
    }
    return TRUE;
}

MP_API char* get_file_hash(const char* file_path) {
    if (!file_path) return stringToCharPtr("");
    MP_GUARD_SCANNER(stringToCharPtr(""));
    string hash = g_scanner->calculateSHA256(file_path);
    return stringToCharPtr(hash);
}

MP_API char* scan_file(const char* file_path) {
    if (!file_path) return stringToCharPtr("{}");
    MP_GUARD_SCANNER(stringToCharPtr("{\"error\":\"core_not_initialized\"}"));
    Logger::instance().info("Core", string("scan_file called: ") + file_path);
    ScanResult result = g_scanner->scanFile(file_path);
    Logger::instance().info("Core", "scan_file result: infected=" + string(result.is_infected ? "YES" : "no") + " threat=" + result.threat_name + " method=" + result.detection_method);
    return stringToCharPtr(resultToJson(result));
}

MP_API void free_string(char* ptr) { if (ptr != nullptr) delete[] ptr; }
MP_API unsigned int mp_get_api_version() { return 0x00010000u; }
MP_API char* get_core_version() { return stringToCharPtr("1.0.0"); }
MP_API int reload_signatures() {
    if (!g_initialized.load() || !g_scanner) return 0;
    const string sigPath = getDllDir() + "data\\signatures.msdb";
    return g_scanner->reloadDatabase(sigPath) ? 1 : 0;
}
MP_API char* get_active_engines() {
    vector<string> active;
    if (g_initialized.load() && g_scanner) active.emplace_back("signature");
    if (g_yara.isAvailable()) active.emplace_back("yara");
    if (g_heuristic.isAvailable()) active.emplace_back("heuristic");

    ostringstream json;
    json << "{\"engines\":[";
    for (size_t i = 0; i < active.size(); ++i) {
        if (i > 0) json << ",";
        json << "\"" << active[i] << "\"";
    }
    json << "],\"count\":" << active.size() << "}";
    return stringToCharPtr(json.str());
}
MP_API char* core_initialize() {
    initializeCore();
    return stringToCharPtr("{\"success\":true}");
}

MP_API char* quarantine_file(const char* file_path, const char* threat_name, const char* threat_type, int danger_level, const char* file_hash, const char* detection_method) {
    initializeCore();
    if (!file_path || file_path[0] == '\0') return stringToCharPtr("{\"success\":false,\"status\":5,\"error\":\"empty_path\"}");
    string pathStr(file_path);
    if (pathStr.length() > MAX_PATH) return stringToCharPtr("{\"success\":false,\"status\":5,\"error\":\"path_too_long\"}");
    vector<wchar_t> canonical(32768);
    DWORD canonLen = GetFullPathNameW(unicode_utils::utf8_to_wide(pathStr).c_str(), static_cast<DWORD>(canonical.size()), canonical.data(), nullptr);
    if (canonLen == 0 || canonLen >= static_cast<DWORD>(canonical.size())) return stringToCharPtr("{\"success\":false,\"status\":5,\"error\":\"path_invalid\"}");

    string canonStr = unicode_utils::wide_to_utf8(canonical.data());

    if (canonStr.rfind("\\\\?\\", 0) == 0 || canonStr.rfind("\\??\\",  0) == 0 || canonStr.rfind("\\\\.\\",  0) == 0) return stringToCharPtr("{\"success\":false,\"status\":5,\"error\":\"path_traversal\"}");

    size_t firstColon = canonStr.find(':');
    if (firstColon != string::npos && canonStr.find(':', firstColon + 1) != string::npos) return stringToCharPtr("{\"success\":false,\"status\":5,\"error\":\"path_traversal\"}");

    if (canonStr.find("..") != string::npos) return stringToCharPtr("{\"success\":false,\"status\":5,\"error\":\"path_traversal\"}");

    QuarantineEntry entry;
    entry.original_path = canonStr;
    entry.threat_name = threat_name ? threat_name: "";
    entry.threat_type = threat_type ? threat_type: "";
    entry.danger_level = danger_level;
    entry.file_hash = file_hash ? file_hash: "";
    entry.detection_method = detection_method ? detection_method : "";

    QuarantineStatus status = getQuarantine().quarantineFile(entry);

    ostringstream json;
    json << "{" << "\"success\":" << (status == QuarantineStatus::Success ? "true" : "false") << "," << "\"entry_id\":\"" << escapeJson(entry.id) << "\"," << "\"status\":" << (int)status << "}";

    return stringToCharPtr(json.str());
}

MP_API char* restore_file(const char* entry_id) {
    if (!entry_id) return stringToCharPtr("{\"success\":false}");
    QuarantineStatus status = getQuarantine().restoreFile(entry_id);
    ostringstream json;
    json << "{" << "\"success\":" << (status == QuarantineStatus::Success ? "true" : "false") << "," << "\"status\":" << (int)status << "}";
    return stringToCharPtr(json.str());
}

MP_API char* delete_from_quarantine(const char* entry_id) {
    if (!entry_id) return stringToCharPtr("{\"success\":false}");

    QuarantineStatus status = getQuarantine().deleteFile(entry_id);
    ostringstream json;
    json << "{" << "\"success\":" << (status == QuarantineStatus::Success ? "true" : "false") << "," << "\"status\":" << (int)status << "}";
    return stringToCharPtr(json.str());
}

MP_API char* get_quarantine_list() {
    auto entries = getQuarantine().getAllEntries();
    ostringstream json;
    json << "{\"count\":" << entries.size() << ",\"total_size\":" << getQuarantine().getTotalSize() << ",\"entries\":[";

    for (size_t i = 0; i < entries.size(); i++) {
        const auto& e = entries[i];
        json << "{" << "\"id\":\"" << escapeJson(e.id) << "\"," << "\"original_name\":\"" << escapeJson(e.original_name) << "\"," << "\"original_path\":\"" << escapeJson(e.original_path) << "\"," << "\"threat_name\":\"" << escapeJson(e.threat_name) << "\"," << "\"threat_type\":\"" << escapeJson(e.threat_type) << "\"," << "\"danger_level\":" << e.danger_level << "," << "\"date_quarantined\":\"" << escapeJson(e.date_quarantined) << "\"," << "\"file_size\":" << e.file_size << "," << "\"detection_method\":\"" << escapeJson(e.detection_method) << "\"," << "\"is_orphan\":" << boolToJson(e.is_orphan) << "}";
        if (i < entries.size() - 1) json << ",";
    }
    json << "]}";
    return stringToCharPtr(json.str());
}

MP_API char* start_process_monitoring() {
    initializeCore();
    bool success = g_process_analyzer->startMonitoring();
    return stringToCharPtr(string("{\"success\":") + (success ? "true" : "false") + "}");
}

MP_API char* stop_process_monitoring() {
    g_process_analyzer->stopMonitoring();
    return stringToCharPtr("{\"success\":true}");
}

MP_API char* get_process_alerts() {
    auto alerts = g_process_analyzer->getAndClearAlerts();

    ostringstream json;
    json << "{\"count\":" << alerts.size() << ",\"alerts\":[";

    for (size_t i = 0; i < alerts.size(); i++) {
        const auto& a = alerts[i];
        json << "{" << "\"pid\":" << a.pid << "," << "\"process_name\":\"" << escapeJson(a.process_name) << "\"," << "\"exe_path\":\"" << escapeJson(a.exe_path) << "\"," << "\"file_hash\":\"" << escapeJson(a.file_hash) << "\"," << "\"score\":" << a.suspicion_score << "," << "\"verdict\":\"" << escapeJson(a.verdict) << "\"," << "\"threat_name\":\"" << escapeJson(a.threat_name) << "\"," << "\"danger_level\":" << a.danger_level << "," << "\"method\":\"" << escapeJson(a.detection_method) << "\"," << "\"detected_at\":\"" << escapeJson(a.detected_at) << "\"," << "\"is_blocked\":" << (a.is_blocked ? "true" : "false") << "," << "\"rules\":[";

        for (size_t j = 0; j < a.triggered_rules.size(); j++) {
            json << "\"" << escapeJson(a.triggered_rules[j]) << "\"";
            if (j < a.triggered_rules.size() - 1) json << ",";
        }
        json << "]}";
        if (i < alerts.size() - 1) json << ",";
    }

    json << "]}";
    return stringToCharPtr(json.str());
}

MP_API char* analyze_process(int pid) {
    initializeCore();
    const DWORD dpid = static_cast<DWORD>(pid);
    {
        lock_guard<mutex> lk(g_process_analyzer->cache_mutex_);
        auto it = g_process_analyzer->analysis_cache_.find(dpid);
        if (it != g_process_analyzer->analysis_cache_.end()) {
            ULONGLONG now = GetTickCount64();
            if (now < it->second.expiry_ms) return stringToCharPtr(it->second.json);
        }
    }

    ProcessAlert a = g_process_analyzer->analyzeProcess(dpid);

    DWORD parentPid = g_process_analyzer->getProcessParentPid(dpid);
    string cmdline = g_process_analyzer->getProcessCmdline(dpid);
    auto modules = g_process_analyzer->getProcessModules(dpid);
    string sig = ProcessAnalyzer::verifyProcessSignature(a.exe_path);

    ostringstream json;
    json << "{" << "\"pid\":" << a.pid << "," << "\"process_name\":\"" << escapeJson(a.process_name) << "\"," << "\"exe_path\":\"" << escapeJson(a.exe_path) << "\"," << "\"parent_pid\":" << parentPid << "," << "\"cmdline\":\"" << escapeJson(cmdline) << "\"," << "\"file_hash\":\"" << escapeJson(a.file_hash) << "\"," << "\"digital_signature\":\"" << sig << "\"," << "\"score\":" << a.suspicion_score << "," << "\"verdict\":\"" << escapeJson(a.verdict) << "\"," << "\"danger_level\":" << a.danger_level << "," << "\"method\":\"" << escapeJson(a.detection_method) << "\"," << "\"modules\":[";

    for (size_t i = 0; i < modules.size(); i++) {
        if (i > 0) json << ",";
        json << "{" << "\"name\":\"" << escapeJson(modules[i].name) << "\"," << "\"size\":" << modules[i].size << "}";
    }
    json << "]}";

    string result = json.str();
    {
        lock_guard<mutex> lk(g_process_analyzer->cache_mutex_);
        g_process_analyzer->analysis_cache_[dpid] = { GetTickCount64() + ProcessAnalyzer::kCacheTtlMs, result };
    }
    return stringToCharPtr(result);
}

MP_API char* terminate_process_by_pid(int pid) {
    bool success = g_process_analyzer->terminateProcess(static_cast<DWORD>(pid));
    return stringToCharPtr(string("{\"success\":") + (success ? "true" : "false") + "}");
}

MP_API char* is_monitoring() {
    bool active = g_process_analyzer->isMonitoring();
    return stringToCharPtr(string("{\"active\":") + (active ? "true" : "false") + "}");
}

MP_API char* scan_vulnerabilities() {
    VulnerabilityScanner scanner;
    VulnerabilityReport report = scanner.scanDevice();

    ostringstream json;
    json << "{" << "\"total\":" << report.total_count << "," << "\"critical\":" << report.critical_count << "," << "\"high\":" << report.high_count << "," << "\"medium\":" << report.medium_count << "," << "\"low\":" << report.low_count << "," << "\"scan_time\":\"" << escapeJson(report.scan_time) << "\"," << "\"os_version\":\"" << escapeJson(report.os_version) << "\"," << "\"computer\":\"" << escapeJson(report.computer_name) << "\"," << "\"vulnerabilities\":[";

    for (size_t i = 0; i < report.vulnerabilities.size(); i++) {
        const auto& v = report.vulnerabilities[i];

        string severity;
        switch (v.severity) {
        case VulnSeverity::Critical: severity = "critical"; break;
        case VulnSeverity::High: severity = "high"; break;
        case VulnSeverity::Medium: severity = "medium"; break;
        case VulnSeverity::Low: severity = "low"; break;
        }

        json << "{" << "\"id\":\"" << escapeJson(v.id) << "\"," << "\"title\":\"" << escapeJson(v.title) << "\"," << "\"description\":\"" << escapeJson(v.description) << "\"," << "\"severity\":\"" << severity << "\"," << "\"category\":\"" << escapeJson(v.category) << "\"," << "\"how_to_fix\":\"" << escapeJson(v.how_to_fix) << "\"," << "\"more_info\":\"" << escapeJson(v.more_info) << "\"," << "\"auto_fixable\":" << (v.auto_fixable ? "true" : "false") << "}";

        if (i < report.vulnerabilities.size() - 1) json << ",";
    }
    json << "]}";
    return stringToCharPtr(json.str());
}
MP_API char* get_vuln_fix_descriptor(const char* vuln_id) {
    if (!vuln_id) return stringToCharPtr("{}");
    return stringToCharPtr(VulnerabilityScanner::getFixDescriptor(vuln_id));
}
MP_API char* scan_computer_start() {
    MP_GUARD_SCANNER(stringToCharPtr("{\"success\":false,\"message\":\"core_not_initialized\"}"));
    bool started = g_scanner->startComputerScan();
    ostringstream json;
    json << "{" << "\"success\":" << (started ? "true" : "false") << "," << "\"message\":\"" << (started ? "Scan started" : "Scan already running") << "\"" << "}";
    return stringToCharPtr(json.str());
}
MP_API char* scan_computer_get_progress() {
    MP_GUARD_SCANNER(stringToCharPtr("{\"is_running\":false,\"error\":\"core_not_initialized\"}"));
    ComputerScanProgress p = g_scanner->getComputerScanProgress();

    ostringstream json;
    json << "{"  << "\"is_running\":" << (p.is_running ? "true" : "false") << "," << "\"is_finished\":" << (p.is_finished ? "true" : "false") << "," << "\"files_total\":" << p.files_total << "," << "\"files_scanned\":" << p.files_scanned << "," << "\"threats_found\":" << p.threats_found << "," << "\"current_drive\":\"" << escapeJson(p.current_drive) << "\"," << "\"current_file\":\"" << escapeJson(p.current_file) << "\"," << "\"error\":\"" << escapeJson(p.error) << "\"," << "\"threats\":[";

    for (size_t i = 0; i < p.threats.size(); i++) {
        json << resultToJson(p.threats[i]);
        if (i < p.threats.size() - 1) json << ",";
    }
    json << "]}";
    return stringToCharPtr(json.str());
}
MP_API char* scan_computer_stop() {
    if (g_scanner) g_scanner->stopComputerScan();
    return stringToCharPtr("{\"success\":true}");
}
MP_API char* start_realtime_monitor() {
    MP_GUARD_SCANNER("{\"success\":false,\"error\":\"not_initialized\"}");
    if (!g_realtime_monitor) return stringToCharPtr("{\"success\":false,\"error\":\"not_initialized\"}");
    if (isServiceHosting()) return stringToCharPtr("{\"success\":true,\"hosted_by_service\":true}");
    bool success = g_realtime_monitor->start();
    if (success) g_tray_notifier.start();
    return stringToCharPtr(string("{\"success\":") + (success ? "true" : "false") + "}");
}
MP_API char* stop_realtime_monitor() {
    g_tray_notifier.stop();
    if (g_realtime_monitor) g_realtime_monitor->stop();
    return stringToCharPtr("{\"success\":true}");
}
MP_API char* is_realtime_monitoring() {
    bool realtime = false, web = false;
    if (serviceQueryStatus(realtime, web)) return stringToCharPtr(string("{\"active\":") + (realtime ? "true" : "false") + "}");
    bool active = (g_realtime_monitor && g_realtime_monitor->isRunning());
    return stringToCharPtr(string("{\"active\":") + (active ? "true" : "false") + "}");
}

MP_API char* get_realtime_events() {
    if (!g_realtime_monitor) return stringToCharPtr("{\"count\":0,\"total_detected\":0,\"threats_found\":0,\"events\":[]}");
    auto events = g_realtime_monitor->getAndClearEvents();

    ostringstream json;
    json << "{" << "\"count\":" << events.size() << "," << "\"total_detected\":" << g_realtime_monitor->totalDetected() << "," << "\"threats_found\":" << g_realtime_monitor->threatsFound() << "," << "\"events\":[";

    for (size_t i = 0; i < events.size(); i++) {
        const auto& e = events[i];
        json << "{" << "\"file_path\":\"" << escapeJson(e.file_path) << "\"," << "\"action\":\"" << escapeJson(e.action) << "\"," << "\"detected_at\":\"" << escapeJson(e.detected_at) << "\"," << "\"scanned\":" << (e.scanned ? "true" : "false") << "," << "\"is_threat\":" << (e.is_threat ? "true" : "false") << "," << "\"threat_name\":\"" << escapeJson(e.threat_name) << "\"," << "\"danger_level\":" << e.danger_level << "," << "\"score\":" << e.score << "," << "\"verdict\":\"" << escapeJson(e.verdict) << "\"," << "\"detection_method\":\"" << escapeJson(e.detection_method) << "\"" << "}";
        if (i < events.size() - 1) json << ",";
    }
    json << "]}";
    return stringToCharPtr(json.str());
}
MP_API char* start_memory_scan() {
    initializeCore();
    bool success = g_memory_scanner.startFullScan();
    return stringToCharPtr(string("{\"success\":") + (success ? "true" : "false") + "}");
}
MP_API char* stop_memory_scan() {
    g_memory_scanner.stopScan();
    return stringToCharPtr("{\"success\":true}");
}
MP_API char* get_memory_scan_progress() {
    MemoryScanProgress p = g_memory_scanner.getProgress();

    ostringstream json;
    json << "{" << "\"is_running\":" << (p.is_running ? "true" : "false") << "," << "\"is_finished\":" << (p.is_finished ? "true" : "false") << "," << "\"processes_total\":" << p.processes_total << "," << "\"processes_scanned\":" << p.processes_scanned << "," << "\"threats_found\":" << p.threats_found << "," << "\"current_process\":\"" << escapeJson(p.current_process) << "\"," << "\"threats\":[";

    for (size_t i = 0; i < p.threats.size(); i++) {
        const auto& t = p.threats[i];
        json << "{" << "\"pid\":" << t.pid << "," << "\"process_name\":\"" << escapeJson(t.process_name) << "\"," << "\"exe_path\":\"" << escapeJson(t.exe_path) << "\"," << "\"is_threat\":" << (t.is_threat ? "true" : "false") << "," << "\"threat_name\":\"" << escapeJson(t.threat_name) << "\"," << "\"matches_count\":" << t.matches_count << "," << "\"memory_scanned\":" << t.memory_scanned << "," << "\"regions_scanned\":" << t.regions_scanned << "," << "\"detected_at\":\"" << escapeJson(t.detected_at) << "\"," << "\"matched_signatures\":[";

        for (size_t j = 0; j < t.matched_signatures.size(); j++) {
            json << "\"" << escapeJson(t.matched_signatures[j]) << "\"";
            if (j < t.matched_signatures.size() - 1) json << ",";
        }
        json << "]}";
        if (i < p.threats.size() - 1) json << ",";
    }
    json << "]}";
    return stringToCharPtr(json.str());
}
MP_API char* scan_process_memory(int pid) {
    initializeCore();
    MemoryScanResult r = g_memory_scanner.scanProcess(static_cast<DWORD>(pid));

    ostringstream json;
    json << "{" << "\"pid\":" << r.pid << "," << "\"process_name\":\"" << escapeJson(r.process_name) << "\"," << "\"exe_path\":\"" << escapeJson(r.exe_path) << "\"," << "\"is_threat\":" << (r.is_threat ? "true" : "false") << "," << "\"threat_name\":\"" << escapeJson(r.threat_name) << "\"," << "\"matches_count\":" << r.matches_count << "," << "\"memory_scanned\":" << r.memory_scanned << "," << "\"regions_scanned\":" << r.regions_scanned << "," << "\"detected_at\":\"" << escapeJson(r.detected_at) << "\"," << "\"matched_signatures\":[";

    for (size_t j = 0; j < r.matched_signatures.size(); j++) {
        json << "\"" << escapeJson(r.matched_signatures[j]) << "\"";
        if (j < r.matched_signatures.size() - 1) json << ",";
    }
    json << "]}";

    return stringToCharPtr(json.str());
}

MP_API char* get_etw_status() {
    initializeCore();

    string mode = g_process_analyzer->getMonitoringMode();
    bool active = g_process_analyzer->isMonitoring();
    bool dllInjection = (mode == "etw");

    ostringstream json;
    json << "{" << "\"active\":" << (active ? "true" : "false") << "," << "\"mode\":\"" << escapeJson(mode) << "\"," << "\"dll_injection_supported\":" << (dllInjection ? "true" : "false") << "}";
    return stringToCharPtr(json.str());
}

MP_API char* get_dll_injection_alerts() {
    auto alerts = g_process_analyzer->getAndClearInjectionAlerts();

    ostringstream json;
    json << "{\"count\":" << alerts.size() << ",\"alerts\":[";

    for (size_t i = 0; i < alerts.size(); i++) {
        const auto& a = alerts[i];
        json << "{" << "\"pid\":" << a.pid << "," << "\"process_name\":\"" << escapeJson(a.process_name) << "\"," << "\"dll_path\":\"" << escapeJson(a.dll_path) << "\"," << "\"reason\":\"" << escapeJson(a.reason) << "\"," << "\"score\":" << a.suspicion_score << "," << "\"detected_at\":\"" << escapeJson(a.detected_at) << "\"" << "}";
        if (i < alerts.size() - 1) json << ",";
    }
    json << "]}";
    return stringToCharPtr(json.str());
}
MP_API char* smart_scan_get_stats() {
    MP_GUARD_SCANNER(stringToCharPtr("{\"hits\":0,\"misses\":0,\"entries\":0}"));
    SmartScanStats stats = g_scanner->getCacheStats();
    uint64_t total = stats.hits + stats.misses;
    double hit_rate = (total > 0) ? (100.0 * stats.hits / total) : 0.0;

    ostringstream json;
    json << "{" << "\"hits\":" << stats.hits << "," << "\"misses\":" << stats.misses << "," << "\"entries\":" << stats.entries << "," << "\"invalidations\":" << stats.invalidations << "," << "\"hit_rate\":" << fixed << setprecision(1) << hit_rate << "}";
    return stringToCharPtr(json.str());
}
MP_API char* smart_scan_invalidate() {
    MP_GUARD_SCANNER(stringToCharPtr("{\"status\":\"error\"}"));
    g_scanner->invalidateCache();
    return stringToCharPtr("{\"status\":\"ok\"}");
}
MP_API char* smart_scan_clear() {
    MP_GUARD_SCANNER(stringToCharPtr("{\"status\":\"error\"}"));
    g_scanner->clearCache();
    return stringToCharPtr("{\"status\":\"ok\"}");
}


static bool initYaraTrampoline() { return g_yara.initialize((getDllDir() + "data\\yara_rules").c_str()); }

static bool safeInitYara() {
    __try { return initYaraTrampoline(); }
    __except (EXCEPTION_EXECUTE_HANDLER) {
        OutputDebugStringA("[MP][YARA] SEH exception in initialize - YARA disabled\n");
        return false;
    }
}
static void ensureYaraInitialized() {
    if (!g_yara_init_done.load(memory_order_acquire)) {
        g_yara_init_done.store(true, memory_order_release);
        OutputDebugStringA("[MP][YARA] Lazy init starting...\n");
        bool ok = safeInitYara();
        OutputDebugStringA(ok ? "[MP][YARA] Init OK\n" : "[MP][YARA] Init FAIL\n");
    }
}
MP_API char* get_yara_status() {
    initializeCore();
    ensureYaraInitialized();
    ostringstream json;
    json << "{" << "\"available\":" << boolToJson(g_yara.isAvailable()) << "," << "\"rules_count\":" << g_yara.getRulesCount() << "," << "\"rules_dir\":\"" << escapeJson(getDllDir() + "data\\yara_rules") << "\"" << "}";
    return stringToCharPtr(json.str());
}
MP_API char* yara_reload_rules() {
    initializeCore();
    ensureYaraInitialized();
    bool ok = g_yara.reloadRules((getDllDir() + "data\\yara_rules").c_str());
    if (ok && g_scanner) g_scanner->invalidateCache();
    ostringstream json;
    json << "{" << "\"success\":" << boolToJson(ok) << "," << "\"rules_count\":" << g_yara.getRulesCount() << "}";
    return stringToCharPtr(json.str());
}

MP_API char* get_exclusions() {
    MP_GUARD_SCANNER(stringToCharPtr("{\"count\":0,\"exclusions\":[]}"));
    auto list = g_scanner->getExclusions();
    ostringstream json;
    json << "{\"count\":" << list.size() << ",\"exclusions\":[";
    for (size_t i = 0; i < list.size(); ++i) {
        if (i > 0) json << ",";
        json << "\"" << escapeJson(list[i]) << "\"";
    }
    json << "]}";
    return stringToCharPtr(json.str());
}
MP_API char* add_exclusion(const char* path) {
    if (!path) return stringToCharPtr("{\"success\":false}");
    MP_GUARD_SCANNER(stringToCharPtr("{\"success\":false}"));
    bool ok = g_scanner->addExclusion(path);
    return stringToCharPtr(string("{\"success\":") + boolToJson(ok) + "}");
}
MP_API char* remove_exclusion(const char* path) {
    if (!path) return stringToCharPtr("{\"success\":false}");
    MP_GUARD_SCANNER(stringToCharPtr("{\"success\":false}"));
    bool ok = g_scanner->removeExclusion(path);
    return stringToCharPtr(string("{\"success\":") + boolToJson(ok) + "}");
}
MP_API char* test_export() { return stringToCharPtr("ok"); }

#ifndef MP_HELPER_EXPECTED_SHA1
#define MP_HELPER_EXPECTED_SHA1 ""
#endif

MP_API int mp_verify_helper_exe(const char* path) {
    if (!path || path[0] == '\0') return 0;

    wstring wpath = unicode_utils::utf8_to_wide(string(path));

    WINTRUST_FILE_INFO fileInfo{};
    fileInfo.cbStruct = sizeof(WINTRUST_FILE_INFO);
    fileInfo.pcwszFilePath = wpath.c_str();

    GUID action_id = WINTRUST_ACTION_GENERIC_VERIFY_V2;

    WINTRUST_DATA td{};
    td.cbStruct = sizeof(WINTRUST_DATA);
    td.dwUIChoice = WTD_UI_NONE;
    td.fdwRevocationChecks = WTD_REVOKE_WHOLECHAIN;
    td.dwUnionChoice = WTD_CHOICE_FILE;
    td.pFile = &fileInfo;
    td.dwStateAction = WTD_STATEACTION_VERIFY;
    td.dwProvFlags = WTD_SAFER_FLAG | WTD_CACHE_ONLY_URL_RETRIEVAL;

    LONG status = WinVerifyTrust((HWND)INVALID_HANDLE_VALUE, &action_id, &td);

    int thumbprintOk = 1;
    constexpr string_view kExpectedThumb = MP_HELPER_EXPECTED_SHA1;
    if (!kExpectedThumb.empty() && (status == ERROR_SUCCESS || status == static_cast<LONG>(TRUST_E_REVOCATION_STATUS_UNKNOWN))) {
        thumbprintOk = 0;
        CRYPT_PROVIDER_DATA* prov = WTHelperProvDataFromStateData(td.hWVTStateData);
        if (prov) {
            CRYPT_PROVIDER_SGNR* sgnr = WTHelperGetProvSignerFromChain(prov, 0, FALSE, 0);
            if (sgnr) {
                CRYPT_PROVIDER_CERT* cert = WTHelperGetProvCertFromChain(sgnr, 0);
                if (cert && cert->pCert) {
                    BYTE sha1[20] = {};
                    DWORD cbSha1 = sizeof(sha1);
                    if (CertGetCertificateContextProperty(cert->pCert, CERT_SHA1_HASH_PROP_ID, sha1, &cbSha1) && cbSha1 == 20) {
                        char hex[41] = {};
                        for (int i = 0; i < 20; i++) sprintf_s(hex + i * 2, 3, "%02x", sha1[i]);
                        thumbprintOk = (kExpectedThumb == string_view(hex)) ? 1 : 0;
                    }
                }
            }
        }
    } 
    td.dwStateAction = WTD_STATEACTION_CLOSE;
    WinVerifyTrust((HWND)INVALID_HANDLE_VALUE, &action_id, &td);

    if (!thumbprintOk) return 0;
    return (status == ERROR_SUCCESS || status == static_cast<LONG>(TRUST_E_REVOCATION_STATUS_UNKNOWN)) ? 1 : 0;
}
MP_API char* archive_scan_supported() {
    int mask = g_archive_scanner.getSupportedFormatsMask();
    ostringstream j;
    j << "{\"supported\":" << mask << ",\"formats\":[";
    bool first = true;
    auto addFmt = [&](const char* name) {
        if (!first) j << ",";
        j << "\"" << name << "\"";
        first = false;
    };
    if (mask & 1) addFmt("zip");
    if (mask & 2) addFmt("7z");
    if (mask & 2) addFmt("rar");
    if (mask & 4) addFmt("iso");
    j << "]}";
    return stringToCharPtr(j.str());
}

MP_API char* sandbox_is_supported() {
    bool ok = SandboxManager::instance().isSupported();
    string reason = ok ? "" : "requires_admin";
    ostringstream j;
    j << "{\"supported\":" << (ok ? "true" : "false") << ",\"reason\":\"" << reason << "\"}";
    return stringToCharPtr(j.str());
}
MP_API char* sandbox_run(const char* file_path) {
    if (!file_path || file_path[0] == '\0') return stringToCharPtr("{\"success\":false,\"error\":\"empty_path\"}");

    wstring wpath = unicode_utils::utf8_to_wide(string(file_path));
    SandboxRunResult res = SandboxManager::instance().run(wpath, 60);
    ostringstream j;
    j << "{\"success\":" << (res.success ? "true" : "false") << ",\"error\":\"" << escapeJson(res.error_code) << "\"}";
    return stringToCharPtr(j.str());
}
MP_API char* sandbox_get_status() {
    auto& mgr = SandboxManager::instance();
    auto state = mgr.getState();
    int  elapsed = mgr.getElapsedSeconds();

    const char* stateStr = "idle";
    switch (state) {
        case SandboxState::Running: stateStr = "running"; break;
        case SandboxState::Completed: stateStr = "completed"; break;
        case SandboxState::Cancelled: stateStr = "cancelled"; break;
        case SandboxState::Error: stateStr = "error"; break;
        default: break;
    }

    ostringstream j;
    j << "{\"state\":\"" << stateStr << "\"," << "\"elapsed\":"  << elapsed  << "}";
    return stringToCharPtr(j.str());
}
MP_API char* sandbox_get_report() {
    return stringToCharPtr(SandboxManager::instance().getReportJson());
}
MP_API char* sandbox_cancel() {
    SandboxManager::instance().cancel();
    return stringToCharPtr("{\"success\":true}");
}
static string nudgeCategoryName(NudgeCategory c) {
    switch (c) {
    case NudgeCategory::DownloadedExe: return "downloaded_exe";
    case NudgeCategory::MacroDocument: return "macro_document";
    case NudgeCategory::SuspiciousScript: return "suspicious_script";
    case NudgeCategory::UsbDevice: return "usb_device";
    case NudgeCategory::DownloadedContainer: return "downloaded_container";
    default: return "unknown";
    }
}

MP_API char* nudge_get_pending() {
    auto nudges = g_nudge_engine.getAndClear();
    ostringstream j;
    j << "[";
    for (size_t i = 0; i < nudges.size(); ++i) {
        const auto& n = nudges[i];
        j << "{" << "\"category\":\"" << nudgeCategoryName(n.category) << "\"," << "\"detail\":\""   << escapeJson(n.detail)   << "\"," << "\"context\":\""  << escapeJson(n.context)  << "\"," << "\"severity\":\"" << escapeJson(n.severity) << "\"," << "\"detected_at\":\"" << escapeJson(n.detected_at) << "\"" << "}";
        if (i + 1 < nudges.size()) j << ",";
    }
    j << "]";
    return stringToCharPtr(j.str());
}

MP_API char* nudge_usb_supported() {
    return stringToCharPtr("{\"supported\":true}");
}
MP_API void tray_show_balloon(const char* title, const char* text) {
    if (!title || !text) return;
    g_tray_notifier.showBalloon(title, text);
}
MP_API char* tray_consume_click() {
    bool clicked = g_tray_notifier.consumeClick();
    return stringToCharPtr(clicked ? "{\"clicked\":true}" : "{\"clicked\":false}");
}