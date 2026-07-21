import 'package:flutter/material.dart';
import '../l10n/app_localizations.g.dart';
import '../l10n/app_localizations_ru.g.dart';
import '../l10n/app_localizations_en.g.dart';
import '../theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ffi/core_bindings.dart';

class AppStateProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  String _locale = 'ru';
  String _coreVersion = '-';
  String _lastScanDate = '';

  ThemeMode get themeMode => _themeMode;
  String get locale => _locale;
  String get coreVersion => _coreVersion;
  String get lastScanDate => _lastScanDate;

  bool get isDark {
    if (_themeMode == ThemeMode.system) {
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  AdaptiveColors get colors => AdaptiveColors(isDark);
  Locale get flutterLocale => Locale(_locale);
  AppLocalizations get strings => _locale == 'ru' ? AppLocalizationsRu() : AppLocalizationsEn();

  bool get coreReady => CoreBindings.isInitialized;

  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setLocale(String locale) {
    _locale = locale;
    notifyListeners();
  }

  void setCoreVersion(String version) {
    _coreVersion = version;
    notifyListeners();
  }

  AppStateProvider() {
    _loadLastScanDate();
    _loadCoreVersion();
  }

  Future<void> _loadLastScanDate() async {
    final prefs = await SharedPreferences.getInstance();
    _lastScanDate = prefs.getString('last_scan_date') ?? '';
    notifyListeners();
  }

  Future<void> saveLastScanDate() async {
    final now = DateTime.now();
    final str = '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_scan_date', str);
    _lastScanDate = str;
    notifyListeners();
  }

  Future<void> _loadCoreVersion() async {
    try {
      final bindings = CoreBindings.instance;
      final version = bindings.callReturningString(bindings.getCoreVersion);
      _coreVersion = version;
      notifyListeners();
    } catch (e) { debugPrint('[MP] FFI error: $e'); }
  }
}

