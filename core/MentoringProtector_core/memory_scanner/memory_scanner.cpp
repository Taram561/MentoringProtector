#include "pch.h"
#include "memory_scanner.h"
#include "../unicode_utils.h"
#include "../logger/logger.h"
#include "../stats/stats_recorder.h"

#include <tlhelp32.h>
#include <future>
#include <set>
#include <chrono>
#include <algorithm>

using namespace std;

void MemoryScanner::buildMatcher() {
    matcher_ = SearchMatcher{};
    for (size_t i = 0; i < signatures_.size(); i++) matcher_.addPattern(signatures_[i].pattern.data(), signatures_[i].pattern.size(), i);
    matcher_.build();
    LS_LOG_INFO("MemoryScanner", "AC automaton built: " + to_string(matcher_.nodeCount()) + " nodes for " + to_string(signatures_.size()) + " patterns");
}

MemoryScanner::MemoryScanner() { loadBuiltinSignatures(); buildMatcher(); }

MemoryScanner::~MemoryScanner() { stopScan(); }

void MemoryScanner::loadBuiltinSignatures() {
    auto addStringSig = [this](const string& name, const string& pattern, int danger) {
        MemorySignature sig;
        sig.name = name;
        sig.pattern.assign(pattern.begin(), pattern.end());
        sig.danger_level = danger;
        signatures_.push_back(move(sig));
    };

    addStringSig("HackTool.Mimikatz", "sekurlsa::logonpasswords", 9);
    addStringSig("HackTool.Mimikatz", "mimikatz # ", 9);
    addStringSig("HackTool.Mimikatz", "gentilkiwi", 8);
    addStringSig("HackTool.Meterpreter", "metsrv.dll", 9);
    addStringSig("HackTool.Meterpreter", "stdapi_", 8);
    addStringSig("HackTool.Meterpreter", "ext_server_", 8);
    addStringSig("HackTool.CobaltStrike", "%s as %s\\%s: %d", 9);
    addStringSig("HackTool.CobaltStrike", "beacon.dll", 9);
    addStringSig("HackTool.CobaltStrike", "ReflectiveLoader", 8);
    addStringSig("HackTool.PSEmpire", "Invoke-Empire", 8);
    addStringSig("HackTool.PSEmpire", "Get-Keystrokes", 7);
    addStringSig("Backdoor.ReverseShell", "/bin/sh -i", 7);
    addStringSig("Backdoor.ReverseShell", "powershell -nop -w hidden -enc", 8);
    addStringSig("Backdoor.ReverseShell", "powershell -ep bypass -nop -w hidden", 8);
    addStringSig("Ransom.Generic", "YOUR FILES HAVE BEEN ENCRYPTED", 9);
    addStringSig("Ransom.Generic", "All your files have been encrypted", 9);
    addStringSig("Ransom.Generic", "send bitcoin to", 8);
    addStringSig("Ransom.WannaCry", "WNcry@2ol7", 10);
    addStringSig("Ransom.WannaCry", "WanaCrypt0r", 10);
    addStringSig("Spyware.Keylogger", "keylogger_output.txt", 7);
    addStringSig("Spyware.Keylogger", "captured_keys.log", 7);
    addStringSig("RAT.Generic", "DarkComet", 8);
    addStringSig("RAT.Generic", "njRAT", 8);
    addStringSig("RAT.Generic", "AsyncRAT", 8);
    addStringSig("RAT.Generic", "QuasarRAT", 8);
    addStringSig("Stealer.Generic", "password_dump.txt", 7);
    addStringSig("Stealer.Generic", "credentials_export", 7);

    LS_LOG_INFO("MemoryScanner", "Loaded " + to_string(signatures_.size()) + " builtin memory signatures");
}

int MemoryScanner::loadSignatures(const string& path) {
    ifstream file(unicode_utils::utf8_to_wide(path));
    if (!file.is_open()) return 0;

    int count = 0;
    string line;
    while (getline(file, line)) {
        if (line.empty() || line[0] == '#') continue;

        size_t p1 = line.find('|');
        size_t p2 = line.rfind('|');
        if (p1 == string::npos || p2 == string::npos || p1 == p2 || p2 <= p1) continue;

        MemorySignature sig;
        sig.name = line.substr(0, p1);
        string patternStr = line.substr(p1 + 1, p2 - p1 - 1);
        try { sig.danger_level = stoi(line.substr(p2 + 1)); }
        catch (const exception&) { sig.danger_level = 5; }

        sig.pattern.assign(patternStr.begin(), patternStr.end());
        signatures_.push_back(move(sig));
        count++;
    }

    LS_LOG_INFO("MemoryScanner", "Loaded " + to_string(count) + " signatures from " + path);
    buildMatcher();
    return count;
}

