#include "pch.h"
#include "sandbox_process.h"
#include "../logger/logger.h"
#include "../unicode_utils.h"
#include <userenv.h>
#include <aclapi.h>
#include <sddl.h>

#pragma comment(lib, "userenv.lib")
#pragma comment(lib, "advapi32.lib")

SandboxProcess::SandboxProcess() = default;
SandboxProcess::~SandboxProcess() {
    terminate();
    close();
    destroyAppContainer();
    if (!work_dir_.empty()) deleteDir(work_dir_);
}

SandboxLaunchResult SandboxProcess::launch(const SandboxConfig& cfg) {
    if (isRunning()) return {false, 0, "already_running"};
    if (cfg.executable_path.empty()) return {false, 0, "empty_path"};

    std::string pathUtf8 = unicode_utils::wide_to_utf8(cfg.executable_path);
    LS_LOG_INFO("Sandbox", "launch start: " + pathUtf8);
    FileKind kind = detectFileKind(cfg.executable_path);
    if (kind == FileKind::DLL) {
        LS_LOG_WARN("Sandbox", "DLL launch unsupported: " + pathUtf8);
        return {false, 0, "dll_entry_unknown"};
    }
    if (kind == FileKind::Unsupported) {
        LS_LOG_WARN("Sandbox", "unsupported file type: " + pathUtf8);
        return {false, 0, "unsupported_file_type"};
    }

    work_dir_ = createTempDir();
    if (work_dir_.empty()) {
        LS_LOG_ERROR("Sandbox", "createTempDir failed");
        return {false, 0, "create_workdir_failed"};
    }

    auto slashPos = cfg.executable_path.find_last_of(L"\\/");
    std::wstring fileName = (slashPos != std::wstring::npos) ? cfg.executable_path.substr(slashPos + 1) : cfg.executable_path;
    std::wstring copiedPath = work_dir_ + fileName;

    if (!CopyFileW(cfg.executable_path.c_str(), copiedPath.c_str(), FALSE)) {
        DWORD err = GetLastError();
        LS_LOG_ERROR("Sandbox", "CopyFileW failed: err=" + std::to_string(err) + " src=" + pathUtf8);
        close();
        return {false, 0, "copy_failed:" + winErrorToCode(err)};
    }
    LS_LOG_INFO("Sandbox", "file copied to workdir");

    std::wstring cmdLine;
    switch (kind) {
        case FileKind::PE:
            cmdLine = L"\"" + copiedPath + L"\"";
            break;
        case FileKind::BatchScript:
            cmdLine = L"cmd.exe /c \"" + copiedPath + L"\"";
            break;
        case FileKind::PowerShellScript:
            cmdLine = L"powershell.exe -NoProfile -ExecutionPolicy Bypass -File \"" + copiedPath + L"\"";
            break;
        case FileKind::WshScript:
            cmdLine = L"cscript.exe //Nologo \"" + copiedPath + L"\"";
            break;
        default:
            return {false, 0, "unsupported_file_type"};
    }

    if (!createAppContainer(app_container_name_, app_container_sid_)) {
        LS_LOG_ERROR("Sandbox", "createAppContainer failed: err=" + std::to_string(GetLastError()));
        close();
        return {false, 0, "app_container_profile_failed"};
    }
    LS_LOG_INFO("Sandbox", "AppContainer profile created");

    if (!grantWorkDirAccessToAppContainer(work_dir_, app_container_sid_)) {
        LS_LOG_ERROR("Sandbox", "grantWorkDirAccessToAppContainer failed");
        close();
        return {false, 0, "app_container_ace_failed"};
    }
    LS_LOG_INFO("Sandbox", "workdir ACE granted to AppContainer");

    if (!setupJobObject(cfg.memory_limit_mb)) {
        LS_LOG_ERROR("Sandbox", "setupJobObject failed");
        close();
        return {false, 0, "create_job_failed"};
    }

    SECURITY_CAPABILITIES sc{};
    sc.AppContainerSid = app_container_sid_;
    sc.Capabilities = nullptr;
    sc.CapabilityCount = 0;
    sc.Reserved = 0;

    STARTUPINFOEXW siex{};
    siex.StartupInfo.cb = sizeof(siex);
    siex.StartupInfo.dwFlags = STARTF_USESHOWWINDOW;
    siex.StartupInfo.wShowWindow = SW_SHOWMINNOACTIVE;

    SIZE_T attrListSize = 0;
    InitializeProcThreadAttributeList(nullptr, 1, 0, &attrListSize);
    std::vector<uint8_t> attrBuf(attrListSize);
    siex.lpAttributeList = reinterpret_cast<LPPROC_THREAD_ATTRIBUTE_LIST>(attrBuf.data());
    if (!InitializeProcThreadAttributeList(siex.lpAttributeList, 1, 0, &attrListSize)) {
        DWORD err = GetLastError();
        LS_LOG_ERROR("Sandbox", "InitializeProcThreadAttributeList failed: err=" + std::to_string(err));
        close();
        return {false, 0, "init_proc_thread_attr_failed"};
    }
    if (!UpdateProcThreadAttribute(siex.lpAttributeList, 0, PROC_THREAD_ATTRIBUTE_SECURITY_CAPABILITIES, &sc, sizeof(sc), nullptr, nullptr)) {
        DWORD err = GetLastError();
        DeleteProcThreadAttributeList(siex.lpAttributeList);
        LS_LOG_ERROR("Sandbox", "UpdateProcThreadAttribute failed: err=" + std::to_string(err));
        close();
        return {false, 0, "update_proc_thread_attr_failed"};
    }

    std::vector<wchar_t> cmdBuf(cmdLine.begin(), cmdLine.end());
    cmdBuf.push_back(L'\0');

    PROCESS_INFORMATION pi{};
    BOOL ok = CreateProcessW(nullptr, cmdBuf.data(), nullptr, nullptr, FALSE, CREATE_SUSPENDED | CREATE_NEW_CONSOLE | EXTENDED_STARTUPINFO_PRESENT, nullptr, work_dir_.c_str(), reinterpret_cast<LPSTARTUPINFOW>(&siex), &pi);
    DWORD createErr = ok ? 0 : GetLastError();
    DeleteProcThreadAttributeList(siex.lpAttributeList);

    if (!ok) {
        std::string code = winErrorToCode(createErr);
        LS_LOG_ERROR("Sandbox", "CreateProcessW failed: err=" + std::to_string(createErr) + " code=" + code);
        close();
        return {false, 0, code};
    }
    LS_LOG_INFO("Sandbox", "process created, pid=" + std::to_string(pi.dwProcessId));

    hProcess_ = pi.hProcess;
    hThread_ = pi.hThread;
    pid_ = pi.dwProcessId;

    if (!AssignProcessToJobObject(hJob_, hProcess_)) {
        DWORD err = GetLastError();
        TerminateProcess(hProcess_, 1);
        close();
        LS_LOG_ERROR("Sandbox", "AssignProcessToJobObject failed: err=" + std::to_string(err));
        return {false, 0, "assign_job_failed:" + winErrorToCode(err)};
    }

    ResumeThread(hThread_);
    LS_LOG_INFO("Sandbox", "launch success");
    return {true, pid_, ""};
}

