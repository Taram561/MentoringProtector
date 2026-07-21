# Экраны

Каждый подкаталог - один раздел интерфейса: экран верхнего уровня плюс собственные виджеты в widgets/. Переиспользуемые в разных экранах виджеты - отдельно, в widgets/ верхнего уровня.

## Онбординг

| Файл | Назначение |
|---|---|
| onboarding/onboarding_screen.dart | Первый запуск: знакомство с приложением в несколько шагов |

## Главный экран

| Файл | Назначение |
|---|---|
| home/home_screen.dart | Общий обзор состояния защиты |
| home/widgets/status_card.dart | Карточка общего статуса защиты |
| home/widgets/active_engines_chip.dart | Индикатор активных движков обнаружения |
| home/widgets/db_status_card.dart | Карточка состояния баз (версия, дата обновления) |
| home/widgets/events_list.dart | Список последних событий защиты |
| home/widgets/security_profile_card.dart | Карточка выбранного профиля безопасности |
| home/widgets/stats_preview_card.dart, stats_row.dart | Краткая сводка статистики |

### Классы и функции - главный экран

| Класс | Описание |
|---|---|
| HomeScreen | Список карточек; статус защиты по числу активных модулей (≥2 - защищено, 1 - предупреждение, 0 - опасность) |
| _ProtectionToggleButton | Кнопка "включить/выключить всю защиту" - ModuleStatusProvider.enableAllProtection/disableAllProtection, запись события риска, предложение квиза при отключении |
| StatusCard | Статус, число активных модулей (N / 5), кнопка сканирования |
| ActiveEnginesChip | Однократный запрос списка движков в initState напрямую через CoreService |
| DbStatusCard / _updateDb | Кнопка обновления через DartCvdDownloader.fetchAndApply, обновление DbStatusProvider и EventsProvider |
| EventsList / _resolveMessage / _buildTile | До 3 подсказок поверх списка из 8 событий; _resolveMessage переводит ключ локализации в текст при отрисовке |
| _NudgeBanner | Для USB-подсказок - динамический статус автосканирования вместо статичного текста |
| SecurityProfileCard | 100 - riskScore профиля, полоса прогресса по RiskTier |
| StatsPreviewCard | Сумма угроз за 7 дней из уже загруженной StatsProvider.threatStats |
| StatsRow / _StatCard | Пара карточек статистики, переиспользуемая с разными данными |

## Сканирование

| Файл | Назначение |
|---|---|
| scan/scan_screen.dart | Экран запуска и просмотра сканирования |
| scan/scan_controller.dart | Логика управления процессом сканирования |
| scan/widgets/scan_target_selector.dart | Выбор цели сканирования (файл, папка, диск) |
| scan/widgets/scan_progress_card.dart | Индикатор хода сканирования |
| scan/widgets/scan_results_widget.dart, scan_result_tile.dart | Список результатов и строка результата |
| scan/widgets/threat_detail_sheet.dart | Объяснимая карточка угрозы |
| scan/widgets/sandbox_report_sheet.dart | Просмотр отчёта запуска в песочнице |

### Классы и функции - сканирование

**ScanController** - конечный автомат (ScanState: ScanIdle/ScanRunning/ ScanFinished/ScanError, sealed class).

| Метод                                          | Описание                                                                            |
| ---------------------------------------------- | ------------------------------------------------------------------------------------- |
| scanFile(path) / scanDirectory(path)           | Разовое сканирование либо рекурсивный сбор файлов (_collectFiles) и запуск _startScan |
| stopComputerScan()                             | Остановка таймера опроса, scan_computer_stop, архивация результатов, ScanFinished     |
| cancel()                                       | Снятие паузы перед остановкой, ветвление на stopComputerScan или обычное завершение   |
| pause() / resume()                             | Приостановка/возобновление опроса прогресса или цикла файлов (через Completer)        |
| reset()                                        | Возврат в ScanIdle, очистка результатов                                               |
| _pollComputerProgress()                        | Опрос scan_computer_get_progress раз в 500 мс, защита флагом _polling                 |
| _archiveAll()                                  | Добавление результатов в ReportsArchiveService                                        |
| _collectFiles(dirPath) / _shouldSkip(filePath) | Обход каталога с пропуском служебных подкаталогов и файлов ядра/сборки                |