MemoryScanResult MemoryScanner::scanProcess(DWORD pid) {
    MemoryScanResult result;
    result.pid = pid;
    result.is_threat = false;
    result.matches_count = 0;
    result.memory_scanned = 0;
    result.regions_scanned = 0;
    result.detected_at = getCurrentTime();

    result.exe_path = getProcessPath(pid);
    size_t slash = result.exe_path.find_last_of("\\/");
    result.process_name = (slash != string::npos) ? result.exe_path.substr(slash + 1) : result.exe_path;

    HANDLE hProcess = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, pid);
    if (!hProcess) return result;

    MEMORY_BASIC_INFORMATION mbi;
    LPVOID address = nullptr;
    const size_t BLOCK_SIZE = 64 * 1024, MAX_MEMORY_PER_PROCESS = 256ULL * 1024 * 1024;
    vector<uint8_t> buffer;
    set<string> found_sigs;
    auto scan_start = chrono::steady_clock::now();
    const auto PROCESS_TIMEOUT = chrono::seconds(4);

    while (VirtualQueryEx(hProcess, address, &mbi, sizeof(mbi))) {
        if (!running_.load() && thread_running_.load()) break;
        auto elapsed = chrono::steady_clock::now() - scan_start;
        if (elapsed >= PROCESS_TIMEOUT) break;
        if (result.memory_scanned >= MAX_MEMORY_PER_PROCESS) break;

        if (isReadableRegion(mbi) && mbi.RegionSize > 0 && mbi.RegionSize < 256 * 1024 * 1024) {
            result.regions_scanned++;
            size_t regionSize = mbi.RegionSize;
            LPVOID regionBase = mbi.BaseAddress;

            for (size_t offset = 0; offset < regionSize; offset += BLOCK_SIZE) {
                if (!running_.load() && thread_running_.load()) break;
                size_t toRead = (min)(BLOCK_SIZE, regionSize - offset);
                buffer.resize(toRead);
                SIZE_T bytesRead = 0;
                LPVOID readAddr = reinterpret_cast<LPVOID>(reinterpret_cast<uintptr_t>(regionBase) + offset);
                if (!ReadProcessMemory(hProcess, readAddr, buffer.data(), toRead, &bytesRead)) continue;

                for (auto [pattern_id, end_pos] : matcher_.findAll(buffer.data(), bytesRead)) {
                    (void)end_pos;
                    if (pattern_id >= signatures_.size()) continue;
                    const auto& sig = signatures_[pattern_id];
                    if (found_sigs.count(sig.name)) continue;
                    result.matches_count++;
                    result.is_threat = true;
                    result.matched_signatures.push_back(sig.name);
                    found_sigs.insert(sig.name);
                    if (result.threat_name.empty()) result.threat_name = sig.name;
                }
            }
            result.memory_scanned += mbi.RegionSize;
        }

        address = reinterpret_cast<LPVOID>(reinterpret_cast<uintptr_t>(mbi.BaseAddress) + mbi.RegionSize);
        if (reinterpret_cast<uintptr_t>(address) < reinterpret_cast<uintptr_t>(mbi.BaseAddress)) break;
    }

    CloseHandle(hProcess);

    if (result.is_threat) {
        LS_LOG_WARN("MemoryScanner", "THREAT in PID " + to_string(pid) + " (" + result.process_name + "): " + result.threat_name + " matches=" + to_string(result.matches_count));
        stats::StatsRecorder::instance().recordThreat(stats::StatsRecorder::Source::kMemory);
    }

    return result;
}

bool MemoryScanner::searchMemory(HANDLE hProcess, const MemorySignature& sig) {
    if (sig.pattern.empty()) return false;

    MEMORY_BASIC_INFORMATION mbi;
    LPVOID address = nullptr;
    const size_t BLOCK_SIZE = 64 * 1024;
    vector<uint8_t> buffer(BLOCK_SIZE + sig.pattern.size());

    while (VirtualQueryEx(hProcess, address, &mbi, sizeof(mbi))) {
        if (isReadableRegion(mbi) && mbi.RegionSize > 0 && mbi.RegionSize < 256 * 1024 * 1024) {
            size_t regionSize = mbi.RegionSize;
            LPVOID regionBase = mbi.BaseAddress;

            for (size_t offset = 0; offset < regionSize; offset += BLOCK_SIZE) {
                size_t toRead = (min)(BLOCK_SIZE, regionSize - offset);
                SIZE_T bytesRead = 0;
                LPVOID readAddr = reinterpret_cast<LPVOID>(reinterpret_cast<uintptr_t>(regionBase) + offset);
                if (ReadProcessMemory(hProcess, readAddr, buffer.data(), toRead, &bytesRead) && bytesRead >= sig.pattern.size()) for (size_t i = 0; i <= bytesRead - sig.pattern.size(); i++) if (memcmp(&buffer[i], sig.pattern.data(), sig.pattern.size()) == 0) return true;
            }
        }

        address = reinterpret_cast<LPVOID>(reinterpret_cast<uintptr_t>(mbi.BaseAddress) + mbi.RegionSize);
        if (reinterpret_cast<uintptr_t>(address) < reinterpret_cast<uintptr_t>(mbi.BaseAddress)) break;
    }

    return false;
}

