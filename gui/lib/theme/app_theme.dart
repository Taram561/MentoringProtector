import 'package:flutter/material.dart';

abstract final class AppColors {
  static const background      = Color(0xFFF0F7FF);
  static const surface         = Color(0xFFFFFFFF);
  static const surfaceVariant  = Color(0xFFE3F2FD);
  static const primary         = Color(0xFF2196F3);
  static const primaryLight    = Color(0xFF64B5F6);
  static const primaryDark     = Color(0xFF1565C0);
  static const onPrimary       = Color(0xFFFFFFFF);
  static const textPrimary     = Color(0xFF1A237E);
  static const textSecondary   = Color(0xFF546E7A);
  static const textHint        = Color(0xFF90A4AE);
  static const onSurface       = Color(0xFF1A237E);
  static const onSurfaceMuted  = Color(0xFF90A4AE);
  static const divider         = Color(0xFFBBDEFB);
  static const cardBorder      = Color(0xFFE3F2FD);
  static const success         = Color(0xFF43A047);
  static const successLight    = Color(0xFFE8F5E9);
  static const warning         = Color(0xFFFB8C00);
  static const warningLight    = Color(0xFFFFF3E0);
  static const danger          = Color(0xFFE53935);
  static const dangerLight     = Color(0xFFFFEBEE);
  static const gradientStart   = Color(0xFF2196F3);
  static const gradientEnd     = Color(0xFF1976D2);
  static const severityLow     = Color(0xFF43A047);
  static const severityMedium  = Color(0xFFFB8C00);
  static const severityHigh    = Color(0xFFE53935);
  static const severityCritical = Color(0xFFB71C1C);
  static const accentPurple    = Color(0xFF9C27B0);
  static const accentTeal      = Color(0xFF00897B);
  static const overlay         = Color(0x80000000);
  static const inkRipple       = Color(0x1F2196F3);
}

abstract final class AppColorsDark {
  static const background      = Color(0xFF0D1117);
  static const surface         = Color(0xFF161B22);
  static const surfaceVariant  = Color(0xFF21262D);
  static const primary         = Color(0xFF58A6FF);
  static const primaryLight    = Color(0xFF79C0FF);
  static const primaryDark     = Color(0xFF1F6FEB);
  static const onPrimary       = Color(0xFF0D1117);
  static const textPrimary     = Color(0xFFE6EDF3);
  static const textSecondary   = Color(0xFF8B949E);
  static const textHint        = Color(0xFF484F58);
  static const onSurface       = Color(0xFFE6EDF3);
  static const onSurfaceMuted  = Color(0xFF484F58);
  static const divider         = Color(0xFF21262D);
  static const cardBorder      = Color(0xFF30363D);
  static const success         = Color(0xFF3FB950);
  static const successLight    = Color(0xFF0F2D1A);
  static const warning         = Color(0xFFD29922);
  static const warningLight    = Color(0xFF2D1F08);
  static const danger          = Color(0xFFF85149);
  static const dangerLight     = Color(0xFF2D1215);
  static const gradientStart   = Color(0xFF2B7EFF);
  static const gradientEnd     = Color(0xFF1652CC);
  static const severityLow     = Color(0xFF3FB950);
  static const severityMedium  = Color(0xFFD29922);
  static const severityHigh    = Color(0xFFF85149);
  static const severityCritical = Color(0xFFFF6B6B);
  static const accentPurple    = Color(0xFFCE93D8);
  static const accentTeal      = Color(0xFF80CBC4);
  static const overlay         = Color(0xCC000000);
  static const inkRipple       = Color(0x1F58A6FF);
}

class AdaptiveColors {
  final bool isDark;
  const AdaptiveColors(this.isDark);

