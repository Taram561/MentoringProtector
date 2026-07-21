## Файлы

| Файл | Описание |
|---|---|
| scan_action_service.dart | Действия над результатом сканирования: карантин, восстановление, удаление записи (ScanActionService, реализует IQuarantineService) |
| module_control_service.dart | Включение/выключение модулей защиты, перезагрузка YARA-правил (ModuleControlService, реализует IModuleControlService) |
| exclusion_service.dart | Список путей, исключённых из проверки (ExclusionService, реализует IExclusionService) |
| sandbox_service.dart | Запуск файла в песочнице, статус, отчёт (SandboxService, реализует ISandboxService) |
| smart_cache_service.dart | Инвалидация и очистка умного кэша (SmartCacheService, реализует ISmartCacheService) |
| vuln_service.dart | Сценарий исправления найденной уязвимости (VulnService, реализует IVulnService) |
| helper_bridge.dart | Запуск mp_helper.exe с повышением прав, строгая проверка формата команды (HelperBridge, HelperResult) |
| elevated_launcher.dart | Низкоуровневый запуск процесса через ShellExecuteEx (ElevatedLauncher, ElevatedRunResult) |
| db_updater.dart | Загрузка и разбор базы сигнатур ClamAV (CVD) как запасной путь обновления (DartCvdDownloader, DbUpdateResult) |
| reports_archive_service.dart | История отчётов о сканированиях и запусках в песочнице, с дедупликацией (ReportsArchiveService) |
| action_status_store.dart | Действие пользователя над записью истории, переживает перезапуск (ActionStatusStore, IncidentStatus) |
| threat_education_service.dart | Подбор обучающего материала по названию/категории угрозы (ThreatEducationService, ThreatEducation) |

## Классы и функции

### ScanActionService (scan_action_service.dart)

| Метод                                      | Описание                                                               |
| ------------------------------------------ | ---------------------------------------------------------------------- |
| restoreFile(entryId) / deleteFile(entryId) | Обёртки над FFI-вызовами, разбор в QuarantineSuccess/QuarantineFailure |
| getQuarantineList()                        | QuarantineList.empty() при недоступности биндинга, без исключения      |
| deletePhysicalFile(filePath)               | Прямое удаление файла (File.deleteSync) после _validatePath            |

**validatePath(rawPath)** - отклонение UNC/NT-путей, каноническая форма через p.canonicalize, требование абсолютного пути с буквой диска, отклонение .. и более одного :, отклонение защищённых системных и собственных каталогов приложения.

**quarantineFile({scanResult})** - validatePath перед вызовом FFI; провал валидации - QuarantineFailure без обращения к ядру.

### ModuleControlService (module_control_service.dart)

Прямая реализация IModuleControlService: каждый метод (startRealtime, stopRealtime, startProcessMonitoring, stopProcessMonitoring, startWebProtection, stopWebProtection, startMemoryScan, stopMemoryScan, reloadYaraRules) - проверка ненулевого указателя, вызов, перехват исключения с логом. Выбор между прямым вызовом и делегированием службе - на уровне ModuleStatusProvider ([providers.md](providers.md)).

### ExclusionService (exclusion_service.dart)

| Метод                 | Описание                                        |
| --------------------- | ----------------------------------------------- |
| getExclusions()       | Список текущих исключений                       |
| addExclusion(path)    | Нормализация (_normalizePath) перед добавлением |
| removeExclusion(path) | Удаление без нормализации (точное совпадение)   |

**normalizePath(raw)** - маски .расширение пропускаются как есть; обычные пути отклоняются при \\/\??\, канонизируются, отклоняются при .. или более одном :.

### SandboxService (sandbox_service.dart)

Реализация ISandboxService: isSupported, run(filePath), getStatus(), getReport(), cancel() - каждый метод при ошибке возвращает безопасное значение по умолчанию вместо исключения.

### SmartCacheService (smart_cache_service.dart)

isAvailable, invalidateCache(), clearCache() - обёртки, проверяющие status == 'ok' в ответе.

### VulnService (vuln_service.dart)

getFixDescriptor(vulnId) - только поле helper_arg из ответа ядра; requires_reboot отбрасывается - решение принимается позже по HelperResult.rebootRequired.

### HelperBridge и ElevatedLauncher

**ElevatedLauncher (elevated_launcher.dart)**:

