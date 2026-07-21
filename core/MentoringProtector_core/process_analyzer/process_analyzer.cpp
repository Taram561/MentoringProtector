#include "pch.h"
#ifndef PROCESSENTRY32
#error "tlhelp32.h not included!"
#endif
#include "../unicode_utils.h"

#include <windows.h>
#include <tlhelp32.h>
#include <psapi.h>
#pragma comment(lib, "psapi.lib")
#include <wintrust.h>
#include <softpub.h>
#pragma comment(lib, "wintrust.lib")
#include <winternl.h>
#pragma comment(lib, "ntdll.lib")
#include <objbase.h>
#pragma comment(lib, "ole32.lib")

#include "process_analyzer.h"
#include "../unicode_utils.h"
#include "../logger/logger.h"

using namespace std;
using namespace unicode_utils;

static string getEnv(const char* name) {
    wchar_t buf[MAX_PATH]{};
    DWORD len = GetEnvironmentVariableW(unicode_utils::utf8_to_wide(name).c_str(), buf, MAX_PATH);
    if (len == 0 || len >= MAX_PATH) return {};
    return unicode_utils::wide_to_utf8(wstring(buf, len));
}
static void addPath(vector<string>& v, const string& base, const string& suffix = "\\") { if (!base.empty()) v.push_back(base + suffix); }

ProcessAnalyzer::ProcessAnalyzer(Scanner* scanner, HeuristicAnalyzer* heuristic, const ProcessAnalyzerConfig& config): config_(config), scanner_(scanner), heuristic_(heuristic) {
    if (config_.excluded_paths.empty()) {
        string winDir = getEnv("SystemRoot");
        string progFiles = getEnv("ProgramFiles");
        string progX86 = getEnv("ProgramFiles(x86)");
        string progData = getEnv("ProgramData");

        addPath(config_.excluded_paths, winDir, "\\System32\\");
        addPath(config_.excluded_paths, winDir, "\\SysWOW64\\");
        addPath(config_.excluded_paths, progFiles);
        addPath(config_.excluded_paths, progX86);
        addPath(config_.excluded_paths, progFiles, "\\Microsoft VS Code\\");
        addPath(config_.excluded_paths, progFiles, "\\Google\\");
        addPath(config_.excluded_paths, progFiles, "\\Mozilla Firefox\\");
        addPath(config_.excluded_paths, progX86, "\\Microsoft\\");
        addPath(config_.excluded_paths, progFiles, "\\dotnet\\");
        addPath(config_.excluded_paths, progFiles, "\\Git\\");
        addPath(config_.excluded_paths, progFiles, "\\nodejs\\");
        addPath(config_.excluded_paths, progFiles, "\\Python");
        addPath(config_.excluded_paths, progFiles, "\\Java\\");
        addPath(config_.excluded_paths, progFiles, "\\JetBrains\\");
        addPath(config_.excluded_paths, progData, "\\Microsoft\\");
    }
}
ProcessAnalyzer::~ProcessAnalyzer() { stopMonitoring(); }