bool MemoryScanner::isReadableRegion(const MEMORY_BASIC_INFORMATION& mbi) const {
    if (mbi.State != MEM_COMMIT) return false;
    if (mbi.Protect & PAGE_GUARD) return false;
    if (mbi.Protect & PAGE_NOACCESS) return false;
    DWORD readable = PAGE_READONLY | PAGE_READWRITE | PAGE_EXECUTE_READ | PAGE_EXECUTE_READWRITE | PAGE_WRITECOPY | PAGE_EXECUTE_WRITECOPY;
    return (mbi.Protect & readable) != 0;
}

bool MemoryScanner::isSystemProcess(const string& processName) const {
    string lower = processName;
    transform(lower.begin(), lower.end(), lower.begin(), [](unsigned char c) { return tolower(c); });
    static const vector<string> skip_list = { "svchost.exe", "lsass.exe", "csrss.exe", "smss.exe", "wininit.exe", "services.exe", "winlogon.exe", "dwm.exe", "fontdrvhost.exe", "lsaiso.exe", "spoolsv.exe", "searchhost.exe", "searchindexer.exe", "msdtc.exe", "wuauserv.exe", "trustedinstaller.exe", "tiworker.exe", "audiodg.exe", "conhost.exe", "sihost.exe", "runtimebroker.exe", "system", "registry", "memory compression" };
    for (const auto& sys : skip_list) if (lower == sys) return true;
    return false;
}

bool MemoryScanner::startFullScan() {
    if (running_.load()) return false;
    for (int i = 0; i < 20 && thread_running_.load(); i++) this_thread::sleep_for(chrono::milliseconds(10));
    running_.store(true);
    {
        lock_guard<mutex> lock(progress_mutex_);
        progress_ = {};
        progress_.is_running = true;
        progress_.is_finished = false;
    }
    scan_thread_ = thread(&MemoryScanner::scanAllProcesses, this);
    LS_LOG_INFO("MemoryScanner", "Full memory scan started");
    return true;
}

void MemoryScanner::stopScan() {
    running_.store(false);
    if (scan_thread_.joinable()) {
        auto future = async(launch::async, [this] { scan_thread_.join(); });
        if (future.wait_for(chrono::seconds(3)) == future_status::timeout) scan_thread_.detach();
    }
}

void MemoryScanner::scanAllProcesses() {
    thread_running_.store(true);
    auto processes = getProcessList();

    {
        lock_guard<mutex> lock(progress_mutex_);
        progress_.processes_total = static_cast<int>(processes.size());
    }

    for (const auto& [pid, name] : processes) {
        if (!running_.load()) break;
        if (pid <= 4) continue;
        if (isSystemProcess(name)) {
            lock_guard<mutex> lock(progress_mutex_);
            progress_.processes_scanned++;
            continue;
        }

        {
            lock_guard<mutex> lock(progress_mutex_);
            progress_.current_process = name;
        }

        auto scanFuture = async(launch::async, &MemoryScanner::scanProcess, this, pid);
        MemoryScanResult result;
        if (scanFuture.wait_for(chrono::seconds(5)) == future_status::ready) {
            result = scanFuture.get();
        } else {
            LS_LOG_WARN("MemoryScanner", "Timeout scanning PID " + to_string(pid) + " (" + name + "), skipping");
            result.is_threat = false;
        }

        {
            lock_guard<mutex> lock(progress_mutex_);
            progress_.processes_scanned++;
            if (result.is_threat) { progress_.threats_found++; progress_.threats.push_back(result); }
        }
    }

    {
        lock_guard<mutex> lock(progress_mutex_);
        progress_.is_running = false;
        progress_.is_finished = true;
        progress_.current_process = "";
    }

    running_.store(false);
    thread_running_.store(false);
    LS_LOG_INFO("MemoryScanner", "Full scan completed. Threats: " + to_string(progress_.threats_found));
}

MemoryScanProgress MemoryScanner::getProgress() {
    lock_guard<mutex> lock(progress_mutex_);
    return progress_;
}

vector<pair<DWORD, string>> MemoryScanner::getProcessList() {
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

string MemoryScanner::getProcessPath(DWORD pid) {
    HANDLE hProcess = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, FALSE, pid);
    if (!hProcess) return "";
    wchar_t path[MAX_PATH] = {};
    DWORD size = MAX_PATH;
    BOOL success = QueryFullProcessImageNameW(hProcess, 0, path, &size);
    CloseHandle(hProcess);
    return success ? unicode_utils::wide_to_utf8(wstring(path, size)) : "";
}

string MemoryScanner::getCurrentTime() const {
    SYSTEMTIME st;
    GetLocalTime(&st);
    char buf[32];
    sprintf_s(buf, "%04d-%02d-%02d %02d:%02d:%02d", st.wYear, st.wMonth, st.wDay, st.wHour, st.wMinute, st.wSecond);
    return buf;
}