  Color get background      => isDark ? AppColorsDark.background      : AppColors.background;
  Color get surface         => isDark ? AppColorsDark.surface         : AppColors.surface;
  Color get surfaceVariant  => isDark ? AppColorsDark.surfaceVariant  : AppColors.surfaceVariant;
  Color get primary         => isDark ? AppColorsDark.primary         : AppColors.primary;
  Color get primaryLight    => isDark ? AppColorsDark.primaryLight    : AppColors.primaryLight;
  Color get primaryDark     => isDark ? AppColorsDark.primaryDark     : AppColors.primaryDark;
  Color get onPrimary       => isDark ? AppColorsDark.onPrimary       : AppColors.onPrimary;
  Color get textPrimary     => isDark ? AppColorsDark.textPrimary     : AppColors.textPrimary;
  Color get textSecondary   => isDark ? AppColorsDark.textSecondary   : AppColors.textSecondary;
  Color get textHint        => isDark ? AppColorsDark.textHint        : AppColors.textHint;
  Color get onSurface       => isDark ? AppColorsDark.onSurface       : AppColors.onSurface;
  Color get onSurfaceMuted  => isDark ? AppColorsDark.onSurfaceMuted  : AppColors.onSurfaceMuted;
  Color get divider         => isDark ? AppColorsDark.divider         : AppColors.divider;
  Color get cardBorder      => isDark ? AppColorsDark.cardBorder      : AppColors.cardBorder;
  Color get success         => isDark ? AppColorsDark.success         : AppColors.success;
  Color get successLight    => isDark ? AppColorsDark.successLight    : AppColors.successLight;
  Color get warning         => isDark ? AppColorsDark.warning         : AppColors.warning;
  Color get warningLight    => isDark ? AppColorsDark.warningLight    : AppColors.warningLight;
  Color get danger          => isDark ? AppColorsDark.danger          : AppColors.danger;
  Color get dangerLight     => isDark ? AppColorsDark.dangerLight     : AppColors.dangerLight;
  Color get gradientStart   => isDark ? AppColorsDark.gradientStart   : AppColors.gradientStart;
  Color get gradientEnd     => isDark ? AppColorsDark.gradientEnd     : AppColors.gradientEnd;
  Color get severityLow     => isDark ? AppColorsDark.severityLow     : AppColors.severityLow;
  Color get severityMedium  => isDark ? AppColorsDark.severityMedium  : AppColors.severityMedium;
  Color get severityHigh    => isDark ? AppColorsDark.severityHigh    : AppColors.severityHigh;
  Color get severityCritical => isDark ? AppColorsDark.severityCritical : AppColors.severityCritical;
  Color get accentPurple    => isDark ? AppColorsDark.accentPurple    : AppColors.accentPurple;
  Color get accentTeal      => isDark ? AppColorsDark.accentTeal      : AppColors.accentTeal;
  Color get overlay         => isDark ? AppColorsDark.overlay         : AppColors.overlay;
  Color get inkRipple       => isDark ? AppColorsDark.inkRipple       : AppColors.inkRipple;

  Color severityColor(int level) => switch (level) {
    >= 9 => severityCritical,
    >= 7 => severityHigh,
    >= 4 => severityMedium,
    _    => severityLow,
  };
}

abstract final class AppTextStyles {
  static const headline = TextStyle(
    fontSize: AppTextStyles.sizeHeadline, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, letterSpacing: -0.5,
  );
  static const title = TextStyle(
    fontSize: AppTextStyles.sizeSubtitle, fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static const body = TextStyle(
    fontSize: AppTextStyles.sizeBody, fontWeight: FontWeight.w400,
    color: AppColors.textSecondary, height: 1.5,
  );
  static const caption = TextStyle(
    fontSize: AppTextStyles.sizeSmall, fontWeight: FontWeight.w400,
    color: AppColors.textHint,
  );
  static const button = TextStyle(
    fontSize: AppTextStyles.sizeLabel, fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );

  static const double sizeMicro    = 9;
  static const double sizeTiny     = 10;
  static const double sizeXSmall   = 11;
  static const double sizeSmall    = 12;
  static const double sizeDefault  = 13;
  static const double sizeBody     = 14;
  static const double sizeLabel    = 15;
  static const double sizeSubtitle = 16;
  static const double sizeMedium    = 17;
  static const double sizeSubheader = 18;
  static const double sizeHeader   = 20;
  static const double sizeHeadline = 22;
  static const double sizeLarge    = 24;
  static const double sizeHero     = 28;
}

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    cardTheme: const CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        side: BorderSide(color: AppColors.cardBorder),
      ),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surface,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
            horizontal: 24, vertical: 14),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        textStyle: AppTextStyles.button,
      ),
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColorsDark.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColorsDark.primary,
      brightness: Brightness.dark,
    ).copyWith(
      surface: AppColorsDark.surface,
    ),
    cardTheme: const CardThemeData(
      color: AppColorsDark.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        side: BorderSide(color: AppColorsDark.cardBorder),
      ),
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColorsDark.primary,
        foregroundColor: AppColorsDark.background,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
            horizontal: 24, vertical: 14),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        textStyle: AppTextStyles.button,
      ),
    ),
    dividerColor: AppColorsDark.divider,
    iconTheme: const IconThemeData(
        color: AppColorsDark.textSecondary),
  );
}

