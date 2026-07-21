#include "pch.h"
#include "scanner.h"
#include "unicode_utils.h"
#include "../json_utils.h"
#include "../stats/stats_recorder.h"
#include <fstream>

using namespace std;

Scanner::Scanner(): db_(make_unique<SignatureDatabase>()), db_threat_(make_unique<ThreatDatabase>()) { }

Scanner::~Scanner() {
    stopComputerScan();
    if (scan_thread_.joinable()) scan_thread_.join();
    stopWorkerPool();
}

bool Scanner::loadSignatures(const string& db_path) {
    int count = db_->loadFromFile(db_path);
    return count > 0;
}

bool Scanner::reloadDatabase(const string& db_path) {
    auto new_db = make_unique<SignatureDatabase>();
    int count = new_db->loadFromFile(db_path);
    if (count <= 0) return false;
    {
        unique_lock<shared_mutex> lock(db_reload_mutex_);
        db_ = std::move(new_db);
    }
    invalidateCache();
    return true;
}
bool Scanner::loadThreatDatabase(const string& json_path) {
    int count = db_threat_->loadFromFile(json_path);
    return count > 0;
}
string Scanner::calculateSHA256(const string& file_path) { return hasher_.calculateSHA256(file_path); }
string Scanner::calculateMD5(const string& file_path) { return hasher_.calculateMD5(file_path); }
string Scanner::calculateSHA1(const string& file_path) { return hasher_.calculateSHA1(file_path); }

void Scanner::setHeuristicAnalyzer(HeuristicAnalyzer* analyzer) { heuristic_ = analyzer; }
void Scanner::setYaraScanner(YaraScanner* scanner) { yara_ = scanner; }
void Scanner::setArchiveScanner(ArchiveScanner* scanner) { archive_scanner_ = scanner; }

bool Scanner::isArchiveFile(const string& path) const {
    string lower = path;
    transform(lower.begin(), lower.end(), lower.begin(), ::tolower);
    static const char* exts[] = { ".zip", ".7z", ".rar", ".iso", ".img", nullptr };
    for (int i = 0; exts[i]; ++i) {
        size_t pos = lower.rfind(exts[i]);
        if (pos != string::npos && pos + strlen(exts[i]) == lower.size()) return true;
    }
    FILE* f = nullptr;
    if (fopen_s(&f, path.c_str(), "rb") != 0 || !f) return false;
    unsigned char magic[8] = {};
    size_t read = fread(magic, 1, 8, f);
    fclose(f);
    if (read < 4) return false;
    if (magic[0] == 0x50 && magic[1] == 0x4B && magic[2] == 0x03 && magic[3] == 0x04) return true;
    if (magic[0] == 0x37 && magic[1] == 0x7A && magic[2] == 0xBC && magic[3] == 0xAF) return true;
    if (magic[0] == 0x52 && magic[1] == 0x61 && magic[2] == 0x72 && magic[3] == 0x21) return true;
    return false;
}