**scanComputer()** - прогрев YARA (ensureYaraReady), затем scan_computer_start асинхронно (Future.delayed(Duration.zero), чтобы успеть отрисовать начальное состояние), запуск опроса прогресса.

**ensureYaraReady()** - запрос статуса YARA плюс сканирование несуществующего пути __warmup__ для прогрева изолята _ScanWorker.

**startScan(files)** - сканирование по одному с проверкой отмены/паузы; пустой результат по всем файлам - повторный проход целиком (защита от гонки при холодном старте изолята).

**ScanScreen** - собственное состояние (ScanScreenState), слушает ScanController вручную (addListener + setState).

| Метод                                                          | Описание                                                                                                                         |
| -------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| _showThreatDetails(result, l10n)                               | ThreatDetailSheet в модальном диалоге; кнопка "песочница" при опасности ≥3 либо угрозе внутри архива                               |
| _quarantineFile / _deleteFile / _ignoreResult / _whitelistFile | Действия над угрозой, запись события риска, удаление из списка результатов                                                         |
| _runSandbox(result, l10n)                                      | Извлечение файла из архива при необходимости, запуск через SandboxService, SandboxReportSheet, удаление временного файла в finally |
| _sandboxErrorText(code, l10n)                                  | Код ошибки песочницы в локализованный текст                                                                                        |

**extractForSandbox(result)** - при угрозе внутри архива (archiveInnerPath) - распаковка конкретной записи ZIP во временный файл с префиксом mp_sandbox_.

**ThreatDetailSheet** - разворачивает ScanResult в объяснимую карточку. buildEducationalSections строит до пяти секций через ThreatEducationService с запасным текстом по категории. SuspicionScoreBar, FilePropertiesRow, SignatureDetailsCard визуализируют оценку, признаки файла и подпись.

**SandboxReportSheet** - опрос статуса раз в 2 секунды до completed/ cancelled (архивация отчёта) или error. ReportBody.groupEvents группирует события по типу.

## Карантин

| Файл | Назначение |
|---|---|
| quarantine/quarantine_screen.dart | Список файлов в карантине, восстановление и удаление |

### Классы и функции - карантин

QuarantineScreen загружает список при инициализации (ScanActionService) и обновляет счётчик в ModuleStatusProvider. restore/delete/ removeOrphan требуют подтверждения (ConfirmDialog); ошибка не перезагружает список. Записи с isOrphan показываются с отдельным значком и единственным действием "убрать из списка".

## Защита в реальном времени и мониторинг процессов

| Файл | Назначение |
|---|---|
| realtime_monitor/realtime_monitor_screen.dart | Включение защиты в реальном времени, лента событий |
| process_monitor/process_monitor_screen.dart | Список отслеживаемых процессов и предупреждений |
| process_monitor/widgets/process_inspect_sheet.dart | Подробности по конкретному процессу |
| memory_scan/memory_scan_screen.dart | Запуск и просмотр результатов сканирования памяти |

### Классы и функции - реальное время, процессы, память

Общий шаблон трёх экранов: кнопка старт/стоп, периодический опрос ядра (Timer.periodic, 500 мс - 2 с), список результатов с обрезкой до 50-200 записей, запись значимых происшествий в EventsProvider.

**RealtimeMonitorScreen** - start()/stop() ветвятся по serviceHosting (служба - HelperBridge.runServiceCmd, иначе прямой FFI). pollEvents() уведомляет по изменению счётчика угроз, а не на каждое событие. pollDllAlerts() - только если dllSupported (из статуса ETW).

**ProcessMonitorScreen** - опрос режима мониторинга (etw/polling/off), предупреждение при резервном режиме. Список группируется по опасности тремя блоками.

