// MentoringProtector Windows Service - Stage S1 (skeleton).
//
// Phase H / H0-1 (DEC-055): фундамент самозащиты. Служба под LocalSystem авто-стартует
// и хостит ядро (mentoring_protector_core.dll), что позволит (S3) службе ВЛАДЕТЬ
// защищёнными файлами (сигнатуры/карантин/токен) с read-only для пользователя -> защита
// от same-user малвари. SCM recovery (restart) = несбиваемый non-admin watchdog.
//
// S1 (этот файл): SCM-плумбинг + install/uninstall с recovery + хостинг ядра через
//   core_initialize() + start_realtime_monitor() (без аргументов-путей).
// S2 ✅ (этот файл + exports.cpp/web_protection_exports.cpp): служба хостит HTTP/web_protection
//   (data\phishing_domains.txt, data\safe_domains.txt рядом с exe службы). Конфликт за порт
//   27432 разрешён через isServiceHosting() (TTL-кэш IPC-ping) в ядре: какой бы процесс
//   ни вызвал start_realtime_monitor()/web_protection_start() ПОСЛЕ того, как служба уже
//   поднята - он увидит занятость и не будет дублировать хостинг. Если GUI стартовал
//   РАНЬШЕ службы (нетипичный порядок - служба обычно поднимается при загрузке системы,
//   до логина пользователя) - bind порта в самой службе может не пройти; это известное
//   ограничение, не закрытое в этой правке.
// S3 control slice ✅ (этот файл + service_ipc.h/.cpp): IPC-пайп теперь принимает
//   privileged-команды realtime_start/stop, web_start/stop (ServiceControlImpl ниже),
//   гейтится elevation-проверкой клиента (DEC-057) в service_ipc.cpp::acceptLoop.
//   status отражает РЕАЛЬНОЕ намерение службы (g_realtimeHosting/g_webHosting), а не
//   просто "процесс жив" - закрывает F1 (флип-флоп тумблера GUI при живой службе).
//   Доставка privileged-команд от non-elevated GUI - через mp_helper.exe (UAC).
// S3 (остаток): ownership-flip DACL на data/+quarantine/. S4: миграция реестровых
//   fix'ов + installer.

#include <windows.h>
#include <string>
#include <atomic>
#include <mutex>
#include <cstdio>   // wprintf (вывод для --install / --uninstall)
#include "service_ipc.h"
#include "service_pipe_protocol.h"  // F-2: единая kPipeName для self-test (см. service_ipc.cpp)
#include "../MentoringProtector_core/json_utils.h"

