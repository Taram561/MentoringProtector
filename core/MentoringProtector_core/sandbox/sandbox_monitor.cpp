#include "pch.h"
#include "sandbox_monitor.h"
#include <psapi.h>

SandboxMonitor::SandboxMonitor(DWORD pid) : target_pid_(pid) {}
SandboxMonitor::~SandboxMonitor() { stop(); }

void SandboxMonitor::start() {
    if (running_.exchange(true)) return;
    known_children_.clear();
    known_modules_.clear();
    known_children_.insert(target_pid_);
    poll_thread_ = std::thread(&SandboxMonitor::pollLoop, this);
}

void SandboxMonitor::stop() {
    running_.store(false);
    if (poll_thread_.joinable()) poll_thread_.join();
}

std::vector<BehavioralEvent> SandboxMonitor::getEvents() const {
    std::lock_guard<std::mutex> lk(events_mutex_);
    return events_;
}

void SandboxMonitor::pollLoop() {
    while (running_.load()) {
        checkChildProcesses();
        checkModules();
        checkMemory();
        std::this_thread::sleep_for(std::chrono::seconds(1));
    }
}

void SandboxMonitor::checkChildProcesses() {
    HANDLE hSnap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if (hSnap == INVALID_HANDLE_VALUE) return;

    std::set<DWORD> sandboxPids = known_children_;
    bool added = true;
    while (added) {
        added = false;
        PROCESSENTRY32W pe{};
        pe.dwSize = sizeof(pe);
        if (!Process32FirstW(hSnap, &pe)) break;
        do {
            if (sandboxPids.count(pe.th32ParentProcessID) && !sandboxPids.count(pe.th32ProcessID)) {
                sandboxPids.insert(pe.th32ProcessID);
                added = true;
            }
        } while (Process32NextW(hSnap, &pe));
        if (added) {
            CloseHandle(hSnap);
            hSnap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
            if (hSnap == INVALID_HANDLE_VALUE) break;
        }
    }

    for (DWORD pid : sandboxPids) {
        if (!known_children_.count(pid)) {
            known_children_.insert(pid);
            HANDLE hProc = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, FALSE, pid);
            std::string name;
            if (hProc) {
                wchar_t path[MAX_PATH] = {};
                DWORD sz = MAX_PATH;
                if (QueryFullProcessImageNameW(hProc, 0, path, &sz)) name = wstrToUtf8(path);
                CloseHandle(hProc);
            }
            if (name.empty()) name = "pid:" + std::to_string(pid);
            addEvent("process_create", name, "child process spawned");
        }
    }
    if (hSnap != INVALID_HANDLE_VALUE) CloseHandle(hSnap);
}

void SandboxMonitor::checkModules() {
    HANDLE hProc = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, target_pid_);
    if (!hProc) return;

    HMODULE mods[512] = {};
    DWORD needed = 0;
    if (EnumProcessModulesEx(hProc, mods, sizeof(mods), &needed, LIST_MODULES_ALL)) {
        DWORD count = std::min<DWORD>(needed / (DWORD)sizeof(HMODULE), 512);
        for (DWORD i = 0; i < count; i++) {
            wchar_t path[MAX_PATH] = {};
            if (!GetModuleFileNameExW(hProc, mods[i], path, MAX_PATH)) continue;
            std::string utf8 = wstrToUtf8(path);
            std::string lower = utf8;
            std::transform(lower.begin(), lower.end(), lower.begin(), ::tolower);
            if (known_modules_.count(lower)) continue;
            known_modules_.insert(lower);
            if (!isSystemPath(lower)) addEvent("module_load", utf8, "non-system module loaded");
        }
    }
    CloseHandle(hProc);
}

void SandboxMonitor::checkMemory() {
    HANDLE hProc = OpenProcess(PROCESS_QUERY_INFORMATION, FALSE, target_pid_);
    if (!hProc) return;

    PROCESS_MEMORY_COUNTERS_EX pmc{};
    pmc.cb = sizeof(pmc);
    if (GetProcessMemoryInfo(hProc, (PROCESS_MEMORY_COUNTERS*)&pmc, sizeof(pmc))) {
        constexpr SIZE_T kThresholdMB = 200;
        SIZE_T wsMB = pmc.WorkingSetSize / (1024 * 1024);
        if (wsMB > kThresholdMB) {
            std::string key = "mem_spike";
            if (!known_modules_.count(key)) {
                known_modules_.insert(key);
                addEvent("memory_spike", std::to_string(wsMB) + " MB", "working set exceeded 200 MB");
            }
        }
    }
    CloseHandle(hProc);
}

int SandboxMonitor::computeRiskScore() const {
    std::lock_guard<std::mutex> lk(events_mutex_);
    int score = 0;
    int procCreates = 0;
    int moduleLoads = 0;
    bool memSpike = false;

    for (const auto& e : events_) {
        if (e.type == "process_create") procCreates++;
        else if (e.type == "module_load") moduleLoads++;
        else if (e.type == "memory_spike") memSpike = true;
    }

    score += std::min(procCreates * 20, 60);
    score += std::min(moduleLoads * 5,  45);
    if (memSpike) score += 25;
    return std::min(score, 100);
}

void SandboxMonitor::addEvent(const std::string& type, const std::string& target, const std::string& detail) {
    std::lock_guard<std::mutex> lk(events_mutex_);
    events_.push_back({type, target, detail, timestamp()});
}

std::string SandboxMonitor::timestamp() const {
    SYSTEMTIME st{};
    GetLocalTime(&st);
    char buf[32];
    snprintf(buf, sizeof(buf), "%04d-%02d-%02dT%02d:%02d:%02d", st.wYear, st.wMonth, st.wDay, st.wHour, st.wMinute, st.wSecond);
    return buf;
}

std::string SandboxMonitor::wstrToUtf8(const std::wstring& ws) const {
    if (ws.empty()) return {};
    int sz = WideCharToMultiByte(CP_UTF8, 0, ws.c_str(), -1, nullptr, 0, nullptr, nullptr);
    if (sz <= 1) return {};
    std::string s(sz - 1, '\0');
    WideCharToMultiByte(CP_UTF8, 0, ws.c_str(), -1, s.data(), sz, nullptr, nullptr);
    return s;
}

bool SandboxMonitor::isSystemPath(const std::string& lower) const { return lower.find("\\windows\\") != std::string::npos  || lower.find("\\system32\\") != std::string::npos || lower.find("\\syswow64\\") != std::string::npos || lower.find("\\winsxs\\") != std::string::npos; }