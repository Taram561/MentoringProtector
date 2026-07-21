import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.g.dart';
import 'app_localizations_ru.g.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.g.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru')
  ];

  /// navHome
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// navScan
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get navScan;

  /// navQuarantine
  ///
  /// In en, this message translates to:
  /// **'Quarantine'**
  String get navQuarantine;

  /// navHygiene
  ///
  /// In en, this message translates to:
  /// **'Hygiene'**
  String get navHygiene;

  /// navStats
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get navStats;

  /// navProcesses
  ///
  /// In en, this message translates to:
  /// **'Processes'**
  String get navProcesses;

  /// navSettings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// navVulnerabilities
  ///
  /// In en, this message translates to:
  /// **'Vulnerabilities'**
  String get navVulnerabilities;

  /// homeTitle
  ///
  /// In en, this message translates to:
  /// **'Mentoring Protector'**
  String get homeTitle;

  /// homeProtected
  ///
  /// In en, this message translates to:
  /// **'Protection active'**
  String get homeProtected;

  /// homeWarning
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get homeWarning;

  /// homeDanger
  ///
  /// In en, this message translates to:
  /// **'Device is not protected'**
  String get homeDanger;

  /// homeLastScan
  ///
  /// In en, this message translates to:
  /// **'Last scan: '**
  String get homeLastScan;

  /// homeNeverScanned
  ///
  /// In en, this message translates to:
  /// **'No scans performed yet'**
  String get homeNeverScanned;

  /// homeStartScan
  ///
  /// In en, this message translates to:
  /// **'Start scan'**
  String get homeStartScan;

  /// homeSignatures
  ///
  /// In en, this message translates to:
  /// **'Signatures in database'**
  String get homeSignatures;

  /// homeSignaturesCount
  ///
  /// In en, this message translates to:
  /// **'signatures'**
  String get homeSignaturesCount;

  /// homeInQuarantine
  ///
  /// In en, this message translates to:
  /// **'In quarantine'**
  String get homeInQuarantine;

  /// homeRecentEvents
  ///
  /// In en, this message translates to:
  /// **'Recent events'**
  String get homeRecentEvents;

  /// homeScanDone
  ///
  /// In en, this message translates to:
  /// **'Scan complete - no threats'**
  String get homeScanDone;

  /// homeDbUpdated
  ///
  /// In en, this message translates to:
  /// **'Database updated'**
  String get homeDbUpdated;

  /// homeAppStarted
  ///
  /// In en, this message translates to:
  /// **'Mentoring Protector started'**
  String get homeAppStarted;

  /// scanTitle
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scanTitle;

  /// scanSelectTarget
  ///
  /// In en, this message translates to:
  /// **'Select scan target'**
  String get scanSelectTarget;

  /// scanFile
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get scanFile;

  /// scanFolder
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get scanFolder;

  /// scanScanning
  ///
  /// In en, this message translates to:
  /// **'Scanning...'**
  String get scanScanning;

  /// scanCancel
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get scanCancel;

  /// scanNewScan
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get scanNewScan;

  /// scanNoThreats
  ///
  /// In en, this message translates to:
  /// **'No threats found'**
  String get scanNoThreats;

  /// scanThreatsFound
  ///
  /// In en, this message translates to:
  /// **'Threats found: '**
  String get scanThreatsFound;

  /// scanResults
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get scanResults;

  /// scanChecked
  ///
  /// In en, this message translates to:
  /// **'Checked: '**
  String get scanChecked;

  /// scanOf
  ///
  /// In en, this message translates to:
  /// **' of '**
  String get scanOf;

  /// scanStatsFilesScanned
  ///
  /// In en, this message translates to:
  /// **'Files scanned'**
  String get scanStatsFilesScanned;

  /// scanStatsElapsedTime
  ///
  /// In en, this message translates to:
  /// **'Elapsed time'**
  String get scanStatsElapsedTime;

  /// scanStatsActiveEngines
  ///
  /// In en, this message translates to:
  /// **'Active engines'**
  String get scanStatsActiveEngines;

  /// scanStatsThreatsFound
  ///
  /// In en, this message translates to:
  /// **'Threats found'**
  String get scanStatsThreatsFound;

  /// quarantineTitle
  ///
  /// In en, this message translates to:
  /// **'Quarantine'**
  String get quarantineTitle;

  /// quarantineEmpty
  ///
  /// In en, this message translates to:
  /// **'Quarantine is empty'**
  String get quarantineEmpty;

  /// quarantineRestore
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get quarantineRestore;

  /// quarantineDelete
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get quarantineDelete;

  /// quarantineFile
  ///
  /// In en, this message translates to:
  /// **'files'**
  String get quarantineFile;

  /// quarantineDeleteConfirm
  ///
  /// In en, this message translates to:
  /// **'Delete this file permanently? It cannot be recovered.'**
  String get quarantineDeleteConfirm;

  /// quarantineRestoreConfirm
  ///
  /// In en, this message translates to:
  /// **'Restore this file to its original location?'**
  String get quarantineRestoreConfirm;

  /// quarantineRestoreSuccess
  ///
  /// In en, this message translates to:
  /// **'File restored'**
  String get quarantineRestoreSuccess;

  /// quarantineOrphanBadge
  ///
  /// In en, this message translates to:
  /// **'File unavailable'**
  String get quarantineOrphanBadge;

  /// quarantineOrphanRemove
  ///
  /// In en, this message translates to:
  /// **'Remove from list'**
  String get quarantineOrphanRemove;

  /// quarantineOrphanRemoveConfirm
  ///
  /// In en, this message translates to:
  /// **'The quarantine file is missing on disk. Remove this entry from the list?'**
  String get quarantineOrphanRemoveConfirm;

  /// processTitle
  ///
  /// In en, this message translates to:
  /// **'Process monitor'**
  String get processTitle;

  /// processStart
  ///
  /// In en, this message translates to:
  /// **'Start monitoring'**
  String get processStart;

  /// processStop
  ///
  /// In en, this message translates to:
  /// **'Stop monitoring'**
  String get processStop;

  /// processActive
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get processActive;

  /// processBlocked
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get processBlocked;

  /// processNoAlerts
  ///
  /// In en, this message translates to:
  /// **'No suspicious processes detected'**
  String get processNoAlerts;

  /// processThreats
  ///
  /// In en, this message translates to:
  /// **'Threats'**
  String get processThreats;

  /// processSuspicious
  ///
  /// In en, this message translates to:
  /// **'Suspicious'**
  String get processSuspicious;

  /// processClean
  ///
  /// In en, this message translates to:
  /// **'Clean'**
  String get processClean;

  /// processAnalysisTitle
  ///
  /// In en, this message translates to:
  /// **'Process file analysis'**
  String get processAnalysisTitle;

  /// processAnalysisDesc
  ///
  /// In en, this message translates to:
  /// **'Mentoring Protector analyses every new process. Unknown files are checked heuristically.'**
  String get processAnalysisDesc;

  /// processStartHint
  ///
  /// In en, this message translates to:
  /// **'Start monitoring\nto analyse processes'**
  String get processStartHint;

  /// vulnTitle
  ///
  /// In en, this message translates to:
  /// **'Device vulnerabilities'**
  String get vulnTitle;

  /// vulnDescription
  ///
  /// In en, this message translates to:
  /// **'Analysis of Windows security settings, open services and system configuration.'**
  String get vulnDescription;

  /// vulnScan
  ///
  /// In en, this message translates to:
  /// **'Scan device'**
  String get vulnScan;

  /// vulnScanBtn
  ///
  /// In en, this message translates to:
  /// **'Scan device'**
  String get vulnScanBtn;

  /// vulnScanning
  ///
  /// In en, this message translates to:
  /// **'Analysing system...'**
  String get vulnScanning;

  /// vulnNone
  ///
  /// In en, this message translates to:
  /// **'No vulnerabilities found'**
  String get vulnNone;

  /// vulnFound
  ///
  /// In en, this message translates to:
  /// **'Vulnerabilities found: '**
  String get vulnFound;

  /// vulnCritical
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get vulnCritical;

  /// vulnHigh
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get vulnHigh;

  /// vulnMedium
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get vulnMedium;

  /// vulnLow
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get vulnLow;

  /// vulnHowToFix
  ///
  /// In en, this message translates to:
  /// **'How to fix'**
  String get vulnHowToFix;

  /// vulnMoreInfo
  ///
  /// In en, this message translates to:
  /// **'More info'**
  String get vulnMoreInfo;

  /// settingsTitle
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// settingsTheme
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// settingsThemeSystem
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsThemeSystem;

  /// settingsThemeLight
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// settingsThemeDark
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// settingsLanguage
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// settingsVersion
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get settingsVersion;

  /// settingsCoreVersion
  ///
  /// In en, this message translates to:
  /// **'Core version'**
  String get settingsCoreVersion;

  /// helpTitle
  ///
  /// In en, this message translates to:
  /// **'Help & About'**
  String get helpTitle;

  /// helpAbout
  ///
  /// In en, this message translates to:
  /// **'About the app, FAQ, and learning resources'**
  String get helpAbout;

  /// helpMission
  ///
  /// In en, this message translates to:
  /// **'Adaptive Cyber Hygiene Platform - teaching users to prevent social engineering and phishing attacks'**
  String get helpMission;

  /// helpLinksTitle
  ///
  /// In en, this message translates to:
  /// **'Links'**
  String get helpLinksTitle;

  /// helpGithub
  ///
  /// In en, this message translates to:
  /// **'GitHub Repository'**
  String get helpGithub;

  /// helpLicense
  ///
  /// In en, this message translates to:
  /// **'License (MIT)'**
  String get helpLicense;

  /// helpEducationTitle
  ///
  /// In en, this message translates to:
  /// **'Learning Resources'**
  String get helpEducationTitle;

  /// helpCourseTitle
  ///
  /// In en, this message translates to:
  /// **'Cybersecurity Course'**
  String get helpCourseTitle;

  /// helpQuizTitle
  ///
  /// In en, this message translates to:
  /// **'Interactive Quizzes'**
  String get helpQuizTitle;

  /// helpCourseSoon
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get helpCourseSoon;

  /// helpEducationPlaceholder
  ///
  /// In en, this message translates to:
  /// **'Educational content is coming soon!'**
  String get helpEducationPlaceholder;

  /// faq01Q
  ///
  /// In en, this message translates to:
  /// **'What is YARA?'**
  String get faq01Q;

  /// faq01A
  ///
  /// In en, this message translates to:
  /// **'YARA is a pattern-matching tool used to identify malware based on textual or binary patterns. MentoringProtector uses YARA rules as one of its detection engines alongside signatures and heuristics.'**
  String get faq01A;

  /// faq02Q
  ///
  /// In en, this message translates to:
  /// **'Why does MentoringProtector need administrator rights?'**
  String get faq02Q;

  /// faq02A
  ///
  /// In en, this message translates to:
  /// **'The main application runs without admin rights. Administrator access (UAC) is only requested when you click \'Fix automatically\' in Vulnerability Scanner - this is required to modify Windows system registry settings.'**
  String get faq02A;

  /// faq03Q
  ///
  /// In en, this message translates to:
  /// **'What is Smart Scan Cache?'**
  String get faq03Q;

  /// faq03A
  ///
  /// In en, this message translates to:
  /// **'Smart Scan Cache stores hash-based scan results so files that haven\'t changed don\'t need to be rescanned. This makes repeated scans significantly faster without compromising security.'**
  String get faq03A;

  /// faq04Q
  ///
  /// In en, this message translates to:
  /// **'What is the Bloom Filter used for?'**
  String get faq04Q;

  /// faq04A
  ///
  /// In en, this message translates to:
  /// **'The Bloom Filter is a probabilistic data structure used for fast phishing domain lookups in Web Protection. It checks ~100K domains in microseconds with near-zero false negatives.'**
  String get faq04A;

  /// faq05Q
  ///
  /// In en, this message translates to:
  /// **'What happens to files in Quarantine?'**
  String get faq05Q;

  /// faq05A
  ///
  /// In en, this message translates to:
  /// **'Quarantined files are encrypted with AES-256 and stored in a protected folder. They cannot execute. You can restore them if they were detected as false positives, or permanently delete them.'**
  String get faq05A;

  /// faq06Q
  ///
  /// In en, this message translates to:
  /// **'How does the heuristic engine work?'**
  String get faq06Q;

  /// faq06A
  ///
  /// In en, this message translates to:
  /// **'The heuristic engine analyzes PE file structure: imports, suspicious strings, entropy (packed/encrypted sections), digital signature validity, and file size anomalies - without needing a signature database.'**
  String get faq06A;

  /// faq07Q
  ///
  /// In en, this message translates to:
  /// **'What is ETW monitoring?'**
  String get faq07Q;

  /// faq07A
  ///
  /// In en, this message translates to:
  /// **'Event Tracing for Windows (ETW) is a kernel-level logging mechanism. MentoringProtector uses it to detect DLL injection and suspicious process activity at the OS kernel level.'**
  String get faq07A;

  /// faq08Q
  ///
  /// In en, this message translates to:
  /// **'Why choose MentoringProtector over Windows Defender?'**
  String get faq08Q;

  /// faq08A
  ///
  /// In en, this message translates to:
  /// **'MentoringProtector is an educational platform: it explains WHY a file is suspicious (explainable detection), teaches cyber hygiene habits, and shows you exactly what detection logic triggered. Defender is great protection but doesn\'t teach.'**
  String get faq08A;

  /// hygieneUpdateTitle
  ///
  /// In en, this message translates to:
  /// **'Keep your system updated'**
  String get hygieneUpdateTitle;

  /// hygieneUpdateDesc
  ///
  /// In en, this message translates to:
  /// **'Install Windows and app updates as soon as they are released. Most attacks exploit known vulnerabilities in older versions.'**
  String get hygieneUpdateDesc;

  /// hygienePasswordTitle
  ///
  /// In en, this message translates to:
  /// **'Use strong passwords'**
  String get hygienePasswordTitle;

  /// hygienePasswordDesc
  ///
  /// In en, this message translates to:
  /// **'Use unique passwords of at least 12 characters for each service. A password manager makes this easy.'**
  String get hygienePasswordDesc;

  /// hygieneWifiTitle
  ///
  /// In en, this message translates to:
  /// **'Secure Wi-Fi'**
  String get hygieneWifiTitle;

  /// hygieneWifiDesc
  ///
  /// In en, this message translates to:
  /// **'Avoid public networks without a VPN. Use WPA3 encryption for your home network.'**
  String get hygieneWifiDesc;

  /// hygienePhishingTitle
  ///
  /// In en, this message translates to:
  /// **'Watch out for phishing'**
  String get hygienePhishingTitle;

  /// hygienePhishingDesc
  ///
  /// In en, this message translates to:
  /// **'Do not open attachments or links in suspicious emails. Always verify the sender address before replying.'**
  String get hygienePhishingDesc;

  /// hygieneBackupTitle
  ///
  /// In en, this message translates to:
  /// **'Back up your data'**
  String get hygieneBackupTitle;

  /// hygieneBackupDesc
  ///
  /// In en, this message translates to:
  /// **'Regularly back up important files. Follow the 3-2-1 rule: 3 copies, 2 media types, 1 offsite.'**
  String get hygieneBackupDesc;

  /// hygieneDownloadTitle
  ///
  /// In en, this message translates to:
  /// **'Download safely'**
  String get hygieneDownloadTitle;

  /// hygieneDownloadDesc
  ///
  /// In en, this message translates to:
  /// **'Only download software from official sources. Scan files before running them.'**
  String get hygieneDownloadDesc;

  /// hygiene2faTitle
  ///
  /// In en, this message translates to:
  /// **'Two-factor authentication'**
  String get hygiene2faTitle;

  /// hygiene2faDesc
  ///
  /// In en, this message translates to:
  /// **'Enable 2FA for all important accounts: email, banking, social media. Use an authenticator app instead of SMS.'**
  String get hygiene2faDesc;

  /// hygieneUsbTitle
  ///
  /// In en, this message translates to:
  /// **'Beware of USB devices'**
  String get hygieneUsbTitle;

  /// hygieneUsbDesc
  ///
  /// In en, this message translates to:
  /// **'Never plug in unknown USB drives. They may contain malware that runs automatically.'**
  String get hygieneUsbDesc;

  /// hygienePrivacyTitle
  ///
  /// In en, this message translates to:
  /// **'Privacy settings'**
  String get hygienePrivacyTitle;

  /// hygienePrivacyDesc
  ///
  /// In en, this message translates to:
  /// **'Regularly review privacy settings in Windows, your browser, and apps. Disable unnecessary telemetry.'**
  String get hygienePrivacyDesc;

  /// hygieneLockTitle
  ///
  /// In en, this message translates to:
  /// **'Lock your screen'**
  String get hygieneLockTitle;

  /// hygieneLockDesc
  ///
  /// In en, this message translates to:
  /// **'Always lock your computer when you step away. Use Win+L. Set auto-lock after 5 minutes of inactivity.'**
  String get hygieneLockDesc;

  /// hygieneExtensionsTitle
  ///
  /// In en, this message translates to:
  /// **'Browser extensions'**
  String get hygieneExtensionsTitle;

  /// hygieneExtensionsDesc
  ///
  /// In en, this message translates to:
  /// **'Remove unnecessary browser extensions. Each one can read your data on websites.'**
  String get hygieneExtensionsDesc;

  /// hygieneEncryptionTitle
  ///
  /// In en, this message translates to:
  /// **'Disk encryption'**
  String get hygieneEncryptionTitle;

  /// hygieneEncryptionDesc
  ///
  /// In en, this message translates to:
  /// **'Enable BitLocker or equivalent to encrypt your system drive. This protects your data if your laptop is stolen.'**
  String get hygieneEncryptionDesc;

  /// btnClose
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get btnClose;

  /// btnOk
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get btnOk;

  /// btnCancel
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get btnCancel;

  /// errorDllNotFound
  ///
  /// In en, this message translates to:
  /// **'Antivirus core not found'**
  String get errorDllNotFound;

  /// errorGeneric
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorGeneric;

  /// computerScanTitle
  ///
  /// In en, this message translates to:
  /// **'Computer Scan'**
  String get computerScanTitle;

  /// computerScanDescription
  ///
  /// In en, this message translates to:
  /// **'Full scan of all drives'**
  String get computerScanDescription;

  /// computerScanStart
  ///
  /// In en, this message translates to:
  /// **'Start Scan'**
  String get computerScanStart;

  /// computerScanDrive
  ///
  /// In en, this message translates to:
  /// **'Drive'**
  String get computerScanDrive;

  /// computerScanThreats
  ///
  /// In en, this message translates to:
  /// **'Threats'**
  String get computerScanThreats;

  /// computerScanThreatsFound
  ///
  /// In en, this message translates to:
  /// **'Threats found'**
  String get computerScanThreatsFound;

  /// computerScanNoThreats
  ///
  /// In en, this message translates to:
  /// **'No threats found'**
  String get computerScanNoThreats;

  /// computerScanInfo1
  ///
  /// In en, this message translates to:
  /// **'Signature scan against ClamAV database'**
  String get computerScanInfo1;

  /// computerScanInfo2
  ///
  /// In en, this message translates to:
  /// **'Heuristic analysis of PE files'**
  String get computerScanInfo2;

  /// computerScanInfo3
  ///
  /// In en, this message translates to:
  /// **'Skips Windows system folders'**
  String get computerScanInfo3;

  /// computerScanInfo4
  ///
  /// In en, this message translates to:
  /// **'Safe: read-only, no file changes'**
  String get computerScanInfo4;

  /// navWebProtection
  ///
  /// In en, this message translates to:
  /// **'Web Shield'**
  String get navWebProtection;

  /// webTitle
  ///
  /// In en, this message translates to:
  /// **'Web Protection'**
  String get webTitle;

  /// webDescription
  ///
  /// In en, this message translates to:
  /// **'Real-time protection against phishing and malicious websites via browser extension.'**
  String get webDescription;

  /// webServerRunning
  ///
  /// In en, this message translates to:
  /// **'Server running'**
  String get webServerRunning;

  /// webServerStopped
  ///
  /// In en, this message translates to:
  /// **'Server stopped'**
  String get webServerStopped;

  /// webStart
  ///
  /// In en, this message translates to:
  /// **'Start protection'**
  String get webStart;

  /// webStop
  ///
  /// In en, this message translates to:
  /// **'Stop protection'**
  String get webStop;

  /// webThreatsLoaded
  ///
  /// In en, this message translates to:
  /// **'Threats in database'**
  String get webThreatsLoaded;

  /// webAuthToken
  ///
  /// In en, this message translates to:
  /// **'Auth token'**
  String get webAuthToken;

  /// webCopyToken
  ///
  /// In en, this message translates to:
  /// **'Copy token'**
  String get webCopyToken;

  /// webTokenCopied
  ///
  /// In en, this message translates to:
  /// **'Token copied to clipboard'**
  String get webTokenCopied;

  /// webRegenerateToken
  ///
  /// In en, this message translates to:
  /// **'Regenerate token'**
  String get webRegenerateToken;

  /// webRegenerateConfirm
  ///
  /// In en, this message translates to:
  /// **'Regenerate token? The current one will be invalidated.'**
  String get webRegenerateConfirm;

  /// webCheckUrl
  ///
  /// In en, this message translates to:
  /// **'Check URL'**
  String get webCheckUrl;

  /// webCheckUrlHint
  ///
  /// In en, this message translates to:
  /// **'Enter URL to check'**
  String get webCheckUrlHint;

  /// webResultSafe
  ///
  /// In en, this message translates to:
  /// **'Safe'**
  String get webResultSafe;

  /// webResultDanger
  ///
  /// In en, this message translates to:
  /// **'Dangerous'**
  String get webResultDanger;

  /// webScore
  ///
  /// In en, this message translates to:
  /// **'Threat score'**
  String get webScore;

  /// webReason
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get webReason;

  /// webDomain
  ///
  /// In en, this message translates to:
  /// **'Domain'**
  String get webDomain;

  /// webEventsTitle
  ///
  /// In en, this message translates to:
  /// **'Recent checks'**
  String get webEventsTitle;

  /// webNoEvents
  ///
  /// In en, this message translates to:
  /// **'No checks yet'**
  String get webNoEvents;

  /// webExtensionHint
  ///
  /// In en, this message translates to:
  /// **'Install the Chrome/Edge extension and paste the token in the extension settings.'**
  String get webExtensionHint;

  /// webDetailTitle
  ///
  /// In en, this message translates to:
  /// **'URL Analysis'**
  String get webDetailTitle;

  /// webDetailDomain
  ///
  /// In en, this message translates to:
  /// **'Domain'**
  String get webDetailDomain;

  /// webDetailThreatType
  ///
  /// In en, this message translates to:
  /// **'Threat Type'**
  String get webDetailThreatType;

  /// webDetailRiskScore
  ///
  /// In en, this message translates to:
  /// **'Risk Level'**
  String get webDetailRiskScore;

  /// webDetailAnalysis
  ///
  /// In en, this message translates to:
  /// **'Analysis Results'**
  String get webDetailAnalysis;

  /// webDetailHomoglyphTitle
  ///
  /// In en, this message translates to:
  /// **'Homoglyph Attack Detected'**
  String get webDetailHomoglyphTitle;

  /// webDetailHomoglyphDesc
  ///
  /// In en, this message translates to:
  /// **'This domain impersonates the brand \"{brand}\" using visually similar characters from another alphabet.'**
  String webDetailHomoglyphDesc(String brand);

  /// webDetailTeachableTitle
  ///
  /// In en, this message translates to:
  /// **'How to spot this yourself?'**
  String get webDetailTeachableTitle;

  /// webTipPhishing
  ///
  /// In en, this message translates to:
  /// **'Phishing sites copy the design of well-known services. Always check the URL bar - the real domain is before the first \"/\".'**
  String get webTipPhishing;

  /// webTipMalware
  ///
  /// In en, this message translates to:
  /// **'Malicious sites often disguise themselves as updates or free software. Only download programs from official websites.'**
  String get webTipMalware;

  /// webTipScam
  ///
  /// In en, this message translates to:
  /// **'Scam sites create urgency: \"you won\", \"account blocked\". Don\'t rush - verify information through the official website.'**
  String get webTipScam;

  /// webTipHomoglyph
  ///
  /// In en, this message translates to:
  /// **'Homoglyph attacks replace letters with lookalikes (e.g., Cyrillic \"а\" instead of Latin \"a\"). Hover over the URL - your browser will show the Punycode version.'**
  String get webTipHomoglyph;

  /// webTipSuspicious
  ///
  /// In en, this message translates to:
  /// **'Suspicious domains often use unusual TLDs (.tk, .xyz), long subdomains, or IP addresses instead of names. When in doubt - don\'t enter your data.'**
  String get webTipSuspicious;

  /// webTipCryptominer
  ///
  /// In en, this message translates to:
  /// **'Website cryptominers use your CPU to mine cryptocurrency. Signs: sudden CPU spike, fan noise, browser lag.'**
  String get webTipCryptominer;

  /// webTipTracking
  ///
  /// In en, this message translates to:
  /// **'Tracking scripts collect data about your behavior. Use ad blockers and incognito mode for better privacy.'**
  String get webTipTracking;

  /// webTipGeneral
  ///
  /// In en, this message translates to:
  /// **'Before entering personal data, verify the URL starts with https:// and the domain matches the expected service.'**
  String get webTipGeneral;

  /// webDetailSafe
  ///
  /// In en, this message translates to:
  /// **'Safe'**
  String get webDetailSafe;

  /// webDetailLow
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get webDetailLow;

  /// webDetailMedium
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get webDetailMedium;

  /// webDetailHigh
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get webDetailHigh;

  /// webDetailCritical
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get webDetailCritical;

  /// webReasonPhishing
  ///
  /// In en, this message translates to:
  /// **'Phishing'**
  String get webReasonPhishing;

  /// webReasonMalware
  ///
  /// In en, this message translates to:
  /// **'Malware'**
  String get webReasonMalware;

  /// webReasonScam
  ///
  /// In en, this message translates to:
  /// **'Scam'**
  String get webReasonScam;

  /// webReasonCryptominer
  ///
  /// In en, this message translates to:
  /// **'Cryptominer'**
  String get webReasonCryptominer;

  /// webReasonTracking
  ///
  /// In en, this message translates to:
  /// **'Tracker'**
  String get webReasonTracking;

  /// webReasonSuspicious
  ///
  /// In en, this message translates to:
  /// **'Suspicious'**
  String get webReasonSuspicious;

  /// webReasonClean
  ///
  /// In en, this message translates to:
  /// **'Clean'**
  String get webReasonClean;

  /// navProtection
  ///
  /// In en, this message translates to:
  /// **'Protection'**
  String get navProtection;

  /// protectionTitle
  ///
  /// In en, this message translates to:
  /// **'Protection Modules'**
  String get protectionTitle;

  /// navRealtime
  ///
  /// In en, this message translates to:
  /// **'Realtime'**
  String get navRealtime;

  /// archiveScannerTitle
  ///
  /// In en, this message translates to:
  /// **'Archive Scanner'**
  String get archiveScannerTitle;

  /// archiveScannerDescription
  ///
  /// In en, this message translates to:
  /// **'Scans ZIP, 7z, RAR and ISO archives for threats inside. Zip-bomb protection included.'**
  String get archiveScannerDescription;

  /// realtimeTitle
  ///
  /// In en, this message translates to:
  /// **'Real-time Protection'**
  String get realtimeTitle;

  /// realtimeDescription
  ///
  /// In en, this message translates to:
  /// **'Monitors file creation and modification in Downloads, Desktop, Documents and Temp'**
  String get realtimeDescription;

  /// realtimeStart
  ///
  /// In en, this message translates to:
  /// **'Enable protection'**
  String get realtimeStart;

  /// realtimeStop
  ///
  /// In en, this message translates to:
  /// **'Disable protection'**
  String get realtimeStop;

  /// realtimeActive
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get realtimeActive;

  /// realtimeNoEvents
  ///
  /// In en, this message translates to:
  /// **'No events'**
  String get realtimeNoEvents;

  /// realtimeStartHint
  ///
  /// In en, this message translates to:
  /// **'Press the button to enable real-time protection'**
  String get realtimeStartHint;

  /// realtimeTotalDetected
  ///
  /// In en, this message translates to:
  /// **'Detected'**
  String get realtimeTotalDetected;

  /// realtimeThreatsFound
  ///
  /// In en, this message translates to:
  /// **'Threats'**
  String get realtimeThreatsFound;

  /// realtimeEvents
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get realtimeEvents;

  /// realtimeCreated
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get realtimeCreated;

  /// realtimeModified
  ///
  /// In en, this message translates to:
  /// **'Modified'**
  String get realtimeModified;

  /// realtimeRenamed
  ///
  /// In en, this message translates to:
  /// **'Renamed'**
  String get realtimeRenamed;

  /// navMemoryScan
  ///
  /// In en, this message translates to:
  /// **'RAM'**
  String get navMemoryScan;

  /// memoryTitle
  ///
  /// In en, this message translates to:
  /// **'Memory Scan'**
  String get memoryTitle;

  /// memoryDescription
  ///
  /// In en, this message translates to:
  /// **'Search for malware signatures in running process memory'**
  String get memoryDescription;

  /// memoryScanStart
  ///
  /// In en, this message translates to:
  /// **'Start RAM scan'**
  String get memoryScanStart;

  /// memoryScanStop
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get memoryScanStop;

  /// memoryScanRunning
  ///
  /// In en, this message translates to:
  /// **'Scanning...'**
  String get memoryScanRunning;

  /// memoryScanFinished
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get memoryScanFinished;

  /// memoryScanNoThreats
  ///
  /// In en, this message translates to:
  /// **'No threats found in memory'**
  String get memoryScanNoThreats;

  /// memoryScanProcesses
  ///
  /// In en, this message translates to:
  /// **'Processes'**
  String get memoryScanProcesses;

  /// memoryScanThreatsFound
  ///
  /// In en, this message translates to:
  /// **'Threats found'**
  String get memoryScanThreatsFound;

  /// memoryScanCurrentProcess
  ///
  /// In en, this message translates to:
  /// **'Current process'**
  String get memoryScanCurrentProcess;

  /// memoryScanRegions
  ///
  /// In en, this message translates to:
  /// **'Memory regions'**
  String get memoryScanRegions;

  /// memoryScanMatches
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get memoryScanMatches;

  /// memoryUnavailable
  ///
  /// In en, this message translates to:
  /// **'Memory scanner unavailable in current DLL'**
  String get memoryUnavailable;

  /// realtimeUnavailable
  ///
  /// In en, this message translates to:
  /// **'Real-time monitor unavailable in current DLL'**
  String get realtimeUnavailable;

  /// scanQuarantine
  ///
  /// In en, this message translates to:
  /// **'Quarantine'**
  String get scanQuarantine;

  /// scanDeleteFile
  ///
  /// In en, this message translates to:
  /// **'Delete file'**
  String get scanDeleteFile;

  /// scanIgnore
  ///
  /// In en, this message translates to:
  /// **'Ignore'**
  String get scanIgnore;

  /// scanQuarantineSuccess
  ///
  /// In en, this message translates to:
  /// **'File quarantined'**
  String get scanQuarantineSuccess;

  /// scanDeleteSuccess
  ///
  /// In en, this message translates to:
  /// **'File deleted'**
  String get scanDeleteSuccess;

  /// scanDeleteConfirm
  ///
  /// In en, this message translates to:
  /// **'Delete file permanently?'**
  String get scanDeleteConfirm;

  /// scanDangerLevel
  ///
  /// In en, this message translates to:
  /// **'Danger level'**
  String get scanDangerLevel;

  /// scanDetectionMethod
  ///
  /// In en, this message translates to:
  /// **'Detection method'**
  String get scanDetectionMethod;

  /// scanMethodSignature
  ///
  /// In en, this message translates to:
  /// **'Signature analysis'**
  String get scanMethodSignature;

  /// scanMethodHeuristic
  ///
  /// In en, this message translates to:
  /// **'Heuristic analysis'**
  String get scanMethodHeuristic;

  /// detectionMethodArchive
  ///
  /// In en, this message translates to:
  /// **'Archive Scan'**
  String get detectionMethodArchive;

  /// archiveThreatFound
  ///
  /// In en, this message translates to:
  /// **'Threat found inside archive'**
  String get archiveThreatFound;

  /// archiveTeachableMoment
  ///
  /// In en, this message translates to:
  /// **'Archives are a common delivery vector for malware. Always verify archive contents before opening, especially files received via email or messengers.'**
  String get archiveTeachableMoment;

  /// scanHeuristicScore
  ///
  /// In en, this message translates to:
  /// **'Suspicion score'**
  String get scanHeuristicScore;

  /// scanEntropy
  ///
  /// In en, this message translates to:
  /// **'File entropy'**
  String get scanEntropy;

  /// scanIsPacked
  ///
  /// In en, this message translates to:
  /// **'Packed'**
  String get scanIsPacked;

  /// scanHasSignature
  ///
  /// In en, this message translates to:
  /// **'Digital signature'**
  String get scanHasSignature;

  /// scanTriggeredRules
  ///
  /// In en, this message translates to:
  /// **'Triggered rules'**
  String get scanTriggeredRules;

  /// scanRecommendation
  ///
  /// In en, this message translates to:
  /// **'Recommendation'**
  String get scanRecommendation;

  /// scanHash
  ///
  /// In en, this message translates to:
  /// **'Hash (SHA256)'**
  String get scanHash;

  /// scanYes
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get scanYes;

  /// scanNo
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get scanNo;

  /// etwModeEtw
  ///
  /// In en, this message translates to:
  /// **'ETW'**
  String get etwModeEtw;

  /// etwModePolling
  ///
  /// In en, this message translates to:
  /// **'Polling'**
  String get etwModePolling;

  /// etwDllInjectionTitle
  ///
  /// In en, this message translates to:
  /// **'DLL Injection'**
  String get etwDllInjectionTitle;

  /// etwDllInjectionEmpty
  ///
  /// In en, this message translates to:
  /// **'No suspicious DLL loads detected'**
  String get etwDllInjectionEmpty;

  /// etwRunAsAdmin
  ///
  /// In en, this message translates to:
  /// **'Run as administrator for ETW mode'**
  String get etwRunAsAdmin;

  /// yaraRules
  ///
  /// In en, this message translates to:
  /// **'YARA rules'**
  String get yaraRules;

  /// yaraDetection
  ///
  /// In en, this message translates to:
  /// **'YARA analysis'**
  String get yaraDetection;

  /// yaraRulesLoaded
  ///
  /// In en, this message translates to:
  /// **'YARA rules loaded'**
  String get yaraRulesLoaded;

  /// yaraNotAvailable
  ///
  /// In en, this message translates to:
  /// **'YARA engine not available'**
  String get yaraNotAvailable;

  /// yaraAuthor
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get yaraAuthor;

  /// yaraSeverity
  ///
  /// In en, this message translates to:
  /// **'Severity'**
  String get yaraSeverity;

  /// homeActiveModules
  ///
  /// In en, this message translates to:
  /// **'Active modules'**
  String get homeActiveModules;

  /// sectionBasicProtection
  ///
  /// In en, this message translates to:
  /// **'Basic Protection'**
  String get sectionBasicProtection;

  /// sectionAdvancedProtection
  ///
  /// In en, this message translates to:
  /// **'Advanced Protection'**
  String get sectionAdvancedProtection;

  /// sectionTools
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get sectionTools;

  /// sectionTechnologies
  ///
  /// In en, this message translates to:
  /// **'Scan Technologies'**
  String get sectionTechnologies;

  /// plannedBadge
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get plannedBadge;

  /// experimentalBadge
  ///
  /// In en, this message translates to:
  /// **'Experimental'**
  String get experimentalBadge;

  /// emailProtectionTitle
  ///
  /// In en, this message translates to:
  /// **'Email Antivirus'**
  String get emailProtectionTitle;

  /// emailProtectionDesc
  ///
  /// In en, this message translates to:
  /// **'Scan email attachments for viruses and phishing'**
  String get emailProtectionDesc;

  /// networkProtectionTitle
  ///
  /// In en, this message translates to:
  /// **'Network Attack Protection'**
  String get networkProtectionTitle;

  /// networkProtectionDesc
  ///
  /// In en, this message translates to:
  /// **'Detect and block network attacks (port scanning, ARP spoofing)'**
  String get networkProtectionDesc;

  /// amsiTitle
  ///
  /// In en, this message translates to:
  /// **'AMSI Integration'**
  String get amsiTitle;

  /// amsiDesc
  ///
  /// In en, this message translates to:
  /// **'Script inspection via Windows Antimalware Scan Interface'**
  String get amsiDesc;

  /// scriptGuardTitle
  ///
  /// In en, this message translates to:
  /// **'Script Guard'**
  String get scriptGuardTitle;

  /// scriptGuardDesc
  ///
  /// In en, this message translates to:
  /// **'Control execution of PowerShell, VBS, BAT scripts'**
  String get scriptGuardDesc;

  /// etwTitle
  ///
  /// In en, this message translates to:
  /// **'ETW Monitoring'**
  String get etwTitle;

  /// etwDesc
  ///
  /// In en, this message translates to:
  /// **'Windows kernel monitoring via Event Tracing (DLL loads, process creation)'**
  String get etwDesc;

  /// smartScanCacheTitle
  ///
  /// In en, this message translates to:
  /// **'Smart Scan Cache'**
  String get smartScanCacheTitle;

  /// smartScanCacheDesc
  ///
  /// In en, this message translates to:
  /// **'Skip re-scanning unchanged files'**
  String get smartScanCacheDesc;

  /// trustedReputationTitle
  ///
  /// In en, this message translates to:
  /// **'Trusted File Reputation'**
  String get trustedReputationTitle;

  /// trustedReputationDesc
  ///
  /// In en, this message translates to:
  /// **'Trust files with valid digital signatures from safe paths'**
  String get trustedReputationDesc;

  /// exclusionListTitle
  ///
  /// In en, this message translates to:
  /// **'Scan Exclusions'**
  String get exclusionListTitle;

  /// exclusionListDesc
  ///
  /// In en, this message translates to:
  /// **'Files and folders excluded from scanning'**
  String get exclusionListDesc;

  /// exclusionListEmpty
  ///
  /// In en, this message translates to:
  /// **'No exclusions configured'**
  String get exclusionListEmpty;

  /// exclusionListAdd
  ///
  /// In en, this message translates to:
  /// **'Add Exclusion'**
  String get exclusionListAdd;

  /// exclusionListAddHint
  ///
  /// In en, this message translates to:
  /// **'File path, folder, or mask (*.log)'**
  String get exclusionListAddHint;

  /// exclusionListRemoveConfirm
  ///
  /// In en, this message translates to:
  /// **'Remove from exclusions?'**
  String get exclusionListRemoveConfirm;

  /// exclusionListFolder
  ///
  /// In en, this message translates to:
  /// **'Select folder'**
  String get exclusionListFolder;

  /// exclusionListFile
  ///
  /// In en, this message translates to:
  /// **'Select file'**
  String get exclusionListFile;

  /// exclusionListMask
  ///
  /// In en, this message translates to:
  /// **'Enter mask'**
  String get exclusionListMask;

  /// onboardingWelcome
  ///
  /// In en, this message translates to:
  /// **'Welcome to Mentoring Protector'**
  String get onboardingWelcome;

  /// onboardingWelcomeDesc
  ///
  /// In en, this message translates to:
  /// **'Let\'s set up protection for your experience level. This will take less than a minute.'**
  String get onboardingWelcomeDesc;

  /// onboardingLevelTitle
  ///
  /// In en, this message translates to:
  /// **'Your Level'**
  String get onboardingLevelTitle;

  /// onboardingLevelDesc
  ///
  /// In en, this message translates to:
  /// **'How would you rate your cybersecurity experience?'**
  String get onboardingLevelDesc;

  /// onboardingBeginner
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get onboardingBeginner;

  /// onboardingBeginnerDesc
  ///
  /// In en, this message translates to:
  /// **'I\'m just starting to learn about security'**
  String get onboardingBeginnerDesc;

  /// onboardingRegular
  ///
  /// In en, this message translates to:
  /// **'Regular User'**
  String get onboardingRegular;

  /// onboardingRegularDesc
  ///
  /// In en, this message translates to:
  /// **'I know the basics but want to learn more'**
  String get onboardingRegularDesc;

  /// onboardingAdvanced
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get onboardingAdvanced;

  /// onboardingAdvancedDesc
  ///
  /// In en, this message translates to:
  /// **'I have strong IT security knowledge'**
  String get onboardingAdvancedDesc;

  /// onboardingGoalTitle
  ///
  /// In en, this message translates to:
  /// **'Your Goal'**
  String get onboardingGoalTitle;

  /// onboardingGoalDesc
  ///
  /// In en, this message translates to:
  /// **'What matters most to you?'**
  String get onboardingGoalDesc;

  /// onboardingGoalMax
  ///
  /// In en, this message translates to:
  /// **'Maximum Protection'**
  String get onboardingGoalMax;

  /// onboardingGoalMaxDesc
  ///
  /// In en, this message translates to:
  /// **'Block everything suspicious - better safe than sorry'**
  String get onboardingGoalMaxDesc;

  /// onboardingGoalBalanced
  ///
  /// In en, this message translates to:
  /// **'Balance of Convenience and Security'**
  String get onboardingGoalBalanced;

  /// onboardingGoalBalancedDesc
  ///
  /// In en, this message translates to:
  /// **'Warn me but don\'t get in the way'**
  String get onboardingGoalBalancedDesc;

  /// onboardingGoalLearn
  ///
  /// In en, this message translates to:
  /// **'I Want to Learn'**
  String get onboardingGoalLearn;

  /// onboardingGoalLearnDesc
  ///
  /// In en, this message translates to:
  /// **'Show detailed threat explanations and how to spot them'**
  String get onboardingGoalLearnDesc;

  /// onboardingStart
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingStart;

  /// onboardingNext
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// onboardingBack
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get onboardingBack;

  /// profileTitle
  ///
  /// In en, this message translates to:
  /// **'Security Profile'**
  String get profileTitle;

  /// profileLevel
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get profileLevel;

  /// profileRiskScore
  ///
  /// In en, this message translates to:
  /// **'Risk Index'**
  String get profileRiskScore;

  /// profileSafetyScore
  ///
  /// In en, this message translates to:
  /// **'Safety Score'**
  String get profileSafetyScore;

  /// profileRiskTierSafe
  ///
  /// In en, this message translates to:
  /// **'Safe behavior'**
  String get profileRiskTierSafe;

  /// profileRiskTierCautious
  ///
  /// In en, this message translates to:
  /// **'Cautious behavior'**
  String get profileRiskTierCautious;

  /// profileRiskTierRisky
  ///
  /// In en, this message translates to:
  /// **'Some risky habits'**
  String get profileRiskTierRisky;

  /// profileRiskTierDangerous
  ///
  /// In en, this message translates to:
  /// **'Frequently ignores warnings'**
  String get profileRiskTierDangerous;

  /// profilePositiveActions
  ///
  /// In en, this message translates to:
  /// **'Positive actions'**
  String get profilePositiveActions;

  /// profileRiskyActions
  ///
  /// In en, this message translates to:
  /// **'Risky actions'**
  String get profileRiskyActions;

  /// profileRecentEvents
  ///
  /// In en, this message translates to:
  /// **'Recent Events'**
  String get profileRecentEvents;

  /// profileNoEvents
  ///
  /// In en, this message translates to:
  /// **'No events yet - keep it up!'**
  String get profileNoEvents;

  /// profileWhyRisky
  ///
  /// In en, this message translates to:
  /// **'Why the system considers you at risk'**
  String get profileWhyRisky;

  /// profileEventWebIgnored
  ///
  /// In en, this message translates to:
  /// **'Web protection warning ignored'**
  String get profileEventWebIgnored;

  /// profileEventScanIgnored
  ///
  /// In en, this message translates to:
  /// **'Detected threat ignored'**
  String get profileEventScanIgnored;

  /// profileEventProtDisabled
  ///
  /// In en, this message translates to:
  /// **'Protection module disabled'**
  String get profileEventProtDisabled;

  /// profileEventDangerDownload
  ///
  /// In en, this message translates to:
  /// **'Dangerous download'**
  String get profileEventDangerDownload;

  /// profileEventLesson
  ///
  /// In en, this message translates to:
  /// **'Training module completed'**
  String get profileEventLesson;

  /// profileEventProtEnabled
  ///
  /// In en, this message translates to:
  /// **'Protection module enabled'**
  String get profileEventProtEnabled;

  /// profileEventQuarantined
  ///
  /// In en, this message translates to:
  /// **'Threat quarantined'**
  String get profileEventQuarantined;

  /// dbStatusTitle
  ///
  /// In en, this message translates to:
  /// **'Database status'**
  String get dbStatusTitle;

  /// dbStatusUpdated
  ///
  /// In en, this message translates to:
  /// **'Up to date'**
  String get dbStatusUpdated;

  /// dbStatusOutdated
  ///
  /// In en, this message translates to:
  /// **'Needs update'**
  String get dbStatusOutdated;

  /// dbStatusNeverUpdated
  ///
  /// In en, this message translates to:
  /// **'Never updated'**
  String get dbStatusNeverUpdated;

  /// dbStatusLastUpdate
  ///
  /// In en, this message translates to:
  /// **'Last update'**
  String get dbStatusLastUpdate;

  /// dbStatusUpdate
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get dbStatusUpdate;

  /// dbStatusUpdating
  ///
  /// In en, this message translates to:
  /// **'Updating...'**
  String get dbStatusUpdating;

  /// dbUpdateFellBackPython
  ///
  /// In en, this message translates to:
  /// **'Updated via Python fallback (CVD parse failed)'**
  String get dbUpdateFellBackPython;

  /// dbUpdateMd5Failed
  ///
  /// In en, this message translates to:
  /// **'CVD checksum mismatch - skipping update'**
  String get dbUpdateMd5Failed;

  /// dbUpdateProgress
  ///
  /// In en, this message translates to:
  /// **'Downloading signature database…'**
  String get dbUpdateProgress;

  /// yaraRulesTitle
  ///
  /// In en, this message translates to:
  /// **'YARA Rules Engine'**
  String get yaraRulesTitle;

  /// yaraRulesCount
  ///
  /// In en, this message translates to:
  /// **'{count} rules loaded'**
  String yaraRulesCount(int count);

  /// yaraUnavailable
  ///
  /// In en, this message translates to:
  /// **'YARA engine not available'**
  String get yaraUnavailable;

  /// yaraReloadButton
  ///
  /// In en, this message translates to:
  /// **'Reload rules'**
  String get yaraReloadButton;

  /// yaraReloadSuccess
  ///
  /// In en, this message translates to:
  /// **'YARA rules reloaded successfully'**
  String get yaraReloadSuccess;

  /// yaraReloadFailed
  ///
  /// In en, this message translates to:
  /// **'Failed to reload YARA rules'**
  String get yaraReloadFailed;

  /// activeEnginesLabel
  ///
  /// In en, this message translates to:
  /// **'Active engines'**
  String get activeEnginesLabel;

  /// engineSignatures
  ///
  /// In en, this message translates to:
  /// **'Signatures'**
  String get engineSignatures;

  /// engineHeuristic
  ///
  /// In en, this message translates to:
  /// **'Heuristic'**
  String get engineHeuristic;

  /// engineYara
  ///
  /// In en, this message translates to:
  /// **'YARA'**
  String get engineYara;

  /// engineBloom
  ///
  /// In en, this message translates to:
  /// **'Bloom Filter'**
  String get engineBloom;

  /// windowMinimize
  ///
  /// In en, this message translates to:
  /// **'Minimize'**
  String get windowMinimize;

  /// windowMaximize
  ///
  /// In en, this message translates to:
  /// **'Maximize'**
  String get windowMaximize;

  /// windowRestore
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get windowRestore;

  /// windowClose
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get windowClose;

  /// eventThreatFound
  ///
  /// In en, this message translates to:
  /// **'Threat found: {name}'**
  String eventThreatFound(String name);

  /// eventScanComplete
  ///
  /// In en, this message translates to:
  /// **'Scan complete'**
  String get eventScanComplete;

  /// eventScanThreats
  ///
  /// In en, this message translates to:
  /// **'Threats found: {count}'**
  String eventScanThreats(int count);

  /// eventProtectionStarted
  ///
  /// In en, this message translates to:
  /// **'Real-time protection enabled'**
  String get eventProtectionStarted;

  /// eventProtectionStopped
  ///
  /// In en, this message translates to:
  /// **'Real-time protection disabled'**
  String get eventProtectionStopped;

  /// threatSuspiciousImports
  ///
  /// In en, this message translates to:
  /// **'Suspicious WinAPI imports'**
  String get threatSuspiciousImports;

  /// threatSuspiciousStrings
  ///
  /// In en, this message translates to:
  /// **'Suspicious strings'**
  String get threatSuspiciousStrings;

  /// threatOpenFileLocation
  ///
  /// In en, this message translates to:
  /// **'Open file location'**
  String get threatOpenFileLocation;

  /// threatVerdictClean
  ///
  /// In en, this message translates to:
  /// **'Clean'**
  String get threatVerdictClean;

  /// threatVerdictSuspicious
  ///
  /// In en, this message translates to:
  /// **'Suspicious'**
  String get threatVerdictSuspicious;

  /// threatVerdictLikelyMalicious
  ///
  /// In en, this message translates to:
  /// **'Likely malicious'**
  String get threatVerdictLikelyMalicious;

  /// threatVerdictMalicious
  ///
  /// In en, this message translates to:
  /// **'Malicious'**
  String get threatVerdictMalicious;

  /// threatVerdictUnknown
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get threatVerdictUnknown;

  /// threatSuspicionLevel
  ///
  /// In en, this message translates to:
  /// **'Suspicion level'**
  String get threatSuspicionLevel;

  /// threatPeFile
  ///
  /// In en, this message translates to:
  /// **'PE file'**
  String get threatPeFile;

  /// threatSigned
  ///
  /// In en, this message translates to:
  /// **'Signed'**
  String get threatSigned;

  /// threatCertRevoked
  ///
  /// In en, this message translates to:
  /// **'Certificate revoked'**
  String get threatCertRevoked;

  /// threatUnsigned
  ///
  /// In en, this message translates to:
  /// **'Unsigned'**
  String get threatUnsigned;

  /// threatEntropyValue
  ///
  /// In en, this message translates to:
  /// **'Entropy: {value}'**
  String threatEntropyValue(String value);

  /// threatSigRevokedTitle
  ///
  /// In en, this message translates to:
  /// **'Signature - CERTIFICATE REVOKED'**
  String get threatSigRevokedTitle;

  /// threatDigitalSignatureTitle
  ///
  /// In en, this message translates to:
  /// **'Digital signature'**
  String get threatDigitalSignatureTitle;

  /// threatSigner
  ///
  /// In en, this message translates to:
  /// **'Signer'**
  String get threatSigner;

  /// threatIssuer
  ///
  /// In en, this message translates to:
  /// **'Issuer'**
  String get threatIssuer;

  /// threatValidUntil
  ///
  /// In en, this message translates to:
  /// **'Valid until'**
  String get threatValidUntil;

  /// threatRevokedWarning
  ///
  /// In en, this message translates to:
  /// **'A revoked certificate means the signing key may have been compromised. The file should not be trusted.'**
  String get threatRevokedWarning;

  /// threatUnknownThreat
  ///
  /// In en, this message translates to:
  /// **'Unknown threat'**
  String get threatUnknownThreat;

  /// threatUnknownDesc
  ///
  /// In en, this message translates to:
  /// **'A suspicious file was detected.'**
  String get threatUnknownDesc;

  /// threatQuarantineStep
  ///
  /// In en, this message translates to:
  /// **'Place the file in quarantine'**
  String get threatQuarantineStep;

  /// threatAuthorPrefix
  ///
  /// In en, this message translates to:
  /// **'Author: {name}'**
  String threatAuthorPrefix(String name);

  /// vulnComponent
  ///
  /// In en, this message translates to:
  /// **'Component'**
  String get vulnComponent;

  /// vulnDescriptionLabel
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get vulnDescriptionLabel;

  /// vulnAutoFixButton
  ///
  /// In en, this message translates to:
  /// **'Fix automatically'**
  String get vulnAutoFixButton;

  /// vulnFixInProgress
  ///
  /// In en, this message translates to:
  /// **'Fixing…'**
  String get vulnFixInProgress;

  /// vulnFixSuccess
  ///
  /// In en, this message translates to:
  /// **'Fixed successfully'**
  String get vulnFixSuccess;

  /// vulnFixError
  ///
  /// In en, this message translates to:
  /// **'Fix failed'**
  String get vulnFixError;

  /// vulnFixUacDenied
  ///
  /// In en, this message translates to:
  /// **'You cancelled the UAC confirmation'**
  String get vulnFixUacDenied;

  /// vulnFixRebootRequired
  ///
  /// In en, this message translates to:
  /// **'Reboot required'**
  String get vulnFixRebootRequired;

  /// vulnFixRebootBody
  ///
  /// In en, this message translates to:
  /// **'This fix takes effect after a system restart. Would you like to restart now?'**
  String get vulnFixRebootBody;

  /// vulnFixRebootNow
  ///
  /// In en, this message translates to:
  /// **'Restart now'**
  String get vulnFixRebootNow;

  /// vulnFixRebootLater
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get vulnFixRebootLater;

  /// vulnFixRebootManual
  ///
  /// In en, this message translates to:
  /// **'Please restart your computer to apply the changes'**
  String get vulnFixRebootManual;

  /// scanTimeSec
  ///
  /// In en, this message translates to:
  /// **'{sec} s'**
  String scanTimeSec(int sec);

  /// scanTimeMinSec
  ///
  /// In en, this message translates to:
  /// **'{min} min {sec} s'**
  String scanTimeMinSec(int min, int sec);

  /// memThreatLabel
  ///
  /// In en, this message translates to:
  /// **'Threat'**
  String get memThreatLabel;

  /// memPathLabel
  ///
  /// In en, this message translates to:
  /// **'Path'**
  String get memPathLabel;

  /// memMatchesLabel
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get memMatchesLabel;

  /// memRegionsLabel
  ///
  /// In en, this message translates to:
  /// **'Regions scanned'**
  String get memRegionsLabel;

  /// memMemoryScanned
  ///
  /// In en, this message translates to:
  /// **'Memory scanned'**
  String get memMemoryScanned;

  /// memMb
  ///
  /// In en, this message translates to:
  /// **'MB'**
  String get memMb;

  /// memDetectedSignatures
  ///
  /// In en, this message translates to:
  /// **'Detected signatures:'**
  String get memDetectedSignatures;

  /// processFunctionUnavailable
  ///
  /// In en, this message translates to:
  /// **'Function unavailable in current DLL version'**
  String get processFunctionUnavailable;

  /// processErrorPrefix
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String processErrorPrefix(String message);

  /// processPathLabel
  ///
  /// In en, this message translates to:
  /// **'Path'**
  String get processPathLabel;

  /// processVerdictLabel
  ///
  /// In en, this message translates to:
  /// **'Verdict'**
  String get processVerdictLabel;

  /// processDangerLevel
  ///
  /// In en, this message translates to:
  /// **'Danger level'**
  String get processDangerLevel;

  /// processSuspicionScore
  ///
  /// In en, this message translates to:
  /// **'Suspicion score'**
  String get processSuspicionScore;

  /// processThreatLabel
  ///
  /// In en, this message translates to:
  /// **'Threat'**
  String get processThreatLabel;

  /// processDetectionMethod
  ///
  /// In en, this message translates to:
  /// **'Detection method'**
  String get processDetectionMethod;

  /// processRulesLabel
  ///
  /// In en, this message translates to:
  /// **'Rules'**
  String get processRulesLabel;

  /// processHashLabel
  ///
  /// In en, this message translates to:
  /// **'Hash'**
  String get processHashLabel;

  /// processTerminatedMsg
  ///
  /// In en, this message translates to:
  /// **'Process {name} terminated'**
  String processTerminatedMsg(String name);

  /// processTerminate
  ///
  /// In en, this message translates to:
  /// **'Terminate'**
  String get processTerminate;

  /// processAllow
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get processAllow;

  /// processWasTerminated
  ///
  /// In en, this message translates to:
  /// **'Process was terminated'**
  String get processWasTerminated;

  /// inspectButton
  ///
  /// In en, this message translates to:
  /// **'Inspect Process'**
  String get inspectButton;

  /// inspectTitle
  ///
  /// In en, this message translates to:
  /// **'Process Inspection'**
  String get inspectTitle;

  /// inspectBasicInfo
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get inspectBasicInfo;

  /// inspectParentPid
  ///
  /// In en, this message translates to:
  /// **'Parent PID'**
  String get inspectParentPid;

  /// inspectProcessName
  ///
  /// In en, this message translates to:
  /// **'Process'**
  String get inspectProcessName;

  /// inspectSignature
  ///
  /// In en, this message translates to:
  /// **'Signature'**
  String get inspectSignature;

  /// inspectCmdline
  ///
  /// In en, this message translates to:
  /// **'Command line'**
  String get inspectCmdline;

  /// inspectFileHash
  ///
  /// In en, this message translates to:
  /// **'File hash'**
  String get inspectFileHash;

  /// inspectModules
  ///
  /// In en, this message translates to:
  /// **'{count} loaded modules'**
  String inspectModules(int count);

  /// exclusionMaskType
  ///
  /// In en, this message translates to:
  /// **'Extension mask'**
  String get exclusionMaskType;

  /// exclusionFolderType
  ///
  /// In en, this message translates to:
  /// **'Folder'**
  String get exclusionFolderType;

  /// exclusionPathType
  ///
  /// In en, this message translates to:
  /// **'Path'**
  String get exclusionPathType;

  /// hygieneIndexTitle
  ///
  /// In en, this message translates to:
  /// **'Digital Hygiene Index'**
  String get hygieneIndexTitle;

  /// hygieneIndexGrowth
  ///
  /// In en, this message translates to:
  /// **'+{value} over the week'**
  String hygieneIndexGrowth(int value);

  /// hygieneIndexDecline
  ///
  /// In en, this message translates to:
  /// **'-{value} over the week'**
  String hygieneIndexDecline(int value);

  /// hygieneCompleted
  ///
  /// In en, this message translates to:
  /// **'Tips completed: {done} / {total}'**
  String hygieneCompleted(int done, int total);

  /// hygieneHistory
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get hygieneHistory;

  /// hygieneWeeklyTitle
  ///
  /// In en, this message translates to:
  /// **'Recommended for you'**
  String get hygieneWeeklyTitle;

  /// hygieneWeeklySubtitle
  ///
  /// In en, this message translates to:
  /// **'Based on your recent activity'**
  String get hygieneWeeklySubtitle;

  /// hygieneAllTips
  ///
  /// In en, this message translates to:
  /// **'All tips'**
  String get hygieneAllTips;

  /// hygieneTipDone
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get hygieneTipDone;

  /// hygieneTipMarkDone
  ///
  /// In en, this message translates to:
  /// **'Mark as done'**
  String get hygieneTipMarkDone;

  /// hygieneTipUndo
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get hygieneTipUndo;

  /// hygieneReasonWeb
  ///
  /// In en, this message translates to:
  /// **'You recently ignored a web warning'**
  String get hygieneReasonWeb;

  /// hygieneReasonScan
  ///
  /// In en, this message translates to:
  /// **'You recently ignored a detected threat'**
  String get hygieneReasonScan;

  /// hygieneReasonDownload
  ///
  /// In en, this message translates to:
  /// **'You recently downloaded a risky file'**
  String get hygieneReasonDownload;

  /// hygieneReasonProtection
  ///
  /// In en, this message translates to:
  /// **'You recently disabled a protection module'**
  String get hygieneReasonProtection;

  /// hygieneRecommended
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get hygieneRecommended;

  /// copyPath
  ///
  /// In en, this message translates to:
  /// **'Copy path'**
  String get copyPath;

  /// copyInstructions
  ///
  /// In en, this message translates to:
  /// **'Copy instructions'**
  String get copyInstructions;

  /// copiedToClipboard
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// quizTitle
  ///
  /// In en, this message translates to:
  /// **'Knowledge Check'**
  String get quizTitle;

  /// quizNext
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get quizNext;

  /// quizFinish
  ///
  /// In en, this message translates to:
  /// **'See results'**
  String get quizFinish;

  /// quizClose
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get quizClose;

  /// quizResultTitle
  ///
  /// In en, this message translates to:
  /// **'Quiz Complete!'**
  String get quizResultTitle;

  /// quizResultScore
  ///
  /// In en, this message translates to:
  /// **'{correct}/{total}'**
  String quizResultScore(int correct, int total);

  /// quizResultPerfect
  ///
  /// In en, this message translates to:
  /// **'Excellent! You know this topic well.'**
  String get quizResultPerfect;

  /// quizResultKeepLearning
  ///
  /// In en, this message translates to:
  /// **'Review the tip and try again to reinforce your knowledge.'**
  String get quizResultKeepLearning;

  /// quizTakeQuiz
  ///
  /// In en, this message translates to:
  /// **'Take quiz'**
  String get quizTakeQuiz;

  /// quizPassed
  ///
  /// In en, this message translates to:
  /// **'Quiz passed'**
  String get quizPassed;

  /// quizUpdateQ1
  ///
  /// In en, this message translates to:
  /// **'Why is it important to install OS and software updates?'**
  String get quizUpdateQ1;

  /// quizUpdateQ1A1
  ///
  /// In en, this message translates to:
  /// **'They fix security vulnerabilities that attackers exploit'**
  String get quizUpdateQ1A1;

  /// quizUpdateQ1A2
  ///
  /// In en, this message translates to:
  /// **'They only add new features'**
  String get quizUpdateQ1A2;

  /// quizUpdateQ1A3
  ///
  /// In en, this message translates to:
  /// **'They make the computer faster'**
  String get quizUpdateQ1A3;

  /// quizUpdateQ1Explain
  ///
  /// In en, this message translates to:
  /// **'Updates often patch known vulnerabilities (CVE). The WannaCry attack in 2017 exploited a flaw that had a patch available 2 months prior.'**
  String get quizUpdateQ1Explain;

  /// quizUpdateQ2
  ///
  /// In en, this message translates to:
  /// **'What should you do if an update requires a restart?'**
  String get quizUpdateQ2;

  /// quizUpdateQ2A1
  ///
  /// In en, this message translates to:
  /// **'Save your work and restart soon - don\'t delay for days'**
  String get quizUpdateQ2A1;

  /// quizUpdateQ2A2
  ///
  /// In en, this message translates to:
  /// **'Postpone it indefinitely - restarts are annoying'**
  String get quizUpdateQ2A2;

  /// quizUpdateQ2A3
  ///
  /// In en, this message translates to:
  /// **'Disable automatic updates entirely'**
  String get quizUpdateQ2A3;

  /// quizUpdateQ2Explain
  ///
  /// In en, this message translates to:
  /// **'Delaying restarts leaves your system exposed. Most attacks target known, already-patched vulnerabilities.'**
  String get quizUpdateQ2Explain;

  /// quizPasswordQ1
  ///
  /// In en, this message translates to:
  /// **'Which password is the most secure?'**
  String get quizPasswordQ1;

  /// quizPasswordQ1A1
  ///
  /// In en, this message translates to:
  /// **'A random phrase: \'correct horse battery staple\''**
  String get quizPasswordQ1A1;

  /// quizPasswordQ1A2
  ///
  /// In en, this message translates to:
  /// **'Your birth date: \'19052000\''**
  String get quizPasswordQ1A2;

  /// quizPasswordQ1A3
  ///
  /// In en, this message translates to:
  /// **'A simple modification: \'P@ssword123\''**
  String get quizPasswordQ1A3;

  /// quizPasswordQ1Explain
  ///
  /// In en, this message translates to:
  /// **'Random passphrases are long and hard to guess, yet easy to remember. Dictionary substitutions like P@ssword are well-known to attackers.'**
  String get quizPasswordQ1Explain;

  /// quizPasswordQ2
  ///
  /// In en, this message translates to:
  /// **'Why should you use a different password for each service?'**
  String get quizPasswordQ2;

  /// quizPasswordQ2A1
  ///
  /// In en, this message translates to:
  /// **'If one service is breached, attackers can\'t access your other accounts'**
  String get quizPasswordQ2A1;

  /// quizPasswordQ2A2
  ///
  /// In en, this message translates to:
  /// **'It\'s not really necessary - one strong password is enough'**
  String get quizPasswordQ2A2;

  /// quizPasswordQ2A3
  ///
  /// In en, this message translates to:
  /// **'Websites require it'**
  String get quizPasswordQ2A3;

  /// quizPasswordQ2Explain
  ///
  /// In en, this message translates to:
  /// **'Credential stuffing attacks test leaked passwords across many services. Unique passwords limit damage to just the breached service.'**
  String get quizPasswordQ2Explain;

  /// quizPhishingQ1
  ///
  /// In en, this message translates to:
  /// **'You receive an email from \'support@paypa1.com\' asking to verify your account. What do you do?'**
  String get quizPhishingQ1;

  /// quizPhishingQ1A1
  ///
  /// In en, this message translates to:
  /// **'Don\'t click - \'paypa1\' uses the digit 1 instead of the letter l'**
  String get quizPhishingQ1A1;

  /// quizPhishingQ1A2
  ///
  /// In en, this message translates to:
  /// **'Click the link and enter your login'**
  String get quizPhishingQ1A2;

  /// quizPhishingQ1A3
  ///
  /// In en, this message translates to:
  /// **'Forward the email to friends'**
  String get quizPhishingQ1A3;

  /// quizPhishingQ1Explain
  ///
  /// In en, this message translates to:
  /// **'Homoglyph attacks use similar-looking characters (1 vs l, 0 vs O). Always verify the exact domain spelling before clicking.'**
  String get quizPhishingQ1Explain;

  /// quizPhishingQ2
  ///
  /// In en, this message translates to:
  /// **'Which is the safest way to visit your bank\'s website?'**
  String get quizPhishingQ2;

  /// quizPhishingQ2A1
  ///
  /// In en, this message translates to:
  /// **'Type the URL manually in the address bar or use a saved bookmark'**
  String get quizPhishingQ2A1;

  /// quizPhishingQ2A2
  ///
  /// In en, this message translates to:
  /// **'Search for it in Google and click the first result'**
  String get quizPhishingQ2A2;

  /// quizPhishingQ2A3
  ///
  /// In en, this message translates to:
  /// **'Click a link in an email from the bank'**
  String get quizPhishingQ2A3;

  /// quizPhishingQ2Explain
  ///
  /// In en, this message translates to:
  /// **'Attackers can buy ads that appear above real search results, and spoofed emails are common. Manual entry or bookmarks are the safest.'**
  String get quizPhishingQ2Explain;

  /// quizPhishingQ3
  ///
  /// In en, this message translates to:
  /// **'A website shows a lock icon (HTTPS). Does this mean it\'s safe?'**
  String get quizPhishingQ3;

  /// quizPhishingQ3A1
  ///
  /// In en, this message translates to:
  /// **'No - HTTPS only means the connection is encrypted, not that the site is trustworthy'**
  String get quizPhishingQ3A1;

  /// quizPhishingQ3A2
  ///
  /// In en, this message translates to:
  /// **'Yes - the lock guarantees the site is legitimate'**
  String get quizPhishingQ3A2;

  /// quizPhishingQ3A3
  ///
  /// In en, this message translates to:
  /// **'Only if the lock is green'**
  String get quizPhishingQ3A3;

  /// quizPhishingQ3Explain
  ///
  /// In en, this message translates to:
  /// **'Free certificates (Let\'s Encrypt) mean phishing sites can also have HTTPS. The lock encrypts traffic but doesn\'t verify the site\'s intentions.'**
  String get quizPhishingQ3Explain;

  /// quizDownloadQ1
  ///
  /// In en, this message translates to:
  /// **'You need a program. What is the safest source?'**
  String get quizDownloadQ1;

  /// quizDownloadQ1A1
  ///
  /// In en, this message translates to:
  /// **'The official website of the developer or an official app store'**
  String get quizDownloadQ1A1;

  /// quizDownloadQ1A2
  ///
  /// In en, this message translates to:
  /// **'A torrent with \'cracked\' in the name'**
  String get quizDownloadQ1A2;

  /// quizDownloadQ1A3
  ///
  /// In en, this message translates to:
  /// **'A random download site from a search result'**
  String get quizDownloadQ1A3;

  /// quizDownloadQ1Explain
  ///
  /// In en, this message translates to:
  /// **'Third-party download sites and cracks often bundle malware. Official sources and stores verify software integrity.'**
  String get quizDownloadQ1Explain;

  /// quizDownloadQ2
  ///
  /// In en, this message translates to:
  /// **'A downloaded file has a double extension \'invoice.pdf.exe\'. What does this mean?'**
  String get quizDownloadQ2;

  /// quizDownloadQ2A1
  ///
  /// In en, this message translates to:
  /// **'It is an executable disguised as a PDF - likely malware'**
  String get quizDownloadQ2A1;

  /// quizDownloadQ2A2
  ///
  /// In en, this message translates to:
  /// **'It is a normal PDF document'**
  String get quizDownloadQ2A2;

  /// quizDownloadQ2A3
  ///
  /// In en, this message translates to:
  /// **'Windows added the extra extension automatically'**
  String get quizDownloadQ2A3;

  /// quizDownloadQ2Explain
  ///
  /// In en, this message translates to:
  /// **'Windows hides known extensions by default. Attackers add a fake extension before the real one (.exe) to trick users into opening malware.'**
  String get quizDownloadQ2Explain;

  /// quizWifiQ1
  ///
  /// In en, this message translates to:
  /// **'Why is public Wi-Fi (cafés, airports) dangerous?'**
  String get quizWifiQ1;

  /// quizWifiQ1A1
  ///
  /// In en, this message translates to:
  /// **'Attackers on the same network can intercept your unencrypted traffic'**
  String get quizWifiQ1A1;

  /// quizWifiQ1A2
  ///
  /// In en, this message translates to:
  /// **'It\'s always slower than mobile data'**
  String get quizWifiQ1A2;

  /// quizWifiQ1A3
  ///
  /// In en, this message translates to:
  /// **'Public Wi-Fi has no dangers if the site uses HTTPS'**
  String get quizWifiQ1A3;

  /// quizWifiQ1Explain
  ///
  /// In en, this message translates to:
  /// **'On public networks, attackers can run man-in-the-middle attacks. Use a VPN or avoid entering sensitive data on public Wi-Fi.'**
  String get quizWifiQ1Explain;

  /// quiz2faQ1
  ///
  /// In en, this message translates to:
  /// **'What is two-factor authentication (2FA)?'**
  String get quiz2faQ1;

  /// quiz2faQ1A1
  ///
  /// In en, this message translates to:
  /// **'An extra verification step (code via SMS/app) in addition to your password'**
  String get quiz2faQ1A1;

  /// quiz2faQ1A2
  ///
  /// In en, this message translates to:
  /// **'Using two different passwords'**
  String get quiz2faQ1A2;

  /// quiz2faQ1A3
  ///
  /// In en, this message translates to:
  /// **'Logging in from two devices at once'**
  String get quiz2faQ1A3;

  /// quiz2faQ1Explain
  ///
  /// In en, this message translates to:
  /// **'2FA requires something you know (password) + something you have (phone/token). Even if your password leaks, the attacker still can\'t log in without the second factor.'**
  String get quiz2faQ1Explain;

  /// hygieneUpdateDescBeginner
  ///
  /// In en, this message translates to:
  /// **'Install updates as soon as they appear - they fix holes that viruses use to break in.'**
  String get hygieneUpdateDescBeginner;

  /// hygieneUpdateDescAdvanced
  ///
  /// In en, this message translates to:
  /// **'Apply OS and application patches promptly. Zero-day exploits target known CVEs within hours of disclosure.'**
  String get hygieneUpdateDescAdvanced;

  /// hygienePasswordDescBeginner
  ///
  /// In en, this message translates to:
  /// **'Use a different long password for every site. A password manager remembers them all for you.'**
  String get hygienePasswordDescBeginner;

  /// hygienePasswordDescAdvanced
  ///
  /// In en, this message translates to:
  /// **'Use a password manager with unique 16+ char credentials per service. Enable breach monitoring (HaveIBeenPwned).'**
  String get hygienePasswordDescAdvanced;

  /// hygienePhishingDescBeginner
  ///
  /// In en, this message translates to:
  /// **'Don\'t click links in suspicious emails. Always check who sent the message and where the link actually goes.'**
  String get hygienePhishingDescBeginner;

  /// hygienePhishingDescAdvanced
  ///
  /// In en, this message translates to:
  /// **'Verify sender SPF/DKIM headers, inspect link destinations via hover, watch for homoglyph domains and URL shorteners.'**
  String get hygienePhishingDescAdvanced;

  /// hygieneDownloadDescBeginner
  ///
  /// In en, this message translates to:
  /// **'Only download programs from official websites. Cracked software almost always contains viruses.'**
  String get hygieneDownloadDescBeginner;

  /// hygieneDownloadDescAdvanced
  ///
  /// In en, this message translates to:
  /// **'Verify file hashes and digital signatures before execution. Use sandboxing for untrusted binaries.'**
  String get hygieneDownloadDescAdvanced;

  /// hygieneWifiDescBeginner
  ///
  /// In en, this message translates to:
  /// **'Don\'t enter passwords or bank details on public Wi-Fi. Use mobile data or a VPN instead.'**
  String get hygieneWifiDescBeginner;

  /// hygieneWifiDescAdvanced
  ///
  /// In en, this message translates to:
  /// **'Public networks enable MITM/ARP spoofing. Use WireGuard/OpenVPN; verify TLS certificate pinning on critical services.'**
  String get hygieneWifiDescAdvanced;

  /// hygiene2faDescBeginner
  ///
  /// In en, this message translates to:
  /// **'Turn on two-factor authentication - even if someone steals your password, they still can\'t log in.'**
  String get hygiene2faDescBeginner;

  /// hygiene2faDescAdvanced
  ///
  /// In en, this message translates to:
  /// **'Enable TOTP or FIDO2/WebAuthn. Avoid SMS-based 2FA where possible due to SIM-swap attacks.'**
  String get hygiene2faDescAdvanced;

  /// quizRetake
  ///
  /// In en, this message translates to:
  /// **'Retake quiz'**
  String get quizRetake;

  /// quizUpdateQ1A4
  ///
  /// In en, this message translates to:
  /// **'Updates are optional and not important'**
  String get quizUpdateQ1A4;

  /// quizUpdateQ2A4
  ///
  /// In en, this message translates to:
  /// **'Only install updates once a year'**
  String get quizUpdateQ2A4;

  /// quizUpdateQ3
  ///
  /// In en, this message translates to:
  /// **'What is a zero-day vulnerability?'**
  String get quizUpdateQ3;

  /// quizUpdateQ3A1
  ///
  /// In en, this message translates to:
  /// **'A flaw exploited before the developer releases a patch'**
  String get quizUpdateQ3A1;

  /// quizUpdateQ3A2
  ///
  /// In en, this message translates to:
  /// **'A virus that activates at midnight'**
  String get quizUpdateQ3A2;

  /// quizUpdateQ3A3
  ///
  /// In en, this message translates to:
  /// **'A computer that has been on for zero days'**
  String get quizUpdateQ3A3;

  /// quizUpdateQ3A4
  ///
  /// In en, this message translates to:
  /// **'A password that expires in zero days'**
  String get quizUpdateQ3A4;

  /// quizUpdateQ3Explain
  ///
  /// In en, this message translates to:
  /// **'Zero-day means the developer has had \'zero days\' to fix it. These are the most dangerous because no patch exists yet. Keeping software updated reduces the window of exposure.'**
  String get quizUpdateQ3Explain;

  /// quizPasswordQ1A4
  ///
  /// In en, this message translates to:
  /// **'A single word from the dictionary: \'sunshine\''**
  String get quizPasswordQ1A4;

  /// quizPasswordQ2A4
  ///
  /// In en, this message translates to:
  /// **'Browsers remember passwords automatically, no need to worry'**
  String get quizPasswordQ2A4;

  /// quizPasswordQ3
  ///
  /// In en, this message translates to:
  /// **'What is a password manager?'**
  String get quizPasswordQ3;

  /// quizPasswordQ3A1
  ///
  /// In en, this message translates to:
  /// **'A program that generates and securely stores unique passwords for each service'**
  String get quizPasswordQ3A1;

  /// quizPasswordQ3A2
  ///
  /// In en, this message translates to:
  /// **'A browser extension that shows saved passwords in plain text'**
  String get quizPasswordQ3A2;

  /// quizPasswordQ3A3
  ///
  /// In en, this message translates to:
  /// **'A text file where you write down all your passwords'**
  String get quizPasswordQ3A3;

  /// quizPasswordQ3A4
  ///
  /// In en, this message translates to:
  /// **'A setting in Windows that remembers your login'**
  String get quizPasswordQ3A4;

  /// quizPasswordQ3Explain
  ///
  /// In en, this message translates to:
  /// **'Password managers encrypt your vault with a master password. They generate random unique passwords, auto-fill login forms, and alert you about breaches.'**
  String get quizPasswordQ3Explain;

  /// quizPhishingQ1A4
  ///
  /// In en, this message translates to:
  /// **'Reply asking them to verify their identity'**
  String get quizPhishingQ1A4;

  /// quizPhishingQ2A4
  ///
  /// In en, this message translates to:
  /// **'Click a link from social media'**
  String get quizPhishingQ2A4;

  /// quizPhishingQ3A4
  ///
  /// In en, this message translates to:
  /// **'HTTPS doesn\'t matter at all'**
  String get quizPhishingQ3A4;

  /// quizDownloadQ1A4
  ///
  /// In en, this message translates to:
  /// **'A link from a stranger in a messaging app'**
  String get quizDownloadQ1A4;

  /// quizDownloadQ2A4
  ///
  /// In en, this message translates to:
  /// **'It\'s a compressed PDF for faster download'**
  String get quizDownloadQ2A4;

  /// quizDownloadQ3
  ///
  /// In en, this message translates to:
  /// **'What should you check before running a downloaded program?'**
  String get quizDownloadQ3;

  /// quizDownloadQ3A1
  ///
  /// In en, this message translates to:
  /// **'Its digital signature - a valid signature confirms the publisher\'s identity'**
  String get quizDownloadQ3A1;

  /// quizDownloadQ3A2
  ///
  /// In en, this message translates to:
  /// **'The file size - larger files are always safer'**
  String get quizDownloadQ3A2;

  /// quizDownloadQ3A3
  ///
  /// In en, this message translates to:
  /// **'The file icon - legitimate programs have professional icons'**
  String get quizDownloadQ3A3;

  /// quizDownloadQ3A4
  ///
  /// In en, this message translates to:
  /// **'Nothing - if the antivirus didn\'t block it, it\'s safe'**
  String get quizDownloadQ3A4;

  /// quizDownloadQ3Explain
  ///
  /// In en, this message translates to:
  /// **'Digital signatures verify that the file comes from the claimed publisher and hasn\'t been tampered with. Unsigned executables from the internet should be treated with extra caution.'**
  String get quizDownloadQ3Explain;

  /// quizWifiQ1A4
  ///
  /// In en, this message translates to:
  /// **'Public Wi-Fi is only dangerous if the network has no password'**
  String get quizWifiQ1A4;

  /// quizWifiQ2
  ///
  /// In en, this message translates to:
  /// **'What is a VPN and why use it on public Wi-Fi?'**
  String get quizWifiQ2;

  /// quizWifiQ2A1
  ///
  /// In en, this message translates to:
  /// **'It encrypts all your traffic through a secure tunnel, hiding it from network attackers'**
  String get quizWifiQ2A1;

  /// quizWifiQ2A2
  ///
  /// In en, this message translates to:
  /// **'It makes your internet faster'**
  String get quizWifiQ2A2;

  /// quizWifiQ2A3
  ///
  /// In en, this message translates to:
  /// **'It blocks all viruses automatically'**
  String get quizWifiQ2A3;

  /// quizWifiQ2A4
  ///
  /// In en, this message translates to:
  /// **'It replaces your antivirus'**
  String get quizWifiQ2A4;

  /// quizWifiQ2Explain
  ///
  /// In en, this message translates to:
  /// **'A VPN (Virtual Private Network) creates an encrypted tunnel between your device and a server. Even if an attacker intercepts your traffic on public Wi-Fi, they only see encrypted data.'**
  String get quizWifiQ2Explain;

  /// quizWifiQ3
  ///
  /// In en, this message translates to:
  /// **'You see a Wi-Fi network called \'Free_Airport_WiFi\' at the airport. What is the risk?'**
  String get quizWifiQ3;

  /// quizWifiQ3A1
  ///
  /// In en, this message translates to:
  /// **'It could be a fake hotspot set up by an attacker to intercept your data'**
  String get quizWifiQ3A1;

  /// quizWifiQ3A2
  ///
  /// In en, this message translates to:
  /// **'Free networks are always safe at airports'**
  String get quizWifiQ3A2;

  /// quizWifiQ3A3
  ///
  /// In en, this message translates to:
  /// **'The only risk is slow speed'**
  String get quizWifiQ3A3;

  /// quizWifiQ3A4
  ///
  /// In en, this message translates to:
  /// **'Airport Wi-Fi is monitored by security, so it\'s always safe'**
  String get quizWifiQ3A4;

  /// quizWifiQ3Explain
  ///
  /// In en, this message translates to:
  /// **'Evil twin attacks create fake hotspots mimicking legitimate networks. Always verify the official network name with staff and use a VPN.'**
  String get quizWifiQ3Explain;

  /// quiz2faQ1A4
  ///
  /// In en, this message translates to:
  /// **'Having two email accounts'**
  String get quiz2faQ1A4;

  /// quiz2faQ2
  ///
  /// In en, this message translates to:
  /// **'Which 2FA method is the most secure?'**
  String get quiz2faQ2;

  /// quiz2faQ2A1
  ///
  /// In en, this message translates to:
  /// **'A hardware key (FIDO2/YubiKey) or authenticator app (TOTP)'**
  String get quiz2faQ2A1;

  /// quiz2faQ2A2
  ///
  /// In en, this message translates to:
  /// **'SMS codes sent to your phone'**
  String get quiz2faQ2A2;

  /// quiz2faQ2A3
  ///
  /// In en, this message translates to:
  /// **'Email verification links'**
  String get quiz2faQ2A3;

  /// quiz2faQ2A4
  ///
  /// In en, this message translates to:
  /// **'Security questions (mother\'s maiden name, etc.)'**
  String get quiz2faQ2A4;

  /// quiz2faQ2Explain
  ///
  /// In en, this message translates to:
  /// **'Hardware keys and TOTP apps are resistant to phishing and SIM-swap attacks. SMS codes can be intercepted via SIM cloning. Security questions are easily guessable from social media.'**
  String get quiz2faQ2Explain;

  /// quiz2faQ3
  ///
  /// In en, this message translates to:
  /// **'You lose your phone with the authenticator app. What should you have prepared?'**
  String get quiz2faQ3;

  /// quiz2faQ3A1
  ///
  /// In en, this message translates to:
  /// **'Backup recovery codes stored in a safe place'**
  String get quiz2faQ3A1;

  /// quiz2faQ3A2
  ///
  /// In en, this message translates to:
  /// **'Nothing - you can always call support'**
  String get quiz2faQ3A2;

  /// quiz2faQ3A3
  ///
  /// In en, this message translates to:
  /// **'Another phone with the same app installed'**
  String get quiz2faQ3A3;

  /// quiz2faQ3A4
  ///
  /// In en, this message translates to:
  /// **'Your password is enough to recover access'**
  String get quiz2faQ3A4;

  /// quiz2faQ3Explain
  ///
  /// In en, this message translates to:
  /// **'Most services provide one-time backup codes when you set up 2FA. Store them offline (printed or in a password manager) - they are your emergency access if you lose your device.'**
  String get quiz2faQ3Explain;

  /// quizBackupQ1
  ///
  /// In en, this message translates to:
  /// **'What is the 3-2-1 backup rule?'**
  String get quizBackupQ1;

  /// quizBackupQ1A1
  ///
  /// In en, this message translates to:
  /// **'3 copies of data, on 2 different media types, with 1 copy offsite'**
  String get quizBackupQ1A1;

  /// quizBackupQ1A2
  ///
  /// In en, this message translates to:
  /// **'Back up 3 files, 2 times a day, to 1 drive'**
  String get quizBackupQ1A2;

  /// quizBackupQ1A3
  ///
  /// In en, this message translates to:
  /// **'Use 3 passwords, 2 accounts, 1 computer'**
  String get quizBackupQ1A3;

  /// quizBackupQ1A4
  ///
  /// In en, this message translates to:
  /// **'3 antivirus programs, 2 firewalls, 1 VPN'**
  String get quizBackupQ1A4;

  /// quizBackupQ1Explain
  ///
  /// In en, this message translates to:
  /// **'The 3-2-1 rule ensures that no single failure (hardware crash, ransomware, fire) can destroy all your data. Offsite means cloud or a physically separate location.'**
  String get quizBackupQ1Explain;

  /// quizBackupQ2
  ///
  /// In en, this message translates to:
  /// **'How can ransomware affect your backups?'**
  String get quizBackupQ2;

  /// quizBackupQ2A1
  ///
  /// In en, this message translates to:
  /// **'It can encrypt backups stored on connected drives, making them useless'**
  String get quizBackupQ2A1;

  /// quizBackupQ2A2
  ///
  /// In en, this message translates to:
  /// **'Ransomware only affects the operating system, not data files'**
  String get quizBackupQ2A2;

  /// quizBackupQ2A3
  ///
  /// In en, this message translates to:
  /// **'Backups are immune to ransomware'**
  String get quizBackupQ2A3;

  /// quizBackupQ2A4
  ///
  /// In en, this message translates to:
  /// **'Ransomware cannot spread to external drives'**
  String get quizBackupQ2A4;

  /// quizBackupQ2Explain
  ///
  /// In en, this message translates to:
  /// **'Ransomware encrypts everything it can access, including mounted backup drives. Keep at least one backup offline (disconnected) or use versioned cloud backups with immutable snapshots.'**
  String get quizBackupQ2Explain;

  /// quizBackupQ3
  ///
  /// In en, this message translates to:
  /// **'How often should you test your backups?'**
  String get quizBackupQ3;

  /// quizBackupQ3A1
  ///
  /// In en, this message translates to:
  /// **'Regularly - a backup you\'ve never tested might be corrupted or incomplete'**
  String get quizBackupQ3A1;

  /// quizBackupQ3A2
  ///
  /// In en, this message translates to:
  /// **'Never - if the backup completed without errors, it works'**
  String get quizBackupQ3A2;

  /// quizBackupQ3A3
  ///
  /// In en, this message translates to:
  /// **'Only after a disaster happens'**
  String get quizBackupQ3A3;

  /// quizBackupQ3A4
  ///
  /// In en, this message translates to:
  /// **'Once when you first set up the backup'**
  String get quizBackupQ3A4;

  /// quizBackupQ3Explain
  ///
  /// In en, this message translates to:
  /// **'Untested backups may contain corrupted files, missing data, or incompatible formats. Schedule periodic restore tests to verify your recovery process actually works.'**
  String get quizBackupQ3Explain;

  /// quizUsbQ1
  ///
  /// In en, this message translates to:
  /// **'You find a USB drive in the parking lot. What should you do?'**
  String get quizUsbQ1;

  /// quizUsbQ1A1
  ///
  /// In en, this message translates to:
  /// **'Do NOT plug it in - it could contain malware that runs automatically'**
  String get quizUsbQ1A1;

  /// quizUsbQ1A2
  ///
  /// In en, this message translates to:
  /// **'Plug it in to find the owner\'s contact information'**
  String get quizUsbQ1A2;

  /// quizUsbQ1A3
  ///
  /// In en, this message translates to:
  /// **'Scan it with antivirus first, then it\'s safe to open'**
  String get quizUsbQ1A3;

  /// quizUsbQ1A4
  ///
  /// In en, this message translates to:
  /// **'Format it and use it as your own'**
  String get quizUsbQ1A4;

  /// quizUsbQ1Explain
  ///
  /// In en, this message translates to:
  /// **'USB drop attacks are a real social engineering technique. Malicious USB devices can execute code automatically (BadUSB), install backdoors, or even physically damage hardware (USB Killer).'**
  String get quizUsbQ1Explain;

  /// quizUsbQ2
  ///
  /// In en, this message translates to:
  /// **'What is a \'BadUSB\' attack?'**
  String get quizUsbQ2;

  /// quizUsbQ2A1
  ///
  /// In en, this message translates to:
  /// **'A USB device that pretends to be a keyboard and types malicious commands'**
  String get quizUsbQ2A1;

  /// quizUsbQ2A2
  ///
  /// In en, this message translates to:
  /// **'A broken USB cable that damages your port'**
  String get quizUsbQ2A2;

  /// quizUsbQ2A3
  ///
  /// In en, this message translates to:
  /// **'A virus that spreads through USB hubs'**
  String get quizUsbQ2A3;

  /// quizUsbQ2A4
  ///
  /// In en, this message translates to:
  /// **'A fake USB charger that charges too slowly'**
  String get quizUsbQ2A4;

  /// quizUsbQ2Explain
  ///
  /// In en, this message translates to:
  /// **'BadUSB reprograms the USB controller firmware to impersonate a keyboard. It can type commands at superhuman speed, downloading and executing malware in seconds.'**
  String get quizUsbQ2Explain;

  /// quizUsbQ3
  ///
  /// In en, this message translates to:
  /// **'How can you safely use USB drives at work?'**
  String get quizUsbQ3;

  /// quizUsbQ3A1
  ///
  /// In en, this message translates to:
  /// **'Only use company-approved encrypted drives and disable autorun'**
  String get quizUsbQ3A1;

  /// quizUsbQ3A2
  ///
  /// In en, this message translates to:
  /// **'Any USB drive is fine as long as you scan it first'**
  String get quizUsbQ3A2;

  /// quizUsbQ3A3
  ///
  /// In en, this message translates to:
  /// **'Only use drives from trusted colleagues'**
  String get quizUsbQ3A3;

  /// quizUsbQ3A4
  ///
  /// In en, this message translates to:
  /// **'USB drives are outdated and never needed'**
  String get quizUsbQ3A4;

  /// quizUsbQ3Explain
  ///
  /// In en, this message translates to:
  /// **'Company-approved encrypted drives prevent data leaks if lost. Disabling autorun stops malware from executing automatically when a drive is inserted.'**
  String get quizUsbQ3Explain;

  /// quizPrivacyQ1
  ///
  /// In en, this message translates to:
  /// **'What information can websites collect about you without cookies?'**
  String get quizPrivacyQ1;

  /// quizPrivacyQ1A1
  ///
  /// In en, this message translates to:
  /// **'Browser fingerprint: screen resolution, installed fonts, timezone, and more'**
  String get quizPrivacyQ1A1;

  /// quizPrivacyQ1A2
  ///
  /// In en, this message translates to:
  /// **'Nothing at all - cookies are the only tracking method'**
  String get quizPrivacyQ1A2;

  /// quizPrivacyQ1A3
  ///
  /// In en, this message translates to:
  /// **'Only your IP address'**
  String get quizPrivacyQ1A3;

  /// quizPrivacyQ1A4
  ///
  /// In en, this message translates to:
  /// **'Only the pages you visit on that specific site'**
  String get quizPrivacyQ1A4;

  /// quizPrivacyQ1Explain
  ///
  /// In en, this message translates to:
  /// **'Browser fingerprinting combines dozens of technical details (screen size, GPU, fonts, timezone, language) into a unique identifier. Even without cookies, ~95% of users can be uniquely identified.'**
  String get quizPrivacyQ1Explain;

  /// quizPrivacyQ2
  ///
  /// In en, this message translates to:
  /// **'Why should you review app permissions on your phone?'**
  String get quizPrivacyQ2;

  /// quizPrivacyQ2A1
  ///
  /// In en, this message translates to:
  /// **'Apps may request access to camera, microphone, or contacts beyond what they need'**
  String get quizPrivacyQ2A1;

  /// quizPrivacyQ2A2
  ///
  /// In en, this message translates to:
  /// **'Permissions are always necessary for the app to function'**
  String get quizPrivacyQ2A2;

  /// quizPrivacyQ2A3
  ///
  /// In en, this message translates to:
  /// **'It\'s only important for paid apps'**
  String get quizPrivacyQ2A3;

  /// quizPrivacyQ2A4
  ///
  /// In en, this message translates to:
  /// **'Permissions don\'t affect your privacy'**
  String get quizPrivacyQ2A4;

  /// quizPrivacyQ2Explain
  ///
  /// In en, this message translates to:
  /// **'A flashlight app doesn\'t need access to your contacts or microphone. Excessive permissions may indicate data harvesting. Review and revoke unnecessary permissions regularly.'**
  String get quizPrivacyQ2Explain;

  /// quizPrivacyQ3
  ///
  /// In en, this message translates to:
  /// **'What is the safest approach to social media privacy?'**
  String get quizPrivacyQ3;

  /// quizPrivacyQ3A1
  ///
  /// In en, this message translates to:
  /// **'Set profiles to private and limit personal information shared publicly'**
  String get quizPrivacyQ3A1;

  /// quizPrivacyQ3A2
  ///
  /// In en, this message translates to:
  /// **'Public profiles are fine - only friends see your posts'**
  String get quizPrivacyQ3A2;

  /// quizPrivacyQ3A3
  ///
  /// In en, this message translates to:
  /// **'Share everything - transparency is modern'**
  String get quizPrivacyQ3A3;

  /// quizPrivacyQ3A4
  ///
  /// In en, this message translates to:
  /// **'Use a fake name and share freely'**
  String get quizPrivacyQ3A4;

  /// quizPrivacyQ3Explain
  ///
  /// In en, this message translates to:
  /// **'Public profiles expose personal data to social engineering attacks. Attackers use birthdays, pet names, school names to guess passwords and security questions.'**
  String get quizPrivacyQ3Explain;

  /// quizLockQ1
  ///
  /// In en, this message translates to:
  /// **'Why should your computer lock automatically after a few minutes?'**
  String get quizLockQ1;

  /// quizLockQ1A1
  ///
  /// In en, this message translates to:
  /// **'Anyone nearby could access your files, email, and accounts while you\'re away'**
  String get quizLockQ1A1;

  /// quizLockQ1A2
  ///
  /// In en, this message translates to:
  /// **'It saves battery power'**
  String get quizLockQ1A2;

  /// quizLockQ1A3
  ///
  /// In en, this message translates to:
  /// **'It prevents the screen from burning in'**
  String get quizLockQ1A3;

  /// quizLockQ1A4
  ///
  /// In en, this message translates to:
  /// **'It\'s only important in offices, not at home'**
  String get quizLockQ1A4;

  /// quizLockQ1Explain
  ///
  /// In en, this message translates to:
  /// **'An unlocked computer is an open door. In seconds, someone can install malware, copy files, or access your accounts. Set auto-lock to 5 minutes or less.'**
  String get quizLockQ1Explain;

  /// quizLockQ2
  ///
  /// In en, this message translates to:
  /// **'Which is the safest way to unlock your computer?'**
  String get quizLockQ2;

  /// quizLockQ2A1
  ///
  /// In en, this message translates to:
  /// **'Biometrics (fingerprint/face) or a strong PIN combined with TPM'**
  String get quizLockQ2A1;

  /// quizLockQ2A2
  ///
  /// In en, this message translates to:
  /// **'A simple 4-digit PIN like 1234'**
  String get quizLockQ2A2;

  /// quizLockQ2A3
  ///
  /// In en, this message translates to:
  /// **'No password - it\'s faster'**
  String get quizLockQ2A3;

  /// quizLockQ2A4
  ///
  /// In en, this message translates to:
  /// **'A pattern drawn on the screen'**
  String get quizLockQ2A4;

  /// quizLockQ2Explain
  ///
  /// In en, this message translates to:
  /// **'Windows Hello biometrics + TPM provides strong local authentication. Simple PINs are easily guessable, and patterns can be observed or smudge-traced.'**
  String get quizLockQ2Explain;

  /// quizLockQ3
  ///
  /// In en, this message translates to:
  /// **'What is Windows Hello?'**
  String get quizLockQ3;

  /// quizLockQ3A1
  ///
  /// In en, this message translates to:
  /// **'A built-in authentication system using fingerprint, face recognition, or secure PIN'**
  String get quizLockQ3A1;

  /// quizLockQ3A2
  ///
  /// In en, this message translates to:
  /// **'A greeting message when Windows starts'**
  String get quizLockQ3A2;

  /// quizLockQ3A3
  ///
  /// In en, this message translates to:
  /// **'A voice assistant like Cortana'**
  String get quizLockQ3A3;

  /// quizLockQ3A4
  ///
  /// In en, this message translates to:
  /// **'A parental control feature'**
  String get quizLockQ3A4;

  /// quizLockQ3Explain
  ///
  /// In en, this message translates to:
  /// **'Windows Hello stores biometric data locally in TPM hardware, not in the cloud. It\'s more secure than passwords because biometrics can\'t be phished or reused across services.'**
  String get quizLockQ3Explain;

  /// quizExtQ1
  ///
  /// In en, this message translates to:
  /// **'What risk do browser extensions pose?'**
  String get quizExtQ1;

  /// quizExtQ1A1
  ///
  /// In en, this message translates to:
  /// **'They can read all data on every page you visit, including passwords and bank details'**
  String get quizExtQ1A1;

  /// quizExtQ1A2
  ///
  /// In en, this message translates to:
  /// **'They only affect the browser\'s appearance'**
  String get quizExtQ1A2;

  /// quizExtQ1A3
  ///
  /// In en, this message translates to:
  /// **'Extensions from the official store are always safe'**
  String get quizExtQ1A3;

  /// quizExtQ1A4
  ///
  /// In en, this message translates to:
  /// **'They can slow down the browser but nothing more'**
  String get quizExtQ1A4;

  /// quizExtQ1Explain
  ///
  /// In en, this message translates to:
  /// **'Extensions with \'Read and change all your data on all websites\' permission can see everything: passwords, credit cards, private messages. Only install extensions you truly need.'**
  String get quizExtQ1Explain;

  /// quizExtQ2
  ///
  /// In en, this message translates to:
  /// **'How should you choose which extensions to install?'**
  String get quizExtQ2;

  /// quizExtQ2A1
  ///
  /// In en, this message translates to:
  /// **'Install only essential ones from known developers, check permissions and reviews'**
  String get quizExtQ2A1;

  /// quizExtQ2A2
  ///
  /// In en, this message translates to:
  /// **'Install as many as possible for maximum functionality'**
  String get quizExtQ2A2;

  /// quizExtQ2A3
  ///
  /// In en, this message translates to:
  /// **'Only look at the star rating'**
  String get quizExtQ2A3;

  /// quizExtQ2A4
  ///
  /// In en, this message translates to:
  /// **'Friends\' recommendations are always trustworthy'**
  String get quizExtQ2A4;

  /// quizExtQ2Explain
  ///
  /// In en, this message translates to:
  /// **'Even popular extensions can be sold to malicious actors who push a trojanized update. Minimize installed extensions, review permissions, and remove ones you no longer use.'**
  String get quizExtQ2Explain;

  /// quizExtQ3
  ///
  /// In en, this message translates to:
  /// **'An extension you\'ve used for months suddenly requests new permissions. What do you do?'**
  String get quizExtQ3;

  /// quizExtQ3A1
  ///
  /// In en, this message translates to:
  /// **'Be suspicious - it may have been sold or compromised; research before accepting'**
  String get quizExtQ3A1;

  /// quizExtQ3A2
  ///
  /// In en, this message translates to:
  /// **'Accept immediately - updates always need new permissions'**
  String get quizExtQ3A2;

  /// quizExtQ3A3
  ///
  /// In en, this message translates to:
  /// **'Ignore the notification'**
  String get quizExtQ3A3;

  /// quizExtQ3A4
  ///
  /// In en, this message translates to:
  /// **'Uninstall and reinstall to fix the bug'**
  String get quizExtQ3A4;

  /// quizExtQ3Explain
  ///
  /// In en, this message translates to:
  /// **'Extension ownership can change hands. New owners may add tracking, ad injection, or data theft. Always research why new permissions are needed before granting them.'**
  String get quizExtQ3Explain;

  /// quizEncryptQ1
  ///
  /// In en, this message translates to:
  /// **'What does full disk encryption (BitLocker) protect against?'**
  String get quizEncryptQ1;

  /// quizEncryptQ1A1
  ///
  /// In en, this message translates to:
  /// **'Someone reading your data if the laptop is stolen or the drive is removed'**
  String get quizEncryptQ1A1;

  /// quizEncryptQ1A2
  ///
  /// In en, this message translates to:
  /// **'Viruses and malware'**
  String get quizEncryptQ1A2;

  /// quizEncryptQ1A3
  ///
  /// In en, this message translates to:
  /// **'Data loss from hardware failure'**
  String get quizEncryptQ1A3;

  /// quizEncryptQ1A4
  ///
  /// In en, this message translates to:
  /// **'Hackers accessing your computer over the network'**
  String get quizEncryptQ1A4;

  /// quizEncryptQ1Explain
  ///
  /// In en, this message translates to:
  /// **'Disk encryption protects data at rest. If someone steals your laptop, they cannot read the drive without your encryption key. It does NOT protect against malware or network attacks.'**
  String get quizEncryptQ1Explain;

  /// quizEncryptQ2
  ///
  /// In en, this message translates to:
  /// **'What happens to encrypted data if you forget the recovery key?'**
  String get quizEncryptQ2;

  /// quizEncryptQ2A1
  ///
  /// In en, this message translates to:
  /// **'The data becomes permanently inaccessible - there is no backdoor'**
  String get quizEncryptQ2A1;

  /// quizEncryptQ2A2
  ///
  /// In en, this message translates to:
  /// **'Microsoft can recover it for you'**
  String get quizEncryptQ2A2;

  /// quizEncryptQ2A3
  ///
  /// In en, this message translates to:
  /// **'The data is only temporarily locked for 24 hours'**
  String get quizEncryptQ2A3;

  /// quizEncryptQ2A4
  ///
  /// In en, this message translates to:
  /// **'You can bypass encryption with Safe Mode'**
  String get quizEncryptQ2A4;

  /// quizEncryptQ2Explain
  ///
  /// In en, this message translates to:
  /// **'Strong encryption means even the manufacturer cannot recover your data without the key. Save your BitLocker recovery key in your Microsoft account or print it and store it safely.'**
  String get quizEncryptQ2Explain;

  /// quizEncryptQ3
  ///
  /// In en, this message translates to:
  /// **'When should you use encrypted messaging (Signal, WhatsApp)?'**
  String get quizEncryptQ3;

  /// quizEncryptQ3A1
  ///
  /// In en, this message translates to:
  /// **'For any sensitive conversations - end-to-end encryption prevents interception'**
  String get quizEncryptQ3A1;

  /// quizEncryptQ3A2
  ///
  /// In en, this message translates to:
  /// **'Only for illegal activities'**
  String get quizEncryptQ3A2;

  /// quizEncryptQ3A3
  ///
  /// In en, this message translates to:
  /// **'Regular messaging apps are equally secure'**
  String get quizEncryptQ3A3;

  /// quizEncryptQ3A4
  ///
  /// In en, this message translates to:
  /// **'Encryption is only needed for businesses'**
  String get quizEncryptQ3A4;

  /// quizEncryptQ3Explain
  ///
  /// In en, this message translates to:
  /// **'End-to-end encryption ensures only you and the recipient can read messages. Not even the service provider can access them. Use it for personal, financial, or medical discussions.'**
  String get quizEncryptQ3Explain;

  /// quizUpdateQ4
  ///
  /// In en, this message translates to:
  /// **'What is the danger of using End of Life (EOL) software?'**
  String get quizUpdateQ4;

  /// quizUpdateQ4A1
  ///
  /// In en, this message translates to:
  /// **'Security patches are no longer released, leaving vulnerabilities permanently open'**
  String get quizUpdateQ4A1;

  /// quizUpdateQ4A2
  ///
  /// In en, this message translates to:
  /// **'It runs slower than newer versions'**
  String get quizUpdateQ4A2;

  /// quizUpdateQ4A3
  ///
  /// In en, this message translates to:
  /// **'It takes up more disk space'**
  String get quizUpdateQ4A3;

  /// quizUpdateQ4A4
  ///
  /// In en, this message translates to:
  /// **'The developer can delete it remotely'**
  String get quizUpdateQ4A4;

  /// quizUpdateQ4Explain
  ///
  /// In en, this message translates to:
  /// **'End-of-life software (like Windows 7) no longer receives security updates. All discovered vulnerabilities remain open forever, making the system an easy target for attackers.'**
  String get quizUpdateQ4Explain;

  /// quizUpdateQ5
  ///
  /// In en, this message translates to:
  /// **'What risk does auto-updating carry?'**
  String get quizUpdateQ5;

  /// quizUpdateQ5A1
  ///
  /// In en, this message translates to:
  /// **'Minimal - security benefits outweigh rare glitches'**
  String get quizUpdateQ5A1;

  /// quizUpdateQ5A2
  ///
  /// In en, this message translates to:
  /// **'High - updates always break the system'**
  String get quizUpdateQ5A2;

  /// quizUpdateQ5A3
  ///
  /// In en, this message translates to:
  /// **'None - updates cannot be tampered with'**
  String get quizUpdateQ5A3;

  /// quizUpdateQ5A4
  ///
  /// In en, this message translates to:
  /// **'Updates permanently slow down the computer'**
  String get quizUpdateQ5A4;

  /// quizUpdateQ5Explain
  ///
  /// In en, this message translates to:
  /// **'Auto-update is best practice: it patches vulnerabilities faster than attackers can exploit them. Rare glitches after updates are easily fixable, but unpatched vulnerabilities are not.'**
  String get quizUpdateQ5Explain;

  /// quizPasswordQ4
  ///
  /// In en, this message translates to:
  /// **'What makes a password truly strong?'**
  String get quizPasswordQ4;

  /// quizPasswordQ4A1
  ///
  /// In en, this message translates to:
  /// **'Length of 12+ characters and randomness - not dictionary words or personal data'**
  String get quizPasswordQ4A1;

  /// quizPasswordQ4A2
  ///
  /// In en, this message translates to:
  /// **'Replacing letters with symbols: P@\$\$w0rd'**
  String get quizPasswordQ4A2;

  /// quizPasswordQ4A3
  ///
  /// In en, this message translates to:
  /// **'Using your birthdate - easy to remember'**
  String get quizPasswordQ4A3;

  /// quizPasswordQ4A4
  ///
  /// In en, this message translates to:
  /// **'Short but with an exclamation mark: Go!1'**
  String get quizPasswordQ4A4;

  /// quizPasswordQ4Explain
  ///
  /// In en, this message translates to:
  /// **'Length matters more than complexity. A 12-character random lowercase password is stronger than an 8-character one with special characters. Substitutions (@=a, 0=o) have long been in attackers\' dictionaries.'**
  String get quizPasswordQ4Explain;

  /// quizPasswordQ5
  ///
  /// In en, this message translates to:
  /// **'Why is password reuse dangerous?'**
  String get quizPasswordQ5;

  /// quizPasswordQ5A1
  ///
  /// In en, this message translates to:
  /// **'A breach on one site gives attackers access to all your accounts'**
  String get quizPasswordQ5A1;

  /// quizPasswordQ5A2
  ///
  /// In en, this message translates to:
  /// **'Websites will know you\'re the same person'**
  String get quizPasswordQ5A2;

  /// quizPasswordQ5A3
  ///
  /// In en, this message translates to:
  /// **'The browser will stop saving passwords'**
  String get quizPasswordQ5A3;

  /// quizPasswordQ5A4
  ///
  /// In en, this message translates to:
  /// **'It\'s prohibited by security policy'**
  String get quizPasswordQ5A4;

  /// quizPasswordQ5Explain
  ///
  /// In en, this message translates to:
  /// **'Credential stuffing is an attack where stolen login/password pairs are automatically tested on hundreds of services. If your password is the same everywhere, one breach opens access to everything.'**
  String get quizPasswordQ5Explain;

  /// quizWifiQ4
  ///
  /// In en, this message translates to:
  /// **'What is a captive portal and why is it risky?'**
  String get quizWifiQ4;

  /// quizWifiQ4A1
  ///
  /// In en, this message translates to:
  /// **'A login page on public Wi-Fi - can be spoofed to steal credentials'**
  String get quizWifiQ4A1;

  /// quizWifiQ4A2
  ///
  /// In en, this message translates to:
  /// **'A program to speed up Wi-Fi'**
  String get quizWifiQ4A2;

  /// quizWifiQ4A3
  ///
  /// In en, this message translates to:
  /// **'A secure hotspot in a cafe'**
  String get quizWifiQ4A3;

  /// quizWifiQ4A4
  ///
  /// In en, this message translates to:
  /// **'An antivirus for routers'**
  String get quizWifiQ4A4;

  /// quizWifiQ4Explain
  ///
  /// In en, this message translates to:
  /// **'A captive portal is the login page you see on public Wi-Fi. An attacker can create a fake hotspot with a similar name and spoof the login page to harvest credentials.'**
  String get quizWifiQ4Explain;

  /// quizWifiQ5
  ///
  /// In en, this message translates to:
  /// **'What advantage does WPA3 have over WPA2?'**
  String get quizWifiQ5;

  /// quizWifiQ5A1
  ///
  /// In en, this message translates to:
  /// **'Protects against traffic interception even with weak passwords thanks to SAE protocol'**
  String get quizWifiQ5A1;

  /// quizWifiQ5A2
  ///
  /// In en, this message translates to:
  /// **'Works 3x faster'**
  String get quizWifiQ5A2;

  /// quizWifiQ5A3
  ///
  /// In en, this message translates to:
  /// **'Doesn\'t require a password at all'**
  String get quizWifiQ5A3;

  /// quizWifiQ5A4
  ///
  /// In en, this message translates to:
  /// **'Supports more devices'**
  String get quizWifiQ5A4;

  /// quizWifiQ5Explain
  ///
  /// In en, this message translates to:
  /// **'WPA3 uses the SAE (Simultaneous Authentication of Equals) protocol, which protects against offline password brute-forcing and KRACK-type attacks. Even with a weak password, intercepting traffic is significantly harder.'**
  String get quizWifiQ5Explain;

  /// quizPhishingQ4
  ///
  /// In en, this message translates to:
  /// **'What is spear-phishing?'**
  String get quizPhishingQ4;

  /// quizPhishingQ4A1
  ///
  /// In en, this message translates to:
  /// **'A targeted phishing attack using the victim\'s personal information'**
  String get quizPhishingQ4A1;

  /// quizPhishingQ4A2
  ///
  /// In en, this message translates to:
  /// **'Phishing via SMS messages'**
  String get quizPhishingQ4A2;

  /// quizPhishingQ4A3
  ///
  /// In en, this message translates to:
  /// **'Mass spam mailing'**
  String get quizPhishingQ4A3;

  /// quizPhishingQ4A4
  ///
  /// In en, this message translates to:
  /// **'Phishing only through social media'**
  String get quizPhishingQ4A4;

  /// quizPhishingQ4Explain
  ///
  /// In en, this message translates to:
  /// **'Spear-phishing is a personalized attack: the attacker researches the victim (job title, colleagues, projects) and crafts a convincing message. Its success rate is 10x higher than mass phishing.'**
  String get quizPhishingQ4Explain;

  /// quizPhishingQ5
  ///
  /// In en, this message translates to:
  /// **'How can you check if a link is safe before clicking?'**
  String get quizPhishingQ5;

  /// quizPhishingQ5A1
  ///
  /// In en, this message translates to:
  /// **'Hover over it and check the domain in the status bar without clicking'**
  String get quizPhishingQ5A1;

  /// quizPhishingQ5A2
  ///
  /// In en, this message translates to:
  /// **'Click and see what opens'**
  String get quizPhishingQ5A2;

  /// quizPhishingQ5A3
  ///
  /// In en, this message translates to:
  /// **'Check if the link looks nice'**
  String get quizPhishingQ5A3;

  /// quizPhishingQ5A4
  ///
  /// In en, this message translates to:
  /// **'Links are always safe if they came by email'**
  String get quizPhishingQ5A4;

  /// quizPhishingQ5Explain
  ///
  /// In en, this message translates to:
  /// **'Before clicking, hover over the link - the real URL appears in the browser status bar. Check the domain: gooogle.com, paypa1.com, sberbank-online.xyz are all phishing signs.'**
  String get quizPhishingQ5Explain;

  /// quizBackupQ4
  ///
  /// In en, this message translates to:
  /// **'What are versioned backups and why are they important?'**
  String get quizBackupQ4;

  /// quizBackupQ4A1
  ///
  /// In en, this message translates to:
  /// **'Storing multiple file copies from different dates - allows rolling back to a needed version'**
  String get quizBackupQ4A1;

  /// quizBackupQ4A2
  ///
  /// In en, this message translates to:
  /// **'Creating a backup every day in the same folder'**
  String get quizBackupQ4A2;

  /// quizBackupQ4A3
  ///
  /// In en, this message translates to:
  /// **'Using different passwords for each backup'**
  String get quizBackupQ4A3;

  /// quizBackupQ4A4
  ///
  /// In en, this message translates to:
  /// **'Copying files from different computers to one drive'**
  String get quizBackupQ4A4;

  /// quizBackupQ4Explain
  ///
  /// In en, this message translates to:
  /// **'Versioned backups store change history. If a file was corrupted a week ago but you noticed only today - you can restore an older version. Without versions, you\'d overwrite good data with damaged data.'**
  String get quizBackupQ4Explain;

  /// quizBackupQ5
  ///
  /// In en, this message translates to:
  /// **'Why are backups critical during a ransomware attack?'**
  String get quizBackupQ5;

  /// quizBackupQ5A1
  ///
  /// In en, this message translates to:
  /// **'They let you restore data without paying the ransom'**
  String get quizBackupQ5A1;

  /// quizBackupQ5A2
  ///
  /// In en, this message translates to:
  /// **'Ransomware can\'t infect backups'**
  String get quizBackupQ5A2;

  /// quizBackupQ5A3
  ///
  /// In en, this message translates to:
  /// **'Backups automatically remove the virus'**
  String get quizBackupQ5A3;

  /// quizBackupQ5A4
  ///
  /// In en, this message translates to:
  /// **'Police use backups to find hackers'**
  String get quizBackupQ5A4;

  /// quizBackupQ5Explain
  ///
  /// In en, this message translates to:
  /// **'Ransomware encrypts your files and demands payment. If you have an offline backup (disconnected from the network), you simply restore your data. Important: a backup on a connected drive can also be encrypted!'**
  String get quizBackupQ5Explain;

  /// quizDownloadQ4
  ///
  /// In en, this message translates to:
  /// **'Why is it dangerous to download from aggregator sites (Softonic, CNET Downloads)?'**
  String get quizDownloadQ4;

  /// quizDownloadQ4A1
  ///
  /// In en, this message translates to:
  /// **'They often bundle installers with adware and potentially unwanted programs'**
  String get quizDownloadQ4A1;

  /// quizDownloadQ4A2
  ///
  /// In en, this message translates to:
  /// **'Programs on aggregators always contain viruses'**
  String get quizDownloadQ4A2;

  /// quizDownloadQ4A3
  ///
  /// In en, this message translates to:
  /// **'They slow down download speed'**
  String get quizDownloadQ4A3;

  /// quizDownloadQ4A4
  ///
  /// In en, this message translates to:
  /// **'Aggregators are not available in all countries'**
  String get quizDownloadQ4A4;

  /// quizDownloadQ4Explain
  ///
  /// In en, this message translates to:
  /// **'Aggregators (Softonic, Download.com) often wrap the original installer in their own downloader with adware, toolbars, and potentially unwanted programs. Download directly from the developer\'s website.'**
  String get quizDownloadQ4Explain;

  /// quizDownloadQ5
  ///
  /// In en, this message translates to:
  /// **'How do attackers disguise malicious files?'**
  String get quizDownloadQ5;

  /// quizDownloadQ5A1
  ///
  /// In en, this message translates to:
  /// **'Using double extensions: document.pdf.exe appears as PDF'**
  String get quizDownloadQ5A1;

  /// quizDownloadQ5A2
  ///
  /// In en, this message translates to:
  /// **'Drawing an antivirus icon on it'**
  String get quizDownloadQ5A2;

  /// quizDownloadQ5A3
  ///
  /// In en, this message translates to:
  /// **'Renaming the file to \'antivirus\''**
  String get quizDownloadQ5A3;

  /// quizDownloadQ5A4
  ///
  /// In en, this message translates to:
  /// **'They don\'t - users download viruses themselves'**
  String get quizDownloadQ5A4;

  /// quizDownloadQ5Explain
  ///
  /// In en, this message translates to:
  /// **'Windows hides known extensions by default. A file \'report.pdf.exe\' displays as \'report.pdf\' with a PDF icon. Enable extension display: Explorer → View → File name extensions.'**
  String get quizDownloadQ5Explain;

  /// quiz2faQ4
  ///
  /// In en, this message translates to:
  /// **'Why is an authenticator app better than SMS for 2FA?'**
  String get quiz2faQ4;

  /// quiz2faQ4A1
  ///
  /// In en, this message translates to:
  /// **'SMS can be intercepted via SIM-swap attacks or SS7 vulnerabilities'**
  String get quiz2faQ4A1;

  /// quiz2faQ4A2
  ///
  /// In en, this message translates to:
  /// **'The app works offline'**
  String get quiz2faQ4A2;

  /// quiz2faQ4A3
  ///
  /// In en, this message translates to:
  /// **'SMS costs money'**
  String get quiz2faQ4A3;

  /// quiz2faQ4A4
  ///
  /// In en, this message translates to:
  /// **'The app looks better'**
  String get quiz2faQ4A4;

  /// quiz2faQ4Explain
  ///
  /// In en, this message translates to:
  /// **'SIM-swap: an attacker transfers your number to their SIM card through the carrier. SS7: a telephony protocol vulnerability allows SMS interception. An authenticator (TOTP) generates codes locally on the device.'**
  String get quiz2faQ4Explain;

  /// quiz2faQ5
  ///
  /// In en, this message translates to:
  /// **'What is TOTP and how does it work?'**
  String get quiz2faQ5;

  /// quiz2faQ5A1
  ///
  /// In en, this message translates to:
  /// **'A one-time code generated every 30 seconds based on a secret key and current time'**
  String get quiz2faQ5A1;

  /// quiz2faQ5A2
  ///
  /// In en, this message translates to:
  /// **'A permanent password sent by the server'**
  String get quiz2faQ5A2;

  /// quiz2faQ5A3
  ///
  /// In en, this message translates to:
  /// **'Encryption of communication between two devices'**
  String get quiz2faQ5A3;

  /// quiz2faQ5A4
  ///
  /// In en, this message translates to:
  /// **'Phone unlock technology using fingerprint'**
  String get quiz2faQ5A4;

  /// quiz2faQ5Explain
  ///
  /// In en, this message translates to:
  /// **'TOTP (Time-based One-Time Password) uses a shared secret key and current time to generate a 6-digit code. The code changes every 30 seconds and works only once - intercepting it is useless.'**
  String get quiz2faQ5Explain;

  /// quizUsbQ4
  ///
  /// In en, this message translates to:
  /// **'What is a USB Rubber Ducky attack?'**
  String get quizUsbQ4;

  /// quizUsbQ4A1
  ///
  /// In en, this message translates to:
  /// **'A device disguised as a keyboard that instantly types malicious commands'**
  String get quizUsbQ4A1;

  /// quizUsbQ4A2
  ///
  /// In en, this message translates to:
  /// **'A virus that wipes flash drive data'**
  String get quizUsbQ4A2;

  /// quizUsbQ4A3
  ///
  /// In en, this message translates to:
  /// **'A flash drive with extremely large storage'**
  String get quizUsbQ4A3;

  /// quizUsbQ4A4
  ///
  /// In en, this message translates to:
  /// **'A USB device for hacking Wi-Fi'**
  String get quizUsbQ4A4;

  /// quizUsbQ4Explain
  ///
  /// In en, this message translates to:
  /// **'USB Rubber Ducky looks like a regular flash drive, but the computer sees it as a keyboard. In seconds, it \'types\' a script: opens terminal, downloads malware, disables protection - faster than you can notice.'**
  String get quizUsbQ4Explain;

  /// quizUsbQ5
  ///
  /// In en, this message translates to:
  /// **'How can you safely check the contents of an unknown flash drive?'**
  String get quizUsbQ5;

  /// quizUsbQ5A1
  ///
  /// In en, this message translates to:
  /// **'Use an isolated virtual machine or a computer without network access'**
  String get quizUsbQ5A1;

  /// quizUsbQ5A2
  ///
  /// In en, this message translates to:
  /// **'Insert and quickly look - the virus won\'t have time to infect'**
  String get quizUsbQ5A2;

  /// quizUsbQ5A3
  ///
  /// In en, this message translates to:
  /// **'Format the drive before use'**
  String get quizUsbQ5A3;

  /// quizUsbQ5A4
  ///
  /// In en, this message translates to:
  /// **'Ask a friend to check on their computer'**
  String get quizUsbQ5A4;

  /// quizUsbQ5Explain
  ///
  /// In en, this message translates to:
  /// **'The safe way is a virtual machine (VirtualBox, Hyper-V) without network access. Even if the drive is infected, the virus stays inside the virtual environment and won\'t harm the main system.'**
  String get quizUsbQ5Explain;

  /// quizPrivacyQ4
  ///
  /// In en, this message translates to:
  /// **'What\'s dangerous about oversharing on social media?'**
  String get quizPrivacyQ4;

  /// quizPrivacyQ4A1
  ///
  /// In en, this message translates to:
  /// **'Attackers collect data for social engineering and password guessing'**
  String get quizPrivacyQ4A1;

  /// quizPrivacyQ4A2
  ///
  /// In en, this message translates to:
  /// **'Social media slows down from too many posts'**
  String get quizPrivacyQ4A2;

  /// quizPrivacyQ4A3
  ///
  /// In en, this message translates to:
  /// **'Friends might get offended by content'**
  String get quizPrivacyQ4A3;

  /// quizPrivacyQ4A4
  ///
  /// In en, this message translates to:
  /// **'Photos take up server space'**
  String get quizPrivacyQ4A4;

  /// quizPrivacyQ4Explain
  ///
  /// In en, this message translates to:
  /// **'Birthday, pet\'s name, favorite movie - common answers to security questions. Photo geolocation reveals routines. Trip information signals an empty apartment.'**
  String get quizPrivacyQ4Explain;

  /// quizPrivacyQ5
  ///
  /// In en, this message translates to:
  /// **'What do tracking cookies do?'**
  String get quizPrivacyQ5;

  /// quizPrivacyQ5A1
  ///
  /// In en, this message translates to:
  /// **'Track your behavior across websites to build an advertising profile'**
  String get quizPrivacyQ5A1;

  /// quizPrivacyQ5A2
  ///
  /// In en, this message translates to:
  /// **'Speed up page loading'**
  String get quizPrivacyQ5A2;

  /// quizPrivacyQ5A3
  ///
  /// In en, this message translates to:
  /// **'Protect against viruses'**
  String get quizPrivacyQ5A3;

  /// quizPrivacyQ5A4
  ///
  /// In en, this message translates to:
  /// **'Save website passwords'**
  String get quizPrivacyQ5A4;

  /// quizPrivacyQ5Explain
  ///
  /// In en, this message translates to:
  /// **'Third-party tracking cookies follow you across thousands of websites, building a detailed profile: interests, purchases, location. Use \'do not track\' mode and regularly clear cookies.'**
  String get quizPrivacyQ5Explain;

  /// quizLockQ4
  ///
  /// In en, this message translates to:
  /// **'What keyboard shortcut instantly locks Windows?'**
  String get quizLockQ4;

  /// quizLockQ4A1
  ///
  /// In en, this message translates to:
  /// **'Win + L - locks the screen instantly without closing programs'**
  String get quizLockQ4A1;

  /// quizLockQ4A2
  ///
  /// In en, this message translates to:
  /// **'Ctrl + Alt + Delete - shuts down the computer'**
  String get quizLockQ4A2;

  /// quizLockQ4A3
  ///
  /// In en, this message translates to:
  /// **'Alt + F4 - locks the current window'**
  String get quizLockQ4A3;

  /// quizLockQ4A4
  ///
  /// In en, this message translates to:
  /// **'Ctrl + Z - pauses the computer'**
  String get quizLockQ4A4;

  /// quizLockQ4Explain
  ///
  /// In en, this message translates to:
  /// **'Win + L is the fastest way to lock Windows. Building a habit of pressing Win + L every time you leave your seat protects against physical access. Programs continue running.'**
  String get quizLockQ4Explain;

  /// quizLockQ5
  ///
  /// In en, this message translates to:
  /// **'What is Dynamic Lock in Windows?'**
  String get quizLockQ5;

  /// quizLockQ5A1
  ///
  /// In en, this message translates to:
  /// **'Automatic computer lock when your Bluetooth device (phone) moves out of range'**
  String get quizLockQ5A1;

  /// quizLockQ5A2
  ///
  /// In en, this message translates to:
  /// **'Lock with a dynamically changing password'**
  String get quizLockQ5A2;

  /// quizLockQ5A3
  ///
  /// In en, this message translates to:
  /// **'Protection against system file changes'**
  String get quizLockQ5A3;

  /// quizLockQ5A4
  ///
  /// In en, this message translates to:
  /// **'A Windows antivirus feature'**
  String get quizLockQ5A4;

  /// quizLockQ5Explain
  ///
  /// In en, this message translates to:
  /// **'Dynamic Lock pairs with your phone via Bluetooth. When you walk away and the phone goes out of range, Windows automatically locks the screen in about 30 seconds.'**
  String get quizLockQ5Explain;

  /// quizExtQ4
  ///
  /// In en, this message translates to:
  /// **'Why is checking browser extension permissions important?'**
  String get quizExtQ4;

  /// quizExtQ4A1
  ///
  /// In en, this message translates to:
  /// **'An extension with \'access to all sites\' can read your passwords and card data'**
  String get quizExtQ4A1;

  /// quizExtQ4A2
  ///
  /// In en, this message translates to:
  /// **'Permissions affect browser speed'**
  String get quizExtQ4A2;

  /// quizExtQ4A3
  ///
  /// In en, this message translates to:
  /// **'Without permissions the extension won\'t install'**
  String get quizExtQ4A3;

  /// quizExtQ4A4
  ///
  /// In en, this message translates to:
  /// **'Permissions are only needed for paid extensions'**
  String get quizExtQ4A4;

  /// quizExtQ4Explain
  ///
  /// In en, this message translates to:
  /// **'An extension with \'Read and change data on all sites\' permission has full access to page content - including login forms, banking data, private messages. Grant minimum permissions.'**
  String get quizExtQ4Explain;

  /// quizExtQ5
  ///
  /// In en, this message translates to:
  /// **'How can you spot a fake browser extension?'**
  String get quizExtQ5;

  /// quizExtQ5A1
  ///
  /// In en, this message translates to:
  /// **'Few reviews, no official website link, requests excessive permissions'**
  String get quizExtQ5A1;

  /// quizExtQ5A2
  ///
  /// In en, this message translates to:
  /// **'It has an ugly icon'**
  String get quizExtQ5A2;

  /// quizExtQ5A3
  ///
  /// In en, this message translates to:
  /// **'It\'s free - must be fake'**
  String get quizExtQ5A3;

  /// quizExtQ5A4
  ///
  /// In en, this message translates to:
  /// **'There are no fake extensions in the Chrome Store'**
  String get quizExtQ5A4;

  /// quizExtQ5Explain
  ///
  /// In en, this message translates to:
  /// **'Signs of a fake: few downloads and reviews, developer name mismatch, excessive permissions, recent publication date. Verify the developer on the official product website.'**
  String get quizExtQ5Explain;

  /// quizEncryptQ4
  ///
  /// In en, this message translates to:
  /// **'Why is BitLocker full-disk encryption needed?'**
  String get quizEncryptQ4;

  /// quizEncryptQ4A1
  ///
  /// In en, this message translates to:
  /// **'Protects all disk data if the laptop is stolen or lost'**
  String get quizEncryptQ4A1;

  /// quizEncryptQ4A2
  ///
  /// In en, this message translates to:
  /// **'Speeds up disk reads'**
  String get quizEncryptQ4A2;

  /// quizEncryptQ4A3
  ///
  /// In en, this message translates to:
  /// **'Prevents virus infections'**
  String get quizEncryptQ4A3;

  /// quizEncryptQ4A4
  ///
  /// In en, this message translates to:
  /// **'Only needed for servers'**
  String get quizEncryptQ4A4;

  /// quizEncryptQ4Explain
  ///
  /// In en, this message translates to:
  /// **'Without BitLocker, removing the disk from a laptop and connecting it to another computer gives full access to all files. With BitLocker, data is encrypted and useless without the key tied to the TPM module.'**
  String get quizEncryptQ4Explain;

  /// quizEncryptQ5
  ///
  /// In en, this message translates to:
  /// **'What\'s the difference between HTTP and HTTPS?'**
  String get quizEncryptQ5;

  /// quizEncryptQ5A1
  ///
  /// In en, this message translates to:
  /// **'HTTPS encrypts traffic between browser and server; HTTP transmits data in plain text'**
  String get quizEncryptQ5A1;

  /// quizEncryptQ5A2
  ///
  /// In en, this message translates to:
  /// **'HTTPS is faster'**
  String get quizEncryptQ5A2;

  /// quizEncryptQ5A3
  ///
  /// In en, this message translates to:
  /// **'HTTP is for computers, HTTPS is for phones'**
  String get quizEncryptQ5A3;

  /// quizEncryptQ5A4
  ///
  /// In en, this message translates to:
  /// **'No difference - they\'re the same'**
  String get quizEncryptQ5A4;

  /// quizEncryptQ5Explain
  ///
  /// In en, this message translates to:
  /// **'HTTPS uses TLS encryption: everything you send (passwords, card data) is encrypted. In HTTP, data is sent in plain text - anyone on the same network can intercept it. Never enter passwords on HTTP sites.'**
  String get quizEncryptQ5Explain;

  /// enableAllProtection
  ///
  /// In en, this message translates to:
  /// **'Enable All Protection'**
  String get enableAllProtection;

  /// enableAllProtectionDesc
  ///
  /// In en, this message translates to:
  /// **'Activate all protection modules with one click'**
  String get enableAllProtectionDesc;

  /// allProtectionEnabled
  ///
  /// In en, this message translates to:
  /// **'All protection modules enabled'**
  String get allProtectionEnabled;

  /// disableAllProtection
  ///
  /// In en, this message translates to:
  /// **'Disable All Protection'**
  String get disableAllProtection;

  /// allProtectionDisabled
  ///
  /// In en, this message translates to:
  /// **'All protection modules disabled'**
  String get allProtectionDisabled;

  /// threatRemediationTitle
  ///
  /// In en, this message translates to:
  /// **'How to Remove'**
  String get threatRemediationTitle;

  /// threatInfectionVectorsTitle
  ///
  /// In en, this message translates to:
  /// **'How It Got Here'**
  String get threatInfectionVectorsTitle;

  /// threatPreventionTitle
  ///
  /// In en, this message translates to:
  /// **'How to Prevent'**
  String get threatPreventionTitle;

  /// threatRemTrojan
  ///
  /// In en, this message translates to:
  /// **'1. Quarantine or delete the file.\n2. Change passwords if the trojan could have intercepted them.\n3. Check startup programs (Win+R → msconfig → Startup).\n4. Run a full computer scan.'**
  String get threatRemTrojan;

  /// threatRemAdware
  ///
  /// In en, this message translates to:
  /// **'1. Uninstall the suspicious program via Settings → Apps.\n2. Reset browser settings.\n3. Check browser extensions and remove unknown ones.\n4. Clear temporary files.'**
  String get threatRemAdware;

  /// threatRemPup
  ///
  /// In en, this message translates to:
  /// **'1. Uninstall the program via Settings → Apps.\n2. Check if browser settings changed (home page, search engine).\n3. Remove associated browser extensions.'**
  String get threatRemPup;

  /// threatRemWorm
  ///
  /// In en, this message translates to:
  /// **'1. Immediately disconnect the computer from the network.\n2. Delete the file and run a full scan.\n3. Check all connected devices and flash drives.\n4. Change passwords for network accounts.'**
  String get threatRemWorm;

  /// threatRemRansom
  ///
  /// In en, this message translates to:
  /// **'1. DO NOT pay the ransom - it doesn\'t guarantee file recovery.\n2. Disconnect the computer from the network.\n3. Check for available backups.\n4. Consult a cybersecurity specialist.'**
  String get threatRemRansom;

  /// threatRemGeneric
  ///
  /// In en, this message translates to:
  /// **'1. Quarantine the file for safe storage.\n2. Run a full computer scan.\n3. Check the system for other suspicious files.'**
  String get threatRemGeneric;

  /// threatVecTrojan
  ///
  /// In en, this message translates to:
  /// **'• Downloading pirated software or cracks\n• Attachments in phishing emails\n• Fake software updates on websites\n• Infected USB drives'**
  String get threatVecTrojan;

  /// threatVecAdware
  ///
  /// In en, this message translates to:
  /// **'• Installing free software with bundled components\n• Clicking deceptive ads\n• Downloading from unverified sources'**
  String get threatVecAdware;

  /// threatVecPup
  ///
  /// In en, this message translates to:
  /// **'• Using \'Express\' install instead of \'Custom\'\n• Bundles during free software installation\n• Deceptive \'Download\' buttons on websites'**
  String get threatVecPup;

  /// threatVecWorm
  ///
  /// In en, this message translates to:
  /// **'• Vulnerabilities in network services\n• Infected files on local network\n• Autorun from USB devices\n• Exploits via unpatched software'**
  String get threatVecWorm;

  /// threatVecRansom
  ///
  /// In en, this message translates to:
  /// **'• Phishing emails with infected attachments\n• Exploit kits on compromised websites\n• RDP vulnerabilities (remote access)\n• Pirated software with embedded ransomware'**
  String get threatVecRansom;

  /// threatVecGeneric
  ///
  /// In en, this message translates to:
  /// **'• Downloading files from unverified sources\n• Clicking suspicious links\n• Connecting infected external devices'**
  String get threatVecGeneric;

  /// threatPrevTrojan
  ///
  /// In en, this message translates to:
  /// **'• Download software only from official websites\n• Don\'t open attachments from unknown senders\n• Keep your system and antivirus updated\n• Enable two-factor authentication on important accounts'**
  String get threatPrevTrojan;

  /// threatPrevAdware
  ///
  /// In en, this message translates to:
  /// **'• Always choose \'Custom\' installation\n• Don\'t click suspicious ads and banners\n• Use an ad blocker in your browser'**
  String get threatPrevAdware;

  /// threatPrevPup
  ///
  /// In en, this message translates to:
  /// **'• Read installation terms and uncheck additional programs\n• Download software only from official websites\n• Use a package manager (winget, chocolatey)'**
  String get threatPrevPup;

  /// threatPrevWorm
  ///
  /// In en, this message translates to:
  /// **'• Regularly install security updates\n• Use a firewall and don\'t disable it\n• Disable USB autorun\n• Don\'t connect unknown flash drives'**
  String get threatPrevWorm;

  /// threatPrevRansom
  ///
  /// In en, this message translates to:
  /// **'• Regularly create backups (3-2-1 rule)\n• Don\'t open suspicious attachments\n• Disable RDP if not in use\n• Keep OS and software updated'**
  String get threatPrevRansom;

  /// threatPrevGeneric
  ///
  /// In en, this message translates to:
  /// **'• Use antivirus with up-to-date databases\n• Don\'t download files from unverified sources\n• Regularly update your operating system\n• Be cautious with email attachments'**
  String get threatPrevGeneric;

  /// scanPause
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get scanPause;

  /// scanResume
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get scanResume;

  /// scanPaused
  ///
  /// In en, this message translates to:
  /// **'Scan paused'**
  String get scanPaused;

  /// quizSuggestionTitle
  ///
  /// In en, this message translates to:
  /// **'Learning Moment'**
  String get quizSuggestionTitle;

  /// quizSuggestionWeb
  ///
  /// In en, this message translates to:
  /// **'You encountered a phishing site. Take a quiz to better recognize such threats!'**
  String get quizSuggestionWeb;

  /// quizSuggestionScan
  ///
  /// In en, this message translates to:
  /// **'A threat was found during scanning. Learn how to prevent infections!'**
  String get quizSuggestionScan;

  /// quizSuggestionDownload
  ///
  /// In en, this message translates to:
  /// **'A dangerous file was detected. Take a quiz about safe file downloads!'**
  String get quizSuggestionDownload;

  /// quizSuggestionProtection
  ///
  /// In en, this message translates to:
  /// **'You disabled protection. Learn why keeping your system up to date is important!'**
  String get quizSuggestionProtection;

  /// quizSuggestionAction
  ///
  /// In en, this message translates to:
  /// **'Take Quiz'**
  String get quizSuggestionAction;

  /// quizSuggestionDismiss
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get quizSuggestionDismiss;

  /// quizLastResult
  ///
  /// In en, this message translates to:
  /// **'Last result'**
  String get quizLastResult;

  /// quizBestResult
  ///
  /// In en, this message translates to:
  /// **'Best result'**
  String get quizBestResult;

  /// quizAttempts
  ///
  /// In en, this message translates to:
  /// **'{count} attempts'**
  String quizAttempts(int count);

  /// quizNeverTaken
  ///
  /// In en, this message translates to:
  /// **'Not taken'**
  String get quizNeverTaken;

  /// hygieneBackupDescBeginner
  ///
  /// In en, this message translates to:
  /// **'Copy important files (photos, documents) to a flash drive or cloud. If your computer breaks or a virus encrypts files - you\'ll have a copy.'**
  String get hygieneBackupDescBeginner;

  /// hygieneBackupDescAdvanced
  ///
  /// In en, this message translates to:
  /// **'Follow the 3-2-1 rule: 3 copies, 2 different media, 1 offsite. Automate via task scheduler. Verify backup integrity regularly.'**
  String get hygieneBackupDescAdvanced;

  /// hygieneUsbDescBeginner
  ///
  /// In en, this message translates to:
  /// **'Never plug in found USB drives. Viruses can spread through them automatically, even without you clicking anything.'**
  String get hygieneUsbDescBeginner;

  /// hygieneUsbDescAdvanced
  ///
  /// In en, this message translates to:
  /// **'USB devices can emulate keyboards (Rubber Ducky) and execute commands. Use group policies to restrict USB. Check devices in an isolated environment.'**
  String get hygieneUsbDescAdvanced;

  /// hygienePrivacyDescBeginner
  ///
  /// In en, this message translates to:
  /// **'Don\'t post your address, phone number, or workplace on social media. Scammers collect such data for targeted attacks.'**
  String get hygienePrivacyDescBeginner;

  /// hygienePrivacyDescAdvanced
  ///
  /// In en, this message translates to:
  /// **'Minimize your digital footprint: disable geolocation in photos, use different emails for different services, set up DNS-over-HTTPS.'**
  String get hygienePrivacyDescAdvanced;

  /// hygieneLockDescBeginner
  ///
  /// In en, this message translates to:
  /// **'Always lock your computer when you step away: Win+L. Without locking, anyone can view your files or install a virus.'**
  String get hygieneLockDescBeginner;

  /// hygieneLockDescAdvanced
  ///
  /// In en, this message translates to:
  /// **'Use Windows Hello (biometrics) + Dynamic Lock (auto-lock when phone leaves). Set screen timeout to 1-2 minutes.'**
  String get hygieneLockDescAdvanced;

  /// hygieneExtensionsDescBeginner
  ///
  /// In en, this message translates to:
  /// **'Only install extensions from the official Chrome/Firefox store. Check reviews and user count before installing.'**
  String get hygieneExtensionsDescBeginner;

  /// hygieneExtensionsDescAdvanced
  ///
  /// In en, this message translates to:
  /// **'Audit extension permissions: if a calculator asks for access to \'all sites\' - that\'s a red flag. Regularly review your extension list.'**
  String get hygieneExtensionsDescAdvanced;

  /// hygieneEncryptionDescBeginner
  ///
  /// In en, this message translates to:
  /// **'Enable BitLocker on your Windows drive - if your laptop is stolen, data will be protected. Settings → Privacy → Encryption.'**
  String get hygieneEncryptionDescBeginner;

  /// hygieneEncryptionDescAdvanced
  ///
  /// In en, this message translates to:
  /// **'Use full-disk encryption (BitLocker/VeraCrypt). For sensitive files - container encryption. Store recovery keys in a secure location.'**
  String get hygieneEncryptionDescAdvanced;

  /// threatWhatItDoesTitle
  ///
  /// In en, this message translates to:
  /// **'What This Threat Does'**
  String get threatWhatItDoesTitle;

  /// threatDescriptionTitle
  ///
  /// In en, this message translates to:
  /// **'Detailed Description'**
  String get threatDescriptionTitle;

  /// threatEduLevelSignature
  ///
  /// In en, this message translates to:
  /// **'Data from knowledge base (exact match)'**
  String get threatEduLevelSignature;

  /// threatEduLevelFamily
  ///
  /// In en, this message translates to:
  /// **'Data from threat family (similar threat)'**
  String get threatEduLevelFamily;

  /// quizUpdateQ6
  ///
  /// In en, this message translates to:
  /// **'Why is it important to update not only the OS but also browsers?'**
  String get quizUpdateQ6;

  /// quizUpdateQ6A1
  ///
  /// In en, this message translates to:
  /// **'Browsers are the main attack target - you visit sites and download files through them'**
  String get quizUpdateQ6A1;

  /// quizUpdateQ6A2
  ///
  /// In en, this message translates to:
  /// **'Browser updates only add bookmarks'**
  String get quizUpdateQ6A2;

  /// quizUpdateQ6A3
  ///
  /// In en, this message translates to:
  /// **'Browsers don\'t need updates'**
  String get quizUpdateQ6A3;

  /// quizUpdateQ6A4
  ///
  /// In en, this message translates to:
  /// **'Updating the browser changes the search engine'**
  String get quizUpdateQ6A4;

  /// quizUpdateQ6Explain
  ///
  /// In en, this message translates to:
  /// **'The browser is the most attacked program: it processes JavaScript, renders HTML/CSS, and handles networking. Vulnerabilities in Chrome/Firefox are discovered weekly.'**
  String get quizUpdateQ6Explain;

  /// quizUpdateQ7
  ///
  /// In en, this message translates to:
  /// **'What happens if you postpone a Windows update for a month?'**
  String get quizUpdateQ7;

  /// quizUpdateQ7A1
  ///
  /// In en, this message translates to:
  /// **'The system remains vulnerable to already-patched attacks that are actively exploited'**
  String get quizUpdateQ7A1;

  /// quizUpdateQ7A2
  ///
  /// In en, this message translates to:
  /// **'Nothing serious - a month isn\'t critical'**
  String get quizUpdateQ7A2;

  /// quizUpdateQ7A3
  ///
  /// In en, this message translates to:
  /// **'Windows will stop working after a month'**
  String get quizUpdateQ7A3;

  /// quizUpdateQ7A4
  ///
  /// In en, this message translates to:
  /// **'Microsoft will block your license'**
  String get quizUpdateQ7A4;

  /// quizUpdateQ7Explain
  ///
  /// In en, this message translates to:
  /// **'Attackers study patches and create exploits within days. Every day without an update increases risk. Attacks on known CVEs are the most common infection vector.'**
  String get quizUpdateQ7Explain;

  /// quizUpdateQ8
  ///
  /// In en, this message translates to:
  /// **'What is a supply chain attack?'**
  String get quizUpdateQ8;

  /// quizUpdateQ8A1
  ///
  /// In en, this message translates to:
  /// **'An attacker injects malicious code into a legitimate update from the developer'**
  String get quizUpdateQ8A1;

  /// quizUpdateQ8A2
  ///
  /// In en, this message translates to:
  /// **'Delayed delivery of an update by mail'**
  String get quizUpdateQ8A2;

  /// quizUpdateQ8A3
  ///
  /// In en, this message translates to:
  /// **'Downloading updates from a slow server'**
  String get quizUpdateQ8A3;

  /// quizUpdateQ8A4
  ///
  /// In en, this message translates to:
  /// **'Developer refusing to release updates'**
  String get quizUpdateQ8A4;

  /// quizUpdateQ8Explain
  ///
  /// In en, this message translates to:
  /// **'SolarWinds attack (2020): hackers embedded a backdoor in a popular software update. 18,000 organizations installed the infected update. Rare but devastating.'**
  String get quizUpdateQ8Explain;

  /// quizUpdateQ9
  ///
  /// In en, this message translates to:
  /// **'How can you check that all programs on your computer are updated?'**
  String get quizUpdateQ9;

  /// quizUpdateQ9A1
  ///
  /// In en, this message translates to:
  /// **'Use an audit utility (Winget upgrade) or each program\'s built-in update check'**
  String get quizUpdateQ9A1;

  /// quizUpdateQ9A2
  ///
  /// In en, this message translates to:
  /// **'Check the install date in Control Panel'**
  String get quizUpdateQ9A2;

  /// quizUpdateQ9A3
  ///
  /// In en, this message translates to:
  /// **'If the program opens - it\'s updated'**
  String get quizUpdateQ9A3;

  /// quizUpdateQ9A4
  ///
  /// In en, this message translates to:
  /// **'Reinstall all programs once a year'**
  String get quizUpdateQ9A4;

  /// quizUpdateQ9Explain
  ///
  /// In en, this message translates to:
  /// **'Winget (built into Windows 11) can mass-update all programs with one command. Manual checking is ineffective - automate the process.'**
  String get quizUpdateQ9Explain;

  /// quizUpdateQ10
  ///
  /// In en, this message translates to:
  /// **'What are firmware updates and why are they important?'**
  String get quizUpdateQ10;

  /// quizUpdateQ10A1
  ///
  /// In en, this message translates to:
  /// **'Updates for device embedded software (BIOS, router) - they patch hardware-level vulnerabilities'**
  String get quizUpdateQ10A1;

  /// quizUpdateQ10A2
  ///
  /// In en, this message translates to:
  /// **'Updates to the device case design'**
  String get quizUpdateQ10A2;

  /// quizUpdateQ10A3
  ///
  /// In en, this message translates to:
  /// **'Installing a new processor'**
  String get quizUpdateQ10A3;

  /// quizUpdateQ10A4
  ///
  /// In en, this message translates to:
  /// **'Firmware updates automatically and needs no attention'**
  String get quizUpdateQ10A4;

  /// quizUpdateQ10Explain
  ///
  /// In en, this message translates to:
  /// **'A router firmware vulnerability can allow interception of all home traffic. BIOS/UEFI firmware affects security even before the OS loads.'**
  String get quizUpdateQ10Explain;

  /// quizPasswordQ6
  ///
  /// In en, this message translates to:
  /// **'What is a passkey and why is it better than a password?'**
  String get quizPasswordQ6;

  /// quizPasswordQ6A1
  ///
  /// In en, this message translates to:
  /// **'A cryptographic key on the device - impossible to brute-force or steal via phishing'**
  String get quizPasswordQ6A1;

  /// quizPasswordQ6A2
  ///
  /// In en, this message translates to:
  /// **'A very long password of 100 characters'**
  String get quizPasswordQ6A2;

  /// quizPasswordQ6A3
  ///
  /// In en, this message translates to:
  /// **'A password written on a physical key'**
  String get quizPasswordQ6A3;

  /// quizPasswordQ6A4
  ///
  /// In en, this message translates to:
  /// **'A biometric iris scan'**
  String get quizPasswordQ6A4;

  /// quizPasswordQ6Explain
  ///
  /// In en, this message translates to:
  /// **'Passkey (FIDO2) is a cryptographic key pair. The private key never leaves the device; the server only stores the public one. Phishing is impossible: the key is bound to the domain.'**
  String get quizPasswordQ6Explain;

  /// quizPasswordQ7
  ///
  /// In en, this message translates to:
  /// **'Why are security questions a weak protection?'**
  String get quizPasswordQ7;

  /// quizPasswordQ7A1
  ///
  /// In en, this message translates to:
  /// **'Answers can often be found on social media or guessed'**
  String get quizPasswordQ7A1;

  /// quizPasswordQ7A2
  ///
  /// In en, this message translates to:
  /// **'There are too few questions for reliability'**
  String get quizPasswordQ7A2;

  /// quizPasswordQ7A3
  ///
  /// In en, this message translates to:
  /// **'They only work in English'**
  String get quizPasswordQ7A3;

  /// quizPasswordQ7A4
  ///
  /// In en, this message translates to:
  /// **'Servers don\'t encrypt the answers'**
  String get quizPasswordQ7A4;

  /// quizPasswordQ7Explain
  ///
  /// In en, this message translates to:
  /// **'Mother\'s maiden name, pet\'s name - all on social media. In 2008, Sarah Palin\'s Yahoo account was hacked via a security question. Use random answers and store them in a password manager.'**
  String get quizPasswordQ7Explain;

  /// quizPasswordQ8
  ///
  /// In en, this message translates to:
  /// **'What is a brute force attack?'**
  String get quizPasswordQ8;

  /// quizPasswordQ8A1
  ///
  /// In en, this message translates to:
  /// **'Automated testing of all password combinations until the correct one is found'**
  String get quizPasswordQ8A1;

  /// quizPasswordQ8A2
  ///
  /// In en, this message translates to:
  /// **'Physically destroying a computer to extract data'**
  String get quizPasswordQ8A2;

  /// quizPasswordQ8A3
  ///
  /// In en, this message translates to:
  /// **'Using force to obtain a password from the owner'**
  String get quizPasswordQ8A3;

  /// quizPasswordQ8A4
  ///
  /// In en, this message translates to:
  /// **'A virus that deletes all passwords from the system'**
  String get quizPasswordQ8A4;

  /// quizPasswordQ8Explain
  ///
  /// In en, this message translates to:
  /// **'In brute force, a program tests billions of combinations per second. A 6-character password - seconds; 12+ random characters - thousands of years. Length is the best defense.'**
  String get quizPasswordQ8Explain;

  /// quizPasswordQ9
  ///
  /// In en, this message translates to:
  /// **'How can you check if your password has been leaked?'**
  String get quizPasswordQ9;

  /// quizPasswordQ9A1
  ///
  /// In en, this message translates to:
  /// **'Use Have I Been Pwned - it checks your email against breach databases'**
  String get quizPasswordQ9A1;

  /// quizPasswordQ9A2
  ///
  /// In en, this message translates to:
  /// **'Try logging into all accounts'**
  String get quizPasswordQ9A2;

  /// quizPasswordQ9A3
  ///
  /// In en, this message translates to:
  /// **'Call your email provider'**
  String get quizPasswordQ9A3;

  /// quizPasswordQ9A4
  ///
  /// In en, this message translates to:
  /// **'Password leaks cannot be detected'**
  String get quizPasswordQ9A4;

  /// quizPasswordQ9Explain
  ///
  /// In en, this message translates to:
  /// **'Have I Been Pwned contains billions of breached records. Password managers (Bitwarden, 1Password) also warn about leaks automatically.'**
  String get quizPasswordQ9Explain;

  /// quizPasswordQ10
  ///
  /// In en, this message translates to:
  /// **'Why is it dangerous to send passwords through messengers?'**
  String get quizPasswordQ10;

  /// quizPasswordQ10A1
  ///
  /// In en, this message translates to:
  /// **'Messages may be stored on the server or read on a compromised device'**
  String get quizPasswordQ10A1;

  /// quizPasswordQ10A2
  ///
  /// In en, this message translates to:
  /// **'Messengers compress text and the password may change'**
  String get quizPasswordQ10A2;

  /// quizPasswordQ10A3
  ///
  /// In en, this message translates to:
  /// **'Passwords can\'t be copied from messengers'**
  String get quizPasswordQ10A3;

  /// quizPasswordQ10A4
  ///
  /// In en, this message translates to:
  /// **'It\'s safe in an encrypted messenger'**
  String get quizPasswordQ10A4;

  /// quizPasswordQ10Explain
  ///
  /// In en, this message translates to:
  /// **'Even in an encrypted messenger, the password is visible on the recipient\'s screen. If their device is compromised - the password is compromised. Use password managers with secure sharing.'**
  String get quizPasswordQ10Explain;

  /// quizWifiQ6
  ///
  /// In en, this message translates to:
  /// **'Is it safe to make online purchases on public Wi-Fi?'**
  String get quizWifiQ6;

  /// quizWifiQ6A1
  ///
  /// In en, this message translates to:
  /// **'Better to wait - even with HTTPS, a DNS attack can substitute the site'**
  String get quizWifiQ6A1;

  /// quizWifiQ6A2
  ///
  /// In en, this message translates to:
  /// **'Yes, HTTPS fully protects transactions'**
  String get quizWifiQ6A2;

  /// quizWifiQ6A3
  ///
  /// In en, this message translates to:
  /// **'Yes, if the purchase amount is small'**
  String get quizWifiQ6A3;

  /// quizWifiQ6A4
  ///
  /// In en, this message translates to:
  /// **'Only through Wi-Fi without a password'**
  String get quizWifiQ6A4;

  /// quizWifiQ6Explain
  ///
  /// In en, this message translates to:
  /// **'HTTPS protects data but not from DNS spoofing or compromised certificates. For financial operations, use mobile data or a VPN.'**
  String get quizWifiQ6Explain;

  /// quizWifiQ7
  ///
  /// In en, this message translates to:
  /// **'How do you protect a home Wi-Fi router?'**
  String get quizWifiQ7;

  /// quizWifiQ7A1
  ///
  /// In en, this message translates to:
  /// **'Change the factory password, use WPA3, update firmware, disable WPS'**
  String get quizWifiQ7A1;

  /// quizWifiQ7A2
  ///
  /// In en, this message translates to:
  /// **'A complex Wi-Fi password is sufficient'**
  String get quizWifiQ7A2;

  /// quizWifiQ7A3
  ///
  /// In en, this message translates to:
  /// **'Hide the router - weak signal = security'**
  String get quizWifiQ7A3;

  /// quizWifiQ7A4
  ///
  /// In en, this message translates to:
  /// **'Home Wi-Fi doesn\'t need protection'**
  String get quizWifiQ7A4;

  /// quizWifiQ7Explain
  ///
  /// In en, this message translates to:
  /// **'Factory router passwords are known from databases. WPS has vulnerabilities. A combination: unique admin password + WPA3 + fresh firmware + WPS disabled.'**
  String get quizWifiQ7Explain;

  /// quizWifiQ8
  ///
  /// In en, this message translates to:
  /// **'What is an Evil Twin attack on Wi-Fi?'**
  String get quizWifiQ8;

  /// quizWifiQ8A1
  ///
  /// In en, this message translates to:
  /// **'A fake access point with the same name to intercept traffic'**
  String get quizWifiQ8A1;

  /// quizWifiQ8A2
  ///
  /// In en, this message translates to:
  /// **'Two routers conflicting with each other'**
  String get quizWifiQ8A2;

  /// quizWifiQ8A3
  ///
  /// In en, this message translates to:
  /// **'A virus that clones a laptop via Wi-Fi'**
  String get quizWifiQ8A3;

  /// quizWifiQ8A4
  ///
  /// In en, this message translates to:
  /// **'Connecting two devices to one network'**
  String get quizWifiQ8A4;

  /// quizWifiQ8Explain
  ///
  /// In en, this message translates to:
  /// **'The attacker creates an access point with the name of a real network. Your device connects automatically. All traffic passes through the attacker.'**
  String get quizWifiQ8Explain;

  /// quizWifiQ9
  ///
  /// In en, this message translates to:
  /// **'Why doesn\'t hiding the network name (SSID) protect Wi-Fi?'**
  String get quizWifiQ9;

  /// quizWifiQ9A1
  ///
  /// In en, this message translates to:
  /// **'Hidden networks are easily discovered with special tools - it\'s a security illusion'**
  String get quizWifiQ9A1;

  /// quizWifiQ9A2
  ///
  /// In en, this message translates to:
  /// **'Hiding SSID is the most reliable protection method'**
  String get quizWifiQ9A2;

  /// quizWifiQ9A3
  ///
  /// In en, this message translates to:
  /// **'Hidden networks work slower'**
  String get quizWifiQ9A3;

  /// quizWifiQ9A4
  ///
  /// In en, this message translates to:
  /// **'You can\'t connect to a hidden network'**
  String get quizWifiQ9A4;

  /// quizWifiQ9Explain
  ///
  /// In en, this message translates to:
  /// **'Airodump-ng discovers hidden networks in seconds - the name is transmitted in probe requests. Instead of hiding, use WPA3 and up-to-date firmware.'**
  String get quizWifiQ9Explain;

  /// quizWifiQ10
  ///
  /// In en, this message translates to:
  /// **'What is MAC filtering and why is it unreliable?'**
  String get quizWifiQ10;

  /// quizWifiQ10A1
  ///
  /// In en, this message translates to:
  /// **'Restricting access by MAC address - easily bypassed since MAC can be spoofed'**
  String get quizWifiQ10A1;

  /// quizWifiQ10A2
  ///
  /// In en, this message translates to:
  /// **'Filtering malicious websites'**
  String get quizWifiQ10A2;

  /// quizWifiQ10A3
  ///
  /// In en, this message translates to:
  /// **'Blocking Apple devices from connecting'**
  String get quizWifiQ10A3;

  /// quizWifiQ10A4
  ///
  /// In en, this message translates to:
  /// **'Router antivirus feature'**
  String get quizWifiQ10A4;

  /// quizWifiQ10Explain
  ///
  /// In en, this message translates to:
  /// **'The MAC address is transmitted in plain text. An attacker intercepts an allowed MAC and clones it in seconds. This is security through obscurity, not real protection.'**
  String get quizWifiQ10Explain;

  /// quizPhishingQ6
  ///
  /// In en, this message translates to:
  /// **'What is vishing?'**
  String get quizPhishingQ6;

  /// quizPhishingQ6A1
  ///
  /// In en, this message translates to:
  /// **'Phone phishing - a call from a \'bank\' to extract data'**
  String get quizPhishingQ6A1;

  /// quizPhishingQ6A2
  ///
  /// In en, this message translates to:
  /// **'Visual phishing through images'**
  String get quizPhishingQ6A2;

  /// quizPhishingQ6A3
  ///
  /// In en, this message translates to:
  /// **'Phishing through video calls'**
  String get quizPhishingQ6A3;

  /// quizPhishingQ6A4
  ///
  /// In en, this message translates to:
  /// **'Sending viruses through voice messages'**
  String get quizPhishingQ6A4;

  /// quizPhishingQ6Explain
  ///
  /// In en, this message translates to:
  /// **'Vishing uses calls with spoofed numbers. The scammer creates urgency: \'Your account is blocked, tell us the SMS code.\' Banks never ask for codes over the phone.'**
  String get quizPhishingQ6Explain;

  /// quizPhishingQ7
  ///
  /// In en, this message translates to:
  /// **'What is smishing?'**
  String get quizPhishingQ7;

  /// quizPhishingQ7A1
  ///
  /// In en, this message translates to:
  /// **'Phishing via SMS - a link to a fake site in a text message'**
  String get quizPhishingQ7A1;

  /// quizPhishingQ7A2
  ///
  /// In en, this message translates to:
  /// **'Phishing through smartwatches'**
  String get quizPhishingQ7A2;

  /// quizPhishingQ7A3
  ///
  /// In en, this message translates to:
  /// **'Sending viruses via Bluetooth'**
  String get quizPhishingQ7A3;

  /// quizPhishingQ7A4
  ///
  /// In en, this message translates to:
  /// **'SMS message encryption'**
  String get quizPhishingQ7A4;

  /// quizPhishingQ7Explain
  ///
  /// In en, this message translates to:
  /// **'Typical smishing: \'Your package is delayed, follow the link.\' The link leads to a fake site. Don\'t follow links from SMS.'**
  String get quizPhishingQ7Explain;

  /// quizPhishingQ8
  ///
  /// In en, this message translates to:
  /// **'How to recognize a phishing email besides checking the domain?'**
  String get quizPhishingQ8;

  /// quizPhishingQ8A1
  ///
  /// In en, this message translates to:
  /// **'Urgency, threats, errors, impersonal greeting, suspicious attachments'**
  String get quizPhishingQ8A1;

  /// quizPhishingQ8A2
  ///
  /// In en, this message translates to:
  /// **'Phishing emails always contain errors'**
  String get quizPhishingQ8A2;

  /// quizPhishingQ8A3
  ///
  /// In en, this message translates to:
  /// **'Phishing is only possible through email'**
  String get quizPhishingQ8A3;

  /// quizPhishingQ8A4
  ///
  /// In en, this message translates to:
  /// **'Emails from acquaintances are always safe'**
  String get quizPhishingQ8A4;

  /// quizPhishingQ8Explain
  ///
  /// In en, this message translates to:
  /// **'Red flags: \'Urgent!\', \'Account blocked\', impersonal greeting. AI generates convincing texts. Check the sender, links, and request logic.'**
  String get quizPhishingQ8Explain;

  /// quizPhishingQ9
  ///
  /// In en, this message translates to:
  /// **'What is a BEC attack (Business Email Compromise)?'**
  String get quizPhishingQ9;

  /// quizPhishingQ9A1
  ///
  /// In en, this message translates to:
  /// **'A fake email from a manager requesting a money transfer'**
  String get quizPhishingQ9A1;

  /// quizPhishingQ9A2
  ///
  /// In en, this message translates to:
  /// **'Hacking email to send spam'**
  String get quizPhishingQ9A2;

  /// quizPhishingQ9A3
  ///
  /// In en, this message translates to:
  /// **'Encrypting corporate correspondence'**
  String get quizPhishingQ9A3;

  /// quizPhishingQ9A4
  ///
  /// In en, this message translates to:
  /// **'Sorting business emails'**
  String get quizPhishingQ9A4;

  /// quizPhishingQ9Explain
  ///
  /// In en, this message translates to:
  /// **'BEC is one of the most expensive attacks (average loss \$120,000). The attacker waits for a payment moment and sends an email with changed details. Confirm transfers by phone.'**
  String get quizPhishingQ9Explain;

  /// quizPhishingQ10
  ///
  /// In en, this message translates to:
  /// **'What to do if you accidentally clicked a phishing link?'**
  String get quizPhishingQ10;

  /// quizPhishingQ10A1
  ///
  /// In en, this message translates to:
  /// **'Don\'t enter data, close the page, change passwords, run antivirus scan'**
  String get quizPhishingQ10A1;

  /// quizPhishingQ10A2
  ///
  /// In en, this message translates to:
  /// **'Nothing - the virus is already installed'**
  String get quizPhishingQ10A2;

  /// quizPhishingQ10A3
  ///
  /// In en, this message translates to:
  /// **'Restart the computer'**
  String get quizPhishingQ10A3;

  /// quizPhishingQ10A4
  ///
  /// In en, this message translates to:
  /// **'Send the scammers a reply email'**
  String get quizPhishingQ10A4;

  /// quizPhishingQ10Explain
  ///
  /// In en, this message translates to:
  /// **'The click itself is usually not dangerous - entering data is. If you didn\'t enter anything - close the page. If you entered a password - change it and enable 2FA.'**
  String get quizPhishingQ10Explain;

  /// quizBackupQ6
  ///
  /// In en, this message translates to:
  /// **'What\'s the difference between full and incremental backup?'**
  String get quizBackupQ6;

  /// quizBackupQ6A1
  ///
  /// In en, this message translates to:
  /// **'Full copies everything, incremental - only changes since the last backup'**
  String get quizBackupQ6A1;

  /// quizBackupQ6A2
  ///
  /// In en, this message translates to:
  /// **'Full backup is larger but incremental is unreliable'**
  String get quizBackupQ6A2;

  /// quizBackupQ6A3
  ///
  /// In en, this message translates to:
  /// **'Incremental is the same thing, just faster'**
  String get quizBackupQ6A3;

  /// quizBackupQ6A4
  ///
  /// In en, this message translates to:
  /// **'Full backup only works on external drives'**
  String get quizBackupQ6A4;

  /// quizBackupQ6Explain
  ///
  /// In en, this message translates to:
  /// **'Incremental backup saves time and space. Optimal strategy: full backup weekly + daily incrementals.'**
  String get quizBackupQ6Explain;

  /// quizBackupQ7
  ///
  /// In en, this message translates to:
  /// **'Why is it important to encrypt backups?'**
  String get quizBackupQ7;

  /// quizBackupQ7A1
  ///
  /// In en, this message translates to:
  /// **'An unencrypted backup on a stolen drive gives access to all data'**
  String get quizBackupQ7A1;

  /// quizBackupQ7A2
  ///
  /// In en, this message translates to:
  /// **'Encryption speeds up recovery'**
  String get quizBackupQ7A2;

  /// quizBackupQ7A3
  ///
  /// In en, this message translates to:
  /// **'Encryption is required by law'**
  String get quizBackupQ7A3;

  /// quizBackupQ7A4
  ///
  /// In en, this message translates to:
  /// **'Without encryption, backups corrupt faster'**
  String get quizBackupQ7A4;

  /// quizBackupQ7Explain
  ///
  /// In en, this message translates to:
  /// **'If an external drive is stolen or a cloud account is hacked - unencrypted backup means full data access. BitLocker or cloud encryption solves this.'**
  String get quizBackupQ7Explain;

  /// quizBackupQ8
  ///
  /// In en, this message translates to:
  /// **'What is an air-gapped backup?'**
  String get quizBackupQ8;

  /// quizBackupQ8A1
  ///
  /// In en, this message translates to:
  /// **'A backup on media physically disconnected from the network and computer'**
  String get quizBackupQ8A1;

  /// quizBackupQ8A2
  ///
  /// In en, this message translates to:
  /// **'Backup on an airplane'**
  String get quizBackupQ8A2;

  /// quizBackupQ8A3
  ///
  /// In en, this message translates to:
  /// **'Wireless backup over Wi-Fi'**
  String get quizBackupQ8A3;

  /// quizBackupQ8A4
  ///
  /// In en, this message translates to:
  /// **'Cloud backup with VPN'**
  String get quizBackupQ8A4;

  /// quizBackupQ8Explain
  ///
  /// In en, this message translates to:
  /// **'Air-gapped backup is a drive connected only during copying. Ransomware can\'t encrypt a disconnected drive. The most reliable ransomware protection.'**
  String get quizBackupQ8Explain;

  /// quizBackupQ9
  ///
  /// In en, this message translates to:
  /// **'How often should you make backups?'**
  String get quizBackupQ9;

  /// quizBackupQ9A1
  ///
  /// In en, this message translates to:
  /// **'Depends on data value: daily for important, weekly for the rest'**
  String get quizBackupQ9A1;

  /// quizBackupQ9A2
  ///
  /// In en, this message translates to:
  /// **'Once a year is enough'**
  String get quizBackupQ9A2;

  /// quizBackupQ9A3
  ///
  /// In en, this message translates to:
  /// **'Only before reinstalling the system'**
  String get quizBackupQ9A3;

  /// quizBackupQ9A4
  ///
  /// In en, this message translates to:
  /// **'Once when buying the computer'**
  String get quizBackupQ9A4;

  /// quizBackupQ9Explain
  ///
  /// In en, this message translates to:
  /// **'Think: how much work can you afford to lose? If losing a day is critical - backup daily. Automate: manual backups get forgotten.'**
  String get quizBackupQ9Explain;

  /// quizBackupQ10
  ///
  /// In en, this message translates to:
  /// **'What to do if a backup can\'t be restored?'**
  String get quizBackupQ10;

  /// quizBackupQ10A1
  ///
  /// In en, this message translates to:
  /// **'The backup is corrupted - you should have tested restoration beforehand'**
  String get quizBackupQ10A1;

  /// quizBackupQ10A2
  ///
  /// In en, this message translates to:
  /// **'Try again in a week'**
  String get quizBackupQ10A2;

  /// quizBackupQ10A3
  ///
  /// In en, this message translates to:
  /// **'Backups always restore successfully'**
  String get quizBackupQ10A3;

  /// quizBackupQ10A4
  ///
  /// In en, this message translates to:
  /// **'Contact the drive manufacturer\'s support'**
  String get quizBackupQ10A4;

  /// quizBackupQ10Explain
  ///
  /// In en, this message translates to:
  /// **'An untested backup is not a backup. Test restoration monthly. Corrupted sectors, outdated formats, forgotten passwords - all discovered only during testing.'**
  String get quizBackupQ10Explain;

  /// quizDownloadQ6
  ///
  /// In en, this message translates to:
  /// **'What is a sandbox?'**
  String get quizDownloadQ6;

  /// quizDownloadQ6A1
  ///
  /// In en, this message translates to:
  /// **'An isolated environment where a program can\'t harm the main system'**
  String get quizDownloadQ6A1;

  /// quizDownloadQ6A2
  ///
  /// In en, this message translates to:
  /// **'An antivirus program'**
  String get quizDownloadQ6A2;

  /// quizDownloadQ6A3
  ///
  /// In en, this message translates to:
  /// **'A special folder on the desktop'**
  String get quizDownloadQ6A3;

  /// quizDownloadQ6A4
  ///
  /// In en, this message translates to:
  /// **'A file archiving program'**
  String get quizDownloadQ6A4;

  /// quizDownloadQ6Explain
  ///
  /// In en, this message translates to:
  /// **'Windows Sandbox creates a disposable virtual Windows copy. Run a suspicious file - after closing, all changes disappear.'**
  String get quizDownloadQ6Explain;

  /// quizDownloadQ7
  ///
  /// In en, this message translates to:
  /// **'How do you verify a file by hash?'**
  String get quizDownloadQ7;

  /// quizDownloadQ7A1
  ///
  /// In en, this message translates to:
  /// **'Compare the SHA-256 hash of the file with the one listed on the developer\'s website'**
  String get quizDownloadQ7A1;

  /// quizDownloadQ7A2
  ///
  /// In en, this message translates to:
  /// **'Open the file and check the contents'**
  String get quizDownloadQ7A2;

  /// quizDownloadQ7A3
  ///
  /// In en, this message translates to:
  /// **'Rename the file and check its size'**
  String get quizDownloadQ7A3;

  /// quizDownloadQ7A4
  ///
  /// In en, this message translates to:
  /// **'The hash is checked automatically by the browser'**
  String get quizDownloadQ7A4;

  /// quizDownloadQ7Explain
  ///
  /// In en, this message translates to:
  /// **'SHA-256 is a digital fingerprint of the file. Changing one byte completely changes the hash. In Windows: certutil -hashfile file.exe SHA256.'**
  String get quizDownloadQ7Explain;

  /// quizDownloadQ8
  ///
  /// In en, this message translates to:
  /// **'What does Windows SmartScreen do?'**
  String get quizDownloadQ8;

  /// quizDownloadQ8A1
  ///
  /// In en, this message translates to:
  /// **'Warns when running unknown or unsigned programs downloaded from the internet'**
  String get quizDownloadQ8A1;

  /// quizDownloadQ8A2
  ///
  /// In en, this message translates to:
  /// **'Blocks all downloads'**
  String get quizDownloadQ8A2;

  /// quizDownloadQ8A3
  ///
  /// In en, this message translates to:
  /// **'Checks RAM'**
  String get quizDownloadQ8A3;

  /// quizDownloadQ8A4
  ///
  /// In en, this message translates to:
  /// **'Filters ads in the browser'**
  String get quizDownloadQ8A4;

  /// quizDownloadQ8Explain
  ///
  /// In en, this message translates to:
  /// **'SmartScreen checks file reputation. A warning doesn\'t mean a virus, but the file is unknown to the system. Proceed with caution.'**
  String get quizDownloadQ8Explain;

  /// quizDownloadQ9
  ///
  /// In en, this message translates to:
  /// **'Why are cracks and keygens especially dangerous?'**
  String get quizDownloadQ9;

  /// quizDownloadQ9A1
  ///
  /// In en, this message translates to:
  /// **'90%+ contain malware: trojans, miners, spyware'**
  String get quizDownloadQ9A1;

  /// quizDownloadQ9A2
  ///
  /// In en, this message translates to:
  /// **'They slow down the computer'**
  String get quizDownloadQ9A2;

  /// quizDownloadQ9A3
  ///
  /// In en, this message translates to:
  /// **'They\'re illegal but technically safe'**
  String get quizDownloadQ9A3;

  /// quizDownloadQ9A4
  ///
  /// In en, this message translates to:
  /// **'Antivirus programs solved this long ago'**
  String get quizDownloadQ9A4;

  /// quizDownloadQ9Explain
  ///
  /// In en, this message translates to:
  /// **'The victim disables antivirus themselves and runs the malware with admin rights. Cracks contain: stealer trojans, cryptominers, and RATs (remote access).'**
  String get quizDownloadQ9Explain;

  /// quizDownloadQ10
  ///
  /// In en, this message translates to:
  /// **'What to do if the browser blocked a download?'**
  String get quizDownloadQ10;

  /// quizDownloadQ10A1
  ///
  /// In en, this message translates to:
  /// **'Don\'t ignore it - verify the source and necessity of the file'**
  String get quizDownloadQ10A1;

  /// quizDownloadQ10A2
  ///
  /// In en, this message translates to:
  /// **'Switch to an unprotected browser'**
  String get quizDownloadQ10A2;

  /// quizDownloadQ10A3
  ///
  /// In en, this message translates to:
  /// **'Browsers are too cautious - always ignore'**
  String get quizDownloadQ10A3;

  /// quizDownloadQ10A4
  ///
  /// In en, this message translates to:
  /// **'Disable protection permanently'**
  String get quizDownloadQ10A4;

  /// quizDownloadQ10Explain
  ///
  /// In en, this message translates to:
  /// **'Browsers block based on reputation and signatures. If a file is blocked - it\'s a serious signal. Verify the source before proceeding.'**
  String get quizDownloadQ10Explain;

  /// quiz2faQ6
  ///
  /// In en, this message translates to:
  /// **'Can two-factor authentication be bypassed?'**
  String get quiz2faQ6;

  /// quiz2faQ6A1
  ///
  /// In en, this message translates to:
  /// **'Yes - through real-time phishing or SIM-swap, that\'s why the 2FA method matters'**
  String get quiz2faQ6A1;

  /// quiz2faQ6A2
  ///
  /// In en, this message translates to:
  /// **'No, 2FA is absolutely impenetrable'**
  String get quiz2faQ6A2;

  /// quiz2faQ6A3
  ///
  /// In en, this message translates to:
  /// **'Only intelligence agencies can bypass 2FA'**
  String get quiz2faQ6A3;

  /// quiz2faQ6A4
  ///
  /// In en, this message translates to:
  /// **'2FA protects against all attacks'**
  String get quiz2faQ6A4;

  /// quiz2faQ6Explain
  ///
  /// In en, this message translates to:
  /// **'Phishing proxies intercept 2FA codes in real time. SIM-swap redirects SMS. Hardware FIDO2 keys are resistant to these attacks.'**
  String get quiz2faQ6Explain;

  /// quiz2faQ7
  ///
  /// In en, this message translates to:
  /// **'What is a hardware security key (YubiKey)?'**
  String get quiz2faQ7;

  /// quiz2faQ7A1
  ///
  /// In en, this message translates to:
  /// **'A physical device for authentication, resistant to phishing'**
  String get quiz2faQ7A1;

  /// quiz2faQ7A2
  ///
  /// In en, this message translates to:
  /// **'A USB drive with passwords'**
  String get quiz2faQ7A2;

  /// quiz2faQ7A3
  ///
  /// In en, this message translates to:
  /// **'A hard drive encryption key'**
  String get quiz2faQ7A3;

  /// quiz2faQ7A4
  ///
  /// In en, this message translates to:
  /// **'A key fob for unlocking a car'**
  String get quiz2faQ7A4;

  /// quiz2faQ7Explain
  ///
  /// In en, this message translates to:
  /// **'A FIDO2 key is cryptographically bound to the domain. Even on a perfect phishing site, the key will refuse to authenticate. Phishing is physically impossible.'**
  String get quiz2faQ7Explain;

  /// quiz2faQ8
  ///
  /// In en, this message translates to:
  /// **'Why is it important to enable 2FA on email first?'**
  String get quiz2faQ8;

  /// quiz2faQ8A1
  ///
  /// In en, this message translates to:
  /// **'Email is the key to all accounts: passwords are reset through it'**
  String get quiz2faQ8A1;

  /// quiz2faQ8A2
  ///
  /// In en, this message translates to:
  /// **'Email is the most popular service'**
  String get quiz2faQ8A2;

  /// quiz2faQ8A3
  ///
  /// In en, this message translates to:
  /// **'You can\'t send email without 2FA'**
  String get quiz2faQ8A3;

  /// quiz2faQ8A4
  ///
  /// In en, this message translates to:
  /// **'2FA on email is less important than on social media'**
  String get quiz2faQ8A4;

  /// quiz2faQ8Explain
  ///
  /// In en, this message translates to:
  /// **'If an attacker gains access to your email, they can reset passwords for all linked accounts. Email is the master key of your digital life. 2FA on email is priority #1.'**
  String get quiz2faQ8Explain;

  /// quiz2faQ9
  ///
  /// In en, this message translates to:
  /// **'What are backup codes and where to store them?'**
  String get quiz2faQ9;

  /// quiz2faQ9A1
  ///
  /// In en, this message translates to:
  /// **'One-time codes for login when 2FA device is lost - in a password manager or safe'**
  String get quiz2faQ9A1;

  /// quiz2faQ9A2
  ///
  /// In en, this message translates to:
  /// **'Codes for file recovery'**
  String get quiz2faQ9A2;

  /// quiz2faQ9A3
  ///
  /// In en, this message translates to:
  /// **'Just remember one code'**
  String get quiz2faQ9A3;

  /// quiz2faQ9A4
  ///
  /// In en, this message translates to:
  /// **'Backup codes last forever'**
  String get quiz2faQ9A4;

  /// quiz2faQ9Explain
  ///
  /// In en, this message translates to:
  /// **'The service issues 8-10 one-time codes. Store in a password manager or print them. Without them, losing your phone = losing access.'**
  String get quiz2faQ9Explain;

  /// quiz2faQ10
  ///
  /// In en, this message translates to:
  /// **'Should you enable 2FA on all accounts?'**
  String get quiz2faQ10;

  /// quiz2faQ10A1
  ///
  /// In en, this message translates to:
  /// **'Yes - especially on email, banking, cloud, and social media'**
  String get quiz2faQ10A1;

  /// quiz2faQ10A2
  ///
  /// In en, this message translates to:
  /// **'Only on banking accounts'**
  String get quiz2faQ10A2;

  /// quiz2faQ10A3
  ///
  /// In en, this message translates to:
  /// **'2FA is too inconvenient'**
  String get quiz2faQ10A3;

  /// quiz2faQ10A4
  ///
  /// In en, this message translates to:
  /// **'One main account is enough'**
  String get quiz2faQ10A4;

  /// quiz2faQ10Explain
  ///
  /// In en, this message translates to:
  /// **'Hacking an \'unimportant\' account is dangerous with reused passwords. 2FA makes hacking exponentially harder. Minimum: email + bank + cloud + social media.'**
  String get quiz2faQ10Explain;

  /// quizUsbQ6
  ///
  /// In en, this message translates to:
  /// **'What is a USB Killer?'**
  String get quizUsbQ6;

  /// quizUsbQ6A1
  ///
  /// In en, this message translates to:
  /// **'A device that sends an electrical discharge through the USB port, destroying hardware'**
  String get quizUsbQ6A1;

  /// quizUsbQ6A2
  ///
  /// In en, this message translates to:
  /// **'An antivirus for USB drives'**
  String get quizUsbQ6A2;

  /// quizUsbQ6A3
  ///
  /// In en, this message translates to:
  /// **'A safe removal program'**
  String get quizUsbQ6A3;

  /// quizUsbQ6A4
  ///
  /// In en, this message translates to:
  /// **'A virus that erases data from flash drives'**
  String get quizUsbQ6A4;

  /// quizUsbQ6Explain
  ///
  /// In en, this message translates to:
  /// **'USB Killer charges capacitors and discharges 200+ volts back into the port. Result: a burned motherboard. Don\'t insert unknown USB devices.'**
  String get quizUsbQ6Explain;

  /// quizUsbQ7
  ///
  /// In en, this message translates to:
  /// **'How to protect against autorun of malware from USB?'**
  String get quizUsbQ7;

  /// quizUsbQ7A1
  ///
  /// In en, this message translates to:
  /// **'Disable autorun in Windows and check flash drive contents manually'**
  String get quizUsbQ7A1;

  /// quizUsbQ7A2
  ///
  /// In en, this message translates to:
  /// **'Autorun is safe in modern Windows'**
  String get quizUsbQ7A2;

  /// quizUsbQ7A3
  ///
  /// In en, this message translates to:
  /// **'Using USB 3.0 is enough'**
  String get quizUsbQ7A3;

  /// quizUsbQ7A4
  ///
  /// In en, this message translates to:
  /// **'Format every flash drive before use'**
  String get quizUsbQ7A4;

  /// quizUsbQ7Explain
  ///
  /// In en, this message translates to:
  /// **'AutoRun for USB is disabled by default, but AutoPlay may suggest actions. Settings → Devices → AutoPlay → Off. Scan new USB drives with antivirus.'**
  String get quizUsbQ7Explain;

  /// quizUsbQ8
  ///
  /// In en, this message translates to:
  /// **'What is juice jacking (USB charging attack)?'**
  String get quizUsbQ8;

  /// quizUsbQ8A1
  ///
  /// In en, this message translates to:
  /// **'Data theft through a public USB charging station disguised as a regular one'**
  String get quizUsbQ8A1;

  /// quizUsbQ8A2
  ///
  /// In en, this message translates to:
  /// **'Electricity theft through USB'**
  String get quizUsbQ8A2;

  /// quizUsbQ8A3
  ///
  /// In en, this message translates to:
  /// **'Phone overheating from charging'**
  String get quizUsbQ8A3;

  /// quizUsbQ8A4
  ///
  /// In en, this message translates to:
  /// **'Using someone else\'s charger'**
  String get quizUsbQ8A4;

  /// quizUsbQ8Explain
  ///
  /// In en, this message translates to:
  /// **'USB carries both power and data. A modified station can read data or install malware. Use your own power adapter or a data blocker.'**
  String get quizUsbQ8Explain;

  /// quizUsbQ9
  ///
  /// In en, this message translates to:
  /// **'What\'s a safe way to transfer files instead of USB?'**
  String get quizUsbQ9;

  /// quizUsbQ9A1
  ///
  /// In en, this message translates to:
  /// **'Cloud storage or transfer via encrypted channel (Wi-Fi Direct, AirDrop)'**
  String get quizUsbQ9A1;

  /// quizUsbQ9A2
  ///
  /// In en, this message translates to:
  /// **'Bluetooth - it\'s always safe'**
  String get quizUsbQ9A2;

  /// quizUsbQ9A3
  ///
  /// In en, this message translates to:
  /// **'Email without restrictions'**
  String get quizUsbQ9A3;

  /// quizUsbQ9A4
  ///
  /// In en, this message translates to:
  /// **'There are no safe alternatives'**
  String get quizUsbQ9A4;

  /// quizUsbQ9Explain
  ///
  /// In en, this message translates to:
  /// **'Cloud services scan files with antivirus. Wi-Fi Direct, AirDrop, Nearby Share are encrypted and don\'t require physical media.'**
  String get quizUsbQ9Explain;

  /// quizUsbQ10
  ///
  /// In en, this message translates to:
  /// **'Why is physical security of USB ports important?'**
  String get quizUsbQ10;

  /// quizUsbQ10A1
  ///
  /// In en, this message translates to:
  /// **'An attacker can quickly insert a malicious device while you\'re away'**
  String get quizUsbQ10A1;

  /// quizUsbQ10A2
  ///
  /// In en, this message translates to:
  /// **'USB ports wear out'**
  String get quizUsbQ10A2;

  /// quizUsbQ10A3
  ///
  /// In en, this message translates to:
  /// **'Antivirus will stop everything'**
  String get quizUsbQ10A3;

  /// quizUsbQ10A4
  ///
  /// In en, this message translates to:
  /// **'Ports need to be covered from dust'**
  String get quizUsbQ10A4;

  /// quizUsbQ10Explain
  ///
  /// In en, this message translates to:
  /// **'Inserting a BadUSB takes a second. On critical computers, use USB blockers or GPO policies restricting new device connections.'**
  String get quizUsbQ10Explain;

  /// quizPrivacyQ6
  ///
  /// In en, this message translates to:
  /// **'What is a digital footprint?'**
  String get quizPrivacyQ6;

  /// quizPrivacyQ6A1
  ///
  /// In en, this message translates to:
  /// **'The totality of all your internet activity - virtually impossible to fully delete'**
  String get quizPrivacyQ6A1;

  /// quizPrivacyQ6A2
  ///
  /// In en, this message translates to:
  /// **'Traces from downloading files'**
  String get quizPrivacyQ6A2;

  /// quizPrivacyQ6A3
  ///
  /// In en, this message translates to:
  /// **'A fingerprint on the screen'**
  String get quizPrivacyQ6A3;

  /// quizPrivacyQ6A4
  ///
  /// In en, this message translates to:
  /// **'Clearing browser history deletes your digital footprint'**
  String get quizPrivacyQ6A4;

  /// quizPrivacyQ6Explain
  ///
  /// In en, this message translates to:
  /// **'Every post, like, purchase forms a digital footprint. Even deleted posts are saved in caches and web archives. Don\'t post what you don\'t want to see public in 10 years.'**
  String get quizPrivacyQ6Explain;

  /// quizPrivacyQ7
  ///
  /// In en, this message translates to:
  /// **'Why use different emails for different purposes?'**
  String get quizPrivacyQ7;

  /// quizPrivacyQ7A1
  ///
  /// In en, this message translates to:
  /// **'Compromise of one address won\'t affect others - account isolation'**
  String get quizPrivacyQ7A1;

  /// quizPrivacyQ7A2
  ///
  /// In en, this message translates to:
  /// **'Email services give discounts for multiple accounts'**
  String get quizPrivacyQ7A2;

  /// quizPrivacyQ7A3
  ///
  /// In en, this message translates to:
  /// **'One address can\'t receive many emails'**
  String get quizPrivacyQ7A3;

  /// quizPrivacyQ7A4
  ///
  /// In en, this message translates to:
  /// **'This is only needed for work'**
  String get quizPrivacyQ7A4;

  /// quizPrivacyQ7Explain
  ///
  /// In en, this message translates to:
  /// **'Separate email for banking, another for forums. A forum database leak won\'t reveal your banking email. Aliases (SimpleLogin) let you delete a leaked address.'**
  String get quizPrivacyQ7Explain;

  /// quizPrivacyQ8
  ///
  /// In en, this message translates to:
  /// **'What is doxxing?'**
  String get quizPrivacyQ8;

  /// quizPrivacyQ8A1
  ///
  /// In en, this message translates to:
  /// **'Collecting and publishing personal information without consent to intimidate'**
  String get quizPrivacyQ8A1;

  /// quizPrivacyQ8A2
  ///
  /// In en, this message translates to:
  /// **'Protecting documents with a password'**
  String get quizPrivacyQ8A2;

  /// quizPrivacyQ8A3
  ///
  /// In en, this message translates to:
  /// **'Archiving files'**
  String get quizPrivacyQ8A3;

  /// quizPrivacyQ8A4
  ///
  /// In en, this message translates to:
  /// **'An identity verification procedure'**
  String get quizPrivacyQ8A4;

  /// quizPrivacyQ8Explain
  ///
  /// In en, this message translates to:
  /// **'Doxxers collect addresses, phone numbers, photos from open sources. Protection: minimize data on social media, use pseudonyms on forums.'**
  String get quizPrivacyQ8Explain;

  /// quizPrivacyQ9
  ///
  /// In en, this message translates to:
  /// **'How to reduce browser tracking?'**
  String get quizPrivacyQ9;

  /// quizPrivacyQ9A1
  ///
  /// In en, this message translates to:
  /// **'Use a tracker blocker (uBlock Origin), clear cookies, enable DNS over HTTPS'**
  String get quizPrivacyQ9A1;

  /// quizPrivacyQ9A2
  ///
  /// In en, this message translates to:
  /// **'Incognito mode is sufficient'**
  String get quizPrivacyQ9A2;

  /// quizPrivacyQ9A3
  ///
  /// In en, this message translates to:
  /// **'Install more privacy extensions'**
  String get quizPrivacyQ9A3;

  /// quizPrivacyQ9A4
  ///
  /// In en, this message translates to:
  /// **'Tracking cannot be prevented'**
  String get quizPrivacyQ9A4;

  /// quizPrivacyQ9Explain
  ///
  /// In en, this message translates to:
  /// **'Incognito does NOT protect against trackers. A combination: uBlock Origin, Firefox with Enhanced Tracking Protection, cookie clearing, DNS over HTTPS.'**
  String get quizPrivacyQ9Explain;

  /// quizPrivacyQ10
  ///
  /// In en, this message translates to:
  /// **'What is the right to be forgotten?'**
  String get quizPrivacyQ10;

  /// quizPrivacyQ10A1
  ///
  /// In en, this message translates to:
  /// **'A legal right to demand companies delete your personal data'**
  String get quizPrivacyQ10A1;

  /// quizPrivacyQ10A2
  ///
  /// In en, this message translates to:
  /// **'Automatic data deletion after a year'**
  String get quizPrivacyQ10A2;

  /// quizPrivacyQ10A3
  ///
  /// In en, this message translates to:
  /// **'A ban on saving cookies'**
  String get quizPrivacyQ10A3;

  /// quizPrivacyQ10A4
  ///
  /// In en, this message translates to:
  /// **'The right to forget your password'**
  String get quizPrivacyQ10A4;

  /// quizPrivacyQ10Explain
  ///
  /// In en, this message translates to:
  /// **'GDPR grants the right to request data deletion. Google allows removing links, social media - deleting accounts. Use it for unused accounts.'**
  String get quizPrivacyQ10Explain;

  /// quizLockQ6
  ///
  /// In en, this message translates to:
  /// **'Why set a BIOS/UEFI password?'**
  String get quizLockQ6;

  /// quizLockQ6A1
  ///
  /// In en, this message translates to:
  /// **'Prevents booting from external media, bypassing OS protection'**
  String get quizLockQ6A1;

  /// quizLockQ6A2
  ///
  /// In en, this message translates to:
  /// **'BIOS password speeds up booting'**
  String get quizLockQ6A2;

  /// quizLockQ6A3
  ///
  /// In en, this message translates to:
  /// **'Without it, the computer won\'t turn on'**
  String get quizLockQ6A3;

  /// quizLockQ6A4
  ///
  /// In en, this message translates to:
  /// **'BIOS password replaces Windows password'**
  String get quizLockQ6A4;

  /// quizLockQ6Explain
  ///
  /// In en, this message translates to:
  /// **'Without a BIOS password, you can boot from USB and bypass the Windows password. BIOS password + BitLocker = reliable protection against physical access.'**
  String get quizLockQ6Explain;

  /// quizLockQ7
  ///
  /// In en, this message translates to:
  /// **'How to protect against shoulder surfing?'**
  String get quizLockQ7;

  /// quizLockQ7A1
  ///
  /// In en, this message translates to:
  /// **'Use biometrics, a privacy screen, and make sure nobody is watching'**
  String get quizLockQ7A1;

  /// quizLockQ7A2
  ///
  /// In en, this message translates to:
  /// **'Enter the password quickly'**
  String get quizLockQ7A2;

  /// quizLockQ7A3
  ///
  /// In en, this message translates to:
  /// **'This is impossible in modern offices'**
  String get quizLockQ7A3;

  /// quizLockQ7A4
  ///
  /// In en, this message translates to:
  /// **'Use a long password'**
  String get quizLockQ7A4;

  /// quizLockQ7Explain
  ///
  /// In en, this message translates to:
  /// **'A privacy screen (3M Privacy Filter) makes the image visible only from a direct angle. Biometrics eliminates shoulder surfing completely.'**
  String get quizLockQ7Explain;

  /// quizLockQ8
  ///
  /// In en, this message translates to:
  /// **'What screen auto-lock timeout is recommended?'**
  String get quizLockQ8;

  /// quizLockQ8A1
  ///
  /// In en, this message translates to:
  /// **'2-5 minutes - enough to not annoy you but protect from access'**
  String get quizLockQ8A1;

  /// quizLockQ8A2
  ///
  /// In en, this message translates to:
  /// **'30 minutes - the standard value'**
  String get quizLockQ8A2;

  /// quizLockQ8A3
  ///
  /// In en, this message translates to:
  /// **'Auto-lock is unrelated to security'**
  String get quizLockQ8A3;

  /// quizLockQ8A4
  ///
  /// In en, this message translates to:
  /// **'1 hour for comfortable work'**
  String get quizLockQ8A4;

  /// quizLockQ8Explain
  ///
  /// In en, this message translates to:
  /// **'In 30 minutes, someone can copy files, install a keylogger, or read email. 5 minutes is a balance between convenience and protection.'**
  String get quizLockQ8Explain;

  /// quizLockQ9
  ///
  /// In en, this message translates to:
  /// **'What\'s the danger of disabling the Windows login password?'**
  String get quizLockQ9;

  /// quizLockQ9A1
  ///
  /// In en, this message translates to:
  /// **'Anyone who turns on the computer gets full access to files and accounts'**
  String get quizLockQ9A1;

  /// quizLockQ9A2
  ///
  /// In en, this message translates to:
  /// **'Windows will run slower'**
  String get quizLockQ9A2;

  /// quizLockQ9A3
  ///
  /// In en, this message translates to:
  /// **'No danger'**
  String get quizLockQ9A3;

  /// quizLockQ9A4
  ///
  /// In en, this message translates to:
  /// **'Vulnerability only to network attacks'**
  String get quizLockQ9A4;

  /// quizLockQ9Explain
  ///
  /// In en, this message translates to:
  /// **'Without a password, the computer is an open book: documents, browser passwords, email. If a laptop is stolen, the thief gains instant access.'**
  String get quizLockQ9Explain;

  /// quizLockQ10
  ///
  /// In en, this message translates to:
  /// **'Why lock your computer at home?'**
  String get quizLockQ10;

  /// quizLockQ10A1
  ///
  /// In en, this message translates to:
  /// **'The habit protects you elsewhere, and at home - from guests and burglars'**
  String get quizLockQ10A1;

  /// quizLockQ10A2
  ///
  /// In en, this message translates to:
  /// **'Locking isn\'t needed at home'**
  String get quizLockQ10A2;

  /// quizLockQ10A3
  ///
  /// In en, this message translates to:
  /// **'Only at work'**
  String get quizLockQ10A3;

  /// quizLockQ10A4
  ///
  /// In en, this message translates to:
  /// **'Viruses can unlock the computer'**
  String get quizLockQ10A4;

  /// quizLockQ10Explain
  ///
  /// In en, this message translates to:
  /// **'Win+L should be a reflex. You have guests, couriers, technicians visiting. A habit developed at home will save you in cafes and offices.'**
  String get quizLockQ10Explain;

  /// quizExtQ6
  ///
  /// In en, this message translates to:
  /// **'What is a browser extension supply chain attack?'**
  String get quizExtQ6;

  /// quizExtQ6A1
  ///
  /// In en, this message translates to:
  /// **'A developer sells the extension to an attacker who releases a malicious update'**
  String get quizExtQ6A1;

  /// quizExtQ6A2
  ///
  /// In en, this message translates to:
  /// **'An extension delivered by mail'**
  String get quizExtQ6A2;

  /// quizExtQ6A3
  ///
  /// In en, this message translates to:
  /// **'A conflict between extensions'**
  String get quizExtQ6A3;

  /// quizExtQ6A4
  ///
  /// In en, this message translates to:
  /// **'Installing from a file'**
  String get quizExtQ6A4;

  /// quizExtQ6Explain
  ///
  /// In en, this message translates to:
  /// **'In 2020-2023, dozens of popular extensions were sold and updated with malicious code. Minimize the number of extensions.'**
  String get quizExtQ6Explain;

  /// quizExtQ7
  ///
  /// In en, this message translates to:
  /// **'How to check permissions of installed extensions?'**
  String get quizExtQ7;

  /// quizExtQ7A1
  ///
  /// In en, this message translates to:
  /// **'chrome://extensions → Details → view site access and permissions'**
  String get quizExtQ7A1;

  /// quizExtQ7A2
  ///
  /// In en, this message translates to:
  /// **'Permissions can\'t be viewed after installation'**
  String get quizExtQ7A2;

  /// quizExtQ7A3
  ///
  /// In en, this message translates to:
  /// **'Only through reinstallation'**
  String get quizExtQ7A3;

  /// quizExtQ7A4
  ///
  /// In en, this message translates to:
  /// **'All extensions have the same permissions'**
  String get quizExtQ7A4;

  /// quizExtQ7Explain
  ///
  /// In en, this message translates to:
  /// **'In Chrome: Extensions → Manage → click → Details. If a calculator needs access to all sites - remove it.'**
  String get quizExtQ7Explain;

  /// quizExtQ8
  ///
  /// In en, this message translates to:
  /// **'Do extensions work in incognito mode?'**
  String get quizExtQ8;

  /// quizExtQ8A1
  ///
  /// In en, this message translates to:
  /// **'By default no - but you can allow it, which creates a tracking risk'**
  String get quizExtQ8A1;

  /// quizExtQ8A2
  ///
  /// In en, this message translates to:
  /// **'All extensions work in incognito'**
  String get quizExtQ8A2;

  /// quizExtQ8A3
  ///
  /// In en, this message translates to:
  /// **'Extensions are safe in incognito'**
  String get quizExtQ8A3;

  /// quizExtQ8A4
  ///
  /// In en, this message translates to:
  /// **'Incognito disables extensions permanently'**
  String get quizExtQ8A4;

  /// quizExtQ8Explain
  ///
  /// In en, this message translates to:
  /// **'An extension enabled in incognito sees all sites you wanted to hide. Only enable trusted ones (uBlock Origin).'**
  String get quizExtQ8Explain;

  /// quizExtQ9
  ///
  /// In en, this message translates to:
  /// **'Why restrict an extension to specific sites?'**
  String get quizExtQ9;

  /// quizExtQ9A1
  ///
  /// In en, this message translates to:
  /// **'Instead of access to all sites, give only to needed ones - principle of least privilege'**
  String get quizExtQ9A1;

  /// quizExtQ9A2
  ///
  /// In en, this message translates to:
  /// **'This speeds up the extension'**
  String get quizExtQ9A2;

  /// quizExtQ9A3
  ///
  /// In en, this message translates to:
  /// **'Restriction is impossible in Chrome'**
  String get quizExtQ9A3;

  /// quizExtQ9A4
  ///
  /// In en, this message translates to:
  /// **'Only for paid extensions'**
  String get quizExtQ9A4;

  /// quizExtQ9Explain
  ///
  /// In en, this message translates to:
  /// **'Right-click the icon → \'On specific sites.\' A translator doesn\'t need access to your Gmail inbox.'**
  String get quizExtQ9Explain;

  /// quizExtQ10
  ///
  /// In en, this message translates to:
  /// **'How do extensions affect browser fingerprinting?'**
  String get quizExtQ10;

  /// quizExtQ10A1
  ///
  /// In en, this message translates to:
  /// **'The set of extensions makes the browser more unique and recognizable'**
  String get quizExtQ10A1;

  /// quizExtQ10A2
  ///
  /// In en, this message translates to:
  /// **'Extensions hide the fingerprint'**
  String get quizExtQ10A2;

  /// quizExtQ10A3
  ///
  /// In en, this message translates to:
  /// **'Extensions don\'t affect privacy'**
  String get quizExtQ10A3;

  /// quizExtQ10A4
  ///
  /// In en, this message translates to:
  /// **'Only ad blockers create a fingerprint'**
  String get quizExtQ10A4;

  /// quizExtQ10Explain
  ///
  /// In en, this message translates to:
  /// **'Sites detect extensions by side effects. Paradox: privacy extensions can make you more identifiable.'**
  String get quizExtQ10Explain;

  /// quizEncryptQ6
  ///
  /// In en, this message translates to:
  /// **'What is AES-256?'**
  String get quizEncryptQ6;

  /// quizEncryptQ6A1
  ///
  /// In en, this message translates to:
  /// **'An encryption algorithm with a 256-bit key - brute-forcing all combinations would take longer than the age of the Universe'**
  String get quizEncryptQ6A1;

  /// quizEncryptQ6A2
  ///
  /// In en, this message translates to:
  /// **'A data compression protocol'**
  String get quizEncryptQ6A2;

  /// quizEncryptQ6A3
  ///
  /// In en, this message translates to:
  /// **'An antivirus algorithm'**
  String get quizEncryptQ6A3;

  /// quizEncryptQ6A4
  ///
  /// In en, this message translates to:
  /// **'An authentication method'**
  String get quizEncryptQ6A4;

  /// quizEncryptQ6Explain
  ///
  /// In en, this message translates to:
  /// **'AES-256 is approved by the NSA for classified documents. 2^256 possible keys exceeds the number of atoms in the Universe.'**
  String get quizEncryptQ6Explain;

  /// quizEncryptQ7
  ///
  /// In en, this message translates to:
  /// **'What\'s the difference between symmetric and asymmetric encryption?'**
  String get quizEncryptQ7;

  /// quizEncryptQ7A1
  ///
  /// In en, this message translates to:
  /// **'Symmetric - one key, asymmetric - a key pair (public + private)'**
  String get quizEncryptQ7A1;

  /// quizEncryptQ7A2
  ///
  /// In en, this message translates to:
  /// **'Symmetric is faster, so it\'s better'**
  String get quizEncryptQ7A2;

  /// quizEncryptQ7A3
  ///
  /// In en, this message translates to:
  /// **'Asymmetric is an outdated method'**
  String get quizEncryptQ7A3;

  /// quizEncryptQ7A4
  ///
  /// In en, this message translates to:
  /// **'No difference'**
  String get quizEncryptQ7A4;

  /// quizEncryptQ7Explain
  ///
  /// In en, this message translates to:
  /// **'HTTPS uses both: asymmetric for key exchange, then symmetric for data. Asymmetric solves the problem of secure key exchange.'**
  String get quizEncryptQ7Explain;

  /// quizEncryptQ8
  ///
  /// In en, this message translates to:
  /// **'Why is it important to encrypt data in the cloud?'**
  String get quizEncryptQ8;

  /// quizEncryptQ8A1
  ///
  /// In en, this message translates to:
  /// **'The provider can technically access unencrypted files'**
  String get quizEncryptQ8A1;

  /// quizEncryptQ8A2
  ///
  /// In en, this message translates to:
  /// **'The cloud automatically encrypts everything'**
  String get quizEncryptQ8A2;

  /// quizEncryptQ8A3
  ///
  /// In en, this message translates to:
  /// **'Cloud is safe without encryption'**
  String get quizEncryptQ8A3;

  /// quizEncryptQ8A4
  ///
  /// In en, this message translates to:
  /// **'Encryption slows sync by 10x'**
  String get quizEncryptQ8A4;

  /// quizEncryptQ8Explain
  ///
  /// In en, this message translates to:
  /// **'Google Drive, Dropbox encrypt data but have access to it. Client-side encryption (Cryptomator) guarantees: only you can read the files.'**
  String get quizEncryptQ8Explain;

  /// quizEncryptQ9
  ///
  /// In en, this message translates to:
  /// **'What to do with the BitLocker recovery key?'**
  String get quizEncryptQ9;

  /// quizEncryptQ9A1
  ///
  /// In en, this message translates to:
  /// **'Save in multiple places: Microsoft account, printout, password manager'**
  String get quizEncryptQ9A1;

  /// quizEncryptQ9A2
  ///
  /// In en, this message translates to:
  /// **'Memorize it'**
  String get quizEncryptQ9A2;

  /// quizEncryptQ9A3
  ///
  /// In en, this message translates to:
  /// **'The key isn\'t needed'**
  String get quizEncryptQ9A3;

  /// quizEncryptQ9A4
  ///
  /// In en, this message translates to:
  /// **'Email it to yourself'**
  String get quizEncryptQ9A4;

  /// quizEncryptQ9Explain
  ///
  /// In en, this message translates to:
  /// **'The BitLocker key is 48 digits. Without it, a TPM failure means data is lost forever. At least 2 copies in different locations.'**
  String get quizEncryptQ9Explain;

  /// quizEncryptQ10
  ///
  /// In en, this message translates to:
  /// **'Can you trust free VPNs?'**
  String get quizEncryptQ10;

  /// quizEncryptQ10A1
  ///
  /// In en, this message translates to:
  /// **'Be cautious - many sell user data or contain adware'**
  String get quizEncryptQ10A1;

  /// quizEncryptQ10A2
  ///
  /// In en, this message translates to:
  /// **'Free VPNs are just as safe as paid ones'**
  String get quizEncryptQ10A2;

  /// quizEncryptQ10A3
  ///
  /// In en, this message translates to:
  /// **'VPN is unrelated to encryption'**
  String get quizEncryptQ10A3;

  /// quizEncryptQ10A4
  ///
  /// In en, this message translates to:
  /// **'Free VPNs are faster than paid ones'**
  String get quizEncryptQ10A4;

  /// quizEncryptQ10Explain
  ///
  /// In en, this message translates to:
  /// **'38% of free Android VPNs contain malware, 75% use trackers. Reliable free options are rare - research before trusting.'**
  String get quizEncryptQ10Explain;

  /// onbExtTitle
  ///
  /// In en, this message translates to:
  /// **'Browser Extension'**
  String get onbExtTitle;

  /// onbExtSubtitle
  ///
  /// In en, this message translates to:
  /// **'Connect MentoringProtector to Chrome for real-time web protection'**
  String get onbExtSubtitle;

  /// onbExtStep1
  ///
  /// In en, this message translates to:
  /// **'Open chrome://extensions in the address bar'**
  String get onbExtStep1;

  /// onbExtStep2
  ///
  /// In en, this message translates to:
  /// **'Enable Developer Mode (toggle in the top-right corner)'**
  String get onbExtStep2;

  /// onbExtStep3
  ///
  /// In en, this message translates to:
  /// **'Click \'Load unpacked\' and select the folder shown below'**
  String get onbExtStep3;

  /// onbExtOpenFolder
  ///
  /// In en, this message translates to:
  /// **'Open Extension Folder'**
  String get onbExtOpenFolder;

  /// onbExtSkip
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onbExtSkip;

  /// onbExtChecking
  ///
  /// In en, this message translates to:
  /// **'Checking... {attempt}/3'**
  String onbExtChecking(int attempt);

  /// onbExtCheckConnection
  ///
  /// In en, this message translates to:
  /// **'Check Connection'**
  String get onbExtCheckConnection;

  /// onbExtConnected
  ///
  /// In en, this message translates to:
  /// **'Extension connected'**
  String get onbExtConnected;

  /// onbExtNotConnected
  ///
  /// In en, this message translates to:
  /// **'Extension not connected'**
  String get onbExtNotConnected;

  /// onbAdminTitle
  ///
  /// In en, this message translates to:
  /// **'Safe Operation Mode'**
  String get onbAdminTitle;

  /// onbAdminNoAdmin
  ///
  /// In en, this message translates to:
  /// **'MentoringProtector runs without administrator privileges'**
  String get onbAdminNoAdmin;

  /// onbAdminBody
  ///
  /// In en, this message translates to:
  /// **'File scanning, web protection, and process monitoring all work in normal user mode. No admin rights are needed for daily operation.'**
  String get onbAdminBody;

  /// onbAdminWhenUac
  ///
  /// In en, this message translates to:
  /// **'When will the UAC prompt appear?'**
  String get onbAdminWhenUac;

  /// onbAdminWhenUacBody
  ///
  /// In en, this message translates to:
  /// **'The Windows confirmation dialog appears only when you click \'Fix Automatically\' in the Vulnerability Scanner - for example, to enable SmartScreen or Firewall. This is required by Windows for writing to the system registry.'**
  String get onbAdminWhenUacBody;

  /// onbAdminWhyLeastPrivilege
  ///
  /// In en, this message translates to:
  /// **'Why not always run as administrator?'**
  String get onbAdminWhyLeastPrivilege;

  /// onbAdminWhyBody
  ///
  /// In en, this message translates to:
  /// **'Fewer privileges → smaller attack surface. Kaspersky and Defender use the same model (service + UI client). We use a helper executable now, with a full Windows Service planned for Phase 5.'**
  String get onbAdminWhyBody;

  /// threatLibraryTitle
  ///
  /// In en, this message translates to:
  /// **'Threat Library'**
  String get threatLibraryTitle;

  /// threatLibraryDesc
  ///
  /// In en, this message translates to:
  /// **'Catalog of known viruses and attacks with descriptions'**
  String get threatLibraryDesc;

  /// threatLibrarySection
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get threatLibrarySection;

  /// threatLibrarySearchHint
  ///
  /// In en, this message translates to:
  /// **'Search by name or description'**
  String get threatLibrarySearchHint;

  /// threatLibraryCount
  ///
  /// In en, this message translates to:
  /// **'Found: {found} of {total}'**
  String threatLibraryCount(int found, int total);

  /// threatLibraryHomeTitle
  ///
  /// In en, this message translates to:
  /// **'Threat Library'**
  String get threatLibraryHomeTitle;

  /// threatLibraryHomeSubtitle
  ///
  /// In en, this message translates to:
  /// **'Learn about known viruses and attacks before they strike'**
  String get threatLibraryHomeSubtitle;

  /// threatLibraryFilterAll
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get threatLibraryFilterAll;

  /// threatLibraryEmpty
  ///
  /// In en, this message translates to:
  /// **'Nothing found. Try a different search or filter.'**
  String get threatLibraryEmpty;

  /// threatLibraryFilterType
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get threatLibraryFilterType;

  /// threatLibraryFilterCategory
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get threatLibraryFilterCategory;

  /// threatTypeTrojan
  ///
  /// In en, this message translates to:
  /// **'Trojan'**
  String get threatTypeTrojan;

  /// threatTypeSpyware
  ///
  /// In en, this message translates to:
  /// **'Spyware'**
  String get threatTypeSpyware;

  /// threatTypePhishing
  ///
  /// In en, this message translates to:
  /// **'Phishing'**
  String get threatTypePhishing;

  /// threatTypeRansomware
  ///
  /// In en, this message translates to:
  /// **'Ransomware'**
  String get threatTypeRansomware;

  /// threatTypeWorm
  ///
  /// In en, this message translates to:
  /// **'Worm'**
  String get threatTypeWorm;

  /// threatTypeAdware
  ///
  /// In en, this message translates to:
  /// **'Adware'**
  String get threatTypeAdware;

  /// threatTypeExploit
  ///
  /// In en, this message translates to:
  /// **'Exploit'**
  String get threatTypeExploit;

  /// threatTypePup
  ///
  /// In en, this message translates to:
  /// **'PUP'**
  String get threatTypePup;

  /// threatTypeBackdoor
  ///
  /// In en, this message translates to:
  /// **'Backdoor'**
  String get threatTypeBackdoor;

  /// threatTypeRootkit
  ///
  /// In en, this message translates to:
  /// **'Rootkit'**
  String get threatTypeRootkit;

  /// threatTypeTest
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get threatTypeTest;

  /// hygieneCategorySafeDownloads
  ///
  /// In en, this message translates to:
  /// **'Safe Downloads'**
  String get hygieneCategorySafeDownloads;

  /// hygieneCategoryGeneral
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get hygieneCategoryGeneral;

  /// hygieneCategoryPhishing
  ///
  /// In en, this message translates to:
  /// **'Phishing'**
  String get hygieneCategoryPhishing;

  /// hygieneCategoryBackups
  ///
  /// In en, this message translates to:
  /// **'Backups'**
  String get hygieneCategoryBackups;

  /// hygieneCategoryNetworkSecurity
  ///
  /// In en, this message translates to:
  /// **'Network Security'**
  String get hygieneCategoryNetworkSecurity;

  /// hygieneCategorySystemMonitoring
  ///
  /// In en, this message translates to:
  /// **'System Monitoring'**
  String get hygieneCategorySystemMonitoring;

  /// hygieneCategoryPasswords
  ///
  /// In en, this message translates to:
  /// **'Passwords'**
  String get hygieneCategoryPasswords;

  /// hygieneCategoryRemovableMedia
  ///
  /// In en, this message translates to:
  /// **'Removable Media'**
  String get hygieneCategoryRemovableMedia;

  /// cacheStatsHits
  ///
  /// In en, this message translates to:
  /// **'Hits'**
  String get cacheStatsHits;

  /// cacheStatsMisses
  ///
  /// In en, this message translates to:
  /// **'Misses'**
  String get cacheStatsMisses;

  /// cacheStatsEntries
  ///
  /// In en, this message translates to:
  /// **'Entries'**
  String get cacheStatsEntries;

  /// cacheStatsHitRate
  ///
  /// In en, this message translates to:
  /// **'Hit rate'**
  String get cacheStatsHitRate;

  /// cacheStatsInvalidations
  ///
  /// In en, this message translates to:
  /// **'Invalidations'**
  String get cacheStatsInvalidations;

  /// cacheInvalidateButton
  ///
  /// In en, this message translates to:
  /// **'Invalidate'**
  String get cacheInvalidateButton;

  /// cacheClearButton
  ///
  /// In en, this message translates to:
  /// **'Clear cache'**
  String get cacheClearButton;

  /// cacheInvalidateSuccess
  ///
  /// In en, this message translates to:
  /// **'Cache invalidated'**
  String get cacheInvalidateSuccess;

  /// cacheInvalidateFailed
  ///
  /// In en, this message translates to:
  /// **'Invalidation failed'**
  String get cacheInvalidateFailed;

  /// cacheClearSuccess
  ///
  /// In en, this message translates to:
  /// **'Cache cleared'**
  String get cacheClearSuccess;

  /// cacheClearFailed
  ///
  /// In en, this message translates to:
  /// **'Failed to clear cache'**
  String get cacheClearFailed;

  /// cacheClearConfirmTitle
  ///
  /// In en, this message translates to:
  /// **'Clear scan cache?'**
  String get cacheClearConfirmTitle;

  /// cacheClearConfirmMsg
  ///
  /// In en, this message translates to:
  /// **'All cached scan results will be deleted. Files will be re-scanned on the next check.'**
  String get cacheClearConfirmMsg;

  /// cacheClearConfirm
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get cacheClearConfirm;

  /// cacheCoreUnavailable
  ///
  /// In en, this message translates to:
  /// **'Core unavailable - cache statistics not accessible'**
  String get cacheCoreUnavailable;

  /// dllInjectionAlertsTitle
  ///
  /// In en, this message translates to:
  /// **'DLL Injections'**
  String get dllInjectionAlertsTitle;

  /// dllInjectionEmptyState
  ///
  /// In en, this message translates to:
  /// **'No suspicious injections detected'**
  String get dllInjectionEmptyState;

  /// dllInjectionScoreLabel
  ///
  /// In en, this message translates to:
  /// **'score'**
  String get dllInjectionScoreLabel;

  /// memoryActionTerminate
  ///
  /// In en, this message translates to:
  /// **'Terminate process'**
  String get memoryActionTerminate;

  /// memoryActionQuarantine
  ///
  /// In en, this message translates to:
  /// **'Quarantine'**
  String get memoryActionQuarantine;

  /// memoryTerminateConfirmTitle
  ///
  /// In en, this message translates to:
  /// **'Terminate process?'**
  String get memoryTerminateConfirmTitle;

  /// memoryTerminateConfirmMsg
  ///
  /// In en, this message translates to:
  /// **'The process will be force-killed. Unsaved data will be lost.'**
  String get memoryTerminateConfirmMsg;

  /// memoryQuarantineConfirmTitle
  ///
  /// In en, this message translates to:
  /// **'Quarantine file?'**
  String get memoryQuarantineConfirmTitle;

  /// memoryQuarantineConfirmMsg
  ///
  /// In en, this message translates to:
  /// **'The process executable will be moved to quarantine.'**
  String get memoryQuarantineConfirmMsg;

  /// memoryActionSuccess
  ///
  /// In en, this message translates to:
  /// **'Action completed'**
  String get memoryActionSuccess;

  /// memoryActionFailed
  ///
  /// In en, this message translates to:
  /// **'Action failed'**
  String get memoryActionFailed;

  /// eventRealtimeThreatBlocked
  ///
  /// In en, this message translates to:
  /// **'Threat blocked in real time'**
  String get eventRealtimeThreatBlocked;

  /// eventMemoryThreatsFound
  ///
  /// In en, this message translates to:
  /// **'Threats found in process memory'**
  String get eventMemoryThreatsFound;

  /// eventDllInjectionDetected
  ///
  /// In en, this message translates to:
  /// **'DLL injection detected'**
  String get eventDllInjectionDetected;

  /// statsScreenTitle
  ///
  /// In en, this message translates to:
  /// **'Threat Statistics'**
  String get statsScreenTitle;

  /// statsScreenSubtitle
  ///
  /// In en, this message translates to:
  /// **'Protection over time'**
  String get statsScreenSubtitle;

  /// statsPeriod7Days
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get statsPeriod7Days;

  /// statsPeriod30Days
  ///
  /// In en, this message translates to:
  /// **'30 days'**
  String get statsPeriod30Days;

  /// statsPeriod90Days
  ///
  /// In en, this message translates to:
  /// **'90 days'**
  String get statsPeriod90Days;

  /// statsHygieneTrendTitle
  ///
  /// In en, this message translates to:
  /// **'Digital hygiene trend'**
  String get statsHygieneTrendTitle;

  /// statsHygieneTrendEmpty
  ///
  /// In en, this message translates to:
  /// **'Not enough data yet'**
  String get statsHygieneTrendEmpty;

  /// statsThreatsActivityTitle
  ///
  /// In en, this message translates to:
  /// **'Threats activity'**
  String get statsThreatsActivityTitle;

  /// statsThreatsActivityEmpty
  ///
  /// In en, this message translates to:
  /// **'No threats detected in this period'**
  String get statsThreatsActivityEmpty;

  /// statsThreatsTotal
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get statsThreatsTotal;

  /// statsEnginesPerformanceTitle
  ///
  /// In en, this message translates to:
  /// **'Engine performance'**
  String get statsEnginesPerformanceTitle;

  /// statsCacheHitRate
  ///
  /// In en, this message translates to:
  /// **'Cache hit rate'**
  String get statsCacheHitRate;

  /// statsCacheEntries
  ///
  /// In en, this message translates to:
  /// **'Cached entries'**
  String get statsCacheEntries;

  /// statsYaraRules
  ///
  /// In en, this message translates to:
  /// **'YARA rules'**
  String get statsYaraRules;

  /// statsQuarantineCount
  ///
  /// In en, this message translates to:
  /// **'Quarantined'**
  String get statsQuarantineCount;

  /// statsThreatSourcesTitle
  ///
  /// In en, this message translates to:
  /// **'Threat sources'**
  String get statsThreatSourcesTitle;

  /// statsThreatSourcesEmpty
  ///
  /// In en, this message translates to:
  /// **'No source data'**
  String get statsThreatSourcesEmpty;

  /// statsSourceScan
  ///
  /// In en, this message translates to:
  /// **'Scanner'**
  String get statsSourceScan;

  /// statsSourceRealtime
  ///
  /// In en, this message translates to:
  /// **'Real-time'**
  String get statsSourceRealtime;

  /// statsSourceMemory
  ///
  /// In en, this message translates to:
  /// **'Memory'**
  String get statsSourceMemory;

  /// statsSourceWeb
  ///
  /// In en, this message translates to:
  /// **'Web'**
  String get statsSourceWeb;

  /// statsLoadingError
  ///
  /// In en, this message translates to:
  /// **'Failed to load statistics'**
  String get statsLoadingError;

  /// statsCoreNotReady
  ///
  /// In en, this message translates to:
  /// **'Core not initialised'**
  String get statsCoreNotReady;

  /// statsRunScanHint
  ///
  /// In en, this message translates to:
  /// **'Run a scan to populate data'**
  String get statsRunScanHint;

  /// statsHomeCardThreatsTodayShort
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get statsHomeCardThreatsTodayShort;

  /// severityLabelInfo
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get severityLabelInfo;

  /// severityLabelWarning
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get severityLabelWarning;

  /// severityLabelHigh
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get severityLabelHigh;

  /// severityLabelCritical
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get severityLabelCritical;

  /// sandboxTitle
  ///
  /// In en, this message translates to:
  /// **'Sandbox'**
  String get sandboxTitle;

  /// sandboxDescription
  ///
  /// In en, this message translates to:
  /// **'Behavioural analysis of suspicious files'**
  String get sandboxDescription;

  /// sandboxRunningBadge
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get sandboxRunningBadge;

  /// sandboxAnalyse
  ///
  /// In en, this message translates to:
  /// **'Analyse in Sandbox'**
  String get sandboxAnalyse;

  /// sandboxRunning
  ///
  /// In en, this message translates to:
  /// **'Running sandbox analysis...'**
  String get sandboxRunning;

  /// sandboxReport
  ///
  /// In en, this message translates to:
  /// **'Behavioral Report'**
  String get sandboxReport;

  /// sandboxCancel
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get sandboxCancel;

  /// sandboxRiskScore
  ///
  /// In en, this message translates to:
  /// **'Risk score'**
  String get sandboxRiskScore;

  /// sandboxRiskIndicators
  ///
  /// In en, this message translates to:
  /// **'Risk indicators'**
  String get sandboxRiskIndicators;

  /// sandboxChildProcesses
  ///
  /// In en, this message translates to:
  /// **'Child processes'**
  String get sandboxChildProcesses;

  /// sandboxLoadedModules
  ///
  /// In en, this message translates to:
  /// **'Loaded modules'**
  String get sandboxLoadedModules;

  /// sandboxMemorySpikes
  ///
  /// In en, this message translates to:
  /// **'Memory spikes'**
  String get sandboxMemorySpikes;

  /// sandboxNoBehaviour
  ///
  /// In en, this message translates to:
  /// **'No suspicious behaviour detected.'**
  String get sandboxNoBehaviour;

  /// sandboxError
  ///
  /// In en, this message translates to:
  /// **'Sandbox error'**
  String get sandboxError;

  /// sandboxRequiresAdmin
  ///
  /// In en, this message translates to:
  /// **'Sandbox requires Windows 8 or later'**
  String get sandboxRequiresAdmin;

  /// sandboxStartFailed
  ///
  /// In en, this message translates to:
  /// **'Failed to start sandbox'**
  String get sandboxStartFailed;

  /// sandboxErrorUnsupported
  ///
  /// In en, this message translates to:
  /// **'This file type is not supported by sandbox. Supported: .exe, .ps1, .bat, .cmd, .vbs, .js'**
  String get sandboxErrorUnsupported;

  /// sandboxErrorBadFormat
  ///
  /// In en, this message translates to:
  /// **'File is not executable. EICAR, .txt, .pdf and similar files cannot be launched directly'**
  String get sandboxErrorBadFormat;

  /// sandboxErrorFileNotFound
  ///
  /// In en, this message translates to:
  /// **'File not found - it may have been deleted or moved'**
  String get sandboxErrorFileNotFound;

  /// sandboxErrorAccessDenied
  ///
  /// In en, this message translates to:
  /// **'Access denied. Check file read permissions'**
  String get sandboxErrorAccessDenied;

  /// sandboxErrorAlreadyRunning
  ///
  /// In en, this message translates to:
  /// **'Sandbox is already running an analysis. Wait for it to finish or cancel it'**
  String get sandboxErrorAlreadyRunning;

  /// sandboxErrorDllUnsupported
  ///
  /// In en, this message translates to:
  /// **'DLL analysis is not yet supported (requires an export entry point)'**
  String get sandboxErrorDllUnsupported;

  /// sandboxErrorNestedJobsUnsupported
  ///
  /// In en, this message translates to:
  /// **'Cannot isolate the process - your system does not support nested Job Objects (Windows 8 or later required)'**
  String get sandboxErrorNestedJobsUnsupported;

  /// sandboxErrorCopyFailed
  ///
  /// In en, this message translates to:
  /// **'Failed to copy the file to a temporary directory for safe analysis. Check available disk space'**
  String get sandboxErrorCopyFailed;

  /// sandboxErrorBlocked
  ///
  /// In en, this message translates to:
  /// **'File launch was blocked by the security system (antivirus or process restrictions). See MentoringProtector.log for details'**
  String get sandboxErrorBlocked;

  /// sandboxErrorAppContainerProfile
  ///
  /// In en, this message translates to:
  /// **'Failed to create AppContainer profile for isolation. Group Policy may block AppContainers'**
  String get sandboxErrorAppContainerProfile;

  /// sandboxErrorAppContainerAce
  ///
  /// In en, this message translates to:
  /// **'Failed to grant sandbox access to temporary directory. Check permissions on %TEMP%'**
  String get sandboxErrorAppContainerAce;

  /// statsTabDashboard
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get statsTabDashboard;

  /// statsTabHistory
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get statsTabHistory;

  /// archiveSearchHint
  ///
  /// In en, this message translates to:
  /// **'Search by file or threat name'**
  String get archiveSearchHint;

  /// archiveFilterAll
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get archiveFilterAll;

  /// archiveFilterScan
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get archiveFilterScan;

  /// archiveFilterSandbox
  ///
  /// In en, this message translates to:
  /// **'Sandbox'**
  String get archiveFilterSandbox;

  /// archiveEmptyTitle
  ///
  /// In en, this message translates to:
  /// **'Archive is empty'**
  String get archiveEmptyTitle;

  /// archiveEmptyDescription
  ///
  /// In en, this message translates to:
  /// **'Completed scans and sandbox analyses will appear here'**
  String get archiveEmptyDescription;

  /// archiveClearMenu
  ///
  /// In en, this message translates to:
  /// **'Clear archive'**
  String get archiveClearMenu;

  /// archiveClearConfirm
  ///
  /// In en, this message translates to:
  /// **'Delete all archive records? This cannot be undone.'**
  String get archiveClearConfirm;

  /// archiveCleared
  ///
  /// In en, this message translates to:
  /// **'Archive cleared'**
  String get archiveCleared;

  /// sandboxErrorGeneric
  ///
  /// In en, this message translates to:
  /// **'Failed to start sandbox: {code}'**
  String sandboxErrorGeneric(String code);

  /// sandboxArchiveExtractFirst
  ///
  /// In en, this message translates to:
  /// **'Could not extract the file from the archive for sandbox analysis.'**
  String get sandboxArchiveExtractFirst;

  /// sandboxArchiveNotExecutable
  ///
  /// In en, this message translates to:
  /// **'The file inside the archive is not executable. Sandbox supports only: .exe, .ps1, .bat, .cmd, .vbs, .js'**
  String get sandboxArchiveNotExecutable;

  /// actionCenterTitle
  ///
  /// In en, this message translates to:
  /// **'Action Center'**
  String get actionCenterTitle;

  /// actionCenterEmpty
  ///
  /// In en, this message translates to:
  /// **'No threats detected yet'**
  String get actionCenterEmpty;

  /// actionCenterViewAll
  ///
  /// In en, this message translates to:
  /// **'View all incidents'**
  String get actionCenterViewAll;

  /// actionCenterCount
  ///
  /// In en, this message translates to:
  /// **'{count} incidents'**
  String actionCenterCount(int count);

  /// btnWhitelist
  ///
  /// In en, this message translates to:
  /// **'Whitelist'**
  String get btnWhitelist;

  /// btnLearn
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get btnLearn;

  /// incidentStatusPending
  ///
  /// In en, this message translates to:
  /// **'Action needed'**
  String get incidentStatusPending;

  /// incidentStatusQuarantined
  ///
  /// In en, this message translates to:
  /// **'Quarantined'**
  String get incidentStatusQuarantined;

  /// incidentStatusWhitelisted
  ///
  /// In en, this message translates to:
  /// **'Excluded'**
  String get incidentStatusWhitelisted;

  /// incidentStatusIgnored
  ///
  /// In en, this message translates to:
  /// **'Ignored'**
  String get incidentStatusIgnored;

  /// incidentReEvaluate
  ///
  /// In en, this message translates to:
  /// **'Re-evaluate'**
  String get incidentReEvaluate;

  /// incidentWhitelistSuccess
  ///
  /// In en, this message translates to:
  /// **'File added to exclusions'**
  String get incidentWhitelistSuccess;

  /// incidentWhitelistFailed
  ///
  /// In en, this message translates to:
  /// **'Failed to add exclusion'**
  String get incidentWhitelistFailed;

  /// actionCenterSearchHint
  ///
  /// In en, this message translates to:
  /// **'Search by file or threat name'**
  String get actionCenterSearchHint;

  /// actionCenterGroupToday
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get actionCenterGroupToday;

  /// actionCenterGroupYesterday
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get actionCenterGroupYesterday;

  /// actionCenterDetectionMethod
  ///
  /// In en, this message translates to:
  /// **'Detection: {method}'**
  String actionCenterDetectionMethod(String method);

  /// nudgeDismiss
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get nudgeDismiss;

  /// nudgeScanFile
  ///
  /// In en, this message translates to:
  /// **'Scan file'**
  String get nudgeScanFile;

  /// nudgeQuarantine
  ///
  /// In en, this message translates to:
  /// **'Quarantine'**
  String get nudgeQuarantine;

  /// nudgeTrust
  ///
  /// In en, this message translates to:
  /// **'I trust this file'**
  String get nudgeTrust;

  /// nudgeCheckDrive
  ///
  /// In en, this message translates to:
  /// **'Check drive'**
  String get nudgeCheckDrive;

  /// nudgeDownloadedExeTitle
  ///
  /// In en, this message translates to:
  /// **'Downloaded executable'**
  String get nudgeDownloadedExeTitle;

  /// nudgeDownloadedExeTip
  ///
  /// In en, this message translates to:
  /// **'Executable files downloaded from the internet are a top malware delivery method. Attackers disguise malware as software installers, free tools, or cracked programs.'**
  String get nudgeDownloadedExeTip;

  /// nudgeDownloadedExeCheck1
  ///
  /// In en, this message translates to:
  /// **'Is this from an official website or trusted app store?'**
  String get nudgeDownloadedExeCheck1;

  /// nudgeDownloadedExeCheck2
  ///
  /// In en, this message translates to:
  /// **'Check the file hash on VirusTotal before running.'**
  String get nudgeDownloadedExeCheck2;

  /// nudgeDownloadedExeCheck3
  ///
  /// In en, this message translates to:
  /// **'Watch for double extensions like \'document.pdf.exe\' - a classic trick.'**
  String get nudgeDownloadedExeCheck3;

  /// nudgeDownloadedExeAction1
  ///
  /// In en, this message translates to:
  /// **'Scan the file with MentoringProtector before opening.'**
  String get nudgeDownloadedExeAction1;

  /// nudgeDownloadedExeAction2
  ///
  /// In en, this message translates to:
  /// **'If unsure - quarantine until you can verify the source.'**
  String get nudgeDownloadedExeAction2;

  /// nudgeDownloadedContainerTitle
  ///
  /// In en, this message translates to:
  /// **'Downloaded container file'**
  String get nudgeDownloadedContainerTitle;

  /// nudgeDownloadedContainerTip
  ///
  /// In en, this message translates to:
  /// **'Container files (ISO, VHD, 7z) downloaded from the internet do NOT pass the \'mark of the web\' to files inside them. Attackers abuse this (ISO smuggling) so extracted executables don\'t trigger the usual download warning.'**
  String get nudgeDownloadedContainerTip;

  /// nudgeDownloadedContainerCheck1
  ///
  /// In en, this message translates to:
  /// **'Did you expect a disk image or archive from this source?'**
  String get nudgeDownloadedContainerCheck1;

  /// nudgeDownloadedContainerCheck2
  ///
  /// In en, this message translates to:
  /// **'Executables extracted from it will NOT show the \'downloaded from internet\' warning - treat them as untrusted.'**
  String get nudgeDownloadedContainerCheck2;

  /// nudgeDownloadedContainerCheck3
  ///
  /// In en, this message translates to:
  /// **'Scan the container with MentoringProtector instead of mounting or extracting it blindly.'**
  String get nudgeDownloadedContainerCheck3;

  /// nudgeDownloadedContainerAction1
  ///
  /// In en, this message translates to:
  /// **'Scan the container and its contents before extracting or mounting.'**
  String get nudgeDownloadedContainerAction1;

  /// nudgeDownloadedContainerAction2
  ///
  /// In en, this message translates to:
  /// **'If unsure - quarantine the container until you verify the source.'**
  String get nudgeDownloadedContainerAction2;

  /// nudgeMacroDocumentTitle
  ///
  /// In en, this message translates to:
  /// **'Macro-enabled document'**
  String get nudgeMacroDocumentTitle;

  /// nudgeMacroDocumentTip
  ///
  /// In en, this message translates to:
  /// **'Macro-enabled Office documents (.docm, .xlsm) can execute code when opened. This format is commonly used in phishing attacks to deliver malware without a visible executable.'**
  String get nudgeMacroDocumentTip;

  /// nudgeMacroDocumentCheck1
  ///
  /// In en, this message translates to:
  /// **'Did you expect this file? Was it from a trusted sender?'**
  String get nudgeMacroDocumentCheck1;

  /// nudgeMacroDocumentCheck2
  ///
  /// In en, this message translates to:
  /// **'Legitimate business files rarely need macros enabled.'**
  String get nudgeMacroDocumentCheck2;

  /// nudgeMacroDocumentCheck3
  ///
  /// In en, this message translates to:
  /// **'If the document says \'Enable Content to view\' - that is a red flag.'**
  String get nudgeMacroDocumentCheck3;

  /// nudgeMacroDocumentAction1
  ///
  /// In en, this message translates to:
  /// **'Open in Protected View (read-only) first.'**
  String get nudgeMacroDocumentAction1;

  /// nudgeMacroDocumentAction2
  ///
  /// In en, this message translates to:
  /// **'Only enable macros if you personally requested this file.'**
  String get nudgeMacroDocumentAction2;

  /// nudgeSuspiciousScriptTitle
  ///
  /// In en, this message translates to:
  /// **'Suspicious script'**
  String get nudgeSuspiciousScriptTitle;

  /// nudgeSuspiciousScriptTip
  ///
  /// In en, this message translates to:
  /// **'This script contains patterns commonly used in malicious PowerShell or VBScript: downloading files from the internet, encoded commands, or hidden execution - all classic signs of a malware loader.'**
  String get nudgeSuspiciousScriptTip;

  /// nudgeSuspiciousScriptCheck1
  ///
  /// In en, this message translates to:
  /// **'Do you know who wrote this script and what it is supposed to do?'**
  String get nudgeSuspiciousScriptCheck1;

  /// nudgeSuspiciousScriptCheck2
  ///
  /// In en, this message translates to:
  /// **'Encoded commands (-EncodedCommand, FromBase64String) hide what the script actually does.'**
  String get nudgeSuspiciousScriptCheck2;

  /// nudgeSuspiciousScriptCheck3
  ///
  /// In en, this message translates to:
  /// **'Legitimate system scripts rarely need to download files at runtime.'**
  String get nudgeSuspiciousScriptCheck3;

  /// nudgeSuspiciousScriptAction1
  ///
  /// In en, this message translates to:
  /// **'Open the script in a text editor and review its contents before running.'**
  String get nudgeSuspiciousScriptAction1;

  /// nudgeSuspiciousScriptAction2
  ///
  /// In en, this message translates to:
  /// **'If received unexpectedly - delete and contact the sender through a different channel.'**
  String get nudgeSuspiciousScriptAction2;

  /// nudgeUsbDeviceTitle
  ///
  /// In en, this message translates to:
  /// **'Removable drive connected'**
  String get nudgeUsbDeviceTitle;

  /// nudgeUsbDeviceTip
  ///
  /// In en, this message translates to:
  /// **'Unknown USB drives are a real attack vector. \'BadUSB\' devices pretend to be keyboards and type malicious commands. Even found drives should not be trusted - this is a known social engineering technique.'**
  String get nudgeUsbDeviceTip;

  /// nudgeUsbDeviceCheck1
  ///
  /// In en, this message translates to:
  /// **'Do you know where this drive came from?'**
  String get nudgeUsbDeviceCheck1;

  /// nudgeUsbDeviceCheck2
  ///
  /// In en, this message translates to:
  /// **'Never plug in found drives - this is a classic social engineering attack.'**
  String get nudgeUsbDeviceCheck2;

  /// nudgeUsbDeviceCheck3
  ///
  /// In en, this message translates to:
  /// **'Autorun is disabled in Windows 7+, but malicious .lnk or .exe files can still be dangerous.'**
  String get nudgeUsbDeviceCheck3;

  /// nudgeUsbDeviceAction1
  ///
  /// In en, this message translates to:
  /// **'Scan the drive with MentoringProtector before opening any files.'**
  String get nudgeUsbDeviceAction1;

  /// nudgeUsbDeviceAction2
  ///
  /// In en, this message translates to:
  /// **'If you do not recognize this drive - eject it without opening.'**
  String get nudgeUsbDeviceAction2;

  /// nudgeSource
  ///
  /// In en, this message translates to:
  /// **'Source:'**
  String get nudgeSource;

  /// nudgeChecklist
  ///
  /// In en, this message translates to:
  /// **'Checklist'**
  String get nudgeChecklist;

  /// nudgeWhatToDo
  ///
  /// In en, this message translates to:
  /// **'What to do'**
  String get nudgeWhatToDo;

  /// nudgeUsbScanning
  ///
  /// In en, this message translates to:
  /// **'Scanning...'**
  String get nudgeUsbScanning;

  /// nudgeUsbScanDone
  ///
  /// In en, this message translates to:
  /// **'Scan complete'**
  String get nudgeUsbScanDone;

  /// nudgeUsbNoThreats
  ///
  /// In en, this message translates to:
  /// **'No threats found'**
  String get nudgeUsbNoThreats;

  /// nudgeUsbThreats
  ///
  /// In en, this message translates to:
  /// **'Threats found'**
  String get nudgeUsbThreats;

  /// nudgeUsbRescan
  ///
  /// In en, this message translates to:
  /// **'Scan again'**
  String get nudgeUsbRescan;

  /// serviceManaged
  ///
  /// In en, this message translates to:
  /// **'Managed by system service'**
  String get serviceManaged;

  /// requiresElevation
  ///
  /// In en, this message translates to:
  /// **'Requires administrator rights'**
  String get requiresElevation;

  /// serviceCmdFailed
  ///
  /// In en, this message translates to:
  /// **'Failed to send command to service'**
  String get serviceCmdFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