ScanResult Scanner::scanFile(const string& file_path) {
    ScanResult result;
    result.file_path = file_path;
    if (shouldSkipPath(file_path)) {
        result.detection_method = "skipped";
        return result;
    }

    SmartScanCacheEntry cached;
    if (scan_cache_.lookup(file_path, cached)) {
        result.is_infected = cached.was_infected;
        result.threat_name = cached.threat_name;
        result.detection_method = cached.detection_method;
        result.danger_level = cached.danger_level;
        if (cached.was_infected && db_threat_ && db_threat_->isLoaded()) result.threat_info = db_threat_->findByName(cached.threat_name);
        return result;
    }
    MultiHash hashes = hasher_.calculateAllHashes(file_path);
    result.file_hash = hashes.sha256;

    if (result.file_hash.empty()) {
        result.threat_name = "Ошибка чтения файла";
        result.detection_method = "error";
        return result;
    }

    bool found_by_signature = false;

    {
        shared_lock<shared_mutex> db_lock(db_reload_mutex_);
        if (db_->isLoaded()) {
            const SignatureRecord* record = nullptr;
            if (!hashes.sha256.empty()) record = db_->findByHash(hashes.sha256);
            if (record == nullptr && !hashes.md5.empty()) record = db_->findByHash(hashes.md5);
            if (record == nullptr && !hashes.sha1.empty()) record = db_->findByHash(hashes.sha1);
            if (record != nullptr) {
                found_by_signature = true;
                result.is_infected = true;
                result.threat_name = record->threat_name;
                if (db_threat_->isLoaded()) result.threat_info = db_threat_->findByName(record->threat_name);
                else result.threat_info = ThreatDatabase::createUnknown(record->threat_name);
                result.threat_type = result.threat_info.type;
                result.danger_level = result.threat_info.danger_level;
                result.detection_method = "signature";
            }
        }
    }

    bool found_by_archive = false;
    if (!found_by_signature && archive_scanner_ != nullptr && isArchiveFile(file_path)) {
        ScanResult ar = archive_scanner_->scanArchive(file_path);
        if (ar.is_infected) {
            found_by_archive = true;
            result.is_infected = true;
            result.detection_method = "archive_scan";
            result.threat_name = ar.threat_name;
            result.threat_type = ar.threat_type;
            result.danger_level = ar.danger_level;
            result.threat_info = ar.threat_info;
            result.engines_triggered.push_back("archive_scan");
        }
    }
    bool found_by_yara = false;
    if (!found_by_signature && !found_by_archive && yara_ != nullptr && yara_->isAvailable() && shouldRunYara(file_path)) {
        result.yara = yara_->scanFile(file_path);
        if (result.yara.is_threat) {
            found_by_yara = true;
            result.is_infected = true;
            result.detection_method = "yara";
            result.threat_name = result.yara.threat_name;
            result.threat_type = "suspicious";
            if (result.yara.score >= 80) result.danger_level = 9;
            else if (result.yara.score >= 50) result.danger_level = 7;
            else result.danger_level = 5;
            if (db_threat_->isLoaded()) {
                ThreatInfo info = db_threat_->findByName(result.threat_name);
                if (info.is_found) {
                    result.threat_info = info;
                    result.threat_type = info.type;
                    result.danger_level = info.danger_level;
                }
            }
        }
    }
    bool skip_heuristic_trusted = false;
    if (!found_by_signature && !found_by_archive && !found_by_yara && shouldRunHeuristic(file_path) && heuristic_ != nullptr) {
        string lower_path = file_path;
        transform(lower_path.begin(), lower_path.end(), lower_path.begin(), ::tolower);
        bool in_trusted_dir = false;
        if (lower_path.length() >= 3 && lower_path[1] == ':' && lower_path[2] == '\\') {
            string after_drive = lower_path.substr(2);
            in_trusted_dir = (after_drive.find("\\program files\\") == 0) || (after_drive.find("\\program files (x86)\\") == 0) || (after_drive.find("\\windows\\") == 0);
        }
        if (in_trusted_dir) {
            bool cached_trusted = false;
            string cached_signer;
            if (trusted_cache_.lookup(file_path, cached_trusted, cached_signer)) {
                if (cached_trusted) {
                    skip_heuristic_trusted = true;
                    result.detection_method = "none";
                }
            } else {
                auto sig_future = async(launch::async, [fp = string(file_path), h = heuristic_]() { return h->checkDigitalSignature(fp); });
                bool has_sig = false;
                if (sig_future.wait_for(chrono::seconds(2)) == future_status::ready) { has_sig = sig_future.get(); }

                trusted_cache_.store(file_path, has_sig);

                if (has_sig) {
                    skip_heuristic_trusted = true;
                    result.detection_method = "none";
                }
            }
        }
    }

    if (!found_by_signature && !found_by_yara && shouldRunHeuristic(file_path) && !skip_heuristic_trusted) {
        if (heuristic_ != nullptr) {
            result.heuristic = heuristic_->analyze(file_path);

            if (result.heuristic.suspicion_score >= 70) {
                result.is_infected = true;
                result.detection_method = "heuristic";
                result.threat_name = result.heuristic.verdict.empty() ? "Heuristic.Suspicious" : result.heuristic.verdict;
                result.threat_type = "suspicious";
                result.danger_level = result.heuristic.danger_level;

                if (db_threat_->isLoaded()) {
                    ThreatInfo info = db_threat_->findByName(result.threat_name);
                    if (info.is_found) result.threat_info = info;
                }
            } else { result.detection_method = "none"; }
        } else { result.detection_method = "none"; }
    }
    if (result.is_infected) {
        if (found_by_signature) {
            result.engines_triggered.push_back("signature");
            if (yara_ != nullptr && yara_->isAvailable() && shouldRunYara(file_path)) {
                YaraResult yr = yara_->scanFile(file_path);
                if (yr.is_threat) {
                    result.yara = yr;
                    result.engines_triggered.push_back("yara");
                }
            }
            if (heuristic_ != nullptr && shouldRunHeuristic(file_path)) {
                const HeuristicResult& hr = result.heuristic.suspicion_score > 0 ? result.heuristic : (result.heuristic = heuristic_->analyze(file_path));
                if (hr.suspicion_score >= 70) result.engines_triggered.push_back("heuristic");
            }
        } else if (found_by_yara) {
            result.engines_triggered.push_back("yara");
            if (heuristic_ != nullptr && shouldRunHeuristic(file_path)) {
                const HeuristicResult& hr = result.heuristic.suspicion_score > 0 ? result.heuristic : (result.heuristic = heuristic_->analyze(file_path));
                if (hr.suspicion_score >= 70) result.engines_triggered.push_back("heuristic");
            }
        } else { result.engines_triggered.push_back("heuristic"); }
    }
    if (result.detection_method != "error") { scan_cache_.store(file_path, result.is_infected, result.threat_name, result.detection_method, result.danger_level); }
    if (result.is_infected) {
        auto& sr = stats::StatsRecorder::instance();
        sr.recordThreat(sr.effectiveSource(stats::StatsRecorder::Source::kScan));
    }
    return result;
}

