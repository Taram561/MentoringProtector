# Браузерные расширения

Расширения для Chrome и Firefox перехватывают переходы по ссылкам и начало загрузок файлов, отправляя их на проверку HTTP-серверу веб-защиты ядра на http://127.0.0.1:27432.

Chrome требует Manifest V3 (service worker), Firefox - Manifest V2 с webRequestBlocking. Общая логика вынесена в extension/shared/ - единый источник истины; build.py копирует ("vendor") её содержимое в chrome/shared/ и firefox/shared/ при сборке (расширения не позволяют импорт за пределы своего каталога). Изменения вносятся только в extension/shared/.

## Общий код

| Файл | Описание |
|---|---|
| constants.js | Адрес сервера, коды категорий угроз, пороги оценки риска, ключи хранилища, категории риска загрузок |
| platform.js | Единая точка доступа к API расширения (chrome.*/browser.*) |
| state.js | Чтение и сохранение состояния расширения |
| url_checker.js | Запрос проверки ссылки, извлечение домена/имени файла |
| response_validator.js | Проверка структуры ответа сервера перед использованием |
| download_handler.js | Оценка риска начинающейся загрузки |
| message_router.js | Обработка сообщений между popup/content и фоном, проверка отправителя и типа |
| nudge_reporter.js | Отправка обучающей подсказки на сервер ядра |
| warning_url_builder.js | Формирование адреса страницы предупреждения |
| teachable.js | Обучающие тексты для страницы предупреждения |

### Классы и функции

**constants.js** - только данные: адрес сервера и точки (ENDPOINTS), справочник типов угроз, пороги SCORE_BLOCK/SCORE_WARN (отдельная копия значений ядра, не общий источник), уровни риска загрузок, подозрительные подстроки имени файла.

**platform.js** - api выбирает между browser и chrome в зависимости от окружения, весь остальной код обращается только к api. runtimeId() - ID расширения либо заглушка.

**state.js**:

| Функция                             | Описание                                     |
| ----------------------------------- | ---------------------------------------------- |
| saveAuthToken(token)                | В storage.session (не local)                   |
| saveStats(stats)                    | Счётчики заблокировано/предупреждено/проверено |
| saveEnabled(value)                  | Флаг включённости защиты                       |
| saveExclusions(list)                | Список доменов-исключений                      |
| addHistoryItem(domain, safe, score) | Запись в историю, лимит 20                     |
| getHistory()                        | Сохранённая история проверок                   |

**readState()** - параллельное чтение storage.local и storage.session; токен - только в session (не переживает перезапуск браузера); enabled по умолчанию true (!== false).

**url_checker.js** - extractDomain/extractFilename с защитой от некорректного URL; checkUrl(url, authToken, timeoutMs) - заголовок Authorization, таймаут 3 сек (AbortController), статус 403 отдельно, ответ через validateCheckResponse; getServerStatus - аналогично к /status с таймаутом 2 сек.

**response_validator.js** - validateCheckResponse(data): score - конечное число [0, 100], safe/reason - типы; при нарушении - null.

**download_handler.js** - assessDownloadRisk: три уровня риска по расширению (максимум), +30 за подозрительную подстроку имени, плюс checkUrl() для источника - итог сложением.

**message_router.js** - routeMessage(...): проверка sender.id, проверка типа по VALID_TYPES (Set); IGNORE_ONCE - временное исключение домена с TTL 1 час и попутной ленивой очисткой; CANCEL_DOWNLOAD валидирует downloadId; sanitizeDomain - внутренняя нормализация.

**nudge_reporter.js** - reportNudge без токена/категории не делает ничего, обрезка полей до 512 символов, ошибки не пробрасываются; getNudgeCategory(ext) - расширение в категорию нуджа.

**warning_url_builder.js** - buildWarningUrl(url, result) / buildDownloadWarningUrl(downloadItem, riskScore, riskReasons): сборка адреса страниц предупреждения через encodeURIComponent всех параметров.

**teachable.js** - только данные, весь текст на английском независимо от локали GUI.

## Chrome (Manifest V3) - extension/chrome/

| Файл | Описание |
|---|---|
| manifest.json | Разрешения, фоновый service worker, content-скрипты |
| src/background.js | Перехват загрузок и навигации |
| src/content.js / content.css | Скрипт на страницах для дополнительных проверок |
| pages/popup.html / popup.js | Всплывающее окно расширения |
| pages/warning.html / warning.js | Страница предупреждения при переходе на опасную ссылку |
| pages/download_warning.html / download_warning.js | Страница предупреждения при рискованной загрузке |
| rules/known_threats.json | Список известных угроз для declarativeNetRequest |
| shared/*.js | Копия extension/shared/ |

## Firefox (Manifest V2) - extension/firefox/

| Файл | Описание |
|---|---|
| manifest.json | Манифест Manifest V2, постоянный фон |
| src/background.html / background_firefox.js | Постоянный фоновый процесс |
| src/content.js / content.css | Аналогично Chrome-версии |
| pages/popup.html / popup.js, pages/warning.html / warning.js, pages/download_warning.html / download_warning.js | Аналогично Chrome-версии |
| shared/*.js | Копия extension/shared/ |

## Сборка и тесты

| Файл | Описание |
|---|---|
| build.py | Копирует общие файлы в оба расширения перед упаковкой |
| package.json, babel.config.cjs, jest.config.cjs | Конфигурация Jest/Babel для extension/tests/ |
| tests/shared/message_router.test.js, response_validator.test.js, url_checker.test.js, warning_url_builder.test.js | Тесты общей логики |
