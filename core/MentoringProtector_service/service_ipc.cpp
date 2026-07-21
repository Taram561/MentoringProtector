#include "service_ipc.h"
#include "service_pipe_protocol.h"
#include "../MentoringProtector_core/json_utils.h"
#include <sddl.h>
#include <cstdio>
#include <vector>

#pragma comment(lib, "advapi32.lib")

namespace {
// kPipeName - единая константа из service_pipe_protocol.h (F-2 self-audit): сервер
// и клиент (mp_helper, core.dll) обязаны указывать на один и тот же пайп, иначе
// расхождение тихо ломает IPC без ошибки компиляции.
using service_pipe::kPipeName;
constexpr DWORD kBufSize = 8192;

// SD: SYSTEM + Administrators - полный доступ; Authenticated Users - чтение/запись
// (чтобы non-elevated GUI мог подключиться без UAC и читать статус). DACL сама
// не различает read-only/привилегированные команды - это разделение делает
// ClientIsElevated() в acceptLoop() (DEC-057): DACL даёт ДОСТУП к пайпу,
// impersonation-проверка даёт ПРАВО на конкретную команду.
constexpr wchar_t kPipeSddl[] = L"D:(A;;GA;;;SY)(A;;GA;;;BA)(A;;GRGW;;;AU)";

// Проверяет импersonированного клиента пайпа (caller обязан вызвать это МЕЖДУ
// ImpersonateNamedPipeClient() и RevertToSelf()): true, если клиент имеет High
// integrity level либо состоит в локальной группе Administrators. Используется
// для гейтинга привилегированных команд (DEC-057) - same-user процесс БЕЗ admin/
// High IL не должен мочь выключить хостинг защиты (confused-deputy/AV-off-switch).
bool ClientIsElevated() {
    HANDLE token = nullptr;
    if (!OpenThreadToken(GetCurrentThread(), TOKEN_QUERY, TRUE, &token)) return false;

    bool elevated = false;

    DWORD len = 0;
    GetTokenInformation(token, TokenIntegrityLevel, nullptr, 0, &len);
    if (len > 0) {
        std::vector<BYTE> buf(len);
        if (GetTokenInformation(token, TokenIntegrityLevel, buf.data(), len, &len)) {
            auto* label = reinterpret_cast<TOKEN_MANDATORY_LABEL*>(buf.data());
            DWORD subAuthCount = *GetSidSubAuthorityCount(label->Label.Sid);
            DWORD rid = *GetSidSubAuthority(label->Label.Sid, subAuthCount - 1);
            if (rid >= SECURITY_MANDATORY_HIGH_RID) elevated = true;
        }
    }

    if (!elevated) {
        // Defense-in-depth: членство в Administrators даже без High IL (напр. UAC
        // отключён политикой). CheckTokenMembership с hToken=NULL берёт токен
        // ИМПЕРСОНАЦИИ текущего потока (документированный паттерн для named-pipe
        // серверов) - явный token из OpenThreadToken здесь не годится для этого вызова.
        BOOL isMember = FALSE;
        PSID adminSid = nullptr;
        SID_IDENTIFIER_AUTHORITY ntAuth = SECURITY_NT_AUTHORITY;
        if (AllocateAndInitializeSid(&ntAuth, 2, SECURITY_BUILTIN_DOMAIN_RID,
                                      DOMAIN_ALIAS_RID_ADMINS, 0, 0, 0, 0, 0, 0, &adminSid)) {
            if (CheckTokenMembership(nullptr, adminSid, &isMember) && isMember) elevated = true;
            FreeSid(adminSid);
        }
    }

    CloseHandle(token);
    return elevated;
}
} // namespace

NamedPipeServer::~NamedPipeServer() { stop(); }

bool NamedPipeServer::start() {
    if (running_.exchange(true)) return false;  // уже запущен
    stopEvent_ = CreateEventW(nullptr, TRUE, FALSE, nullptr);  // manual-reset
    if (!stopEvent_) { running_ = false; return false; }

    if (!ConvertStringSecurityDescriptorToSecurityDescriptorW(
            kPipeSddl, SDDL_REVISION_1, &securityDescriptor_, nullptr)) {
        CloseHandle(stopEvent_); stopEvent_ = nullptr;
        running_ = false;
        return false;  // не смогли защитить pipe -> fail-closed (IPC не поднимаем)
    }

    threads_.reserve(kWorkerCount);
    for (int i = 0; i < kWorkerCount; ++i) {
        threads_.emplace_back(&NamedPipeServer::acceptLoop, this);
    }
    return true;
}