bool SandboxProcess::createAppContainer(std::wstring& outName, PSID& outSid) {
    GUID guid{};
    if (CoCreateGuid(&guid) != S_OK) return false;
    wchar_t guidStr[40] = {};
    StringFromGUID2(guid, guidStr, 40);

    std::wstring cleanGuid;
    for (wchar_t c : std::wstring(guidStr)) { if (c != L'{' && c != L'}' && c != L'-') cleanGuid.push_back(c); }
    outName = L"MentoringProtector.Sandbox." + cleanGuid;

    PSID sid = nullptr;
    HRESULT hr = CreateAppContainerProfile(outName.c_str(), outName.c_str(), outName.c_str(), nullptr, 0, &sid);

    if (FAILED(hr)) {
        if (hr == HRESULT_FROM_WIN32(ERROR_ALREADY_EXISTS)) {
            if (SUCCEEDED(DeriveAppContainerSidFromAppContainerName(outName.c_str(), &sid)) && sid != nullptr) {
                outSid = sid;
                return true;
            }
        }
        return false;
    }
    outSid = sid;
    return true;
}

void SandboxProcess::destroyAppContainer() {
    if (app_container_sid_) {
        FreeSid(app_container_sid_);
        app_container_sid_ = nullptr;
    }
    if (!app_container_name_.empty()) {
        DeleteAppContainerProfile(app_container_name_.c_str());
        app_container_name_.clear();
    }
}