**ProcessInspectSheet** - по требованию вызывает analyze_process: PID родителя, командная строка, подпись, модули (до 20).

**MemoryScanScreen** и **MemoryThreatSheet** - действия onTerminate (завершить процесс) и onQuarantine (карантин исполняемого файла с синтетическим именем memory_threat), под флагом busy.

## Веб-защита

| Файл | Назначение |
|---|---|
| web_protection/web_protection_screen.dart | Состояние веб-защиты, статистика заблокированных ссылок |

### Классы и функции - веб-защита

**UrlCheckEvent** - неизменяемая запись одной проверки URL, только в рамках сессии экрана.

**_WebProtectionScreenState**:

| Метод                                                                                                  | Описание                                                         |
| ------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------ |
| initState()                                                                                            | Первый опрос статуса, таймер каждые 3 секунды                      |
| dispose()                                                                                              | Остановка таймера, освобождение контроллера                        |
| _loadToken()                                                                                           | Токен авторизации через FFI                                        |
| _regenerateToken(l10n, colors)                                                                         | Подтверждение, webProtectionRegenerateToken, перечитывание токена  |
| build(context)                                                                                         | Статус, (если запущено) токен + проверка + журнал, иначе подсказка |
| _buildStatusCard/_buildTokenCard/_buildUrlChecker/_buildEventsList/_buildEventTile/_buildHintCard(...) | Карточки соответствующих секций                                    |
| _showEventDetail(event, l10n, colors)                                                                  | _WebThreatDetailSheet в Dialog                                     |

**refreshStatus()** - опрос webProtectionIsRunning/webProtectionThreatsCount, setState только при реальном изменении; при запущенном сервере без токена - сразу loadToken().

**startServer() / stopServer()** - паттерн служба/напрямую: при serviceHosting - HelperBridge.runServiceCmd, иначе прямой FFI; после успеха - событие риска и, при отключении, предложение квиза.

**checkUrl()** - webProtectionCheckUrl, разбор JSON, новое событие в начало списка (лимит 50).

**_WebThreatDetailSheet**:

| Метод                                                                                          | Описание                                                                |
| ---------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------- |
| build(context)                                                                                 | Заголовок, шкала риска, чипы, блок омоглифа, причины, обучающая подсказка |
| _buildChip/_buildHomoglyphCard/_buildSectionHeader/_buildReasonTile/_buildTeachableMoment(...) | Элементы карточки                                                         |
| _localizedReason() / _reasonColor() / _scoreLabel() / _scoreColor() / _teachableTip()          | Локализация и цвет причины/оценки, текст подсказки                        |

**buildScoreBar()** - доля (score / 100).clamp(0.0, 1.0) через Stack/FractionallySizedBox; пороги локальны для веб-проверок, не совпадают с BLOCK/WARN серверной части.

## Уязвимости

| Файл | Назначение |
|---|---|
| vulnerability/vuln_screen.dart | Список найденных уязвимостей, запуск проверки, группировка по критичности |
| vulnerability/vuln_controller.dart | Пустой файл-заглушка, не используется |
| vulnerability/widgets/vuln_tile.dart | Строка одной уязвимости |
| vulnerability/widgets/vuln_detail_sheet.dart | Подробности и кнопка исправления |

### Классы и функции - уязвимости

**_VulnScreenState**:

| Метод                                                                                       | Описание                                                         |
| ------------------------------------------------------------------------------------------- | ---------------------------------------------------------------- |
| _startScan()                                                                                | CoreService.scanVulnerabilities(), сохранение отчёта либо ошибки |
| build(context)                                                                              | Кнопка сканирования, индикатор, ошибка или отчёт                 |
| _buildScanButton/_buildProgress/_buildError/_buildReport/_buildSummaryCard/_buildGroup(...) | Элементы экрана                                                  |
| _showDetails(v)                                                                             | VulnDetailSheet в bottom sheet                                   |

startScan() вызывает scan_vulnerabilities через CoreService; ошибка показывается напрямую.

