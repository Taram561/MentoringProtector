#include "service_pipe_protocol.h"
#include <aclapi.h>
#include <string>

namespace service_pipe {

namespace {

void LogFailure(const std::string& reason) {
    wchar_t exe[MAX_PATH] = {};
    if (!GetModuleFileNameW(nullptr, exe, MAX_PATH)) return;
    std::wstring path(exe);
    auto pos = path.find_last_of(L"\\/");
    if (pos == std::wstring::npos) return;
    path = path.substr(0, pos + 1) + L"service_pipe_send_error.log";
    HANDLE h = CreateFileW(path.c_str(), FILE_APPEND_DATA, FILE_SHARE_READ, nullptr, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, nullptr);
    if (h == INVALID_HANDLE_VALUE) return;
    SetFilePointer(h, 0, nullptr, FILE_END);
    std::string line = reason + "\r\n";
    WriteFile(h, line.c_str(), static_cast<DWORD>(line.size()), nullptr, nullptr);
    CloseHandle(h);
}

bool OwnerIsTrusted(HANDLE pipe) {
    PSID owner = nullptr;
    PSECURITY_DESCRIPTOR pSD = nullptr;
    if (GetSecurityInfo(pipe, SE_KERNEL_OBJECT, OWNER_SECURITY_INFORMATION,
                        &owner, nullptr, nullptr, nullptr, &pSD) != ERROR_SUCCESS) {
        return false;
    }
    bool trusted = false;
    if (owner && IsValidSid(owner)) {
        BYTE wk[SECURITY_MAX_SID_SIZE];
        DWORD wkSz = sizeof(wk);
        if (CreateWellKnownSid(WinLocalSystemSid, nullptr, wk, &wkSz) && EqualSid(owner, reinterpret_cast<PSID>(wk))) {
            trusted = true;
        } else {
            wkSz = sizeof(wk);
            if (CreateWellKnownSid(WinBuiltinAdministratorsSid, nullptr, wk, &wkSz) && EqualSid(owner, reinterpret_cast<PSID>(wk))) trusted = true;
        }
    }
    if (pSD) LocalFree(pSD);
    return trusted;
}

}

bool send(const std::string& reqJson, std::string& respOut) {
    constexpr DWORD kTimeoutMs = 400;

    auto openPipe = [&]() -> HANDLE {return CreateFileW(kPipeName, GENERIC_READ | GENERIC_WRITE, 0, nullptr, OPEN_EXISTING, FILE_FLAG_OVERLAPPED, nullptr);};

    HANDLE h = INVALID_HANDLE_VALUE;
    DWORD lastErr = 0;
    constexpr int kMaxAttempts = 4;
    for (int attempt = 0; attempt < kMaxAttempts; ++attempt) {
        h = openPipe();
        if (h != INVALID_HANDLE_VALUE) break;
        lastErr = GetLastError();
        if (lastErr != ERROR_PIPE_BUSY) break;
        WaitNamedPipeW(kPipeName, kTimeoutMs / kMaxAttempts);
    }
    if (h == INVALID_HANDLE_VALUE) {
        LogFailure("CreateFileW failed after retries, GetLastError=" + std::to_string(lastErr));
        return false;
    }

    if (!OwnerIsTrusted(h)) {
        LogFailure("OwnerIsTrusted=false - pipe owner is not SYSTEM/Administrators");
        CloseHandle(h);
        return false;
    }

    DWORD mode = PIPE_READMODE_MESSAGE;
    SetNamedPipeHandleState(h, &mode, nullptr, nullptr);

    HANDLE ioEvent = CreateEventW(nullptr, TRUE, FALSE, nullptr);
    if (!ioEvent) {
        LogFailure("CreateEventW failed, GetLastError=" + std::to_string(GetLastError()));
        CloseHandle(h);
        return false;
    }

    bool success = false;
    do {
        DWORD written = 0;
        OVERLAPPED wov{};
        wov.hEvent = ioEvent;
        if (!WriteFile(h, reqJson.data(), static_cast<DWORD>(reqJson.size()), &written, &wov)) {
            if (GetLastError() != ERROR_IO_PENDING) {
                LogFailure("WriteFile failed, GetLastError=" + std::to_string(GetLastError()));
                break;
            }
            if (WaitForSingleObject(ioEvent, kTimeoutMs) != WAIT_OBJECT_0) {
                LogFailure("WriteFile timed out after " + std::to_string(kTimeoutMs) + "ms");
                CancelIo(h); break;
            }
            if (!GetOverlappedResult(h, &wov, &written, FALSE)) {
                LogFailure("GetOverlappedResult(write) failed, GetLastError=" + std::to_string(GetLastError()));
                break;
            }
        }

        char buf[8192] = {};
        DWORD readBytes = 0;
        OVERLAPPED rov{};
        ResetEvent(ioEvent);
        rov.hEvent = ioEvent;
        BOOL rok = ReadFile(h, buf, sizeof(buf) - 1, &readBytes, &rov);
        if (!rok) {
            if (GetLastError() != ERROR_IO_PENDING) {
                LogFailure("ReadFile failed, GetLastError=" + std::to_string(GetLastError()));
                break;
            }
            if (WaitForSingleObject(ioEvent, kTimeoutMs) != WAIT_OBJECT_0) {
                LogFailure("ReadFile timed out after " + std::to_string(kTimeoutMs) + "ms");
                CancelIo(h); break;
            }
            rok = GetOverlappedResult(h, &rov, &readBytes, FALSE);
        }
        if (rok && readBytes > 0) {
            respOut.assign(buf, readBytes);
            success = true;
        } else if (!rok) LogFailure("GetOverlappedResult(read) failed, GetLastError=" + std::to_string(GetLastError()));
         else LogFailure("ReadFile succeeded but readBytes=0");
    } while (false);

    CloseHandle(ioEvent);
    CloseHandle(h);
    return success;
}

}