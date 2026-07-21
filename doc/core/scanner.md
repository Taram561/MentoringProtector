# Сканер

## Файлы

| Файл | Описание |
|---|---|
| scanner.cpp / scanner.h | Основной класс сканера: разовая проверка файла, полное сканирование компьютера, управление исключениями |
| file_hasher.cpp / file_hasher.h | Вычисление хэшей файла (SHA-256, MD5, SHA-1) |
| i_scan_engine.h | Общий интерфейс для подключаемых движков обнаружения |
| scan_result.h | Структура результата проверки одного файла |
| smart_scan_cache.h | Умный кэш результатов сканирования и кэш доверенных (подписанных) файлов |

## Классы и функции

### Scanner (scanner.h / scanner.cpp)

| Метод                                                      | Описание                                                                   |
| ---------------------------------------------------------- | -------------------------------------------------------------------------- |
| Scanner()                                                  | Создание пустых SignatureDatabase и ThreatDatabase                         |
| ~Scanner()                                                 | Остановка полного сканирования и пула рабочих потоков                      |
| loadSignatures(db_path)                                    | Загрузка базы сигнатур; успех - только если загружена хотя бы одна запись  |
| loadThreatDatabase(json_path)                              | Загрузка объяснимой базы угроз                                             |
| calculateSHA256/MD5/SHA1(file_path)                        | Обёртки над методами FileHasher                                            |
| scanFile(file_path)                                        | См. разбор ниже - основной метод проверки одного файла                     |
| startComputerScan()                                        | См. разбор ниже - запуск полного сканирования всех дисков                  |
| stopComputerScan()                                         | Флаг остановки, очистка очереди файлов, пробуждение всех ожидающих потоков |
| getComputerScanProgress() const                            | Копия текущего прогресса под мьютексом                                     |
| setHeuristicAnalyzer/setYaraScanner/setArchiveScanner(...) | Подключение внешних движков (без владения ими)                             |
| getCacheStats() const                                      | Статистика умного кэша                                                     |
| invalidateCache()                                          | Увеличение версии кэша - старые записи перестают быть валидными            |
| clearCache()                                               | Полная очистка кэша и счётчиков                                            |
| getExclusions() const                                      | Копия списка исключений под мьютексом                                      |
| addExclusion(path) / removeExclusion(path)                 | Добавление/удаление пути из списка исключений с сохранением файла          |
| shouldRunHeuristic(path) const / shouldRunYara(path) const | Проверка расширения файла по фиксированному списку                         |
| startWorkerPool() / stopWorkerPool()                       | Запуск/остановка пула потоков (от 2 до 8, по числу ядер)                   |

**scanFile(file_path)** - цепочка движков по приоритету: исключения -> умный кэш -> хэши и сигнатуры (под shared_lock) -> архив (рекурсивно через ArchiveScanner) -> YARA -> проверка цифровой подписи для доверенных каталогов (кэш в TrustedFileReputation, пропуск эвристики для подписанных) -> эвристика (порог suspicion_score >= 70). После вердикта довычисляется engines_triggered (дополнительные движки только для объяснения, без влияния на вердикт), результат сохраняется в кэш и уходит в StatsRecorder.

**reloadDatabase(db_path)** - новая SignatureDatabase собирается рядом со старой, подмена указателя - под unique_lock, затем invalidateCache().

**startComputerScan()** - обход дисков (фиксированные и съёмные) в отдельном потоке через GetLogicalDrives и scanDirectoryRecursive, параллельная раздача файлов пулу воркеров, итог - в StatsRecorder.

**scanDirectoryRecursive(path, depth)** - FindFirstFileW/FindNextFileW, глубина до 15 уровней, файлы не крупнее 100 МБ в общую очередь; при очереди свыше 1000 элементов - пауза.

**scanWorkerLoop()** - разбор очереди с таймаутом 50 мс, вызов scanFile, исключения перехватываются, чтобы не остановить весь пул.

**shouldSkipPath(path) const** - многоуровневый фильтр: каталоги распаковки, собственный каталог установки, системные каталоги, кэши браузеров, служебные имена ($Recycle.Bin, node_modules, .git), безопасные расширения, пользовательские исключения.

**isArchiveFile(path) const** - по расширению, при несовпадении - по magic-числам (ZIP, 7-Zip, RAR) в первых 8 байтах.

**loadExclusions(json_path) / saveExclusions() const** - самодельный разбор/сборка JSON-массива exclusions без json_utils.

### FileHasher (file_hasher.h / file_hasher.cpp)

| Метод                                     | Описание                                                       |
| ----------------------------------------- | -------------------------------------------------------------- |
| calculateSHA256/MD5/SHA1(file_path) const | Чтение файла блоками через Windows CryptoAPI, хэш в hex-строке |
| bytesToHex(data, length) (статический)    | Массив байт в строку шестнадцатеричных пар                     |

**calculateAllHashes(file_path) const** - один проход по данным файла для всех трёх алгоритмов сразу (втрое дешевле, чем читать файл заново на каждый); именно этот метод использует Scanner::scanFile.

### SmartScanCache и TrustedFileReputation (smart_scan_cache.h)

| Метод (SmartScanCache) | Описание |
|---|---|
| lookup(path, out_entry) | Совпадение версии базы и трёх признаков файла (размер, время создания/записи), иначе счётчик промахов |
| store(...) | Сохранение записи с текущей версией базы |
| invalidateAll() | Увеличение версии кэша |
| setDbVersion(version) | Принудительная установка версии |
| getStats() const | hits/misses/invalidations/entries |
| clear() | Очистка записей и счётчиков |

| Метод (TrustedFileReputation) | Описание |
|---|---|
| lookup(path, out_trusted, out_signer) | Аналогично, без привязки к версии базы сигнатур |
| store(path, is_trusted, signer_name) | Сохранение результата проверки подписи |
| getStats() const / clear() | Аналогично SmartScanCache |

Оба класса потокобезопасны через std::shared_mutex.

### IScanEngine (i_scan_engine.h)

Интерфейс, реализуемый HeuristicAnalyzer и YaraScanner: scan(file_path), isAvailable() const, name() const.
