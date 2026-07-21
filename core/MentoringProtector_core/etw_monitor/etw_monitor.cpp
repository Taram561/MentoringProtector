#include "pch.h"
#include "etw_monitor.h"
#include "../unicode_utils.h"
#include "../logger/logger.h"
#include <algorithm>
#include <sstream>
#include <future>

#pragma comment(lib, "tdh.lib")
#pragma comment(lib, "advapi32.lib")

using namespace std;

EtwMonitor* EtwMonitor::s_instance_ = nullptr;

EtwMonitor::EtwMonitor() {
    session_name_ = L"MentoringProtector_ETW_" + to_wstring(GetCurrentProcessId());

    auto addSafeDir = [this](const char* envVar, const string& suffix = "\\") {
        wchar_t buf[MAX_PATH]{};
        DWORD len = GetEnvironmentVariableW(unicode_utils::utf8_to_wide(envVar).c_str(), buf, MAX_PATH);
        if (len > 0 && len < MAX_PATH) {
            string dir = unicode_utils::wide_to_utf8(wstring(buf, len)) + suffix;
            transform(dir.begin(), dir.end(), dir.begin(), [](unsigned char c) { return tolower(c); });
            safe_dll_dirs_.push_back(dir);
        }
    };

    addSafeDir("SystemRoot", "\\system32\\");
    addSafeDir("SystemRoot", "\\syswow64\\");
    addSafeDir("SystemRoot", "\\winsxs\\");
    addSafeDir("ProgramFiles", "\\");
    addSafeDir("ProgramFiles(x86)", "\\");
    addSafeDir("ProgramData", "\\microsoft\\");
}

EtwMonitor::~EtwMonitor() { stop(); }

const unordered_set<string>& EtwMonitor::getSystemDllNames() {
    static const unordered_set<string> names = { "kernel32.dll", "kernelbase.dll", "ntdll.dll", "user32.dll", "gdi32.dll", "advapi32.dll", "shell32.dll", "ole32.dll", "oleaut32.dll", "msvcrt.dll", "ucrtbase.dll", "combase.dll", "rpcrt4.dll", "sechost.dll", "bcrypt.dll", "crypt32.dll", "ws2_32.dll", "winhttp.dll", "wininet.dll", "urlmon.dll", "shlwapi.dll", "version.dll", "dbghelp.dll", "dwmapi.dll", "uxtheme.dll", "dnsapi.dll", "iphlpapi.dll", "wtsapi32.dll", "netapi32.dll", "samcli.dll" };
    return names;
}

void EtwMonitor::setProcessCallback(ProcessCallback cb) { process_callback_ = move(cb); }

vector<DllInjectionAlert> EtwMonitor::getAndClearInjectionAlerts() {
    lock_guard<mutex> lock(injection_mutex_);
    vector<DllInjectionAlert> result = move(injection_alerts_);
    injection_alerts_.clear();
    return result;
}

string EtwMonitor::getStatus() const { return status_; }

bool EtwMonitor::start() {
    if (running_.load()) return false;
    for (int i = 0; i < 20 && thread_running_.load(); i++) this_thread::sleep_for(chrono::milliseconds(10));

    s_instance_ = this;

    {
        size_t bufSize = sizeof(EVENT_TRACE_PROPERTIES) + (session_name_.size() + 1) * sizeof(wchar_t);
        vector<BYTE> buf(bufSize, 0);
        auto* props = reinterpret_cast<EVENT_TRACE_PROPERTIES*>(buf.data());
        props->Wnode.BufferSize = static_cast<ULONG>(bufSize);
        ControlTraceW(0, session_name_.c_str(), props, EVENT_TRACE_CONTROL_STOP);
    }

    if (!createSession()) { LS_LOG_ERROR("EtwMonitor", "Не удалось создать ETW сессию: " + status_); return false; }
    if (!enableProvider()) { LS_LOG_ERROR("EtwMonitor", "Не удалось подписаться на провайдер"); cleanup(); return false; }
    if (!openConsumer()) { LS_LOG_ERROR("EtwMonitor", "Не удалось открыть consumer"); cleanup(); return false; }

    running_.store(true);
    trace_thread_ = thread(&EtwMonitor::traceLoop, this);
    status_ = "active";
    LS_LOG_INFO("EtwMonitor", "ETW сессия запущена: " + wstringToUtf8(session_name_));
    return true;
}

