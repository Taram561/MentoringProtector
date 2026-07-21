## Файлы

| Файл | Что описывает | Ключевые типы |
|---|---|---|
| scan_result.dart | Результат проверки одного файла | ScanResult, DetectionMethod, SeverityLevel |
| heuristic_result.dart | Результат эвристического и YARA-анализа, информация о цифровой подписи | HeuristicResult, YaraMatchResult, SignatureInfo |
| threat_info.dart | Развёрнутое объяснимое описание угрозы | ThreatInfo |
| quarantine_entry.dart | Запись файла, помещённого в карантин | QuarantineEntry |
| process_alert.dart | Предупреждение о подозрительном процессе | ProcessAlert, ProcessDetectionMethod |
| process_analysis.dart | Подробный разбор конкретного процесса | ProcessAnalysis, ProcessModule |
| dll_injection_alert.dart | Предупреждение об инъекции кода в процесс | DllInjectionAlert |
| realtime_event.dart | Событие защиты в реальном времени | RealtimeEvent |
| memory_threat.dart | Угроза, найденная при сканировании памяти процесса | MemoryThreat |
| vulnerability.dart | Найденная уязвимость конфигурации и отчёт по ним | Vulnerability, VulnerabilityReport |
| sandbox_report.dart | Отчёт о поведении файла в песочнице | SandboxReport, BehavioralEvent |
| archived_report.dart | Запись истории (сканирование или запуск в песочнице) | ArchivedReport, ArchivedReportType |
| scan_history.dart | Статистика сканирований по дням | ScanHistory, DailyScan |
| threat_stats.dart | Статистика найденных угроз по дням и по движку | ThreatStats, DailyStats, ThreatSource |
| threat_sources_aggregate.dart | Агрегированные данные для диаграммы источников угроз | ThreatSourcesAggregate |
| smart_cache_stats.dart | Статистика попаданий/промахов умного кэша | SmartCacheStats |
| nudge.dart | Обучающая подсказка от ядра | Nudge, NudgeCategory |
| nudge_education.dart | Обучающий текст для категории подсказки | NudgeEducation |
| user_profile.dart | Профиль пользователя: уровень, история событий, индекс гигиены, квизы | UserProfile, UserLevel, RiskTier, RiskEvent, RiskEventType, QuizResult, HygieneSnapshot |

## Классы и функции
### scan_result.dart

| Объект                 | Поля / методы                                                                                                                                                                                                                                                     |
| ---------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| DetectionMethod (enum) | signature, yara, heuristic, archiveScan, clean                                                                                                                                                                                                                    |
| SeverityLevel (enum)   | info/warning/high/critical; fromDangerLevel(level) - границы ≤2/≤5/≤8; color/adaptiveColor/icon                                                                                                                                                                   |
| ScanResult             | isInfected, filePath, fileHash, threatName, threatType, dangerLevel, threatInfo, heuristic, detectionMethod, enginesTriggered; severity через SeverityLevel.fromDangerLevel; archiveInnerPath извлекает путь внутри архива из суффикса (inside: ...) в threatName |

### heuristic_result.dart

| Объект          | Поля                                                                                                                                                                                                                            |
| --------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| SignatureInfo   | isValid, isRevoked, signerName, issuer, expiryDate, thumbprint, revocationStatus; hasInfo                                                                                                                                       |
| YaraMatchResult | ruleName, ruleNamespace, metaAuthor, metaDesc, metaSeverity, metaReference, tags, matchedStrings                                                                                                                                |
| HeuristicResult | suspicionScore, verdict, dangerLevel, entropy, isPeFile, isPacked, hasSignature, signature, triggeredRules, suspiciousImports, suspiciousStrings, analyzed, yaraScore, yaraScanTimeMs, yaraMatches; verdictLabelLocalized(l10n) |

### threat_info.dart (ThreatInfo)

Поля: name, displayName, type, dangerLevel, descriptionShort, descriptionFull, howItSpreads, whatItDoes, recommendedAction, removalSteps, preventionTips, hygieneCategory, isFound. Фабрики: fromJson, unknown(name) (зеркалит ThreatDatabase::createUnknown в ядре), empty().

### quarantine_entry.dart (QuarantineEntry)

Поля: id, originalName, originalPath, threatName, threatType, dangerLevel, dateQuarantined, fileSize, detectionMethod, isOrphan. fileSizeLabel форматирует Б/КБ/МБ.

### process_alert.dart