void NamedPipeServer::stop() {
    running_.store(false);
    if (stopEvent_) SetEvent(stopEvent_);
    for (auto& t : threads_) {
        if (t.joinable()) t.join();
    }
    threads_.clear();
    if (stopEvent_) { CloseHandle(stopEvent_); stopEvent_ = nullptr; }
    if (securityDescriptor_) { LocalFree(securityDescriptor_); securityDescriptor_ = nullptr; }
}

void NamedPipeServer::acceptLoop() {
    SECURITY_ATTRIBUTES sa{};
    sa.nLength = sizeof(sa);
    sa.bInheritHandle = FALSE;
    sa.lpSecurityDescriptor = securityDescriptor_;  // общий, создан один раз в start()

    HANDLE ioEvent = CreateEventW(nullptr, TRUE, FALSE, nullptr);  // manual-reset для overlapped
    if (!ioEvent) return;

    while (running_.load()) {
        // A2: ровно один инстанс за всё время жизни службы получает FIRST_PIPE_INSTANCE
        // (анти-сквоттинг имени) - атомарный claim вместо локального bool, т.к. инстансы
        // создают НЕСКОЛЬКО потоков конкурентно.
        bool claimFirst = !firstInstanceClaimed_.exchange(true);
        DWORD openMode = PIPE_ACCESS_DUPLEX | FILE_FLAG_OVERLAPPED;
        if (claimFirst) openMode |= FILE_FLAG_FIRST_PIPE_INSTANCE;
        HANDLE pipe = CreateNamedPipeW(
            kPipeName,
            openMode,
            PIPE_TYPE_MESSAGE | PIPE_READMODE_MESSAGE | PIPE_WAIT,
            PIPE_UNLIMITED_INSTANCES, kBufSize, kBufSize, 0, &sa);
        if (pipe == INVALID_HANDLE_VALUE) {
            if (claimFirst) {
                // Сквоттинг на ПЕРВОМ инстансе - кто-то уже держит это имя пайпа.
                // Угроза касается всей службы, не только этого потока -> fail-closed
                // глобально (сигналим всем worker-потокам остановиться).
                running_.store(false);
                if (stopEvent_) SetEvent(stopEvent_);
            }
            break;  // этот поток больше не служит
        }

        // --- Ждём подключения клиента (overlapped) с возможностью прерывания stop-event ---
        OVERLAPPED ov{};
        ResetEvent(ioEvent);
        ov.hEvent = ioEvent;

        BOOL connected = ConnectNamedPipe(pipe, &ov);
        DWORD err = GetLastError();
        if (!connected && err == ERROR_IO_PENDING) {
            HANDLE waits[2] = { stopEvent_, ioEvent };
            DWORD w = WaitForMultipleObjects(2, waits, FALSE, INFINITE);
            if (w == WAIT_OBJECT_0) {          // сигнал остановки
                CancelIo(pipe);
                CloseHandle(pipe);
                break;
            }
            DWORD got = 0;
            if (!GetOverlappedResult(pipe, &ov, &got, FALSE)) { CloseHandle(pipe); continue; }
        } else if (!connected && err != ERROR_PIPE_CONNECTED) {
            CloseHandle(pipe);
            continue;
        }

        // --- Читаем запрос (overlapped, с таймаутом и прерыванием по stop) ---
        char buf[kBufSize];
        OVERLAPPED rov{};
        ResetEvent(ioEvent);
        rov.hEvent = ioEvent;
        DWORD readBytes = 0;
        BOOL rok = ReadFile(pipe, buf, kBufSize - 1, &readBytes, &rov);
        if (!rok && GetLastError() == ERROR_IO_PENDING) {
            HANDLE waits[2] = { stopEvent_, ioEvent };
            DWORD w = WaitForMultipleObjects(2, waits, FALSE, 3000);
            if (w == WAIT_OBJECT_0) { CancelIo(pipe); CloseHandle(pipe); break; }
            if (w != WAIT_OBJECT_0 + 1) { CancelIo(pipe); DisconnectNamedPipe(pipe); CloseHandle(pipe); continue; }
            rok = GetOverlappedResult(pipe, &rov, &readBytes, FALSE);
        }

        if (rok && readBytes > 0) {
            const std::string reqStr(buf, readBytes);
            std::string resp;

            // DEC-057: команды, меняющие хостинг, требуют elevated-клиента. Гейт
            // живёт здесь (не в handleRequest), т.к. только здесь есть HANDLE пайпа,
            // нужный ImpersonateNamedPipeClient. Дешёвая повторная экстракция "cmd" -
            // handleRequest() её делает снова для диспетчеризации - сознательная
            // плата за чистое разделение "проверка прав" / "бизнес-логика".
            const std::string cmd = json_utils::extractString(reqStr, "cmd");
            if (NamedPipeServer::isPrivilegedCmd(cmd)) {
                bool authorized = false;
                if (ImpersonateNamedPipeClient(pipe)) {
                    authorized = ClientIsElevated();
                    RevertToSelf();
                }
                resp = authorized ? handleRequest(reqStr)
                                   : std::string("{\"ok\":false,\"error\":\"requires_elevation\"}");
            } else {
                resp = handleRequest(reqStr);
            }

            OVERLAPPED wov{};
            ResetEvent(ioEvent);
            wov.hEvent = ioEvent;
            DWORD written = 0;
            BOOL wok = WriteFile(pipe, resp.data(), static_cast<DWORD>(resp.size()), &written, &wov);
            if (!wok && GetLastError() == ERROR_IO_PENDING) {
                if (WaitForSingleObject(ioEvent, 3000) == WAIT_OBJECT_0)
                    GetOverlappedResult(pipe, &wov, &written, FALSE);
                else
                    CancelIo(pipe);
            }
            FlushFileBuffers(pipe);
        }

        DisconnectNamedPipe(pipe);
        CloseHandle(pipe);
    }

    CloseHandle(ioEvent);
    // securityDescriptor_ общий для всех потоков - освобождается централизованно в stop().
}