bool SandboxProcess::grantWorkDirAccessToAppContainer(const std::wstring& dir, PSID sid) {
    EXPLICIT_ACCESSW ea{};
    ea.grfAccessPermissions = GENERIC_READ | GENERIC_EXECUTE;
    ea.grfAccessMode = GRANT_ACCESS;
    ea.grfInheritance = SUB_CONTAINERS_AND_OBJECTS_INHERIT;
    ea.Trustee.TrusteeForm = TRUSTEE_IS_SID;
    ea.Trustee.TrusteeType = TRUSTEE_IS_WELL_KNOWN_GROUP;
    ea.Trustee.ptstrName = reinterpret_cast<LPWSTR>(sid);

    PACL oldDacl = nullptr, newDacl = nullptr;
    PSECURITY_DESCRIPTOR pSD = nullptr;

    DWORD r = GetNamedSecurityInfoW(const_cast<LPWSTR>(dir.c_str()), SE_FILE_OBJECT, DACL_SECURITY_INFORMATION, nullptr, nullptr, &oldDacl, nullptr, &pSD);
    if (r != ERROR_SUCCESS) return false;

    r = SetEntriesInAclW(1, &ea, oldDacl, &newDacl);
    if (r != ERROR_SUCCESS) {
        if (pSD) LocalFree(pSD);
        return false;
    }

    r = SetNamedSecurityInfoW(const_cast<LPWSTR>(dir.c_str()), SE_FILE_OBJECT, DACL_SECURITY_INFORMATION, nullptr, nullptr, newDacl, nullptr);

    if (pSD) LocalFree(pSD);
    if (newDacl) LocalFree(newDacl);
    return r == ERROR_SUCCESS;
}

bool SandboxProcess::setupJobObject(SIZE_T memMB) {
    hJob_ = CreateJobObjectW(nullptr, nullptr);
    if (!hJob_) return false;

    JOBOBJECT_EXTENDED_LIMIT_INFORMATION eli{};
    eli.BasicLimitInformation.LimitFlags = JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE | JOB_OBJECT_LIMIT_JOB_MEMORY | JOB_OBJECT_LIMIT_ACTIVE_PROCESS | JOB_OBJECT_LIMIT_DIE_ON_UNHANDLED_EXCEPTION;
    eli.JobMemoryLimit = memMB * 1024ULL * 1024ULL;
    eli.BasicLimitInformation.ActiveProcessLimit = 5;

    return SetInformationJobObject(hJob_, JobObjectExtendedLimitInformation, &eli, sizeof(eli)) != FALSE;
}

std::wstring SandboxProcess::createTempDir() {
    wchar_t tempPath[MAX_PATH] = {};
    if (!GetTempPathW(MAX_PATH, tempPath)) return {};

    GUID guid{};
    if (CoCreateGuid(&guid) != S_OK) return {};

    wchar_t guidStr[33] = {};
    swprintf_s(guidStr, L"%08X%04X%04X%02X%02X%02X%02X%02X%02X%02X%02X", guid.Data1, guid.Data2, guid.Data3, guid.Data4[0], guid.Data4[1], guid.Data4[2], guid.Data4[3], guid.Data4[4], guid.Data4[5], guid.Data4[6], guid.Data4[7]);
    std::wstring parent = std::wstring(tempPath) + L"MPSandbox\\";
    CreateDirectoryW(parent.c_str(), nullptr);
    std::wstring dir = parent + guidStr + L"\\";
    if (!CreateDirectoryW(dir.c_str(), nullptr)) return {};
    return dir;
}

void SandboxProcess::deleteDir(const std::wstring& dir) {
    WIN32_FIND_DATAW fd{};
    std::wstring pattern = dir + L"*";
    HANDLE hFind = FindFirstFileW(pattern.c_str(), &fd);
    if (hFind != INVALID_HANDLE_VALUE) {
        do {
            if (fd.cFileName[0] == L'.') continue;
            std::wstring full = dir + fd.cFileName;
            if (fd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) {
                deleteDir(full + L"\\");
            } else {
                SetFileAttributesW(full.c_str(), FILE_ATTRIBUTE_NORMAL);
                DeleteFileW(full.c_str());
            }
        } while (FindNextFileW(hFind, &fd));
        FindClose(hFind);
    }
    RemoveDirectoryW(dir.c_str());
}