void EtwMonitor::stop() {
    if (!running_.load() && !thread_running_.load()) return;
    running_.store(false);
    cleanup();
    if (trace_thread_.joinable()) {
        auto future = async(launch::async, [this] { trace_thread_.join(); });
        if (future.wait_for(chrono::seconds(3)) == future_status::timeout) trace_thread_.detach();
    }
    if (s_instance_ == this) s_instance_ = nullptr;
    status_ = "not_started";
    LS_LOG_INFO("EtwMonitor", "ETW сессия остановлена");
}

bool EtwMonitor::createSession() {
    size_t bufSize = sizeof(EVENT_TRACE_PROPERTIES) + (session_name_.size() + 1) * sizeof(wchar_t);
    properties_buf_.resize(bufSize, 0);

    auto* props = reinterpret_cast<EVENT_TRACE_PROPERTIES*>(properties_buf_.data());
    props->Wnode.BufferSize = static_cast<ULONG>(bufSize);
    props->Wnode.Flags = WNODE_FLAG_TRACED_GUID;
    props->Wnode.ClientContext = 1;
    props->LogFileMode = EVENT_TRACE_REAL_TIME_MODE;
    props->LoggerNameOffset = sizeof(EVENT_TRACE_PROPERTIES);
    props->BufferSize = 64;
    props->MinimumBuffers = 4;
    props->MaximumBuffers = 16;
    props->FlushTimer = 1;

    ULONG result = StartTraceW(&session_handle_, session_name_.c_str(), props);

    if (result == ERROR_ACCESS_DENIED) {
        status_ = "failed_no_admin";
        LS_LOG_WARN("EtwMonitor", "Нет прав администратора для ETW. Будет использован polling.");
        return false;
    }

    if (result == ERROR_ALREADY_EXISTS) {
        LS_LOG_WARN("EtwMonitor", "Orphaned ETW сессия, повторная очистка...");
        ControlTraceW(0, session_name_.c_str(), props, EVENT_TRACE_CONTROL_STOP);
        this_thread::sleep_for(chrono::milliseconds(100));

        fill(properties_buf_.begin(), properties_buf_.end(), 0);
        props = reinterpret_cast<EVENT_TRACE_PROPERTIES*>(properties_buf_.data());
        props->Wnode.BufferSize = static_cast<ULONG>(bufSize);
        props->Wnode.Flags = WNODE_FLAG_TRACED_GUID;
        props->Wnode.ClientContext = 1;
        props->LogFileMode = EVENT_TRACE_REAL_TIME_MODE;
        props->LoggerNameOffset = sizeof(EVENT_TRACE_PROPERTIES);
        props->BufferSize = 64;
        props->MinimumBuffers = 4;
        props->MaximumBuffers = 16;
        props->FlushTimer = 1;
        result = StartTraceW(&session_handle_, session_name_.c_str(), props);
    }

    if (result != ERROR_SUCCESS) {
        status_ = "failed_start";
        LS_LOG_ERROR("EtwMonitor", "StartTraceW error: " + to_string(result));
        return false;
    }
    return true;
}

bool EtwMonitor::enableProvider() {
    const ULONGLONG keywords = 0x30;
    ULONG result = EnableTraceEx2(session_handle_, &KERNEL_PROCESS_GUID, EVENT_CONTROL_CODE_ENABLE_PROVIDER, TRACE_LEVEL_INFORMATION, keywords, 0, 0, nullptr);
    if (result != ERROR_SUCCESS) {
        status_ = "failed_provider";
        LS_LOG_ERROR("EtwMonitor", "EnableTraceEx2 error: " + to_string(result));
        return false;
    }
    return true;
}