SmartScanStats Scanner::getCacheStats() const { return scan_cache_.getStats(); }
void Scanner::invalidateCache() { scan_cache_.invalidateAll(); }
void Scanner::clearCache() { scan_cache_.clear(); }

void Scanner::startWorkerPool() {
    num_workers_ = max(2u, thread::hardware_concurrency());
    if (num_workers_ > 8) num_workers_ = 8;

    pool_running_.store(true);
    worker_threads_.reserve(num_workers_);

    for (int i = 0; i < num_workers_; i++) worker_threads_.emplace_back(&Scanner::scanWorkerLoop, this);
}

void Scanner::stopWorkerPool() {
    pool_running_.store(false);
    queue_cv_.notify_all();

    for (auto& t : worker_threads_) if (t.joinable()) t.join();
    worker_threads_.clear();
}

void Scanner::scanWorkerLoop() {
    while (pool_running_.load() && !scan_stop_flag_.load()) {
        string file_path;

        {
            unique_lock<mutex> lock(queue_mutex_);
            queue_cv_.wait_for(lock, chrono::milliseconds(50), [this] { return !file_queue_.empty() || !pool_running_.load(); });

            if (!pool_running_.load() && file_queue_.empty()) break;
            if (file_queue_.empty()) continue;

            file_path = move(file_queue_.back());
            file_queue_.pop_back();
        }

        if (scan_stop_flag_.load()) break;
        try {
            ScanResult result = scanFile(file_path);
            lock_guard<mutex> lock(progress_mutex_);
            progress_.files_scanned++;
            if (result.is_infected) {
                progress_.threats_found++;
                progress_.threats.push_back(move(result));
            }
        }
        catch (...) {
            lock_guard<mutex> lock(progress_mutex_);
            progress_.files_scanned++;
        }
    }
}
bool Scanner::startComputerScan() {
    {
        lock_guard<mutex> lock(progress_mutex_);
        if (progress_.is_running) return false;
        progress_ = ComputerScanProgress{};
        progress_.is_running = true;
    }
    if (scan_thread_.joinable()) scan_thread_.join();
    scan_stop_flag_.store(false);
    if (heuristic_) HeuristicAnalyzer::prefetchCertificateCache();

    startWorkerPool();
    scan_thread_ = thread([this]() {
        try {
            DWORD drives = GetLogicalDrives();
            vector<string> drive_list;

            for (int i = 0; i < 26; i++) {
                if (!(drives & (1 << i))) continue;
                string drive = string(1, (char)('A' + i)) + ":\\";
                UINT type = GetDriveTypeW(unicode_utils::utf8_to_wide(drive).c_str());
                if (type == DRIVE_FIXED || type == DRIVE_REMOVABLE) drive_list.push_back(drive);
            }

            for (const auto& drive : drive_list) {
                if (scan_stop_flag_.load()) break;
                {
                    lock_guard<mutex> lock(progress_mutex_);
                    progress_.current_drive = drive;
                }
                scanDirectoryRecursive(drive, 0);
            }
        }
        catch (const exception& e) {
            lock_guard<mutex> lock(progress_mutex_);
            progress_.error = e.what();
        }
        catch (...) {
            lock_guard<mutex> lock(progress_mutex_);
            progress_.error = "Unknown error during computer scan";
        }
        while (true) {
            {
                lock_guard<mutex> lock(queue_mutex_);
                if (file_queue_.empty()) break;
            }
            this_thread::sleep_for(chrono::milliseconds(50));
            if (scan_stop_flag_.load()) break;
        }

        stopWorkerPool();

        uint32_t files_scanned_snapshot = 0;
        {
            lock_guard<mutex> lock(progress_mutex_);
            progress_.is_running = false;
            progress_.is_finished = true;
            progress_.current_file = "";
            files_scanned_snapshot = static_cast<uint32_t>(progress_.files_scanned);
        }
        stats::StatsRecorder::instance().recordScan(files_scanned_snapshot);
    });
    return true;
}
void Scanner::stopComputerScan() {
    scan_stop_flag_.store(true);
    {
        lock_guard<mutex> lock(queue_mutex_);
        file_queue_.clear();
    }
    queue_cv_.notify_all();
}