bool ProcessAnalyzer::loadResources(const string& signatures_path, const string& rules_path, const string& threat_db_path) {
    if (!scanner_ || !heuristic_) {
        LS_LOG_WARN("ProcessAnalyzer", "loadResources: зависимости не инжектированы (scanner/heuristic)");
        return false;
    }
    bool sigs = scanner_->loadSignatures(signatures_path), rules = heuristic_->loadRules(rules_path);
    scanner_->loadThreatDatabase(threat_db_path);

    LS_LOG_INFO("ProcessAnalyzer", "Ресурсы загружены: сигнатуры=" + to_string(sigs) + " правила=" + to_string(rules));

    return sigs && rules;
}
bool ProcessAnalyzer::startMonitoring() {
    if (monitoring_.load()) return false;
    for (int i = 0; i < 20 && thread_running_.load(); i++) this_thread::sleep_for(chrono::milliseconds(10));
    etw_monitor_ = make_unique<EtwMonitor>();
    etw_monitor_->setProcessCallback([this](const EtwProcessEvent& evt) { onEtwProcessStart(evt); });
    if (etw_monitor_->start()) {
        use_etw_ = true;
        monitoring_.store(true);
        LS_LOG_INFO("ProcessAnalyzer", "ETW mode active - real-time process monitoring");
        return true;
    }
    string reason = etw_monitor_->getStatus();
    etw_monitor_.reset();
    use_etw_ = false;
    monitoring_.store(true);
    monitor_thread_ = thread(&ProcessAnalyzer::monitorLoop, this);

    LS_LOG_WARN("ProcessAnalyzer", "ETW unavailable (" + reason + "), fallback to polling. " "Interval: " + to_string(config_.poll_interval_ms) + " ms");
    return true;
}
void ProcessAnalyzer::stopMonitoring() {
    if (!monitoring_.load()) return;
    { lock_guard<mutex> lk(cv_stop_mutex_); monitoring_.store(false); }
    cv_stop_.notify_all();
    if (use_etw_ && etw_monitor_) {
        etw_monitor_->stop();
        etw_monitor_.reset();
        use_etw_ = false;
    } else if (monitor_thread_.joinable()) {
        constexpr int kPollMs = 5;
        constexpr int kMaxWaitMs = 500;
        for (int w = 0; w < kMaxWaitMs && thread_running_.load(); w += kPollMs)
            this_thread::sleep_for(chrono::milliseconds(kPollMs));
        if (!thread_running_.load()) monitor_thread_.join();
        else {
            monitor_thread_.detach();
            LS_LOG_WARN("ProcessAnalyzer", "Monitor thread detached on stop (WinVerifyTrust/COM stall)");
        }
    }
    LS_LOG_INFO("ProcessAnalyzer", "Мониторинг остановлен");
}
void ProcessAnalyzer::monitorLoop() {
    const bool com_inited = SUCCEEDED(CoInitializeEx(nullptr, COINIT_MULTITHREADED));
    thread_running_.store(true);
    while (monitoring_.load()) {
        auto processes = getRunningProcesses();

        for (const auto& [pid, name] : processes) {
            if (!monitoring_.load()) break;
            {
                lock_guard<mutex> lock(pids_mutex_);
                if (checked_pids_.count(pid)) continue;
                checked_pids_.insert(pid);
            }
            if (isTrustedProcess(name)) continue;
            string exePath = getProcessExePath(pid);
            if (exePath.empty()) continue;
            if (isExcluded(exePath)) continue;
            ProcessAlert alert = analyzeProcess(pid);
            LS_LOG_INFO("ProcessAnalyzer", "Процесс " + name + " (PID:" + to_string(pid) + "): " + alert.verdict + " score=" + to_string(alert.suspicion_score));
            if (alert.suspicion_score >= config_.warn_threshold || !alert.threat_name.empty()) { addAlert(alert); }
            if (config_.block_threshold > 0 && alert.suspicion_score >= config_.block_threshold && !alert.is_blocked) {
                if (terminateProcess(pid)) {
                    alert.is_blocked = true;
                    LS_LOG_WARN("ProcessAnalyzer", "Заблокирован процесс: " + name + " score=" + to_string(alert.suspicion_score));
                }
            }
        }
        static int iteration = 0;
        if (++iteration % 100 == 0) {
            lock_guard<mutex> lock(pids_mutex_);
            checked_pids_.clear();
        }
        {
            unique_lock<mutex> lk(cv_stop_mutex_);
            cv_stop_.wait_for(lk, chrono::milliseconds(config_.poll_interval_ms), [this] { return !monitoring_.load(); });
        }
    }
    thread_running_.store(false);
    if (com_inited) CoUninitialize();
}
ProcessAlert ProcessAnalyzer::analyzeProcess(DWORD pid) {
    ProcessAlert alert;
    alert.pid = pid;
    alert.detected_at = getCurrentTime();
    alert.is_blocked = false;
    alert.exe_path = getProcessExePath(pid);
    if (alert.exe_path.empty()) {
        alert.verdict = "unknown";
        alert.suspicion_score = 0;
        return alert;
    }
    size_t slash = alert.exe_path.find_last_of("\\/");
    alert.process_name = (slash != string::npos) ? alert.exe_path.substr(slash + 1) : alert.exe_path;
    if (!scanner_) {
        alert.verdict = "no_scanner";
        return alert;
    }
    ScanResult scanResult = scanner_->scanFile(alert.exe_path);
    alert.file_hash = scanResult.file_hash;
    if (scanResult.is_infected) {
        alert.suspicion_score = 100;
        alert.verdict = "malicious";
        alert.threat_name = scanResult.threat_name;
        alert.danger_level = scanResult.danger_level;
        alert.detection_method = "signature";
        return alert;
    }
    if (!config_.unknown_only) { }
    else if (scanResult.file_hash.empty()) {
        alert.verdict = "unreadable";
        return alert;
    }

    if (!heuristic_) {
        alert.verdict = "no_heuristic";
        return alert;
    }
    HeuristicResult hr = heuristic_->analyze(alert.exe_path);

    int score = hr.suspicion_score;
    if (hr.has_signature && score > 0) score = static_cast<int>(score * 0.6);

    if (score <= 20) {
        alert.verdict = "clean";
        alert.danger_level = 0;
    } else if (score <= 50) {
        alert.verdict = "suspicious";
        alert.danger_level = 4;
    } else if (score <= 80) {
        alert.verdict = "likely_malicious";
        alert.danger_level = 7;
    } else {
        alert.verdict = "malicious";
        alert.danger_level = 9;
    }
    alert.suspicion_score = score;
    alert.triggered_rules = hr.triggered_rules;
    alert.detection_method = "heuristic";
    return alert;
}

