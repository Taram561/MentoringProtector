# Веб-защита

## Файлы

| Файл | Описание |
|---|---|
| http_server.cpp / http_server.h | HTTP-сервер: приём соединений, маршрутизация, ограничение частоты запросов, CORS |
| auth_token.cpp / auth_token.h | Генерация, хранение и проверка токена авторизации |
| bloom_filter.cpp / bloom_filter.h | Быстрая предварительная проверка "домена точно нет в базе" |
| phishing_db.cpp / phishing_db.h | База известных фишинговых и безопасных доменов, с bloom-фильтром сверху |
| url_checker.cpp / url_checker.h | Основная точка проверки URL: домен, база угроз, эвристика |
| url_heuristics.cpp / url_heuristics.h | Признаковый анализ URL: гомоглифы, имитация брендов, подозрительные зоны, обфускация |
| web_protection_exports.cpp / web_protection_exports.h | Экспортируемые функции управления сервером |

## Классы и функции

### WebProtectionServer (http_server.h / http_server.cpp)

| Метод                                                        | Описание                                                                  |
| ------------------------------------------------------------ | ------------------------------------------------------------------------- |
| WebProtectionServer(checker, nudge_sink)                     | Инициализация Winsock                                                     |
| ~WebProtectionServer()                                       | Остановка сервера, освобождение Winsock                                   |
| stop()                                                       | Атомарная остановка, закрытие слушающего сокета, ожидание рабочих потоков |
| isRunning() const                                            | Флаг running_                                                             |
| port() const                                                 | Номер порта (27432)                                                       |
| acceptLoop()                                                 | Приём входящих соединений, постановка сокета в очередь задач              |
| workerFunc()                                                 | Один из 8 рабочих потоков: ожидание сокета в очереди, вызов handleClient  |
| routeRequest(method, path, query)                            | Маршрутизация: GET /check, /nudge, /status, /version; остальное - 404     |
| handleCheck(query)                                           | Параметр url, вызов UrlChecker::check, сборка JSON-ответа                 |
| handleStatus() const                                         | Счётчики загруженных угроз/доверенных доменов, номер порта                |
| handleVersion() const                                        | Статичная строка версии протокола                                         |
| sanitize(s, cap) (статический)                               | Обрезка строки, удаление управляющих символов                             |
| buildResponse(statusCode, body, allowedOrigin) (статический) | Сборка сырого HTTP-ответа                                                 |
| urlDecode(encoded) (статический)                             | Декодирование %XX и + в параметрах                                        |
| getQueryParam(query, param) (статический)                    | Поиск значения параметра по имени                                         |
| parseRequestLine(request, method, path, query) (статический) | Разбор первой строки HTTP-запроса                                         |
| getHeader(request, headerName) (статический)                 | Поиск значения заголовка                                                  |

**start()** - привязка сокета строго к INADDR_LOOPBACK (127.0.0.1); пул из 8 рабочих потоков и отдельный поток приёма соединений.

**handleClient(clientSocket)** - таймауты приёма/отправки 2 секунды, чтение до \r\n\r\n или 8192 байт; ограничение частоты по IP (tryConsumeToken), проверка Authorization: Bearer для всех путей кроме /version, маршрутизация и ответ.

**handleNudge(query)** - категория события, путь файла, URL источника (все поля через sanitize), формирование Nudge и передача в INudgeSink.

**validateOrigin(origin)** - разрешение только chrome-extension:// или moz-extension://; при заданном во время сборки ожидаемом идентификаторе - точное совпадение.

**tryConsumeToken(clientIP)** - token bucket: 100 токенов на IP, пополнение 50/сек, запрос стоит 1 токен; при росте числа IP сверх 64 - эвикция самой старой записи.

### AuthToken (auth_token.h / auth_token.cpp)

| Метод                                       | Описание                                  |
| ------------------------------------------- | ----------------------------------------- |
| getInstance() (статический)                 | Единственный экземпляр                    |
| getToken() const / getTokenFilePath() const | Токен/путь к файлу под мьютексом          |
| regenerate()                                | Новый случайный токен поверх старого      |
| generateRandomBytes(buffer, length)         | Случайные байты через CryptGenRandom      |
| base64Encode(data, length) (статический)    | Кодирование в base64                      |
| setFilePermissions(filepath)                | Ограничение доступа к файлу токена (SDDL) |

**initialize(data_dir)** - генерация 32 случайных байт при отсутствии/ повреждении токена, кодирование в base64, немедленное затирание исходных байт (SecureZeroMemory).

**validate(auth_header) const** - ожидание Bearer <токен>, сравнение длины до посимвольного сравнения через constantTimeCompare.

**constantTimeCompare(a, b) const** - сравнение без раннего выхода (result |= a[i] ^ b[i]) - защита от атаки по времени ответа.

**saveToken(filepath) / loadToken(filepath)** - токен на диске хранится зашифрованным через DPAPI (CryptProtectData/CryptUnprotectData).

### BloomFilter (bloom_filter.h / bloom_filter.cpp)

| Метод                                                           | Описание                                                             |
| --------------------------------------------------------------- | -------------------------------------------------------------------- |
| BloomFilter(expected_elements, false_positive_rate)             | Вычисление оптимального размера битового массива и числа хэш-функций |
| add(element)                                                    | Установка m_numHashes бит для элемента                               |
| mightContain(element) const                                     | false, если хотя бы один бит не выставлен; иначе true                |
| clear()                                                         | Обнуление битового массива и счётчика                                |
| getBitCount/getHashCount/getMemoryBytes/getElementCount() const | Параметры и состояние фильтра                                        |
| estimatedFalsePositiveRate() const                              | Оценка вероятности ложного срабатывания по формуле                   |
| murmurHash3(key, seed) const                                    | Реализация хэша MurmurHash3 (32-бит)                                 |
| setBit(index) / getBit(index) const                             | Установка/чтение одного бита                                         |

