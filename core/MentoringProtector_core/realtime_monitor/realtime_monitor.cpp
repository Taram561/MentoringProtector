#include "pch.h"
#include "realtime_monitor.h"
#include "../unicode_utils.h"
#include "../logger/logger.h"
#include "../stats/stats_recorder.h"
#include "../nudge/motw_reader.h"
#include "../nudge/nudge.h"
#include "../nudge/script_guard.h"
#include <future>

using namespace std;

RealtimeMonitor::RealtimeMonitor(const RealtimeMonitorConfig& config, Scanner* scanner, HeuristicAnalyzer* heuristic, INudgeSink* nudge_sink) : config_(config), scanner_(scanner), heuristic_(heuristic), nudge_sink_(nudge_sink) {
    if (config_.watch_paths.empty()) {
        char* userProfile = nullptr;
        size_t len = 0;
        if (_dupenv_s(&userProfile, &len, "USERPROFILE") == 0 && userProfile) {
            string home(userProfile);
            free(userProfile);
            config_.watch_paths.push_back(home + "\\Downloads");
            config_.watch_paths.push_back(home + "\\Desktop");
            config_.watch_paths.push_back(home + "\\Documents");
        }
        char* temp = nullptr;
        if (_dupenv_s(&temp, &len, "TEMP") == 0 && temp) {
            config_.watch_paths.push_back(string(temp));
            free(temp);
        }
    }
}
RealtimeMonitor::~RealtimeMonitor() { stop(); }
bool RealtimeMonitor::loadResources(const string& signatures_path, const string& rules_path, const string& threat_db_path) {
    if (scanner_ != nullptr) return true;
    owned_scanner_ = make_unique<Scanner>();
    owned_heuristic_ = make_unique<HeuristicAnalyzer>();
    scanner_ = owned_scanner_.get();
    heuristic_ = owned_heuristic_.get();
    bool sigs { scanner_->loadSignatures(signatures_path) > 0 };
    bool rules = heuristic_->loadRules(rules_path);
    scanner_->loadThreatDatabase(threat_db_path);
    LS_LOG_INFO("RealtimeMonitor", "Resources loaded (standalone): sigs=" + to_string(sigs) + " rules=" + to_string(rules));
    return sigs && rules;
}
bool RealtimeMonitor::start() {
    if (running_.load()) return false;
    for (int i = 0; i < 20 && thread_running_.load(); i++) this_thread::sleep_for(chrono::milliseconds(10));

    running_.store(true);
    scan_thread_ = thread(&RealtimeMonitor::scanWorker, this);
    for (const auto& path : config_.watch_paths) {
        DWORD attrs = GetFileAttributesW(unicode_utils::utf8_to_wide(path).c_str());
        if (attrs == INVALID_FILE_ATTRIBUTES || !(attrs & FILE_ATTRIBUTE_DIRECTORY)) {
            LS_LOG_WARN("RealtimeMonitor", "Skipping non-existent directory: " + path);
            continue;
        }
        watch_threads_.emplace_back(&RealtimeMonitor::watchDirectory, this, path);
        LS_LOG_INFO("RealtimeMonitor", "Watching: " + path);
    }
    LS_LOG_INFO("RealtimeMonitor", "Started with " + to_string(watch_threads_.size()) + " watchers");
    return true;
}
void RealtimeMonitor::stop() {
    if (!running_.load()) return;
    running_.store(false);
    queue_cv_.notify_all();

    {
        lock_guard<mutex> lock(handles_mutex_);
        for (HANDLE h : dir_handles_) {
            if (h != INVALID_HANDLE_VALUE) {
                CancelIoEx(h, nullptr);
                CloseHandle(h);
            }
        }
        dir_handles_.clear();
    }

    for (auto& t : watch_threads_) {
        if (t.joinable()) t.join();
    }
    watch_threads_.clear();
    if (scan_thread_.joinable()) scan_thread_.join();

    LS_LOG_INFO("RealtimeMonitor", "Stopped");
}