vector<pair<DWORD, string>>
ProcessAnalyzer::getRunningProcesses() {
    vector<pair<DWORD, string>> result;
    HANDLE snapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if (snapshot == INVALID_HANDLE_VALUE) return result;
    PROCESSENTRY32W entry;
    entry.dwSize = sizeof(entry);
    if (Process32FirstW(snapshot, &entry)) {
        do {
            if (entry.th32ProcessID > 4) {
                int size = WideCharToMultiByte(CP_UTF8, 0, entry.szExeFile, -1, nullptr, 0, nullptr, nullptr);
                string name(size - 1, '\0');
                WideCharToMultiByte(CP_UTF8, 0, entry.szExeFile, -1, &name[0], size, nullptr, nullptr);
                result.emplace_back(entry.th32ProcessID, name);
            }
        } while (Process32NextW(snapshot, &entry));
    }
    CloseHandle(snapshot);
    return result;
}
string ProcessAnalyzer::getProcessExePath(DWORD pid) {
    HANDLE hProcess = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, FALSE, pid);
    if (!hProcess) return "";
    wchar_t path[MAX_PATH] = {};
    DWORD size = MAX_PATH;
    BOOL success = QueryFullProcessImageNameW(hProcess, 0, path, &size);
    CloseHandle(hProcess);
    return success ? unicode_utils::wide_to_utf8(wstring(path, size)) : "";
}
bool ProcessAnalyzer::isExcluded(const string& path) const {
    string pathLower = path;
    transform(pathLower.begin(), pathLower.end(), pathLower.begin(), ::tolower);
    for (const auto& excluded : config_.excluded_paths) {
        string excLower = excluded;
        transform(excLower.begin(), excLower.end(), excLower.begin(), ::tolower);
        if (pathLower.find(excLower) == 0) return true;
    }
    if (pathLower.find("\\appdata\\local\\programs\\") != string::npos) return true;
    if (pathLower.find("\\appdata\\local\\microsoft\\") != string::npos) return true;
    if (pathLower.find("\\appdata\\local\\google\\") != string::npos) return true;
    if (pathLower.find("\\microsoft vs code\\") != string::npos) return true;
    return false;
}
bool ProcessAnalyzer::terminateProcess(DWORD pid) {
    HANDLE hProcess = OpenProcess(PROCESS_TERMINATE, FALSE, pid);
    if (!hProcess) {
        LS_LOG_ERROR("ProcessAnalyzer", "Нет прав для завершения PID: " + to_string(pid));
        return false;
    }
    BOOL success = TerminateProcess(hProcess, 1);
    CloseHandle(hProcess);
    if (!success) { LS_LOG_ERROR("ProcessAnalyzer", "Не удалось завершить PID: " + to_string(pid)); }
    return success == TRUE;
}
vector<ProcessAlert>
ProcessAnalyzer::getAndClearAlerts() {
    lock_guard<mutex> lock(alerts_mutex_);
    vector<ProcessAlert> result = move(alerts_);
    alerts_.clear();
    return result;
}
void ProcessAnalyzer::addAlert(ProcessAlert alert) {
    lock_guard<mutex> lock(alerts_mutex_);
    alerts_.push_back(move(alert));
}
bool ProcessAnalyzer::isTrustedProcess(const string& processName) const {
    string nameLower = processName;
    transform(nameLower.begin(), nameLower.end(), nameLower.begin(), ::tolower);
    for (const auto& trusted : config_.trusted_processes) if (nameLower == trusted) return true;
    return false;
}
string ProcessAnalyzer::getCurrentTime() const {
    SYSTEMTIME st;
    GetLocalTime(&st);
    char buf[32];
    sprintf_s(buf, "%04d-%02d-%02d %02d:%02d:%02d", st.wYear, st.wMonth, st.wDay, st.wHour, st.wMinute, st.wSecond);
    return buf;
}
void ProcessAnalyzer::onEtwProcessStart(const EtwProcessEvent& event) {
    if (!event.is_start) return;
    if (!monitoring_.load()) return;
    {
        lock_guard<mutex> lock(pids_mutex_);
        if (checked_pids_.count(event.pid)) return;
        checked_pids_.insert(event.pid);
    }
    string name;
    if (!event.image_path.empty()) {
        size_t slash = event.image_path.find_last_of("\\/");
        name = (slash != string::npos) ? event.image_path.substr(slash + 1) : event.image_path;
    }
    else name = "";
    if (!name.empty() && isTrustedProcess(name)) return;
    if (!event.image_path.empty() && isExcluded(event.image_path)) return;

    ProcessAlert alert = analyzeProcess(event.pid);
    LS_LOG_INFO("ProcessAnalyzer", "[ETW] Процесс " + alert.process_name + " (PID:" + to_string(event.pid) + " PPID:" + to_string(event.parent_pid) + "): " + alert.verdict + " score=" + to_string(alert.suspicion_score));
    if (alert.suspicion_score >= config_.warn_threshold || !alert.threat_name.empty()) { addAlert(alert); }
    if (config_.block_threshold > 0 && alert.suspicion_score >= config_.block_threshold && !alert.is_blocked) {
        if (terminateProcess(event.pid)) {
            alert.is_blocked = true;
            LS_LOG_WARN("ProcessAnalyzer", "[ETW] Заблокирован процесс: " + alert.process_name + " score=" + to_string(alert.suspicion_score));
        }
    }
    {
        lock_guard<mutex> lock(pids_mutex_);
        if (checked_pids_.size() > 500) checked_pids_.clear();
    }
}
string ProcessAnalyzer::getMonitoringMode() const {
    if (use_etw_) return "etw";
    if (monitoring_.load()) return "polling";
    return "off";
}
vector<DllInjectionAlert>
ProcessAnalyzer::getAndClearInjectionAlerts() {
    if (etw_monitor_) return etw_monitor_->getAndClearInjectionAlerts();
    return {};
}