ComputerScanProgress Scanner::getComputerScanProgress() const {
    lock_guard<mutex> lock(progress_mutex_);
    return progress_;
}
void Scanner::scanDirectoryRecursive(const string& path, int depth) {
    if ((depth > 15) || (scan_stop_flag_.load()) || (shouldSkipPath(path))) return;
    WIN32_FIND_DATAW fd;
    wstring wide_pattern = unicode_utils::utf8_to_wide(path + "*");
    HANDLE hFind = FindFirstFileW(wide_pattern.c_str(), &fd);
    if (hFind == INVALID_HANDLE_VALUE) return;

    do {
        if (scan_stop_flag_.load()) break;

        string name = unicode_utils::wide_to_utf8(fd.cFileName);
        if (name == "." || name == "..") continue;

        string full_path = path + name;

        if (fd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) scanDirectoryRecursive(full_path + "\\", depth + 1);
        else {
            if (shouldSkipPath(full_path)) continue;
            LARGE_INTEGER file_size;
            file_size.LowPart = fd.nFileSizeLow;
            file_size.HighPart = fd.nFileSizeHigh;
            if (file_size.QuadPart > 100LL * 1024 * 1024) continue;

            {
                lock_guard<mutex> lock(progress_mutex_);
                progress_.files_total++;
                progress_.current_file = full_path;
            }
            {
                lock_guard<mutex> lock(queue_mutex_);
                file_queue_.push_back(full_path);
            }
            queue_cv_.notify_one();

            while (true) {
                {
                    lock_guard<mutex> lock(queue_mutex_);
                    if (file_queue_.size() < 1000) break;
                }
                this_thread::sleep_for(chrono::milliseconds(10));
                if (scan_stop_flag_.load()) break;
            }
        }
    } while (FindNextFileW(hFind, &fd));
    FindClose(hFind);
}
static const string& selfModuleDirLower() {
    static once_flag flag;
    static string value;
    call_once(flag, []() {
        wchar_t buf[MAX_PATH] = {};
        HMODULE hm = NULL;
        if (GetModuleHandleExW(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS | GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT, reinterpret_cast<LPCWSTR>(&selfModuleDirLower), &hm) && hm) {
            DWORD n = GetModuleFileNameW(hm, buf, MAX_PATH);
            if (n > 0 && n < MAX_PATH) {
                wstring wdir(buf, n);
                auto pos = wdir.find_last_of(L"\\/");
                if (pos != wstring::npos) {
                    wdir.resize(pos + 1);
                    string dir = unicode_utils::wide_to_utf8(wdir);
                    transform(dir.begin(), dir.end(), dir.begin(), ::tolower);
                    value = dir;
                }
            }
        }
    });
    return value;
}

