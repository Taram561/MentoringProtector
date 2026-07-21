#include "pch.h"
#include "logger.h"
#include "../unicode_utils.h"
#include <aclapi.h>
#include <sddl.h>

using namespace std;

static wstring getLogBaseDir() {
    wchar_t path[MAX_PATH] = {};
    HMODULE hm = NULL;
    GetModuleHandleExW(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS | GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT, (LPCWSTR)&getLogBaseDir, &hm);
    GetModuleFileNameW(hm, path, MAX_PATH);
    wstring dllDir(path);
    auto pos = dllDir.find_last_of(L"\\/");
    if (pos != wstring::npos) dllDir = dllDir.substr(0, pos + 1);
    DWORD attr = GetFileAttributesW((dllDir + L"data").c_str());
    if (attr != INVALID_FILE_ATTRIBUTES && (attr & FILE_ATTRIBUTE_DIRECTORY)) return dllDir;
    return L"..\\";
}

Logger& Logger::instance() {
    static Logger inst;
    return inst;
}

Logger::Logger() {
    auto base = getLogBaseDir();
    auto logsDir = base + L"logs";
    CreateDirectoryW(logsDir.c_str(), nullptr);
    applyDirDacl(logsDir);
    logPath_ = logsDir + L"\\MentoringProtector.log";
    rotateIfNeeded(logPath_);
    log_file_.open(logPath_.c_str(), ios::app);
    applyFileDacl(logPath_);
    flush_thread_ = std::thread(&Logger::backgroundFlush, this);
    info("Logger", "=== MentoringProtector запущен ===");
}

Logger::~Logger() {
    info("Logger", "=== MentoringProtector завершен ===");
    running_ = false;
    flush_cv_.notify_one();
    if (flush_thread_.joinable()) flush_thread_.join();
    if (log_file_.is_open()) { log_file_.flush(); log_file_.close(); }
}

static constexpr int kRotateCheckInterval = 100;

void Logger::log(LogLevel level, const string& module, const string& message) {
    lock_guard<mutex> lock(mutex_);
    if (!log_file_.is_open()) return;
    log_file_ << "[" << getCurrentTime() << "] " << "[" << levelToString(level) << "] " << "[" << module << "] " << message << "\n";
    if (level >= LogLevel::Warning) log_file_.flush();
    if (++writeCount_ >= kRotateCheckInterval) { writeCount_ = 0; rotateIfNeeded(logPath_); reopenFile(); }
}

void Logger::backgroundFlush() {
    while (running_) {
        unique_lock<mutex> lk(mutex_);
        flush_cv_.wait_for(lk, chrono::seconds(1), [this] { return !running_.load(); });
        if (log_file_.is_open()) log_file_.flush();
    }
}

string Logger::getCurrentTime() const {
    SYSTEMTIME st;
    GetLocalTime(&st);
    char buf[32];
    sprintf_s(buf, "%04d-%02d-%02d %02d:%02d:%02d", st.wYear, st.wMonth, st.wDay, st.wHour, st.wMinute, st.wSecond);
    return buf;
}

string Logger::levelToString(LogLevel level) const {
    switch (level) {
    case LogLevel::Debug: return "DEBUG";
    case LogLevel::Info: return "INFO ";
    case LogLevel::Warning: return "WARN ";
    case LogLevel::Error: return "ERROR";
    default: return "?????";
    }
}

void Logger::rotateIfNeeded(const wstring& logPath) const {
    WIN32_FILE_ATTRIBUTE_DATA info{};
    if (!GetFileAttributesExW(logPath.c_str(), GetFileExInfoStandard, &info)) return;
    constexpr LONGLONG kMaxBytes = 5LL * 1024 * 1024;
    LONGLONG size = (static_cast<LONGLONG>(info.nFileSizeHigh) << 32) | info.nFileSizeLow;
    if (size < kMaxBytes) return;
    DeleteFileW((logPath + L".2").c_str());
    MoveFileW((logPath + L".1").c_str(), (logPath + L".2").c_str());
    MoveFileW(logPath.c_str(), (logPath + L".1").c_str());
}

void Logger::reopenFile() {
    if (log_file_.is_open()) { log_file_.flush(); log_file_.close(); }
    log_file_.open(logPath_.c_str(), ios::app);
    if (log_file_.is_open()) applyFileDacl(logPath_);
}

void Logger::applyFileDacl(const wstring& filePath) const {
    PSECURITY_DESCRIPTOR pSD = nullptr;
    if (!ConvertStringSecurityDescriptorToSecurityDescriptorW(L"D:P(A;;FA;;;OW)(A;;FA;;;SY)", SDDL_REVISION_1, &pSD, nullptr) || !pSD) return;
    BOOL present, defaulted; PACL pDacl = nullptr;
    GetSecurityDescriptorDacl(pSD, &present, &pDacl, &defaulted);
    SetNamedSecurityInfoW(const_cast<wchar_t*>(filePath.c_str()), SE_FILE_OBJECT, DACL_SECURITY_INFORMATION | PROTECTED_DACL_SECURITY_INFORMATION, nullptr, nullptr, pDacl, nullptr);
    LocalFree(pSD);
}

void Logger::applyDirDacl(const wstring& dirPath) const {
    PSECURITY_DESCRIPTOR pSD = nullptr;
    if (!ConvertStringSecurityDescriptorToSecurityDescriptorW(L"D:PAI(A;OICI;FA;;;OW)(A;OICI;FA;;;SY)", SDDL_REVISION_1, &pSD, nullptr) || !pSD) return;
    BOOL present, defaulted; PACL pDacl = nullptr;
    GetSecurityDescriptorDacl(pSD, &present, &pDacl, &defaulted);
    SetNamedSecurityInfoW(const_cast<wchar_t*>(dirPath.c_str()), SE_FILE_OBJECT, DACL_SECURITY_INFORMATION | PROTECTED_DACL_SECURITY_INFORMATION, nullptr, nullptr, pDacl, nullptr);
    LocalFree(pSD);
}
