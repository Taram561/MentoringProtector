#pragma once
#include "pch.h"
#include <evntrace.h>
#include <evntcons.h>
#include <tdh.h>
#include <functional>
#include <unordered_set>

static const GUID KERNEL_PROCESS_GUID = {0x22FB2CD6, 0x0E7B, 0x422B, { 0xA0, 0xC7, 0x2F, 0xAD, 0x1F, 0xD0, 0xE7, 0x16 }};

struct EtwProcessEvent {
    DWORD pid = 0, parent_pid = 0;
    std::string image_path, command_line, timestamp;
    bool is_start = false;
};

struct DllInjectionAlert {
    DWORD pid = 0;
    std::string process_name, dll_path, reason, detected_at;
    int suspicion_score = 0;
};

class EtwMonitor {
public:
    using ProcessCallback = std::function<void(const EtwProcessEvent&)>;

    EtwMonitor();
    ~EtwMonitor();
    EtwMonitor(const EtwMonitor&) = delete;
    EtwMonitor& operator=(const EtwMonitor&) = delete;

    bool start();
    void stop();
    bool isRunning() const { return running_.load(); }
    void setProcessCallback(ProcessCallback cb);
    std::vector<DllInjectionAlert> getAndClearInjectionAlerts();
    std::string getStatus() const;

private:
    std::atomic<bool> running_{false}, thread_running_{false};
    std::thread trace_thread_;
    TRACEHANDLE session_handle_ = 0, consumer_handle_ = INVALID_PROCESSTRACE_HANDLE;
    std::wstring session_name_;
    std::vector<BYTE> properties_buf_;
    ProcessCallback process_callback_;
    std::vector<DllInjectionAlert> injection_alerts_;
    std::mutex injection_mutex_;
    std::vector<std::string> safe_dll_dirs_;
    static const std::unordered_set<std::string>& getSystemDllNames();
    std::string status_ = "not_started";
    static EtwMonitor* s_instance_;
    static void WINAPI eventRecordCallback(PEVENT_RECORD pEvent);

    void handleProcessStart(PEVENT_RECORD pEvent);
    void handleProcessStop(PEVENT_RECORD pEvent);
    void handleImageLoad(PEVENT_RECORD pEvent);
    void analyzeDllLoad(DWORD pid, const std::string& dllPath);
    bool isSuspiciousDll(const std::string& dllPath) const;
    bool isDllHijacking(const std::string& dllName, const std::string& dllDir) const;
    bool createSession();
    bool enableProvider();
    bool openConsumer();
    void traceLoop();
    void cleanup();
    std::string getCurrentTime() const;
    std::string wstringToUtf8(const std::wstring& wstr) const;
    std::string getProcessNameByPid(DWORD pid) const;
    std::wstring getEventStringProperty(PEVENT_RECORD pEvent, const wchar_t* propertyName);
    DWORD getEventUInt32Property(PEVENT_RECORD pEvent, const wchar_t* propertyName);
};
