#pragma once
// S3: named-pipe IPC сервер службы MentoringProtector.
// Read-only команды (ping/status) открыты любому аутентифицированному клиенту -
// нужно non-elevated GUI (DEC-055), чтобы читать статус без UAC.
// Привилегированные команды (realtime_start/stop, web_start/stop) меняют состояние
// хостинга -> требуют от клиента High integrity level ИЛИ членства в Administrators
// (DEC-057). Эта проверка делается в acceptLoop() через ImpersonateNamedPipeClient
// (только там доступен HANDLE пайпа) - handleRequest() НЕ проверяет привилегии,
// остаётся чистым диспетчером и юнит-тестируется без живого пайпа.
// Чистая остановка: overlapped ConnectNamedPipe + stop-event (не блокирующий accept).

#include <windows.h>
#include <string>
#include <thread>
#include <vector>
#include <atomic>

// Абстракция управления хостингом модулей ядра внутри службы. Внедряется через
// NamedPipeServer::setControl() - позволяет юнит-тестировать диспетчер команд
// (handleRequest) фейковой реализацией, без реального ядра/FFI. Настоящую
// реализацию поверх core_initialize()/start_realtime_monitor()/... предоставляет
// main.cpp службы.
class IServiceControl {
public:
    virtual ~IServiceControl() = default;
    virtual bool startRealtime() = 0;
    virtual void stopRealtime() = 0;
    virtual bool startWeb() = 0;
    virtual void stopWeb() = 0;
    virtual bool realtimeHosting() const = 0;
    virtual bool webHosting() const = 0;
};

class NamedPipeServer {
public:
    NamedPipeServer() = default;
    ~NamedPipeServer();

    NamedPipeServer(const NamedPipeServer&) = delete;
    NamedPipeServer& operator=(const NamedPipeServer&) = delete;

    bool start();   // запускает accept-поток; false если уже запущен/ошибка
    void stop();    // сигнал остановки + join (идемпотентно)

    // Внедряет управление хостингом. nullptr (значение по умолчанию) - status/
    // realtime_start/.../web_stop отвечают {"ok":false,"error":"unavailable"}
    // (так юнит-тесты диспетчера не требуют реального ядра).
    void setControl(IServiceControl* control) { control_ = control; }

    // Разбирает JSON-запрос и возвращает JSON-ответ.
    // public: позволяет юнит-тестировать без запуска pipe-сервера.
    // Не проверяет привилегии клиента - см. баннер выше.
    std::string handleRequest(const std::string& req) const;

    // true, если команда меняет состояние хостинга (требует elevated-клиента).
    // public/static: используется acceptLoop() как гейт ДО handleRequest()
    // и юнит-тестируется отдельно от живого пайпа.
    static bool isPrivilegedCmd(const std::string& cmd);

private:
    void acceptLoop();

    // Несколько worker-потоков, каждый со своим pipe-инстансом (PIPE_UNLIMITED_INSTANCES
    // это разрешает): однопоточный accept обслуживал клиентов последовательно, и под
    // конкурентной нагрузкой (GUI поллит status каждые 2-3с на нескольких экранах
    // одновременно) сервер был занят дольше клиентского retry-окна - mp_helper.exe
    // получал стабильный ERROR_PIPE_BUSY вместо обслуживания. N независимых инстансов
    // устраняют конкуренцию, а не просто снижают её вероятность.
    static constexpr int kWorkerCount = 8;
    std::vector<std::thread> threads_;
    std::atomic<bool>        running_{false};
    std::atomic<bool>        firstInstanceClaimed_{false};  // anti-squatting: ровно один инстанс
    HANDLE                   stopEvent_ = nullptr;
    PSECURITY_DESCRIPTOR     securityDescriptor_ = nullptr;  // общий для всех потоков, read-only
    IServiceControl*         control_ = nullptr;
};