void RealtimeMonitor::watchDirectory(const string& dirPath) {
    thread_running_.store(true);
    HANDLE hDir = CreateFileW(unicode_utils::utf8_to_wide(dirPath).c_str(), FILE_LIST_DIRECTORY, FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE, nullptr, OPEN_EXISTING, FILE_FLAG_BACKUP_SEMANTICS | FILE_FLAG_OVERLAPPED, nullptr);
    if (hDir == INVALID_HANDLE_VALUE) {
        LS_LOG_ERROR("RealtimeMonitor", "Cannot open directory: " + dirPath + " error=" + to_string(GetLastError()));
        thread_running_.store(false);
        return;
    }
    {
        lock_guard<mutex> lock(handles_mutex_);
        dir_handles_.push_back(hDir);
    }
    const DWORD bufferSize = 64 * 1024;
    vector<BYTE> buffer(bufferSize);
    OVERLAPPED overlapped = {};
    overlapped.hEvent = CreateEventW(nullptr, TRUE, FALSE, nullptr);

    while (running_.load()) {
        DWORD bytesReturned = 0;
        BOOL success = ReadDirectoryChangesW(hDir, buffer.data(), bufferSize, TRUE, FILE_NOTIFY_CHANGE_FILE_NAME | FILE_NOTIFY_CHANGE_SIZE | FILE_NOTIFY_CHANGE_LAST_WRITE | FILE_NOTIFY_CHANGE_CREATION, nullptr, &overlapped, nullptr);
        if (!success) {
            DWORD err = GetLastError();
            if (err == ERROR_OPERATION_ABORTED) break;
            LS_LOG_ERROR("RealtimeMonitor", "ReadDirectoryChangesW failed: " + to_string(err));
            break;
        }
        DWORD waitResult = WaitForSingleObject(overlapped.hEvent, 500);
        if (waitResult == WAIT_TIMEOUT) continue;
        if (waitResult != WAIT_OBJECT_0) break;
        if (!GetOverlappedResult(hDir, &overlapped, &bytesReturned, FALSE)) {
            DWORD err = GetLastError();
            if (err == ERROR_OPERATION_ABORTED) break;
            continue;
        }
        ResetEvent(overlapped.hEvent);
        if (bytesReturned == 0) continue;
        BYTE* ptr = buffer.data();
        while (true) {
            auto* info = reinterpret_cast<FILE_NOTIFY_INFORMATION*>(ptr);
            int nameLen = info->FileNameLength / sizeof(WCHAR);
            int utf8Size = WideCharToMultiByte(CP_UTF8, 0, info->FileName, nameLen, nullptr, 0, nullptr, nullptr);
            string fileName(utf8Size, '\0');
            WideCharToMultiByte(CP_UTF8, 0, info->FileName, nameLen, &fileName[0], utf8Size, nullptr, nullptr);
            string fullPath = dirPath + "\\" + fileName, action;
            switch (info->Action) {
            case FILE_ACTION_ADDED: action = "created";
                break;
            case FILE_ACTION_MODIFIED: action = "modified";
                break;
            case FILE_ACTION_RENAMED_NEW_NAME: action = "renamed";
                break;
            default:
                break;
            }
            if (!action.empty() && shouldScan(fullPath)) enqueueFile(fullPath, action);
            if (info->NextEntryOffset == 0) break;
            ptr += info->NextEntryOffset;
        }
    }
    CloseHandle(overlapped.hEvent);
    thread_running_.store(false);
}