bool SandboxProcess::isRunning() const {
    if (hProcess_ == INVALID_HANDLE_VALUE || !hProcess_) return false;
    DWORD code = 0;
    if (!GetExitCodeProcess(hProcess_, &code)) return false;
    return code == STILL_ACTIVE;
}

std::wstring SandboxProcess::toLowerExt(const std::wstring& path) {
    auto pos = path.rfind(L'.');
    if (pos == std::wstring::npos) return {};
    std::wstring ext = path.substr(pos);
    for (auto& c : ext) c = static_cast<wchar_t>(towlower(c));
    return ext;
}

FileKind SandboxProcess::detectFileKind(const std::wstring& path) {
    HANDLE h = CreateFileW(path.c_str(), GENERIC_READ, FILE_SHARE_READ, nullptr, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, nullptr);
    if (h != INVALID_HANDLE_VALUE) {
        uint8_t buf[0x40] = {};
        DWORD read = 0;
        ReadFile(h, buf, sizeof(buf), &read, nullptr);
        CloseHandle(h);

        if (read >= 2 && buf[0] == 'M' && buf[1] == 'Z') {
            if (read >= 0x40) {
                uint32_t peOffset = 0;
                memcpy(&peOffset, buf + 0x3C, sizeof(peOffset));
                if (peOffset < 0xD0) {
                    HANDLE h2 = CreateFileW(path.c_str(), GENERIC_READ, FILE_SHARE_READ, nullptr, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, nullptr);
                    if (h2 != INVALID_HANDLE_VALUE) {
                        uint8_t hdr[0xD0] = {};
                        DWORD r2 = 0;
                        ReadFile(h2, hdr, sizeof(hdr), &r2, nullptr);
                        CloseHandle(h2);
                        uint32_t charOfs = peOffset + 4 + 18;
                        if (r2 >= charOfs + 2) {
                            uint16_t characteristics = 0;
                            memcpy(&characteristics, hdr + charOfs, 2);
                            if (characteristics & 0x2000) return FileKind::DLL;
                        }
                    }
                }
            }
            return FileKind::PE;
        }
    }

    std::wstring ext = toLowerExt(path);
    if (ext == L".bat" || ext == L".cmd") return FileKind::BatchScript;
    if (ext == L".ps1") return FileKind::PowerShellScript;
    if (ext == L".vbs" || ext == L".js" || ext == L".wsf") return FileKind::WshScript;
    return FileKind::Unsupported;
}

std::string SandboxProcess::winErrorToCode(DWORD err) {
    switch (err) {
        case ERROR_FILE_NOT_FOUND:
        case ERROR_PATH_NOT_FOUND: return "file_not_found";
        case ERROR_ACCESS_DENIED: return "access_denied";
        case ERROR_BAD_EXE_FORMAT: return "bad_exe_format";
        case ERROR_NOT_ENOUGH_MEMORY:
        case ERROR_OUTOFMEMORY: return "out_of_memory";
        default: {
            char buf[32];
            snprintf(buf, sizeof(buf), "win_error_%lu", static_cast<unsigned long>(err));
            return buf;
        }
    }
}

void SandboxProcess::terminate() {
    if (hProcess_ != INVALID_HANDLE_VALUE && hProcess_) {
        TerminateProcess(hProcess_, 0);
        WaitForSingleObject(hProcess_, 3000);
    }
}

void SandboxProcess::close() {
    if (hThread_ != INVALID_HANDLE_VALUE && hThread_) {
        CloseHandle(hThread_);
        hThread_ = INVALID_HANDLE_VALUE;
    }
    if (hProcess_ != INVALID_HANDLE_VALUE && hProcess_) {
        CloseHandle(hProcess_);
        hProcess_ = INVALID_HANDLE_VALUE;
    }
    if (hJob_) {
        CloseHandle(hJob_);
        hJob_ = nullptr;
    }
    pid_ = 0;
}