bool EtwMonitor::openConsumer() {
    EVENT_TRACE_LOGFILEW logFile = {};
    logFile.LoggerName = const_cast<LPWSTR>(session_name_.c_str());
    logFile.ProcessTraceMode = PROCESS_TRACE_MODE_REAL_TIME | PROCESS_TRACE_MODE_EVENT_RECORD;
    logFile.EventRecordCallback = &EtwMonitor::eventRecordCallback;
    consumer_handle_ = OpenTraceW(&logFile);
    if (consumer_handle_ == INVALID_PROCESSTRACE_HANDLE) {
        status_ = "failed_consumer";
        LS_LOG_ERROR("EtwMonitor", "OpenTraceW error: " + to_string(GetLastError()));
        return false;
    }
    return true;
}

void EtwMonitor::traceLoop() {
    thread_running_.store(true);
    LS_LOG_INFO("EtwMonitor", "Trace thread запущен");
    ULONG result = ProcessTrace(&consumer_handle_, 1, nullptr, nullptr);
    if (result != ERROR_SUCCESS && result != ERROR_CANCELLED) LS_LOG_ERROR("EtwMonitor", "ProcessTrace завершился с ошибкой: " + to_string(result));
    thread_running_.store(false);
    LS_LOG_INFO("EtwMonitor", "Trace thread завершен");
}

void EtwMonitor::cleanup() {
    if (consumer_handle_ != INVALID_PROCESSTRACE_HANDLE) { CloseTrace(consumer_handle_); consumer_handle_ = INVALID_PROCESSTRACE_HANDLE; }
    if (session_handle_ != 0 && !properties_buf_.empty()) {
        auto* props = reinterpret_cast<EVENT_TRACE_PROPERTIES*>(properties_buf_.data());
        ZeroMemory(props, properties_buf_.size());
        props->Wnode.BufferSize = static_cast<ULONG>(properties_buf_.size());
        props->LoggerNameOffset = sizeof(EVENT_TRACE_PROPERTIES);
        ControlTraceW(session_handle_, nullptr, props, EVENT_TRACE_CONTROL_STOP);
        session_handle_ = 0;
    }
}

void WINAPI EtwMonitor::eventRecordCallback(PEVENT_RECORD pEvent) {
    if (!s_instance_ || !s_instance_->running_.load()) return;
    if (!pEvent) return;
    if (!IsEqualGUID(pEvent->EventHeader.ProviderId, KERNEL_PROCESS_GUID)) return;
    switch (pEvent->EventHeader.EventDescriptor.Id) {
    case 1: s_instance_->handleProcessStart(pEvent); break;
    case 2: s_instance_->handleProcessStop(pEvent); break;
    case 5: s_instance_->handleImageLoad(pEvent); break;
    default: break;
    }
}