| Метод/функция                       | Описание                                                                                                                           |
| ----------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| _runExclusive(exePath, args)        | Запуск в отдельном изоляте (таймаут 120 сек), ожидание завершения опросом WaitForSingleObject до 15 секунд, затем TerminateProcess |
| _launchElevatedBlocking(payload)    | ShellExecuteExW с глаголом "runas" и SEE_MASK_NOCLOSEPROCESS                                                                       |
| _quoteArg(arg)                      | Экранирование кавычек аргумента                                                                                                    |
| createElevatedOutputPath()          | Уникальный путь во временном каталоге для файла результата                                                                         |

**ElevatedLauncher.run(exePath, args)** - все вызовы сериализуются через цепочку Future (queue) - второй запрос UAC ждёт завершения первого.

**HelperBridge (helper_bridge.dart)**:

| Метод                                     | Описание                                                             |
| ----------------------------------------- | -------------------------------------------------------------------- |
| runServiceCmd(cmd) / runServiceCmds(cmds) | Проверка регулярным выражением _kServiceCmdRe до обращения к хелперу |
| runFix(vulnId)                            | Аналогично с _kVulnIdRe; код 1223 распознаётся как userCancelled     |

**runElevatedHelper(args)** - проверка цифровой подписи mp_helper.exe через ядро (verifyHelperExe) перед запуском; результат читается из временного файла (--output-file), файл удаляется в finally.

### DartCvdDownloader (db_updater.dart)

| Метод                            | Описание                                                                                           |
| -------------------------------- | -------------------------------------------------------------------------------------------------- |
| fetchAndApply()                  | Скачивание и разбор средствами Dart, при ошибке - откат на _fallbackPython                         |
| verifySignaturesOnStartup()      | При старте: без базы - пропуск; без сохранённого отпечатка - _bootstrapPin; иначе _verifyIntegrity |
| _bootstrapPin()                  | Разовое вычисление SHA-256 существующей базы как доверенного отпечатка                             |
| _fallbackPython()                | Запуск updater/fetch_signatures.py внешним процессом (python/python3/py)                           |
| _ffiReload()                     | Перечитывание базы сигнатур ядром после обновления                                                 |
| _md5Hex(data) / _sha256Hex(data) | Хэши средствами Dart                                                                               |

**downloadAndParse()** - скачивание CVD ClamAV, проверка заголовка и контрольной суммы MD5, распаковка BZip2/TAR, фильтрация записей Android; атомарная запись через .tmp; вычисление и сохранение отдельного SHA-256-отпечатка проекта.

**verifyIntegrity()** - при маркере .pin_required несовпадение SHA-256 или отсутствие отпечатка - исключение (возможная подмена файла); без маркера - не ошибка (fail-closed только после первого включения пиннинга).

### ReportsArchiveService (reports_archive_service.dart)

| Метод                                 | Описание                                                                                |
| ------------------------------------- | --------------------------------------------------------------------------------------- |
| cleanDuplicates()                     | Одна запись на уникальный ключ (путь+хэш или id), перезапись при удалении               |
| loadAll({limit})                      | Построчное чтение JSONL, повреждённые строки пропускаются, сортировка от новых к старым |
| search({query, type, minDangerLevel}) | Фильтрация загруженного списка                                                          |
| deleteOne(id) / clear()               | Удаление записи/архива целиком                                                          |
| _rotateIfNeeded(file)                 | Обрезка файла свыше 10000 строк до последних 5000                                       |
| _rewriteFile(reports)                 | Полная перезапись файла                                                                 |
| _loadDedupCache()                     | Набор виденных ключей из существующего архива                                           |

**append(report)** - операции сериализуются через writeLock; дедупликация по путь+хэш для записей "сканирование"; формат JSON Lines позволяет дозапись без перезаписи всего файла.

### ActionStatusStore (action_status_store.dart)

Одиночка с картой путь_записи -> IncidentStatus в SharedPreferences; getStatus(reportKey) возвращает pending по умолчанию.

### ThreatEducationService (threat_education_service.dart) и ThreatEducation

| Метод                                        | Описание                                                                                          |
| -------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| load()                                       | Чтение data/threat_database.json, построение индексов по названию и по типу; выполняется один раз |
| _normalizeType(type)                         | Строка типа угрозы к одной из 9 канонических категорий                                            |
| _hasContent(info)                            | Содержательность записи по наличию шагов удаления/описания распространения                        |

**lookup(...)** - трёхуровневый откат: переданная ThreatInfo -> точное название в базе -> нормализованная категория -> пустая заглушка с самым общим уровнем.