DWORD ProcessAnalyzer::getProcessParentPid(DWORD pid) const {
    HANDLE snap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if (snap == INVALID_HANDLE_VALUE) return 0;
    PROCESSENTRY32W pe{};
    pe.dwSize = sizeof(pe);
    DWORD parent = 0;
    if (Process32FirstW(snap, &pe)) {
        do {
            if (pe.th32ProcessID == pid) {
                parent = pe.th32ParentProcessID;
                break;
            }
        } while (Process32NextW(snap, &pe));
    }
    CloseHandle(snap);
    return parent;
}

std::string ProcessAnalyzer::getProcessCmdline(DWORD pid) const {
    HANDLE hProc = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, pid);
    if (!hProc) return "";

    PROCESS_BASIC_INFORMATION pbi{};
    ULONG retLen = 0;
    using NtQIP_t = NTSTATUS(NTAPI*)(HANDLE, PROCESSINFOCLASS, PVOID, ULONG, PULONG);
    auto NtQIP = reinterpret_cast<NtQIP_t>(GetProcAddress(GetModuleHandleW(L"ntdll.dll"), "NtQueryInformationProcess"));

    std::string result;
    if (NtQIP && NT_SUCCESS(NtQIP(hProc, ProcessBasicInformation, &pbi, sizeof(pbi), &retLen))) {
        PEB peb{};
        SIZE_T rd = 0;
        if (ReadProcessMemory(hProc, pbi.PebBaseAddress, &peb, sizeof(peb), &rd)) {
            RTL_USER_PROCESS_PARAMETERS params{};
            if (ReadProcessMemory(hProc, peb.ProcessParameters, &params, sizeof(params), &rd)) {
                const auto len = params.CommandLine.Length;
                if (len > 0 && len < 32768) {
                    std::wstring buf(len / sizeof(wchar_t), L'\0');
                    if (ReadProcessMemory(hProc, params.CommandLine.Buffer, buf.data(), len, &rd)) {
                        result = wide_to_utf8(buf);
                    }
                }
            }
        }
    }
    CloseHandle(hProc);
    return result;
}

