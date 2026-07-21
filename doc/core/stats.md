# Статистика и история

## Файлы

| Файл | Описание |
|---|---|
| stats_recorder.cpp / stats_recorder.h | Единая точка записи статистики, формирование JSON-отчётов по периодам |
| stats_storage.cpp / stats_storage.h | Хранение счётчиков по дням, сохранение/загрузка, ротация устаревших записей |
| stats_exports.cpp | Экспортируемые функции получения статистики и истории |

## Классы и функции

### StatsRecorder (stats_recorder.h / stats_recorder.cpp)

| Метод                                                                   | Описание                                                                  |
| ----------------------------------------------------------------------- | ------------------------------------------------------------------------- |
| instance() (статический)                                                | Единственный экземпляр                                                    |
| recordThreat(src, count)                                                | Увеличение общего и по-источнику счётчика угроз за сегодня                |
| recordScan(files_scanned)                                               | Увеличение счётчика сканирований и проверенных файлов                     |
| effectiveSource(defaultSrc) const                                       | Активная подмена источника для текущего потока либо значение по умолчанию |
| getThreatStatsJson/getScanHistoryJson/getThreatSourcesJson(period_days) | JSON-отчёт за период (до 90 дней)                                         |
| setStorageFilePathForTest(path) / resetForTest()                        | Сброс состояния для тестов                                                |
| storageForTest() / dirtyWritesForTest() const                           | Доступ к внутренностям для тестов                                         |
| currentDateString()                                                     | Сегодняшняя дата ГГГГ-ММ-ДД                                               |
| ensureLoadedLocked()                                                    | Ленивая загрузка файла статистики при первом обращении                    |
| flushIfThresholdExceeded()                                              | flush() при достижении порога изменений (50)                              |

**getStatsFilePath()** - путь к data/stats.db относительно расположения DLL, с запасными вариантами и созданием каталога при необходимости.

**flush()** - StatsStorage::rotate перед сохранением; счётчик "грязных" записей сбрасывается только при успешном сохранении.

**ScopedSourceOverride** - RAII на thread_local: временная подмена источника статистики на время блока кода; пример - RealtimeMonitor::scanFile засчитывает угрозу из Scanner::scanFile как найденную защитой в реальном времени, а не ручным сканированием.

### StatsStorage (stats_storage.h / stats_storage.cpp)

| Метод                                                                                   | Описание                                                             |
| --------------------------------------------------------------------------------------- | -------------------------------------------------------------------- |
| dayCounters(date)                                                                       | Счётчики для указанной даты (создание при отсутствии)                |
| rangeForDays(days) const                                                                | Непрерывный диапазон дат за N дней вплоть до сегодня, без "провалов" |
| rotate(keep_days)                                                                       | Удаление из памяти записей старше keep_days                          |
| allDays() const                                                                         | Константная ссылка на всю карту дней                                 |
| toJson() const / fromJson(json)                                                         | Сериализация/разбор в JSON с версией формата                         |
| todayString() / subtractDays(date, days) / isOlderThan(candidate, cutoff) (статические) | Работа с датами через системные функции Windows                      |

**load(path) / save(path)** - лимит чтения 64 МБ; атомарная запись через временный файл .tmp и MoveFileExW.
