## Файлы

| Файл | Что хранит | Ключевые типы |
|---|---|---|
| app_state_provider.dart | Готовность ядра, версия, активные модули защиты | AppStateProvider |
| db_status_provider.dart | Версия и дата обновления баз данных | DbStatusProvider |
| events_provider.dart | Накопленные события защиты в реальном времени | EventsProvider |
| module_status_provider.dart | Включение/выключение каждого модуля защиты | ModuleStatusProvider |
| nudge_provider.dart | Текущие обучающие подсказки, состояние сканирования USB | NudgeProvider, UsbScanState |
| stats_provider.dart | Статистика для дашборда | StatsProvider |
| user_profile_provider.dart | Профиль пользователя и индекс цифровой гигиены | UserProfileProvider |

## Классы и функции

### AppStateProvider (app_state_provider.dart)

| Метод/свойство | Описание |
|---|---|
| themeMode/locale/coreVersion/lastScanDate (геттеры) | Тема, язык, версия ядра, дата последнего сканирования |
| isDark (геттер) | При теме system - по яркости платформы, иначе по явному выбору |
| colors/flutterLocale/strings (геттеры) | Адаптивная цветовая схема, Locale, объект локализованных строк |
| coreReady (геттер) | Обёртка над CoreBindings.isInitialized |
| setTheme(mode)/setLocale(locale)/setCoreVersion(version) | Смена поля, notifyListeners() |
| saveLastScanDate() | Текущее время в SharedPreferences |
| _loadLastScanDate()/_loadCoreVersion() | Восстановление из конструктора, в try/catch |

### DbStatusProvider (db_status_provider.dart)

| Метод/свойство | Описание |
|---|---|
| lastDbUpdate/dbUpdating (геттеры) | Дата обновления баз / идёт ли обновление |
| dbIsOutdated (геттер) | true, если дата неизвестна или прошло больше 7 дней |
| setDbUpdating(v) | Переключает флаг обновления |
| setDbUpdated() | Фиксирует момент обновления, сбрасывает флаг, сохраняет на диск |
| _loadDbUpdateDate()/_saveDbUpdateDate() | Чтение/запись в SharedPreferences |

### EventsProvider (events_provider.dart)

| Метод                         | Описание                                             |
| ----------------------------- | ------------------------------------------------------ |
| appEvents (геттер)            | Неизменяемый список событий                            |
| addEvent(event)               | Добавление в начало, обрезка до 50 записей, сохранение |
| _loadEvents()/_saveEvents()   | Сериализация в SharedPreferences                       |

**migrateLegacyMessage(legacy)** - старые события без messageKey сопоставляются с новым ключом локализации по известным старым строкам; нераспознанный текст отбрасывается - персистентность хранит только ключи локализации.

### ModuleStatusProvider (module_status_provider.dart)

| Метод/свойство                                      | Описание                                                                                          |
| --------------------------------------------------- | --------------------------------------------------------------------------------------------------- |
| activeModulesCount (геттер)                         | Сумма пяти булевых флагов активности                                                                |
| allProtectionActive (геттер)                        | true, только если realtime/process/web/memory все активны (ETW не входит)                           |
| refreshModuleStates() / _refreshModuleStatesImpl()  | Опрос статуса каждого модуля через отдельный FFI-вызов в своём try/catch                            |
| refreshQuarantineCount() / refreshSmartCacheStats() | Точечные обновления одного показателя                                                               |
| _backgroundCoreInit(dllPath)                        | В отдельном изоляте через compute - загрузка DLL и core_initialize в фоне                           |
| _countYaraRulesFromDisk(yaraRulesDir)               | В отдельном изоляте: подсчёт вхождений rule  в .yar-файлах регулярным выражением, независимо от FFI |

**Конструктор** - после первого кадра отрисовки запускает backgroundCoreInit в изоляте, затем обновляет состояние модулей, карантина и YARA.

**enableAllProtection() / disableAllProtection()** - при активной службе (b.serviceHosting) realtime и веб-защита переключаются через HelperBridge.runServiceCmds; process-мониторинг и сканирование памяти - всегда напрямую FFI. При неактивной службе все четыре модуля - напрямую.

### NudgeProvider (nudge_provider.dart) и UsbScanState

| Метод/свойство                                                                  | Описание                                                                                       |
| ------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| pending (геттер)                                                                | Неизменяемый список текущих подсказок                                                            |
| usbScans (геттер)                                                               | Карта состояний автосканирования по подключённому накопителю                                     |
| consumeBalloonNudge() / consumeTrayClick()                                      | "Прочитать и сбросить"                                                                           |
| poll() / _pollNewNudges() / _pollTrayClick()                                    | Забор новых подсказок (nudge_get_pending), клик по трею (tray_consume_click)                     |
| _fireTrayBalloon(nudge) / _balloonTitle(cat) / _fireTrayBalloonRaw(title, body) | Всплывающее уведомление в трее                                                                   |
| onEngaged(nudge) / onIgnored(nudge)                                             | Удаление подсказки, запись события в профиль пользователя                                        |
| _removePending(nudge)                                                           | Удаление из очереди по категории+детали                                                          |
| retriggerUsbScan(nudge)                                                         | Сброс и повторный запуск сканирования диска                                                      |
| _collectUsbFiles(drivePath)                                                     | Рекурсивный обход накопителя с лимитами (10000 файлов, 50 МБ, служебные расширения пропускаются) |

**pollNewNudges()** - подсказка категории "USB-устройство" автоматически запускает сканирование накопителя (_startUsbAutoScan); остальные категории - всплывающее уведомление.

**startUsbAutoScan(nudge)** - последовательное сканирование файлов через CoreService.scanFile, обновление прогресса каждые 50 файлов, итоговое уведомление по завершении.

### StatsProvider (stats_provider.dart)

| Метод | Описание |
|---|---|
| refreshStats(days) | Три независимых отчёта за период, каждый в своём try/catch; ошибка одного не мешает остальным |

### UserProfileProvider (user_profile_provider.dart)

Обёртка над UserProfile с персистентностью в SharedPreferences.

| Метод                                                                          | Описание                                                     |
| ------------------------------------------------------------------------------ | -------------------------------------------------------------- |
| recentEvents (геттер)                                                          | События профиля за 30 дней, от новых к старым                  |
| completeOnboarding(level, goal)                                                | Завершение первичной настройки                                 |
| recordEvent(type, detail)                                                      | Добавление события риска, сохранение                           |
| setLevel(level)                                                                | Смена уровня опыта                                             |
| saveQuizResult(tipId, correct, total)                                          | Сохранение результата, только если не хуже уже сохранённого    |
| markTipCompleted(tipId) / markTipIncomplete(tipId)                             | Отметка темы пройденной/непройденной                           |
| resetQuizzesIfMonthPassed()                                                    | Сброс пройденных тем раз в 30 дней                             |
| snapshotHygieneIndex(currentIndex)                                             | Точка истории индекса не чаще раза в день, обрезка до 30 точек |
| _load() / _save()                                                              | Чтение/запись профиля в SharedPreferences                      |

**getSeenQuestions(tipId) / markQuestionsShown(...)** - отслеживание увиденных вопросов квиза по теме; при достижении общего числа вопросов запись удаляется - следующий показ начинает цикл заново.