void RealtimeMonitor::scanWorker() {
    while (running_.load()) {
        vector<pair<string, string>> batch;
        {
            unique_lock<mutex> lock(queue_mutex_);
            queue_cv_.wait_for(lock, chrono::milliseconds(200),  [this] { return !scan_queue_.empty() || !running_.load(); });
            if (!running_.load() && scan_queue_.empty()) break;
            batch = move(scan_queue_);
            scan_queue_.clear();
        }
        for (const auto& [path, action] : batch) {
            if (!running_.load()) break;
            this_thread::sleep_for(chrono::milliseconds(config_.scan_delay_ms));
            FileEvent event = scanFile(path, action);
            {
                lock_guard<mutex> lock(events_mutex_);
                events_.push_back(move(event));
                if (static_cast<int>(events_.size()) > config_.max_events) events_.erase(events_.begin());
            }
        }
    }
}
void RealtimeMonitor::enqueueFile(const string& path, const string& action) {
    {
        lock_guard<mutex> lock(recent_mutex_);
        auto now = chrono::steady_clock::now();
        auto it = recent_files_.find(path);
        if (it != recent_files_.end()) {
            auto elapsed = chrono::duration_cast< chrono::seconds>(now - it->second);
            if (elapsed.count() < 3) return;
        }
        recent_files_[path] = now;
        if (recent_files_.size() > 1000) {
            for (auto it2 = recent_files_.begin();
                it2 != recent_files_.end(); ) {
                auto age = chrono::duration_cast< chrono::seconds>(now - it2->second);
                if (age.count() > 30) it2 = recent_files_.erase(it2);
                else { ++it2; }
            }
        }
    }
    {
        lock_guard<mutex> lock(queue_mutex_);
        scan_queue_.emplace_back(path, action);
    }
    queue_cv_.notify_one();
    total_detected_.fetch_add(1);
}
FileEvent RealtimeMonitor::scanFile(const string& path, const string& action) {
    FileEvent event;
    event.file_path = path;
    event.action = action;
    event.detected_at = getCurrentTime();
    event.scanned = false;
    event.is_threat = false;
    event.danger_level = 0;
    event.score = 0;
    event.verdict = "clean";

    wstring wide_path = unicode_utils::utf8_to_wide(path);
    DWORD attrs = GetFileAttributesW(wide_path.c_str());
    if (attrs == INVALID_FILE_ATTRIBUTES) return event;
    if (attrs & FILE_ATTRIBUTE_DIRECTORY) return event;

    HANDLE hFile = CreateFileW(wide_path.c_str(), GENERIC_READ, FILE_SHARE_READ | FILE_SHARE_WRITE, nullptr, OPEN_EXISTING, 0, nullptr);
    if (hFile != INVALID_HANDLE_VALUE) {
        LARGE_INTEGER fileSize;
        if (GetFileSizeEx(hFile, &fileSize)) {
            if (static_cast<size_t>(fileSize.QuadPart) > config_.max_file_size) {
                CloseHandle(hFile);
                return event;
            }
        }
        CloseHandle(hFile);
    }
    event.scanned = true;
    stats::StatsRecorder::ScopedSourceOverride src_override(stats::StatsRecorder::Source::kRealtime);
    if (!scanner_) return event;
    ScanResult scanResult = scanner_->scanFile(path);
    if (scanResult.is_infected) {
        event.is_threat = true;
        event.threat_name = scanResult.threat_name;
        event.danger_level = scanResult.danger_level;
        event.score = 100;
        event.verdict = "malicious";
        event.detection_method = "signature";
        threats_found_.fetch_add(1);
        LS_LOG_WARN("RealtimeMonitor", "THREAT: " + path + " => " + scanResult.threat_name);
        return event;
    }
    string ext = path;
    transform(ext.begin(), ext.end(), ext.begin(), ::tolower);
    size_t dotPos = ext.rfind('.');
    if (dotPos != string::npos) ext = ext.substr(dotPos);
    bool isPE = (ext == ".exe" || ext == ".dll" || ext == ".scr" || ext == ".sys" || ext == ".drv" || ext == ".com");

    if (isPE && heuristic_) {
        HeuristicResult hr = heuristic_->analyze(path);
        int score = hr.suspicion_score;
        if (hr.has_signature && score > 0) score = static_cast<int>(score * 0.6);
        event.score = score;
        if (score <= 20) {
            event.verdict = "clean";
            event.danger_level = 0;
        } else if (score <= 50) {
            event.verdict = "suspicious";
            event.danger_level = 4;
        } else if (score <= 80) {
            event.verdict = "likely_malicious";
            event.danger_level = 7;
            event.is_threat = true;
            threats_found_.fetch_add(1);
            stats::StatsRecorder::instance().recordThreat(stats::StatsRecorder::Source::kRealtime);
        } else {
            event.verdict = "malicious";
            event.danger_level = 9;
            event.is_threat = true;
            threats_found_.fetch_add(1);
            stats::StatsRecorder::instance().recordThreat(stats::StatsRecorder::Source::kRealtime);
        }
        event.detection_method = "heuristic";
        if (event.is_threat) { LS_LOG_WARN("RealtimeMonitor", "HEURISTIC: " + path + " score=" + to_string(score) + " verdict=" + event.verdict); }
    }
    if (nudge_sink_ && !event.is_threat) {
        string fileName = path;
        size_t sep = fileName.rfind('\\');
        if (sep != string::npos) fileName = fileName.substr(sep + 1);
        static const string dangerousExts[] = { ".exe", ".scr", ".msi", ".bat", ".cmd", ".com", ".pif" };
        bool isDangerous = false;
        for (const auto& dext : dangerousExts) {
            if (ext == dext) { isDangerous = true; break; }
        }
        if (isDangerous && motw::isFromInternet(path)) {
            Nudge n;
            n.category = NudgeCategory::DownloadedExe;
            n.detail = fileName;
            n.severity = "security";
            n.detected_at = event.detected_at;
            nudge_sink_->emit(n);
        }

        static const string containerExts[] = { ".iso", ".vhd", ".vhdx", ".img", ".7z", ".rar" };
        bool isContainer = false;
        for (const auto& cext : containerExts) {
            if (ext == cext) { isContainer = true; break; }
        }
        if (isContainer && motw::isFromInternet(path)) {
            Nudge n;
            n.category = NudgeCategory::DownloadedContainer;
            n.detail = fileName;
            n.severity = "security";
            n.detected_at = event.detected_at;
            nudge_sink_->emit(n);
        }

        static const string macroExts[] = { ".docm", ".xlsm", ".pptm", ".dotm", ".xlam" };
        bool isMacro = false;
        for (const auto& mext : macroExts) {
            if (ext == mext) { isMacro = true; break; }
        }
        if (isMacro) {
            Nudge n;
            n.category = NudgeCategory::MacroDocument;
            n.detail = fileName;
            n.severity = "info";
            n.detected_at = event.detected_at;
            nudge_sink_->emit(n);
        }
        static const string scriptExts[] = { ".ps1", ".vbs", ".hta" };
        bool isScript = false;
        for (const auto& sext : scriptExts) {
            if (ext == sext) { isScript = true; break; }
        }
        if (isScript) {
            auto sg = script_guard::analyze(path);
            if (sg.suspicious) {
                Nudge n;
                n.category = NudgeCategory::SuspiciousScript;
                n.detail = fileName;
                n.context = sg.foundTokens;
                n.severity = "security";
                n.detected_at = event.detected_at;
                nudge_sink_->emit(n);
            }
        }
    }
    return event;
}

bool RealtimeMonitor::shouldScan(const string& path) const {
    string lower = path;
    transform(lower.begin(), lower.end(), lower.begin(), ::tolower);
    size_t dotPos = lower.rfind('.');
    if (dotPos == string::npos) return false;
    string ext = lower.substr(dotPos);
    for (const auto& scanExt : config_.scan_extensions) if (ext == scanExt) return true;
    return false;
}
vector<FileEvent> RealtimeMonitor::getAndClearEvents() {
    lock_guard<mutex> lock(events_mutex_);
    vector<FileEvent> result = move(events_);
    events_.clear();
    return result;
}

string RealtimeMonitor::getCurrentTime() const {
    SYSTEMTIME st;
    GetLocalTime(&st);
    char buf[32];
    sprintf_s(buf, "%04d-%02d-%02d %02d:%02d:%02d", st.wYear, st.wMonth, st.wDay, st.wHour, st.wMinute, st.wSecond);
    return buf;
}