namespace {

constexpr wchar_t kServiceName[] = L"MentoringProtectorService";
constexpr wchar_t kDisplayName[] = L"Mentoring Protector Service";
constexpr wchar_t kCoreDll[]     = L"MentoringProtector_core.dll";

SERVICE_STATUS        g_status{};
SERVICE_STATUS_HANDLE g_statusHandle = nullptr;
HANDLE                g_stopEvent    = nullptr;  // сигнал остановки из SvcCtrlHandler

// Экспорты ядра (FFI), резолвятся через GetProcAddress.
using FnInit         = char* (*)();
using FnStartRt      = char* (*)();
using FnStopRt       = char* (*)();
using FnFreeString   = void  (*)(char*);
using FnStartWeb     = int   (*)(const char*, const char*);
using FnStopWeb      = void  (*)();

HMODULE      g_core      = nullptr;
FnInit       g_init      = nullptr;
FnStartRt    g_startRt   = nullptr;
FnStopRt     g_stopRt    = nullptr;
FnFreeString g_freeStr   = nullptr;
FnStartWeb   g_startWeb  = nullptr;  // S2: опционально - старый core.dll без этого экспорта не ломает службу
FnStopWeb    g_stopWeb   = nullptr;

NamedPipeServer g_ipc;  // S3: IPC named-pipe сервер (read-only + elevation-gated control)

// Интент-флаги хостинга для status-команды IPC (S3). НЕ читаем is_realtime_monitoring()/
// web_protection_is_running() из ядра для этой цели: те экспорты сами пингуют этот же
// IPC-пайп через isServiceHosting() (S2) - вызов отсюда был бы самовызовом службы в саму
// себя. Флаги отражают, что служба САМА запросила у ядра (а не что ядро решило по факту).
// atomic: читаются/пишутся из разных worker-потоков NamedPipeServer (S3 многопоточный
// acceptLoop) - один поток может обслуживать status-poll, другой privileged start/stop.
std::atomic<bool> g_realtimeHosting{false};
std::atomic<bool> g_webHosting{false};

// Каталог исполняемого файла службы (с завершающим '\').
std::wstring ExeDir() {
    wchar_t buf[MAX_PATH] = {};
    DWORD n = GetModuleFileNameW(nullptr, buf, MAX_PATH);
    std::wstring path(buf, (n > 0 && n < MAX_PATH) ? n : 0);
    auto pos = path.find_last_of(L"\\/");
    return (pos == std::wstring::npos) ? std::wstring() : path.substr(0, pos + 1);
}

void ReportStatus(DWORD state, DWORD exitCode, DWORD waitHintMs) {
    static DWORD checkPoint = 1;
    g_status.dwCurrentState  = state;
    g_status.dwWin32ExitCode = exitCode;
    g_status.dwWaitHint      = waitHintMs;
    g_status.dwControlsAccepted =
        (state == SERVICE_START_PENDING) ? 0 : (SERVICE_ACCEPT_STOP | SERVICE_ACCEPT_SHUTDOWN);
    g_status.dwCheckPoint =
        (state == SERVICE_RUNNING || state == SERVICE_STOPPED) ? 0 : checkPoint++;
    if (g_statusHandle) SetServiceStatus(g_statusHandle, &g_status);
}

std::string WideToUtf8(const std::wstring& w) {
    if (w.empty()) return std::string();
    int sz = WideCharToMultiByte(CP_UTF8, 0, w.c_str(), -1, nullptr, 0, nullptr, nullptr);
    if (sz <= 0) return std::string();
    std::string out(static_cast<size_t>(sz - 1), '\0');  // sz включает null-терминатор
    WideCharToMultiByte(CP_UTF8, 0, w.c_str(), -1, out.data(), sz, nullptr, nullptr);
    return out;
}

// Пишет диагностическую строку в лог рядом с exe службы - у службы нет консоли,
// поэтому это единственный способ узнать причину сбоя LoadCore() постфактум.
void LogStartupError(const std::wstring& message) {
    const std::wstring logPath = ExeDir() + L"service_startup_error.log";
    HANDLE h = CreateFileW(logPath.c_str(), FILE_APPEND_DATA, FILE_SHARE_READ, nullptr,
                            OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, nullptr);
    if (h == INVALID_HANDLE_VALUE) return;
    SetFilePointer(h, 0, nullptr, FILE_END);
    std::string line = WideToUtf8(message) + "\r\n";
    WriteFile(h, line.c_str(), static_cast<DWORD>(line.size()), nullptr, nullptr);
    CloseHandle(h);
}

// Грузит ядро с тем же hardening, что H0-5 (DEFAULT_DIRS: без CWD/PATH).
// outError - реальный GetLastError()/диагностика сбоя (вызывающий код не должен
// подставлять произвольный код вместо настоящей причины - иначе диагностика теряется).
bool LoadCore(DWORD& outError) {
    const std::wstring dllPath = ExeDir() + kCoreDll;
    const DWORD attrs = GetFileAttributesW(dllPath.c_str());
    LogStartupError(L"GetFileAttributesW(" + dllPath + L")=" + std::to_wstring(attrs) +
                     (attrs == INVALID_FILE_ATTRIBUTES ? L" (INVALID, GetLastError=" + std::to_wstring(GetLastError()) + L")" : L" (exists)"));
    g_core = LoadLibraryExW(dllPath.c_str(), nullptr, LOAD_LIBRARY_SEARCH_DEFAULT_DIRS);
    if (!g_core) {
        // Fail-closed (H0-5): НЕ откатываемся на безфлаговый LoadLibraryW - это вернуло
        // бы CWD/PATH в поиск зависимостей и открыло DLL-planting для SYSTEM-процесса.
        // Диагностика (GetFileAttributesW + GetLastError выше/ниже) достаточна для разбора
        // причины без compromise безопасности.
        outError = GetLastError();
        LogStartupError(L"LoadLibraryExW(DEFAULT_DIRS) failed, GetLastError=" + std::to_wstring(outError) +
                         L" - failing closed, NOT relaxing search order");
        return false;
    }
    g_init     = reinterpret_cast<FnInit>(GetProcAddress(g_core, "core_initialize"));
    g_startRt  = reinterpret_cast<FnStartRt>(GetProcAddress(g_core, "start_realtime_monitor"));
    g_stopRt   = reinterpret_cast<FnStopRt>(GetProcAddress(g_core, "stop_realtime_monitor"));
    g_freeStr  = reinterpret_cast<FnFreeString>(GetProcAddress(g_core, "free_string"));
    // S2: опциональны - отсутствие в старом core.dll не должно ронять службу (g_startWeb==nullptr -> просто не хостим веб).
    g_startWeb = reinterpret_cast<FnStartWeb>(GetProcAddress(g_core, "web_protection_start"));
    g_stopWeb  = reinterpret_cast<FnStopWeb>(GetProcAddress(g_core, "web_protection_stop"));
    if (!g_init || !g_freeStr) {
        outError = ERROR_PROC_NOT_FOUND;
        LogStartupError(L"GetProcAddress failed: core_initialize=" + std::to_wstring(reinterpret_cast<uintptr_t>(g_init)) +
                         L" free_string=" + std::to_wstring(reinterpret_cast<uintptr_t>(g_freeStr)));
        return false;
    }
    return true;
}

// Вызывает char*-экспорт и освобождает результат через free_string (контракт FFI).
void CallAndFree(char* (*fn)()) {
    if (!fn) return;
    char* r = fn();
    if (r && g_freeStr) g_freeStr(r);
}

// База/whitelist живут в data\ рядом с exe службы (тот же install-каталог, что GUI).
// Общий код для запуска при старте службы (StartCoreHosting) и для control-команды
// web_start, приходящей по IPC (S3, ServiceControlImpl::startWeb).
void BuildWebDataPaths(std::string& phishingPath, std::string& safeListPath) {
    const std::wstring dataDir = ExeDir() + L"data\\";
    phishingPath = WideToUtf8(dataDir + L"phishing_domains.txt");
    safeListPath = WideToUtf8(dataDir + L"safe_domains.txt");
}

std::wstring StateFilePath() { return ExeDir() + L"data\\service_state.json"; }

void ReadState(bool& realtimeWanted, bool& webWanted) {
    realtimeWanted = true;
    webWanted = true;
    HANDLE h = CreateFileW(StateFilePath().c_str(), GENERIC_READ, FILE_SHARE_READ, nullptr, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, nullptr);
    if (h == INVALID_HANDLE_VALUE) return;
    char buf[256] = {};
    DWORD readBytes = 0;
    ReadFile(h, buf, sizeof(buf) - 1, &readBytes, nullptr);
    CloseHandle(h);
    if (readBytes == 0) return;
    const std::string json(buf, readBytes);
    realtimeWanted = json_utils::extractBool(json, "realtime", true);
    webWanted = json_utils::extractBool(json, "web", true);
}

void WriteState(bool realtimeWanted, bool webWanted) {
    const std::string json = json_utils::JsonBuilder().boolean("realtime", realtimeWanted).boolean("web", webWanted).build();
    HANDLE h = CreateFileW(StateFilePath().c_str(), GENERIC_WRITE, FILE_SHARE_READ, nullptr, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, nullptr);
    if (h == INVALID_HANDLE_VALUE) return;
    DWORD written = 0;
    WriteFile(h, json.data(), static_cast<DWORD>(json.size()), &written, nullptr);
    CloseHandle(h);
}

void StartCoreHosting() {
    CallAndFree(g_init);

    bool realtimeWanted = true, webWanted = true;
    ReadState(realtimeWanted, webWanted);

    if (g_startRt && realtimeWanted) { CallAndFree(g_startRt); g_realtimeHosting = true; }
    if (g_startWeb && webWanted) {
        std::string phishingPath, safeListPath;
        BuildWebDataPaths(phishingPath, safeListPath);
        g_startWeb(phishingPath.c_str(), safeListPath.c_str());
        g_webHosting = true;
    }
}

void StopCoreHosting() {
    if (g_stopWeb) { g_stopWeb(); g_webHosting = false; }
    CallAndFree(g_stopRt);
    g_realtimeHosting = false;
    if (g_core) { FreeLibrary(g_core); g_core = nullptr; }
}

// Реализация IServiceControl поверх тех же FFI-экспортов, что StartCoreHosting/
// StopCoreHosting (S3). Обслуживает privileged IPC-команды realtime_start/stop,
// web_start/stop - доставляются из GUI через mp_helper.exe (elevation, DEC-057).
class ServiceControlImpl : public IServiceControl {
public:
    // S3 многопоточный acceptLoop: до этого core-функции (start/stop_realtime_monitor,
    // web_protection_start/stop) вызывались строго из одного потока (однопоточный
    // accept). Теперь несколько worker-потоков могут вызвать их конкурентно (GUI
    // status-poll на одном потоке + privileged start/stop на другом) - сами эти
    // FFI-функции в core.dll не гарантированно thread-safe (не проектировались под
    // конкурентный вызов). Мьютекс сериализует именно бизнес-логику (вызовы в
    // core.dll), не PIPE I/O - устраняет конкурентный доступ без отказа от
    // многопоточности accept (которая нужна для устранения ERROR_PIPE_BUSY, см. S3).
    mutable std::mutex mutex_;