wstring EtwMonitor::getEventStringProperty(PEVENT_RECORD pEvent, const wchar_t* propertyName) {
    if (!pEvent || !pEvent->UserData || pEvent->UserDataLength == 0) return L"";

    ULONG bufferSize = 0;
    ULONG status = TdhGetEventInformation(pEvent, 0, nullptr, nullptr, &bufferSize);
    if (status != ERROR_INSUFFICIENT_BUFFER || bufferSize == 0) return L"";

    vector<BYTE> buffer(bufferSize);
    auto* info = reinterpret_cast<TRACE_EVENT_INFO*>(buffer.data());
    status = TdhGetEventInformation(pEvent, 0, nullptr, info, &bufferSize);
    if (status != ERROR_SUCCESS) return L"";

    BYTE* userData = static_cast<BYTE*>(pEvent->UserData);
    USHORT userDataLen = pEvent->UserDataLength, offset = 0;

    for (ULONG i = 0; i < info->TopLevelPropertyCount; i++) {
        EVENT_PROPERTY_INFO& prop = info->EventPropertyInfoArray[i];
        const wchar_t* name = reinterpret_cast<const wchar_t*>(reinterpret_cast<BYTE*>(info) + prop.NameOffset);

        USHORT propSize = 0;
        if ((prop.Flags & PropertyParamLength) != 0) {
            if (wcscmp(name, propertyName) == 0 && offset < userDataLen) {
                const wchar_t* str = reinterpret_cast<const wchar_t*>(userData + offset);
                size_t maxChars = (userDataLen - offset) / sizeof(wchar_t), len = wcsnlen(str, maxChars);
                return wstring(str, len);
            }
            break;
        } else if (prop.length > 0) propSize = prop.length;
        else switch (prop.nonStructType.InType) {
            case TDH_INTYPE_UINT32: case TDH_INTYPE_INT32: propSize = 4; break;
            case TDH_INTYPE_UINT64: case TDH_INTYPE_INT64: case TDH_INTYPE_FILETIME: propSize = 8; break;
            case TDH_INTYPE_UINT16: case TDH_INTYPE_INT16: propSize = 2; break;
            case TDH_INTYPE_UINT8: case TDH_INTYPE_INT8: propSize = 1; break;
            case TDH_INTYPE_POINTER: case TDH_INTYPE_SIZET: propSize = (pEvent->EventHeader.Flags & EVENT_HEADER_FLAG_64_BIT_HEADER) ? 8 : 4; break;
            case TDH_INTYPE_UNICODESTRING: {
                if (offset >= userDataLen) break;
                const wchar_t* str = reinterpret_cast<const wchar_t*>(userData + offset);
                size_t maxChars = (userDataLen - offset) / sizeof(wchar_t), len = wcsnlen(str, maxChars);
                propSize = static_cast<USHORT>((len + 1) * sizeof(wchar_t));
                if (wcscmp(name, propertyName) == 0) return wstring(str, len);
                break;
            }
            case TDH_INTYPE_SID: {
                if (offset >= userDataLen) break;
                PISID pSid = reinterpret_cast<PISID>(userData + offset);
                if (offset + sizeof(SID) <= userDataLen) propSize = static_cast<USHORT>(FIELD_OFFSET(SID, SubAuthority) + pSid->SubAuthorityCount * sizeof(DWORD));
                break;
            }
            default: propSize = 0; break;
        }

        if (propSize == 0) break;
        if (wcscmp(name, propertyName) == 0 && prop.nonStructType.InType != TDH_INTYPE_UNICODESTRING) return L"";
        offset += propSize;
        if (offset > userDataLen) break;
    }
    return L"";
}

