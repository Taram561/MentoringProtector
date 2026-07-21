# Защита в реальном времени

## Файлы

| Файл | Описание |
|---|---|
| realtime_monitor.cpp / realtime_monitor.h | Наблюдение за файловой системой, очередь проверки, накопление событий |

## Классы и функции

### RealtimeMonitor (realtime_monitor.h / realtime_monitor.cpp)

| Метод                                                      | Описание                                                                        |
| ---------------------------------------------------------- | ------------------------------------------------------------------------------- |
| RealtimeMonitor(config, scanner, heuristic, nudge_sink)    | По умолчанию - Downloads, Desktop, Documents, %TEMP%                            |
| ~RealtimeMonitor()                                         | Вызов stop()                                                                    |
| loadResources(signatures_path, rules_path, threat_db_path) | Создание собственных Scanner/HeuristicAnalyzer, если не переданы извне          |
| start()                                                    | Поток-наблюдатель на каждый существующий каталог, плюс поток-сканер             |
| isRunning() const                                          | Флаг running_                                                                   |
| getAndClearEvents()                                        | Список событий под мьютексом, с очисткой                                        |
| totalDetected() const / threatsFound() const               | Атомарные счётчики                                                              |
| scanWorker()                                               | Разбор очереди пачками, вызов scanFile, добавление FileEvent (лимит max_events) |
| shouldScan(path) const                                     | Проверка расширения по scan_extensions                                          |
| getCurrentTime() const                                     | Текущее локальное время                                                         |
| getDefaultWatchPaths()                                     | Не реализован отдельно - логика по умолчанию встроена в конструктор             |

**stop()** - явная отмена незавершённых ReadDirectoryChangesW (CancelIoEx) и закрытие дескрипторов каталогов до ожидания завершения потоков.

**watchDirectory(dirPath)** - асинхронный ReadDirectoryChangesW с таймаутом ожидания 500 мс; события ставятся в очередь через enqueueFile после фильтра shouldScan.

**enqueueFile(path, action)** - дедупликация: повторная постановка того же пути игнорируется в течение 3 секунд; карта чистится от записей старше 30 секунд при росте свыше 1000 элементов.

**scanFile(path, action)** - файлы крупнее max_file_size пропускаются; полный scanner_->scanFile (вердикт фиксируется как detection_method = "signature" независимо от реально сработавшего движка); при отсутствии угрозы и исполняемом расширении - повторный независимый heuristic_->analyze со своей шкалой 20/50/80 (не совпадает с порогом Scanner); при отсутствии угрозы - проверка условий для обучающих подсказок (Mark of the Web, макросы, скрипты через script_guard).