bool Scanner::shouldSkipPath(const string& path) const {
    string lower = path;
    transform(lower.begin(), lower.end(), lower.begin(), ::tolower);
    if (lower.find("\\mentoringprotector\\unpack\\") != string::npos) return false;
    if (lower.find("\\tmp\\unpack\\") != string::npos) return false;
    {
        const string& selfDir = selfModuleDirLower();
        if (!selfDir.empty() && lower.size() >= selfDir.size() && lower.compare(0, selfDir.size(), selfDir) == 0) return true;
    }
    static const vector<string> SKIP_SUBSTRINGS = { "\\windows\\system32", "\\windows\\syswow64", "\\windows\\winsxs", "\\windows\\servicing", "\\windows\\installer", "\\windows\\assembly", "\\windows\\microsoft.net", "\\windows\\immersivecontrolpanel", "\\windows\\temp", "\\windows\\prefetch", "\\windows\\logs", "\\mentoringprotector\\quarantine", "\\mentoringprotector\\data", "\\appdata\\local\\temp", "\\appdata\\local\\microsoft\\windows\\inetcache", "\\appdata\\local\\google\\chrome\\user data\\default\\cache", "\\appdata\\local\\mozilla\\firefox\\profiles", "\\appdata\\local\\packages", "\\build\\windows\\x64", "\\mentoringprotector\\core\\", "\\mentoringprotector\\gui\\", "\\mentoringprotector\\extension\\","\\mentoringprotector\\tests\\", "\\mentoringprotector\\updater\\", "\\mentoringprotector\\build\\", "\\mentoringprotector\\yara\\tests\\", "\\microsoft\\windows defender", "\\programdata\\microsoft\\windows defender", };
    for (const auto& skip : SKIP_SUBSTRINGS) if (lower.find(skip) != string::npos) return true;
    static const unordered_set<string> SKIP_BASENAMES = { "$recycle.bin", "$windows.~bt", "$windows.~ws", "system volume information", "node_modules", "__pycache__", ".venv", ".nuget", ".cargo", ".rustup", ".gradle", ".pub-cache", ".git", ".m2", "msys64", "mingit", "cygwin", "cygwin64", "mingw64", "mingw32", "kaspersky lab", "eset", "norton", "bitdefender", "avast software", "avg", "malwarebytes", "windows defender", "drweb", "comodo", "trendmicro", "mcafee", "sophos", "f-secure", "panda security", };
    {
        size_t start = 0;
        while (start < lower.size()) {
            size_t sep = lower.find_first_of("\\/", start);
            if (sep == string::npos) sep = lower.size();
            if (sep > start && SKIP_BASENAMES.count(lower.substr(start, sep - start))) return true;
            start = sep + 1;
        }
    }
    static const unordered_set<string> SAFE_EXTS = { ".jpg", ".jpeg", ".png", ".gif", ".bmp", ".svg", ".ico", ".webp", ".tiff", ".tif", ".raw", ".heic", ".avif", ".mp3", ".mp4", ".avi", ".mkv", ".wav", ".flac", ".ogg", ".aac", ".wma", ".wmv", ".mov", ".webm", ".m4a", ".m4v", ".woff", ".woff2", ".ttf", ".otf", ".eot", };
    size_t dot = lower.rfind('.');
    if (dot != string::npos && SAFE_EXTS.count(lower.substr(dot))) return true;
    {
        lock_guard<mutex> lock(exclusions_mutex_);
        for (const auto& excl : user_exclusions_) {
            if (excl.empty()) continue;
            if (excl.size() >= 2 && excl[0] == '*' && excl[1] == '.') {
                if (dot != string::npos && lower.substr(dot) == excl.substr(1)) return true;
            } else if (lower.find(excl) != string::npos) {
                return true;
            }
        }
    }
    return false;
}