std::vector<ProcessAnalyzer::ModuleInfo>
ProcessAnalyzer::getProcessModules(DWORD pid) const {
    std::vector<ModuleInfo> modules;
    HANDLE snap = CreateToolhelp32Snapshot(TH32CS_SNAPMODULE | TH32CS_SNAPMODULE32, pid);
    if (snap == INVALID_HANDLE_VALUE) return modules;

    MODULEENTRY32W me{};
    me.dwSize = sizeof(me);
    if (Module32FirstW(snap, &me)) {
        do {
            ModuleInfo info;
            info.name = wide_to_utf8(me.szModule);
            info.base = reinterpret_cast<uintptr_t>(me.modBaseAddr);
            info.size = me.modBaseSize;
            modules.push_back(std::move(info));
            if (modules.size() >= 64) break;
        } while (Module32NextW(snap, &me));
    }
    CloseHandle(snap);
    return modules;
}
std::string ProcessAnalyzer::verifyProcessSignature(const std::string& exe_path) {
    std::wstring wpath = utf8_to_wide(exe_path);
    WINTRUST_FILE_INFO fileInfo{};
    fileInfo.cbStruct = sizeof(fileInfo);
    fileInfo.pcwszFilePath = wpath.c_str();

    GUID policyGuid = WINTRUST_ACTION_GENERIC_VERIFY_V2;
    WINTRUST_DATA wd{};
    wd.cbStruct = sizeof(wd);
    wd.dwUIChoice = WTD_UI_NONE;
    wd.fdwRevocationChecks = WTD_REVOKE_NONE;
    wd.dwUnionChoice = WTD_CHOICE_FILE;
    wd.pFile = &fileInfo;
    wd.dwStateAction = WTD_STATEACTION_VERIFY;

    LONG status = WinVerifyTrust(nullptr, &policyGuid, &wd);

    wd.dwStateAction = WTD_STATEACTION_CLOSE;
    WinVerifyTrust(nullptr, &policyGuid, &wd);

    return (status == ERROR_SUCCESS) ? "signed" : "unsigned";
}