    bool startRealtime() override {
        std::lock_guard<std::mutex> lock(mutex_);
        if (!g_startRt) return false;
        CallAndFree(g_startRt);
        g_realtimeHosting = true;
        WriteState(true, g_webHosting);
        return true;
    }
    void stopRealtime() override {
        std::lock_guard<std::mutex> lock(mutex_);
        CallAndFree(g_stopRt);
        g_realtimeHosting = false;
        WriteState(false, g_webHosting);
    }
    bool startWeb() override {
        std::lock_guard<std::mutex> lock(mutex_);
        if (!g_startWeb) return false;
        std::string phishingPath, safeListPath;
        BuildWebDataPaths(phishingPath, safeListPath);
        g_startWeb(phishingPath.c_str(), safeListPath.c_str());
        g_webHosting = true;
        WriteState(g_realtimeHosting, true);
        return true;
    }
    void stopWeb() override {
        std::lock_guard<std::mutex> lock(mutex_);
        if (g_stopWeb) g_stopWeb();
        g_webHosting = false;
        WriteState(g_realtimeHosting, false);
    }
    bool realtimeHosting() const override { return g_realtimeHosting; }
    bool webHosting()      const override { return g_webHosting; }
};

ServiceControlImpl g_control;

DWORD WINAPI SvcCtrlHandler(DWORD ctrl, DWORD, LPVOID, LPVOID) {
    switch (ctrl) {
    case SERVICE_CONTROL_STOP:
    case SERVICE_CONTROL_SHUTDOWN:
        ReportStatus(SERVICE_STOP_PENDING, NO_ERROR, 5000);
        if (g_stopEvent) SetEvent(g_stopEvent);
        return NO_ERROR;
    case SERVICE_CONTROL_INTERROGATE:
        return NO_ERROR;
    default:
        return ERROR_CALL_NOT_IMPLEMENTED;
    }
}

void WINAPI ServiceMain(DWORD, LPWSTR*) {
    g_statusHandle = RegisterServiceCtrlHandlerExW(kServiceName, SvcCtrlHandler, nullptr);
    if (!g_statusHandle) return;

    g_status.dwServiceType = SERVICE_WIN32_OWN_PROCESS;
    ReportStatus(SERVICE_START_PENDING, NO_ERROR, 10000);

    g_stopEvent = CreateEventW(nullptr, TRUE, FALSE, nullptr);
    if (!g_stopEvent) { ReportStatus(SERVICE_STOPPED, GetLastError(), 0); return; }

    DWORD loadCoreError = NO_ERROR;
    if (!LoadCore(loadCoreError)) {
        // Граница безопасности: без ядра служба бесполезна -> останавливаемся явно.
        // Реальный код ошибки (не подмена) - иначе диагностика теряется (см. LogStartupError).
        ReportStatus(SERVICE_STOPPED, loadCoreError, 0);
        CloseHandle(g_stopEvent);
        return;
    }

    StartCoreHosting();
    g_ipc.setControl(&g_control);  // S3: даём IPC-серверу доступ к управлению хостингом
    g_ipc.start();
    ReportStatus(SERVICE_RUNNING, NO_ERROR, 0);

    WaitForSingleObject(g_stopEvent, INFINITE);

    ReportStatus(SERVICE_STOP_PENDING, NO_ERROR, 5000);
    g_ipc.stop();  // S3a: останавливаем IPC до выгрузки ядра
    StopCoreHosting();
    CloseHandle(g_stopEvent);
    g_stopEvent = nullptr;
    ReportStatus(SERVICE_STOPPED, NO_ERROR, 0);
}

// --- Install / Uninstall (требуют admin; manifest = requireAdministrator) ---

int InstallService() {
    wchar_t exe[MAX_PATH] = {};
    if (!GetModuleFileNameW(nullptr, exe, MAX_PATH)) return 1;

    // CWE-428 (unquoted service path): без кавычек SCM при наличии пробела в пути
    // трактует каждый сегмент до пробела как отдельный кандидат на запуск (напр.
    // "C:\Program.exe" вместо "C:\Program Files\..."). На дефолтных ACL не пишутся
    // обычным пользователем, но кавычки - бесплатная defense-in-depth для кастомных
    // путей установки.
    const std::wstring quotedExe = L"\"" + std::wstring(exe) + L"\"";

    SC_HANDLE scm = OpenSCManagerW(nullptr, nullptr, SC_MANAGER_CREATE_SERVICE);
    if (!scm) { wprintf(L"OpenSCManager failed: %lu\n", GetLastError()); return 1; }

    SC_HANDLE svc = CreateServiceW(
        scm, kServiceName, kDisplayName,
        SERVICE_ALL_ACCESS, SERVICE_WIN32_OWN_PROCESS,
        SERVICE_AUTO_START, SERVICE_ERROR_NORMAL,
        quotedExe.c_str(), nullptr, nullptr, nullptr,
        nullptr /* LocalSystem */, nullptr);

    if (!svc) {
        DWORD e = GetLastError();
        CloseServiceHandle(scm);
        if (e == ERROR_SERVICE_EXISTS) { wprintf(L"Service already exists.\n"); return 0; }
        wprintf(L"CreateService failed: %lu\n", e);
        return 1;
    }

    // Watchdog: SCM перезапускает службу при сбое (несбиваемо для non-admin).
    SC_ACTION actions[3] = {
        { SC_ACTION_RESTART, 5000 },   // 1-й сбой: рестарт через 5с
        { SC_ACTION_RESTART, 5000 },   // 2-й сбой: рестарт через 5с
        { SC_ACTION_RESTART, 30000 },  // далее: рестарт через 30с
    };
    SERVICE_FAILURE_ACTIONS fa{};
    fa.dwResetPeriod = 86400;          // сброс счётчика сбоев раз в сутки
    fa.cActions      = 3;
    fa.lpsaActions   = actions;
    ChangeServiceConfig2W(svc, SERVICE_CONFIG_FAILURE_ACTIONS, &fa);

    SERVICE_DESCRIPTIONW desc{};
    desc.lpDescription = const_cast<LPWSTR>(L"Самозащита и фоновая защита Mentoring Protector.");
    ChangeServiceConfig2W(svc, SERVICE_CONFIG_DESCRIPTION, &desc);

    wprintf(L"Service installed (auto-start + recovery).\n");
    CloseServiceHandle(svc);
    CloseServiceHandle(scm);
    return 0;
}

int UninstallService() {
    SC_HANDLE scm = OpenSCManagerW(nullptr, nullptr, SC_MANAGER_CONNECT);
    if (!scm) { wprintf(L"OpenSCManager failed: %lu\n", GetLastError()); return 1; }

    SC_HANDLE svc = OpenServiceW(scm, kServiceName, SERVICE_STOP | DELETE);
    if (!svc) {
        DWORD e = GetLastError();
        CloseServiceHandle(scm);
        if (e == ERROR_SERVICE_DOES_NOT_EXIST) { wprintf(L"Service not installed.\n"); return 0; }
        wprintf(L"OpenService failed: %lu\n", e);
        return 1;
    }

    SERVICE_STATUS st{};
    ControlService(svc, SERVICE_CONTROL_STOP, &st);  // best-effort stop
    if (!DeleteService(svc)) wprintf(L"DeleteService failed: %lu\n", GetLastError());
    else                     wprintf(L"Service uninstalled.\n");

    CloseServiceHandle(svc);
    CloseServiceHandle(scm);
    return 0;
}

// --- S3a: IPC self-test (поднять сервер + клиент-ping; без install/admin) ---
int IpcSelfTest() {
    NamedPipeServer srv;
    if (!srv.start()) { wprintf(L"IPC self-test FAIL: server start\n"); return 1; }

    HANDLE h = INVALID_HANDLE_VALUE;
    for (int i = 0; i < 50 && h == INVALID_HANDLE_VALUE; ++i) {
        h = CreateFileW(service_pipe::kPipeName,
                        GENERIC_READ | GENERIC_WRITE, 0, nullptr, OPEN_EXISTING, 0, nullptr);
        if (h == INVALID_HANDLE_VALUE) Sleep(50);
    }
    if (h == INVALID_HANDLE_VALUE) {
        wprintf(L"IPC self-test FAIL: client connect (err=%lu)\n", GetLastError());
        srv.stop();
        return 1;
    }
    DWORD mode = PIPE_READMODE_MESSAGE;
    SetNamedPipeHandleState(h, &mode, nullptr, nullptr);

    const char req[] = "{\"cmd\":\"ping\"}";
    DWORD written = 0;
    WriteFile(h, req, static_cast<DWORD>(sizeof(req) - 1), &written, nullptr);

    char buf[256] = {};
    DWORD readBytes = 0;
    BOOL ok = ReadFile(h, buf, sizeof(buf) - 1, &readBytes, nullptr);
    CloseHandle(h);
    srv.stop();

    if (ok && readBytes > 0 &&
        std::string(buf, readBytes).find("\"ok\":true") != std::string::npos) {
        printf("IPC self-test OK: %.*s\n", static_cast<int>(readBytes), buf);
        return 0;
    }
    wprintf(L"IPC self-test FAIL: bad response (ok=%d, bytes=%lu)\n", ok, readBytes);
    return 1;
}

} // namespace

int wmain(int argc, wchar_t* argv[]) {
    if (argc >= 2) {
        const std::wstring flag = argv[1];
        if (flag == L"--install" || flag == L"--install-service")   return InstallService();
        if (flag == L"--uninstall" || flag == L"--uninstall-service") return UninstallService();
        if (flag == L"--ipc-selftest") return IpcSelfTest();
        wprintf(L"Usage: MentoringProtector_service.exe [--install | --uninstall | --ipc-selftest]\n");
        return 1;
    }

    // Без аргументов = запуск под управлением SCM.
    SERVICE_TABLE_ENTRYW table[] = {
        { const_cast<LPWSTR>(kServiceName), ServiceMain },
        { nullptr, nullptr },
    };
    if (!StartServiceCtrlDispatcherW(table)) {
        // Запущен не из SCM (напр. вручную из консоли) - подсказываем.
        DWORD e = GetLastError();
        if (e == ERROR_FAILED_SERVICE_CONTROLLER_CONNECT)
            wprintf(L"Run via SCM, or use --install / --uninstall.\n");
        return 1;
    }
    return 0;
}
