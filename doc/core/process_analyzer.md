# Анализ процессов

## Файлы

| Файл | Описание |
|---|---|
| process_analyzer.cpp / process_analyzer.h | Наблюдение за процессами (ETW или опрос), анализ через сканер/эвристику, кэш анализа, список доверенных процессов |

## Классы и функции

### ProcessAnalyzer (process_analyzer.h / process_analyzer.cpp)

| Метод                                                      | Описание                                                                                            |
| ---------------------------------------------------------- | --------------------------------------------------------------------------------------------------- |
| ProcessAnalyzer(scanner, heuristic, config)                | Список исключённых путей по умолчанию - системные каталоги, Program Files, известные IDE и рантаймы |
| ~ProcessAnalyzer()                                         | Вызов stopMonitoring()                                                                              |
| loadResources(signatures_path, rules_path, threat_db_path) | Загрузка баз в уже переданные scanner/heuristic                                                     |
| getAndClearAlerts()                                        | Список предупреждений с очисткой                                                                    |
| isMonitoring() const                                       | Флаг monitoring_                                                                                    |
| getMonitoringMode() const                                  | "etw", "polling" или "off"                                                                          |
| getAndClearInjectionAlerts()                               | Делегирует в EtwMonitor::getAndClearInjectionAlerts, если ETW активен                               |
| terminateProcess(pid)                                      | OpenProcess(PROCESS_TERMINATE) + TerminateProcess                                                   |
| getRunningProcesses()                                      | Снимок процессов                                                                                    |
| getProcessExePath(pid)                                     | Путь исполняемого файла                                                                             |
| isExcluded(path) const                                     | Совпадение с исключёнными каталогами                                                                |
| isTrustedProcess(processName) const                        | Проверка по списку доверенных процессов                                                             |
| addAlert(alert)                                            | Добавление предупреждения под мьютексом                                                             |
| getCurrentTime() const                                     | Текущее время                                                                                       |
| getProcessParentPid(pid) const                             | PID родителя перебором снимка процессов                                                             |
| getProcessModules(pid) const                               | Список загруженных модулей (лимит 64)                                                               |
| verifyProcessSignature(exe_path) (статический)             | Быстрая проверка подписи без отзыва: "signed"/"unsigned"                                            |

**startMonitoring()** - сначала EtwMonitor; при недоступности (нет прав) - резервный поток опроса (monitorLoop, интервал по умолчанию 2 сек).

**stopMonitoring()** - в режиме ETW - остановка и уничтожение EtwMonitor; в режиме опроса - ожидание потока до 500 мс, при зависании - принудительное отсоединение.

**analyzeProcess(pid)** - полный Scanner::scanFile; совпадение с сигнатурой - malicious со счётом 100; иначе отдельный heuristic_->analyze со своей шкалой 20/50/80 (аналогично RealtimeMonitor). Кэш результата на 5 секунд ведётся не здесь, а в FFI-экспортах

**monitorLoop()** - инициализация COM для потока, обход снимка процессов с запоминанием уже проверенных PID (сброс каждые 100 итераций).

**onEtwProcessStart(event)** - те же проверки на доверенность/исключение, что и в monitorLoop, но по событию сразу; список проверенных PID ограничен 500 записями.

**getProcessCmdline(pid) const** - чтение PEB чужого процесса через недокументированную NtQueryInformationProcess и ReadProcessMemory - типичный для Windows приём, полагающийся на внутреннее устройство структур ОС.