std::string NamedPipeServer::handleRequest(const std::string& req) const {
    // Строгий JSON-диспетчер: извлекаем точное значение поля "cmd".
    // Substring-матч недопустим: payload-данные могут содержать имена команд.
    // Привилегированные команды (см. isPrivilegedCmd) НЕ проверяют права здесь -
    // это уже сделал caller (acceptLoop, DEC-057) до вызова handleRequest.
    const std::string cmd = json_utils::extractString(req, "cmd");

    if (cmd == "ping") {
        char out[160];
        _snprintf_s(out, sizeof(out), _TRUNCATE,
                    "{\"ok\":true,\"service\":\"MentoringProtector\",\"pid\":%lu}",
                    static_cast<unsigned long>(GetCurrentProcessId()));
        return std::string(out);
    }
    if (cmd == "status") {
        if (!control_) return "{\"ok\":false,\"error\":\"unavailable\"}";
        char out[96];
        _snprintf_s(out, sizeof(out), _TRUNCATE,
                    "{\"ok\":true,\"realtime\":%s,\"web\":%s}",
                    control_->realtimeHosting() ? "true" : "false",
                    control_->webHosting()      ? "true" : "false");
        return std::string(out);
    }
    if (cmd == "realtime_start") {
        if (!control_) return "{\"ok\":false,\"error\":\"unavailable\"}";
        return control_->startRealtime() ? "{\"ok\":true,\"hosting\":true}"
                                          : "{\"ok\":false,\"error\":\"start_failed\"}";
    }
    if (cmd == "realtime_stop") {
        if (!control_) return "{\"ok\":false,\"error\":\"unavailable\"}";
        control_->stopRealtime();
        return "{\"ok\":true,\"hosting\":false}";
    }
    if (cmd == "web_start") {
        if (!control_) return "{\"ok\":false,\"error\":\"unavailable\"}";
        return control_->startWeb() ? "{\"ok\":true,\"hosting\":true}"
                                     : "{\"ok\":false,\"error\":\"start_failed\"}";
    }
    if (cmd == "web_stop") {
        if (!control_) return "{\"ok\":false,\"error\":\"unavailable\"}";
        control_->stopWeb();
        return "{\"ok\":true,\"hosting\":false}";
    }
    if (cmd.empty()) {
        return "{\"ok\":false,\"error\":\"invalid_json\"}";
    }
    return "{\"ok\":false,\"error\":\"unknown_cmd\"}";
}

bool NamedPipeServer::isPrivilegedCmd(const std::string& cmd) {
    return cmd == "realtime_start" || cmd == "realtime_stop" ||
           cmd == "web_start"      || cmd == "web_stop";
}
