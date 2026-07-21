# Сканер архивов

## Файлы

| Файл | Описание |
|---|---|
| archive_scanner.cpp / archive_scanner.h | Координация экстракторов, применение лимитов, вызов проверки для каждого извлечённого файла |
| iextractor.h | Общий интерфейс распаковщика архива и структуры результата/лимитов |
| zip_extractor.cpp / zip_extractor.h | Распаковка ZIP-архивов (через библиотеку miniz) |
| iso_extractor.cpp / iso_extractor.h | Чтение содержимого ISO-образов через монтирование средствами Windows |
| seven_zip_extractor.cpp / seven_zip_extractor.h | Распаковка 7-Zip-архивов через динамически загружаемую системную библиотеку |
| miniz.c / miniz.h, miniz_common.h, miniz_export.h, miniz_tdef.c / .h, miniz_tinfl.c / .h, miniz_zip.c / .h | Встроенная (vendored) сторонняя библиотека сжатия miniz |

## Классы и функции

### ArchiveScanner (archive_scanner.h / archive_scanner.cpp)

| Метод                            | Описание                                                                             |
| -------------------------------- | -------------------------------------------------------------------------------------- |
| addExtractor(extractor)          | Добавление распаковщика в список подключённых                                          |
| setScanCallback(cb)              | Регистрация функции проверки извлечённого файла (Scanner::scanFile)                    |
| getSupportedFormatsMask() const  | Проверка каждого экстрактора на тестовых именах, битовая маска поддерживаемых форматов |
| setBaseExtractionDir(dir)        | Явный базовый каталог для временной распаковки                                         |
| createTempDir() const            | Уникальный временный каталог на основе GUID                                            |
| removeTempDir(path) const        | Рекурсивное удаление временного каталога                                               |

**scanArchive(archive_path, depth)** - поиск подходящего экстрактора, гарантированное удаление временного каталога через RAII (TempDirGuard); вложенный архив - рекурсивный вызов с depth + 1.

### IExtractor (iextractor.h)

Интерфейс: canHandle(path) const, extract(path, dest_dir, limits) -> ExtractionResult.

### ZipExtractor (zip_extractor.h / zip_extractor.cpp)

| Метод                           | Описание                                     |
| ------------------------------- | ---------------------------------------------- |
| canHandle(path) const           | По расширению .zip либо magic-числу PK\x03\x04 |
| hasPkMagic(path) const          | Проверка первых 4 байт файла                   |

**extract(path, dest_dir, limits)** - библиотека miniz; защита от "zip-бомбы": лимит числа файлов, суммарного несжатого размера, коэффициента сжатия; путь каждой записи очищается (sanitizeEntryPath) от ./.. и указаний диска - защита от "zip slip" (path traversal).

### IsoExtractor (iso_extractor.h / iso_extractor.cpp)

| Метод                           | Описание                                                          |
| ------------------------------- | ------------------------------------------------------------------- |
| canHandle(path) const           | По расширению .iso или .img                                         |
| copyDirRecursive(...)           | Рекурсивное копирование из смонтированного тома с проверкой лимитов |

**extract(path, dest_dir, limits)** - монтирование как виртуальный диск через Virtual Disk API (только для чтения), поиск буквы тома, копирование через CopyFileW; диск отключается через RAII (VirtualDiskGuard); при нехватке прав на монтирование - код ошибки requires_elevation.

### SevenZipExtractor (seven_zip_extractor.h / seven_zip_extractor.cpp)

| Метод                           | Описание                                                               |
| ------------------------------- | ---------------------------------------------------------------------- |
| SevenZipExtractor(dll_dir)      | Загрузка 7z.dll, разрешение функции CreateObject                       |
| ~SevenZipExtractor()            | Выгрузка библиотеки                                                    |
| canHandle(path) const           | По расширениям .7z, .rar, .tar, .gz, .bz2, если библиотека загрузилась |
| isAvailable() const             | true, если 7z.dll загружена                                            |

**extract(path, dest_dir, limits)** - COM-подобные интерфейсы 7-Zip (IInArchive, IArchiveExtractCallback) как C++ абстрактные классы с заданными вручную GUID; проверка лимита max_files; извлечение с обратным вызовом ExtractCallback, путь каждой записи очищается от слэшей и буквы диска.