| Сущность | Поля / методы |
|---|---|
| ProcessDetectionMethod (enum) | signature, heuristic, unknown |
| ProcessAlert | pid, processName, exePath, fileHash, suspicionScore, verdict, threatName, dangerLevel, detectionMethod, detectedAt, isBlocked, triggeredRules; isDangerous, isSuspicious |

### process_analysis.dart

ProcessModule (name, size) и ProcessAnalysis (pid, processName, exePath, parentPid, cmdline, fileHash, digitalSignature, score, verdict, dangerLevel, method, modules).

### dll_injection_alert.dart (DllInjectionAlert)

Поля: processName, pid, dllPath, reason, score, detectedAt.

### realtime_event.dart (RealtimeEvent)

Поля: isThreat, verdict, score, action, filePath, threatName, detectedAt; fileName извлекает имя файла, определяя разделитель по содержимому строки (путь всегда в формате Windows).

### memory_threat.dart (MemoryThreat)

Поля: processName, threatName, pid, matchesCount, exePath, memoryScanned, regionsScanned, matchedSignatures, dangerLevel (по умолчанию 7, если поле отсутствует в JSON).

### vulnerability.dart

| Объект              | Поля / методы                                                                        |
| ------------------- | ------------------------------------------------------------------------------------ |
| Vulnerability       | id, title, description, severity, affectedComponent, howToFix, moreInfo, autoFixable |
| VulnerabilityReport | scannedAt, osVersion, vulnerabilities; critical/high/medium/low, счётчики, total     |

### sandbox_report.dart

BehavioralEvent (type, target, detail, timestamp) и SandboxReport (completed, durationSeconds, riskScore, timedOut, riskIndicators, events).

### archived_report.dart

| Объект                    | Поля / методы                                                                                                                                                                                                        |
| ------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ArchivedReportType (enum) | scan, sandbox                                                                                                                                                                                                        |
| ArchivedReport            | id, type, timestamp, filePath, fileName, dangerLevel, threatName, detectionMethod, scanExtras, sandboxData; fromScanResult(r) и fromSandboxRun(r, sr) формируют id из времени в микросекундах плюс начала хэша файла |

### scan_history.dart

DailyScan (date, scans, filesScanned) и ScanHistory (periodDays, daily, totalScans, totalFiles); fromJson бросает FormatException при поле error в ответе ядра.

### threat_stats.dart

ThreatSource (enum: scan/realtime/memory/web), DailyStats (date, threats, счётчик на источник), ThreatStats (periodDays, daily, total); bySource суммирует все дни в Map<ThreatSource, int>.

### threat_sources_aggregate.dart (ThreatSourcesAggregate)

Поля: periodDays, scan, realtime, memory, web, total - агрегированы ядром напрямую.

### smart_cache_stats.dart (SmartCacheStats)

Поля: hits, misses, entries, invalidations, hitRate.

### nudge.dart

| Объект               | Поля / методы                                                                                             |
| -------------------- | --------------------------------------------------------------------------------------------------------- |
| NudgeCategory (enum) | downloadedExe, macroDocument, suspiciousScript, usbDevice, downloadedContainer; fromString(s); isSecurity |
| Nudge                | category, detail, context, severity, detectedAt                                                           |

### nudge_education.dart (NudgeEducation)

Поля: titleKey, tipKey, checklistKeys, actionKeys - ключи локализации, не готовый текст. of(cat) возвращает запись по категории, с откатом на downloadedExe.

### user_profile.dart

| Объект                            | Поля / методы                                                         |
| --------------------------------- | --------------------------------------------------------------------- |
| UserLevel (enum)                  | beginner/regular/advanced; fromId(id) с откатом на regular            |
| RiskTier (enum)                   | safe/cautious/risky/dangerous; fromScore(score) - границы <20/<40/<70 |
| RiskEventType (enum с параметром) | 12 типов событий, вес от -10 до +25                                   |
| RiskEvent                         | type, timestamp, detail; компактная сериализация (type/ts/detail)     |
| QuizResult                        | correct, total, date; ratio, isPerfect                                |
| HygieneSnapshot                   | score, date                                                           |

**UserProfile** - единственная модель с содержательной логикой: riskScore суммирует веса событий за последние 30 дней, ограничен 0-100; riskTier переводит через RiskTier.fromScore; positiveActions / riskyActions считают число событий по знаку веса; addEvent(event) обрезает историю до 200 записей; toJson()/fromJson(json) сериализуют весь профиль (нет аналога в ядре - хранится локально).
