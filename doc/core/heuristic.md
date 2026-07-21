# Эвристика

## Файлы

| Файл | Описание |
|---|---|
| heuristic.cpp / heuristic.h | Основной анализатор: PE-заголовок, импорты, строки, энтропия, проверка подписи; правила - в data/heuristic_rules.json |
| crl_updater.cpp / crl_updater.h | Фоновое обновление списков отозванных сертификатов (CRL) |

## Классы и функции

### HeuristicRules (heuristic.h / heuristic.cpp)

| Метод                                          | Описание                                                                                                           |
| ---------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| HeuristicRules()                               | Значения по умолчанию на случай, если файл правил не загрузится: пороги энтропии 6.8/7.2, пороги вердикта 20/50/80 |
| isLoaded() const                               | Успешно ли загружен хотя бы один список правил                                                                     |
| getEntropySuspicious/Malicious() const         | Пороги энтропии                                                                                                    |
| getThresholdClean/Suspicious/Malicious() const | Пороги итогового счёта для вердикта                                                                                |
| getImportRules/StringRules/PeRules() const     | Загруженные списки правил по категориям                                                                            |

**loadFromFile(json_path)** - разбор блоков entropy_thresholds, verdict_thresholds и трёх массивов правил; успех - если загружен хотя бы один непустой список правил.

**extractRules(json, key)** - самодельный построчный разбор JSON-массива объектов по подсчёту вложенности фигурных скобок, без json_utils.

### HeuristicAnalyzer (heuristic.h / heuristic.cpp)

| Метод                                      | Описание                                                                                           |
| ------------------------------------------ | -------------------------------------------------------------------------------------------------- |
| HeuristicAnalyzer() / ~HeuristicAnalyzer() | Создание/удаление внутреннего HeuristicRules                                                       |
| loadRules(rules_path)                      | Делегирует в HeuristicRules::loadFromFile                                                          |
| scan(file_path) (реализация IScanEngine)   | Вызов analyze, угроза при suspicion_score >= 70                                                    |
| isAvailable() const                        | true, если правила загружены                                                                       |
| extractStrings(file_path, min_length)      | Накопление подряд идущих печатаемых ASCII-символов в строки не короче min_length                   |
| calculateVerdict(result)                   | Сравнение счёта с порогами, вердикт: clean(0) / suspicious(4) / likely_malicious(7) / malicious(9) |
| isPeFile(file_path)                        | Сигнатура MZ в первых 2 байтах                                                                     |
| isIndexFile(path) const                    | Расширение из списка служебных форматов, где поиск строк не имеет смысла                           |

**analyze(file_path)** - порядок: открытие файла -> проверка подписи (в отдельном потоке с таймаутом 3 сек) -> энтропия -> PE-заголовок и импорты -> строки -> корректировка счёта по подписи (доверенный издатель - деление на 2-3, неподписанный PE - штраф +10) -> при подписи и счёте выше 30 - онлайн- проверка отзыва сертификата (+40 при отзыве) -> неподписанный файл в системном/пакетном каталоге - счёт вдвое ниже -> calculateVerdict.

**analyzePeHeader(file_path, result)** - разбор DOS/PE-заголовков по сырым байтам: отсутствие таблицы импорта при UPX-секциях (+20), точка входа вне .text (+35 или +10 при подписи), UPX-секции (+15), секции RWX (+30), случайные имена секций (+20).

**analyzeImports(path, result)** - разбор таблицы импорта (32/64-бит, лимит 500 библиотек / 5000 функций), для каждой функции - checkImportRule.

**checkImportRule(func_name, result)** - совпадение по правилам из JSON (без учёта регистра и суффикса A/W) либо запасной список из 18 классических подозрительных функций (VirtualAllocEx, WriteProcessMemory, CreateRemoteThread, NtUnmapViewOfSection и другие).

**analyzeStrings(file_path, result)** - поиск фраз из правил либо запасного списка (биткоин, текст вымогателя, .onion, скрытный запуск cmd.exe/powershell -enc, автозагрузка реестра); совпадение, уже засчитанное как импорт, не дублируется.

**calculateEntropy(file_path)** - энтропия Шеннона по гистограмме частот 256 значений байта.

**checkDigitalSignature(file_path)** - офлайн WinVerifyTrust; при отсутствии встроенной подписи - проверка каталожной подписи (verifyCatalogSignature).

**verifyCatalogSignature(wide_path)** - хэш файла через CryptCATAdminCalcHashFromFileHandle, поиск каталога подписи по хэшу, повторная проверка через WinVerifyTrust.

**extractSignatureInfo(file_path, check_revocation)** - извлечение имени подписанта, издателя, даты истечения, отпечатка сертификата; при check_revocation - полная онлайн-проверка цепочки, поэтому вызывается на отдельном потоке с таймаутом.

**prefetchCertificateCache()** (статический) - прогрев кэша проверки сертификатов на нескольких системных файлах перед полным сканированием компьютера.

### CrlUpdater (crl_updater.h / crl_updater.cpp)

| Метод                             | Описание                                |
| --------------------------------- | --------------------------------------- |
| CrlUpdater() / ~CrlUpdater()      | Деструктор останавливает фоновый поток  |
| start()                           | Запуск фонового потока (workerLoop)     |
| stop()                            | Остановка потока с ожиданием завершения |
| isRunning() const                 | Флаг работы потока                      |
| getStats() const                  | Копия статистики под мьютексом          |

**workerLoop()** - цикл обновления сразу при старте, затем раз в 4 часа (UPDATE_INTERVAL_SEC), прерывается сигналом остановки.

**updateCycle()** - сбор URL точек CRL из подписанных файлов в Program Files (collectCrlUrls), последовательное скачивание (downloadCrl).

**collectCrlUrls(directory)** - верхний уровень подкаталогов (не рекурсивно), не более 50 файлов за вызов.

**extractCrlUrlsFromFile(file_path)** - разбор встроенной подписи PKCS#7, декодирование расширения "точки распространения CRL" у каждого сертификата.

**downloadCrl(url)** - сначала из локального кэша Windows, затем прямым сетевым обращением с таймаутом 10 секунд.