DWORD EtwMonitor::getEventUInt32Property(PEVENT_RECORD pEvent, const wchar_t* propertyName) {
    if (!pEvent || !pEvent->UserData || pEvent->UserDataLength == 0) return 0;

    ULONG bufferSize = 0;
    ULONG status = TdhGetEventInformation(pEvent, 0, nullptr, nullptr, &bufferSize);
    if (status != ERROR_INSUFFICIENT_BUFFER || bufferSize == 0) return 0;

    vector<BYTE> buffer(bufferSize);
    auto* info = reinterpret_cast<TRACE_EVENT_INFO*>(buffer.data());
    status = TdhGetEventInformation(pEvent, 0, nullptr, info, &bufferSize);
    if (status != ERROR_SUCCESS) return 0;

    BYTE* userData = static_cast<BYTE*>(pEvent->UserData);
    USHORT userDataLen = pEvent->UserDataLength, offset = 0;

    for (ULONG i = 0; i < info->TopLevelPropertyCount; i++) {
        EVENT_PROPERTY_INFO& prop = info->EventPropertyInfoArray[i];
        const wchar_t* name = reinterpret_cast<const wchar_t*>(reinterpret_cast<BYTE*>(info) + prop.NameOffset);

        USHORT propSize = 0;
        if (prop.length > 0) propSize = prop.length;
        else switch (prop.nonStructType.InType) {
            case TDH_INTYPE_UINT32: case TDH_INTYPE_INT32: propSize = 4; break;
            case TDH_INTYPE_UINT64: case TDH_INTYPE_INT64: case TDH_INTYPE_FILETIME: propSize = 8; break;
            case TDH_INTYPE_UINT16: case TDH_INTYPE_INT16: propSize = 2; break;
            case TDH_INTYPE_UINT8: case TDH_INTYPE_INT8: propSize = 1; break;
            case TDH_INTYPE_POINTER: case TDH_INTYPE_SIZET: propSize = (pEvent->EventHeader.Flags & EVENT_HEADER_FLAG_64_BIT_HEADER) ? 8 : 4; break;
            case TDH_INTYPE_UNICODESTRING: {
                if (offset >= userDataLen) break;
                const wchar_t* str = reinterpret_cast<const wchar_t*>(userData + offset);
                size_t maxChars = (userDataLen - offset) / sizeof(wchar_t), len = wcsnlen(str, maxChars);
                propSize = static_cast<USHORT>((len + 1) * sizeof(wchar_t));
                break;
            }
            case TDH_INTYPE_SID: {
                if (offset >= sizeof(SID) || offset >= userDataLen) break;
                PISID pSid = reinterpret_cast<PISID>(userData + offset);
                if (offset + sizeof(SID) <= userDataLen) propSize = static_cast<USHORT>(FIELD_OFFSET(SID, SubAuthority) + pSid->SubAuthorityCount * sizeof(DWORD));
                break;
            }
            default: propSize = 0; break;
        }

        if (propSize == 0) break;
        if (wcscmp(name, propertyName) == 0) {
            if (propSize == 4 && offset + 4 <= userDataLen) return *reinterpret_cast<DWORD*>(userData + offset);
            return 0;
        }
        offset += propSize;
        if (offset > userDataLen) break;
    }
    return 0;
}

void EtwMonitor::handleProcessStart(PEVENT_RECORD pEvent) {
    EtwProcessEvent evt;
    evt.is_start = true;
    evt.timestamp = getCurrentTime();
    evt.pid = getEventUInt32Property(pEvent, L"ProcessID");
    evt.parent_pid = getEventUInt32Property(pEvent, L"ParentProcessID");
    wstring imageName = getEventStringProperty(pEvent, L"ImageName"), cmdLine = getEventStringProperty(pEvent, L"CommandLine");
    evt.image_path = wstringToUtf8(imageName);
    evt.command_line = wstringToUtf8(cmdLine);
    if (evt.pid <= 4) return;
    if (process_callback_) process_callback_(evt);
}

void EtwMonitor::handleProcessStop(PEVENT_RECORD pEvent) {
    EtwProcessEvent evt;
    evt.is_start = false;
    evt.timestamp = getCurrentTime();
    evt.pid = getEventUInt32Property(pEvent, L"ProcessID");
    evt.image_path = wstringToUtf8(getEventStringProperty(pEvent, L"ImageName"));
    if (evt.pid <= 4) return;
    if (process_callback_) process_callback_(evt);
}

void EtwMonitor::handleImageLoad(PEVENT_RECORD pEvent) {
    DWORD pid = getEventUInt32Property(pEvent, L"ProcessID");
    wstring imageName = getEventStringProperty(pEvent, L"ImageName");
    if (pid <= 4 || imageName.empty()) return;
    string dllPath = wstringToUtf8(imageName);
    string lower = dllPath;
    transform(lower.begin(), lower.end(), lower.begin(), [](unsigned char c) { return tolower(c); });
    if (lower.size() >= 4 && lower.substr(lower.size() - 4) == ".dll") analyzeDllLoad(pid, dllPath);
}