**VulnCountStat**, **VulnTile** - тривиальны (число+подпись; строка списка с цветом по severityColor).

**_VulnDetailSheetState**:

| Метод                       | Описание                                                        |
| --------------------------- | --------------------------------------------------------------- |
| _severityColor(colors)      | Цвет по критичности                                             |
| _launchUrl(url)             | Ссылка "подробнее" через url_launcher                           |
| _showRebootDialog(appState) | Диалог "требуется перезагрузка"                                 |
| build(context)              | Заголовок, описание, инструкция, кнопка автоисправления, ссылка |

**runAutoFix()** - аргумент хелпера из vuln.id, либо явный дескриптор из VulnService.getFixDescriptor(id); HelperBridge.runFix(helperArg); три исхода - отмена UAC (userCancelled), неудача, успех (с проверкой rebootRequired).

## Общая защита

| Файл | Назначение |
|---|---|
| protection/protection_screen.dart | Общее управление модулями защиты |
| protection/widgets/smart_cache_stats_sheet.dart | Статистика умного кэша сканирования |

### Классы и функции - общая защита

**_ProtectionScreenState**:

| Метод                    | Описание                                                          |
| ------------------------ | ----------------------------------------------------------------- |
| initState()              | После первого кадра - ModuleStatusProvider.refreshModuleStates()  |
| _refreshStates()         | Перечитывание состояний всех модулей                              |
| _toggleProcess(value)    | Мониторинг процессов через ModuleControlService, без ветки службы |
| _toggleWeb(value)        | Паттерн служба/напрямую, как _toggleRealtime                      |
| _toggleMemoryScan(value) | Через ModuleControlService, без ветки службы                      |
| _navigateTo(screen)      | Переход с фейдом, _refreshStates() после возврата                 |
| build(context)           | Плитки _ProtectionTile по разделам "базовая"/"расширенная" защита |

toggleRealtime()/toggleWeb() - служба/напрямую; toggleProcess()/ toggleMemoryScan() всегда напрямую (работают в процессе GUI независимо от хостинга ядра).

**ProtectionTile** - иконка меняется при isActive, бейдж ON/OFF только при onToggle, иначе стрелка перехода (showArrow).

**_SmartCacheStatsSheetState**:

| Метод                   | Описание                                                         |
| ----------------------- | ---------------------------------------------------------------- |
| initState()             | Обновление статистики умного кэша после первого кадра            |
| _coreAvailable (геттер) | SmartCacheService.isAvailable                                    |
| _onClear()              | Подтверждение (деструктивно) -> clearCache() -> обновление       |
| build(context)          | Заголовок, предупреждение, три StatChip, полоса hit rate, кнопки |

onInvalidate() вызывает invalidateCache() без подтверждения (не удаляет данные); _onClear() требует ConfirmDialog(isDestructive: true).

**HitRateBar** - цвет по порогам ≥70%/≥40%; тривиален.

## Статистика

| Файл | Назначение |
|---|---|
| stats/stats_dashboard_screen.dart | Дашборд статистики защиты |
| stats/widgets/stats_period_selector.dart | Выбор периода (день/неделя/месяц) |
| stats/widgets/threat_bar_chart.dart | Столбчатая диаграмма угроз по дням |
| stats/widgets/threat_sources_donut.dart | Круговая диаграмма источников угроз |
| stats/widgets/reports_history_view.dart | История сохранённых отчётов |

### Классы и функции - статистика

**_StatsDashboardScreenState**:

| Метод | Описание |
|---|---|
| initState() | Первая загрузка статистики за 30 дней |
| _load(days) | StatsProvider.refreshStats(days), ошибки только логируются |
| build(context) | Вкладки "Дашборд"/"История" (ReportsHistoryView) |
| _buildBody(statsState, colors, l10n) | Загрузка -> ошибка -> пустое состояние -> секции |

load() в try/finally; initialFetchDone отличает первую загрузку от переключений периода.

