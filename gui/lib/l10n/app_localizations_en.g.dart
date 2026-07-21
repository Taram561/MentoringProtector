// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.g.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navHome => 'Home';

  @override
  String get navScan => 'Scan';

  @override
  String get navQuarantine => 'Quarantine';

  @override
  String get navHygiene => 'Hygiene';

  @override
  String get navStats => 'Stats';

  @override
  String get navProcesses => 'Processes';

  @override
  String get navSettings => 'Settings';

  @override
  String get navVulnerabilities => 'Vulnerabilities';

  @override
  String get homeTitle => 'Mentoring Protector';

  @override
  String get homeProtected => 'Protection active';

  @override
  String get homeWarning => 'Needs attention';

  @override
  String get homeDanger => 'Device is not protected';

  @override
  String get homeLastScan => 'Last scan: ';

  @override
  String get homeNeverScanned => 'No scans performed yet';

  @override
  String get homeStartScan => 'Start scan';

  @override
  String get homeSignatures => 'Signatures in database';

  @override
  String get homeSignaturesCount => 'signatures';

  @override
  String get homeInQuarantine => 'In quarantine';

  @override
  String get homeRecentEvents => 'Recent events';

  @override
  String get homeScanDone => 'Scan complete - no threats';

  @override
  String get homeDbUpdated => 'Database updated';

  @override
  String get homeAppStarted => 'Mentoring Protector started';

  @override
  String get scanTitle => 'Scan';

  @override
  String get scanSelectTarget => 'Select scan target';

  @override
  String get scanFile => 'File';

  @override
  String get scanFolder => 'Folder';

  @override
  String get scanScanning => 'Scanning...';

  @override
  String get scanCancel => 'Cancel';

  @override
  String get scanNewScan => 'New';

  @override
  String get scanNoThreats => 'No threats found';

  @override
  String get scanThreatsFound => 'Threats found: ';

  @override
  String get scanResults => 'Results';

  @override
  String get scanChecked => 'Checked: ';

  @override
  String get scanOf => ' of ';

  @override
  String get scanStatsFilesScanned => 'Files scanned';

  @override
  String get scanStatsElapsedTime => 'Elapsed time';

  @override
  String get scanStatsActiveEngines => 'Active engines';

  @override
  String get scanStatsThreatsFound => 'Threats found';

  @override
  String get quarantineTitle => 'Quarantine';

  @override
  String get quarantineEmpty => 'Quarantine is empty';

  @override
  String get quarantineRestore => 'Restore';

  @override
  String get quarantineDelete => 'Delete';

  @override
  String get quarantineFile => 'files';

  @override
  String get quarantineDeleteConfirm =>
      'Delete this file permanently? It cannot be recovered.';

  @override
  String get quarantineRestoreConfirm =>
      'Restore this file to its original location?';

  @override
  String get quarantineRestoreSuccess => 'File restored';

  @override
  String get quarantineOrphanBadge => 'File unavailable';

  @override
  String get quarantineOrphanRemove => 'Remove from list';

  @override
  String get quarantineOrphanRemoveConfirm =>
      'The quarantine file is missing on disk. Remove this entry from the list?';

  @override
  String get processTitle => 'Process monitor';

  @override
  String get processStart => 'Start monitoring';

  @override
  String get processStop => 'Stop monitoring';

  @override
  String get processActive => 'Active';

  @override
  String get processBlocked => 'Blocked';

  @override
  String get processNoAlerts => 'No suspicious processes detected';

  @override
  String get processThreats => 'Threats';

  @override
  String get processSuspicious => 'Suspicious';

  @override
  String get processClean => 'Clean';

  @override
  String get processAnalysisTitle => 'Process file analysis';

  @override
  String get processAnalysisDesc =>
      'Mentoring Protector analyses every new process. Unknown files are checked heuristically.';

  @override
  String get processStartHint => 'Start monitoring\nto analyse processes';

  @override
  String get vulnTitle => 'Device vulnerabilities';

  @override
  String get vulnDescription =>
      'Analysis of Windows security settings, open services and system configuration.';

  @override
  String get vulnScan => 'Scan device';

  @override
  String get vulnScanBtn => 'Scan device';

  @override
  String get vulnScanning => 'Analysing system...';

  @override
  String get vulnNone => 'No vulnerabilities found';

  @override
  String get vulnFound => 'Vulnerabilities found: ';

  @override
  String get vulnCritical => 'Critical';

  @override
  String get vulnHigh => 'High';

  @override
  String get vulnMedium => 'Medium';

  @override
  String get vulnLow => 'Low';

  @override
  String get vulnHowToFix => 'How to fix';

  @override
  String get vulnMoreInfo => 'More info';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeSystem => 'System default';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsVersion => 'App version';

  @override
  String get settingsCoreVersion => 'Core version';

  @override
  String get helpTitle => 'Help & About';

  @override
  String get helpAbout => 'About the app, FAQ, and learning resources';

  @override
  String get helpMission =>
      'Adaptive Cyber Hygiene Platform - teaching users to prevent social engineering and phishing attacks';

  @override
  String get helpLinksTitle => 'Links';

  @override
  String get helpGithub => 'GitHub Repository';

  @override
  String get helpLicense => 'License (MIT)';

  @override
  String get helpEducationTitle => 'Learning Resources';

  @override
  String get helpCourseTitle => 'Cybersecurity Course';

  @override
  String get helpQuizTitle => 'Interactive Quizzes';

  @override
  String get helpCourseSoon => 'Coming soon';

  @override
  String get helpEducationPlaceholder => 'Educational content is coming soon!';

  @override
  String get faq01Q => 'What is YARA?';

  @override
  String get faq01A =>
      'YARA is a pattern-matching tool used to identify malware based on textual or binary patterns. MentoringProtector uses YARA rules as one of its detection engines alongside signatures and heuristics.';

  @override
  String get faq02Q => 'Why does MentoringProtector need administrator rights?';

  @override
  String get faq02A =>
      'The main application runs without admin rights. Administrator access (UAC) is only requested when you click \'Fix automatically\' in Vulnerability Scanner - this is required to modify Windows system registry settings.';

  @override
  String get faq03Q => 'What is Smart Scan Cache?';

  @override
  String get faq03A =>
      'Smart Scan Cache stores hash-based scan results so files that haven\'t changed don\'t need to be rescanned. This makes repeated scans significantly faster without compromising security.';

  @override
  String get faq04Q => 'What is the Bloom Filter used for?';

  @override
  String get faq04A =>
      'The Bloom Filter is a probabilistic data structure used for fast phishing domain lookups in Web Protection. It checks ~100K domains in microseconds with near-zero false negatives.';

  @override
  String get faq05Q => 'What happens to files in Quarantine?';

  @override
  String get faq05A =>
      'Quarantined files are encrypted with AES-256 and stored in a protected folder. They cannot execute. You can restore them if they were detected as false positives, or permanently delete them.';

  @override
  String get faq06Q => 'How does the heuristic engine work?';

  @override
  String get faq06A =>
      'The heuristic engine analyzes PE file structure: imports, suspicious strings, entropy (packed/encrypted sections), digital signature validity, and file size anomalies - without needing a signature database.';

  @override
  String get faq07Q => 'What is ETW monitoring?';

  @override
  String get faq07A =>
      'Event Tracing for Windows (ETW) is a kernel-level logging mechanism. MentoringProtector uses it to detect DLL injection and suspicious process activity at the OS kernel level.';

  @override
  String get faq08Q => 'Why choose MentoringProtector over Windows Defender?';

  @override
  String get faq08A =>
      'MentoringProtector is an educational platform: it explains WHY a file is suspicious (explainable detection), teaches cyber hygiene habits, and shows you exactly what detection logic triggered. Defender is great protection but doesn\'t teach.';

  @override
  String get hygieneUpdateTitle => 'Keep your system updated';

  @override
  String get hygieneUpdateDesc =>
      'Install Windows and app updates as soon as they are released. Most attacks exploit known vulnerabilities in older versions.';

  @override
  String get hygienePasswordTitle => 'Use strong passwords';

  @override
  String get hygienePasswordDesc =>
      'Use unique passwords of at least 12 characters for each service. A password manager makes this easy.';

  @override
  String get hygieneWifiTitle => 'Secure Wi-Fi';

  @override
  String get hygieneWifiDesc =>
      'Avoid public networks without a VPN. Use WPA3 encryption for your home network.';

  @override
  String get hygienePhishingTitle => 'Watch out for phishing';

  @override
  String get hygienePhishingDesc =>
      'Do not open attachments or links in suspicious emails. Always verify the sender address before replying.';

  @override
  String get hygieneBackupTitle => 'Back up your data';

  @override
  String get hygieneBackupDesc =>
      'Regularly back up important files. Follow the 3-2-1 rule: 3 copies, 2 media types, 1 offsite.';

  @override
  String get hygieneDownloadTitle => 'Download safely';

  @override
  String get hygieneDownloadDesc =>
      'Only download software from official sources. Scan files before running them.';

  @override
  String get hygiene2faTitle => 'Two-factor authentication';

  @override
  String get hygiene2faDesc =>
      'Enable 2FA for all important accounts: email, banking, social media. Use an authenticator app instead of SMS.';

  @override
  String get hygieneUsbTitle => 'Beware of USB devices';

  @override
  String get hygieneUsbDesc =>
      'Never plug in unknown USB drives. They may contain malware that runs automatically.';

  @override
  String get hygienePrivacyTitle => 'Privacy settings';

  @override
  String get hygienePrivacyDesc =>
      'Regularly review privacy settings in Windows, your browser, and apps. Disable unnecessary telemetry.';

  @override
  String get hygieneLockTitle => 'Lock your screen';

  @override
  String get hygieneLockDesc =>
      'Always lock your computer when you step away. Use Win+L. Set auto-lock after 5 minutes of inactivity.';

  @override
  String get hygieneExtensionsTitle => 'Browser extensions';

  @override
  String get hygieneExtensionsDesc =>
      'Remove unnecessary browser extensions. Each one can read your data on websites.';

  @override
  String get hygieneEncryptionTitle => 'Disk encryption';

  @override
  String get hygieneEncryptionDesc =>
      'Enable BitLocker or equivalent to encrypt your system drive. This protects your data if your laptop is stolen.';

  @override
  String get btnClose => 'Close';

  @override
  String get btnOk => 'OK';

  @override
  String get btnCancel => 'Cancel';

  @override
  String get errorDllNotFound => 'Antivirus core not found';

  @override
  String get errorGeneric => 'An error occurred';

  @override
  String get computerScanTitle => 'Computer Scan';

  @override
  String get computerScanDescription => 'Full scan of all drives';

  @override
  String get computerScanStart => 'Start Scan';

  @override
  String get computerScanDrive => 'Drive';

  @override
  String get computerScanThreats => 'Threats';

  @override
  String get computerScanThreatsFound => 'Threats found';

  @override
  String get computerScanNoThreats => 'No threats found';

  @override
  String get computerScanInfo1 => 'Signature scan against ClamAV database';

  @override
  String get computerScanInfo2 => 'Heuristic analysis of PE files';

  @override
  String get computerScanInfo3 => 'Skips Windows system folders';

  @override
  String get computerScanInfo4 => 'Safe: read-only, no file changes';

  @override
  String get navWebProtection => 'Web Shield';

  @override
  String get webTitle => 'Web Protection';

  @override
  String get webDescription =>
      'Real-time protection against phishing and malicious websites via browser extension.';

  @override
  String get webServerRunning => 'Server running';

  @override
  String get webServerStopped => 'Server stopped';

  @override
  String get webStart => 'Start protection';

  @override
  String get webStop => 'Stop protection';

  @override
  String get webThreatsLoaded => 'Threats in database';

  @override
  String get webAuthToken => 'Auth token';

  @override
  String get webCopyToken => 'Copy token';

  @override
  String get webTokenCopied => 'Token copied to clipboard';

  @override
  String get webRegenerateToken => 'Regenerate token';

  @override
  String get webRegenerateConfirm =>
      'Regenerate token? The current one will be invalidated.';

  @override
  String get webCheckUrl => 'Check URL';

  @override
  String get webCheckUrlHint => 'Enter URL to check';

  @override
  String get webResultSafe => 'Safe';

  @override
  String get webResultDanger => 'Dangerous';

  @override
  String get webScore => 'Threat score';

  @override
  String get webReason => 'Reason';

  @override
  String get webDomain => 'Domain';

  @override
  String get webEventsTitle => 'Recent checks';

  @override
  String get webNoEvents => 'No checks yet';

  @override
  String get webExtensionHint =>
      'Install the Chrome/Edge extension and paste the token in the extension settings.';

  @override
  String get webDetailTitle => 'URL Analysis';

  @override
  String get webDetailDomain => 'Domain';

  @override
  String get webDetailThreatType => 'Threat Type';

  @override
  String get webDetailRiskScore => 'Risk Level';

  @override
  String get webDetailAnalysis => 'Analysis Results';

  @override
  String get webDetailHomoglyphTitle => 'Homoglyph Attack Detected';

  @override
  String webDetailHomoglyphDesc(String brand) {
    return 'This domain impersonates the brand \"$brand\" using visually similar characters from another alphabet.';
  }

  @override
  String get webDetailTeachableTitle => 'How to spot this yourself?';

  @override
  String get webTipPhishing =>
      'Phishing sites copy the design of well-known services. Always check the URL bar - the real domain is before the first \"/\".';

  @override
  String get webTipMalware =>
      'Malicious sites often disguise themselves as updates or free software. Only download programs from official websites.';

  @override
  String get webTipScam =>
      'Scam sites create urgency: \"you won\", \"account blocked\". Don\'t rush - verify information through the official website.';

  @override
  String get webTipHomoglyph =>
      'Homoglyph attacks replace letters with lookalikes (e.g., Cyrillic \"а\" instead of Latin \"a\"). Hover over the URL - your browser will show the Punycode version.';

  @override
  String get webTipSuspicious =>
      'Suspicious domains often use unusual TLDs (.tk, .xyz), long subdomains, or IP addresses instead of names. When in doubt - don\'t enter your data.';

  @override
  String get webTipCryptominer =>
      'Website cryptominers use your CPU to mine cryptocurrency. Signs: sudden CPU spike, fan noise, browser lag.';

  @override
  String get webTipTracking =>
      'Tracking scripts collect data about your behavior. Use ad blockers and incognito mode for better privacy.';

  @override
  String get webTipGeneral =>
      'Before entering personal data, verify the URL starts with https:// and the domain matches the expected service.';

  @override
  String get webDetailSafe => 'Safe';

  @override
  String get webDetailLow => 'Low';

  @override
  String get webDetailMedium => 'Medium';

  @override
  String get webDetailHigh => 'High';

  @override
  String get webDetailCritical => 'Critical';

  @override
  String get webReasonPhishing => 'Phishing';

  @override
  String get webReasonMalware => 'Malware';

  @override
  String get webReasonScam => 'Scam';

  @override
  String get webReasonCryptominer => 'Cryptominer';

  @override
  String get webReasonTracking => 'Tracker';

  @override
  String get webReasonSuspicious => 'Suspicious';

  @override
  String get webReasonClean => 'Clean';

  @override
  String get navProtection => 'Protection';

  @override
  String get protectionTitle => 'Protection Modules';

  @override
  String get navRealtime => 'Realtime';

  @override
  String get archiveScannerTitle => 'Archive Scanner';

  @override
  String get archiveScannerDescription =>
      'Scans ZIP, 7z, RAR and ISO archives for threats inside. Zip-bomb protection included.';

  @override
  String get realtimeTitle => 'Real-time Protection';

  @override
  String get realtimeDescription =>
      'Monitors file creation and modification in Downloads, Desktop, Documents and Temp';

  @override
  String get realtimeStart => 'Enable protection';

  @override
  String get realtimeStop => 'Disable protection';

  @override
  String get realtimeActive => 'Active';

  @override
  String get realtimeNoEvents => 'No events';

  @override
  String get realtimeStartHint =>
      'Press the button to enable real-time protection';

  @override
  String get realtimeTotalDetected => 'Detected';

  @override
  String get realtimeThreatsFound => 'Threats';

  @override
  String get realtimeEvents => 'Events';

  @override
  String get realtimeCreated => 'Created';

  @override
  String get realtimeModified => 'Modified';

  @override
  String get realtimeRenamed => 'Renamed';

  @override
  String get navMemoryScan => 'RAM';

  @override
  String get memoryTitle => 'Memory Scan';

  @override
  String get memoryDescription =>
      'Search for malware signatures in running process memory';

  @override
  String get memoryScanStart => 'Start RAM scan';

  @override
  String get memoryScanStop => 'Stop';

  @override
  String get memoryScanRunning => 'Scanning...';

  @override
  String get memoryScanFinished => 'Completed';

  @override
  String get memoryScanNoThreats => 'No threats found in memory';

  @override
  String get memoryScanProcesses => 'Processes';

  @override
  String get memoryScanThreatsFound => 'Threats found';

  @override
  String get memoryScanCurrentProcess => 'Current process';

  @override
  String get memoryScanRegions => 'Memory regions';

  @override
  String get memoryScanMatches => 'Matches';

  @override
  String get memoryUnavailable => 'Memory scanner unavailable in current DLL';

  @override
  String get realtimeUnavailable =>
      'Real-time monitor unavailable in current DLL';

  @override
  String get scanQuarantine => 'Quarantine';

  @override
  String get scanDeleteFile => 'Delete file';

  @override
  String get scanIgnore => 'Ignore';

  @override
  String get scanQuarantineSuccess => 'File quarantined';

  @override
  String get scanDeleteSuccess => 'File deleted';

  @override
  String get scanDeleteConfirm => 'Delete file permanently?';

  @override
  String get scanDangerLevel => 'Danger level';

  @override
  String get scanDetectionMethod => 'Detection method';

  @override
  String get scanMethodSignature => 'Signature analysis';

  @override
  String get scanMethodHeuristic => 'Heuristic analysis';

  @override
  String get detectionMethodArchive => 'Archive Scan';

  @override
  String get archiveThreatFound => 'Threat found inside archive';

  @override
  String get archiveTeachableMoment =>
      'Archives are a common delivery vector for malware. Always verify archive contents before opening, especially files received via email or messengers.';

  @override
  String get scanHeuristicScore => 'Suspicion score';

  @override
  String get scanEntropy => 'File entropy';

  @override
  String get scanIsPacked => 'Packed';

  @override
  String get scanHasSignature => 'Digital signature';

  @override
  String get scanTriggeredRules => 'Triggered rules';

  @override
  String get scanRecommendation => 'Recommendation';

  @override
  String get scanHash => 'Hash (SHA256)';

  @override
  String get scanYes => 'Yes';

  @override
  String get scanNo => 'No';

  @override
  String get etwModeEtw => 'ETW';

  @override
  String get etwModePolling => 'Polling';

  @override
  String get etwDllInjectionTitle => 'DLL Injection';

  @override
  String get etwDllInjectionEmpty => 'No suspicious DLL loads detected';

  @override
  String get etwRunAsAdmin => 'Run as administrator for ETW mode';

  @override
  String get yaraRules => 'YARA rules';

  @override
  String get yaraDetection => 'YARA analysis';

  @override
  String get yaraRulesLoaded => 'YARA rules loaded';

  @override
  String get yaraNotAvailable => 'YARA engine not available';

  @override
  String get yaraAuthor => 'Author';

  @override
  String get yaraSeverity => 'Severity';

  @override
  String get homeActiveModules => 'Active modules';

  @override
  String get sectionBasicProtection => 'Basic Protection';

  @override
  String get sectionAdvancedProtection => 'Advanced Protection';

  @override
  String get sectionTools => 'Tools';

  @override
  String get sectionTechnologies => 'Scan Technologies';

  @override
  String get plannedBadge => 'Planned';

  @override
  String get experimentalBadge => 'Experimental';

  @override
  String get emailProtectionTitle => 'Email Antivirus';

  @override
  String get emailProtectionDesc =>
      'Scan email attachments for viruses and phishing';

  @override
  String get networkProtectionTitle => 'Network Attack Protection';

  @override
  String get networkProtectionDesc =>
      'Detect and block network attacks (port scanning, ARP spoofing)';

  @override
  String get amsiTitle => 'AMSI Integration';

  @override
  String get amsiDesc =>
      'Script inspection via Windows Antimalware Scan Interface';

  @override
  String get scriptGuardTitle => 'Script Guard';

  @override
  String get scriptGuardDesc =>
      'Control execution of PowerShell, VBS, BAT scripts';

  @override
  String get etwTitle => 'ETW Monitoring';

  @override
  String get etwDesc =>
      'Windows kernel monitoring via Event Tracing (DLL loads, process creation)';

  @override
  String get smartScanCacheTitle => 'Smart Scan Cache';

  @override
  String get smartScanCacheDesc => 'Skip re-scanning unchanged files';

  @override
  String get trustedReputationTitle => 'Trusted File Reputation';

  @override
  String get trustedReputationDesc =>
      'Trust files with valid digital signatures from safe paths';

  @override
  String get exclusionListTitle => 'Scan Exclusions';

  @override
  String get exclusionListDesc => 'Files and folders excluded from scanning';

  @override
  String get exclusionListEmpty => 'No exclusions configured';

  @override
  String get exclusionListAdd => 'Add Exclusion';

  @override
  String get exclusionListAddHint => 'File path, folder, or mask (*.log)';

  @override
  String get exclusionListRemoveConfirm => 'Remove from exclusions?';

  @override
  String get exclusionListFolder => 'Select folder';

  @override
  String get exclusionListFile => 'Select file';

  @override
  String get exclusionListMask => 'Enter mask';

  @override
  String get onboardingWelcome => 'Welcome to Mentoring Protector';

  @override
  String get onboardingWelcomeDesc =>
      'Let\'s set up protection for your experience level. This will take less than a minute.';

  @override
  String get onboardingLevelTitle => 'Your Level';

  @override
  String get onboardingLevelDesc =>
      'How would you rate your cybersecurity experience?';

  @override
  String get onboardingBeginner => 'Beginner';

  @override
  String get onboardingBeginnerDesc =>
      'I\'m just starting to learn about security';

  @override
  String get onboardingRegular => 'Regular User';

  @override
  String get onboardingRegularDesc =>
      'I know the basics but want to learn more';

  @override
  String get onboardingAdvanced => 'Advanced';

  @override
  String get onboardingAdvancedDesc => 'I have strong IT security knowledge';

  @override
  String get onboardingGoalTitle => 'Your Goal';

  @override
  String get onboardingGoalDesc => 'What matters most to you?';

  @override
  String get onboardingGoalMax => 'Maximum Protection';

  @override
  String get onboardingGoalMaxDesc =>
      'Block everything suspicious - better safe than sorry';

  @override
  String get onboardingGoalBalanced => 'Balance of Convenience and Security';

  @override
  String get onboardingGoalBalancedDesc => 'Warn me but don\'t get in the way';

  @override
  String get onboardingGoalLearn => 'I Want to Learn';

  @override
  String get onboardingGoalLearnDesc =>
      'Show detailed threat explanations and how to spot them';

  @override
  String get onboardingStart => 'Get Started';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingBack => 'Back';

  @override
  String get profileTitle => 'Security Profile';

  @override
  String get profileLevel => 'Level';

  @override
  String get profileRiskScore => 'Risk Index';

  @override
  String get profileSafetyScore => 'Safety Score';

  @override
  String get profileRiskTierSafe => 'Safe behavior';

  @override
  String get profileRiskTierCautious => 'Cautious behavior';

  @override
  String get profileRiskTierRisky => 'Some risky habits';

  @override
  String get profileRiskTierDangerous => 'Frequently ignores warnings';

  @override
  String get profilePositiveActions => 'Positive actions';

  @override
  String get profileRiskyActions => 'Risky actions';

  @override
  String get profileRecentEvents => 'Recent Events';

  @override
  String get profileNoEvents => 'No events yet - keep it up!';

  @override
  String get profileWhyRisky => 'Why the system considers you at risk';

  @override
  String get profileEventWebIgnored => 'Web protection warning ignored';

  @override
  String get profileEventScanIgnored => 'Detected threat ignored';

  @override
  String get profileEventProtDisabled => 'Protection module disabled';

  @override
  String get profileEventDangerDownload => 'Dangerous download';

  @override
  String get profileEventLesson => 'Training module completed';

  @override
  String get profileEventProtEnabled => 'Protection module enabled';

  @override
  String get profileEventQuarantined => 'Threat quarantined';

  @override
  String get dbStatusTitle => 'Database status';

  @override
  String get dbStatusUpdated => 'Up to date';

  @override
  String get dbStatusOutdated => 'Needs update';

  @override
  String get dbStatusNeverUpdated => 'Never updated';

  @override
  String get dbStatusLastUpdate => 'Last update';

  @override
  String get dbStatusUpdate => 'Update';

  @override
  String get dbStatusUpdating => 'Updating...';

  @override
  String get dbUpdateFellBackPython =>
      'Updated via Python fallback (CVD parse failed)';

  @override
  String get dbUpdateMd5Failed => 'CVD checksum mismatch - skipping update';

  @override
  String get dbUpdateProgress => 'Downloading signature database…';

  @override
  String get yaraRulesTitle => 'YARA Rules Engine';

  @override
  String yaraRulesCount(int count) {
    return '$count rules loaded';
  }

  @override
  String get yaraUnavailable => 'YARA engine not available';

  @override
  String get yaraReloadButton => 'Reload rules';

  @override
  String get yaraReloadSuccess => 'YARA rules reloaded successfully';

  @override
  String get yaraReloadFailed => 'Failed to reload YARA rules';

  @override
  String get activeEnginesLabel => 'Active engines';

  @override
  String get engineSignatures => 'Signatures';

  @override
  String get engineHeuristic => 'Heuristic';

  @override
  String get engineYara => 'YARA';

  @override
  String get engineBloom => 'Bloom Filter';

  @override
  String get windowMinimize => 'Minimize';

  @override
  String get windowMaximize => 'Maximize';

  @override
  String get windowRestore => 'Restore';

  @override
  String get windowClose => 'Close';

  @override
  String eventThreatFound(String name) {
    return 'Threat found: $name';
  }

  @override
  String get eventScanComplete => 'Scan complete';

  @override
  String eventScanThreats(int count) {
    return 'Threats found: $count';
  }

  @override
  String get eventProtectionStarted => 'Real-time protection enabled';

  @override
  String get eventProtectionStopped => 'Real-time protection disabled';

  @override
  String get threatSuspiciousImports => 'Suspicious WinAPI imports';

  @override
  String get threatSuspiciousStrings => 'Suspicious strings';

  @override
  String get threatOpenFileLocation => 'Open file location';

  @override
  String get threatVerdictClean => 'Clean';

  @override
  String get threatVerdictSuspicious => 'Suspicious';

  @override
  String get threatVerdictLikelyMalicious => 'Likely malicious';

  @override
  String get threatVerdictMalicious => 'Malicious';

  @override
  String get threatVerdictUnknown => 'Unknown';

  @override
  String get threatSuspicionLevel => 'Suspicion level';

  @override
  String get threatPeFile => 'PE file';

  @override
  String get threatSigned => 'Signed';

  @override
  String get threatCertRevoked => 'Certificate revoked';

  @override
  String get threatUnsigned => 'Unsigned';

  @override
  String threatEntropyValue(String value) {
    return 'Entropy: $value';
  }

  @override
  String get threatSigRevokedTitle => 'Signature - CERTIFICATE REVOKED';

  @override
  String get threatDigitalSignatureTitle => 'Digital signature';

  @override
  String get threatSigner => 'Signer';

  @override
  String get threatIssuer => 'Issuer';

  @override
  String get threatValidUntil => 'Valid until';

  @override
  String get threatRevokedWarning =>
      'A revoked certificate means the signing key may have been compromised. The file should not be trusted.';

  @override
  String get threatUnknownThreat => 'Unknown threat';

  @override
  String get threatUnknownDesc => 'A suspicious file was detected.';

  @override
  String get threatQuarantineStep => 'Place the file in quarantine';

  @override
  String threatAuthorPrefix(String name) {
    return 'Author: $name';
  }

  @override
  String get vulnComponent => 'Component';

  @override
  String get vulnDescriptionLabel => 'Description';

  @override
  String get vulnAutoFixButton => 'Fix automatically';

  @override
  String get vulnFixInProgress => 'Fixing…';

  @override
  String get vulnFixSuccess => 'Fixed successfully';

  @override
  String get vulnFixError => 'Fix failed';

  @override
  String get vulnFixUacDenied => 'You cancelled the UAC confirmation';

  @override
  String get vulnFixRebootRequired => 'Reboot required';

  @override
  String get vulnFixRebootBody =>
      'This fix takes effect after a system restart. Would you like to restart now?';

  @override
  String get vulnFixRebootNow => 'Restart now';

  @override
  String get vulnFixRebootLater => 'Later';

  @override
  String get vulnFixRebootManual =>
      'Please restart your computer to apply the changes';

  @override
  String scanTimeSec(int sec) {
    return '$sec s';
  }

  @override
  String scanTimeMinSec(int min, int sec) {
    return '$min min $sec s';
  }

  @override
  String get memThreatLabel => 'Threat';

  @override
  String get memPathLabel => 'Path';

  @override
  String get memMatchesLabel => 'Matches';

  @override
  String get memRegionsLabel => 'Regions scanned';

  @override
  String get memMemoryScanned => 'Memory scanned';

  @override
  String get memMb => 'MB';

  @override
  String get memDetectedSignatures => 'Detected signatures:';

  @override
  String get processFunctionUnavailable =>
      'Function unavailable in current DLL version';

  @override
  String processErrorPrefix(String message) {
    return 'Error: $message';
  }

  @override
  String get processPathLabel => 'Path';

  @override
  String get processVerdictLabel => 'Verdict';

  @override
  String get processDangerLevel => 'Danger level';

  @override
  String get processSuspicionScore => 'Suspicion score';

  @override
  String get processThreatLabel => 'Threat';

  @override
  String get processDetectionMethod => 'Detection method';

  @override
  String get processRulesLabel => 'Rules';

  @override
  String get processHashLabel => 'Hash';

  @override
  String processTerminatedMsg(String name) {
    return 'Process $name terminated';
  }

  @override
  String get processTerminate => 'Terminate';

  @override
  String get processAllow => 'Allow';

  @override
  String get processWasTerminated => 'Process was terminated';

  @override
  String get inspectButton => 'Inspect Process';

  @override
  String get inspectTitle => 'Process Inspection';

  @override
  String get inspectBasicInfo => 'General';

  @override
  String get inspectParentPid => 'Parent PID';

  @override
  String get inspectProcessName => 'Process';

  @override
  String get inspectSignature => 'Signature';

  @override
  String get inspectCmdline => 'Command line';

  @override
  String get inspectFileHash => 'File hash';

  @override
  String inspectModules(int count) {
    return '$count loaded modules';
  }

  @override
  String get exclusionMaskType => 'Extension mask';

  @override
  String get exclusionFolderType => 'Folder';

  @override
  String get exclusionPathType => 'Path';

  @override
  String get hygieneIndexTitle => 'Digital Hygiene Index';

  @override
  String hygieneIndexGrowth(int value) {
    return '+$value over the week';
  }

  @override
  String hygieneIndexDecline(int value) {
    return '-$value over the week';
  }

  @override
  String hygieneCompleted(int done, int total) {
    return 'Tips completed: $done / $total';
  }

  @override
  String get hygieneHistory => 'Last 30 days';

  @override
  String get hygieneWeeklyTitle => 'Recommended for you';

  @override
  String get hygieneWeeklySubtitle => 'Based on your recent activity';

  @override
  String get hygieneAllTips => 'All tips';

  @override
  String get hygieneTipDone => 'Completed';

  @override
  String get hygieneTipMarkDone => 'Mark as done';

  @override
  String get hygieneTipUndo => 'Undo';

  @override
  String get hygieneReasonWeb => 'You recently ignored a web warning';

  @override
  String get hygieneReasonScan => 'You recently ignored a detected threat';

  @override
  String get hygieneReasonDownload => 'You recently downloaded a risky file';

  @override
  String get hygieneReasonProtection =>
      'You recently disabled a protection module';

  @override
  String get hygieneRecommended => 'Recommended';

  @override
  String get copyPath => 'Copy path';

  @override
  String get copyInstructions => 'Copy instructions';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String get quizTitle => 'Knowledge Check';

  @override
  String get quizNext => 'Next';

  @override
  String get quizFinish => 'See results';

  @override
  String get quizClose => 'Close';

  @override
  String get quizResultTitle => 'Quiz Complete!';

  @override
  String quizResultScore(int correct, int total) {
    return '$correct/$total';
  }

  @override
  String get quizResultPerfect => 'Excellent! You know this topic well.';

  @override
  String get quizResultKeepLearning =>
      'Review the tip and try again to reinforce your knowledge.';

  @override
  String get quizTakeQuiz => 'Take quiz';

  @override
  String get quizPassed => 'Quiz passed';

  @override
  String get quizUpdateQ1 =>
      'Why is it important to install OS and software updates?';

  @override
  String get quizUpdateQ1A1 =>
      'They fix security vulnerabilities that attackers exploit';

  @override
  String get quizUpdateQ1A2 => 'They only add new features';

  @override
  String get quizUpdateQ1A3 => 'They make the computer faster';

  @override
  String get quizUpdateQ1Explain =>
      'Updates often patch known vulnerabilities (CVE). The WannaCry attack in 2017 exploited a flaw that had a patch available 2 months prior.';

  @override
  String get quizUpdateQ2 =>
      'What should you do if an update requires a restart?';

  @override
  String get quizUpdateQ2A1 =>
      'Save your work and restart soon - don\'t delay for days';

  @override
  String get quizUpdateQ2A2 =>
      'Postpone it indefinitely - restarts are annoying';

  @override
  String get quizUpdateQ2A3 => 'Disable automatic updates entirely';

  @override
  String get quizUpdateQ2Explain =>
      'Delaying restarts leaves your system exposed. Most attacks target known, already-patched vulnerabilities.';

  @override
  String get quizPasswordQ1 => 'Which password is the most secure?';

  @override
  String get quizPasswordQ1A1 =>
      'A random phrase: \'correct horse battery staple\'';

  @override
  String get quizPasswordQ1A2 => 'Your birth date: \'19052000\'';

  @override
  String get quizPasswordQ1A3 => 'A simple modification: \'P@ssword123\'';

  @override
  String get quizPasswordQ1Explain =>
      'Random passphrases are long and hard to guess, yet easy to remember. Dictionary substitutions like P@ssword are well-known to attackers.';

  @override
  String get quizPasswordQ2 =>
      'Why should you use a different password for each service?';

  @override
  String get quizPasswordQ2A1 =>
      'If one service is breached, attackers can\'t access your other accounts';

  @override
  String get quizPasswordQ2A2 =>
      'It\'s not really necessary - one strong password is enough';

  @override
  String get quizPasswordQ2A3 => 'Websites require it';

  @override
  String get quizPasswordQ2Explain =>
      'Credential stuffing attacks test leaked passwords across many services. Unique passwords limit damage to just the breached service.';

  @override
  String get quizPhishingQ1 =>
      'You receive an email from \'support@paypa1.com\' asking to verify your account. What do you do?';

  @override
  String get quizPhishingQ1A1 =>
      'Don\'t click - \'paypa1\' uses the digit 1 instead of the letter l';

  @override
  String get quizPhishingQ1A2 => 'Click the link and enter your login';

  @override
  String get quizPhishingQ1A3 => 'Forward the email to friends';

  @override
  String get quizPhishingQ1Explain =>
      'Homoglyph attacks use similar-looking characters (1 vs l, 0 vs O). Always verify the exact domain spelling before clicking.';

  @override
  String get quizPhishingQ2 =>
      'Which is the safest way to visit your bank\'s website?';

  @override
  String get quizPhishingQ2A1 =>
      'Type the URL manually in the address bar or use a saved bookmark';

  @override
  String get quizPhishingQ2A2 =>
      'Search for it in Google and click the first result';

  @override
  String get quizPhishingQ2A3 => 'Click a link in an email from the bank';

  @override
  String get quizPhishingQ2Explain =>
      'Attackers can buy ads that appear above real search results, and spoofed emails are common. Manual entry or bookmarks are the safest.';

  @override
  String get quizPhishingQ3 =>
      'A website shows a lock icon (HTTPS). Does this mean it\'s safe?';

  @override
  String get quizPhishingQ3A1 =>
      'No - HTTPS only means the connection is encrypted, not that the site is trustworthy';

  @override
  String get quizPhishingQ3A2 =>
      'Yes - the lock guarantees the site is legitimate';

  @override
  String get quizPhishingQ3A3 => 'Only if the lock is green';

  @override
  String get quizPhishingQ3Explain =>
      'Free certificates (Let\'s Encrypt) mean phishing sites can also have HTTPS. The lock encrypts traffic but doesn\'t verify the site\'s intentions.';

  @override
  String get quizDownloadQ1 => 'You need a program. What is the safest source?';

  @override
  String get quizDownloadQ1A1 =>
      'The official website of the developer or an official app store';

  @override
  String get quizDownloadQ1A2 => 'A torrent with \'cracked\' in the name';

  @override
  String get quizDownloadQ1A3 => 'A random download site from a search result';

  @override
  String get quizDownloadQ1Explain =>
      'Third-party download sites and cracks often bundle malware. Official sources and stores verify software integrity.';

  @override
  String get quizDownloadQ2 =>
      'A downloaded file has a double extension \'invoice.pdf.exe\'. What does this mean?';

  @override
  String get quizDownloadQ2A1 =>
      'It is an executable disguised as a PDF - likely malware';

  @override
  String get quizDownloadQ2A2 => 'It is a normal PDF document';

  @override
  String get quizDownloadQ2A3 =>
      'Windows added the extra extension automatically';

  @override
  String get quizDownloadQ2Explain =>
      'Windows hides known extensions by default. Attackers add a fake extension before the real one (.exe) to trick users into opening malware.';

  @override
  String get quizWifiQ1 => 'Why is public Wi-Fi (cafés, airports) dangerous?';

  @override
  String get quizWifiQ1A1 =>
      'Attackers on the same network can intercept your unencrypted traffic';

  @override
  String get quizWifiQ1A2 => 'It\'s always slower than mobile data';

  @override
  String get quizWifiQ1A3 =>
      'Public Wi-Fi has no dangers if the site uses HTTPS';

  @override
  String get quizWifiQ1Explain =>
      'On public networks, attackers can run man-in-the-middle attacks. Use a VPN or avoid entering sensitive data on public Wi-Fi.';

  @override
  String get quiz2faQ1 => 'What is two-factor authentication (2FA)?';

  @override
  String get quiz2faQ1A1 =>
      'An extra verification step (code via SMS/app) in addition to your password';

  @override
  String get quiz2faQ1A2 => 'Using two different passwords';

  @override
  String get quiz2faQ1A3 => 'Logging in from two devices at once';

  @override
  String get quiz2faQ1Explain =>
      '2FA requires something you know (password) + something you have (phone/token). Even if your password leaks, the attacker still can\'t log in without the second factor.';

  @override
  String get hygieneUpdateDescBeginner =>
      'Install updates as soon as they appear - they fix holes that viruses use to break in.';

  @override
  String get hygieneUpdateDescAdvanced =>
      'Apply OS and application patches promptly. Zero-day exploits target known CVEs within hours of disclosure.';

  @override
  String get hygienePasswordDescBeginner =>
      'Use a different long password for every site. A password manager remembers them all for you.';

  @override
  String get hygienePasswordDescAdvanced =>
      'Use a password manager with unique 16+ char credentials per service. Enable breach monitoring (HaveIBeenPwned).';

  @override
  String get hygienePhishingDescBeginner =>
      'Don\'t click links in suspicious emails. Always check who sent the message and where the link actually goes.';

  @override
  String get hygienePhishingDescAdvanced =>
      'Verify sender SPF/DKIM headers, inspect link destinations via hover, watch for homoglyph domains and URL shorteners.';

  @override
  String get hygieneDownloadDescBeginner =>
      'Only download programs from official websites. Cracked software almost always contains viruses.';

  @override
  String get hygieneDownloadDescAdvanced =>
      'Verify file hashes and digital signatures before execution. Use sandboxing for untrusted binaries.';

  @override
  String get hygieneWifiDescBeginner =>
      'Don\'t enter passwords or bank details on public Wi-Fi. Use mobile data or a VPN instead.';

  @override
  String get hygieneWifiDescAdvanced =>
      'Public networks enable MITM/ARP spoofing. Use WireGuard/OpenVPN; verify TLS certificate pinning on critical services.';

  @override
  String get hygiene2faDescBeginner =>
      'Turn on two-factor authentication - even if someone steals your password, they still can\'t log in.';

  @override
  String get hygiene2faDescAdvanced =>
      'Enable TOTP or FIDO2/WebAuthn. Avoid SMS-based 2FA where possible due to SIM-swap attacks.';

  @override
  String get quizRetake => 'Retake quiz';

  @override
  String get quizUpdateQ1A4 => 'Updates are optional and not important';

  @override
  String get quizUpdateQ2A4 => 'Only install updates once a year';

  @override
  String get quizUpdateQ3 => 'What is a zero-day vulnerability?';

  @override
  String get quizUpdateQ3A1 =>
      'A flaw exploited before the developer releases a patch';

  @override
  String get quizUpdateQ3A2 => 'A virus that activates at midnight';

  @override
  String get quizUpdateQ3A3 => 'A computer that has been on for zero days';

  @override
  String get quizUpdateQ3A4 => 'A password that expires in zero days';

  @override
  String get quizUpdateQ3Explain =>
      'Zero-day means the developer has had \'zero days\' to fix it. These are the most dangerous because no patch exists yet. Keeping software updated reduces the window of exposure.';

  @override
  String get quizPasswordQ1A4 =>
      'A single word from the dictionary: \'sunshine\'';

  @override
  String get quizPasswordQ2A4 =>
      'Browsers remember passwords automatically, no need to worry';

  @override
  String get quizPasswordQ3 => 'What is a password manager?';

  @override
  String get quizPasswordQ3A1 =>
      'A program that generates and securely stores unique passwords for each service';

  @override
  String get quizPasswordQ3A2 =>
      'A browser extension that shows saved passwords in plain text';

  @override
  String get quizPasswordQ3A3 =>
      'A text file where you write down all your passwords';

  @override
  String get quizPasswordQ3A4 =>
      'A setting in Windows that remembers your login';

  @override
  String get quizPasswordQ3Explain =>
      'Password managers encrypt your vault with a master password. They generate random unique passwords, auto-fill login forms, and alert you about breaches.';

  @override
  String get quizPhishingQ1A4 => 'Reply asking them to verify their identity';

  @override
  String get quizPhishingQ2A4 => 'Click a link from social media';

  @override
  String get quizPhishingQ3A4 => 'HTTPS doesn\'t matter at all';

  @override
  String get quizDownloadQ1A4 => 'A link from a stranger in a messaging app';

  @override
  String get quizDownloadQ2A4 => 'It\'s a compressed PDF for faster download';

  @override
  String get quizDownloadQ3 =>
      'What should you check before running a downloaded program?';

  @override
  String get quizDownloadQ3A1 =>
      'Its digital signature - a valid signature confirms the publisher\'s identity';

  @override
  String get quizDownloadQ3A2 =>
      'The file size - larger files are always safer';

  @override
  String get quizDownloadQ3A3 =>
      'The file icon - legitimate programs have professional icons';

  @override
  String get quizDownloadQ3A4 =>
      'Nothing - if the antivirus didn\'t block it, it\'s safe';

  @override
  String get quizDownloadQ3Explain =>
      'Digital signatures verify that the file comes from the claimed publisher and hasn\'t been tampered with. Unsigned executables from the internet should be treated with extra caution.';

  @override
  String get quizWifiQ1A4 =>
      'Public Wi-Fi is only dangerous if the network has no password';

  @override
  String get quizWifiQ2 => 'What is a VPN and why use it on public Wi-Fi?';

  @override
  String get quizWifiQ2A1 =>
      'It encrypts all your traffic through a secure tunnel, hiding it from network attackers';

  @override
  String get quizWifiQ2A2 => 'It makes your internet faster';

  @override
  String get quizWifiQ2A3 => 'It blocks all viruses automatically';

  @override
  String get quizWifiQ2A4 => 'It replaces your antivirus';

  @override
  String get quizWifiQ2Explain =>
      'A VPN (Virtual Private Network) creates an encrypted tunnel between your device and a server. Even if an attacker intercepts your traffic on public Wi-Fi, they only see encrypted data.';

  @override
  String get quizWifiQ3 =>
      'You see a Wi-Fi network called \'Free_Airport_WiFi\' at the airport. What is the risk?';

  @override
  String get quizWifiQ3A1 =>
      'It could be a fake hotspot set up by an attacker to intercept your data';

  @override
  String get quizWifiQ3A2 => 'Free networks are always safe at airports';

  @override
  String get quizWifiQ3A3 => 'The only risk is slow speed';

  @override
  String get quizWifiQ3A4 =>
      'Airport Wi-Fi is monitored by security, so it\'s always safe';

  @override
  String get quizWifiQ3Explain =>
      'Evil twin attacks create fake hotspots mimicking legitimate networks. Always verify the official network name with staff and use a VPN.';

  @override
  String get quiz2faQ1A4 => 'Having two email accounts';

  @override
  String get quiz2faQ2 => 'Which 2FA method is the most secure?';

  @override
  String get quiz2faQ2A1 =>
      'A hardware key (FIDO2/YubiKey) or authenticator app (TOTP)';

  @override
  String get quiz2faQ2A2 => 'SMS codes sent to your phone';

  @override
  String get quiz2faQ2A3 => 'Email verification links';

  @override
  String get quiz2faQ2A4 => 'Security questions (mother\'s maiden name, etc.)';

  @override
  String get quiz2faQ2Explain =>
      'Hardware keys and TOTP apps are resistant to phishing and SIM-swap attacks. SMS codes can be intercepted via SIM cloning. Security questions are easily guessable from social media.';

  @override
  String get quiz2faQ3 =>
      'You lose your phone with the authenticator app. What should you have prepared?';

  @override
  String get quiz2faQ3A1 => 'Backup recovery codes stored in a safe place';

  @override
  String get quiz2faQ3A2 => 'Nothing - you can always call support';

  @override
  String get quiz2faQ3A3 => 'Another phone with the same app installed';

  @override
  String get quiz2faQ3A4 => 'Your password is enough to recover access';

  @override
  String get quiz2faQ3Explain =>
      'Most services provide one-time backup codes when you set up 2FA. Store them offline (printed or in a password manager) - they are your emergency access if you lose your device.';

  @override
  String get quizBackupQ1 => 'What is the 3-2-1 backup rule?';

  @override
  String get quizBackupQ1A1 =>
      '3 copies of data, on 2 different media types, with 1 copy offsite';

  @override
  String get quizBackupQ1A2 => 'Back up 3 files, 2 times a day, to 1 drive';

  @override
  String get quizBackupQ1A3 => 'Use 3 passwords, 2 accounts, 1 computer';

  @override
  String get quizBackupQ1A4 => '3 antivirus programs, 2 firewalls, 1 VPN';

  @override
  String get quizBackupQ1Explain =>
      'The 3-2-1 rule ensures that no single failure (hardware crash, ransomware, fire) can destroy all your data. Offsite means cloud or a physically separate location.';

  @override
  String get quizBackupQ2 => 'How can ransomware affect your backups?';

  @override
  String get quizBackupQ2A1 =>
      'It can encrypt backups stored on connected drives, making them useless';

  @override
  String get quizBackupQ2A2 =>
      'Ransomware only affects the operating system, not data files';

  @override
  String get quizBackupQ2A3 => 'Backups are immune to ransomware';

  @override
  String get quizBackupQ2A4 => 'Ransomware cannot spread to external drives';

  @override
  String get quizBackupQ2Explain =>
      'Ransomware encrypts everything it can access, including mounted backup drives. Keep at least one backup offline (disconnected) or use versioned cloud backups with immutable snapshots.';

  @override
  String get quizBackupQ3 => 'How often should you test your backups?';

  @override
  String get quizBackupQ3A1 =>
      'Regularly - a backup you\'ve never tested might be corrupted or incomplete';

  @override
  String get quizBackupQ3A2 =>
      'Never - if the backup completed without errors, it works';

  @override
  String get quizBackupQ3A3 => 'Only after a disaster happens';

  @override
  String get quizBackupQ3A4 => 'Once when you first set up the backup';

  @override
  String get quizBackupQ3Explain =>
      'Untested backups may contain corrupted files, missing data, or incompatible formats. Schedule periodic restore tests to verify your recovery process actually works.';

  @override
  String get quizUsbQ1 =>
      'You find a USB drive in the parking lot. What should you do?';

  @override
  String get quizUsbQ1A1 =>
      'Do NOT plug it in - it could contain malware that runs automatically';

  @override
  String get quizUsbQ1A2 =>
      'Plug it in to find the owner\'s contact information';

  @override
  String get quizUsbQ1A3 =>
      'Scan it with antivirus first, then it\'s safe to open';

  @override
  String get quizUsbQ1A4 => 'Format it and use it as your own';

  @override
  String get quizUsbQ1Explain =>
      'USB drop attacks are a real social engineering technique. Malicious USB devices can execute code automatically (BadUSB), install backdoors, or even physically damage hardware (USB Killer).';

  @override
  String get quizUsbQ2 => 'What is a \'BadUSB\' attack?';

  @override
  String get quizUsbQ2A1 =>
      'A USB device that pretends to be a keyboard and types malicious commands';

  @override
  String get quizUsbQ2A2 => 'A broken USB cable that damages your port';

  @override
  String get quizUsbQ2A3 => 'A virus that spreads through USB hubs';

  @override
  String get quizUsbQ2A4 => 'A fake USB charger that charges too slowly';

  @override
  String get quizUsbQ2Explain =>
      'BadUSB reprograms the USB controller firmware to impersonate a keyboard. It can type commands at superhuman speed, downloading and executing malware in seconds.';

  @override
  String get quizUsbQ3 => 'How can you safely use USB drives at work?';

  @override
  String get quizUsbQ3A1 =>
      'Only use company-approved encrypted drives and disable autorun';

  @override
  String get quizUsbQ3A2 =>
      'Any USB drive is fine as long as you scan it first';

  @override
  String get quizUsbQ3A3 => 'Only use drives from trusted colleagues';

  @override
  String get quizUsbQ3A4 => 'USB drives are outdated and never needed';

  @override
  String get quizUsbQ3Explain =>
      'Company-approved encrypted drives prevent data leaks if lost. Disabling autorun stops malware from executing automatically when a drive is inserted.';

  @override
  String get quizPrivacyQ1 =>
      'What information can websites collect about you without cookies?';

  @override
  String get quizPrivacyQ1A1 =>
      'Browser fingerprint: screen resolution, installed fonts, timezone, and more';

  @override
  String get quizPrivacyQ1A2 =>
      'Nothing at all - cookies are the only tracking method';

  @override
  String get quizPrivacyQ1A3 => 'Only your IP address';

  @override
  String get quizPrivacyQ1A4 =>
      'Only the pages you visit on that specific site';

  @override
  String get quizPrivacyQ1Explain =>
      'Browser fingerprinting combines dozens of technical details (screen size, GPU, fonts, timezone, language) into a unique identifier. Even without cookies, ~95% of users can be uniquely identified.';

  @override
  String get quizPrivacyQ2 =>
      'Why should you review app permissions on your phone?';

  @override
  String get quizPrivacyQ2A1 =>
      'Apps may request access to camera, microphone, or contacts beyond what they need';

  @override
  String get quizPrivacyQ2A2 =>
      'Permissions are always necessary for the app to function';

  @override
  String get quizPrivacyQ2A3 => 'It\'s only important for paid apps';

  @override
  String get quizPrivacyQ2A4 => 'Permissions don\'t affect your privacy';

  @override
  String get quizPrivacyQ2Explain =>
      'A flashlight app doesn\'t need access to your contacts or microphone. Excessive permissions may indicate data harvesting. Review and revoke unnecessary permissions regularly.';

  @override
  String get quizPrivacyQ3 =>
      'What is the safest approach to social media privacy?';

  @override
  String get quizPrivacyQ3A1 =>
      'Set profiles to private and limit personal information shared publicly';

  @override
  String get quizPrivacyQ3A2 =>
      'Public profiles are fine - only friends see your posts';

  @override
  String get quizPrivacyQ3A3 => 'Share everything - transparency is modern';

  @override
  String get quizPrivacyQ3A4 => 'Use a fake name and share freely';

  @override
  String get quizPrivacyQ3Explain =>
      'Public profiles expose personal data to social engineering attacks. Attackers use birthdays, pet names, school names to guess passwords and security questions.';

  @override
  String get quizLockQ1 =>
      'Why should your computer lock automatically after a few minutes?';

  @override
  String get quizLockQ1A1 =>
      'Anyone nearby could access your files, email, and accounts while you\'re away';

  @override
  String get quizLockQ1A2 => 'It saves battery power';

  @override
  String get quizLockQ1A3 => 'It prevents the screen from burning in';

  @override
  String get quizLockQ1A4 => 'It\'s only important in offices, not at home';

  @override
  String get quizLockQ1Explain =>
      'An unlocked computer is an open door. In seconds, someone can install malware, copy files, or access your accounts. Set auto-lock to 5 minutes or less.';

  @override
  String get quizLockQ2 => 'Which is the safest way to unlock your computer?';

  @override
  String get quizLockQ2A1 =>
      'Biometrics (fingerprint/face) or a strong PIN combined with TPM';

  @override
  String get quizLockQ2A2 => 'A simple 4-digit PIN like 1234';

  @override
  String get quizLockQ2A3 => 'No password - it\'s faster';

  @override
  String get quizLockQ2A4 => 'A pattern drawn on the screen';

  @override
  String get quizLockQ2Explain =>
      'Windows Hello biometrics + TPM provides strong local authentication. Simple PINs are easily guessable, and patterns can be observed or smudge-traced.';

  @override
  String get quizLockQ3 => 'What is Windows Hello?';

  @override
  String get quizLockQ3A1 =>
      'A built-in authentication system using fingerprint, face recognition, or secure PIN';

  @override
  String get quizLockQ3A2 => 'A greeting message when Windows starts';

  @override
  String get quizLockQ3A3 => 'A voice assistant like Cortana';

  @override
  String get quizLockQ3A4 => 'A parental control feature';

  @override
  String get quizLockQ3Explain =>
      'Windows Hello stores biometric data locally in TPM hardware, not in the cloud. It\'s more secure than passwords because biometrics can\'t be phished or reused across services.';

  @override
  String get quizExtQ1 => 'What risk do browser extensions pose?';

  @override
  String get quizExtQ1A1 =>
      'They can read all data on every page you visit, including passwords and bank details';

  @override
  String get quizExtQ1A2 => 'They only affect the browser\'s appearance';

  @override
  String get quizExtQ1A3 =>
      'Extensions from the official store are always safe';

  @override
  String get quizExtQ1A4 => 'They can slow down the browser but nothing more';

  @override
  String get quizExtQ1Explain =>
      'Extensions with \'Read and change all your data on all websites\' permission can see everything: passwords, credit cards, private messages. Only install extensions you truly need.';

  @override
  String get quizExtQ2 => 'How should you choose which extensions to install?';

  @override
  String get quizExtQ2A1 =>
      'Install only essential ones from known developers, check permissions and reviews';

  @override
  String get quizExtQ2A2 =>
      'Install as many as possible for maximum functionality';

  @override
  String get quizExtQ2A3 => 'Only look at the star rating';

  @override
  String get quizExtQ2A4 => 'Friends\' recommendations are always trustworthy';

  @override
  String get quizExtQ2Explain =>
      'Even popular extensions can be sold to malicious actors who push a trojanized update. Minimize installed extensions, review permissions, and remove ones you no longer use.';

  @override
  String get quizExtQ3 =>
      'An extension you\'ve used for months suddenly requests new permissions. What do you do?';

  @override
  String get quizExtQ3A1 =>
      'Be suspicious - it may have been sold or compromised; research before accepting';

  @override
  String get quizExtQ3A2 =>
      'Accept immediately - updates always need new permissions';

  @override
  String get quizExtQ3A3 => 'Ignore the notification';

  @override
  String get quizExtQ3A4 => 'Uninstall and reinstall to fix the bug';

  @override
  String get quizExtQ3Explain =>
      'Extension ownership can change hands. New owners may add tracking, ad injection, or data theft. Always research why new permissions are needed before granting them.';

  @override
  String get quizEncryptQ1 =>
      'What does full disk encryption (BitLocker) protect against?';

  @override
  String get quizEncryptQ1A1 =>
      'Someone reading your data if the laptop is stolen or the drive is removed';

  @override
  String get quizEncryptQ1A2 => 'Viruses and malware';

  @override
  String get quizEncryptQ1A3 => 'Data loss from hardware failure';

  @override
  String get quizEncryptQ1A4 =>
      'Hackers accessing your computer over the network';

  @override
  String get quizEncryptQ1Explain =>
      'Disk encryption protects data at rest. If someone steals your laptop, they cannot read the drive without your encryption key. It does NOT protect against malware or network attacks.';

  @override
  String get quizEncryptQ2 =>
      'What happens to encrypted data if you forget the recovery key?';

  @override
  String get quizEncryptQ2A1 =>
      'The data becomes permanently inaccessible - there is no backdoor';

  @override
  String get quizEncryptQ2A2 => 'Microsoft can recover it for you';

  @override
  String get quizEncryptQ2A3 =>
      'The data is only temporarily locked for 24 hours';

  @override
  String get quizEncryptQ2A4 => 'You can bypass encryption with Safe Mode';

  @override
  String get quizEncryptQ2Explain =>
      'Strong encryption means even the manufacturer cannot recover your data without the key. Save your BitLocker recovery key in your Microsoft account or print it and store it safely.';

  @override
  String get quizEncryptQ3 =>
      'When should you use encrypted messaging (Signal, WhatsApp)?';

  @override
  String get quizEncryptQ3A1 =>
      'For any sensitive conversations - end-to-end encryption prevents interception';

  @override
  String get quizEncryptQ3A2 => 'Only for illegal activities';

  @override
  String get quizEncryptQ3A3 => 'Regular messaging apps are equally secure';

  @override
  String get quizEncryptQ3A4 => 'Encryption is only needed for businesses';

  @override
  String get quizEncryptQ3Explain =>
      'End-to-end encryption ensures only you and the recipient can read messages. Not even the service provider can access them. Use it for personal, financial, or medical discussions.';

  @override
  String get quizUpdateQ4 =>
      'What is the danger of using End of Life (EOL) software?';

  @override
  String get quizUpdateQ4A1 =>
      'Security patches are no longer released, leaving vulnerabilities permanently open';

  @override
  String get quizUpdateQ4A2 => 'It runs slower than newer versions';

  @override
  String get quizUpdateQ4A3 => 'It takes up more disk space';

  @override
  String get quizUpdateQ4A4 => 'The developer can delete it remotely';

  @override
  String get quizUpdateQ4Explain =>
      'End-of-life software (like Windows 7) no longer receives security updates. All discovered vulnerabilities remain open forever, making the system an easy target for attackers.';

  @override
  String get quizUpdateQ5 => 'What risk does auto-updating carry?';

  @override
  String get quizUpdateQ5A1 =>
      'Minimal - security benefits outweigh rare glitches';

  @override
  String get quizUpdateQ5A2 => 'High - updates always break the system';

  @override
  String get quizUpdateQ5A3 => 'None - updates cannot be tampered with';

  @override
  String get quizUpdateQ5A4 => 'Updates permanently slow down the computer';

  @override
  String get quizUpdateQ5Explain =>
      'Auto-update is best practice: it patches vulnerabilities faster than attackers can exploit them. Rare glitches after updates are easily fixable, but unpatched vulnerabilities are not.';

  @override
  String get quizPasswordQ4 => 'What makes a password truly strong?';

  @override
  String get quizPasswordQ4A1 =>
      'Length of 12+ characters and randomness - not dictionary words or personal data';

  @override
  String get quizPasswordQ4A2 => 'Replacing letters with symbols: P@\$\$w0rd';

  @override
  String get quizPasswordQ4A3 => 'Using your birthdate - easy to remember';

  @override
  String get quizPasswordQ4A4 => 'Short but with an exclamation mark: Go!1';

  @override
  String get quizPasswordQ4Explain =>
      'Length matters more than complexity. A 12-character random lowercase password is stronger than an 8-character one with special characters. Substitutions (@=a, 0=o) have long been in attackers\' dictionaries.';

  @override
  String get quizPasswordQ5 => 'Why is password reuse dangerous?';

  @override
  String get quizPasswordQ5A1 =>
      'A breach on one site gives attackers access to all your accounts';

  @override
  String get quizPasswordQ5A2 => 'Websites will know you\'re the same person';

  @override
  String get quizPasswordQ5A3 => 'The browser will stop saving passwords';

  @override
  String get quizPasswordQ5A4 => 'It\'s prohibited by security policy';

  @override
  String get quizPasswordQ5Explain =>
      'Credential stuffing is an attack where stolen login/password pairs are automatically tested on hundreds of services. If your password is the same everywhere, one breach opens access to everything.';

  @override
  String get quizWifiQ4 => 'What is a captive portal and why is it risky?';

  @override
  String get quizWifiQ4A1 =>
      'A login page on public Wi-Fi - can be spoofed to steal credentials';

  @override
  String get quizWifiQ4A2 => 'A program to speed up Wi-Fi';

  @override
  String get quizWifiQ4A3 => 'A secure hotspot in a cafe';

  @override
  String get quizWifiQ4A4 => 'An antivirus for routers';

  @override
  String get quizWifiQ4Explain =>
      'A captive portal is the login page you see on public Wi-Fi. An attacker can create a fake hotspot with a similar name and spoof the login page to harvest credentials.';

  @override
  String get quizWifiQ5 => 'What advantage does WPA3 have over WPA2?';

  @override
  String get quizWifiQ5A1 =>
      'Protects against traffic interception even with weak passwords thanks to SAE protocol';

  @override
  String get quizWifiQ5A2 => 'Works 3x faster';

  @override
  String get quizWifiQ5A3 => 'Doesn\'t require a password at all';

  @override
  String get quizWifiQ5A4 => 'Supports more devices';

  @override
  String get quizWifiQ5Explain =>
      'WPA3 uses the SAE (Simultaneous Authentication of Equals) protocol, which protects against offline password brute-forcing and KRACK-type attacks. Even with a weak password, intercepting traffic is significantly harder.';

  @override
  String get quizPhishingQ4 => 'What is spear-phishing?';

  @override
  String get quizPhishingQ4A1 =>
      'A targeted phishing attack using the victim\'s personal information';

  @override
  String get quizPhishingQ4A2 => 'Phishing via SMS messages';

  @override
  String get quizPhishingQ4A3 => 'Mass spam mailing';

  @override
  String get quizPhishingQ4A4 => 'Phishing only through social media';

  @override
  String get quizPhishingQ4Explain =>
      'Spear-phishing is a personalized attack: the attacker researches the victim (job title, colleagues, projects) and crafts a convincing message. Its success rate is 10x higher than mass phishing.';

  @override
  String get quizPhishingQ5 =>
      'How can you check if a link is safe before clicking?';

  @override
  String get quizPhishingQ5A1 =>
      'Hover over it and check the domain in the status bar without clicking';

  @override
  String get quizPhishingQ5A2 => 'Click and see what opens';

  @override
  String get quizPhishingQ5A3 => 'Check if the link looks nice';

  @override
  String get quizPhishingQ5A4 => 'Links are always safe if they came by email';

  @override
  String get quizPhishingQ5Explain =>
      'Before clicking, hover over the link - the real URL appears in the browser status bar. Check the domain: gooogle.com, paypa1.com, sberbank-online.xyz are all phishing signs.';

  @override
  String get quizBackupQ4 =>
      'What are versioned backups and why are they important?';

  @override
  String get quizBackupQ4A1 =>
      'Storing multiple file copies from different dates - allows rolling back to a needed version';

  @override
  String get quizBackupQ4A2 => 'Creating a backup every day in the same folder';

  @override
  String get quizBackupQ4A3 => 'Using different passwords for each backup';

  @override
  String get quizBackupQ4A4 =>
      'Copying files from different computers to one drive';

  @override
  String get quizBackupQ4Explain =>
      'Versioned backups store change history. If a file was corrupted a week ago but you noticed only today - you can restore an older version. Without versions, you\'d overwrite good data with damaged data.';

  @override
  String get quizBackupQ5 =>
      'Why are backups critical during a ransomware attack?';

  @override
  String get quizBackupQ5A1 =>
      'They let you restore data without paying the ransom';

  @override
  String get quizBackupQ5A2 => 'Ransomware can\'t infect backups';

  @override
  String get quizBackupQ5A3 => 'Backups automatically remove the virus';

  @override
  String get quizBackupQ5A4 => 'Police use backups to find hackers';

  @override
  String get quizBackupQ5Explain =>
      'Ransomware encrypts your files and demands payment. If you have an offline backup (disconnected from the network), you simply restore your data. Important: a backup on a connected drive can also be encrypted!';

  @override
  String get quizDownloadQ4 =>
      'Why is it dangerous to download from aggregator sites (Softonic, CNET Downloads)?';

  @override
  String get quizDownloadQ4A1 =>
      'They often bundle installers with adware and potentially unwanted programs';

  @override
  String get quizDownloadQ4A2 =>
      'Programs on aggregators always contain viruses';

  @override
  String get quizDownloadQ4A3 => 'They slow down download speed';

  @override
  String get quizDownloadQ4A4 =>
      'Aggregators are not available in all countries';

  @override
  String get quizDownloadQ4Explain =>
      'Aggregators (Softonic, Download.com) often wrap the original installer in their own downloader with adware, toolbars, and potentially unwanted programs. Download directly from the developer\'s website.';

  @override
  String get quizDownloadQ5 => 'How do attackers disguise malicious files?';

  @override
  String get quizDownloadQ5A1 =>
      'Using double extensions: document.pdf.exe appears as PDF';

  @override
  String get quizDownloadQ5A2 => 'Drawing an antivirus icon on it';

  @override
  String get quizDownloadQ5A3 => 'Renaming the file to \'antivirus\'';

  @override
  String get quizDownloadQ5A4 =>
      'They don\'t - users download viruses themselves';

  @override
  String get quizDownloadQ5Explain =>
      'Windows hides known extensions by default. A file \'report.pdf.exe\' displays as \'report.pdf\' with a PDF icon. Enable extension display: Explorer → View → File name extensions.';

  @override
  String get quiz2faQ4 =>
      'Why is an authenticator app better than SMS for 2FA?';

  @override
  String get quiz2faQ4A1 =>
      'SMS can be intercepted via SIM-swap attacks or SS7 vulnerabilities';

  @override
  String get quiz2faQ4A2 => 'The app works offline';

  @override
  String get quiz2faQ4A3 => 'SMS costs money';

  @override
  String get quiz2faQ4A4 => 'The app looks better';

  @override
  String get quiz2faQ4Explain =>
      'SIM-swap: an attacker transfers your number to their SIM card through the carrier. SS7: a telephony protocol vulnerability allows SMS interception. An authenticator (TOTP) generates codes locally on the device.';

  @override
  String get quiz2faQ5 => 'What is TOTP and how does it work?';

  @override
  String get quiz2faQ5A1 =>
      'A one-time code generated every 30 seconds based on a secret key and current time';

  @override
  String get quiz2faQ5A2 => 'A permanent password sent by the server';

  @override
  String get quiz2faQ5A3 => 'Encryption of communication between two devices';

  @override
  String get quiz2faQ5A4 => 'Phone unlock technology using fingerprint';

  @override
  String get quiz2faQ5Explain =>
      'TOTP (Time-based One-Time Password) uses a shared secret key and current time to generate a 6-digit code. The code changes every 30 seconds and works only once - intercepting it is useless.';

  @override
  String get quizUsbQ4 => 'What is a USB Rubber Ducky attack?';

  @override
  String get quizUsbQ4A1 =>
      'A device disguised as a keyboard that instantly types malicious commands';

  @override
  String get quizUsbQ4A2 => 'A virus that wipes flash drive data';

  @override
  String get quizUsbQ4A3 => 'A flash drive with extremely large storage';

  @override
  String get quizUsbQ4A4 => 'A USB device for hacking Wi-Fi';

  @override
  String get quizUsbQ4Explain =>
      'USB Rubber Ducky looks like a regular flash drive, but the computer sees it as a keyboard. In seconds, it \'types\' a script: opens terminal, downloads malware, disables protection - faster than you can notice.';

  @override
  String get quizUsbQ5 =>
      'How can you safely check the contents of an unknown flash drive?';

  @override
  String get quizUsbQ5A1 =>
      'Use an isolated virtual machine or a computer without network access';

  @override
  String get quizUsbQ5A2 =>
      'Insert and quickly look - the virus won\'t have time to infect';

  @override
  String get quizUsbQ5A3 => 'Format the drive before use';

  @override
  String get quizUsbQ5A4 => 'Ask a friend to check on their computer';

  @override
  String get quizUsbQ5Explain =>
      'The safe way is a virtual machine (VirtualBox, Hyper-V) without network access. Even if the drive is infected, the virus stays inside the virtual environment and won\'t harm the main system.';

  @override
  String get quizPrivacyQ4 =>
      'What\'s dangerous about oversharing on social media?';

  @override
  String get quizPrivacyQ4A1 =>
      'Attackers collect data for social engineering and password guessing';

  @override
  String get quizPrivacyQ4A2 => 'Social media slows down from too many posts';

  @override
  String get quizPrivacyQ4A3 => 'Friends might get offended by content';

  @override
  String get quizPrivacyQ4A4 => 'Photos take up server space';

  @override
  String get quizPrivacyQ4Explain =>
      'Birthday, pet\'s name, favorite movie - common answers to security questions. Photo geolocation reveals routines. Trip information signals an empty apartment.';

  @override
  String get quizPrivacyQ5 => 'What do tracking cookies do?';

  @override
  String get quizPrivacyQ5A1 =>
      'Track your behavior across websites to build an advertising profile';

  @override
  String get quizPrivacyQ5A2 => 'Speed up page loading';

  @override
  String get quizPrivacyQ5A3 => 'Protect against viruses';

  @override
  String get quizPrivacyQ5A4 => 'Save website passwords';

  @override
  String get quizPrivacyQ5Explain =>
      'Third-party tracking cookies follow you across thousands of websites, building a detailed profile: interests, purchases, location. Use \'do not track\' mode and regularly clear cookies.';

  @override
  String get quizLockQ4 => 'What keyboard shortcut instantly locks Windows?';

  @override
  String get quizLockQ4A1 =>
      'Win + L - locks the screen instantly without closing programs';

  @override
  String get quizLockQ4A2 => 'Ctrl + Alt + Delete - shuts down the computer';

  @override
  String get quizLockQ4A3 => 'Alt + F4 - locks the current window';

  @override
  String get quizLockQ4A4 => 'Ctrl + Z - pauses the computer';

  @override
  String get quizLockQ4Explain =>
      'Win + L is the fastest way to lock Windows. Building a habit of pressing Win + L every time you leave your seat protects against physical access. Programs continue running.';

  @override
  String get quizLockQ5 => 'What is Dynamic Lock in Windows?';

  @override
  String get quizLockQ5A1 =>
      'Automatic computer lock when your Bluetooth device (phone) moves out of range';

  @override
  String get quizLockQ5A2 => 'Lock with a dynamically changing password';

  @override
  String get quizLockQ5A3 => 'Protection against system file changes';

  @override
  String get quizLockQ5A4 => 'A Windows antivirus feature';

  @override
  String get quizLockQ5Explain =>
      'Dynamic Lock pairs with your phone via Bluetooth. When you walk away and the phone goes out of range, Windows automatically locks the screen in about 30 seconds.';

  @override
  String get quizExtQ4 =>
      'Why is checking browser extension permissions important?';

  @override
  String get quizExtQ4A1 =>
      'An extension with \'access to all sites\' can read your passwords and card data';

  @override
  String get quizExtQ4A2 => 'Permissions affect browser speed';

  @override
  String get quizExtQ4A3 => 'Without permissions the extension won\'t install';

  @override
  String get quizExtQ4A4 => 'Permissions are only needed for paid extensions';

  @override
  String get quizExtQ4Explain =>
      'An extension with \'Read and change data on all sites\' permission has full access to page content - including login forms, banking data, private messages. Grant minimum permissions.';

  @override
  String get quizExtQ5 => 'How can you spot a fake browser extension?';

  @override
  String get quizExtQ5A1 =>
      'Few reviews, no official website link, requests excessive permissions';

  @override
  String get quizExtQ5A2 => 'It has an ugly icon';

  @override
  String get quizExtQ5A3 => 'It\'s free - must be fake';

  @override
  String get quizExtQ5A4 => 'There are no fake extensions in the Chrome Store';

  @override
  String get quizExtQ5Explain =>
      'Signs of a fake: few downloads and reviews, developer name mismatch, excessive permissions, recent publication date. Verify the developer on the official product website.';

  @override
  String get quizEncryptQ4 => 'Why is BitLocker full-disk encryption needed?';

  @override
  String get quizEncryptQ4A1 =>
      'Protects all disk data if the laptop is stolen or lost';

  @override
  String get quizEncryptQ4A2 => 'Speeds up disk reads';

  @override
  String get quizEncryptQ4A3 => 'Prevents virus infections';

  @override
  String get quizEncryptQ4A4 => 'Only needed for servers';

  @override
  String get quizEncryptQ4Explain =>
      'Without BitLocker, removing the disk from a laptop and connecting it to another computer gives full access to all files. With BitLocker, data is encrypted and useless without the key tied to the TPM module.';

  @override
  String get quizEncryptQ5 => 'What\'s the difference between HTTP and HTTPS?';

  @override
  String get quizEncryptQ5A1 =>
      'HTTPS encrypts traffic between browser and server; HTTP transmits data in plain text';

  @override
  String get quizEncryptQ5A2 => 'HTTPS is faster';

  @override
  String get quizEncryptQ5A3 => 'HTTP is for computers, HTTPS is for phones';

  @override
  String get quizEncryptQ5A4 => 'No difference - they\'re the same';

  @override
  String get quizEncryptQ5Explain =>
      'HTTPS uses TLS encryption: everything you send (passwords, card data) is encrypted. In HTTP, data is sent in plain text - anyone on the same network can intercept it. Never enter passwords on HTTP sites.';

  @override
  String get enableAllProtection => 'Enable All Protection';

  @override
  String get enableAllProtectionDesc =>
      'Activate all protection modules with one click';

  @override
  String get allProtectionEnabled => 'All protection modules enabled';

  @override
  String get disableAllProtection => 'Disable All Protection';

  @override
  String get allProtectionDisabled => 'All protection modules disabled';

  @override
  String get threatRemediationTitle => 'How to Remove';

  @override
  String get threatInfectionVectorsTitle => 'How It Got Here';

  @override
  String get threatPreventionTitle => 'How to Prevent';

  @override
  String get threatRemTrojan =>
      '1. Quarantine or delete the file.\n2. Change passwords if the trojan could have intercepted them.\n3. Check startup programs (Win+R → msconfig → Startup).\n4. Run a full computer scan.';

  @override
  String get threatRemAdware =>
      '1. Uninstall the suspicious program via Settings → Apps.\n2. Reset browser settings.\n3. Check browser extensions and remove unknown ones.\n4. Clear temporary files.';

  @override
  String get threatRemPup =>
      '1. Uninstall the program via Settings → Apps.\n2. Check if browser settings changed (home page, search engine).\n3. Remove associated browser extensions.';

  @override
  String get threatRemWorm =>
      '1. Immediately disconnect the computer from the network.\n2. Delete the file and run a full scan.\n3. Check all connected devices and flash drives.\n4. Change passwords for network accounts.';

  @override
  String get threatRemRansom =>
      '1. DO NOT pay the ransom - it doesn\'t guarantee file recovery.\n2. Disconnect the computer from the network.\n3. Check for available backups.\n4. Consult a cybersecurity specialist.';

  @override
  String get threatRemGeneric =>
      '1. Quarantine the file for safe storage.\n2. Run a full computer scan.\n3. Check the system for other suspicious files.';

  @override
  String get threatVecTrojan =>
      '• Downloading pirated software or cracks\n• Attachments in phishing emails\n• Fake software updates on websites\n• Infected USB drives';

  @override
  String get threatVecAdware =>
      '• Installing free software with bundled components\n• Clicking deceptive ads\n• Downloading from unverified sources';

  @override
  String get threatVecPup =>
      '• Using \'Express\' install instead of \'Custom\'\n• Bundles during free software installation\n• Deceptive \'Download\' buttons on websites';

  @override
  String get threatVecWorm =>
      '• Vulnerabilities in network services\n• Infected files on local network\n• Autorun from USB devices\n• Exploits via unpatched software';

  @override
  String get threatVecRansom =>
      '• Phishing emails with infected attachments\n• Exploit kits on compromised websites\n• RDP vulnerabilities (remote access)\n• Pirated software with embedded ransomware';

  @override
  String get threatVecGeneric =>
      '• Downloading files from unverified sources\n• Clicking suspicious links\n• Connecting infected external devices';

  @override
  String get threatPrevTrojan =>
      '• Download software only from official websites\n• Don\'t open attachments from unknown senders\n• Keep your system and antivirus updated\n• Enable two-factor authentication on important accounts';

  @override
  String get threatPrevAdware =>
      '• Always choose \'Custom\' installation\n• Don\'t click suspicious ads and banners\n• Use an ad blocker in your browser';

  @override
  String get threatPrevPup =>
      '• Read installation terms and uncheck additional programs\n• Download software only from official websites\n• Use a package manager (winget, chocolatey)';

  @override
  String get threatPrevWorm =>
      '• Regularly install security updates\n• Use a firewall and don\'t disable it\n• Disable USB autorun\n• Don\'t connect unknown flash drives';

  @override
  String get threatPrevRansom =>
      '• Regularly create backups (3-2-1 rule)\n• Don\'t open suspicious attachments\n• Disable RDP if not in use\n• Keep OS and software updated';

  @override
  String get threatPrevGeneric =>
      '• Use antivirus with up-to-date databases\n• Don\'t download files from unverified sources\n• Regularly update your operating system\n• Be cautious with email attachments';

  @override
  String get scanPause => 'Pause';

  @override
  String get scanResume => 'Resume';

  @override
  String get scanPaused => 'Scan paused';

  @override
  String get quizSuggestionTitle => 'Learning Moment';

  @override
  String get quizSuggestionWeb =>
      'You encountered a phishing site. Take a quiz to better recognize such threats!';

  @override
  String get quizSuggestionScan =>
      'A threat was found during scanning. Learn how to prevent infections!';

  @override
  String get quizSuggestionDownload =>
      'A dangerous file was detected. Take a quiz about safe file downloads!';

  @override
  String get quizSuggestionProtection =>
      'You disabled protection. Learn why keeping your system up to date is important!';

  @override
  String get quizSuggestionAction => 'Take Quiz';

  @override
  String get quizSuggestionDismiss => 'Later';

  @override
  String get quizLastResult => 'Last result';

  @override
  String get quizBestResult => 'Best result';

  @override
  String quizAttempts(int count) {
    return '$count attempts';
  }

  @override
  String get quizNeverTaken => 'Not taken';

  @override
  String get hygieneBackupDescBeginner =>
      'Copy important files (photos, documents) to a flash drive or cloud. If your computer breaks or a virus encrypts files - you\'ll have a copy.';

  @override
  String get hygieneBackupDescAdvanced =>
      'Follow the 3-2-1 rule: 3 copies, 2 different media, 1 offsite. Automate via task scheduler. Verify backup integrity regularly.';

  @override
  String get hygieneUsbDescBeginner =>
      'Never plug in found USB drives. Viruses can spread through them automatically, even without you clicking anything.';

  @override
  String get hygieneUsbDescAdvanced =>
      'USB devices can emulate keyboards (Rubber Ducky) and execute commands. Use group policies to restrict USB. Check devices in an isolated environment.';

  @override
  String get hygienePrivacyDescBeginner =>
      'Don\'t post your address, phone number, or workplace on social media. Scammers collect such data for targeted attacks.';

  @override
  String get hygienePrivacyDescAdvanced =>
      'Minimize your digital footprint: disable geolocation in photos, use different emails for different services, set up DNS-over-HTTPS.';

  @override
  String get hygieneLockDescBeginner =>
      'Always lock your computer when you step away: Win+L. Without locking, anyone can view your files or install a virus.';

  @override
  String get hygieneLockDescAdvanced =>
      'Use Windows Hello (biometrics) + Dynamic Lock (auto-lock when phone leaves). Set screen timeout to 1-2 minutes.';

  @override
  String get hygieneExtensionsDescBeginner =>
      'Only install extensions from the official Chrome/Firefox store. Check reviews and user count before installing.';

  @override
  String get hygieneExtensionsDescAdvanced =>
      'Audit extension permissions: if a calculator asks for access to \'all sites\' - that\'s a red flag. Regularly review your extension list.';

  @override
  String get hygieneEncryptionDescBeginner =>
      'Enable BitLocker on your Windows drive - if your laptop is stolen, data will be protected. Settings → Privacy → Encryption.';

  @override
  String get hygieneEncryptionDescAdvanced =>
      'Use full-disk encryption (BitLocker/VeraCrypt). For sensitive files - container encryption. Store recovery keys in a secure location.';

  @override
  String get threatWhatItDoesTitle => 'What This Threat Does';

  @override
  String get threatDescriptionTitle => 'Detailed Description';

  @override
  String get threatEduLevelSignature =>
      'Data from knowledge base (exact match)';

  @override
  String get threatEduLevelFamily => 'Data from threat family (similar threat)';

  @override
  String get quizUpdateQ6 =>
      'Why is it important to update not only the OS but also browsers?';

  @override
  String get quizUpdateQ6A1 =>
      'Browsers are the main attack target - you visit sites and download files through them';

  @override
  String get quizUpdateQ6A2 => 'Browser updates only add bookmarks';

  @override
  String get quizUpdateQ6A3 => 'Browsers don\'t need updates';

  @override
  String get quizUpdateQ6A4 => 'Updating the browser changes the search engine';

  @override
  String get quizUpdateQ6Explain =>
      'The browser is the most attacked program: it processes JavaScript, renders HTML/CSS, and handles networking. Vulnerabilities in Chrome/Firefox are discovered weekly.';

  @override
  String get quizUpdateQ7 =>
      'What happens if you postpone a Windows update for a month?';

  @override
  String get quizUpdateQ7A1 =>
      'The system remains vulnerable to already-patched attacks that are actively exploited';

  @override
  String get quizUpdateQ7A2 => 'Nothing serious - a month isn\'t critical';

  @override
  String get quizUpdateQ7A3 => 'Windows will stop working after a month';

  @override
  String get quizUpdateQ7A4 => 'Microsoft will block your license';

  @override
  String get quizUpdateQ7Explain =>
      'Attackers study patches and create exploits within days. Every day without an update increases risk. Attacks on known CVEs are the most common infection vector.';

  @override
  String get quizUpdateQ8 => 'What is a supply chain attack?';

  @override
  String get quizUpdateQ8A1 =>
      'An attacker injects malicious code into a legitimate update from the developer';

  @override
  String get quizUpdateQ8A2 => 'Delayed delivery of an update by mail';

  @override
  String get quizUpdateQ8A3 => 'Downloading updates from a slow server';

  @override
  String get quizUpdateQ8A4 => 'Developer refusing to release updates';

  @override
  String get quizUpdateQ8Explain =>
      'SolarWinds attack (2020): hackers embedded a backdoor in a popular software update. 18,000 organizations installed the infected update. Rare but devastating.';

  @override
  String get quizUpdateQ9 =>
      'How can you check that all programs on your computer are updated?';

  @override
  String get quizUpdateQ9A1 =>
      'Use an audit utility (Winget upgrade) or each program\'s built-in update check';

  @override
  String get quizUpdateQ9A2 => 'Check the install date in Control Panel';

  @override
  String get quizUpdateQ9A3 => 'If the program opens - it\'s updated';

  @override
  String get quizUpdateQ9A4 => 'Reinstall all programs once a year';

  @override
  String get quizUpdateQ9Explain =>
      'Winget (built into Windows 11) can mass-update all programs with one command. Manual checking is ineffective - automate the process.';

  @override
  String get quizUpdateQ10 =>
      'What are firmware updates and why are they important?';

  @override
  String get quizUpdateQ10A1 =>
      'Updates for device embedded software (BIOS, router) - they patch hardware-level vulnerabilities';

  @override
  String get quizUpdateQ10A2 => 'Updates to the device case design';

  @override
  String get quizUpdateQ10A3 => 'Installing a new processor';

  @override
  String get quizUpdateQ10A4 =>
      'Firmware updates automatically and needs no attention';

  @override
  String get quizUpdateQ10Explain =>
      'A router firmware vulnerability can allow interception of all home traffic. BIOS/UEFI firmware affects security even before the OS loads.';

  @override
  String get quizPasswordQ6 =>
      'What is a passkey and why is it better than a password?';

  @override
  String get quizPasswordQ6A1 =>
      'A cryptographic key on the device - impossible to brute-force or steal via phishing';

  @override
  String get quizPasswordQ6A2 => 'A very long password of 100 characters';

  @override
  String get quizPasswordQ6A3 => 'A password written on a physical key';

  @override
  String get quizPasswordQ6A4 => 'A biometric iris scan';

  @override
  String get quizPasswordQ6Explain =>
      'Passkey (FIDO2) is a cryptographic key pair. The private key never leaves the device; the server only stores the public one. Phishing is impossible: the key is bound to the domain.';

  @override
  String get quizPasswordQ7 => 'Why are security questions a weak protection?';

  @override
  String get quizPasswordQ7A1 =>
      'Answers can often be found on social media or guessed';

  @override
  String get quizPasswordQ7A2 => 'There are too few questions for reliability';

  @override
  String get quizPasswordQ7A3 => 'They only work in English';

  @override
  String get quizPasswordQ7A4 => 'Servers don\'t encrypt the answers';

  @override
  String get quizPasswordQ7Explain =>
      'Mother\'s maiden name, pet\'s name - all on social media. In 2008, Sarah Palin\'s Yahoo account was hacked via a security question. Use random answers and store them in a password manager.';

  @override
  String get quizPasswordQ8 => 'What is a brute force attack?';

  @override
  String get quizPasswordQ8A1 =>
      'Automated testing of all password combinations until the correct one is found';

  @override
  String get quizPasswordQ8A2 =>
      'Physically destroying a computer to extract data';

  @override
  String get quizPasswordQ8A3 =>
      'Using force to obtain a password from the owner';

  @override
  String get quizPasswordQ8A4 =>
      'A virus that deletes all passwords from the system';

  @override
  String get quizPasswordQ8Explain =>
      'In brute force, a program tests billions of combinations per second. A 6-character password - seconds; 12+ random characters - thousands of years. Length is the best defense.';

  @override
  String get quizPasswordQ9 =>
      'How can you check if your password has been leaked?';

  @override
  String get quizPasswordQ9A1 =>
      'Use Have I Been Pwned - it checks your email against breach databases';

  @override
  String get quizPasswordQ9A2 => 'Try logging into all accounts';

  @override
  String get quizPasswordQ9A3 => 'Call your email provider';

  @override
  String get quizPasswordQ9A4 => 'Password leaks cannot be detected';

  @override
  String get quizPasswordQ9Explain =>
      'Have I Been Pwned contains billions of breached records. Password managers (Bitwarden, 1Password) also warn about leaks automatically.';

  @override
  String get quizPasswordQ10 =>
      'Why is it dangerous to send passwords through messengers?';

  @override
  String get quizPasswordQ10A1 =>
      'Messages may be stored on the server or read on a compromised device';

  @override
  String get quizPasswordQ10A2 =>
      'Messengers compress text and the password may change';

  @override
  String get quizPasswordQ10A3 => 'Passwords can\'t be copied from messengers';

  @override
  String get quizPasswordQ10A4 => 'It\'s safe in an encrypted messenger';

  @override
  String get quizPasswordQ10Explain =>
      'Even in an encrypted messenger, the password is visible on the recipient\'s screen. If their device is compromised - the password is compromised. Use password managers with secure sharing.';

  @override
  String get quizWifiQ6 =>
      'Is it safe to make online purchases on public Wi-Fi?';

  @override
  String get quizWifiQ6A1 =>
      'Better to wait - even with HTTPS, a DNS attack can substitute the site';

  @override
  String get quizWifiQ6A2 => 'Yes, HTTPS fully protects transactions';

  @override
  String get quizWifiQ6A3 => 'Yes, if the purchase amount is small';

  @override
  String get quizWifiQ6A4 => 'Only through Wi-Fi without a password';

  @override
  String get quizWifiQ6Explain =>
      'HTTPS protects data but not from DNS spoofing or compromised certificates. For financial operations, use mobile data or a VPN.';

  @override
  String get quizWifiQ7 => 'How do you protect a home Wi-Fi router?';

  @override
  String get quizWifiQ7A1 =>
      'Change the factory password, use WPA3, update firmware, disable WPS';

  @override
  String get quizWifiQ7A2 => 'A complex Wi-Fi password is sufficient';

  @override
  String get quizWifiQ7A3 => 'Hide the router - weak signal = security';

  @override
  String get quizWifiQ7A4 => 'Home Wi-Fi doesn\'t need protection';

  @override
  String get quizWifiQ7Explain =>
      'Factory router passwords are known from databases. WPS has vulnerabilities. A combination: unique admin password + WPA3 + fresh firmware + WPS disabled.';

  @override
  String get quizWifiQ8 => 'What is an Evil Twin attack on Wi-Fi?';

  @override
  String get quizWifiQ8A1 =>
      'A fake access point with the same name to intercept traffic';

  @override
  String get quizWifiQ8A2 => 'Two routers conflicting with each other';

  @override
  String get quizWifiQ8A3 => 'A virus that clones a laptop via Wi-Fi';

  @override
  String get quizWifiQ8A4 => 'Connecting two devices to one network';

  @override
  String get quizWifiQ8Explain =>
      'The attacker creates an access point with the name of a real network. Your device connects automatically. All traffic passes through the attacker.';

  @override
  String get quizWifiQ9 =>
      'Why doesn\'t hiding the network name (SSID) protect Wi-Fi?';

  @override
  String get quizWifiQ9A1 =>
      'Hidden networks are easily discovered with special tools - it\'s a security illusion';

  @override
  String get quizWifiQ9A2 =>
      'Hiding SSID is the most reliable protection method';

  @override
  String get quizWifiQ9A3 => 'Hidden networks work slower';

  @override
  String get quizWifiQ9A4 => 'You can\'t connect to a hidden network';

  @override
  String get quizWifiQ9Explain =>
      'Airodump-ng discovers hidden networks in seconds - the name is transmitted in probe requests. Instead of hiding, use WPA3 and up-to-date firmware.';

  @override
  String get quizWifiQ10 => 'What is MAC filtering and why is it unreliable?';

  @override
  String get quizWifiQ10A1 =>
      'Restricting access by MAC address - easily bypassed since MAC can be spoofed';

  @override
  String get quizWifiQ10A2 => 'Filtering malicious websites';

  @override
  String get quizWifiQ10A3 => 'Blocking Apple devices from connecting';

  @override
  String get quizWifiQ10A4 => 'Router antivirus feature';

  @override
  String get quizWifiQ10Explain =>
      'The MAC address is transmitted in plain text. An attacker intercepts an allowed MAC and clones it in seconds. This is security through obscurity, not real protection.';

  @override
  String get quizPhishingQ6 => 'What is vishing?';

  @override
  String get quizPhishingQ6A1 =>
      'Phone phishing - a call from a \'bank\' to extract data';

  @override
  String get quizPhishingQ6A2 => 'Visual phishing through images';

  @override
  String get quizPhishingQ6A3 => 'Phishing through video calls';

  @override
  String get quizPhishingQ6A4 => 'Sending viruses through voice messages';

  @override
  String get quizPhishingQ6Explain =>
      'Vishing uses calls with spoofed numbers. The scammer creates urgency: \'Your account is blocked, tell us the SMS code.\' Banks never ask for codes over the phone.';

  @override
  String get quizPhishingQ7 => 'What is smishing?';

  @override
  String get quizPhishingQ7A1 =>
      'Phishing via SMS - a link to a fake site in a text message';

  @override
  String get quizPhishingQ7A2 => 'Phishing through smartwatches';

  @override
  String get quizPhishingQ7A3 => 'Sending viruses via Bluetooth';

  @override
  String get quizPhishingQ7A4 => 'SMS message encryption';

  @override
  String get quizPhishingQ7Explain =>
      'Typical smishing: \'Your package is delayed, follow the link.\' The link leads to a fake site. Don\'t follow links from SMS.';

  @override
  String get quizPhishingQ8 =>
      'How to recognize a phishing email besides checking the domain?';

  @override
  String get quizPhishingQ8A1 =>
      'Urgency, threats, errors, impersonal greeting, suspicious attachments';

  @override
  String get quizPhishingQ8A2 => 'Phishing emails always contain errors';

  @override
  String get quizPhishingQ8A3 => 'Phishing is only possible through email';

  @override
  String get quizPhishingQ8A4 => 'Emails from acquaintances are always safe';

  @override
  String get quizPhishingQ8Explain =>
      'Red flags: \'Urgent!\', \'Account blocked\', impersonal greeting. AI generates convincing texts. Check the sender, links, and request logic.';

  @override
  String get quizPhishingQ9 =>
      'What is a BEC attack (Business Email Compromise)?';

  @override
  String get quizPhishingQ9A1 =>
      'A fake email from a manager requesting a money transfer';

  @override
  String get quizPhishingQ9A2 => 'Hacking email to send spam';

  @override
  String get quizPhishingQ9A3 => 'Encrypting corporate correspondence';

  @override
  String get quizPhishingQ9A4 => 'Sorting business emails';

  @override
  String get quizPhishingQ9Explain =>
      'BEC is one of the most expensive attacks (average loss \$120,000). The attacker waits for a payment moment and sends an email with changed details. Confirm transfers by phone.';

  @override
  String get quizPhishingQ10 =>
      'What to do if you accidentally clicked a phishing link?';

  @override
  String get quizPhishingQ10A1 =>
      'Don\'t enter data, close the page, change passwords, run antivirus scan';

  @override
  String get quizPhishingQ10A2 => 'Nothing - the virus is already installed';

  @override
  String get quizPhishingQ10A3 => 'Restart the computer';

  @override
  String get quizPhishingQ10A4 => 'Send the scammers a reply email';

  @override
  String get quizPhishingQ10Explain =>
      'The click itself is usually not dangerous - entering data is. If you didn\'t enter anything - close the page. If you entered a password - change it and enable 2FA.';

  @override
  String get quizBackupQ6 =>
      'What\'s the difference between full and incremental backup?';

  @override
  String get quizBackupQ6A1 =>
      'Full copies everything, incremental - only changes since the last backup';

  @override
  String get quizBackupQ6A2 =>
      'Full backup is larger but incremental is unreliable';

  @override
  String get quizBackupQ6A3 => 'Incremental is the same thing, just faster';

  @override
  String get quizBackupQ6A4 => 'Full backup only works on external drives';

  @override
  String get quizBackupQ6Explain =>
      'Incremental backup saves time and space. Optimal strategy: full backup weekly + daily incrementals.';

  @override
  String get quizBackupQ7 => 'Why is it important to encrypt backups?';

  @override
  String get quizBackupQ7A1 =>
      'An unencrypted backup on a stolen drive gives access to all data';

  @override
  String get quizBackupQ7A2 => 'Encryption speeds up recovery';

  @override
  String get quizBackupQ7A3 => 'Encryption is required by law';

  @override
  String get quizBackupQ7A4 => 'Without encryption, backups corrupt faster';

  @override
  String get quizBackupQ7Explain =>
      'If an external drive is stolen or a cloud account is hacked - unencrypted backup means full data access. BitLocker or cloud encryption solves this.';

  @override
  String get quizBackupQ8 => 'What is an air-gapped backup?';

  @override
  String get quizBackupQ8A1 =>
      'A backup on media physically disconnected from the network and computer';

  @override
  String get quizBackupQ8A2 => 'Backup on an airplane';

  @override
  String get quizBackupQ8A3 => 'Wireless backup over Wi-Fi';

  @override
  String get quizBackupQ8A4 => 'Cloud backup with VPN';

  @override
  String get quizBackupQ8Explain =>
      'Air-gapped backup is a drive connected only during copying. Ransomware can\'t encrypt a disconnected drive. The most reliable ransomware protection.';

  @override
  String get quizBackupQ9 => 'How often should you make backups?';

  @override
  String get quizBackupQ9A1 =>
      'Depends on data value: daily for important, weekly for the rest';

  @override
  String get quizBackupQ9A2 => 'Once a year is enough';

  @override
  String get quizBackupQ9A3 => 'Only before reinstalling the system';

  @override
  String get quizBackupQ9A4 => 'Once when buying the computer';

  @override
  String get quizBackupQ9Explain =>
      'Think: how much work can you afford to lose? If losing a day is critical - backup daily. Automate: manual backups get forgotten.';

  @override
  String get quizBackupQ10 => 'What to do if a backup can\'t be restored?';

  @override
  String get quizBackupQ10A1 =>
      'The backup is corrupted - you should have tested restoration beforehand';

  @override
  String get quizBackupQ10A2 => 'Try again in a week';

  @override
  String get quizBackupQ10A3 => 'Backups always restore successfully';

  @override
  String get quizBackupQ10A4 => 'Contact the drive manufacturer\'s support';

  @override
  String get quizBackupQ10Explain =>
      'An untested backup is not a backup. Test restoration monthly. Corrupted sectors, outdated formats, forgotten passwords - all discovered only during testing.';

  @override
  String get quizDownloadQ6 => 'What is a sandbox?';

  @override
  String get quizDownloadQ6A1 =>
      'An isolated environment where a program can\'t harm the main system';

  @override
  String get quizDownloadQ6A2 => 'An antivirus program';

  @override
  String get quizDownloadQ6A3 => 'A special folder on the desktop';

  @override
  String get quizDownloadQ6A4 => 'A file archiving program';

  @override
  String get quizDownloadQ6Explain =>
      'Windows Sandbox creates a disposable virtual Windows copy. Run a suspicious file - after closing, all changes disappear.';

  @override
  String get quizDownloadQ7 => 'How do you verify a file by hash?';

  @override
  String get quizDownloadQ7A1 =>
      'Compare the SHA-256 hash of the file with the one listed on the developer\'s website';

  @override
  String get quizDownloadQ7A2 => 'Open the file and check the contents';

  @override
  String get quizDownloadQ7A3 => 'Rename the file and check its size';

  @override
  String get quizDownloadQ7A4 =>
      'The hash is checked automatically by the browser';

  @override
  String get quizDownloadQ7Explain =>
      'SHA-256 is a digital fingerprint of the file. Changing one byte completely changes the hash. In Windows: certutil -hashfile file.exe SHA256.';

  @override
  String get quizDownloadQ8 => 'What does Windows SmartScreen do?';

  @override
  String get quizDownloadQ8A1 =>
      'Warns when running unknown or unsigned programs downloaded from the internet';

  @override
  String get quizDownloadQ8A2 => 'Blocks all downloads';

  @override
  String get quizDownloadQ8A3 => 'Checks RAM';

  @override
  String get quizDownloadQ8A4 => 'Filters ads in the browser';

  @override
  String get quizDownloadQ8Explain =>
      'SmartScreen checks file reputation. A warning doesn\'t mean a virus, but the file is unknown to the system. Proceed with caution.';

  @override
  String get quizDownloadQ9 =>
      'Why are cracks and keygens especially dangerous?';

  @override
  String get quizDownloadQ9A1 =>
      '90%+ contain malware: trojans, miners, spyware';

  @override
  String get quizDownloadQ9A2 => 'They slow down the computer';

  @override
  String get quizDownloadQ9A3 => 'They\'re illegal but technically safe';

  @override
  String get quizDownloadQ9A4 => 'Antivirus programs solved this long ago';

  @override
  String get quizDownloadQ9Explain =>
      'The victim disables antivirus themselves and runs the malware with admin rights. Cracks contain: stealer trojans, cryptominers, and RATs (remote access).';

  @override
  String get quizDownloadQ10 => 'What to do if the browser blocked a download?';

  @override
  String get quizDownloadQ10A1 =>
      'Don\'t ignore it - verify the source and necessity of the file';

  @override
  String get quizDownloadQ10A2 => 'Switch to an unprotected browser';

  @override
  String get quizDownloadQ10A3 => 'Browsers are too cautious - always ignore';

  @override
  String get quizDownloadQ10A4 => 'Disable protection permanently';

  @override
  String get quizDownloadQ10Explain =>
      'Browsers block based on reputation and signatures. If a file is blocked - it\'s a serious signal. Verify the source before proceeding.';

  @override
  String get quiz2faQ6 => 'Can two-factor authentication be bypassed?';

  @override
  String get quiz2faQ6A1 =>
      'Yes - through real-time phishing or SIM-swap, that\'s why the 2FA method matters';

  @override
  String get quiz2faQ6A2 => 'No, 2FA is absolutely impenetrable';

  @override
  String get quiz2faQ6A3 => 'Only intelligence agencies can bypass 2FA';

  @override
  String get quiz2faQ6A4 => '2FA protects against all attacks';

  @override
  String get quiz2faQ6Explain =>
      'Phishing proxies intercept 2FA codes in real time. SIM-swap redirects SMS. Hardware FIDO2 keys are resistant to these attacks.';

  @override
  String get quiz2faQ7 => 'What is a hardware security key (YubiKey)?';

  @override
  String get quiz2faQ7A1 =>
      'A physical device for authentication, resistant to phishing';

  @override
  String get quiz2faQ7A2 => 'A USB drive with passwords';

  @override
  String get quiz2faQ7A3 => 'A hard drive encryption key';

  @override
  String get quiz2faQ7A4 => 'A key fob for unlocking a car';

  @override
  String get quiz2faQ7Explain =>
      'A FIDO2 key is cryptographically bound to the domain. Even on a perfect phishing site, the key will refuse to authenticate. Phishing is physically impossible.';

  @override
  String get quiz2faQ8 => 'Why is it important to enable 2FA on email first?';

  @override
  String get quiz2faQ8A1 =>
      'Email is the key to all accounts: passwords are reset through it';

  @override
  String get quiz2faQ8A2 => 'Email is the most popular service';

  @override
  String get quiz2faQ8A3 => 'You can\'t send email without 2FA';

  @override
  String get quiz2faQ8A4 =>
      '2FA on email is less important than on social media';

  @override
  String get quiz2faQ8Explain =>
      'If an attacker gains access to your email, they can reset passwords for all linked accounts. Email is the master key of your digital life. 2FA on email is priority #1.';

  @override
  String get quiz2faQ9 => 'What are backup codes and where to store them?';

  @override
  String get quiz2faQ9A1 =>
      'One-time codes for login when 2FA device is lost - in a password manager or safe';

  @override
  String get quiz2faQ9A2 => 'Codes for file recovery';

  @override
  String get quiz2faQ9A3 => 'Just remember one code';

  @override
  String get quiz2faQ9A4 => 'Backup codes last forever';

  @override
  String get quiz2faQ9Explain =>
      'The service issues 8-10 one-time codes. Store in a password manager or print them. Without them, losing your phone = losing access.';

  @override
  String get quiz2faQ10 => 'Should you enable 2FA on all accounts?';

  @override
  String get quiz2faQ10A1 =>
      'Yes - especially on email, banking, cloud, and social media';

  @override
  String get quiz2faQ10A2 => 'Only on banking accounts';

  @override
  String get quiz2faQ10A3 => '2FA is too inconvenient';

  @override
  String get quiz2faQ10A4 => 'One main account is enough';

  @override
  String get quiz2faQ10Explain =>
      'Hacking an \'unimportant\' account is dangerous with reused passwords. 2FA makes hacking exponentially harder. Minimum: email + bank + cloud + social media.';

  @override
  String get quizUsbQ6 => 'What is a USB Killer?';

  @override
  String get quizUsbQ6A1 =>
      'A device that sends an electrical discharge through the USB port, destroying hardware';

  @override
  String get quizUsbQ6A2 => 'An antivirus for USB drives';

  @override
  String get quizUsbQ6A3 => 'A safe removal program';

  @override
  String get quizUsbQ6A4 => 'A virus that erases data from flash drives';

  @override
  String get quizUsbQ6Explain =>
      'USB Killer charges capacitors and discharges 200+ volts back into the port. Result: a burned motherboard. Don\'t insert unknown USB devices.';

  @override
  String get quizUsbQ7 => 'How to protect against autorun of malware from USB?';

  @override
  String get quizUsbQ7A1 =>
      'Disable autorun in Windows and check flash drive contents manually';

  @override
  String get quizUsbQ7A2 => 'Autorun is safe in modern Windows';

  @override
  String get quizUsbQ7A3 => 'Using USB 3.0 is enough';

  @override
  String get quizUsbQ7A4 => 'Format every flash drive before use';

  @override
  String get quizUsbQ7Explain =>
      'AutoRun for USB is disabled by default, but AutoPlay may suggest actions. Settings → Devices → AutoPlay → Off. Scan new USB drives with antivirus.';

  @override
  String get quizUsbQ8 => 'What is juice jacking (USB charging attack)?';

  @override
  String get quizUsbQ8A1 =>
      'Data theft through a public USB charging station disguised as a regular one';

  @override
  String get quizUsbQ8A2 => 'Electricity theft through USB';

  @override
  String get quizUsbQ8A3 => 'Phone overheating from charging';

  @override
  String get quizUsbQ8A4 => 'Using someone else\'s charger';

  @override
  String get quizUsbQ8Explain =>
      'USB carries both power and data. A modified station can read data or install malware. Use your own power adapter or a data blocker.';

  @override
  String get quizUsbQ9 =>
      'What\'s a safe way to transfer files instead of USB?';

  @override
  String get quizUsbQ9A1 =>
      'Cloud storage or transfer via encrypted channel (Wi-Fi Direct, AirDrop)';

  @override
  String get quizUsbQ9A2 => 'Bluetooth - it\'s always safe';

  @override
  String get quizUsbQ9A3 => 'Email without restrictions';

  @override
  String get quizUsbQ9A4 => 'There are no safe alternatives';

  @override
  String get quizUsbQ9Explain =>
      'Cloud services scan files with antivirus. Wi-Fi Direct, AirDrop, Nearby Share are encrypted and don\'t require physical media.';

  @override
  String get quizUsbQ10 => 'Why is physical security of USB ports important?';

  @override
  String get quizUsbQ10A1 =>
      'An attacker can quickly insert a malicious device while you\'re away';

  @override
  String get quizUsbQ10A2 => 'USB ports wear out';

  @override
  String get quizUsbQ10A3 => 'Antivirus will stop everything';

  @override
  String get quizUsbQ10A4 => 'Ports need to be covered from dust';

  @override
  String get quizUsbQ10Explain =>
      'Inserting a BadUSB takes a second. On critical computers, use USB blockers or GPO policies restricting new device connections.';

  @override
  String get quizPrivacyQ6 => 'What is a digital footprint?';

  @override
  String get quizPrivacyQ6A1 =>
      'The totality of all your internet activity - virtually impossible to fully delete';

  @override
  String get quizPrivacyQ6A2 => 'Traces from downloading files';

  @override
  String get quizPrivacyQ6A3 => 'A fingerprint on the screen';

  @override
  String get quizPrivacyQ6A4 =>
      'Clearing browser history deletes your digital footprint';

  @override
  String get quizPrivacyQ6Explain =>
      'Every post, like, purchase forms a digital footprint. Even deleted posts are saved in caches and web archives. Don\'t post what you don\'t want to see public in 10 years.';

  @override
  String get quizPrivacyQ7 =>
      'Why use different emails for different purposes?';

  @override
  String get quizPrivacyQ7A1 =>
      'Compromise of one address won\'t affect others - account isolation';

  @override
  String get quizPrivacyQ7A2 =>
      'Email services give discounts for multiple accounts';

  @override
  String get quizPrivacyQ7A3 => 'One address can\'t receive many emails';

  @override
  String get quizPrivacyQ7A4 => 'This is only needed for work';

  @override
  String get quizPrivacyQ7Explain =>
      'Separate email for banking, another for forums. A forum database leak won\'t reveal your banking email. Aliases (SimpleLogin) let you delete a leaked address.';

  @override
  String get quizPrivacyQ8 => 'What is doxxing?';

  @override
  String get quizPrivacyQ8A1 =>
      'Collecting and publishing personal information without consent to intimidate';

  @override
  String get quizPrivacyQ8A2 => 'Protecting documents with a password';

  @override
  String get quizPrivacyQ8A3 => 'Archiving files';

  @override
  String get quizPrivacyQ8A4 => 'An identity verification procedure';

  @override
  String get quizPrivacyQ8Explain =>
      'Doxxers collect addresses, phone numbers, photos from open sources. Protection: minimize data on social media, use pseudonyms on forums.';

  @override
  String get quizPrivacyQ9 => 'How to reduce browser tracking?';

  @override
  String get quizPrivacyQ9A1 =>
      'Use a tracker blocker (uBlock Origin), clear cookies, enable DNS over HTTPS';

  @override
  String get quizPrivacyQ9A2 => 'Incognito mode is sufficient';

  @override
  String get quizPrivacyQ9A3 => 'Install more privacy extensions';

  @override
  String get quizPrivacyQ9A4 => 'Tracking cannot be prevented';

  @override
  String get quizPrivacyQ9Explain =>
      'Incognito does NOT protect against trackers. A combination: uBlock Origin, Firefox with Enhanced Tracking Protection, cookie clearing, DNS over HTTPS.';

  @override
  String get quizPrivacyQ10 => 'What is the right to be forgotten?';

  @override
  String get quizPrivacyQ10A1 =>
      'A legal right to demand companies delete your personal data';

  @override
  String get quizPrivacyQ10A2 => 'Automatic data deletion after a year';

  @override
  String get quizPrivacyQ10A3 => 'A ban on saving cookies';

  @override
  String get quizPrivacyQ10A4 => 'The right to forget your password';

  @override
  String get quizPrivacyQ10Explain =>
      'GDPR grants the right to request data deletion. Google allows removing links, social media - deleting accounts. Use it for unused accounts.';

  @override
  String get quizLockQ6 => 'Why set a BIOS/UEFI password?';

  @override
  String get quizLockQ6A1 =>
      'Prevents booting from external media, bypassing OS protection';

  @override
  String get quizLockQ6A2 => 'BIOS password speeds up booting';

  @override
  String get quizLockQ6A3 => 'Without it, the computer won\'t turn on';

  @override
  String get quizLockQ6A4 => 'BIOS password replaces Windows password';

  @override
  String get quizLockQ6Explain =>
      'Without a BIOS password, you can boot from USB and bypass the Windows password. BIOS password + BitLocker = reliable protection against physical access.';

  @override
  String get quizLockQ7 => 'How to protect against shoulder surfing?';

  @override
  String get quizLockQ7A1 =>
      'Use biometrics, a privacy screen, and make sure nobody is watching';

  @override
  String get quizLockQ7A2 => 'Enter the password quickly';

  @override
  String get quizLockQ7A3 => 'This is impossible in modern offices';

  @override
  String get quizLockQ7A4 => 'Use a long password';

  @override
  String get quizLockQ7Explain =>
      'A privacy screen (3M Privacy Filter) makes the image visible only from a direct angle. Biometrics eliminates shoulder surfing completely.';

  @override
  String get quizLockQ8 => 'What screen auto-lock timeout is recommended?';

  @override
  String get quizLockQ8A1 =>
      '2-5 minutes - enough to not annoy you but protect from access';

  @override
  String get quizLockQ8A2 => '30 minutes - the standard value';

  @override
  String get quizLockQ8A3 => 'Auto-lock is unrelated to security';

  @override
  String get quizLockQ8A4 => '1 hour for comfortable work';

  @override
  String get quizLockQ8Explain =>
      'In 30 minutes, someone can copy files, install a keylogger, or read email. 5 minutes is a balance between convenience and protection.';

  @override
  String get quizLockQ9 =>
      'What\'s the danger of disabling the Windows login password?';

  @override
  String get quizLockQ9A1 =>
      'Anyone who turns on the computer gets full access to files and accounts';

  @override
  String get quizLockQ9A2 => 'Windows will run slower';

  @override
  String get quizLockQ9A3 => 'No danger';

  @override
  String get quizLockQ9A4 => 'Vulnerability only to network attacks';

  @override
  String get quizLockQ9Explain =>
      'Without a password, the computer is an open book: documents, browser passwords, email. If a laptop is stolen, the thief gains instant access.';

  @override
  String get quizLockQ10 => 'Why lock your computer at home?';

  @override
  String get quizLockQ10A1 =>
      'The habit protects you elsewhere, and at home - from guests and burglars';

  @override
  String get quizLockQ10A2 => 'Locking isn\'t needed at home';

  @override
  String get quizLockQ10A3 => 'Only at work';

  @override
  String get quizLockQ10A4 => 'Viruses can unlock the computer';

  @override
  String get quizLockQ10Explain =>
      'Win+L should be a reflex. You have guests, couriers, technicians visiting. A habit developed at home will save you in cafes and offices.';

  @override
  String get quizExtQ6 => 'What is a browser extension supply chain attack?';

  @override
  String get quizExtQ6A1 =>
      'A developer sells the extension to an attacker who releases a malicious update';

  @override
  String get quizExtQ6A2 => 'An extension delivered by mail';

  @override
  String get quizExtQ6A3 => 'A conflict between extensions';

  @override
  String get quizExtQ6A4 => 'Installing from a file';

  @override
  String get quizExtQ6Explain =>
      'In 2020-2023, dozens of popular extensions were sold and updated with malicious code. Minimize the number of extensions.';

  @override
  String get quizExtQ7 => 'How to check permissions of installed extensions?';

  @override
  String get quizExtQ7A1 =>
      'chrome://extensions → Details → view site access and permissions';

  @override
  String get quizExtQ7A2 => 'Permissions can\'t be viewed after installation';

  @override
  String get quizExtQ7A3 => 'Only through reinstallation';

  @override
  String get quizExtQ7A4 => 'All extensions have the same permissions';

  @override
  String get quizExtQ7Explain =>
      'In Chrome: Extensions → Manage → click → Details. If a calculator needs access to all sites - remove it.';

  @override
  String get quizExtQ8 => 'Do extensions work in incognito mode?';

  @override
  String get quizExtQ8A1 =>
      'By default no - but you can allow it, which creates a tracking risk';

  @override
  String get quizExtQ8A2 => 'All extensions work in incognito';

  @override
  String get quizExtQ8A3 => 'Extensions are safe in incognito';

  @override
  String get quizExtQ8A4 => 'Incognito disables extensions permanently';

  @override
  String get quizExtQ8Explain =>
      'An extension enabled in incognito sees all sites you wanted to hide. Only enable trusted ones (uBlock Origin).';

  @override
  String get quizExtQ9 => 'Why restrict an extension to specific sites?';

  @override
  String get quizExtQ9A1 =>
      'Instead of access to all sites, give only to needed ones - principle of least privilege';

  @override
  String get quizExtQ9A2 => 'This speeds up the extension';

  @override
  String get quizExtQ9A3 => 'Restriction is impossible in Chrome';

  @override
  String get quizExtQ9A4 => 'Only for paid extensions';

  @override
  String get quizExtQ9Explain =>
      'Right-click the icon → \'On specific sites.\' A translator doesn\'t need access to your Gmail inbox.';

  @override
  String get quizExtQ10 => 'How do extensions affect browser fingerprinting?';

  @override
  String get quizExtQ10A1 =>
      'The set of extensions makes the browser more unique and recognizable';

  @override
  String get quizExtQ10A2 => 'Extensions hide the fingerprint';

  @override
  String get quizExtQ10A3 => 'Extensions don\'t affect privacy';

  @override
  String get quizExtQ10A4 => 'Only ad blockers create a fingerprint';

  @override
  String get quizExtQ10Explain =>
      'Sites detect extensions by side effects. Paradox: privacy extensions can make you more identifiable.';

  @override
  String get quizEncryptQ6 => 'What is AES-256?';

  @override
  String get quizEncryptQ6A1 =>
      'An encryption algorithm with a 256-bit key - brute-forcing all combinations would take longer than the age of the Universe';

  @override
  String get quizEncryptQ6A2 => 'A data compression protocol';

  @override
  String get quizEncryptQ6A3 => 'An antivirus algorithm';

  @override
  String get quizEncryptQ6A4 => 'An authentication method';

  @override
  String get quizEncryptQ6Explain =>
      'AES-256 is approved by the NSA for classified documents. 2^256 possible keys exceeds the number of atoms in the Universe.';

  @override
  String get quizEncryptQ7 =>
      'What\'s the difference between symmetric and asymmetric encryption?';

  @override
  String get quizEncryptQ7A1 =>
      'Symmetric - one key, asymmetric - a key pair (public + private)';

  @override
  String get quizEncryptQ7A2 => 'Symmetric is faster, so it\'s better';

  @override
  String get quizEncryptQ7A3 => 'Asymmetric is an outdated method';

  @override
  String get quizEncryptQ7A4 => 'No difference';

  @override
  String get quizEncryptQ7Explain =>
      'HTTPS uses both: asymmetric for key exchange, then symmetric for data. Asymmetric solves the problem of secure key exchange.';

  @override
  String get quizEncryptQ8 =>
      'Why is it important to encrypt data in the cloud?';

  @override
  String get quizEncryptQ8A1 =>
      'The provider can technically access unencrypted files';

  @override
  String get quizEncryptQ8A2 => 'The cloud automatically encrypts everything';

  @override
  String get quizEncryptQ8A3 => 'Cloud is safe without encryption';

  @override
  String get quizEncryptQ8A4 => 'Encryption slows sync by 10x';

  @override
  String get quizEncryptQ8Explain =>
      'Google Drive, Dropbox encrypt data but have access to it. Client-side encryption (Cryptomator) guarantees: only you can read the files.';

  @override
  String get quizEncryptQ9 => 'What to do with the BitLocker recovery key?';

  @override
  String get quizEncryptQ9A1 =>
      'Save in multiple places: Microsoft account, printout, password manager';

  @override
  String get quizEncryptQ9A2 => 'Memorize it';

  @override
  String get quizEncryptQ9A3 => 'The key isn\'t needed';

  @override
  String get quizEncryptQ9A4 => 'Email it to yourself';

  @override
  String get quizEncryptQ9Explain =>
      'The BitLocker key is 48 digits. Without it, a TPM failure means data is lost forever. At least 2 copies in different locations.';

  @override
  String get quizEncryptQ10 => 'Can you trust free VPNs?';

  @override
  String get quizEncryptQ10A1 =>
      'Be cautious - many sell user data or contain adware';

  @override
  String get quizEncryptQ10A2 => 'Free VPNs are just as safe as paid ones';

  @override
  String get quizEncryptQ10A3 => 'VPN is unrelated to encryption';

  @override
  String get quizEncryptQ10A4 => 'Free VPNs are faster than paid ones';

  @override
  String get quizEncryptQ10Explain =>
      '38% of free Android VPNs contain malware, 75% use trackers. Reliable free options are rare - research before trusting.';

  @override
  String get onbExtTitle => 'Browser Extension';

  @override
  String get onbExtSubtitle =>
      'Connect MentoringProtector to Chrome for real-time web protection';

  @override
  String get onbExtStep1 => 'Open chrome://extensions in the address bar';

  @override
  String get onbExtStep2 =>
      'Enable Developer Mode (toggle in the top-right corner)';

  @override
  String get onbExtStep3 =>
      'Click \'Load unpacked\' and select the folder shown below';

  @override
  String get onbExtOpenFolder => 'Open Extension Folder';

  @override
  String get onbExtSkip => 'Skip';

  @override
  String onbExtChecking(int attempt) {
    return 'Checking... $attempt/3';
  }

  @override
  String get onbExtCheckConnection => 'Check Connection';

  @override
  String get onbExtConnected => 'Extension connected';

  @override
  String get onbExtNotConnected => 'Extension not connected';

  @override
  String get onbAdminTitle => 'Safe Operation Mode';

  @override
  String get onbAdminNoAdmin =>
      'MentoringProtector runs without administrator privileges';

  @override
  String get onbAdminBody =>
      'File scanning, web protection, and process monitoring all work in normal user mode. No admin rights are needed for daily operation.';

  @override
  String get onbAdminWhenUac => 'When will the UAC prompt appear?';

  @override
  String get onbAdminWhenUacBody =>
      'The Windows confirmation dialog appears only when you click \'Fix Automatically\' in the Vulnerability Scanner - for example, to enable SmartScreen or Firewall. This is required by Windows for writing to the system registry.';

  @override
  String get onbAdminWhyLeastPrivilege =>
      'Why not always run as administrator?';

  @override
  String get onbAdminWhyBody =>
      'Fewer privileges → smaller attack surface. Kaspersky and Defender use the same model (service + UI client). We use a helper executable now, with a full Windows Service planned for Phase 5.';

  @override
  String get threatLibraryTitle => 'Threat Library';

  @override
  String get threatLibraryDesc =>
      'Catalog of known viruses and attacks with descriptions';

  @override
  String get threatLibrarySection => 'Education';

  @override
  String get threatLibrarySearchHint => 'Search by name or description';

  @override
  String threatLibraryCount(int found, int total) {
    return 'Found: $found of $total';
  }

  @override
  String get threatLibraryHomeTitle => 'Threat Library';

  @override
  String get threatLibraryHomeSubtitle =>
      'Learn about known viruses and attacks before they strike';

  @override
  String get threatLibraryFilterAll => 'All';

  @override
  String get threatLibraryEmpty =>
      'Nothing found. Try a different search or filter.';

  @override
  String get threatLibraryFilterType => 'Type';

  @override
  String get threatLibraryFilterCategory => 'Category';

  @override
  String get threatTypeTrojan => 'Trojan';

  @override
  String get threatTypeSpyware => 'Spyware';

  @override
  String get threatTypePhishing => 'Phishing';

  @override
  String get threatTypeRansomware => 'Ransomware';

  @override
  String get threatTypeWorm => 'Worm';

  @override
  String get threatTypeAdware => 'Adware';

  @override
  String get threatTypeExploit => 'Exploit';

  @override
  String get threatTypePup => 'PUP';

  @override
  String get threatTypeBackdoor => 'Backdoor';

  @override
  String get threatTypeRootkit => 'Rootkit';

  @override
  String get threatTypeTest => 'Test';

  @override
  String get hygieneCategorySafeDownloads => 'Safe Downloads';

  @override
  String get hygieneCategoryGeneral => 'General';

  @override
  String get hygieneCategoryPhishing => 'Phishing';

  @override
  String get hygieneCategoryBackups => 'Backups';

  @override
  String get hygieneCategoryNetworkSecurity => 'Network Security';

  @override
  String get hygieneCategorySystemMonitoring => 'System Monitoring';

  @override
  String get hygieneCategoryPasswords => 'Passwords';

  @override
  String get hygieneCategoryRemovableMedia => 'Removable Media';

  @override
  String get cacheStatsHits => 'Hits';

  @override
  String get cacheStatsMisses => 'Misses';

  @override
  String get cacheStatsEntries => 'Entries';

  @override
  String get cacheStatsHitRate => 'Hit rate';

  @override
  String get cacheStatsInvalidations => 'Invalidations';

  @override
  String get cacheInvalidateButton => 'Invalidate';

  @override
  String get cacheClearButton => 'Clear cache';

  @override
  String get cacheInvalidateSuccess => 'Cache invalidated';

  @override
  String get cacheInvalidateFailed => 'Invalidation failed';

  @override
  String get cacheClearSuccess => 'Cache cleared';

  @override
  String get cacheClearFailed => 'Failed to clear cache';

  @override
  String get cacheClearConfirmTitle => 'Clear scan cache?';

  @override
  String get cacheClearConfirmMsg =>
      'All cached scan results will be deleted. Files will be re-scanned on the next check.';

  @override
  String get cacheClearConfirm => 'Clear';

  @override
  String get cacheCoreUnavailable =>
      'Core unavailable - cache statistics not accessible';

  @override
  String get dllInjectionAlertsTitle => 'DLL Injections';

  @override
  String get dllInjectionEmptyState => 'No suspicious injections detected';

  @override
  String get dllInjectionScoreLabel => 'score';

  @override
  String get memoryActionTerminate => 'Terminate process';

  @override
  String get memoryActionQuarantine => 'Quarantine';

  @override
  String get memoryTerminateConfirmTitle => 'Terminate process?';

  @override
  String get memoryTerminateConfirmMsg =>
      'The process will be force-killed. Unsaved data will be lost.';

  @override
  String get memoryQuarantineConfirmTitle => 'Quarantine file?';

  @override
  String get memoryQuarantineConfirmMsg =>
      'The process executable will be moved to quarantine.';

  @override
  String get memoryActionSuccess => 'Action completed';

  @override
  String get memoryActionFailed => 'Action failed';

  @override
  String get eventRealtimeThreatBlocked => 'Threat blocked in real time';

  @override
  String get eventMemoryThreatsFound => 'Threats found in process memory';

  @override
  String get eventDllInjectionDetected => 'DLL injection detected';

  @override
  String get statsScreenTitle => 'Threat Statistics';

  @override
  String get statsScreenSubtitle => 'Protection over time';

  @override
  String get statsPeriod7Days => '7 days';

  @override
  String get statsPeriod30Days => '30 days';

  @override
  String get statsPeriod90Days => '90 days';

  @override
  String get statsHygieneTrendTitle => 'Digital hygiene trend';

  @override
  String get statsHygieneTrendEmpty => 'Not enough data yet';

  @override
  String get statsThreatsActivityTitle => 'Threats activity';

  @override
  String get statsThreatsActivityEmpty => 'No threats detected in this period';

  @override
  String get statsThreatsTotal => 'Total';

  @override
  String get statsEnginesPerformanceTitle => 'Engine performance';

  @override
  String get statsCacheHitRate => 'Cache hit rate';

  @override
  String get statsCacheEntries => 'Cached entries';

  @override
  String get statsYaraRules => 'YARA rules';

  @override
  String get statsQuarantineCount => 'Quarantined';

  @override
  String get statsThreatSourcesTitle => 'Threat sources';

  @override
  String get statsThreatSourcesEmpty => 'No source data';

  @override
  String get statsSourceScan => 'Scanner';

  @override
  String get statsSourceRealtime => 'Real-time';

  @override
  String get statsSourceMemory => 'Memory';

  @override
  String get statsSourceWeb => 'Web';

  @override
  String get statsLoadingError => 'Failed to load statistics';

  @override
  String get statsCoreNotReady => 'Core not initialised';

  @override
  String get statsRunScanHint => 'Run a scan to populate data';

  @override
  String get statsHomeCardThreatsTodayShort => 'Today';

  @override
  String get severityLabelInfo => 'Info';

  @override
  String get severityLabelWarning => 'Warning';

  @override
  String get severityLabelHigh => 'High';

  @override
  String get severityLabelCritical => 'Critical';

  @override
  String get sandboxTitle => 'Sandbox';

  @override
  String get sandboxDescription => 'Behavioural analysis of suspicious files';

  @override
  String get sandboxRunningBadge => 'Running';

  @override
  String get sandboxAnalyse => 'Analyse in Sandbox';

  @override
  String get sandboxRunning => 'Running sandbox analysis...';

  @override
  String get sandboxReport => 'Behavioral Report';

  @override
  String get sandboxCancel => 'Cancel';

  @override
  String get sandboxRiskScore => 'Risk score';

  @override
  String get sandboxRiskIndicators => 'Risk indicators';

  @override
  String get sandboxChildProcesses => 'Child processes';

  @override
  String get sandboxLoadedModules => 'Loaded modules';

  @override
  String get sandboxMemorySpikes => 'Memory spikes';

  @override
  String get sandboxNoBehaviour => 'No suspicious behaviour detected.';

  @override
  String get sandboxError => 'Sandbox error';

  @override
  String get sandboxRequiresAdmin => 'Sandbox requires Windows 8 or later';

  @override
  String get sandboxStartFailed => 'Failed to start sandbox';

  @override
  String get sandboxErrorUnsupported =>
      'This file type is not supported by sandbox. Supported: .exe, .ps1, .bat, .cmd, .vbs, .js';

  @override
  String get sandboxErrorBadFormat =>
      'File is not executable. EICAR, .txt, .pdf and similar files cannot be launched directly';

  @override
  String get sandboxErrorFileNotFound =>
      'File not found - it may have been deleted or moved';

  @override
  String get sandboxErrorAccessDenied =>
      'Access denied. Check file read permissions';

  @override
  String get sandboxErrorAlreadyRunning =>
      'Sandbox is already running an analysis. Wait for it to finish or cancel it';

  @override
  String get sandboxErrorDllUnsupported =>
      'DLL analysis is not yet supported (requires an export entry point)';

  @override
  String get sandboxErrorNestedJobsUnsupported =>
      'Cannot isolate the process - your system does not support nested Job Objects (Windows 8 or later required)';

  @override
  String get sandboxErrorCopyFailed =>
      'Failed to copy the file to a temporary directory for safe analysis. Check available disk space';

  @override
  String get sandboxErrorBlocked =>
      'File launch was blocked by the security system (antivirus or process restrictions). See MentoringProtector.log for details';

  @override
  String get sandboxErrorAppContainerProfile =>
      'Failed to create AppContainer profile for isolation. Group Policy may block AppContainers';

  @override
  String get sandboxErrorAppContainerAce =>
      'Failed to grant sandbox access to temporary directory. Check permissions on %TEMP%';

  @override
  String get statsTabDashboard => 'Dashboard';

  @override
  String get statsTabHistory => 'History';

  @override
  String get archiveSearchHint => 'Search by file or threat name';

  @override
  String get archiveFilterAll => 'All';

  @override
  String get archiveFilterScan => 'Scan';

  @override
  String get archiveFilterSandbox => 'Sandbox';

  @override
  String get archiveEmptyTitle => 'Archive is empty';

  @override
  String get archiveEmptyDescription =>
      'Completed scans and sandbox analyses will appear here';

  @override
  String get archiveClearMenu => 'Clear archive';

  @override
  String get archiveClearConfirm =>
      'Delete all archive records? This cannot be undone.';

  @override
  String get archiveCleared => 'Archive cleared';

  @override
  String sandboxErrorGeneric(String code) {
    return 'Failed to start sandbox: $code';
  }

  @override
  String get sandboxArchiveExtractFirst =>
      'Could not extract the file from the archive for sandbox analysis.';

  @override
  String get sandboxArchiveNotExecutable =>
      'The file inside the archive is not executable. Sandbox supports only: .exe, .ps1, .bat, .cmd, .vbs, .js';

  @override
  String get actionCenterTitle => 'Action Center';

  @override
  String get actionCenterEmpty => 'No threats detected yet';

  @override
  String get actionCenterViewAll => 'View all incidents';

  @override
  String actionCenterCount(int count) {
    return '$count incidents';
  }

  @override
  String get btnWhitelist => 'Whitelist';

  @override
  String get btnLearn => 'Learn';

  @override
  String get incidentStatusPending => 'Action needed';

  @override
  String get incidentStatusQuarantined => 'Quarantined';

  @override
  String get incidentStatusWhitelisted => 'Excluded';

  @override
  String get incidentStatusIgnored => 'Ignored';

  @override
  String get incidentReEvaluate => 'Re-evaluate';

  @override
  String get incidentWhitelistSuccess => 'File added to exclusions';

  @override
  String get incidentWhitelistFailed => 'Failed to add exclusion';

  @override
  String get actionCenterSearchHint => 'Search by file or threat name';

  @override
  String get actionCenterGroupToday => 'Today';

  @override
  String get actionCenterGroupYesterday => 'Yesterday';

  @override
  String actionCenterDetectionMethod(String method) {
    return 'Detection: $method';
  }

  @override
  String get nudgeDismiss => 'Got it';

  @override
  String get nudgeScanFile => 'Scan file';

  @override
  String get nudgeQuarantine => 'Quarantine';

  @override
  String get nudgeTrust => 'I trust this file';

  @override
  String get nudgeCheckDrive => 'Check drive';

  @override
  String get nudgeDownloadedExeTitle => 'Downloaded executable';

  @override
  String get nudgeDownloadedExeTip =>
      'Executable files downloaded from the internet are a top malware delivery method. Attackers disguise malware as software installers, free tools, or cracked programs.';

  @override
  String get nudgeDownloadedExeCheck1 =>
      'Is this from an official website or trusted app store?';

  @override
  String get nudgeDownloadedExeCheck2 =>
      'Check the file hash on VirusTotal before running.';

  @override
  String get nudgeDownloadedExeCheck3 =>
      'Watch for double extensions like \'document.pdf.exe\' - a classic trick.';

  @override
  String get nudgeDownloadedExeAction1 =>
      'Scan the file with MentoringProtector before opening.';

  @override
  String get nudgeDownloadedExeAction2 =>
      'If unsure - quarantine until you can verify the source.';

  @override
  String get nudgeDownloadedContainerTitle => 'Downloaded container file';

  @override
  String get nudgeDownloadedContainerTip =>
      'Container files (ISO, VHD, 7z) downloaded from the internet do NOT pass the \'mark of the web\' to files inside them. Attackers abuse this (ISO smuggling) so extracted executables don\'t trigger the usual download warning.';

  @override
  String get nudgeDownloadedContainerCheck1 =>
      'Did you expect a disk image or archive from this source?';

  @override
  String get nudgeDownloadedContainerCheck2 =>
      'Executables extracted from it will NOT show the \'downloaded from internet\' warning - treat them as untrusted.';

  @override
  String get nudgeDownloadedContainerCheck3 =>
      'Scan the container with MentoringProtector instead of mounting or extracting it blindly.';

  @override
  String get nudgeDownloadedContainerAction1 =>
      'Scan the container and its contents before extracting or mounting.';

  @override
  String get nudgeDownloadedContainerAction2 =>
      'If unsure - quarantine the container until you verify the source.';

  @override
  String get nudgeMacroDocumentTitle => 'Macro-enabled document';

  @override
  String get nudgeMacroDocumentTip =>
      'Macro-enabled Office documents (.docm, .xlsm) can execute code when opened. This format is commonly used in phishing attacks to deliver malware without a visible executable.';

  @override
  String get nudgeMacroDocumentCheck1 =>
      'Did you expect this file? Was it from a trusted sender?';

  @override
  String get nudgeMacroDocumentCheck2 =>
      'Legitimate business files rarely need macros enabled.';

  @override
  String get nudgeMacroDocumentCheck3 =>
      'If the document says \'Enable Content to view\' - that is a red flag.';

  @override
  String get nudgeMacroDocumentAction1 =>
      'Open in Protected View (read-only) first.';

  @override
  String get nudgeMacroDocumentAction2 =>
      'Only enable macros if you personally requested this file.';

  @override
  String get nudgeSuspiciousScriptTitle => 'Suspicious script';

  @override
  String get nudgeSuspiciousScriptTip =>
      'This script contains patterns commonly used in malicious PowerShell or VBScript: downloading files from the internet, encoded commands, or hidden execution - all classic signs of a malware loader.';

  @override
  String get nudgeSuspiciousScriptCheck1 =>
      'Do you know who wrote this script and what it is supposed to do?';

  @override
  String get nudgeSuspiciousScriptCheck2 =>
      'Encoded commands (-EncodedCommand, FromBase64String) hide what the script actually does.';

  @override
  String get nudgeSuspiciousScriptCheck3 =>
      'Legitimate system scripts rarely need to download files at runtime.';

  @override
  String get nudgeSuspiciousScriptAction1 =>
      'Open the script in a text editor and review its contents before running.';

  @override
  String get nudgeSuspiciousScriptAction2 =>
      'If received unexpectedly - delete and contact the sender through a different channel.';

  @override
  String get nudgeUsbDeviceTitle => 'Removable drive connected';

  @override
  String get nudgeUsbDeviceTip =>
      'Unknown USB drives are a real attack vector. \'BadUSB\' devices pretend to be keyboards and type malicious commands. Even found drives should not be trusted - this is a known social engineering technique.';

  @override
  String get nudgeUsbDeviceCheck1 => 'Do you know where this drive came from?';

  @override
  String get nudgeUsbDeviceCheck2 =>
      'Never plug in found drives - this is a classic social engineering attack.';

  @override
  String get nudgeUsbDeviceCheck3 =>
      'Autorun is disabled in Windows 7+, but malicious .lnk or .exe files can still be dangerous.';

  @override
  String get nudgeUsbDeviceAction1 =>
      'Scan the drive with MentoringProtector before opening any files.';

  @override
  String get nudgeUsbDeviceAction2 =>
      'If you do not recognize this drive - eject it without opening.';

  @override
  String get nudgeSource => 'Source:';

  @override
  String get nudgeChecklist => 'Checklist';

  @override
  String get nudgeWhatToDo => 'What to do';

  @override
  String get nudgeUsbScanning => 'Scanning...';

  @override
  String get nudgeUsbScanDone => 'Scan complete';

  @override
  String get nudgeUsbNoThreats => 'No threats found';

  @override
  String get nudgeUsbThreats => 'Threats found';

  @override
  String get nudgeUsbRescan => 'Scan again';

  @override
  String get serviceManaged => 'Managed by system service';

  @override
  String get requiresElevation => 'Requires administrator rights';

  @override
  String get serviceCmdFailed => 'Failed to send command to service';
}
