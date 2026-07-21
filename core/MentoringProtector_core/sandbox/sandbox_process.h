#pragma once
#include "pch.h"

struct SandboxConfig {
    std::wstring executable_path;
    int timeout_seconds = 60;
    SIZE_T memory_limit_mb = 256;
};
struct SandboxLaunchResult {
    bool success = false;
    DWORD pid = 0;
    std::string error_code;
};

enum class FileKind { PE, DLL, BatchScript, PowerShellScript, WshScript, Unsupported };

class SandboxProcess {
public:
    SandboxProcess();
    ~SandboxProcess();
    SandboxProcess(const SandboxProcess&) = delete;
    SandboxProcess& operator=(const SandboxProcess&) = delete;

    SandboxLaunchResult launch(const SandboxConfig& cfg);
    void terminate();
    bool isRunning() const;
    DWORD getPid() const { return pid_; }

    static FileKind detectFileKind(const std::wstring& path);
    static std::wstring toLowerExt(const std::wstring& path);
    static std::string winErrorToCode(DWORD err);

private:
    HANDLE hProcess_ = INVALID_HANDLE_VALUE;
    HANDLE hThread_ = INVALID_HANDLE_VALUE;
    HANDLE hJob_ = nullptr;
    DWORD pid_ = 0;
    std::wstring work_dir_;
    PSID app_container_sid_ = nullptr;
    std::wstring app_container_name_;

    bool setupJobObject(SIZE_T memMB);
    std::wstring createTempDir();
    void deleteDir(const std::wstring& dir);
    void close();

    bool createAppContainer(std::wstring& outName, PSID& outSid);
    void destroyAppContainer();
    bool grantWorkDirAccessToAppContainer(const std::wstring& dir, PSID sid);
};