**HygieneSection** - тренд индекса гигиены, delta между первым и последним значением истории (от 2 точек), GenericSparkline.

**DeltaBadge**, **ThreatsActivitySection**, **EnginesSection**, **ThreatSourcesSection** - бейдж дельты; счётчик угроз + ThreatBarChart; четыре StatChip из ModuleStatusProvider; ThreatSourcesDonut либо заглушка.

**StatsPeriodSelector** - SegmentedButton 7/30/90 дней, тривиален.

**ThreatBarChart**:

| Метод                      | Описание                                                           |
| -------------------------- | ------------------------------------------------------------------ |
| build(context)             | Агрегация дневных данных в корзины, CustomPaint с _BarChartPainter |


**aggregateForPeriod()** - период ≤30 дней - день на столбец; длиннее - 13 корзин по ceil(period / 13) дней, значение - сумма угроз.

**BarChartPainter** - сетка из 4 линий (drawGrid), столбцы высотой value / maxValue (drawBars, ширина 60% слота), подписи X только в трёх точках (drawXAxisLabels). shouldRepaint сравнивает число корзин, максимум и метку времени последней.

**ThreatSourcesDonut**:

| Метод | Описание |
|---|---|
| build(context) | CustomPaint с диаграммой слева и _Legend справа |

**DonutPainter** - кольцо через drawArc, угол сегмента (value / total) * 2π, начало с -π/2; при total == 0 - серое кольцо-заглушка.

**Legend** / **LegendRow** - подписи с точкой цвета, количеством, процентом; тривиальны.

**_ReportsHistoryViewState**:

| Метод                            | Описание                                                    |
| -------------------------------- | ----------------------------------------------------------- |
| initState()                      | Подписка на ReportsArchiveService.instance, первая загрузка |
| dispose()                        | Отписка, отмена debounce, освобождение контроллера          |
| _load()                          | До 500 последних отчётов через loadAll                      |
| _clear()                         | Подтверждение (деструктивно) -> clear() -> перезагрузка     |
| _showDetails(r)                  | _ReportDetailSheet в bottom sheet                           |
| build(context)                   | Поиск, фильтр-чипы, список либо заглушка                    |
| _filterChip(label, type, colors) | ChoiceChip фильтра                                          |

**onArchiveChanged()** - debounce 300 мс, каждый вызов отменяет предыдущий таймер. **filtered** - фильтр по типу и поиск без учёта регистра по трём полям.

**ReportCard** - иконка по типу, цвет по опасности (пороги 9/6/3 - своя шкала).

**ReportDetailSheet** - пары ключ-значение; дополнительные данные через_pretty().

## Библиотека угроз и обучение

| Файл | Назначение |
|---|---|
| threat_library/threat_library_screen.dart | Каталог известных угроз с объяснимым описанием |
| threat_library/threat_library_entry_card.dart | Карточка одной записи каталога |
| threat_library/widgets/threat_card.dart | Компактное представление угрозы в списке |
| threat_library/widgets/threat_filters.dart | Фильтрация каталога по категории/типу |
| threat_library/widgets/threat_library_detail_sheet.dart | Развёрнутая карточка угрозы |
| hygiene/hygiene_screen.dart | Модуль цифровой гигиены: индекс, советы, квизы |
| hygiene/hygiene_data.dart | Статические данные советов по гигиене |
| hygiene/quiz_data.dart | Вопросы и ответы квизов |
| hygiene/quiz_suggestion.dart | Подбор релевантного квиза |
| hygiene/widgets/hygiene_index_card.dart | Карточка индекса гигиены |
| hygiene/widgets/hygiene_sparkline.dart | Мини-график динамики индекса |
| hygiene/widgets/tip_quiz_sheet.dart | Карточка совета или квиза |

### Классы и функции - библиотека угроз

**_ThreatLibraryScreenState**:

| Метод              | Описание                                               |
| ------------------ | ------------------------------------------------------ |
| initState()        | Подписка на поле поиска, ThreatEducationService.load() |
| dispose()          | Освобождение контроллера                               |
| build(context)     | Поиск и фильтры, счётчик, список либо заглушка         |

