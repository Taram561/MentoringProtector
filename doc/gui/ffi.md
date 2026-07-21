## Файлы

| Файл | Описание |
|---|---|
| core_bindings.dart | Загрузка DLL, разрешение символов, проверка версии API |
| core_service.dart | Высокоуровневая обёртка над CoreBindings: сканирование файла (в отдельном изоляте), проверка уязвимостей |
| app_paths.dart | Вычисление путей к DLL, хелперу и файлам данных |
| service_interfaces.dart | Абстрактные интерфейсы сервисов, реализуемые в services/ |
| core_result.dart | Вспомогательные структуры разбора JSON-ответов ядра |

## Классы и функции

### CoreBindings (core_bindings.dart)

| Метод                                                                                                                                                                | Описание                                                                                                                                  |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| CoreBindings._internal() (приватный конструктор)                                                                                                                     | Загрузка библиотеки по AppPaths.dllPath, разрешение всех символов (_bindAll)                                                              |
| instance (статическое свойство)                                                                                                                                      | Единственный уже инициализированный экземпляр; StateError, если tryInitialize не вызывался                                                |
| isInitialized (статическое свойство)                                                                                                                                 | Проверка без попытки создания                                                                                                             |
| _bindAll()                                                                                                                                                           | Разрешение по имени функций из exports.h ([../core/exports_ffi.md](../core/exports_ffi.md)) - часть обязательна, остальные через _tryBind |
| serviceHosting (свойство)                                                                                                                                            | Спрашивает у ядра, отвечает ли служба на пинг (mp_service_is_running)                                                                     |
| callReturningString/callWithOneStringArg/callWithIntArg/callQuarantineFile/callStartWeb/callReloadDb/callGetThreatStats/callGetScanHistory/callGetThreatSources(...) | Однотипные обёртки: Arena для временных нативных строк, вызов, декодирование результата, освобождение через freeString в finally          |


**tryInitialize()** - создание CoreBindings, сверка старшего байта версии API (mp_get_api_version) с ожидаемой (kApiMajor); несовпадение - управляемая ошибка DllInitFailure вместо работы с недостоверным ABI.

**tryBind(bind)** - отсутствующий в загруженной DLL символ оставляет поле null, не проваливая инициализацию целиком; вызывающий код обязан проверять на null.

**ptrToString(ptr) / decodeWindows1251(bytes)** - основной путь UTF-8; при FormatException - резервная интерпретация как Windows-1251.

### CoreService (core_service.dart)

| Метод                                              | Описание                                                           |
| -------------------------------------------------- | ------------------------------------------------------------------ |
| coreVersion (свойство)                             | Версия ядра через getCoreVersion                                   |
| getActiveEngines()                                 | Разбор JSON get_active_engines в список строк, с защитой от ошибки |
| scanFile(filePath) (реализация IScannerService)    | Делегирует в _scanWorker.scanFile, разбор результата в ScanResult  |
| getFileHash(filePath) (реализация IScannerService) | get_file_hash асинхронно (Future.delayed, не изолят)               |
| scanVulnerabilities()                              | scan_vulnerabilities, разбор в VulnerabilityReport                 |
| _parseScanResult/_parseVulnerabilityReport(...)    | Разбор JSON с защитой от ошибок                                    |

**ScanWorker** - фоновый изолят Dart для сканирования файлов:

| Метод                           | Описание                                                                                    |
| ------------------------------- | ------------------------------------------------------------------------------------------- |
| scanFile(filePath)              | Команда в изолят через порт, таймаут 120 сек (по истечении - JSON с "error":"scan_timeout") |
| _handleResponse(message, ready) | Разбор сообщений: готовность, ошибка инициализации, результат/ошибка по requestId           |
| _failWorker(error, stackTrace)  | Крах изолята - все ожидающие запросы заваливаются, порты закрываются                        |

**ensureCommandPort()** - ленивый Isolate.spawn при первом сканировании, подписка на onError/onExit; повторные вызовы переиспользуют живой изолят.

**scanWorkerMain(responsePort)** - заново вызывает CoreBindings.tryInitialize() и core_initialize() - изолят не разделяет память с основным потоком.

### AppPaths (app_paths.dart)

| Метод                                                                                                                                           | Описание                                                    |
| ----------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------- |
| dllPath (свойство)                                                                                                                              | Рядом с exe, затем в корне проекта, затем голое имя файла   |
| helperExePath / dataDir / phishingDomainsPath / safeDomainsPath / signaturesPath / heuristicRulesPath / threatDatabasePath / extensionChromeDir | Пути к ресурсам относительно каталога exe или корня проекта |


**resolveProjectRoot()** - поиск каталога с data/ от рабочего каталога (до 6 уровней), затем от каталога исполняемого файла (до 10 уровней) - отражает сценарии разработки и портативного дистрибутива.

### service_interfaces.dart

Только объявления: IExclusionService, IModuleControlService, IQuarantineService, ISandboxService (плюс SandboxRunResult), IScannerService, ISmartCacheService, IVulnService.

### core_result.dart

| Объект                                                                                 | Описание                                                                                       |
| -------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| QuarantineOperationResult (sealed class, варианты QuarantineSuccess/QuarantineFailure) | Типобезопасный результат операции карантина                                                    |
| QuarantineList                                                                         | Список записей карантина со счётчиком и суммарным размером; totalSizeLabel форматирует Б/КБ/МБ |
