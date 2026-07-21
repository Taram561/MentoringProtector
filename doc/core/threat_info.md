# Объяснимая база угроз

## Файлы

| Файл | Описание |
|---|---|
| threat_info.cpp / threat_info.h | Загрузка и поиск по объяснимой базе описаний угроз; данные - data/threat_database.json |

## Классы и функции

### ThreatDatabase (threat_info.h / threat_info.cpp)

| Метод                                                              | Описание                                                          |
| ------------------------------------------------------------------ | ----------------------------------------------------------------- |
| findByName(threat_name) const                                      | Точное совпадение; при отсутствии - заготовка через createUnknown |
| findByType(type) const                                             | Линейный перебор, все записи с указанной категорией               |
| getCount() const / isLoaded() const                                | Число загруженных записей / успешность загрузки                   |
| extractJsonString/extractJsonInt/extractJsonArray(json, key) const | Посимвольный разбор поля JSON по ключу                            |
| parseOneThreat(json_block) const                                   | Сборка одной записи из JSON-блока                                 |

**loadFromFile(json_path)** - разбор массива "threats" по подсчёту вложенности фигурных скобок, без json_utils; запись валидна при непустом поле name.

**createUnknown(threat_name)** - полноценная карточка с общими рекомендациями (карантин, полное сканирование, обновление баз) вместо пустой заглушки.