**filtered** - пусто до загрузки каталога; далее три условия одновременно: поиск по трём полям, тип угрозы, категория гигиены.

**ThreatLibraryEntryCard** - переход в каталог, тривиален.

**ThreatCard** - цвет по опасности (пороги 7/4 - независимая шкала).

**ThreatFilters** - два набора FilterChip, без состояния, колбэки наружу.

**ThreatLibraryDetailSheet**:

| Метод | Описание |
|---|---|
| show(context, info) | DraggableScrollableSheet |
| build(context) | Заголовок, описание, до пяти секций |
| _dangerColor(level, colors) | Цвет по опасности (пороги 7/4) |

Секции строятся условно по заполненности полей ThreatInfo; "Описание" разворачивается сразу, остальные - по тапу.

**EducationalSectionState** - bool expanded, переключение по тапу.

### Классы и функции - гигиена и обучающие квизы

**hygiene_data.dart** - алгоритм адаптивного обучения, функции верхнего уровня и статические данные:

| Функция/данные                                  | Описание                                                |
| ----------------------------------------------- | ------------------------------------------------------- |
| HygieneTipData.adaptiveDescription(l10n, level) | Текст под уровень пользователя                          |
| tipRiskMapping                                  | Карта: тип события риска -> совет гигиены               |
| allTips                                         | 12 советов с иконкой, цветом, текстами для трёх уровней |

**tipPriority()** - пройденный совет: -50; +20 за каждое связанное рискованное событие за 30 дней; для beginner - четыре базовых совета +10. Сортировка по убыванию значения.

**computeHygieneIndex()** - старт от 50; за пройденный совет +1..+3 по качеству квиза; по событиям риска за 30 дней: неверный ответ -4, рискованное событие -3, нейтральное/позитивное +2; итог clamp(0, 100).

**tipReasonText()** - null без связанных типов риска/событий за 30 дней, иначе - локализованная фраза по первому типу.

**_HygieneScreenState**:

| Метод                                 | Описание                                        |
| ------------------------------------- | ----------------------------------------------- |
| _openQuiz(ctx, tipId, l10n, provider) | showQuizDialog, сохранение результата и события |

**build()** - через addPostFrameCallback: resetQuizzesIfMonthPassed() при первой загрузке профиля, однократный snapshotHygieneIndex(). Список советов - по tipPriority; "рекомендованные" - первые 4 непройденных с положительным приоритетом.

**ThreatLibraryBanner**, **RecommendedTipCard** / **TipCard**, **QuizScoreBadge** - переход в каталог; карточки совета (с бейджем пройденного квиза у TipCard); бейдж "N/M".

**quiz_data.dart** - статическая структура allQuizzes (10 вопросов на каждый из 12 советов); правильный ответ всегда options[0] до перемешивания в QuizDialogState.

**_QuizDialogState**:

| Метод                             | Описание                                     |
| --------------------------------- | -------------------------------------------- |
| initState()                       | _reshuffleAll()                              |
| build(context)                    | Счётчик, прогресс-бар, вопрос либо результат |
| _buildQuestion(colors, l10n)      | Подсветка правильного/неверного, объяснение  |
| _buildResult(colors, l10n, total) | Итог, кнопки "заново"/"закрыть"              |
| _answer(shuffledIndex, isCorrect) | Фиксация выбора, счётчик правильных          |
| _next()                           | Следующий вопрос либо завершение сессии      |
| _retake()                         | Сброс прогресса, _reshuffleAll()             |

**reshuffleAll()** - перемешивание индексов вопросов, исключение уже виденных (seenIndices, персистентно); при пустом остатке - полный список заново; первые min(unseen.length, 5) в сессию. Варианты ответов перемешиваются отдельно (ShuffledOption.originalIndex для isCorrect).

**ShuffledOption** - пара индекс+текст, без логики.

**HygieneIndexCard**:

