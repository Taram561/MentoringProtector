// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.g.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get navHome => 'Главная';

  @override
  String get navScan => 'Сканирование';

  @override
  String get navQuarantine => 'Карантин';

  @override
  String get navHygiene => 'Гигиена';

  @override
  String get navStats => 'Статистика';

  @override
  String get navProcesses => 'Процессы';

  @override
  String get navSettings => 'Настройки';

  @override
  String get navVulnerabilities => 'Уязвимости';

  @override
  String get homeTitle => 'Mentoring Protector';

  @override
  String get homeProtected => 'Защита активна';

  @override
  String get homeWarning => 'Требует внимания';

  @override
  String get homeDanger => 'Устройство не защищено';

  @override
  String get homeLastScan => 'Последнее сканирование';

  @override
  String get homeNeverScanned => 'Сканирование ещё не выполнялось';

  @override
  String get homeStartScan => 'Начать сканирование';

  @override
  String get homeSignatures => 'Сигнатур в базе ';

  @override
  String get homeSignaturesCount => 'сигнатур ';

  @override
  String get homeInQuarantine => 'В карантине ';

  @override
  String get homeRecentEvents => 'Последние события ';

  @override
  String get homeScanDone => 'Сканирование завершено - угроз нет';

  @override
  String get homeDbUpdated => 'База обновлена';

  @override
  String get homeAppStarted => 'Mentoring Protector запущен';

  @override
  String get scanTitle => 'Сканирование';

  @override
  String get scanSelectTarget => 'Выберите объект сканирования';

  @override
  String get scanFile => 'Файл';

  @override
  String get scanFolder => 'Папка';

  @override
  String get scanScanning => 'Сканирование...';

  @override
  String get scanCancel => 'Отмена';

  @override
  String get scanNewScan => 'Новое сканирование';

  @override
  String get scanNoThreats => 'Угроз не обнаружено';

  @override
  String get scanThreatsFound => 'Угроз найдено ';

  @override
  String get scanResults => 'Результаты';

  @override
  String get scanChecked => 'Проверено ';

  @override
  String get scanOf => ' из ';

  @override
  String get scanStatsFilesScanned => 'Файлов проверено';

  @override
  String get scanStatsElapsedTime => 'Время сканирования';

  @override
  String get scanStatsActiveEngines => 'Активные движки';

  @override
  String get scanStatsThreatsFound => 'Найдено угроз';

  @override
  String get quarantineTitle => 'Карантин';

  @override
  String get quarantineEmpty => 'Карантин пуст';

  @override
  String get quarantineRestore => 'Восстановить';

  @override
  String get quarantineDelete => 'Удалить';

  @override
  String get quarantineFile => 'файлов';

  @override
  String get quarantineDeleteConfirm =>
      'Удалить этот файл безвозвратно? Восстановить его будет невозможно.';

  @override
  String get quarantineRestoreConfirm =>
      'Восстановить файл в исходное расположение?';

  @override
  String get quarantineRestoreSuccess => 'Файл восстановлен';

  @override
  String get quarantineOrphanBadge => 'Файл недоступен';

  @override
  String get quarantineOrphanRemove => 'Убрать из списка';

  @override
  String get quarantineOrphanRemoveConfirm =>
      'Файл карантина отсутствует на диске. Убрать эту запись из списка?';

  @override
  String get processTitle => 'Мониторинг процессов';

  @override
  String get processStart => 'Запустить мониторинг';

  @override
  String get processStop => 'Остановить мониторинг';

  @override
  String get processActive => 'Активен';

  @override
  String get processBlocked => 'Заблокирован';

  @override
  String get processNoAlerts => 'Подозрительных процессов не обнаружено';

  @override
  String get processThreats => 'Угрозы';

  @override
  String get processSuspicious => 'Подозрительные';

  @override
  String get processClean => 'Чистые';

  @override
  String get processAnalysisTitle => 'Анализ запускаемых файлов';

  @override
  String get processAnalysisDesc =>
      'Mentoring Protector анализирует каждый новый процесс. Неизвестные файлы проверяются эвристически.';

  @override
  String get processStartHint => 'Запустите мониторинг\nдля анализа процессов';

  @override
  String get vulnTitle => 'Уязвимости устройства';

  @override
  String get vulnDescription =>
      'Анализ настроек безопасности Windows, открытых служб и конфигурации системы.';

  @override
  String get vulnScan => 'Проверить устройство';

  @override
  String get vulnScanBtn => 'Проверить устройство';

  @override
  String get vulnScanning => 'Анализ системы...';

  @override
  String get vulnNone => 'Уязвимостей не обнаружено';

  @override
  String get vulnFound => 'Найдено уязвимостей: ';

  @override
  String get vulnCritical => 'Критические';

  @override
  String get vulnHigh => 'Высокие';

  @override
  String get vulnMedium => 'Средние';

  @override
  String get vulnLow => 'Низкие';

  @override
  String get vulnHowToFix => 'Как исправить';

  @override
  String get vulnMoreInfo => 'Подробнее';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsTheme => 'Тема оформления';

  @override
  String get settingsThemeSystem => 'Как в системе';

  @override
  String get settingsThemeLight => 'Светлая';

  @override
  String get settingsThemeDark => 'Тёмная';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsVersion => 'Версия приложения';

  @override
  String get settingsCoreVersion => 'Версия ядра';

  @override
  String get helpTitle => 'Справка и о программе';

  @override
  String get helpAbout => 'О приложении, FAQ и обучающие материалы';

  @override
  String get helpMission =>
      'Adaptive Cyber Hygiene Platform - обучаем пользователей противостоять социальной инженерии и фишингу';

  @override
  String get helpLinksTitle => 'Ссылки';

  @override
  String get helpGithub => 'Репозиторий GitHub';

  @override
  String get helpLicense => 'Лицензия (MIT)';

  @override
  String get helpEducationTitle => 'Обучающие материалы';

  @override
  String get helpCourseTitle => 'Курс по кибербезопасности';

  @override
  String get helpQuizTitle => 'Интерактивные тесты';

  @override
  String get helpCourseSoon => 'Скоро будет доступно';

  @override
  String get helpEducationPlaceholder => 'Обучающий контент скоро появится!';

  @override
  String get faq01Q => 'Что такое YARA?';

  @override
  String get faq01A =>
      'YARA - инструмент поиска по шаблонам для обнаружения вредоносных программ. MentoringProtector использует YARA-правила как один из движков наряду с сигнатурами и эвристикой.';

  @override
  String get faq02Q => 'Зачем MentoringProtector нужны права администратора?';

  @override
  String get faq02A =>
      'Основное приложение работает без прав администратора. Права администратора (UAC) запрашиваются только при нажатии «Исправить автоматически» в сканере уязвимостей - для записи в системный реестр Windows.';

  @override
  String get faq03Q => 'Что такое Smart Scan Cache?';

  @override
  String get faq03A =>
      'Smart Scan Cache сохраняет результаты сканирования по хешу, чтобы неизменённые файлы не сканировались повторно. Это значительно ускоряет повторные проверки без ущерба для безопасности.';

  @override
  String get faq04Q => 'Для чего используется Bloom Filter?';

  @override
  String get faq04A =>
      'Bloom Filter - вероятностная структура данных для быстрого поиска фишинговых доменов в модуле веб-защиты. Проверяет ~100К доменов за микросекунды с практически нулевым количеством ложных отрицаний.';

  @override
  String get faq05Q => 'Что происходит с файлами в карантине?';

  @override
  String get faq05A =>
      'Файлы в карантине шифруются с помощью AES-256 и хранятся в защищённой папке. Они не могут выполняться. Вы можете восстановить их при ложных срабатываниях или удалить насовсем.';

  @override
  String get faq06Q => 'Как работает эвристический движок?';

  @override
  String get faq06A =>
      'Эвристический движок анализирует структуру PE-файла: импорты, подозрительные строки, энтропию (упакованные секции), цифровую подпись и аномалии размера - без базы сигнатур.';

  @override
  String get faq07Q => 'Что такое мониторинг ETW?';

  @override
  String get faq07A =>
      'Event Tracing for Windows (ETW) - механизм логирования на уровне ядра. MentoringProtector использует его для обнаружения DLL-инъекций и подозрительной активности процессов.';

  @override
  String get faq08Q => 'Зачем MentoringProtector, если есть Windows Defender?';

  @override
  String get faq08A =>
      'MentoringProtector - образовательная платформа: объясняет ПОЧЕМУ файл подозрителен (объяснимое обнаружение), формирует привычки кибергигиены и показывает сработавшую логику. Defender хорошо защищает, но не обучает.';

  @override
  String get hygieneUpdateTitle => 'Обновляйте систему';

  @override
  String get hygieneUpdateDesc =>
      'Устанавливайте обновления Windows и приложений сразу после выхода.';

  @override
  String get hygienePasswordTitle => 'Сильные пароли';

  @override
  String get hygienePasswordDesc =>
      'Используйте уникальные пароли от 12 символов для каждого сервиса.';

  @override
  String get hygieneWifiTitle => 'Безопасный Wi-Fi';

  @override
  String get hygieneWifiDesc => 'Избегайте публичных сетей без VPN.';

  @override
  String get hygienePhishingTitle => 'Осторожно с письмами';

  @override
  String get hygienePhishingDesc =>
      'Не открывайте вложения из подозрительных писем.';

  @override
  String get hygieneBackupTitle => 'Резервные копии';

  @override
  String get hygieneBackupDesc =>
      'Регулярно создавайте резервные копии важных файлов.';

  @override
  String get hygieneDownloadTitle => 'Безопасные загрузки';

  @override
  String get hygieneDownloadDesc =>
      'Скачивайте программы только с официальных сайтов.';

  @override
  String get hygiene2faTitle => 'Двухфакторная аутентификация';

  @override
  String get hygiene2faDesc =>
      'Включите 2FA для всех важных аккаунтов: почта, банк, соцсети. Используйте приложение-аутентификатор вместо SMS.';

  @override
  String get hygieneUsbTitle => 'Осторожно с USB-устройствами';

  @override
  String get hygieneUsbDesc =>
      'Не подключайте неизвестные USB-накопители. Они могут содержать вредоносное ПО, которое запускается автоматически.';

  @override
  String get hygienePrivacyTitle => 'Настройки конфиденциальности';

  @override
  String get hygienePrivacyDesc =>
      'Регулярно проверяйте настройки приватности в Windows, браузере и приложениях. Отключите ненужную телеметрию.';

  @override
  String get hygieneLockTitle => 'Блокировка экрана';

  @override
  String get hygieneLockDesc =>
      'Всегда блокируйте компьютер при отходе. Используйте Win+L. Установите автоблокировку через 5 минут неактивности.';

  @override
  String get hygieneExtensionsTitle => 'Расширения браузера';

  @override
  String get hygieneExtensionsDesc =>
      'Удалите ненужные расширения браузера. Каждое из них может читать ваши данные на сайтах.';

  @override
  String get hygieneEncryptionTitle => 'Шифрование диска';

  @override
  String get hygieneEncryptionDesc =>
      'Включите BitLocker или аналог для шифрования системного диска. Это защитит данные при краже ноутбука.';

  @override
  String get btnClose => 'Закрыть';

  @override
  String get btnOk => 'OK';

  @override
  String get btnCancel => 'Отмена';

  @override
  String get errorDllNotFound => 'Ядро антивируса не найдено';

  @override
  String get errorGeneric => 'Произошла ошибка';

  @override
  String get computerScanTitle => 'Сканирование компьютера';

  @override
  String get computerScanDescription => 'Полная проверка всех дисков';

  @override
  String get computerScanStart => 'Начать сканирование';

  @override
  String get computerScanDrive => 'Диск';

  @override
  String get computerScanThreats => 'Угроз';

  @override
  String get computerScanThreatsFound => 'Найдено угроз';

  @override
  String get computerScanNoThreats => 'Угроз не обнаружено';

  @override
  String get computerScanInfo1 => 'Сигнатурный анализ по базе ClamAV';

  @override
  String get computerScanInfo2 => 'Эвристический анализ PE файлов';

  @override
  String get computerScanInfo3 => 'Пропуск системных папок Windows';

  @override
  String get computerScanInfo4 => 'Безопасно: только чтение файлов';

  @override
  String get navWebProtection => 'Веб-защита';

  @override
  String get webTitle => 'Веб-защита';

  @override
  String get webDescription =>
      'Защита от фишинга и вредоносных сайтов в реальном времени через браузерное расширение.';

  @override
  String get webServerRunning => 'Сервер запущен';

  @override
  String get webServerStopped => 'Сервер остановлен';

  @override
  String get webStart => 'Запустить защиту';

  @override
  String get webStop => 'Остановить защиту';

  @override
  String get webThreatsLoaded => 'Угроз в базе';

  @override
  String get webAuthToken => 'Токен авторизации';

  @override
  String get webCopyToken => 'Скопировать токен';

  @override
  String get webTokenCopied => 'Токен скопирован в буфер обмена';

  @override
  String get webRegenerateToken => 'Перегенерировать токен';

  @override
  String get webRegenerateConfirm =>
      'Перегенерировать токен? Текущий станет недействительным.';

  @override
  String get webCheckUrl => 'Проверить URL';

  @override
  String get webCheckUrlHint => 'Введите URL для проверки';

  @override
  String get webResultSafe => 'Безопасно';

  @override
  String get webResultDanger => 'Опасно';

  @override
  String get webScore => 'Оценка угрозы';

  @override
  String get webReason => 'Причина';

  @override
  String get webDomain => 'Домен';

  @override
  String get webEventsTitle => 'Последние проверки';

  @override
  String get webNoEvents => 'Проверок ещё не было';

  @override
  String get webExtensionHint =>
      'Установите расширение для Chrome/Edge и вставьте токен в настройках расширения.';

  @override
  String get webDetailTitle => 'Анализ URL';

  @override
  String get webDetailDomain => 'Домен';

  @override
  String get webDetailThreatType => 'Тип угрозы';

  @override
  String get webDetailRiskScore => 'Уровень риска';

  @override
  String get webDetailAnalysis => 'Результаты анализа';

  @override
  String get webDetailHomoglyphTitle => 'Обнаружена гомоглиф-атака';

  @override
  String webDetailHomoglyphDesc(String brand) {
    return 'Домен имитирует бренд «$brand» используя визуально похожие символы из другого алфавита.';
  }

  @override
  String get webDetailTeachableTitle => 'Как распознать самому?';

  @override
  String get webTipPhishing =>
      'Фишинговые сайты копируют дизайн известных сервисов. Всегда проверяйте URL в адресной строке - настоящий домен находится перед первым «/».';

  @override
  String get webTipMalware =>
      'Вредоносные сайты часто маскируются под обновления или бесплатный софт. Скачивайте программы только с официальных сайтов.';

  @override
  String get webTipScam =>
      'Мошеннические сайты создают ощущение срочности: «вы выиграли», «аккаунт заблокирован». Не торопитесь - проверьте информацию через официальный сайт.';

  @override
  String get webTipHomoglyph =>
      'Гомоглиф-атака подменяет буквы на похожие символы (например, «а» кириллическая вместо «a» латинской). Наведите курсор на URL - браузер покажет Punycode-версию.';

  @override
  String get webTipSuspicious =>
      'Подозрительные домены часто используют необычные TLD (.tk, .xyz), длинные поддомены или IP-адреса вместо имён. Если сомневаетесь - не вводите данные.';

  @override
  String get webTipCryptominer =>
      'Криптомайнеры на сайтах используют ваш процессор для добычи криптовалюты. Признаки: резкий рост загрузки CPU, шум вентилятора, торможение браузера.';

  @override
  String get webTipTracking =>
      'Трекинговые скрипты собирают данные о вашем поведении. Используйте блокировщики рекламы и режим инкогнито для повышения приватности.';

  @override
  String get webTipGeneral =>
      'Перед вводом личных данных убедитесь, что URL начинается с https:// и домен соответствует ожидаемому сервису.';

  @override
  String get webDetailSafe => 'Безопасно';

  @override
  String get webDetailLow => 'Низкий';

  @override
  String get webDetailMedium => 'Средний';

  @override
  String get webDetailHigh => 'Высокий';

  @override
  String get webDetailCritical => 'Критический';

  @override
  String get webReasonPhishing => 'Фишинг';

  @override
  String get webReasonMalware => 'Вредоносный';

  @override
  String get webReasonScam => 'Мошенничество';

  @override
  String get webReasonCryptominer => 'Криптомайнер';

  @override
  String get webReasonTracking => 'Трекер';

  @override
  String get webReasonSuspicious => 'Подозрительный';

  @override
  String get webReasonClean => 'Чисто';

  @override
  String get navProtection => 'Защита';

  @override
  String get protectionTitle => 'Модули защиты';

  @override
  String get navRealtime => 'Защита';

  @override
  String get archiveScannerTitle => 'Архивный сканер';

  @override
  String get archiveScannerDescription =>
      'Сканирует ZIP, 7z, RAR и ISO архивы на наличие угроз внутри. Защита от zip-бомб включена.';

  @override
  String get realtimeTitle => 'Защита в реальном времени';

  @override
  String get realtimeDescription =>
      'Отслеживает создание и изменение файлов в Downloads, Desktop, Documents и Temp';

  @override
  String get realtimeStart => 'Включить защиту';

  @override
  String get realtimeStop => 'Отключить защиту';

  @override
  String get realtimeActive => 'Активна';

  @override
  String get realtimeNoEvents => 'Событий нет';

  @override
  String get realtimeStartHint =>
      'Нажмите кнопку для включения защиты в реальном времени';

  @override
  String get realtimeTotalDetected => 'Обнаружено';

  @override
  String get realtimeThreatsFound => 'Угрозы';

  @override
  String get realtimeEvents => 'События';

  @override
  String get realtimeCreated => 'Создан';

  @override
  String get realtimeModified => 'Изменён';

  @override
  String get realtimeRenamed => 'Переименован';

  @override
  String get navMemoryScan => 'RAM';

  @override
  String get memoryTitle => 'Сканирование оперативной памяти';

  @override
  String get memoryDescription =>
      'Поиск вредоносных сигнатур в памяти запущенных процессов';

  @override
  String get memoryScanStart => 'Начать сканирование RAM';

  @override
  String get memoryScanStop => 'Остановить';

  @override
  String get memoryScanRunning => 'Сканирование...';

  @override
  String get memoryScanFinished => 'Завершено';

  @override
  String get memoryScanNoThreats => 'Угроз в памяти не обнаружено';

  @override
  String get memoryScanProcesses => 'Процессов';

  @override
  String get memoryScanThreatsFound => 'Обнаружено угроз';

  @override
  String get memoryScanCurrentProcess => 'Текущий процесс';

  @override
  String get memoryScanRegions => 'Регионов памяти';

  @override
  String get memoryScanMatches => 'Совпадений';

  @override
  String get memoryUnavailable =>
      'Сканирование памяти недоступно в текущей версии DLL';

  @override
  String get realtimeUnavailable =>
      'Мониторинг в реальном времени недоступен в текущей версии DLL';

  @override
  String get scanQuarantine => 'В карантин';

  @override
  String get scanDeleteFile => 'Удалить файл';

  @override
  String get scanIgnore => 'Игнорировать';

  @override
  String get scanQuarantineSuccess => 'Файл помещён в карантин';

  @override
  String get scanDeleteSuccess => 'Файл удалён';

  @override
  String get scanDeleteConfirm => 'Удалить файл безвозвратно?';

  @override
  String get scanDangerLevel => 'Опасность';

  @override
  String get scanDetectionMethod => 'Метод обнаружения';

  @override
  String get scanMethodSignature => 'Сигнатурный анализ';

  @override
  String get scanMethodHeuristic => 'Эвристический анализ';

  @override
  String get detectionMethodArchive => 'Архив';

  @override
  String get archiveThreatFound => 'Угроза внутри архива';

  @override
  String get archiveTeachableMoment =>
      'Архивы - популярный вектор доставки вредоносного ПО. Всегда проверяй содержимое архива перед распаковкой, особенно полученного по почте или в мессенджерах.';

  @override
  String get scanHeuristicScore => 'Оценка подозрительности';

  @override
  String get scanEntropy => 'Энтропия файла';

  @override
  String get scanIsPacked => 'Упакован';

  @override
  String get scanHasSignature => 'Цифровая подпись';

  @override
  String get scanTriggeredRules => 'Сработавшие правила';

  @override
  String get scanRecommendation => 'Рекомендация';

  @override
  String get scanHash => 'Хеш (SHA256)';

  @override
  String get scanYes => 'Да';

  @override
  String get scanNo => 'Нет';

  @override
  String get etwModeEtw => 'ETW';

  @override
  String get etwModePolling => 'Polling';

  @override
  String get etwDllInjectionTitle => 'DLL Injection';

  @override
  String get etwDllInjectionEmpty =>
      'Подозрительных загрузок DLL не обнаружено';

  @override
  String get etwRunAsAdmin => 'Запустите от администратора для ETW режима';

  @override
  String get yaraRules => 'YARA правила';

  @override
  String get yaraDetection => 'YARA анализ';

  @override
  String get yaraRulesLoaded => 'YARA правил загружено';

  @override
  String get yaraNotAvailable => 'YARA движок недоступен';

  @override
  String get yaraAuthor => 'Автор';

  @override
  String get yaraSeverity => 'Уровень';

  @override
  String get homeActiveModules => 'Модулей активно';

  @override
  String get sectionBasicProtection => 'Базовая защита';

  @override
  String get sectionAdvancedProtection => 'Продвинутая защита';

  @override
  String get sectionTools => 'Инструменты';

  @override
  String get sectionTechnologies => 'Технологии проверки';

  @override
  String get plannedBadge => 'Planned';

  @override
  String get experimentalBadge => 'Experimental';

  @override
  String get emailProtectionTitle => 'Почтовый антивирус';

  @override
  String get emailProtectionDesc =>
      'Проверка вложений электронной почты на вирусы и фишинг';

  @override
  String get networkProtectionTitle => 'Защита от сетевых атак';

  @override
  String get networkProtectionDesc =>
      'Обнаружение и блокировка сетевых атак (сканирование портов, ARP-spoofing)';

  @override
  String get amsiTitle => 'AMSI интеграция';

  @override
  String get amsiDesc =>
      'Проверка скриптов через Windows Antimalware Scan Interface';

  @override
  String get scriptGuardTitle => 'Script Guard';

  @override
  String get scriptGuardDesc =>
      'Контроль запуска скриптов PowerShell, VBS, BAT';

  @override
  String get etwTitle => 'ETW мониторинг';

  @override
  String get etwDesc =>
      'Мониторинг ядра Windows через Event Tracing (загрузка DLL, создание процессов)';

  @override
  String get smartScanCacheTitle => 'Smart Scan Cache';

  @override
  String get smartScanCacheDesc =>
      'Пропуск повторного сканирования неизменённых файлов';

  @override
  String get trustedReputationTitle => 'Trusted File Reputation';

  @override
  String get trustedReputationDesc =>
      'Доверие к файлам с валидной цифровой подписью из безопасных путей';

  @override
  String get exclusionListTitle => 'Исключения из сканирования';

  @override
  String get exclusionListDesc =>
      'Файлы и папки, которые не проверяются при сканировании';

  @override
  String get exclusionListEmpty => 'Список исключений пуст';

  @override
  String get exclusionListAdd => 'Добавить исключение';

  @override
  String get exclusionListAddHint => 'Путь к файлу, папке или маска (*.log)';

  @override
  String get exclusionListRemoveConfirm => 'Удалить из исключений?';

  @override
  String get exclusionListFolder => 'Выбрать папку';

  @override
  String get exclusionListFile => 'Выбрать файл';

  @override
  String get exclusionListMask => 'Ввести маску';

  @override
  String get onboardingWelcome => 'Добро пожаловать в Mentoring Protector';

  @override
  String get onboardingWelcomeDesc =>
      'Давайте настроим защиту под ваш уровень опыта. Это займёт меньше минуты.';

  @override
  String get onboardingLevelTitle => 'Ваш уровень';

  @override
  String get onboardingLevelDesc =>
      'Выберите, как вы оцениваете свой опыт в кибербезопасности';

  @override
  String get onboardingBeginner => 'Новичок';

  @override
  String get onboardingBeginnerDesc =>
      'Я только начинаю разбираться в безопасности';

  @override
  String get onboardingRegular => 'Обычный пользователь';

  @override
  String get onboardingRegularDesc => 'Знаю основы, но хочу узнать больше';

  @override
  String get onboardingAdvanced => 'Опытный';

  @override
  String get onboardingAdvancedDesc => 'Хорошо разбираюсь в IT-безопасности';

  @override
  String get onboardingGoalTitle => 'Ваша цель';

  @override
  String get onboardingGoalDesc => 'Что для вас важнее всего?';

  @override
  String get onboardingGoalMax => 'Максимальная защита';

  @override
  String get onboardingGoalMaxDesc =>
      'Блокировать всё подозрительное, лучше перестраховаться';

  @override
  String get onboardingGoalBalanced => 'Баланс удобства и защиты';

  @override
  String get onboardingGoalBalancedDesc => 'Предупреждать, но не мешать работе';

  @override
  String get onboardingGoalLearn => 'Хочу учиться';

  @override
  String get onboardingGoalLearnDesc =>
      'Показывать подробные объяснения угроз и как их распознавать';

  @override
  String get onboardingStart => 'Начать';

  @override
  String get onboardingNext => 'Далее';

  @override
  String get onboardingBack => 'Назад';

  @override
  String get profileTitle => 'Профиль безопасности';

  @override
  String get profileLevel => 'Уровень';

  @override
  String get profileRiskScore => 'Индекс риска';

  @override
  String get profileSafetyScore => 'Уровень безопасности';

  @override
  String get profileRiskTierSafe => 'Безопасное поведение';

  @override
  String get profileRiskTierCautious => 'Осторожное поведение';

  @override
  String get profileRiskTierRisky => 'Есть рискованные привычки';

  @override
  String get profileRiskTierDangerous => 'Часто игнорирует предупреждения';

  @override
  String get profilePositiveActions => 'Правильных действий';

  @override
  String get profileRiskyActions => 'Рискованных действий';

  @override
  String get profileRecentEvents => 'Последние события';

  @override
  String get profileNoEvents => 'Событий пока нет - продолжайте в том же духе!';

  @override
  String get profileWhyRisky => 'Почему система считает вас в зоне риска';

  @override
  String get profileEventWebIgnored =>
      'Проигнорировано предупреждеждие веб-защиты';

  @override
  String get profileEventScanIgnored => 'Проигнорирована обнаруженная угроза';

  @override
  String get profileEventProtDisabled => 'Отключён модуль защиты';

  @override
  String get profileEventDangerDownload => 'Опасное скачивание';

  @override
  String get profileEventLesson => 'Пройден обучающий модуль';

  @override
  String get profileEventProtEnabled => 'Включён модуль защиты';

  @override
  String get profileEventQuarantined => 'Угроза отправлена в карантин';

  @override
  String get dbStatusTitle => 'Состояние баз';

  @override
  String get dbStatusUpdated => 'Обновлена';

  @override
  String get dbStatusOutdated => 'Требует обновления';

  @override
  String get dbStatusNeverUpdated => 'Не обновлялась';

  @override
  String get dbStatusLastUpdate => 'Последнее обновление';

  @override
  String get dbStatusUpdate => 'Обновить';

  @override
  String get dbStatusUpdating => 'Обновление...';

  @override
  String get dbUpdateFellBackPython =>
      'Обновлено через Python (CVD-парсер дал сбой)';

  @override
  String get dbUpdateMd5Failed =>
      'Несовпадение контрольной суммы CVD - обновление пропущено';

  @override
  String get dbUpdateProgress => 'Загрузка базы сигнатур…';

  @override
  String get yaraRulesTitle => 'Движок YARA-правил';

  @override
  String yaraRulesCount(int count) {
    return 'Загружено правил: $count';
  }

  @override
  String get yaraUnavailable => 'Движок YARA недоступен';

  @override
  String get yaraReloadButton => 'Перезагрузить правила';

  @override
  String get yaraReloadSuccess => 'YARA-правила успешно перезагружены';

  @override
  String get yaraReloadFailed => 'Не удалось перезагрузить YARA-правила';

  @override
  String get activeEnginesLabel => 'Активные движки';

  @override
  String get engineSignatures => 'Сигнатуры';

  @override
  String get engineHeuristic => 'Эвристика';

  @override
  String get engineYara => 'YARA';

  @override
  String get engineBloom => 'Bloom-фильтр';

  @override
  String get windowMinimize => 'Свернуть';

  @override
  String get windowMaximize => 'Развернуть';

  @override
  String get windowRestore => 'Восстановить';

  @override
  String get windowClose => 'Закрыть';

  @override
  String eventThreatFound(String name) {
    return 'Обнаружена угроза: $name';
  }

  @override
  String get eventScanComplete => 'Сканирование завершено';

  @override
  String eventScanThreats(int count) {
    return 'Обнаружено угроз: $count';
  }

  @override
  String get eventProtectionStarted => 'Защита в реальном времени включена';

  @override
  String get eventProtectionStopped => 'Защита в реальном времени отключена';

  @override
  String get threatSuspiciousImports => 'Подозрительные импорты WinAPI';

  @override
  String get threatSuspiciousStrings => 'Подозрительные строки';

  @override
  String get threatOpenFileLocation => 'Открыть расположение файла';

  @override
  String get threatVerdictClean => 'Чисто';

  @override
  String get threatVerdictSuspicious => 'Подозрительно';

  @override
  String get threatVerdictLikelyMalicious => 'Вероятно вредоносный';

  @override
  String get threatVerdictMalicious => 'Вредоносный';

  @override
  String get threatVerdictUnknown => 'Неизвестно';

  @override
  String get threatSuspicionLevel => 'Уровень подозрительности';

  @override
  String get threatPeFile => 'PE файл';

  @override
  String get threatSigned => 'Подписан';

  @override
  String get threatCertRevoked => 'Сертификат отозван';

  @override
  String get threatUnsigned => 'Без подписи';

  @override
  String threatEntropyValue(String value) {
    return 'Энтропия: $value';
  }

  @override
  String get threatSigRevokedTitle => 'Подпись - СЕРТИФИКАТ ОТОЗВАН';

  @override
  String get threatDigitalSignatureTitle => 'Цифровая подпись';

  @override
  String get threatSigner => 'Подписант';

  @override
  String get threatIssuer => 'Издатель';

  @override
  String get threatValidUntil => 'Действует до';

  @override
  String get threatRevokedWarning =>
      'Отозванный сертификат означает, что ключ подписи мог быть скомпрометирован. Файлу нельзя доверять.';

  @override
  String get threatUnknownThreat => 'Неизвестная угроза';

  @override
  String get threatUnknownDesc => 'Обнаружен подозрительный файл.';

  @override
  String get threatQuarantineStep => 'Поместите файл в карантин';

  @override
  String threatAuthorPrefix(String name) {
    return 'Автор: $name';
  }

  @override
  String get vulnComponent => 'Компонент';

  @override
  String get vulnDescriptionLabel => 'Описание';

  @override
  String get vulnAutoFixButton => 'Исправить автоматически';

  @override
  String get vulnFixInProgress => 'Исправляем…';

  @override
  String get vulnFixSuccess => 'Успешно исправлено';

  @override
  String get vulnFixError => 'Не удалось исправить';

  @override
  String get vulnFixUacDenied => 'Вы отменили подтверждение UAC';

  @override
  String get vulnFixRebootRequired => 'Требуется перезагрузка';

  @override
  String get vulnFixRebootBody =>
      'Это исправление вступит в силу после перезагрузки системы. Перезагрузить сейчас?';

  @override
  String get vulnFixRebootNow => 'Перезагрузить сейчас';

  @override
  String get vulnFixRebootLater => 'Позже';

  @override
  String get vulnFixRebootManual =>
      'Пожалуйста, перезагрузите компьютер, чтобы применить изменения';

  @override
  String scanTimeSec(int sec) {
    return '$sec с';
  }

  @override
  String scanTimeMinSec(int min, int sec) {
    return '$min мин $sec с';
  }

  @override
  String get memThreatLabel => 'Угроза';

  @override
  String get memPathLabel => 'Путь';

  @override
  String get memMatchesLabel => 'Совпадений';

  @override
  String get memRegionsLabel => 'Регионов проверено';

  @override
  String get memMemoryScanned => 'Памяти проверено';

  @override
  String get memMb => 'МБ';

  @override
  String get memDetectedSignatures => 'Обнаруженные сигнатуры:';

  @override
  String get processFunctionUnavailable =>
      'Функция недоступна в текущей версии DLL';

  @override
  String processErrorPrefix(String message) {
    return 'Ошибка: $message';
  }

  @override
  String get processPathLabel => 'Путь';

  @override
  String get processVerdictLabel => 'Вердикт';

  @override
  String get processDangerLevel => 'Уровень угрозы';

  @override
  String get processSuspicionScore => 'Оценка подозрительности';

  @override
  String get processThreatLabel => 'Угроза';

  @override
  String get processDetectionMethod => 'Метод обнаружения';

  @override
  String get processRulesLabel => 'Правила';

  @override
  String get processHashLabel => 'Хеш';

  @override
  String processTerminatedMsg(String name) {
    return 'Процесс $name завершён';
  }

  @override
  String get processTerminate => 'Завершить';

  @override
  String get processAllow => 'Разрешить';

  @override
  String get processWasTerminated => 'Процесс был завершён';

  @override
  String get inspectButton => 'Инспектировать процесс';

  @override
  String get inspectTitle => 'Инспекция процесса';

  @override
  String get inspectBasicInfo => 'Общие сведения';

  @override
  String get inspectParentPid => 'Родительский PID';

  @override
  String get inspectProcessName => 'Процесс';

  @override
  String get inspectSignature => 'Подпись';

  @override
  String get inspectCmdline => 'Командная строка';

  @override
  String get inspectFileHash => 'Хеш файла';

  @override
  String inspectModules(int count) {
    return 'Загружено модулей: $count';
  }

  @override
  String get exclusionMaskType => 'Маска расширения';

  @override
  String get exclusionFolderType => 'Папка';

  @override
  String get exclusionPathType => 'Путь';

  @override
  String get hygieneIndexTitle => 'Индекс цифровой гигиены';

  @override
  String hygieneIndexGrowth(int value) {
    return '+$value за неделю';
  }

  @override
  String hygieneIndexDecline(int value) {
    return '-$value за неделю';
  }

  @override
  String hygieneCompleted(int done, int total) {
    return 'Советов пройдено: $done / $total';
  }

  @override
  String get hygieneHistory => 'За 30 дней';

  @override
  String get hygieneWeeklyTitle => 'Рекомендовано для вас';

  @override
  String get hygieneWeeklySubtitle => 'На основе вашей недавней активности';

  @override
  String get hygieneAllTips => 'Все советы';

  @override
  String get hygieneTipDone => 'Пройдено';

  @override
  String get hygieneTipMarkDone => 'Отметить пройденным';

  @override
  String get hygieneTipUndo => 'Отменить';

  @override
  String get hygieneReasonWeb =>
      'Вы недавно проигнорировали предупреждение веб-защиты';

  @override
  String get hygieneReasonScan =>
      'Вы недавно проигнорировали обнаруженную угрозу';

  @override
  String get hygieneReasonDownload => 'Вы недавно скачали подозрительный файл';

  @override
  String get hygieneReasonProtection => 'Вы недавно отключили модуль защиты';

  @override
  String get hygieneRecommended => 'Рекомендовано';

  @override
  String get copyPath => 'Скопировать путь';

  @override
  String get copyInstructions => 'Скопировать инструкцию';

  @override
  String get copiedToClipboard => 'Скопировано в буфер обмена';

  @override
  String get quizTitle => 'Проверка знаний';

  @override
  String get quizNext => 'Далее';

  @override
  String get quizFinish => 'Результаты';

  @override
  String get quizClose => 'Закрыть';

  @override
  String get quizResultTitle => 'Квиз пройден!';

  @override
  String quizResultScore(int correct, int total) {
    return '$correct/$total';
  }

  @override
  String get quizResultPerfect =>
      'Отлично! Вы хорошо разбираетесь в этой теме.';

  @override
  String get quizResultKeepLearning =>
      'Перечитайте совет и попробуйте снова для закрепления знаний.';

  @override
  String get quizTakeQuiz => 'Пройти квиз';

  @override
  String get quizPassed => 'Квиз пройден';

  @override
  String get quizUpdateQ1 =>
      'Почему важно устанавливать обновления ОС и программ?';

  @override
  String get quizUpdateQ1A1 =>
      'Они закрывают уязвимости, которые используют злоумышленники';

  @override
  String get quizUpdateQ1A2 => 'Они только добавляют новые функции';

  @override
  String get quizUpdateQ1A3 => 'Они ускоряют работу компьютера';

  @override
  String get quizUpdateQ1Explain =>
      'Обновления часто закрывают известные уязвимости (CVE). Атака WannaCry в 2017 году использовала уязвимость, патч для которой вышел за 2 месяца до атаки.';

  @override
  String get quizUpdateQ2 =>
      'Что делать, если обновление требует перезагрузки?';

  @override
  String get quizUpdateQ2A1 =>
      'Сохранить работу и перезагрузиться в ближайшее время';

  @override
  String get quizUpdateQ2A2 =>
      'Откладывать бесконечно - перезагрузки раздражают';

  @override
  String get quizUpdateQ2A3 => 'Полностью отключить автоматические обновления';

  @override
  String get quizUpdateQ2Explain =>
      'Откладывание перезагрузки оставляет систему уязвимой. Большинство атак нацелены на уже известные и исправленные уязвимости.';

  @override
  String get quizPasswordQ1 => 'Какой пароль самый надёжный?';

  @override
  String get quizPasswordQ1A1 =>
      'Случайная фраза: правильная лошадь батарейка скрепка';

  @override
  String get quizPasswordQ1A2 => 'Дата рождения: 19052000';

  @override
  String get quizPasswordQ1A3 => 'Простая замена: P@ssword123';

  @override
  String get quizPasswordQ1Explain =>
      'Случайные фразы длинные и трудно угадываемые, но легко запоминаются. Подстановки вроде P@ssword хорошо известны злоумышленникам.';

  @override
  String get quizPasswordQ2 => 'Почему для каждого сервиса нужен свой пароль?';

  @override
  String get quizPasswordQ2A1 =>
      'При утечке одного сервиса злоумышленники не получат доступ к остальным';

  @override
  String get quizPasswordQ2A2 =>
      'Это не обязательно - одного сильного пароля достаточно';

  @override
  String get quizPasswordQ2A3 => 'Сайты этого требуют';

  @override
  String get quizPasswordQ2Explain =>
      'Атаки credential stuffing проверяют утечённые пароли на множестве сервисов. Уникальные пароли ограничивают ущерб одним взломанным сервисом.';

  @override
  String get quizPhishingQ1 =>
      'Вы получили письмо от support@paypa1.com с просьбой подтвердить аккаунт. Что делать?';

  @override
  String get quizPhishingQ1A1 =>
      'Не нажимать - \'paypa1\' использует цифру 1 вместо буквы l';

  @override
  String get quizPhishingQ1A2 => 'Перейти по ссылке и ввести логин';

  @override
  String get quizPhishingQ1A3 => 'Переслать письмо друзьям';

  @override
  String get quizPhishingQ1Explain =>
      'Атаки с использованием похожих символов (1 вместо l, 0 вместо O) - гомоглифы. Всегда проверяйте точное написание домена.';

  @override
  String get quizPhishingQ2 => 'Как безопаснее всего зайти на сайт банка?';

  @override
  String get quizPhishingQ2A1 =>
      'Вручную ввести адрес или использовать сохранённую закладку';

  @override
  String get quizPhishingQ2A2 => 'Найти в Google и нажать первый результат';

  @override
  String get quizPhishingQ2A3 => 'Перейти по ссылке из письма от банка';

  @override
  String get quizPhishingQ2Explain =>
      'Злоумышленники могут покупать рекламу выше настоящих результатов, а поддельные письма - обычное дело. Ручной ввод или закладки - самый безопасный способ.';

  @override
  String get quizPhishingQ3 =>
      'На сайте есть значок замка (HTTPS). Значит ли это, что сайт безопасен?';

  @override
  String get quizPhishingQ3A1 =>
      'Нет - HTTPS означает только шифрование соединения, а не надёжность сайта';

  @override
  String get quizPhishingQ3A2 => 'Да - замок гарантирует легитимность сайта';

  @override
  String get quizPhishingQ3A3 => 'Только если замок зелёного цвета';

  @override
  String get quizPhishingQ3Explain =>
      'Бесплатные сертификаты (Let\'s Encrypt) позволяют фишинговым сайтам тоже иметь HTTPS. Замок шифрует трафик, но не проверяет намерения сайта.';

  @override
  String get quizDownloadQ1 =>
      'Вам нужна программа. Откуда безопаснее скачивать?';

  @override
  String get quizDownloadQ1A1 =>
      'С официального сайта разработчика или из магазина приложений';

  @override
  String get quizDownloadQ1A2 => 'С торрента с пометкой \'cracked\'';

  @override
  String get quizDownloadQ1A3 => 'С первого попавшегося сайта в поиске';

  @override
  String get quizDownloadQ1Explain =>
      'Сторонние сайты и кряки часто содержат вредоносное ПО. Официальные источники и магазины проверяют целостность программ.';

  @override
  String get quizDownloadQ2 =>
      'У скачанного файла двойное расширение \'invoice.pdf.exe\'. Что это значит?';

  @override
  String get quizDownloadQ2A1 =>
      'Это исполняемый файл, замаскированный под PDF - скорее всего вирус';

  @override
  String get quizDownloadQ2A2 => 'Это обычный PDF-документ';

  @override
  String get quizDownloadQ2A3 => 'Windows автоматически добавила расширение';

  @override
  String get quizDownloadQ2Explain =>
      'Windows по умолчанию скрывает расширения. Злоумышленники добавляют фальшивое расширение перед настоящим (.exe), чтобы обмануть пользователя.';

  @override
  String get quizWifiQ1 => 'Почему публичный Wi-Fi (кафе, аэропорты) опасен?';

  @override
  String get quizWifiQ1A1 =>
      'Злоумышленники в той же сети могут перехватить ваш незашифрованный трафик';

  @override
  String get quizWifiQ1A2 => 'Он всегда медленнее мобильного интернета';

  @override
  String get quizWifiQ1A3 =>
      'Публичный Wi-Fi безопасен, если сайт использует HTTPS';

  @override
  String get quizWifiQ1Explain =>
      'В публичных сетях злоумышленники могут проводить атаки man-in-the-middle. Используйте VPN или избегайте ввода конфиденциальных данных.';

  @override
  String get quiz2faQ1 => 'Что такое двухфакторная аутентификация (2FA)?';

  @override
  String get quiz2faQ1A1 =>
      'Дополнительный шаг проверки (код по SMS/приложению) помимо пароля';

  @override
  String get quiz2faQ1A2 => 'Использование двух разных паролей';

  @override
  String get quiz2faQ1A3 => 'Вход с двух устройств одновременно';

  @override
  String get quiz2faQ1Explain =>
      '2FA требует то, что вы знаете (пароль) + то, что у вас есть (телефон/токен). Даже при утечке пароля злоумышленник не сможет войти без второго фактора.';

  @override
  String get hygieneUpdateDescBeginner =>
      'Устанавливайте обновления сразу, как они появляются - они закрывают дыры, через которые проникают вирусы.';

  @override
  String get hygieneUpdateDescAdvanced =>
      'Своевременно применяйте патчи ОС и приложений. Zero-day эксплойты нацелены на известные CVE в течение часов после публикации.';

  @override
  String get hygienePasswordDescBeginner =>
      'Используйте разные длинные пароли для каждого сайта. Менеджер паролей запомнит их за вас.';

  @override
  String get hygienePasswordDescAdvanced =>
      'Используйте менеджер паролей с уникальными 16+ символьными паролями. Включите мониторинг утечек (HaveIBeenPwned).';

  @override
  String get hygienePhishingDescBeginner =>
      'Не нажимайте на ссылки в подозрительных письмах. Проверяйте, кто отправил сообщение и куда ведёт ссылка.';

  @override
  String get hygienePhishingDescAdvanced =>
      'Проверяйте заголовки SPF/DKIM, инспектируйте URL через наведение, следите за гомоглифными доменами и сокращателями ссылок.';

  @override
  String get hygieneDownloadDescBeginner =>
      'Скачивайте программы только с официальных сайтов. Кряки и взломанные программы почти всегда содержат вирусы.';

  @override
  String get hygieneDownloadDescAdvanced =>
      'Проверяйте хеши файлов и цифровые подписи перед запуском. Используйте песочницу для недоверенных файлов.';

  @override
  String get hygieneWifiDescBeginner =>
      'Не вводите пароли и банковские данные через публичный Wi-Fi. Используйте мобильный интернет или VPN.';

  @override
  String get hygieneWifiDescAdvanced =>
      'Публичные сети допускают MITM/ARP-спуфинг. Используйте WireGuard/OpenVPN; проверяйте TLS certificate pinning критичных сервисов.';

  @override
  String get hygiene2faDescBeginner =>
      'Включите двухфакторную аутентификацию - даже если кто-то узнает ваш пароль, войти без кода он не сможет.';

  @override
  String get hygiene2faDescAdvanced =>
      'Включите TOTP или FIDO2/WebAuthn. Избегайте SMS-based 2FA из-за атак SIM-swap.';

  @override
  String get quizRetake => 'Пройти заново';

  @override
  String get quizUpdateQ1A4 => 'Обновления необязательны и не важны';

  @override
  String get quizUpdateQ2A4 => 'Устанавливать обновления только раз в год';

  @override
  String get quizUpdateQ3 => 'Что такое уязвимость нулевого дня (zero-day)?';

  @override
  String get quizUpdateQ3A1 =>
      'Уязвимость, которую эксплуатируют до выхода патча от разработчика';

  @override
  String get quizUpdateQ3A2 => 'Вирус, который активируется в полночь';

  @override
  String get quizUpdateQ3A3 => 'Компьютер, который работает ноль дней';

  @override
  String get quizUpdateQ3A4 => 'Пароль, который истекает через ноль дней';

  @override
  String get quizUpdateQ3Explain =>
      'Zero-day означает, что у разработчика было «ноль дней» на исправление. Это самые опасные уязвимости, так как патча ещё не существует. Своевременные обновления сокращают окно уязвимости.';

  @override
  String get quizPasswordQ1A4 => 'Одно слово из словаря: \'солнышко\'';

  @override
  String get quizPasswordQ2A4 =>
      'Браузер сам запоминает пароли, беспокоиться не о чем';

  @override
  String get quizPasswordQ3 => 'Что такое менеджер паролей?';

  @override
  String get quizPasswordQ3A1 =>
      'Программа, которая генерирует и безопасно хранит уникальные пароли для каждого сервиса';

  @override
  String get quizPasswordQ3A2 =>
      'Расширение браузера, показывающее сохранённые пароли открытым текстом';

  @override
  String get quizPasswordQ3A3 =>
      'Текстовый файл, куда вы записываете все пароли';

  @override
  String get quizPasswordQ3A4 =>
      'Настройка Windows, которая запоминает ваш логин';

  @override
  String get quizPasswordQ3Explain =>
      'Менеджеры паролей шифруют хранилище мастер-паролем. Они генерируют случайные уникальные пароли, автозаполняют формы входа и предупреждают об утечках.';

  @override
  String get quizPhishingQ1A4 => 'Ответить с просьбой подтвердить их личность';

  @override
  String get quizPhishingQ2A4 => 'Перейти по ссылке из социальной сети';

  @override
  String get quizPhishingQ3A4 => 'HTTPS вообще не имеет значения';

  @override
  String get quizDownloadQ1A4 => 'Ссылка от незнакомца в мессенджере';

  @override
  String get quizDownloadQ2A4 => 'Это сжатый PDF для быстрой загрузки';

  @override
  String get quizDownloadQ3 =>
      'Что нужно проверить перед запуском скачанной программы?';

  @override
  String get quizDownloadQ3A1 =>
      'Цифровую подпись - валидная подпись подтверждает личность издателя';

  @override
  String get quizDownloadQ3A2 =>
      'Размер файла - большие файлы всегда безопаснее';

  @override
  String get quizDownloadQ3A3 =>
      'Иконку файла - у легитимных программ профессиональные иконки';

  @override
  String get quizDownloadQ3A4 =>
      'Ничего - если антивирус не заблокировал, значит безопасно';

  @override
  String get quizDownloadQ3Explain =>
      'Цифровая подпись подтверждает, что файл получен от заявленного издателя и не был изменён. К неподписанным исполняемым файлам из интернета следует относиться с особой осторожностью.';

  @override
  String get quizWifiQ1A4 =>
      'Публичный Wi-Fi опасен только если сеть без пароля';

  @override
  String get quizWifiQ2 =>
      'Что такое VPN и зачем использовать его в публичном Wi-Fi?';

  @override
  String get quizWifiQ2A1 =>
      'Он шифрует весь трафик через защищённый туннель, скрывая его от злоумышленников в сети';

  @override
  String get quizWifiQ2A2 => 'Он ускоряет интернет';

  @override
  String get quizWifiQ2A3 => 'Он автоматически блокирует все вирусы';

  @override
  String get quizWifiQ2A4 => 'Он заменяет антивирус';

  @override
  String get quizWifiQ2Explain =>
      'VPN (Virtual Private Network) создаёт зашифрованный туннель между вашим устройством и сервером. Даже если злоумышленник перехватит трафик в публичном Wi-Fi, он увидит только зашифрованные данные.';

  @override
  String get quizWifiQ3 =>
      'Вы видите в аэропорту сеть Wi-Fi \'Free_Airport_WiFi\'. В чём риск?';

  @override
  String get quizWifiQ3A1 =>
      'Это может быть поддельная точка доступа для перехвата ваших данных';

  @override
  String get quizWifiQ3A2 => 'Бесплатные сети в аэропортах всегда безопасны';

  @override
  String get quizWifiQ3A3 => 'Единственный риск - низкая скорость';

  @override
  String get quizWifiQ3A4 =>
      'Wi-Fi в аэропорту контролируется охраной, поэтому всегда безопасен';

  @override
  String get quizWifiQ3Explain =>
      'Атаки «злой двойник» создают поддельные точки доступа, имитирующие легитимные сети. Всегда уточняйте официальное имя сети у персонала и используйте VPN.';

  @override
  String get quiz2faQ1A4 => 'Наличие двух почтовых аккаунтов';

  @override
  String get quiz2faQ2 => 'Какой метод 2FA самый безопасный?';

  @override
  String get quiz2faQ2A1 =>
      'Аппаратный ключ (FIDO2/YubiKey) или приложение-аутентификатор (TOTP)';

  @override
  String get quiz2faQ2A2 => 'SMS-коды на телефон';

  @override
  String get quiz2faQ2A3 => 'Ссылки для подтверждения по email';

  @override
  String get quiz2faQ2A4 =>
      'Контрольные вопросы (девичья фамилия матери и т.д.)';

  @override
  String get quiz2faQ2Explain =>
      'Аппаратные ключи и TOTP-приложения устойчивы к фишингу и атакам SIM-swap. SMS-коды могут быть перехвачены через клонирование SIM. Контрольные вопросы легко угадать по соцсетям.';

  @override
  String get quiz2faQ3 =>
      'Вы потеряли телефон с приложением-аутентификатором. Что нужно было подготовить заранее?';

  @override
  String get quiz2faQ3A1 =>
      'Резервные коды восстановления, хранящиеся в безопасном месте';

  @override
  String get quiz2faQ3A2 => 'Ничего - всегда можно позвонить в поддержку';

  @override
  String get quiz2faQ3A3 => 'Другой телефон с таким же приложением';

  @override
  String get quiz2faQ3A4 => 'Пароля достаточно для восстановления доступа';

  @override
  String get quiz2faQ3Explain =>
      'Большинство сервисов предоставляют одноразовые резервные коды при настройке 2FA. Храните их офлайн (распечатанными или в менеджере паролей) - это ваш экстренный доступ при потере устройства.';

  @override
  String get quizBackupQ1 => 'Что такое правило резервного копирования 3-2-1?';

  @override
  String get quizBackupQ1A1 =>
      '3 копии данных на 2 разных типах носителей, 1 копия вне офиса';

  @override
  String get quizBackupQ1A2 => 'Копировать 3 файла, 2 раза в день, на 1 диск';

  @override
  String get quizBackupQ1A3 => 'Использовать 3 пароля, 2 аккаунта, 1 компьютер';

  @override
  String get quizBackupQ1A4 => '3 антивируса, 2 файрвола, 1 VPN';

  @override
  String get quizBackupQ1Explain =>
      'Правило 3-2-1 гарантирует, что ни одна единичная поломка (сбой диска, шифровальщик, пожар) не уничтожит все ваши данные. «Вне офиса» означает облако или физически отдельное место.';

  @override
  String get quizBackupQ2 =>
      'Как программа-шифровальщик может повлиять на ваши бэкапы?';

  @override
  String get quizBackupQ2A1 =>
      'Она может зашифровать бэкапы на подключённых дисках, сделав их бесполезными';

  @override
  String get quizBackupQ2A2 =>
      'Шифровальщик поражает только ОС, а не файлы данных';

  @override
  String get quizBackupQ2A3 => 'Бэкапы неуязвимы для шифровальщиков';

  @override
  String get quizBackupQ2A4 =>
      'Шифровальщик не может распространиться на внешние диски';

  @override
  String get quizBackupQ2Explain =>
      'Шифровальщик шифрует всё, к чему имеет доступ, включая подключённые диски с бэкапами. Храните хотя бы одну копию офлайн (отключённой) или используйте версионные облачные бэкапы с неизменяемыми снимками.';

  @override
  String get quizBackupQ3 => 'Как часто нужно проверять свои бэкапы?';

  @override
  String get quizBackupQ3A1 =>
      'Регулярно - непроверенный бэкап может быть повреждён или неполным';

  @override
  String get quizBackupQ3A2 =>
      'Никогда - если копирование прошло без ошибок, бэкап работает';

  @override
  String get quizBackupQ3A3 => 'Только после того, как произойдёт катастрофа';

  @override
  String get quizBackupQ3A4 => 'Один раз при первой настройке бэкапа';

  @override
  String get quizBackupQ3Explain =>
      'Непроверенные бэкапы могут содержать повреждённые файлы, неполные данные или несовместимые форматы. Планируйте периодические тестовые восстановления, чтобы убедиться в работоспособности.';

  @override
  String get quizUsbQ1 => 'Вы нашли USB-накопитель на парковке. Что делать?';

  @override
  String get quizUsbQ1A1 =>
      'НЕ подключать - он может содержать вредоносное ПО, запускающееся автоматически';

  @override
  String get quizUsbQ1A2 => 'Подключить, чтобы найти контакты владельца';

  @override
  String get quizUsbQ1A3 =>
      'Сначала проверить антивирусом, потом можно открывать';

  @override
  String get quizUsbQ1A4 => 'Отформатировать и использовать как свой';

  @override
  String get quizUsbQ1Explain =>
      'Атаки через подброшенные USB - реальная техника социальной инженерии. Вредоносные USB-устройства могут автоматически выполнять код (BadUSB), устанавливать бэкдоры или даже физически повредить оборудование (USB Killer).';

  @override
  String get quizUsbQ2 => 'Что такое атака BadUSB?';

  @override
  String get quizUsbQ2A1 =>
      'USB-устройство, которое притворяется клавиатурой и вводит вредоносные команды';

  @override
  String get quizUsbQ2A2 => 'Сломанный USB-кабель, повреждающий порт';

  @override
  String get quizUsbQ2A3 => 'Вирус, распространяющийся через USB-хабы';

  @override
  String get quizUsbQ2A4 =>
      'Поддельное USB-зарядное устройство, которое заряжает слишком медленно';

  @override
  String get quizUsbQ2Explain =>
      'BadUSB перепрограммирует прошивку USB-контроллера для имитации клавиатуры. Оно может вводить команды со сверхчеловеческой скоростью, загружая и запуская вредоносное ПО за секунды.';

  @override
  String get quizUsbQ3 =>
      'Как безопасно использовать USB-накопители на работе?';

  @override
  String get quizUsbQ3A1 =>
      'Использовать только утверждённые компанией зашифрованные накопители и отключить автозапуск';

  @override
  String get quizUsbQ3A2 =>
      'Любой USB-накопитель подойдёт, если сначала его просканировать';

  @override
  String get quizUsbQ3A3 =>
      'Использовать только накопители от доверенных коллег';

  @override
  String get quizUsbQ3A4 => 'USB-накопители устарели и никогда не нужны';

  @override
  String get quizUsbQ3Explain =>
      'Утверждённые компанией зашифрованные накопители предотвращают утечку данных при потере. Отключение автозапуска останавливает автоматический запуск вредоносного ПО при подключении.';

  @override
  String get quizPrivacyQ1 =>
      'Какую информацию сайты могут собирать о вас без cookies?';

  @override
  String get quizPrivacyQ1A1 =>
      'Цифровой отпечаток браузера: разрешение экрана, установленные шрифты, часовой пояс и другое';

  @override
  String get quizPrivacyQ1A2 =>
      'Ничего - cookies единственный метод отслеживания';

  @override
  String get quizPrivacyQ1A3 => 'Только ваш IP-адрес';

  @override
  String get quizPrivacyQ1A4 =>
      'Только страницы, которые вы посещаете на этом конкретном сайте';

  @override
  String get quizPrivacyQ1Explain =>
      'Фингерпринтинг браузера объединяет десятки технических деталей (размер экрана, GPU, шрифты, часовой пояс, язык) в уникальный идентификатор. Даже без cookies ~95% пользователей можно уникально идентифицировать.';

  @override
  String get quizPrivacyQ2 =>
      'Зачем проверять разрешения приложений на телефоне?';

  @override
  String get quizPrivacyQ2A1 =>
      'Приложения могут запрашивать доступ к камере, микрофону или контактам сверх необходимого';

  @override
  String get quizPrivacyQ2A2 =>
      'Разрешения всегда необходимы для работы приложения';

  @override
  String get quizPrivacyQ2A3 => 'Это важно только для платных приложений';

  @override
  String get quizPrivacyQ2A4 =>
      'Разрешения не влияют на вашу конфиденциальность';

  @override
  String get quizPrivacyQ2Explain =>
      'Приложению-фонарику не нужен доступ к контактам или микрофону. Избыточные разрешения могут указывать на сбор данных. Регулярно проверяйте и отзывайте ненужные разрешения.';

  @override
  String get quizPrivacyQ3 =>
      'Какой подход к конфиденциальности в соцсетях самый безопасный?';

  @override
  String get quizPrivacyQ3A1 =>
      'Сделать профиль закрытым и ограничить публично доступную личную информацию';

  @override
  String get quizPrivacyQ3A2 =>
      'Открытые профили безопасны - только друзья видят ваши посты';

  @override
  String get quizPrivacyQ3A3 => 'Делиться всем - прозрачность - это современно';

  @override
  String get quizPrivacyQ3A4 =>
      'Использовать вымышленное имя и делиться свободно';

  @override
  String get quizPrivacyQ3Explain =>
      'Открытые профили раскрывают личные данные для атак социальной инженерии. Злоумышленники используют дни рождения, клички питомцев, названия школ для подбора паролей и контрольных вопросов.';

  @override
  String get quizLockQ1 =>
      'Почему компьютер должен автоматически блокироваться через несколько минут?';

  @override
  String get quizLockQ1A1 =>
      'Любой рядом может получить доступ к вашим файлам, почте и аккаунтам, пока вас нет';

  @override
  String get quizLockQ1A2 => 'Это экономит заряд батареи';

  @override
  String get quizLockQ1A3 => 'Это предотвращает выгорание экрана';

  @override
  String get quizLockQ1A4 => 'Это важно только в офисах, а не дома';

  @override
  String get quizLockQ1Explain =>
      'Незаблокированный компьютер - это открытая дверь. За секунды кто-то может установить вредоносное ПО, скопировать файлы или получить доступ к аккаунтам. Установите автоблокировку на 5 минут или меньше.';

  @override
  String get quizLockQ2 =>
      'Какой самый безопасный способ разблокировки компьютера?';

  @override
  String get quizLockQ2A1 =>
      'Биометрия (отпечаток/лицо) или надёжный PIN в сочетании с TPM';

  @override
  String get quizLockQ2A2 => 'Простой 4-значный PIN вроде 1234';

  @override
  String get quizLockQ2A3 => 'Без пароля - так быстрее';

  @override
  String get quizLockQ2A4 => 'Графический ключ на экране';

  @override
  String get quizLockQ2Explain =>
      'Биометрия Windows Hello + TPM обеспечивает надёжную локальную аутентификацию. Простые PIN легко угадать, а графические ключи можно подсмотреть или восстановить по отпечаткам на экране.';

  @override
  String get quizLockQ3 => 'Что такое Windows Hello?';

  @override
  String get quizLockQ3A1 =>
      'Встроенная система аутентификации по отпечатку пальца, распознаванию лица или безопасному PIN';

  @override
  String get quizLockQ3A2 => 'Приветственное сообщение при запуске Windows';

  @override
  String get quizLockQ3A3 => 'Голосовой помощник типа Cortana';

  @override
  String get quizLockQ3A4 => 'Функция родительского контроля';

  @override
  String get quizLockQ3Explain =>
      'Windows Hello хранит биометрические данные локально в аппаратном модуле TPM, а не в облаке. Это безопаснее паролей, потому что биометрию нельзя перехватить фишингом или использовать повторно.';

  @override
  String get quizExtQ1 => 'Какой риск несут расширения браузера?';

  @override
  String get quizExtQ1A1 =>
      'Они могут читать все данные на каждой странице, включая пароли и банковские реквизиты';

  @override
  String get quizExtQ1A2 => 'Они влияют только на внешний вид браузера';

  @override
  String get quizExtQ1A3 =>
      'Расширения из официального магазина всегда безопасны';

  @override
  String get quizExtQ1A4 => 'Они могут замедлить браузер, но не более того';

  @override
  String get quizExtQ1Explain =>
      'Расширения с разрешением «Читать и изменять все данные на всех сайтах» видят всё: пароли, данные карт, личные сообщения. Устанавливайте только действительно необходимые расширения.';

  @override
  String get quizExtQ2 => 'Как выбирать расширения для установки?';

  @override
  String get quizExtQ2A1 =>
      'Устанавливать только необходимые от известных разработчиков, проверять разрешения и отзывы';

  @override
  String get quizExtQ2A2 =>
      'Устанавливать как можно больше для максимальной функциональности';

  @override
  String get quizExtQ2A3 => 'Смотреть только на рейтинг звёзд';

  @override
  String get quizExtQ2A4 => 'Рекомендации друзей всегда надёжны';

  @override
  String get quizExtQ2Explain =>
      'Даже популярные расширения могут быть проданы злоумышленникам, которые выпустят троянизированное обновление. Минимизируйте расширения, проверяйте разрешения, удаляйте неиспользуемые.';

  @override
  String get quizExtQ3 =>
      'Расширение, которым вы пользуетесь месяцами, внезапно запрашивает новые разрешения. Что делать?';

  @override
  String get quizExtQ3A1 =>
      'Насторожиться - оно могло быть продано или скомпрометировано; изучить причину перед принятием';

  @override
  String get quizExtQ3A2 =>
      'Принять сразу - обновления всегда требуют новых разрешений';

  @override
  String get quizExtQ3A3 => 'Проигнорировать уведомление';

  @override
  String get quizExtQ3A4 => 'Удалить и переустановить для исправления ошибки';

  @override
  String get quizExtQ3Explain =>
      'Владельцы расширений могут меняться. Новые владельцы могут добавить отслеживание, рекламу или кражу данных. Всегда изучайте, зачем нужны новые разрешения, прежде чем их предоставлять.';

  @override
  String get quizEncryptQ1 =>
      'От чего защищает полное шифрование диска (BitLocker)?';

  @override
  String get quizEncryptQ1A1 =>
      'От чтения ваших данных при краже ноутбука или извлечении диска';

  @override
  String get quizEncryptQ1A2 => 'От вирусов и вредоносного ПО';

  @override
  String get quizEncryptQ1A3 => 'От потери данных из-за поломки оборудования';

  @override
  String get quizEncryptQ1A4 =>
      'От хакеров, получающих доступ к компьютеру по сети';

  @override
  String get quizEncryptQ1Explain =>
      'Шифрование диска защищает данные в состоянии покоя. При краже ноутбука злоумышленник не сможет прочитать диск без ключа шифрования. Оно НЕ защищает от вредоносного ПО или сетевых атак.';

  @override
  String get quizEncryptQ2 =>
      'Что произойдёт с зашифрованными данными, если вы забудете ключ восстановления?';

  @override
  String get quizEncryptQ2A1 =>
      'Данные станут навсегда недоступны - обходного пути нет';

  @override
  String get quizEncryptQ2A2 => 'Microsoft может восстановить их для вас';

  @override
  String get quizEncryptQ2A3 => 'Данные временно заблокируются на 24 часа';

  @override
  String get quizEncryptQ2A4 =>
      'Можно обойти шифрование через безопасный режим';

  @override
  String get quizEncryptQ2Explain =>
      'Надёжное шифрование означает, что даже производитель не может восстановить данные без ключа. Сохраните ключ восстановления BitLocker в учётной записи Microsoft или распечатайте и храните в безопасном месте.';

  @override
  String get quizEncryptQ3 =>
      'Когда следует использовать зашифрованные мессенджеры (Signal, WhatsApp)?';

  @override
  String get quizEncryptQ3A1 =>
      'Для любых конфиденциальных разговоров - сквозное шифрование предотвращает перехват';

  @override
  String get quizEncryptQ3A2 => 'Только для незаконной деятельности';

  @override
  String get quizEncryptQ3A3 => 'Обычные мессенджеры одинаково безопасны';

  @override
  String get quizEncryptQ3A4 => 'Шифрование нужно только бизнесу';

  @override
  String get quizEncryptQ3Explain =>
      'Сквозное шифрование гарантирует, что только вы и получатель можете прочитать сообщения. Даже провайдер сервиса не имеет к ним доступа. Используйте для личных, финансовых и медицинских разговоров.';

  @override
  String get quizUpdateQ4 =>
      'Чем опасно использование программ, снятых с поддержки (End of Life)?';

  @override
  String get quizUpdateQ4A1 =>
      'Для них больше не выпускают патчи безопасности, уязвимости остаются навсегда';

  @override
  String get quizUpdateQ4A2 => 'Они работают медленнее новых версий';

  @override
  String get quizUpdateQ4A3 => 'Они занимают больше места на диске';

  @override
  String get quizUpdateQ4A4 => 'Разработчик может удалить их удалённо';

  @override
  String get quizUpdateQ4Explain =>
      'Программы с истёкшей поддержкой (например, Windows 7) не получают обновлений безопасности. Все найденные уязвимости остаются открытыми навсегда, превращая систему в лёгкую мишень.';

  @override
  String get quizUpdateQ5 => 'Какой риск несёт автообновление программ?';

  @override
  String get quizUpdateQ5A1 =>
      'Минимальный - преимущества безопасности перевешивают редкие сбои';

  @override
  String get quizUpdateQ5A2 => 'Высокий - обновления всегда ломают систему';

  @override
  String get quizUpdateQ5A3 => 'Никакого - обновления невозможно подделать';

  @override
  String get quizUpdateQ5A4 => 'Обновления замедляют компьютер навсегда';

  @override
  String get quizUpdateQ5Explain =>
      'Автообновление - лучшая практика: оно закрывает уязвимости быстрее, чем злоумышленники их используют. Редкие сбои после обновлений легко решаемы, а незакрытые дыры - нет.';

  @override
  String get quizPasswordQ4 => 'Что делает пароль по-настоящему надёжным?';

  @override
  String get quizPasswordQ4A1 =>
      'Длина от 12 символов и случайность - не слова из словаря и не личные данные';

  @override
  String get quizPasswordQ4A2 => 'Замена букв на символы: P@\$\$w0rd';

  @override
  String get quizPasswordQ4A3 =>
      'Использование даты рождения - её легко запомнить';

  @override
  String get quizPasswordQ4A4 => 'Короткий, но с восклицательным знаком: Go!1';

  @override
  String get quizPasswordQ4Explain =>
      'Длина важнее сложности. 12-символьный случайный пароль из строчных букв устойчивее, чем 8-символьный со спецсимволами. Подстановки (@=a, 0=o) давно в словарях атакующих.';

  @override
  String get quizPasswordQ5 => 'Почему повторное использование пароля опасно?';

  @override
  String get quizPasswordQ5A1 =>
      'При утечке с одного сайта злоумышленники получат доступ ко всем вашим аккаунтам';

  @override
  String get quizPasswordQ5A2 => 'Сайты будут знать, что вы один человек';

  @override
  String get quizPasswordQ5A3 => 'Браузер перестанет сохранять пароли';

  @override
  String get quizPasswordQ5A4 => 'Это запрещено политикой безопасности';

  @override
  String get quizPasswordQ5Explain =>
      'Credential stuffing - атака, при которой украденные пары логин/пароль автоматически проверяются на сотнях сервисов. Если пароль один - взлом одного сайта открывает доступ ко всем.';

  @override
  String get quizWifiQ4 => 'Что такое captive portal и чем он опасен?';

  @override
  String get quizWifiQ4A1 =>
      'Страница авторизации в публичном Wi-Fi - может быть подделана для кражи данных';

  @override
  String get quizWifiQ4A2 => 'Программа для ускорения Wi-Fi';

  @override
  String get quizWifiQ4A3 => 'Защищённая точка доступа в кафе';

  @override
  String get quizWifiQ4A4 => 'Антивирус для роутера';

  @override
  String get quizWifiQ4Explain =>
      'Captive portal - страница входа в публичный Wi-Fi. Злоумышленник может создать фальшивую точку доступа с похожим именем и подменить страницу входа, чтобы собирать учётные данные.';

  @override
  String get quizWifiQ5 => 'В чём преимущество WPA3 перед WPA2?';

  @override
  String get quizWifiQ5A1 =>
      'Защищает от перехвата трафика даже при слабом пароле благодаря SAE-протоколу';

  @override
  String get quizWifiQ5A2 => 'Работает быстрее в 3 раза';

  @override
  String get quizWifiQ5A3 => 'Не требует пароля вообще';

  @override
  String get quizWifiQ5A4 => 'Поддерживает больше устройств';

  @override
  String get quizWifiQ5Explain =>
      'WPA3 использует протокол SAE (Simultaneous Authentication of Equals), который защищает от офлайн-перебора пароля и атак типа KRACK. Даже при слабом пароле перехватить трафик значительно сложнее.';

  @override
  String get quizPhishingQ4 => 'Что такое spear-phishing?';

  @override
  String get quizPhishingQ4A1 =>
      'Целевая фишинговая атака с использованием личной информации жертвы';

  @override
  String get quizPhishingQ4A2 => 'Фишинг через СМС-сообщения';

  @override
  String get quizPhishingQ4A3 => 'Массовая рассылка спама';

  @override
  String get quizPhishingQ4A4 => 'Фишинг только через социальные сети';

  @override
  String get quizPhishingQ4Explain =>
      'Spear-phishing - персонализированная атака: злоумышленник изучает жертву (должность, коллег, проекты) и создаёт убедительное сообщение. Эффективность такой атаки в 10 раз выше массового фишинга.';

  @override
  String get quizPhishingQ5 =>
      'Как проверить безопасность ссылки перед переходом?';

  @override
  String get quizPhishingQ5A1 =>
      'Навести курсор и проверить домен в строке состояния, не кликая';

  @override
  String get quizPhishingQ5A2 => 'Кликнуть и посмотреть, что откроется';

  @override
  String get quizPhishingQ5A3 => 'Проверить, красивая ли ссылка';

  @override
  String get quizPhishingQ5A4 =>
      'Ссылки всегда безопасны, если пришли по почте';

  @override
  String get quizPhishingQ5Explain =>
      'Перед кликом наведите курсор на ссылку - в строке состояния браузера отобразится реальный URL. Проверьте домен: gooogle.com, paypa1.com, sberbank-online.xyz - признаки фишинга.';

  @override
  String get quizBackupQ4 => 'Что такое версионные бэкапы и зачем они нужны?';

  @override
  String get quizBackupQ4A1 =>
      'Хранение нескольких копий файла за разные даты - позволяет откатиться к нужной версии';

  @override
  String get quizBackupQ4A2 =>
      'Создание бэкапа каждый день в одну и ту же папку';

  @override
  String get quizBackupQ4A3 =>
      'Использование разных паролей для каждого бэкапа';

  @override
  String get quizBackupQ4A4 =>
      'Копирование файлов с разных компьютеров на один диск';

  @override
  String get quizBackupQ4Explain =>
      'Версионные бэкапы хранят историю изменений. Если файл повреждён или зашифрован неделю назад, а вы заметили только сегодня - можно восстановить версию двухнедельной давности.';

  @override
  String get quizBackupQ5 =>
      'Почему бэкапы критически важны при атаке шифровальщика?';

  @override
  String get quizBackupQ5A1 =>
      'Позволяют восстановить данные без уплаты выкупа';

  @override
  String get quizBackupQ5A2 => 'Шифровальщик не может заразить бэкапы';

  @override
  String get quizBackupQ5A3 => 'Бэкап автоматически удаляет вирус';

  @override
  String get quizBackupQ5A4 => 'Полиция использует бэкапы для поиска хакеров';

  @override
  String get quizBackupQ5Explain =>
      'Ransomware шифрует ваши файлы и требует выкуп. Если есть офлайн-бэкап (отключённый от сети), вы просто восстанавливаете данные. Важно: бэкап на подключённом диске тоже может быть зашифрован!';

  @override
  String get quizDownloadQ4 =>
      'Почему опасно скачивать программы с агрегаторов (Softonic, CNET Downloads)?';

  @override
  String get quizDownloadQ4A1 =>
      'Они часто добавляют к установщику рекламное и нежелательное ПО';

  @override
  String get quizDownloadQ4A2 =>
      'Программы на агрегаторах всегда содержат вирусы';

  @override
  String get quizDownloadQ4A3 => 'Они замедляют скорость загрузки';

  @override
  String get quizDownloadQ4A4 => 'Агрегаторы доступны не во всех странах';

  @override
  String get quizDownloadQ4Explain =>
      'Агрегаторы (Softonic, Download.com) часто оборачивают оригинальный установщик в свой загрузчик с рекламным ПО, тулбарами и потенциально опасными программами. Скачивайте напрямую с сайта разработчика.';

  @override
  String get quizDownloadQ5 =>
      'Как злоумышленники маскируют вредоносные файлы?';

  @override
  String get quizDownloadQ5A1 =>
      'Используют двойные расширения: document.pdf.exe выглядит как PDF';

  @override
  String get quizDownloadQ5A2 => 'Рисуют картинку антивируса на иконке';

  @override
  String get quizDownloadQ5A3 => 'Переименовывают файл в «антивирус»';

  @override
  String get quizDownloadQ5A4 =>
      'Не маскируют - пользователи сами скачивают вирусы';

  @override
  String get quizDownloadQ5Explain =>
      'Windows скрывает известные расширения по умолчанию. Файл «report.pdf.exe» отображается как «report.pdf» с иконкой PDF. Включите отображение расширений: Проводник → Вид → Расширения имён файлов.';

  @override
  String get quiz2faQ4 => 'Почему приложение-аутентификатор лучше СМС для 2FA?';

  @override
  String get quiz2faQ4A1 =>
      'СМС можно перехватить через SIM-swap атаку или уязвимости SS7';

  @override
  String get quiz2faQ4A2 => 'Приложение работает без интернета';

  @override
  String get quiz2faQ4A3 => 'СМС стоит денег';

  @override
  String get quiz2faQ4A4 => 'Приложение красивее';

  @override
  String get quiz2faQ4Explain =>
      'SIM-swap: злоумышленник переносит ваш номер на свою SIM-карту через оператора. SS7: уязвимость протокола телефонии позволяет перехватывать СМС. Аутентификатор (TOTP) генерирует коды локально на устройстве.';

  @override
  String get quiz2faQ5 => 'Что такое TOTP и как он работает?';

  @override
  String get quiz2faQ5A1 =>
      'Одноразовый код, генерируемый каждые 30 секунд на основе секретного ключа и времени';

  @override
  String get quiz2faQ5A2 => 'Постоянный пароль, который присылает сервер';

  @override
  String get quiz2faQ5A3 => 'Шифрование переписки между двумя устройствами';

  @override
  String get quiz2faQ5A4 => 'Технология разблокировки телефона по отпечатку';

  @override
  String get quiz2faQ5Explain =>
      'TOTP (Time-based One-Time Password) использует общий секретный ключ и текущее время для генерации 6-значного кода. Код меняется каждые 30 секунд и действует только один раз - перехватить его бесполезно.';

  @override
  String get quizUsbQ4 => 'Что такое атака USB Rubber Ducky?';

  @override
  String get quizUsbQ4A1 =>
      'Устройство, маскирующееся под клавиатуру и мгновенно вводящее вредоносные команды';

  @override
  String get quizUsbQ4A2 => 'Вирус, стирающий данные с флешки';

  @override
  String get quizUsbQ4A3 => 'Флешка с очень большим объёмом памяти';

  @override
  String get quizUsbQ4A4 => 'USB-устройство для взлома Wi-Fi';

  @override
  String get quizUsbQ4Explain =>
      'USB Rubber Ducky выглядит как обычная флешка, но компьютер видит её как клавиатуру. За секунды она «набирает» скрипт: открывает терминал, скачивает вредонос, отключает защиту - быстрее, чем вы заметите.';

  @override
  String get quizUsbQ5 =>
      'Как безопасно проверить содержимое незнакомой флешки?';

  @override
  String get quizUsbQ5A1 =>
      'Использовать изолированную виртуальную машину или компьютер без доступа к сети';

  @override
  String get quizUsbQ5A2 =>
      'Вставить и быстро посмотреть - вирус не успеет заразить';

  @override
  String get quizUsbQ5A3 => 'Отформатировать флешку перед использованием';

  @override
  String get quizUsbQ5A4 => 'Попросить друга проверить на своём компьютере';

  @override
  String get quizUsbQ5Explain =>
      'Безопасный способ - виртуальная машина (VirtualBox, Hyper-V) без сетевого доступа. Даже если флешка заражена, вирус останется внутри виртуальной среды и не повредит основную систему.';

  @override
  String get quizPrivacyQ4 =>
      'Чем опасно чрезмерное раскрытие информации в соцсетях?';

  @override
  String get quizPrivacyQ4A1 =>
      'Злоумышленники собирают данные для социальной инженерии и подбора паролей';

  @override
  String get quizPrivacyQ4A2 =>
      'Соцсети замедляются от большого количества постов';

  @override
  String get quizPrivacyQ4A3 => 'Друзья могут обидеться на контент';

  @override
  String get quizPrivacyQ4A4 => 'Фотографии занимают место на сервере';

  @override
  String get quizPrivacyQ4Explain =>
      'Дата рождения, имя питомца, любимый фильм - частые ответы на секретные вопросы. Геолокация фото раскрывает маршруты. Информация о поездках сигнализирует о пустой квартире.';

  @override
  String get quizPrivacyQ5 => 'Что делают tracking cookies?';

  @override
  String get quizPrivacyQ5A1 =>
      'Отслеживают ваше поведение на разных сайтах для создания рекламного профиля';

  @override
  String get quizPrivacyQ5A2 => 'Ускоряют загрузку страниц';

  @override
  String get quizPrivacyQ5A3 => 'Защищают от вирусов';

  @override
  String get quizPrivacyQ5A4 => 'Сохраняют пароли от сайтов';

  @override
  String get quizPrivacyQ5Explain =>
      'Third-party tracking cookies следят за вами на тысячах сайтов, формируя подробный профиль: интересы, покупки, местоположение. Используйте режим «без отслеживания» и регулярно очищайте cookies.';

  @override
  String get quizLockQ4 =>
      'Какая комбинация клавиш мгновенно блокирует Windows?';

  @override
  String get quizLockQ4A1 =>
      'Win + L - блокирует экран за секунду, не закрывая программы';

  @override
  String get quizLockQ4A2 => 'Ctrl + Alt + Delete - выключает компьютер';

  @override
  String get quizLockQ4A3 => 'Alt + F4 - блокирует текущее окно';

  @override
  String get quizLockQ4A4 => 'Ctrl + Z - ставит компьютер на паузу';

  @override
  String get quizLockQ4Explain =>
      'Win + L - самый быстрый способ заблокировать Windows. Привычка нажимать Win + L каждый раз, когда встаёте со стула, защищает от физического доступа. Программы продолжают работать.';

  @override
  String get quizLockQ5 => 'Что такое Dynamic Lock в Windows?';

  @override
  String get quizLockQ5A1 =>
      'Автоматическая блокировка компьютера при удалении Bluetooth-устройства (телефона)';

  @override
  String get quizLockQ5A2 => 'Блокировка динамически изменяющимся паролем';

  @override
  String get quizLockQ5A3 => 'Защита от изменения системных файлов';

  @override
  String get quizLockQ5A4 => 'Антивирусная функция Windows';

  @override
  String get quizLockQ5Explain =>
      'Dynamic Lock связывается с вашим телефоном по Bluetooth. Когда вы уходите и телефон выходит из зоны действия, Windows автоматически блокирует экран примерно через 30 секунд.';

  @override
  String get quizExtQ4 =>
      'Почему важно проверять разрешения расширений браузера?';

  @override
  String get quizExtQ4A1 =>
      'Расширение с доступом «ко всем сайтам» может читать ваши пароли и данные карт';

  @override
  String get quizExtQ4A2 => 'Разрешения влияют на скорость браузера';

  @override
  String get quizExtQ4A3 => 'Без разрешений расширение не установится';

  @override
  String get quizExtQ4A4 => 'Разрешения нужны только для платных расширений';

  @override
  String get quizExtQ4Explain =>
      'Расширение с разрешением «Читать и изменять данные на всех сайтах» имеет полный доступ к содержимому страниц - включая формы логинов, банковские данные, приватную переписку. Давайте минимум разрешений.';

  @override
  String get quizExtQ5 => 'Как распознать фальшивое расширение браузера?';

  @override
  String get quizExtQ5A1 =>
      'Мало отзывов, нет ссылки на официальный сайт, запрашивает лишние разрешения';

  @override
  String get quizExtQ5A2 => 'У него некрасивая иконка';

  @override
  String get quizExtQ5A3 => 'Оно бесплатное - значит подделка';

  @override
  String get quizExtQ5A4 => 'Фальшивых расширений не бывает в магазине Chrome';

  @override
  String get quizExtQ5Explain =>
      'Признаки подделки: мало загрузок и отзывов, несоответствие названия разработчика, чрезмерные разрешения, недавняя дата публикации. Проверяйте разработчика на официальном сайте продукта.';

  @override
  String get quizEncryptQ4 => 'Зачем нужно полнодисковое шифрование BitLocker?';

  @override
  String get quizEncryptQ4A1 =>
      'Защищает все данные на диске при краже или потере ноутбука';

  @override
  String get quizEncryptQ4A2 => 'Ускоряет чтение диска';

  @override
  String get quizEncryptQ4A3 => 'Предотвращает заражение вирусами';

  @override
  String get quizEncryptQ4A4 => 'Нужно только для серверов';

  @override
  String get quizEncryptQ4Explain =>
      'Без BitLocker достаточно извлечь диск из ноутбука и подключить к другому компьютеру - все файлы будут доступны. С BitLocker данные зашифрованы и бесполезны без ключа, привязанного к TPM-модулю.';

  @override
  String get quizEncryptQ5 => 'В чём разница между HTTP и HTTPS?';

  @override
  String get quizEncryptQ5A1 =>
      'HTTPS шифрует трафик между браузером и сервером, HTTP передаёт данные открытым текстом';

  @override
  String get quizEncryptQ5A2 => 'HTTPS работает быстрее';

  @override
  String get quizEncryptQ5A3 => 'HTTP - для компьютеров, HTTPS - для телефонов';

  @override
  String get quizEncryptQ5A4 => 'Разницы нет - это одно и то же';

  @override
  String get quizEncryptQ5Explain =>
      'HTTPS использует TLS-шифрование: всё, что вы отправляете (пароли, данные карт), зашифровано. В HTTP данные передаются открытым текстом - любой в той же сети может их перехватить. Никогда не вводите пароли на HTTP-сайтах.';

  @override
  String get enableAllProtection => 'Включить всю защиту';

  @override
  String get enableAllProtectionDesc =>
      'Активировать все модули защиты одним нажатием';

  @override
  String get allProtectionEnabled => 'Все модули защиты включены';

  @override
  String get disableAllProtection => 'Отключить защиту';

  @override
  String get allProtectionDisabled => 'Все модули защиты отключены';

  @override
  String get threatRemediationTitle => 'Как устранить';

  @override
  String get threatInfectionVectorsTitle => 'Как мог попасть';

  @override
  String get threatPreventionTitle => 'Как предотвратить';

  @override
  String get threatRemTrojan =>
      '1. Отправьте файл в карантин или удалите его.\n2. Смените пароли, если троян мог их перехватить.\n3. Проверьте автозагрузку (Win+R → msconfig → Автозагрузка).\n4. Запустите полное сканирование компьютера.';

  @override
  String get threatRemAdware =>
      '1. Удалите подозрительную программу через Параметры → Приложения.\n2. Сбросьте настройки браузера.\n3. Проверьте расширения браузера и удалите неизвестные.\n4. Очистите временные файлы.';

  @override
  String get threatRemPup =>
      '1. Удалите программу через Параметры → Приложения.\n2. Проверьте, не изменились ли настройки браузера (домашняя страница, поиск).\n3. Удалите связанные расширения браузера.';

  @override
  String get threatRemWorm =>
      '1. Немедленно отключите компьютер от сети.\n2. Удалите файл и запустите полное сканирование.\n3. Проверьте все подключённые устройства и флешки.\n4. Смените пароли от сетевых аккаунтов.';

  @override
  String get threatRemRansom =>
      '1. НЕ платите выкуп - это не гарантирует возврат файлов.\n2. Отключите компьютер от сети.\n3. Проверьте наличие бэкапов.\n4. Обратитесь к специалисту по кибербезопасности.';

  @override
  String get threatRemGeneric =>
      '1. Отправьте файл в карантин для безопасного хранения.\n2. Запустите полное сканирование компьютера.\n3. Проверьте систему на другие подозрительные файлы.';

  @override
  String get threatVecTrojan =>
      '• Скачивание пиратского ПО или кряков\n• Вложения в фишинговых письмах\n• Фейковые обновления программ на сайтах\n• Заражённые USB-носители';

  @override
  String get threatVecAdware =>
      '• Установка бесплатных программ с дополнительными компонентами\n• Нажатие на обманчивую рекламу\n• Скачивание с непроверенных источников';

  @override
  String get threatVecPup =>
      '• Установка ПО через «Быстрый» режим вместо «Выборочного»\n• Бандлы при установке бесплатных программ\n• Обманчивые кнопки «Скачать» на сайтах';

  @override
  String get threatVecWorm =>
      '• Уязвимости в сетевых сервисах\n• Заражённые файлы в локальной сети\n• Автозапуск с USB-устройств\n• Эксплойты через непропатченное ПО';

  @override
  String get threatVecRansom =>
      '• Фишинговые письма с заражёнными вложениями\n• Эксплойт-киты на скомпрометированных сайтах\n• Уязвимости RDP (удалённый доступ)\n• Пиратское ПО со встроенным шифровальщиком';

  @override
  String get threatVecGeneric =>
      '• Скачивание файлов из непроверенных источников\n• Переход по подозрительным ссылкам\n• Подключение заражённых внешних устройств';

  @override
  String get threatPrevTrojan =>
      '• Скачивайте ПО только с официальных сайтов\n• Не открывайте вложения от незнакомых отправителей\n• Держите систему и антивирус обновлёнными\n• Включите двухфакторную аутентификацию на важных аккаунтах';

  @override
  String get threatPrevAdware =>
      '• При установке всегда выбирайте «Выборочную» установку\n• Не нажимайте на подозрительную рекламу и баннеры\n• Используйте блокировщик рекламы в браузере';

  @override
  String get threatPrevPup =>
      '• Читайте условия установки и снимайте галочки с дополнительных программ\n• Скачивайте ПО только с официальных сайтов\n• Используйте менеджер пакетов (winget, chocolatey)';

  @override
  String get threatPrevWorm =>
      '• Регулярно устанавливайте обновления безопасности\n• Используйте файрвол и не отключайте его\n• Отключите автозапуск с USB\n• Не подключайте к компьютеру чужие флешки';

  @override
  String get threatPrevRansom =>
      '• Регулярно создавайте резервные копии (правило 3-2-1)\n• Не открывайте подозрительные вложения\n• Отключите RDP если не используете\n• Держите ОС и ПО обновлёнными';

  @override
  String get threatPrevGeneric =>
      '• Используйте антивирус с актуальными базами\n• Не скачивайте файлы из непроверенных источников\n• Регулярно обновляйте операционную систему\n• Будьте осторожны с вложениями в письмах';

  @override
  String get scanPause => 'Пауза';

  @override
  String get scanResume => 'Продолжить';

  @override
  String get scanPaused => 'Сканирование приостановлено';

  @override
  String get quizSuggestionTitle => 'Момент для обучения';

  @override
  String get quizSuggestionWeb =>
      'Вы столкнулись с фишинговым сайтом. Пройдите квиз, чтобы лучше распознавать такие угрозы!';

  @override
  String get quizSuggestionScan =>
      'При сканировании найдена угроза. Узнайте, как предотвращать заражение!';

  @override
  String get quizSuggestionDownload =>
      'Обнаружен опасный файл. Пройдите квиз о безопасной загрузке файлов!';

  @override
  String get quizSuggestionProtection =>
      'Вы отключили защиту. Узнайте, почему важно поддерживать систему в актуальном состоянии!';

  @override
  String get quizSuggestionAction => 'Пройти квиз';

  @override
  String get quizSuggestionDismiss => 'Позже';

  @override
  String get quizLastResult => 'Последний результат';

  @override
  String get quizBestResult => 'Лучший результат';

  @override
  String quizAttempts(int count) {
    return '$count попыток';
  }

  @override
  String get quizNeverTaken => 'Не пройден';

  @override
  String get hygieneBackupDescBeginner =>
      'Копируйте важные файлы (фото, документы) на флешку или в облако. Если компьютер сломается или вирус зашифрует файлы - у вас будет копия.';

  @override
  String get hygieneBackupDescAdvanced =>
      'Следуйте правилу 3-2-1: 3 копии, 2 разных носителя, 1 offsite. Автоматизируйте через планировщик задач. Проверяйте целостность бэкапов.';

  @override
  String get hygieneUsbDescBeginner =>
      'Никогда не подключайте найденные флешки. Через них вирусы попадают на компьютер автоматически, даже без вашего клика.';

  @override
  String get hygieneUsbDescAdvanced =>
      'USB-устройства могут эмулировать клавиатуру (Rubber Ducky) и выполнять команды. Используйте групповые политики для ограничения USB. Проверяйте устройства в изолированной среде.';

  @override
  String get hygienePrivacyDescBeginner =>
      'Не публикуйте в соцсетях адрес, номер телефона, место работы. Мошенники собирают такие данные для целевых атак.';

  @override
  String get hygienePrivacyDescAdvanced =>
      'Минимизируйте цифровой след: отключите геолокацию в фото, используйте разные email для разных сервисов, настройте DNS-over-HTTPS.';

  @override
  String get hygieneLockDescBeginner =>
      'Всегда блокируйте компьютер, когда отходите: Win+L. Без блокировки любой может просмотреть ваши файлы или установить вирус.';

  @override
  String get hygieneLockDescAdvanced =>
      'Используйте Windows Hello (биометрия) + Dynamic Lock (авто-блокировка при уходе телефона). Настройте тайм-аут экрана 1-2 минуты.';

  @override
  String get hygieneExtensionsDescBeginner =>
      'Устанавливайте расширения только из официального магазина Chrome/Firefox. Перед установкой проверяйте отзывы и количество пользователей.';

  @override
  String get hygieneExtensionsDescAdvanced =>
      'Аудируйте permissions расширений: если калькулятор просит доступ к «всем сайтам» - это red flag. Регулярно проверяйте список расширений.';

  @override
  String get hygieneEncryptionDescBeginner =>
      'Включите BitLocker на диске с Windows - если ноутбук украдут, данные будут защищены. Настройка: Параметры → Конфиденциальность → Шифрование.';

  @override
  String get hygieneEncryptionDescAdvanced =>
      'Используйте полнодисковое шифрование (BitLocker/VeraCrypt). Для особо важных файлов - контейнерное шифрование. Храните ключи восстановления в надёжном месте.';

  @override
  String get threatWhatItDoesTitle => 'Что делает угроза';

  @override
  String get threatDescriptionTitle => 'Подробное описание';

  @override
  String get threatEduLevelSignature =>
      'Данные из базы знаний (точное совпадение)';

  @override
  String get threatEduLevelFamily =>
      'Данные по семейству угроз (похожая угроза)';

  @override
  String get quizUpdateQ6 =>
      'Почему важно обновлять не только ОС, но и браузеры?';

  @override
  String get quizUpdateQ6A1 =>
      'Браузеры - главная цель атак, через них вы посещаете сайты и скачиваете файлы';

  @override
  String get quizUpdateQ6A2 => 'Обновления браузера только добавляют закладки';

  @override
  String get quizUpdateQ6A3 => 'Браузеры не нуждаются в обновлениях';

  @override
  String get quizUpdateQ6A4 => 'Обновление браузера меняет поисковую систему';

  @override
  String get quizUpdateQ6Explain =>
      'Браузер - самая атакуемая программа: он обрабатывает JavaScript, рендерит HTML/CSS, работает с сетью. Уязвимости в Chrome/Firefox обнаруживают еженедельно.';

  @override
  String get quizUpdateQ7 =>
      'Что произойдёт, если отложить обновление Windows на месяц?';

  @override
  String get quizUpdateQ7A1 =>
      'Система останется уязвимой к уже исправленным атакам, которые активно эксплуатируются';

  @override
  String get quizUpdateQ7A2 => 'Ничего страшного - месяц не критично';

  @override
  String get quizUpdateQ7A3 => 'Windows перестанет работать через месяц';

  @override
  String get quizUpdateQ7A4 => 'Microsoft заблокирует лицензию';

  @override
  String get quizUpdateQ7Explain =>
      'Злоумышленники изучают патчи и создают эксплойты за дни. Каждый день без обновления увеличивает риск. Атаки на известные CVE - самый массовый вектор заражения.';

  @override
  String get quizUpdateQ8 =>
      'Что такое атака через цепочку поставок (supply chain attack)?';

  @override
  String get quizUpdateQ8A1 =>
      'Злоумышленник внедряет вредоносный код в легитимное обновление от разработчика';

  @override
  String get quizUpdateQ8A2 => 'Задержка доставки обновления почтой';

  @override
  String get quizUpdateQ8A3 => 'Скачивание обновлений с медленного сервера';

  @override
  String get quizUpdateQ8A4 => 'Отказ разработчика выпускать обновления';

  @override
  String get quizUpdateQ8Explain =>
      'Атака SolarWinds (2020): хакеры внедрили бэкдор в обновление популярного ПО. 18 000 организаций установили заражённое обновление. Редкая, но разрушительная атака.';

  @override
  String get quizUpdateQ9 =>
      'Как проверить, что все программы на компьютере обновлены?';

  @override
  String get quizUpdateQ9A1 =>
      'Использовать утилиту аудита (Winget upgrade) или встроенную проверку обновлений каждой программы';

  @override
  String get quizUpdateQ9A2 => 'Посмотреть дату установки в панели управления';

  @override
  String get quizUpdateQ9A3 => 'Если программа открывается - значит обновлена';

  @override
  String get quizUpdateQ9A4 => 'Переустановить все программы раз в год';

  @override
  String get quizUpdateQ9Explain =>
      'Winget (встроен в Windows 11) может массово обновить все программы одной командой. Ручная проверка неэффективна - автоматизируйте процесс.';

  @override
  String get quizUpdateQ10 =>
      'Что такое обновления прошивки (firmware) и почему они важны?';

  @override
  String get quizUpdateQ10A1 =>
      'Обновления встроенного ПО устройств (BIOS, роутер) - закрывают уязвимости на уровне железа';

  @override
  String get quizUpdateQ10A2 => 'Обновления дизайна корпуса устройства';

  @override
  String get quizUpdateQ10A3 => 'Установка нового процессора';

  @override
  String get quizUpdateQ10A4 =>
      'Прошивка обновляется автоматически и не требует внимания';

  @override
  String get quizUpdateQ10Explain =>
      'Уязвимость в прошивке роутера может позволить перехватить весь домашний трафик. Прошивка BIOS/UEFI влияет на безопасность ещё до загрузки ОС.';

  @override
  String get quizPasswordQ6 => 'Что такое passkey и чем он лучше пароля?';

  @override
  String get quizPasswordQ6A1 =>
      'Криптографический ключ на устройстве - невозможно подобрать или украсть через фишинг';

  @override
  String get quizPasswordQ6A2 => 'Очень длинный пароль из 100 символов';

  @override
  String get quizPasswordQ6A3 => 'Пароль, записанный на физическом ключе';

  @override
  String get quizPasswordQ6A4 => 'Биометрический скан радужки глаза';

  @override
  String get quizPasswordQ6Explain =>
      'Passkey (FIDO2) - пара криптографических ключей. Приватный ключ не покидает устройство, сервер хранит только публичный. Фишинг невозможен: ключ привязан к домену.';

  @override
  String get quizPasswordQ7 => 'Почему секретные вопросы - слабая защита?';

  @override
  String get quizPasswordQ7A1 =>
      'Ответы часто можно найти в соцсетях или угадать';

  @override
  String get quizPasswordQ7A2 => 'Вопросов слишком мало для надёжности';

  @override
  String get quizPasswordQ7A3 => 'Они работают только на английском языке';

  @override
  String get quizPasswordQ7A4 => 'Серверы не шифруют ответы';

  @override
  String get quizPasswordQ7Explain =>
      'Девичья фамилия матери, кличка питомца - всё это есть в соцсетях. В 2008 году аккаунт Yahoo Сары Пейлин взломали через секретный вопрос. Используйте случайные ответы и храните в менеджере паролей.';

  @override
  String get quizPasswordQ8 => 'Что такое атака brute force (перебор)?';

  @override
  String get quizPasswordQ8A1 =>
      'Автоматический перебор всех комбинаций пароля до нахождения правильного';

  @override
  String get quizPasswordQ8A2 =>
      'Физическое разрушение компьютера для извлечения данных';

  @override
  String get quizPasswordQ8A3 =>
      'Использование силы для получения пароля от владельца';

  @override
  String get quizPasswordQ8A4 => 'Вирус, удаляющий все пароли из системы';

  @override
  String get quizPasswordQ8Explain =>
      'При brute force программа перебирает миллиарды комбинаций в секунду. Пароль из 6 символов - за секунды, из 12+ случайных - за тысячи лет. Длина - лучшая защита.';

  @override
  String get quizPasswordQ9 => 'Как проверить, не утёк ли ваш пароль?';

  @override
  String get quizPasswordQ9A1 =>
      'Использовать сервис Have I Been Pwned - он проверяет email по базам утечек';

  @override
  String get quizPasswordQ9A2 => 'Попробовать войти во все аккаунты';

  @override
  String get quizPasswordQ9A3 => 'Позвонить провайдеру почты';

  @override
  String get quizPasswordQ9A4 => 'Утечки паролей невозможно обнаружить';

  @override
  String get quizPasswordQ9Explain =>
      'Have I Been Pwned содержит миллиарды утёкших записей. Менеджеры паролей (Bitwarden, 1Password) также предупреждают об утечках автоматически.';

  @override
  String get quizPasswordQ10 =>
      'Почему опасно отправлять пароли через мессенджеры?';

  @override
  String get quizPasswordQ10A1 =>
      'Сообщения могут быть сохранены на сервере или прочитаны на скомпрометированном устройстве';

  @override
  String get quizPasswordQ10A2 =>
      'Мессенджеры сжимают текст и пароль может измениться';

  @override
  String get quizPasswordQ10A3 => 'Пароли нельзя копировать из мессенджеров';

  @override
  String get quizPasswordQ10A4 => 'Это безопасно в зашифрованном мессенджере';

  @override
  String get quizPasswordQ10Explain =>
      'Даже в зашифрованном мессенджере пароль виден на экране получателя. Если его устройство взломано - пароль скомпрометирован. Используйте менеджеры паролей с безопасным шарингом.';

  @override
  String get quizWifiQ6 =>
      'Можно ли безопасно делать онлайн-покупки в публичном Wi-Fi?';

  @override
  String get quizWifiQ6A1 =>
      'Лучше подождать - даже с HTTPS атака на DNS может подменить сайт';

  @override
  String get quizWifiQ6A2 => 'Да, HTTPS полностью защищает транзакции';

  @override
  String get quizWifiQ6A3 => 'Да, если сумма покупки небольшая';

  @override
  String get quizWifiQ6A4 => 'Только через Wi-Fi без пароля';

  @override
  String get quizWifiQ6Explain =>
      'HTTPS защищает данные, но не от DNS-спуфинга или скомпрометированных сертификатов. Для финансовых операций используйте мобильный интернет или VPN.';

  @override
  String get quizWifiQ7 => 'Как защитить домашний Wi-Fi роутер?';

  @override
  String get quizWifiQ7A1 =>
      'Сменить заводской пароль, использовать WPA3, обновить прошивку, отключить WPS';

  @override
  String get quizWifiQ7A2 => 'Достаточно сложного пароля Wi-Fi';

  @override
  String get quizWifiQ7A3 => 'Спрятать роутер - слабый сигнал = безопасность';

  @override
  String get quizWifiQ7A4 => 'Домашний Wi-Fi не нуждается в защите';

  @override
  String get quizWifiQ7Explain =>
      'Заводские пароли роутеров известны по базам. WPS имеет уязвимости. Комплекс мер: уникальный admin-пароль + WPA3 + свежая прошивка + выключенный WPS.';

  @override
  String get quizWifiQ8 => 'Что такое атака Evil Twin на Wi-Fi?';

  @override
  String get quizWifiQ8A1 =>
      'Поддельная точка доступа с таким же именем для перехвата трафика';

  @override
  String get quizWifiQ8A2 => 'Два роутера, конфликтующих друг с другом';

  @override
  String get quizWifiQ8A3 => 'Вирус, клонирующий ноутбук по Wi-Fi';

  @override
  String get quizWifiQ8A4 => 'Подключение двух устройств к одной сети';

  @override
  String get quizWifiQ8Explain =>
      'Злоумышленник создаёт точку доступа с именем настоящей сети. Ваше устройство подключается автоматически. Весь трафик проходит через атакующего.';

  @override
  String get quizWifiQ9 =>
      'Почему скрытие имени сети (SSID) не защищает Wi-Fi?';

  @override
  String get quizWifiQ9A1 =>
      'Скрытые сети легко обнаружить специальными инструментами - это иллюзия безопасности';

  @override
  String get quizWifiQ9A2 => 'Скрытие SSID - самый надёжный метод защиты';

  @override
  String get quizWifiQ9A3 => 'Скрытые сети работают медленнее';

  @override
  String get quizWifiQ9A4 => 'К скрытой сети нельзя подключиться';

  @override
  String get quizWifiQ9Explain =>
      'Airodump-ng обнаруживает скрытые сети за секунды - имя передаётся в probe-запросах. Вместо скрытия используйте WPA3 и актуальную прошивку.';

  @override
  String get quizWifiQ10 => 'Что такое MAC-фильтрация и почему она ненадёжна?';

  @override
  String get quizWifiQ10A1 =>
      'Ограничение доступа по MAC-адресу - легко обходится, так как MAC можно подделать';

  @override
  String get quizWifiQ10A2 => 'Фильтрация вредоносных сайтов';

  @override
  String get quizWifiQ10A3 => 'Блокировка устройств Apple от подключения';

  @override
  String get quizWifiQ10A4 => 'Антивирусная функция роутера';

  @override
  String get quizWifiQ10Explain =>
      'MAC-адрес передаётся открытым текстом. Атакующий перехватывает разрешённый MAC и клонирует его за секунды. Это security through obscurity, а не реальная защита.';

  @override
  String get quizPhishingQ6 => 'Что такое вишинг (vishing)?';

  @override
  String get quizPhishingQ6A1 =>
      'Фишинг по телефону - звонок от «банка» с целью выманить данные';

  @override
  String get quizPhishingQ6A2 => 'Визуальный фишинг через картинки';

  @override
  String get quizPhishingQ6A3 => 'Фишинг через видеозвонки';

  @override
  String get quizPhishingQ6A4 => 'Рассылка вирусов через голосовые сообщения';

  @override
  String get quizPhishingQ6Explain =>
      'Вишинг использует звонки с подменой номера. Мошенник создаёт срочность: «Ваш счёт заблокирован, назовите код из SMS». Банки никогда не просят коды по телефону.';

  @override
  String get quizPhishingQ7 => 'Что такое смишинг (smishing)?';

  @override
  String get quizPhishingQ7A1 =>
      'Фишинг через СМС - ссылка на фальшивый сайт в текстовом сообщении';

  @override
  String get quizPhishingQ7A2 => 'Фишинг через умные часы';

  @override
  String get quizPhishingQ7A3 => 'Отправка вирусов через Bluetooth';

  @override
  String get quizPhishingQ7A4 => 'Шифрование СМС-сообщений';

  @override
  String get quizPhishingQ7Explain =>
      'Типичный смишинг: «Ваша посылка задержана, перейдите по ссылке». Ссылка ведёт на фальшивый сайт. Не переходите по ссылкам из SMS.';

  @override
  String get quizPhishingQ8 =>
      'Как распознать фишинговое письмо кроме проверки домена?';

  @override
  String get quizPhishingQ8A1 =>
      'Срочность, угрозы, ошибки, обезличенное обращение, подозрительные вложения';

  @override
  String get quizPhishingQ8A2 => 'Фишинговые письма всегда содержат ошибки';

  @override
  String get quizPhishingQ8A3 => 'Фишинг возможен только через email';

  @override
  String get quizPhishingQ8A4 => 'Письма от знакомых всегда безопасны';

  @override
  String get quizPhishingQ8Explain =>
      'Признаки: «Срочно!», «Аккаунт заблокирован», обезличенное обращение. AI генерирует убедительные тексты. Проверяйте отправителя, ссылки и логику запроса.';

  @override
  String get quizPhishingQ9 =>
      'Что такое BEC-атака (Business Email Compromise)?';

  @override
  String get quizPhishingQ9A1 =>
      'Поддельное письмо от руководителя с просьбой перевести деньги';

  @override
  String get quizPhishingQ9A2 => 'Взлом почты для рассылки спама';

  @override
  String get quizPhishingQ9A3 => 'Шифрование корпоративной переписки';

  @override
  String get quizPhishingQ9A4 => 'Сортировка бизнес-писем';

  @override
  String get quizPhishingQ9Explain =>
      'BEC - одна из самых дорогих атак (средний ущерб \$120 000). Злоумышленник ждёт момент оплаты и отправляет письмо с изменёнными реквизитами. Подтверждайте переводы звонком.';

  @override
  String get quizPhishingQ10 =>
      'Что делать, если случайно перешли по фишинговой ссылке?';

  @override
  String get quizPhishingQ10A1 =>
      'Не вводить данные, закрыть страницу, сменить пароли, проверить антивирусом';

  @override
  String get quizPhishingQ10A2 => 'Ничего - вирус уже установился';

  @override
  String get quizPhishingQ10A3 => 'Перезагрузить компьютер';

  @override
  String get quizPhishingQ10A4 => 'Написать мошенникам ответное письмо';

  @override
  String get quizPhishingQ10Explain =>
      'Сам переход обычно не опасен - опасен ввод данных. Если ничего не вводили - закройте страницу. Если ввели пароль - смените его и включите 2FA.';

  @override
  String get quizBackupQ6 =>
      'В чём разница между полным и инкрементальным бэкапом?';

  @override
  String get quizBackupQ6A1 =>
      'Полный копирует всё, инкрементальный - только изменения с прошлого бэкапа';

  @override
  String get quizBackupQ6A2 =>
      'Полный бэкап больше, но инкрементальный ненадёжен';

  @override
  String get quizBackupQ6A3 => 'Инкрементальный - то же самое, только быстрее';

  @override
  String get quizBackupQ6A4 => 'Полный бэкап работает только на внешних дисках';

  @override
  String get quizBackupQ6Explain =>
      'Инкрементальный бэкап экономит время и место. Оптимальная стратегия: полный бэкап раз в неделю + ежедневные инкременты.';

  @override
  String get quizBackupQ7 => 'Почему важно шифровать резервные копии?';

  @override
  String get quizBackupQ7A1 =>
      'Незашифрованный бэкап на украденном диске даёт доступ ко всем данным';

  @override
  String get quizBackupQ7A2 => 'Шифрование ускоряет восстановление';

  @override
  String get quizBackupQ7A3 => 'Шифрование обязательно по закону';

  @override
  String get quizBackupQ7A4 => 'Без шифрования бэкап повреждается быстрее';

  @override
  String get quizBackupQ7Explain =>
      'Если внешний диск украден или облачный аккаунт взломан - незашифрованный бэкап это полный доступ к данным. BitLocker или шифрование облака решают проблему.';

  @override
  String get quizBackupQ8 => 'Что такое air-gapped (изолированный) бэкап?';

  @override
  String get quizBackupQ8A1 =>
      'Бэкап на носителе, физически отключённом от сети и компьютера';

  @override
  String get quizBackupQ8A2 => 'Бэкап в самолёте';

  @override
  String get quizBackupQ8A3 => 'Беспроводной бэкап через Wi-Fi';

  @override
  String get quizBackupQ8A4 => 'Облачный бэкап с VPN';

  @override
  String get quizBackupQ8Explain =>
      'Air-gapped бэкап - диск, подключаемый только на время копирования. Шифровальщик не может зашифровать отключённый диск. Самая надёжная защита от ransomware.';

  @override
  String get quizBackupQ9 => 'Как часто нужно делать бэкапы?';

  @override
  String get quizBackupQ9A1 =>
      'Зависит от ценности данных: ежедневно для важных, еженедельно для остального';

  @override
  String get quizBackupQ9A2 => 'Раз в год достаточно';

  @override
  String get quizBackupQ9A3 => 'Только перед переустановкой системы';

  @override
  String get quizBackupQ9A4 => 'Один раз при покупке компьютера';

  @override
  String get quizBackupQ9Explain =>
      'Подумайте: сколько работы вы готовы потерять? Если потеря дня критична - бэкап ежедневный. Автоматизируйте: ручные бэкапы забываются.';

  @override
  String get quizBackupQ10 => 'Что делать, если бэкап не удаётся восстановить?';

  @override
  String get quizBackupQ10A1 =>
      'Бэкап повреждён - нужно было тестировать восстановление заранее';

  @override
  String get quizBackupQ10A2 => 'Попробовать через неделю';

  @override
  String get quizBackupQ10A3 => 'Бэкапы всегда восстанавливаются';

  @override
  String get quizBackupQ10A4 => 'Написать в техподдержку производителя диска';

  @override
  String get quizBackupQ10Explain =>
      'Непроверенный бэкап - не бэкап. Раз в месяц проверяйте восстановление. Повреждённые секторы, устаревший формат, забытый пароль - всё обнаруживается только при тесте.';

  @override
  String get quizDownloadQ6 => 'Что такое песочница (sandbox)?';

  @override
  String get quizDownloadQ6A1 =>
      'Изолированная среда, где программа не может навредить основной системе';

  @override
  String get quizDownloadQ6A2 => 'Антивирусная программа';

  @override
  String get quizDownloadQ6A3 => 'Специальная папка на рабочем столе';

  @override
  String get quizDownloadQ6A4 => 'Программа для упаковки файлов';

  @override
  String get quizDownloadQ6Explain =>
      'Windows Sandbox создаёт одноразовую виртуальную копию Windows. Запустите подозрительный файл - после закрытия все изменения исчезнут.';

  @override
  String get quizDownloadQ7 => 'Как проверить файл по хеш-сумме?';

  @override
  String get quizDownloadQ7A1 =>
      'Сравнить SHA-256 хеш файла с указанным на сайте разработчика';

  @override
  String get quizDownloadQ7A2 => 'Открыть файл и проверить содержимое';

  @override
  String get quizDownloadQ7A3 => 'Переименовать файл и проверить размер';

  @override
  String get quizDownloadQ7A4 => 'Хеш проверяется автоматически браузером';

  @override
  String get quizDownloadQ7Explain =>
      'SHA-256 - цифровой отпечаток файла. Изменение одного байта полностью меняет хеш. В Windows: certutil -hashfile file.exe SHA256.';

  @override
  String get quizDownloadQ8 => 'Что делает Windows SmartScreen?';

  @override
  String get quizDownloadQ8A1 =>
      'Предупреждает при запуске неизвестных или неподписанных программ из интернета';

  @override
  String get quizDownloadQ8A2 => 'Блокирует все скачивания';

  @override
  String get quizDownloadQ8A3 => 'Проверяет оперативную память';

  @override
  String get quizDownloadQ8A4 => 'Фильтрует рекламу в браузере';

  @override
  String get quizDownloadQ8Explain =>
      'SmartScreen проверяет репутацию файла. Предупреждение не означает вирус, но файл неизвестен системе. Относитесь с осторожностью.';

  @override
  String get quizDownloadQ9 => 'Почему кряки и кейгены особенно опасны?';

  @override
  String get quizDownloadQ9A1 =>
      'В 90%+ случаев содержат вредоносное ПО: трояны, майнеры, шпионское ПО';

  @override
  String get quizDownloadQ9A2 => 'Они тормозят компьютер';

  @override
  String get quizDownloadQ9A3 => 'Они незаконны, но безопасны технически';

  @override
  String get quizDownloadQ9A4 => 'Антивирусы давно решили эту проблему';

  @override
  String get quizDownloadQ9Explain =>
      'Жертва сама отключает антивирус и запускает вредонос с правами администратора. В кряках: трояны-стилеры, криптомайнеры и RAT (удалённый доступ).';

  @override
  String get quizDownloadQ10 =>
      'Что делать, если браузер заблокировал скачивание?';

  @override
  String get quizDownloadQ10A1 =>
      'Не игнорировать - проверить источник и необходимость файла';

  @override
  String get quizDownloadQ10A2 => 'Сменить браузер на незащищённый';

  @override
  String get quizDownloadQ10A3 =>
      'Браузеры слишком осторожны - всегда игнорировать';

  @override
  String get quizDownloadQ10A4 => 'Отключить защиту навсегда';

  @override
  String get quizDownloadQ10Explain =>
      'Браузеры блокируют на основе репутации и сигнатур. Если файл заблокирован - серьёзный сигнал. Проверьте источник перед продолжением.';

  @override
  String get quiz2faQ6 => 'Можно ли обойти двухфакторную аутентификацию?';

  @override
  String get quiz2faQ6A1 =>
      'Да - через фишинг в реальном времени или SIM-swap, поэтому важен метод 2FA';

  @override
  String get quiz2faQ6A2 => 'Нет, 2FA абсолютно непробиваема';

  @override
  String get quiz2faQ6A3 => 'Только спецслужбы могут обойти 2FA';

  @override
  String get quiz2faQ6A4 => '2FA защищает от всех атак';

  @override
  String get quiz2faQ6Explain =>
      'Фишинг-прокси перехватывает код 2FA в реальном времени. SIM-swap перенаправляет SMS. Аппаратные ключи FIDO2 устойчивы к этим атакам.';

  @override
  String get quiz2faQ7 => 'Что такое аппаратный ключ безопасности (YubiKey)?';

  @override
  String get quiz2faQ7A1 =>
      'Физическое устройство для аутентификации, устойчивое к фишингу';

  @override
  String get quiz2faQ7A2 => 'USB-флешка с паролями';

  @override
  String get quiz2faQ7A3 => 'Ключ шифрования жёсткого диска';

  @override
  String get quiz2faQ7A4 => 'Брелок для разблокировки автомобиля';

  @override
  String get quiz2faQ7Explain =>
      'FIDO2 ключ криптографически привязан к домену. Даже на идеальном фишинговом сайте ключ откажется аутентифицироваться. Фишинг невозможен физически.';

  @override
  String get quiz2faQ8 =>
      'Почему важно включить 2FA на email в первую очередь?';

  @override
  String get quiz2faQ8A1 =>
      'Email - ключ ко всем аккаунтам: через него сбрасываются пароли';

  @override
  String get quiz2faQ8A2 => 'Email - самый популярный сервис';

  @override
  String get quiz2faQ8A3 => 'Без 2FA нельзя отправлять email';

  @override
  String get quiz2faQ8A4 => '2FA на email менее важна, чем на соцсетях';

  @override
  String get quiz2faQ8Explain =>
      'Если злоумышленник получит доступ к почте, он сбросит пароли всех привязанных аккаунтов. Email - мастер-ключ цифровой жизни. 2FA на почте - приоритет №1.';

  @override
  String get quiz2faQ9 => 'Что такое резервные коды и где их хранить?';

  @override
  String get quiz2faQ9A1 =>
      'Одноразовые коды для входа при потере 2FA-устройства - в менеджере паролей или сейфе';

  @override
  String get quiz2faQ9A2 => 'Коды для восстановления файлов';

  @override
  String get quiz2faQ9A3 => 'Достаточно запомнить один код';

  @override
  String get quiz2faQ9A4 => 'Резервные коды действуют бесконечно';

  @override
  String get quiz2faQ9Explain =>
      'Сервис выдаёт 8-10 одноразовых кодов. Храните в менеджере паролей или распечатайте. Без них потеря телефона = потеря доступа.';

  @override
  String get quiz2faQ10 => 'Стоит ли включать 2FA на всех аккаунтах?';

  @override
  String get quiz2faQ10A1 => 'Да - особенно на email, банке, облаке и соцсетях';

  @override
  String get quiz2faQ10A2 => 'Только на банковских аккаунтах';

  @override
  String get quiz2faQ10A3 => '2FA слишком неудобна';

  @override
  String get quiz2faQ10A4 => 'Достаточно одного главного аккаунта';

  @override
  String get quiz2faQ10Explain =>
      'Взлом «неважного» аккаунта опасен при повторном пароле. 2FA делает взлом экспоненциально сложнее. Минимум: email + банк + облако + соцсети.';

  @override
  String get quizUsbQ6 => 'Что такое USB Killer?';

  @override
  String get quizUsbQ6A1 =>
      'Устройство, посылающее электрический разряд через USB-порт, уничтожая оборудование';

  @override
  String get quizUsbQ6A2 => 'Антивирус для USB-накопителей';

  @override
  String get quizUsbQ6A3 => 'Программа безопасного извлечения';

  @override
  String get quizUsbQ6A4 => 'Вирус, стирающий данные с флешки';

  @override
  String get quizUsbQ6Explain =>
      'USB Killer заряжает конденсаторы и разряжает 200+ вольт обратно в порт. Результат: сгоревшая материнская плата. Не вставляйте неизвестные USB-устройства.';

  @override
  String get quizUsbQ7 =>
      'Как защититься от автозапуска вредоносных программ с USB?';

  @override
  String get quizUsbQ7A1 =>
      'Отключить автозапуск в Windows и проверять содержимое флешки вручную';

  @override
  String get quizUsbQ7A2 => 'Автозапуск безопасен в современных Windows';

  @override
  String get quizUsbQ7A3 => 'Достаточно использовать USB 3.0';

  @override
  String get quizUsbQ7A4 => 'Форматировать каждую флешку перед использованием';

  @override
  String get quizUsbQ7Explain =>
      'AutoRun для USB отключён по умолчанию, но AutoPlay может предложить действия. Параметры → Устройства → Автозапуск → Выкл. Сканируйте новые USB антивирусом.';

  @override
  String get quizUsbQ8 => 'Что такое juice jacking (атака через USB-зарядку)?';

  @override
  String get quizUsbQ8A1 =>
      'Кража данных через публичную USB-зарядную станцию, замаскированную под обычную';

  @override
  String get quizUsbQ8A2 => 'Кража электроэнергии через USB';

  @override
  String get quizUsbQ8A3 => 'Перегрев телефона от зарядки';

  @override
  String get quizUsbQ8A4 => 'Использование чужого зарядного устройства';

  @override
  String get quizUsbQ8Explain =>
      'USB передаёт и питание, и данные. Модифицированная станция может читать данные или устанавливать вредонос. Используйте свой блок питания или data blocker.';

  @override
  String get quizUsbQ9 => 'Какой безопасный способ передачи файлов вместо USB?';

  @override
  String get quizUsbQ9A1 =>
      'Облачное хранилище или передача по зашифрованному каналу (Wi-Fi Direct, AirDrop)';

  @override
  String get quizUsbQ9A2 => 'Bluetooth - он всегда безопасен';

  @override
  String get quizUsbQ9A3 => 'Email без ограничений';

  @override
  String get quizUsbQ9A4 => 'Безопасных альтернатив нет';

  @override
  String get quizUsbQ9Explain =>
      'Облачные сервисы проверяют файлы антивирусом. Wi-Fi Direct, AirDrop, Nearby Share зашифрованы и не требуют физического носителя.';

  @override
  String get quizUsbQ10 => 'Почему важна физическая безопасность USB-портов?';

  @override
  String get quizUsbQ10A1 =>
      'Злоумышленник может быстро вставить вредоносное устройство, пока вас нет';

  @override
  String get quizUsbQ10A2 => 'USB-порты изнашиваются';

  @override
  String get quizUsbQ10A3 => 'Антивирус всё остановит';

  @override
  String get quizUsbQ10A4 => 'Порты нужно закрывать от пыли';

  @override
  String get quizUsbQ10Explain =>
      'Вставить BadUSB - секунда. На критичных компьютерах используйте USB-блокираторы или GPO-политики, ограничивающие подключение новых устройств.';

  @override
  String get quizPrivacyQ6 => 'Что такое цифровой след?';

  @override
  String get quizPrivacyQ6A1 =>
      'Совокупность всей вашей активности в интернете - полностью удалить практически невозможно';

  @override
  String get quizPrivacyQ6A2 => 'Следы от скачивания файлов';

  @override
  String get quizPrivacyQ6A3 => 'Отпечаток пальца на экране';

  @override
  String get quizPrivacyQ6A4 =>
      'Очистка истории браузера удаляет цифровой след';

  @override
  String get quizPrivacyQ6Explain =>
      'Каждый пост, лайк, покупка формируют цифровой след. Даже удалённые посты сохраняются в кешах и веб-архивах. Не публикуйте то, что не хотите видеть публичным через 10 лет.';

  @override
  String get quizPrivacyQ7 =>
      'Зачем использовать разные email для разных целей?';

  @override
  String get quizPrivacyQ7A1 =>
      'Компрометация одного адреса не затронет остальные - изоляция аккаунтов';

  @override
  String get quizPrivacyQ7A2 =>
      'Почтовые сервисы дают скидку за несколько аккаунтов';

  @override
  String get quizPrivacyQ7A3 => 'Один адрес не может получать много писем';

  @override
  String get quizPrivacyQ7A4 => 'Это нужно только для работы';

  @override
  String get quizPrivacyQ7Explain =>
      'Отдельный email для банка, другой для форумов. Утечка базы форума не раскроет банковский email. Алиасы (SimpleLogin) позволяют удалить утёкший адрес.';

  @override
  String get quizPrivacyQ8 => 'Что такое доксинг (doxxing)?';

  @override
  String get quizPrivacyQ8A1 =>
      'Сбор и публикация личной информации без согласия с целью запугивания';

  @override
  String get quizPrivacyQ8A2 => 'Защита документов паролем';

  @override
  String get quizPrivacyQ8A3 => 'Архивирование файлов';

  @override
  String get quizPrivacyQ8A4 => 'Процедура проверки личности';

  @override
  String get quizPrivacyQ8Explain =>
      'Доксеры собирают адрес, телефон, фото из открытых источников. Защита: минимизируйте данные в соцсетях, используйте псевдонимы на форумах.';

  @override
  String get quizPrivacyQ9 => 'Как уменьшить отслеживание в браузере?';

  @override
  String get quizPrivacyQ9A1 =>
      'Использовать блокировщик трекеров (uBlock Origin), очищать cookies, включить DNS over HTTPS';

  @override
  String get quizPrivacyQ9A2 => 'Достаточно режима инкогнито';

  @override
  String get quizPrivacyQ9A3 => 'Установить больше расширений приватности';

  @override
  String get quizPrivacyQ9A4 => 'Отслеживание невозможно предотвратить';

  @override
  String get quizPrivacyQ9Explain =>
      'Инкогнито НЕ защищает от трекеров. Комплекс мер: uBlock Origin, Firefox с Enhanced Tracking Protection, очистка cookies, DNS over HTTPS.';

  @override
  String get quizPrivacyQ10 => 'Что такое право на забвение?';

  @override
  String get quizPrivacyQ10A1 =>
      'Законное право потребовать от компаний удалить ваши персональные данные';

  @override
  String get quizPrivacyQ10A2 => 'Автоматическое удаление данных через год';

  @override
  String get quizPrivacyQ10A3 => 'Запрет на сохранение cookies';

  @override
  String get quizPrivacyQ10A4 => 'Право забыть свой пароль';

  @override
  String get quizPrivacyQ10Explain =>
      'GDPR даёт право запросить удаление данных. Google позволяет удалить ссылки, соцсети - удалить аккаунт. Воспользуйтесь для неиспользуемых аккаунтов.';

  @override
  String get quizLockQ6 => 'Почему стоит установить пароль на BIOS/UEFI?';

  @override
  String get quizLockQ6A1 =>
      'Предотвращает загрузку с внешнего носителя, обходящую защиту ОС';

  @override
  String get quizLockQ6A2 => 'BIOS-пароль ускоряет загрузку';

  @override
  String get quizLockQ6A3 => 'Без него компьютер не включится';

  @override
  String get quizLockQ6A4 => 'BIOS-пароль заменяет пароль Windows';

  @override
  String get quizLockQ6Explain =>
      'Без BIOS-пароля можно загрузиться с USB и обойти пароль Windows. BIOS-пароль + BitLocker = надёжная защита от физического доступа.';

  @override
  String get quizLockQ7 =>
      'Как защититься от подглядывания пароля (shoulder surfing)?';

  @override
  String get quizLockQ7A1 =>
      'Использовать биометрию, экран приватности и убедиться, что никто не смотрит';

  @override
  String get quizLockQ7A2 => 'Вводить пароль быстро';

  @override
  String get quizLockQ7A3 => 'В современных офисах это невозможно';

  @override
  String get quizLockQ7A4 => 'Использовать длинный пароль';

  @override
  String get quizLockQ7Explain =>
      'Экран приватности (3M Privacy Filter) делает изображение видимым только под прямым углом. Биометрия исключает подглядывание полностью.';

  @override
  String get quizLockQ8 => 'Какое время автоблокировки экрана рекомендуется?';

  @override
  String get quizLockQ8A1 =>
      '2-5 минут - достаточно, чтобы не раздражать, но защитить от доступа';

  @override
  String get quizLockQ8A2 => '30 минут - стандартное значение';

  @override
  String get quizLockQ8A3 => 'Автоблокировка не связана с безопасностью';

  @override
  String get quizLockQ8A4 => '1 час для комфортной работы';

  @override
  String get quizLockQ8Explain =>
      'За 30 минут можно скопировать файлы, установить кейлоггер или прочитать почту. 5 минут - баланс между удобством и защитой.';

  @override
  String get quizLockQ9 =>
      'В чём опасность отключения пароля при входе в Windows?';

  @override
  String get quizLockQ9A1 =>
      'Любой, включивший компьютер, получит полный доступ к файлам и аккаунтам';

  @override
  String get quizLockQ9A2 => 'Windows будет работать медленнее';

  @override
  String get quizLockQ9A3 => 'Никакой опасности';

  @override
  String get quizLockQ9A4 => 'Уязвимость только для сетевых атак';

  @override
  String get quizLockQ9Explain =>
      'Без пароля компьютер - открытая книга: документы, пароли браузера, почта. При краже ноутбука вор получит доступ мгновенно.';

  @override
  String get quizLockQ10 => 'Зачем блокировать компьютер дома?';

  @override
  String get quizLockQ10A1 =>
      'Привычка защищает в других местах, а дома - от гостей и воров';

  @override
  String get quizLockQ10A2 => 'Дома блокировка не нужна';

  @override
  String get quizLockQ10A3 => 'Только на работе';

  @override
  String get quizLockQ10A4 => 'Вирусы могут разблокировать компьютер';

  @override
  String get quizLockQ10Explain =>
      'Win+L должен быть рефлексом. К вам приходят гости, курьеры, техники. Привычка, выработанная дома, спасёт в кафе и офисе.';

  @override
  String get quizExtQ6 => 'Что такое атака на цепочку поставок расширений?';

  @override
  String get quizExtQ6A1 =>
      'Разработчик продаёт расширение злоумышленнику, который выпускает вредоносное обновление';

  @override
  String get quizExtQ6A2 => 'Расширение доставляется по почте';

  @override
  String get quizExtQ6A3 => 'Конфликт между расширениями';

  @override
  String get quizExtQ6A4 => 'Установка из файла';

  @override
  String get quizExtQ6Explain =>
      'В 2020-2023 десятки популярных расширений были проданы и обновлены с вредоносным кодом. Минимизируйте количество расширений.';

  @override
  String get quizExtQ7 => 'Как проверить разрешения установленных расширений?';

  @override
  String get quizExtQ7A1 =>
      'chrome://extensions → Подробности → посмотреть доступ к сайтам и разрешения';

  @override
  String get quizExtQ7A2 => 'Разрешения нельзя посмотреть после установки';

  @override
  String get quizExtQ7A3 => 'Только через переустановку';

  @override
  String get quizExtQ7A4 => 'Разрешения у всех одинаковые';

  @override
  String get quizExtQ7Explain =>
      'В Chrome: Расширения → Управление → клик → Подробности. Если калькулятору нужен доступ ко всем сайтам - удаляйте.';

  @override
  String get quizExtQ8 => 'Работают ли расширения в режиме инкогнито?';

  @override
  String get quizExtQ8A1 =>
      'По умолчанию нет - но можно разрешить, что создаёт риск отслеживания';

  @override
  String get quizExtQ8A2 => 'Все расширения работают в инкогнито';

  @override
  String get quizExtQ8A3 => 'В инкогнито расширения безопасны';

  @override
  String get quizExtQ8A4 => 'Инкогнито отключает расширения навсегда';

  @override
  String get quizExtQ8Explain =>
      'Включённое в инкогнито расширение видит все сайты, которые вы хотели скрыть. Включайте только доверенные (uBlock Origin).';

  @override
  String get quizExtQ9 =>
      'Почему стоит ограничить расширение конкретными сайтами?';

  @override
  String get quizExtQ9A1 =>
      'Вместо доступа ко всем сайтам дать только к нужным - принцип минимальных привилегий';

  @override
  String get quizExtQ9A2 => 'Это ускоряет расширение';

  @override
  String get quizExtQ9A3 => 'Ограничение невозможно в Chrome';

  @override
  String get quizExtQ9A4 => 'Только для платных расширений';

  @override
  String get quizExtQ9Explain =>
      'Правый клик на иконку → «На определённых сайтах». Переводчику не нужен доступ к вашей переписке в Gmail.';

  @override
  String get quizExtQ10 =>
      'Как расширения влияют на цифровой отпечаток браузера?';

  @override
  String get quizExtQ10A1 =>
      'Набор расширений делает браузер более уникальным и узнаваемым';

  @override
  String get quizExtQ10A2 => 'Расширения скрывают отпечаток';

  @override
  String get quizExtQ10A3 => 'Расширения не влияют на приватность';

  @override
  String get quizExtQ10A4 => 'Только блокировщики рекламы создают отпечаток';

  @override
  String get quizExtQ10Explain =>
      'Сайты определяют расширения по побочным эффектам. Парадокс: расширения приватности могут делать вас более узнаваемым.';

  @override
  String get quizEncryptQ6 => 'Что такое AES-256?';

  @override
  String get quizEncryptQ6A1 =>
      'Алгоритм шифрования с ключом 256 бит - перебор всех комбинаций займёт больше, чем возраст Вселенной';

  @override
  String get quizEncryptQ6A2 => 'Протокол сжатия данных';

  @override
  String get quizEncryptQ6A3 => 'Антивирусный алгоритм';

  @override
  String get quizEncryptQ6A4 => 'Метод аутентификации';

  @override
  String get quizEncryptQ6Explain =>
      'AES-256 одобрен NSA для секретных документов. 2^256 возможных ключей больше количества атомов во Вселенной.';

  @override
  String get quizEncryptQ7 =>
      'В чём разница между симметричным и асимметричным шифрованием?';

  @override
  String get quizEncryptQ7A1 =>
      'Симметричное - один ключ, асимметричное - пара ключей (публичный + приватный)';

  @override
  String get quizEncryptQ7A2 => 'Симметричное быстрее, значит лучше';

  @override
  String get quizEncryptQ7A3 => 'Асимметричное - устаревший метод';

  @override
  String get quizEncryptQ7A4 => 'Разницы нет';

  @override
  String get quizEncryptQ7Explain =>
      'HTTPS использует оба: асимметричное для обмена ключами, затем симметричное для данных. Асимметричное решает проблему безопасного обмена ключами.';

  @override
  String get quizEncryptQ8 => 'Почему важно шифровать данные в облаке?';

  @override
  String get quizEncryptQ8A1 =>
      'Провайдер может технически получить доступ к незашифрованным файлам';

  @override
  String get quizEncryptQ8A2 => 'Облако автоматически шифрует всё';

  @override
  String get quizEncryptQ8A3 => 'Облако безопасно без шифрования';

  @override
  String get quizEncryptQ8A4 => 'Шифрование замедляет синхронизацию в 10 раз';

  @override
  String get quizEncryptQ8Explain =>
      'Google Drive, Dropbox шифруют данные, но имеют к ним доступ. Клиентское шифрование (Cryptomator) гарантирует: только вы можете прочитать файлы.';

  @override
  String get quizEncryptQ9 => 'Что делать с ключом восстановления BitLocker?';

  @override
  String get quizEncryptQ9A1 =>
      'Сохранить в нескольких местах: Microsoft-аккаунт, распечатка, менеджер паролей';

  @override
  String get quizEncryptQ9A2 => 'Запомнить наизусть';

  @override
  String get quizEncryptQ9A3 => 'Ключ не нужен';

  @override
  String get quizEncryptQ9A4 => 'Отправить себе по email';

  @override
  String get quizEncryptQ9Explain =>
      'Ключ BitLocker - 48 цифр. Без него при сбое TPM данные утеряны навсегда. Минимум 2 копии в разных местах.';

  @override
  String get quizEncryptQ10 => 'Можно ли доверять бесплатным VPN?';

  @override
  String get quizEncryptQ10A1 =>
      'Осторожно - многие продают данные пользователей или содержат рекламное ПО';

  @override
  String get quizEncryptQ10A2 => 'Бесплатные VPN так же безопасны, как платные';

  @override
  String get quizEncryptQ10A3 => 'VPN не связан с шифрованием';

  @override
  String get quizEncryptQ10A4 => 'Бесплатные VPN быстрее платных';

  @override
  String get quizEncryptQ10Explain =>
      '38% бесплатных Android VPN содержат вредоносное ПО, 75% используют трекеры. Надежные бесплатные варианты встречаются редко - проведите исследование, прежде чем доверять им.';

  @override
  String get onbExtTitle => 'Расширение браузера';

  @override
  String get onbExtSubtitle =>
      'Подключите MentoringProtector к Chrome для веб-защиты в реальном времени';

  @override
  String get onbExtStep1 => 'Откройте chrome://extensions в адресной строке';

  @override
  String get onbExtStep2 =>
      'Включите Режим разработчика (переключатель в правом верхнем углу)';

  @override
  String get onbExtStep3 =>
      'Нажмите «Загрузить распакованное» и выберите папку ниже';

  @override
  String get onbExtOpenFolder => 'Открыть папку расширения';

  @override
  String get onbExtSkip => 'Пропустить';

  @override
  String onbExtChecking(int attempt) {
    return 'Проверяем... $attempt/3';
  }

  @override
  String get onbExtCheckConnection => 'Проверить подключение';

  @override
  String get onbExtConnected => 'Расширение подключено';

  @override
  String get onbExtNotConnected => 'Расширение не подключено';

  @override
  String get onbAdminTitle => 'Безопасный режим работы';

  @override
  String get onbAdminNoAdmin =>
      'MentoringProtector работает без прав администратора';

  @override
  String get onbAdminBody =>
      'Сканирование файлов, веб-защита и мониторинг процессов - всё работает в обычном пользовательском режиме. Права администратора не нужны для повседневной работы.';

  @override
  String get onbAdminWhenUac => 'Когда появится окно UAC?';

  @override
  String get onbAdminWhenUacBody =>
      'Окно подтверждения Windows появится только когда вы нажмёте «Исправить автоматически» в Сканере уязвимостей - например, чтобы включить SmartScreen или Firewall. Это требование Windows для записи в системный реестр.';

  @override
  String get onbAdminWhyLeastPrivilege =>
      'Почему не требуем права администратора постоянно?';

  @override
  String get onbAdminWhyBody =>
      'Меньше прав → меньше поверхность атаки. Касперский и Defender используют ту же модель (служба + UI-клиент). Сейчас у нас helper.exe, в Phase 5 будет полноценная Windows-служба.';

  @override
  String get threatLibraryTitle => 'Библиотека угроз';

  @override
  String get threatLibraryDesc =>
      'Каталог известных вирусов и атак с описаниями';

  @override
  String get threatLibrarySection => 'Образование';

  @override
  String get threatLibrarySearchHint => 'Поиск по имени или описанию';

  @override
  String threatLibraryCount(int found, int total) {
    return 'Найдено: $found из $total';
  }

  @override
  String get threatLibraryHomeTitle => 'Библиотека угроз';

  @override
  String get threatLibraryHomeSubtitle =>
      'Изучите известные вирусы и атаки до того, как они вас коснутся';

  @override
  String get threatLibraryFilterAll => 'Все';

  @override
  String get threatLibraryEmpty =>
      'Ничего не найдено. Попробуйте изменить поиск или фильтры.';

  @override
  String get threatLibraryFilterType => 'Тип';

  @override
  String get threatLibraryFilterCategory => 'Категория';

  @override
  String get threatTypeTrojan => 'Троян';

  @override
  String get threatTypeSpyware => 'Шпионское ПО';

  @override
  String get threatTypePhishing => 'Фишинг';

  @override
  String get threatTypeRansomware => 'Шифровальщик';

  @override
  String get threatTypeWorm => 'Червь';

  @override
  String get threatTypeAdware => 'Рекламное ПО';

  @override
  String get threatTypeExploit => 'Эксплойт';

  @override
  String get threatTypePup => 'PUP';

  @override
  String get threatTypeBackdoor => 'Бэкдор';

  @override
  String get threatTypeRootkit => 'Руткит';

  @override
  String get threatTypeTest => 'Тест';

  @override
  String get hygieneCategorySafeDownloads => 'Безопасные загрузки';

  @override
  String get hygieneCategoryGeneral => 'Общие';

  @override
  String get hygieneCategoryPhishing => 'Фишинг';

  @override
  String get hygieneCategoryBackups => 'Резервные копии';

  @override
  String get hygieneCategoryNetworkSecurity => 'Сетевая безопасность';

  @override
  String get hygieneCategorySystemMonitoring => 'Мониторинг системы';

  @override
  String get hygieneCategoryPasswords => 'Пароли';

  @override
  String get hygieneCategoryRemovableMedia => 'Съёмные носители';

  @override
  String get cacheStatsHits => 'Совпадений';

  @override
  String get cacheStatsMisses => 'Промахов';

  @override
  String get cacheStatsEntries => 'Записей';

  @override
  String get cacheStatsHitRate => 'Эффективность';

  @override
  String get cacheStatsInvalidations => 'Инвалидаций';

  @override
  String get cacheInvalidateButton => 'Сбросить версию';

  @override
  String get cacheClearButton => 'Очистить кэш';

  @override
  String get cacheInvalidateSuccess => 'Кэш инвалидирован';

  @override
  String get cacheInvalidateFailed => 'Ошибка инвалидации';

  @override
  String get cacheClearSuccess => 'Кэш очищен';

  @override
  String get cacheClearFailed => 'Не удалось очистить кэш';

  @override
  String get cacheClearConfirmTitle => 'Очистить кэш сканирования?';

  @override
  String get cacheClearConfirmMsg =>
      'Все кэшированные результаты будут удалены. Файлы будут повторно проверены при следующем сканировании.';

  @override
  String get cacheClearConfirm => 'Очистить';

  @override
  String get cacheCoreUnavailable =>
      'Ядро недоступно - статистика кэша недоступна';

  @override
  String get dllInjectionAlertsTitle => 'Инъекции DLL';

  @override
  String get dllInjectionEmptyState => 'Подозрительных инъекций не обнаружено';

  @override
  String get dllInjectionScoreLabel => 'риск';

  @override
  String get memoryActionTerminate => 'Завершить процесс';

  @override
  String get memoryActionQuarantine => 'В карантин';

  @override
  String get memoryTerminateConfirmTitle => 'Завершить процесс?';

  @override
  String get memoryTerminateConfirmMsg =>
      'Процесс будет принудительно остановлен. Несохранённые данные будут потеряны.';

  @override
  String get memoryQuarantineConfirmTitle => 'Поместить в карантин?';

  @override
  String get memoryQuarantineConfirmMsg =>
      'Исполняемый файл процесса будет помещён в карантин.';

  @override
  String get memoryActionSuccess => 'Действие выполнено';

  @override
  String get memoryActionFailed => 'Не удалось выполнить действие';

  @override
  String get eventRealtimeThreatBlocked =>
      'Угроза заблокирована в реальном времени';

  @override
  String get eventMemoryThreatsFound => 'Найдены угрозы в памяти процессов';

  @override
  String get eventDllInjectionDetected => 'Обнаружена инъекция DLL';

  @override
  String get statsScreenTitle => 'Статистика защиты';

  @override
  String get statsScreenSubtitle => 'Защита во времени';

  @override
  String get statsPeriod7Days => '7 дней';

  @override
  String get statsPeriod30Days => '30 дней';

  @override
  String get statsPeriod90Days => '90 дней';

  @override
  String get statsHygieneTrendTitle => 'Гигиена цифровой жизни';

  @override
  String get statsHygieneTrendEmpty => 'Недостаточно данных для тренда';

  @override
  String get statsThreatsActivityTitle => 'Активность угроз';

  @override
  String get statsThreatsActivityEmpty => 'Угроз не обнаружено в этот период';

  @override
  String get statsThreatsTotal => 'Всего';

  @override
  String get statsEnginesPerformanceTitle => 'Производительность движков';

  @override
  String get statsCacheHitRate => 'Кэш hit rate';

  @override
  String get statsCacheEntries => 'В кэше';

  @override
  String get statsYaraRules => 'YARA правил';

  @override
  String get statsQuarantineCount => 'В карантине';

  @override
  String get statsThreatSourcesTitle => 'Источники угроз';

  @override
  String get statsThreatSourcesEmpty => 'Нет данных';

  @override
  String get statsSourceScan => 'Сканер';

  @override
  String get statsSourceRealtime => 'Реалтайм';

  @override
  String get statsSourceMemory => 'Память';

  @override
  String get statsSourceWeb => 'Веб';

  @override
  String get statsLoadingError => 'Не удалось загрузить статистику';

  @override
  String get statsCoreNotReady => 'Ядро не инициализировано';

  @override
  String get statsRunScanHint =>
      'Запустите сканирование, чтобы появились данные';

  @override
  String get statsHomeCardThreatsTodayShort => 'Сегодня';

  @override
  String get severityLabelInfo => 'Информация';

  @override
  String get severityLabelWarning => 'Предупреждение';

  @override
  String get severityLabelHigh => 'Высокий';

  @override
  String get severityLabelCritical => 'Критический';

  @override
  String get sandboxTitle => 'Песочница';

  @override
  String get sandboxDescription => 'Поведенческий анализ подозрительных файлов';

  @override
  String get sandboxRunningBadge => 'Выполняется';

  @override
  String get sandboxAnalyse => 'Анализировать в песочнице';

  @override
  String get sandboxRunning => 'Выполняется анализ в песочнице...';

  @override
  String get sandboxReport => 'Поведенческий отчёт';

  @override
  String get sandboxCancel => 'Отменить';

  @override
  String get sandboxRiskScore => 'Оценка риска';

  @override
  String get sandboxRiskIndicators => 'Индикаторы риска';

  @override
  String get sandboxChildProcesses => 'Дочерние процессы';

  @override
  String get sandboxLoadedModules => 'Загруженные модули';

  @override
  String get sandboxMemorySpikes => 'Выбросы памяти';

  @override
  String get sandboxNoBehaviour => 'Подозрительного поведения не обнаружено.';

  @override
  String get sandboxError => 'Ошибка песочницы';

  @override
  String get sandboxRequiresAdmin => 'Песочница требует Windows 8 или выше';

  @override
  String get sandboxStartFailed => 'Не удалось запустить песочницу';

  @override
  String get sandboxErrorUnsupported =>
      'Этот тип файла не поддерживается песочницей. Поддерживаются: .exe, .ps1, .bat, .cmd, .vbs, .js';

  @override
  String get sandboxErrorBadFormat =>
      'Файл не является исполняемым. EICAR, .txt, .pdf и подобные файлы нельзя запустить напрямую';

  @override
  String get sandboxErrorFileNotFound =>
      'Файл не найден - возможно, он был удалён или перемещён';

  @override
  String get sandboxErrorAccessDenied =>
      'Нет доступа к файлу. Проверьте права на чтение';

  @override
  String get sandboxErrorAlreadyRunning =>
      'Песочница уже выполняет анализ. Дождитесь завершения или отмените';

  @override
  String get sandboxErrorDllUnsupported =>
      'Анализ DLL-файлов пока не поддерживается (требуется имя экспорта)';

  @override
  String get sandboxErrorNestedJobsUnsupported =>
      'Не удалось изолировать процесс - операционная система не поддерживает вложенные Job Objects (требуется Windows 8 или выше)';

  @override
  String get sandboxErrorCopyFailed =>
      'Не удалось скопировать файл во временную директорию для безопасного анализа. Проверьте свободное место на диске';

  @override
  String get sandboxErrorBlocked =>
      'Запуск файла заблокирован системой безопасности (антивирусом или ограничениями процесса). Откройте лог MentoringProtector.log для подробностей';

  @override
  String get sandboxErrorAppContainerProfile =>
      'Не удалось создать профиль AppContainer для изоляции. Возможно, групповая политика блокирует AppContainer\'ы';

  @override
  String get sandboxErrorAppContainerAce =>
      'Не удалось предоставить песочнице доступ к временной директории. Проверьте права на %TEMP%';

  @override
  String get statsTabDashboard => 'Дашборд';

  @override
  String get statsTabHistory => 'История';

  @override
  String get archiveSearchHint => 'Поиск по имени файла или угрозе';

  @override
  String get archiveFilterAll => 'Все';

  @override
  String get archiveFilterScan => 'Сканирование';

  @override
  String get archiveFilterSandbox => 'Песочница';

  @override
  String get archiveEmptyTitle => 'Архив пуст';

  @override
  String get archiveEmptyDescription =>
      'Завершённые проверки и анализы в песочнице будут отображаться здесь';

  @override
  String get archiveClearMenu => 'Очистить архив';

  @override
  String get archiveClearConfirm =>
      'Удалить все записи архива? Действие необратимо.';

  @override
  String get archiveCleared => 'Архив очищен';

  @override
  String sandboxErrorGeneric(String code) {
    return 'Не удалось запустить песочницу: $code';
  }

  @override
  String get sandboxArchiveExtractFirst =>
      'Не удалось извлечь файл из архива для анализа в песочнице.';

  @override
  String get sandboxArchiveNotExecutable =>
      'Файл внутри архива не является исполняемым. Песочница поддерживает только: .exe, .ps1, .bat, .cmd, .vbs, .js';

  @override
  String get actionCenterTitle => 'Центр действий';

  @override
  String get actionCenterEmpty => 'Угроз не обнаружено';

  @override
  String get actionCenterViewAll => 'Все инциденты';

  @override
  String actionCenterCount(int count) {
    return '$count инцидентов';
  }

  @override
  String get btnWhitelist => 'В список исключений';

  @override
  String get btnLearn => 'Узнать больше';

  @override
  String get incidentStatusPending => 'Требует решения';

  @override
  String get incidentStatusQuarantined => 'В карантине';

  @override
  String get incidentStatusWhitelisted => 'Исключён';

  @override
  String get incidentStatusIgnored => 'Проигнорирован';

  @override
  String get incidentReEvaluate => 'Пересмотреть';

  @override
  String get incidentWhitelistSuccess => 'Файл добавлен в исключения';

  @override
  String get incidentWhitelistFailed => 'Не удалось добавить в исключения';

  @override
  String get actionCenterSearchHint => 'Поиск по файлу или угрозе';

  @override
  String get actionCenterGroupToday => 'Сегодня';

  @override
  String get actionCenterGroupYesterday => 'Вчера';

  @override
  String actionCenterDetectionMethod(String method) {
    return 'Метод: $method';
  }

  @override
  String get nudgeDismiss => 'Понятно';

  @override
  String get nudgeScanFile => 'Проверить файл';

  @override
  String get nudgeQuarantine => 'В карантин';

  @override
  String get nudgeTrust => 'Я доверяю этому файлу';

  @override
  String get nudgeCheckDrive => 'Проверить диск';

  @override
  String get nudgeDownloadedExeTitle => 'Скачанный исполняемый файл';

  @override
  String get nudgeDownloadedExeTip =>
      'Исполняемые файлы, скачанные из интернета - основной способ доставки вредоносного ПО. Злоумышленники маскируют малварь под установщики программ, бесплатные утилиты и «кряки».';

  @override
  String get nudgeDownloadedExeCheck1 =>
      'Это файл с официального сайта или проверенного магазина приложений?';

  @override
  String get nudgeDownloadedExeCheck2 =>
      'Перед запуском проверьте хеш файла на VirusTotal.';

  @override
  String get nudgeDownloadedExeCheck3 =>
      'Остерегайтесь двойных расширений типа \'document.pdf.exe\' - классический трюк.';

  @override
  String get nudgeDownloadedExeAction1 =>
      'Сначала проверьте файл через MentoringProtector.';

  @override
  String get nudgeDownloadedExeAction2 =>
      'Если сомневаетесь - отправьте в карантин до выяснения источника.';

  @override
  String get nudgeDownloadedContainerTitle => 'Скачанный контейнер';

  @override
  String get nudgeDownloadedContainerTip =>
      'Контейнеры (ISO, VHD, 7z), скачанные из интернета, НЕ передают «метку интернета» (MOTW) файлам внутри. Атакующие этим пользуются (ISO-smuggling): извлечённые .exe не вызывают обычное предупреждение о загрузке.';

  @override
  String get nudgeDownloadedContainerCheck1 =>
      'Вы ожидали образ диска или архив из этого источника?';

  @override
  String get nudgeDownloadedContainerCheck2 =>
      'Извлечённые из него .exe НЕ покажут предупреждение «скачано из интернета» - считайте их недоверенными.';

  @override
  String get nudgeDownloadedContainerCheck3 =>
      'Просканируйте контейнер через MentoringProtector, а не монтируйте и не распаковывайте вслепую.';

  @override
  String get nudgeDownloadedContainerAction1 =>
      'Просканируйте контейнер и его содержимое до распаковки или монтирования.';

  @override
  String get nudgeDownloadedContainerAction2 =>
      'Если сомневаетесь - поместите контейнер в карантин до проверки источника.';

  @override
  String get nudgeMacroDocumentTitle => 'Документ с поддержкой макросов';

  @override
  String get nudgeMacroDocumentTip =>
      'Документы Office с макросами (.docm, .xlsm) могут выполнять код при открытии. Этот формат широко используется в фишинговых атаках для доставки малвари без видимого исполняемого файла.';

  @override
  String get nudgeMacroDocumentCheck1 =>
      'Вы ожидали этот файл? От доверенного отправителя?';

  @override
  String get nudgeMacroDocumentCheck2 =>
      'Легитимные рабочие документы редко требуют включения макросов.';

  @override
  String get nudgeMacroDocumentCheck3 =>
      'Если документ просит \'Включить содержимое для просмотра\' - это красный флаг.';

  @override
  String get nudgeMacroDocumentAction1 =>
      'Сначала откройте в защищённом режиме просмотра (только для чтения).';

  @override
  String get nudgeMacroDocumentAction2 =>
      'Включайте макросы только если лично запрашивали этот файл.';

  @override
  String get nudgeSuspiciousScriptTitle => 'Подозрительный скрипт';

  @override
  String get nudgeSuspiciousScriptTip =>
      'Этот скрипт содержит паттерны, характерные для вредоносного PowerShell или VBScript: загрузка файлов из интернета, закодированные команды, скрытое выполнение - классические признаки загрузчика малвари.';

  @override
  String get nudgeSuspiciousScriptCheck1 =>
      'Вы знаете, кто написал этот скрипт и что он должен делать?';

  @override
  String get nudgeSuspiciousScriptCheck2 =>
      'Закодированные команды (-EncodedCommand, FromBase64String) скрывают реальные действия скрипта.';

  @override
  String get nudgeSuspiciousScriptCheck3 =>
      'Легитимные системные скрипты редко скачивают файлы во время выполнения.';

  @override
  String get nudgeSuspiciousScriptAction1 =>
      'Откройте скрипт в текстовом редакторе и изучите содержимое перед запуском.';

  @override
  String get nudgeSuspiciousScriptAction2 =>
      'Если получили неожиданно - удалите и свяжитесь с отправителем другим способом.';

  @override
  String get nudgeUsbDeviceTitle => 'Подключено съёмное устройство';

  @override
  String get nudgeUsbDeviceTip =>
      'Неизвестные USB-накопители - реальный вектор атак. Устройства \'BadUSB\' притворяются клавиатурой и вводят вредоносные команды. Найденные флешки не стоит доверять - классическая техника социальной инженерии.';

  @override
  String get nudgeUsbDeviceCheck1 => 'Вы знаете, откуда этот накопитель?';

  @override
  String get nudgeUsbDeviceCheck2 =>
      'Никогда не подключайте найденные накопители - классическая атака социальной инженерии.';

  @override
  String get nudgeUsbDeviceCheck3 =>
      'Автозапуск отключён в Windows 7+, но вредоносные .lnk и .exe файлы всё равно опасны.';

  @override
  String get nudgeUsbDeviceAction1 =>
      'Проверьте накопитель через MentoringProtector перед открытием файлов.';

  @override
  String get nudgeUsbDeviceAction2 =>
      'Если не узнаёте устройство - извлеките его, не открывая файлы.';

  @override
  String get nudgeSource => 'Источник:';

  @override
  String get nudgeChecklist => 'Контрольный список';

  @override
  String get nudgeWhatToDo => 'Что делать';

  @override
  String get nudgeUsbScanning => 'Сканирую...';

  @override
  String get nudgeUsbScanDone => 'Проверка завершена';

  @override
  String get nudgeUsbNoThreats => 'Угроз не найдено';

  @override
  String get nudgeUsbThreats => 'Найдены угрозы';

  @override
  String get nudgeUsbRescan => 'Проверить снова';

  @override
  String get serviceManaged => 'Управляется системной службой';

  @override
  String get requiresElevation => 'Требуются права администратора';

  @override
  String get serviceCmdFailed => 'Ошибка отправки команды службе';
}