void EtwMonitor::analyzeDllLoad(DWORD pid, const string& dllPath) {
    if (!isSuspiciousDll(dllPath)) return;

    DllInjectionAlert alert;
    alert.pid = pid;
    alert.dll_path = dllPath;
    alert.detected_at = getCurrentTime();
    alert.process_name = getProcessNameByPid(pid);
    alert.suspicion_score = 0;

    string dllLower = dllPath;
    transform(dllLower.begin(), dllLower.end(), dllLower.begin(), [](unsigned char c) { return tolower(c); });

    size_t lastSlash = dllLower.find_last_of("\\/");
    string dllName = (lastSlash != string::npos) ? dllLower.substr(lastSlash + 1) : dllLower, dllDir = (lastSlash != string::npos) ? dllLower.substr(0, lastSlash + 1) : "";

    if (dllLower.find("\\temp\\") != string::npos || dllLower.find("\\tmp\\") != string::npos) { alert.reason = "DLL loaded from temp directory"; alert.suspicion_score += 40; }

    if (dllLower.find("\\downloads\\") != string::npos || dllLower.find("\\desktop\\") != string::npos || dllLower.find("\\documents\\") != string::npos) {
        if (alert.reason.empty()) alert.reason = "DLL loaded from user directory";
        alert.suspicion_score += 35;
    }

    if (isDllHijacking(dllName, dllDir)) { alert.reason = "DLL hijacking: system DLL name (" + dllName + ") loaded from non-system path"; alert.suspicion_score += 60; }

    if (alert.suspicion_score >= 35) {
        lock_guard<mutex> lock(injection_mutex_);
        if (injection_alerts_.size() < 200) { LS_LOG_WARN("EtwMonitor", "DLL injection suspect: PID=" + to_string(pid) + " DLL=" + dllPath + " score=" + to_string(alert.suspicion_score)); injection_alerts_.push_back(move(alert)); }
    }
}

bool EtwMonitor::isSuspiciousDll(const string& dllPath) const {
    string lower = dllPath;
    transform(lower.begin(), lower.end(), lower.begin(), [](unsigned char c) { return tolower(c); });
    for (const auto& safeDir : safe_dll_dirs_) if (lower.find(safeDir) == 0) return false;
    if (lower.find("\\device\\") == 0) return false;
    return true;
}

bool EtwMonitor::isDllHijacking(const string& dllName, const string& dllDir) const {
    const auto& sysNames = getSystemDllNames();
    if (sysNames.find(dllName) == sysNames.end()) return false;
    for (const auto& safeDir : safe_dll_dirs_) if (dllDir.find(safeDir) == 0) return false;
    return true;
}

string EtwMonitor::getProcessNameByPid(DWORD pid) const {
    HANDLE hProcess = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, FALSE, pid);
    if (!hProcess) return "unknown";
    wchar_t path[MAX_PATH] = {};
    DWORD size = MAX_PATH;
    BOOL ok = QueryFullProcessImageNameW(hProcess, 0, path, &size);
    CloseHandle(hProcess);
    if (!ok) return "unknown";
    string fullPath = unicode_utils::wide_to_utf8(wstring(path, size));
    size_t slash = fullPath.find_last_of("\\/");
    return (slash != string::npos) ? fullPath.substr(slash + 1) : fullPath;
}

string EtwMonitor::wstringToUtf8(const wstring& wstr) const {
    if (wstr.empty()) return "";
    int size = WideCharToMultiByte(CP_UTF8, 0, wstr.c_str(), static_cast<int>(wstr.size()), nullptr, 0, nullptr, nullptr);
    if (size <= 0) return "";
    string result(size, '\0');
    WideCharToMultiByte(CP_UTF8, 0, wstr.c_str(), static_cast<int>(wstr.size()), &result[0], size, nullptr, nullptr);
    return result;
}

string EtwMonitor::getCurrentTime() const {
    SYSTEMTIME st;
    GetLocalTime(&st);
    char buf[32];
    sprintf_s(buf, "%04d-%02d-%02d %02d:%02d:%02d", st.wYear, st.wMonth, st.wDay, st.wHour, st.wMinute, st.wSecond);
    return buf;
}