| Метод               | Описание                                                      |
| ------------------- | ------------------------------------------------------------- |
| _indexColor(colors) | Цвет: ≥75/≥50/≥30/иначе                                       |
| build(context)      | Круговой индикатор, изменение за неделю, счётчик, мини-график |

**computeChange()** - разница с последним снимком старше 7 дней; null без такого снимка.

**HygieneSparkline** / **SparklinePainter** - многоточие при <2 точек; иначе линия+заливка, диапазон фиксирован [0, 100], акцентная точка на последнем значении.

## Действия и настройки

| Файл | Назначение |
|---|---|
| action_center/action_center_screen.dart | Центр действий: сводка рекомендованных шагов |
| settings/settings_screen.dart | Основные настройки приложения |
| settings/exclusion_list_screen.dart | Управление списком исключений |
| help/help_screen.dart | Справочная информация внутри приложения |

### Классы и функции - действия и настройки

**_ActionCenterScreenState**:

| Метод                             | Описание                                                     |
| --------------------------------- | ------------------------------------------------------------ |
| initState()                       | Подписка на архив, первая загрузка                           |
| dispose()                         | Отписка, отмена debounce, освобождение контроллера           |
| _onArchiveChanged()               | Debounce 300 мс                                              |
| _filtered (геттер)                | Поиск по имени файла и названию угрозы                       |
| _groupByDate(reports, l10n)       | Группировка по дате: сегодня/вчера/иначе                     |
| _setStatus(r, status)             | Сохранение статуса в ActionStatusStore                       |
| _statusOf(r)                      | Текущий статус, по умолчанию pending                         |
| _whitelist(r, l10n)               | Исключение через ExclusionService, событие threatWhitelisted |
| build(context)                    | Загрузка либо содержимое                                     |
| _buildContent/_buildTimeline(...) | Поиск, счётчик, временная шкала                              |
| _toScanResult(r)                  | ScanResult из архивной записи                                |
| _parseMethod(s)                   | Строка метода -> DetectionMethod                             |

**load()** - фильтр dangerLevel > 0 - только реальные угрозы. Статусы связаны по timestamp.toIso8601String().

**showDetail()** - тот же ThreatDetailSheet, но кнопки действий - null, если статус уже не pending (кроме "узнать больше").

**DateHeader**, **IncidentCard**, **ActionRow** / **StatusBadge** - заголовок дат; карточка инцидента (полоса по опасности, пороги 8/5/3 - своя шкала, кнопки только при pending и существующем файле); строка кнопок и бейдж статуса.

**SettingsScreen** - декларативный StatelessWidget, список IconTile; логика в AppStateProvider.

**_ExclusionListScreenState**:

| Метод | Описание |
|---|---|
| initState() | Загрузка списка исключений после первого кадра |
| _loadExclusions() | ExclusionService.getExclusions() |
| _addExclusion(path) | Добавление, перечитывание списка |
| _removeExclusion(path) | Аналогично для удаления |
| _showAddDialog(l10n, colors) | _AddExclusionSheetContent |
| _confirmRemove(path, l10n, colors) | Подтверждение -> _removeExclusion |
| build(context) | Список с иконкой по типу, заглушка, кнопка добавления |

Тип исключения - эвристика по строке пути (. - маска, \// в конце - папка). Валидация - в ExclusionService.

**AddExclusionSheetContentState** - выбор папки/файла или ручной ввод, все три пути ведут к widget.onAddPath.

**_HelpScreenState**:

| Метод               | Описание                                                      |
| ------------------- | ------------------------------------------------------------- |
| _openUrl(url)       | Ссылка во внешнем браузере                                    |
| _navigateTo(screen) | Переход с фейдом                                              |
| build(context)      | О программе, ссылки, обучение, технологии с индикаторами, FAQ |

**reloadYara()** - ModuleControlService.reloadYaraRules(), snack по результату, обновление состояния модулей.

**BadgeChip** / **LinkTile** / **FaqTile** - тривиальны.