bool Scanner::shouldRunHeuristic(const string& path) const {
    string lower = path;
    transform(lower.begin(), lower.end(), lower.begin(), ::tolower);
    size_t dot = lower.rfind('.');
    if (dot == string::npos) return true;

    string ext = lower.substr(dot);
    static const unordered_set<string> heuristic_exts = { ".exe", ".dll", ".sys", ".scr", ".cpl", ".ocx", ".drv", ".com", ".pif", ".bat", ".cmd", ".ps1", ".vbs", ".vbe", ".jse", ".wsf", ".wsh", ".hta", ".msi", ".msp", ".js" };

    return heuristic_exts.count(ext) > 0;
}
bool Scanner::shouldRunYara(const string& path) const {
    string lower = path;
    transform(lower.begin(), lower.end(), lower.begin(), ::tolower);

    size_t dot = lower.rfind('.');
    if (dot == string::npos) return true;

    string ext = lower.substr(dot);
    static const unordered_set<string> yara_exts = { ".exe", ".dll", ".sys", ".scr", ".cpl", ".ocx", ".drv", ".com", ".pif", ".bat", ".cmd", ".ps1", ".vbs", ".vbe", ".jse", ".wsf", ".wsh", ".hta", ".msi", ".msp", ".js", ".txt", ".doc", ".docx", ".xls", ".xlsx", ".ppt", ".pptx", ".pdf", ".rtf", ".html", ".htm", ".xml", ".lnk", ".jar", ".class", ".py", ".rb", ".sh", ".vba" };
    return yara_exts.count(ext) > 0;
}

bool Scanner::loadExclusions(const string& json_path) {
    exclusions_file_ = json_path;
    lock_guard<mutex> lock(exclusions_mutex_);
    user_exclusions_.clear();
    ifstream file(json_path);
    if (!file.is_open()) return true;
    string content((istreambuf_iterator<char>(file)), istreambuf_iterator<char>());
    file.close();
    string arr = json_utils::extractArray(content, "exclusions");
    if (arr.empty()) return true;
    size_t pos = 0;
    while ((pos = arr.find('"', pos)) != string::npos) {
        size_t end = arr.find('"', pos + 1);
        if (end == string::npos) break;
        string val = arr.substr(pos + 1, end - pos - 1);
        transform(val.begin(), val.end(), val.begin(), ::tolower);
        if (!val.empty()) user_exclusions_.push_back(val);
        pos = end + 1;
    }
    return true;
}
bool Scanner::saveExclusions() const {
    if (exclusions_file_.empty()) return false;
    lock_guard<mutex> lock(exclusions_mutex_);
    ofstream file(exclusions_file_);
    if (!file.is_open()) return false;
    file << "{\n  \"exclusions\": [";
    for (size_t i = 0; i < user_exclusions_.size(); ++i) {
        if (i > 0) file << ",";
        file << "\n    \"" << json_utils::escapeJson(user_exclusions_[i]) << "\"";
    }
    file << "\n  ]\n}\n";
    file.close();
    return true;
}
vector<string> Scanner::getExclusions() const {
    lock_guard<mutex> lock(exclusions_mutex_);
    return user_exclusions_;
}
bool Scanner::addExclusion(const string& path) {
    string lower = path;
    transform(lower.begin(), lower.end(), lower.begin(), ::tolower);
    if (lower.empty()) return false;
    {
        lock_guard<mutex> lock(exclusions_mutex_);
        for (const auto& excl : user_exclusions_) if (excl == lower) return true;
        user_exclusions_.push_back(lower);
    }
    return saveExclusions();
}
bool Scanner::removeExclusion(const string& path) {
    string lower = path;
    transform(lower.begin(), lower.end(), lower.begin(), ::tolower);
    {
        lock_guard<mutex> lock(exclusions_mutex_);
        auto it = find(user_exclusions_.begin(), user_exclusions_.end(), lower);
        if (it == user_exclusions_.end()) return false;
        user_exclusions_.erase(it);
    }
    return saveExclusions();
}