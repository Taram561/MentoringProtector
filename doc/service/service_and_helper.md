# Фоновая служба и elevated-хелпер
**Фоновая служба** (core/MentoringProtector_service/) - MentoringProtectorService.exe регистрируется как служба Windows под LocalSystem с автозапуском, загружает то же ядро через GetProcAddress и поднимает защиту в реальном времени и веб-защиту без интерфейса. Конкуренция за порт/наблюдателей между службой и интерфейсом решается в ядре. Управление - через именованный канал: статус доступен обычным пользователям, привилегированные команды - только клиенту с проверенными повышенными правами.

**Elevated-хелпер** (core/MentoringProtector_helper/) - mp_helper.exe доставляет привилегированную команду от неповышенного интерфейса к службе через разовое UAC-повышение, а также применяет часть исправлений уязвимостей (registry_fixes). Список передаваемых команд жёстко ограничен (isAllowedServiceCmd).

## Файлы

| Файл | Описание |
|---|---|
| MentoringProtector_service/main.cpp | Точка входа службы: регистрация в SCM, хостинг ядра, обработчик команд управления |
| MentoringProtector_service/service_ipc.cpp / .h | Сервер именованного канала: приём запросов, проверка повышенных прав клиента |
| MentoringProtector_service/service_pipe_protocol.cpp / .h | Общее имя канала и базовая функция отправки запроса |
| MentoringProtector_service/service.exe.manifest | Манифест исполняемого файла службы |
| MentoringProtector_helper/main.cpp | Точка входа хелпера: разбор команды, проверка разрешённого списка, отправка службе, применение исправлений реестра |
| MentoringProtector_helper/registry_fixes.cpp / .h | Применение исправлений уязвимостей, требующих прав администратора |
| MentoringProtector_helper/helper.exe.manifest | Манифест хелпера с требованием UAC |

## Классы и функции

### Служба - точка входа (MentoringProtector_service/main.cpp)

| Функция                                | Описание                                                                                                      |
| -------------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| ServiceMain(...)                       | Точка входа от SCM: регистрирует обработчик команд, грузит ядро, поднимает хостинг и IPC-сервер, ждёт остановки |
| SvcCtrlHandler(ctrl, ...)              | На SERVICE_CONTROL_STOP/SHUTDOWN сигналит событие остановки, не блокируя поток SCM                              |
| StartCoreHosting() / StopCoreHosting() | Инициализация/остановка ядра; поднимают защиту согласно сохранённому состоянию (ReadState)                      |
| ReadState(...) / WriteState(...)       | Чтение/запись data\service_state.json - персистентный выбор пользователя                                        |
| BuildWebDataPaths(...)                 | Пути к базам веб-защиты рядом с exe службы                                                                      |
| IpcSelfTest()                          | Сервер+клиент именованного канала в одном процессе, ping-проверка без установки службы                          |
| CallAndFree(fn)                        | Вызов экспорта ядра, возвращающего char*, с немедленным free_string                                             |
| LogStartupError(message)               | Диагностическая строка в файл рядом с exe (у службы нет консоли)                                                |

**wmain(argc, argv)** - без аргументов ожидает запуск через SCM; с флагами --install/--uninstall/--ipc-selftest выполняет разовое действие.

**LoadCore(outError)** - загрузка строго через LOAD_LIBRARY_SEARCH_DEFAULT_DIRS, без отката на менее строгий вызов - защита от DLL planting для процесса SYSTEM.

**InstallService()** - путь к exe в кавычках (защита от unquoted service path), автоперезапуск при сбое (2 раза по 5 сек, далее каждые 30 сек).

### Служба - IPC-сервер (service_ipc.h / service_ipc.cpp)

| Метод/функция                                       | Описание                                                                           |
| --------------------------------------------------- | ------------------------------------------------------------------------------------ |
| NamedPipeServer::start() / stop()                   | SDDL-дескриптор безопасности пайпа, запуск/остановка рабочих потоков (acceptLoop)    |
| NamedPipeServer::handleRequest(req) const           | Диспетчер по точному значению cmd: ping, status, realtime_start/stop, web_start/stop |
| NamedPipeServer::isPrivilegedCmd(cmd) (статический) | true для четырёх команд, меняющих состояние хостинга                                 |

**acceptLoop()** - несколько потоков параллельно создают экземпляры именованного канала (устраняет ERROR_PIPE_BUSY); ровно один поток создаёт первый экземпляр с FILE_FLAG_FIRST_PIPE_INSTANCE - при неудаче IPC останавливается целиком (fail-closed, защита от сквоттинга имени пайпа).

**ClientIsElevated()** - проверка между ImpersonateNamedPipeClient() и RevertToSelf(): уровень целостности High IL, запасной путь - членство в группе администраторов.

### Служба - протокол канала (service_pipe_protocol.h / .cpp)

| Функция                | Описание                                                                    |
| ---------------------- | ----------------------------------------------------------------------------- |
| OwnerIsTrusted(pipe)   | Проверка, что владелец открытого канала - SYSTEM или локальные администраторы |
| LogFailure(reason)     | Причина неудачи IPC в файл рядом с exe вызывающего процесса                   |

**send(reqJson, respOut)** - клиентская сторона (ядро и хелпер); перед отправкой проверяет OwnerIsTrusted; при ERROR_PIPE_BUSY - до 4 попыток подключения с ожиданием.

### Elevated-хелпер (main.cpp / registry_fixes.h / .cpp)

| Функция                                                           | Описание                                              |
| ----------------------------------------------------------------- | ------------------------------------------------------- |
| isAllowedServiceCmd(cmd)                                          | Список из четырёх разрешённых команд службе             |
| splitCsv(s)                                                       | Разбор списка команд через запятую для пакетного режима |
| isKnownVulnId(vuln_id)                                            | Список из 5 поддерживаемых уязвимостей                  |
| applyFix(vuln_id)                                                 | Диспетчер к одной из пяти функций исправления           |
| listSupported()                                                   | JSON-массив поддерживаемых идентификаторов уязвимостей  |
| fixSmartScreen/fixFirewall/fixUac/fixWindowsUpdate/fixAutoLogon() | Записи реестра через KEY_WOW64_64KEY                    |

**main(argc, argv)** - режимы --list-supported, --fix <vuln_id>, --service-cmd, --service-cmds (несколько команд за один
UAC-диалог); --output-file  дублирует результат в файл.

**writeResultFile(path, json)** - результат дублируется в файл, поскольку ShellExecuteEx с "runas" не даёт перенаправить stdout повышенного процесса.

**fixUac()** - единственное из пяти исправлений с reboot_required = true.

