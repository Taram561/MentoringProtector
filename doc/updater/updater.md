# Обновление баз угроз (updater/)

Python-скрипты, отдельные от приложения, скачивающие, проверяющие и подготавливающие базы сигнатур и списки доменов в data/, откуда их читает ядро.

fetch_signatures.py скачивает базы ClamAV (main.cvd, daily.cvd) с database.clamav.net, разбирает формат CVD и преобразует в signatures.msdb. Проверка целостности: подпись ClamAV (strict_verify) и TLS-пиннинг сертификата (pins.json, fail-closed при непустом списке); max_signatures ограничивает разрастание базы.

fetch_threat_feeds.py - аналогичный процесс для дополнительных источников (списки доменов, YARA-правила сообществ).

## Файлы

| Файл | Описание |
|---|---|
| fetch_signatures.py | Скачивание, проверка и преобразование баз ClamAV в signatures.msdb |
| fetch_threat_feeds.py | Скачивание дополнительных источников (домены, YARA-правила сообществ) |
| test_dsig.py | Тесты проверки цифровой подписи скачанных баз, без обращения к сети |
| pins.json | Закреплённые TLS-сертификаты (SPKI) для database.clamav.net; пустой список - без пиннинга |

## Классы и функции

### fetch_signatures.py

| Функция/класс                                  | Описание                                                        |
| ---------------------------------------------- | ----------------------------------------------------------------- |
| Logger                                         | Сообщения в консоль и файл лога с меткой времени и уровнем        |
| _load_pins(logger)                             | Список SPKI-отпечатков из pins.json, пусто при отсутствии/ошибке  |
| _spki_sha256_b64(cert_der)                     | SPKI из DER-сертификата, SHA-256 в base64                         |
| _get_session(logger)                           | requests.Session с _SPKIPinningAdapter, если пины заданы          |
| record_pin(host, logger)                       | --record-pin: вычисление SPKI сервера и запись в pins.json        |
| download_file(url, dest_path, logger, timeout) | Потоковое скачивание с прогресс-баром                             |
| extract_cvd(cvd_path, extract_dir, logger)     | Отделение заголовка CVD от tar.gz, распаковка (filter='data')     |
| parse_hdb(hdb_path, logger)                    | Быстрый подсчёт угроз в .hdb                                      |
| parse_hdb_full(hdb_path, logger, max_count)    | Разбор .hdb/.hsb в список (хэш, размер, имя) с проверкой алфавита |
| parse_msdb(msdb_path, logger, max_count)       | Разбор готовой signatures.msdb                                    |
| write_msdb(signatures, output_path, logger)    | Запись списка сигнатур в текстовый файл                           |
| save_version(version_path, count, msdb_sha256) | Метаданные версии базы                                            |
| check_update_needed(version_path)              | True, если прошло ≥ 24 часов                                      |
| run_test_mode(logger)                          | --test: печать состояния без обращения к сети                     |

**SPKIPinningAdapter** - после TLS-запроса сверяет SPKI-отпечаток сертификата сервера со списком разрешённых; отсутствие сертификата, cryptography, или несовпадение - в каждом случае fail-closed.

**cli_decodesig_bignum(sig)** - порт cli_decodesig: раскодирование строки подписи в число, чтение символов с конца строки в 64-ричной системе.

**verify_cvd_dsig(payload, fields, logger)** - порт cli_versig: сверка MD5 заголовка с телом (hmac.compare_digest) -> декодирование подписи -> pow(c, E, N) -> проверка длины ≤128 бит -> сравнение с MD5; статусы "verified"/"mismatch"/"unavailable", без исключений наружу.

**validate_cvd(cvd_path, logger, strict)** - заголовок, магическая строка, verify_cvd_dsig; strict=True (по умолчанию) отклоняет при несовпадении подписи; отдельно сверяется MD5 тела.

**main()** - аргументы (--force/--test/--local/--strict/ --no-strict/--record-pin), проверка необходимости обновления, для каждой базы - скачивание/валидация/распаковка/разбор, дедупликация по хэшу, атомарная запись (.new -> проверка размера -> .bak -> rename, с откатом при неудаче).

### fetch_threat_feeds.py

| Функция                                      | Описание                                                               |
| -------------------------------------------- | ------------------------------------------------------------------------ |
| Logger                                       | Независимая копия логгера                                                |
| download_to_memory(url, logger, timeout)     | Скачивание URL целиком в память                                          |
| download_to_file(url, dest, logger, timeout) | Потоковое скачивание в файл                                              |
| fetch_malwarebazaar(logger)                  | Свежие SHA-256 хеши (abuse.ch) в malwarebazaar_hashes.txt                |
| fetch_urlhaus(logger)                        | Вредоносные URL (URLhaus) в phishing_domains.txt, риск 85                |
| fetch_phishtank(logger)                      | Фишинговые URL (PhishTank), риск 90                                      |
| _load_existing_domains(phishing_file)        | Уже существующие домены, без дублей                                      |
| main()                                       | Аргументы (--yara/--malwarebazaar/--urlhaus/--phishtank), запуск, сводка |

**fetch_yara_rules()** - два сообщества (YARAify, YARA-Forge), файлы переименовываются с префиксом источника в data/yara_rules/community/; удаление compiled_rules.yrc - сигнал ядру пересобрать кэш.

Три функции доменов/хешей следуют паттерну: скачать -> сравнить со существующим файлом -> дозаписать только новые строки.

### test_dsig.py

| Класс тестов | Что проверяет |
|---|---|
| NcodecAlphabetTests | Алфавит _DSIG_NCODEC - 64 уникальных символа |
| DecodesigBignumTests | _cli_decodesig_bignum: порядок байт, исключения |
| VerifyCvdDsigUnitTests | _verify_cvd_dsig на синтетических данных |
| GenuineCvdTests | На настоящих main.cvd/daily.cvd, если скачаны локально |

GenuineCvdTests пропускается без локальных файлов; синтетические тесты запускаются всегда.