**getNthHash(element, n) const** - двойное хэширование: два значения MurmurHash3 с разными сидами, следующая позиция - h1 + nh2 по модулю числа бит; дешевле, чем вызывать хэш-функцию m_numHashes раз. Фильтр может ошибочно сказать "возможно, есть в базе", но никогда не ошибается, говоря "точно нет" - поэтому безопасен как предварительный, быстрый фильтр перед точной проверкой (PhishingDb::mightBePhishing): "точно нет" даёт немедленный ответ "безопасно", "возможно, есть" запускает точный поиск в хэш-таблице.

### PhishingDb (phishing_db.h / phishing_db.cpp)

| Метод | Описание |
|---|---|
| instance() (статический) | Единственный экземпляр |
| loadFromFile(path) | Построчное чтение угроз (домен\tтип\tоценка\tисточник), перестроение bloom-фильтра |
| loadSafeList(path) | Построчное чтение доверенных доменов |
| findThreat(domain) const | Точное совпадение, при отсутствии - родительский домен |
| isSafe(domain) const | Проверка вхождения в safeList_ |
| threatCount() const / safeCount() const | Размеры коллекций |
| addThreat(record) / addSafe(domain) | Добавление одной записи без перезагрузки файла |
| mightBePhishing(domain) const | Предварительный отсев через bloom-фильтр |
| rebuildBloomFilter() | Очистка и заполнение фильтра заново |
| normalizeDomain(domain) (статический) | Нижний регистр, без www. и завершающего / |

### UrlChecker (url_checker.h / url_checker.cpp)

| Метод                                  | Описание                              |
| -------------------------------------- | ------------------------------------- |
| UrlChecker(db)                         | Сохранение ссылки на IPhishingDb      |
| extractDomain(url) (статический)       | Отрезание схемы и всего после //?/#/: |
| isHttps(url) (статический)             | Проверка префикса https://            |
| threatTypeToString(type) (статический) | DomainThreatType в строку для JSON    |

**check(url) const** - порядок: белый список -> точная база угроз (через bloom-фильтр) -> встроенный heuristicScore и UrlHeuristics::analyze (максимум из двух, порог >= 50); совпадение отправляется в StatsRecorder.

**heuristicScore(url, domain)** - отсутствие HTTPS (+10), IP-адрес (+35), подозрительная TLD (+20), опечатки брендов (+40), фишинговые ключевые слова (до +30), избыточные дефисы/точки/цифры; итог ограничен 100.

### UrlHeuristics (url_heuristics.h / url_heuristics.cpp)

| Метод                                                                                     | Описание                                                         |
| ----------------------------------------------------------------------------------------- | ---------------------------------------------------------------- |
| UrlHeuristics()                                                                           | Заполнение таблиц гомоглифов, брендов, TLD, ключевых слов        |
| analyze(url) const                                                                        | Прогон всех проверок, суммарный счёт 0-100                       |
| hasMixedScripts(domain) const                                                             | Проверка смешения латиницы и не-латиницы по диапазону байт UTF-8 |
| decodePunycode(encoded) const                                                             | Заглушка - строка без изменений                                  |
| normalizeHomoglyphs(domain) const                                                         | Замена не-латинских кодовых точек на похожие латинские           |
| detectBrandImpersonation(normalized_domain) const                                         | Совпадение части домена с одним из ~45 брендов                   |
| checkIPAddress(host, result) const / isIPAddress(host) const / isObfuscatedIP(host) const | Проверка на IP-адрес в обычном/обфусцированном виде              |
| checkSuspiciousTLD(domain, result) const                                                  | Таблица подозрительных TLD с весами                              |
| checkDomainStructure(domain, result) const                                                | Число поддоменов, длина, дефисы, бренд как часть домена          |
| checkPathPatterns(path, result) const                                                     | Фишинговые ключевые слова и опасные расширения в пути            |
| checkObfuscation(url, result) const                                                       | Символ @, двойное URL-кодирование                                |
| extractHost/extractPath/extractTLD/toLower                                                | Разбор частей URL                                                |

**checkHomoglyphs(domain, result) const** - запуск только при смешанных алфавитах или Punycode; нормализованный домен сравнивается с брендами (+40, флаг is_homoglyph), простое смешение алфавитов - +15. Важная особенность реализации: decodePunycode - заглушка, возвращающая строку без изменений, поэтому нормализация гомоглифов реально срабатывает только тогда, когда сама строка уже содержит "сырые" не-ASCII символы Unicode; для домена в технической Punycode-форме (xn--...) сравнение с таблицей гомоглифов не находит совпадений - сравнивать не с чем.

### FFI-экспорты (web_protection_exports.h / .cpp)

| Функция                                                             | Описание                                  |
| ------------------------------------------------------------------- | ----------------------------------------- |
| web_protection_set_nudge_sink(sink)                                 | Регистрация приёмника обучающих подсказок |
| web_protection_stop()                                               | Остановка сервера                         |
| web_protection_is_running()                                         | Статус у службы, иначе локальный g_server |
| web_protection_check_url(url)                                       | Прямой вызов проверки URL в обход HTTP    |
| web_protection_threats_count()                                      | Число загруженных угроз                   |
| web_protection_reload_db(phishingDbPath)                            | Перезагрузка базы фишинговых доменов      |
| web_protection_get_auth_token() / web_protection_regenerate_token() | Текущий токен / новый токен               |

**web_protection_start(...)** - загрузка баз, инициализация AuthToken, создание UrlChecker; проверка isServiceHosting() перед стартом собственного сервера - если служба уже хостит веб-защиту, второй сервер на том же порту не поднимается.

