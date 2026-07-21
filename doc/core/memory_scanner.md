# Сканирование памяти

## Файлы

| Файл | Описание |
|---|---|
| memory_scanner.cpp / memory_scanner.h | Сканирование памяти процессов: чтение регионов, применение сигнатур, прогресс полного сканирования |
| search.cpp / search.h | Одновременный поиск множества образцов за один проход по данным |

## Классы и функции

### MemoryScanner (memory_scanner.h / memory_scanner.cpp)

| Метод                              | Описание                                                                                         |
| ---------------------------------- | ------------------------------------------------------------------------------------------------ |
| MemoryScanner()                    | Загрузка встроенных сигнатур, построение матчера                                                 |
| ~MemoryScanner()                   | Вызов stopScan()                                                                                 |
| loadBuiltinSignatures()            | Встроенный набор из 26 текстовых образцов известных инструментов атаки                           |
| startFullScan()                    | Запуск scanAllProcesses в отдельном потоке                                                       |
| stopScan()                         | Флаг остановки; при отсутствии завершения за 3 сек - принудительное отсоединение потока          |
| getProgress()                      | Копия прогресса под мьютексом                                                                    |
| isRunning() const                  | Флаг running_                                                                                    |
| buildMatcher()                     | Пересоздание SearchMatcher со всеми текущими сигнатурами                                         |
| getProcessList()                   | Снимок процессов через CreateToolhelp32Snapshot                                                  |
| getProcessPath(pid)                | Полный путь исполняемого файла процесса                                                          |
| searchMemory(hProcess, sig)        | Побайтовый поиск одной сигнатуры (не используется - scanProcess вызывает общий matcher_.findAll) |
| isReadableRegion(mbi) const        | Регион зафиксирован (MEM_COMMIT), без PAGE_GUARD/PAGE_NOACCESS, с читаемым флагом защиты         |
| isSystemProcess(processName) const | Список из 23 системных процессов Windows, не сканируемых                                         |
| getCurrentTime() const             | Текущее локальное время                                                                          |

**loadSignatures(path)** - формат имя\|байты_образца\|уровень_опасности, записи добавляются к встроенным, матчер перестраивается.

**scanProcess(pid)** - открытие процесса с минимальными правами (PROCESS_QUERY_INFORMATION | PROCESS_VM_READ), обход региона за регионом через VirtualQueryEx, блоки по 64 КБ через общий matcher_.findAll; лимиты 4 секунды и 256 МБ на процесс.

**scanAllProcesses()** - пропуск системных процессов и PID ≤ 4; каждый процесс - в отдельной асинхронной задаче с таймаутом 5 секунд.

### SearchMatcher (search.h / search.cpp)

| Метод | Описание |
|---|---|
| addPattern(pattern, length, id) | Добавление образца в дерево поиска |
| build() | Построение запасных переходов (fail-ссылок), автомат готов к поиску |
| findAll(data, len) const | Один проход по данным, все пары (id образца, позиция) |
| isBuilt() const / nodeCount() const | Готовность автомата / число узлов |
