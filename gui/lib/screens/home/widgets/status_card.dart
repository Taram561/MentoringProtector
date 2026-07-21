import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_state_provider.dart';
import '../../../providers/module_status_provider.dart';
import '../../../theme/app_theme.dart';

enum ProtectionStatus { protected, warning, danger }

class StatusCard extends StatelessWidget {
  final ProtectionStatus status;
  final String           lastScanText;
  final VoidCallback     onScanPressed;

  const StatusCard({
    super.key,
    required this.status,
    required this.lastScanText,
    required this.onScanPressed,
  });

  @override
  Widget build(BuildContext context) {
    final state   = context.watch<AppStateProvider>();
    final modules = context.watch<ModuleStatusProvider>();
    final l10n    = state.strings;
    final colors  = state.colors;
    final isDark  = state.isDark;

    final statusText = switch (status) {
      ProtectionStatus.protected => l10n.homeProtected,
      ProtectionStatus.warning   => l10n.homeWarning,
      ProtectionStatus.danger    => l10n.homeDanger,
    };

    final iconColor = switch (status) {
      ProtectionStatus.protected => AppColors.onPrimary,
      ProtectionStatus.warning   => colors.warning,
      ProtectionStatus.danger    => colors.danger,
    };

    final mpColor = colors.gradientEnd;

    final btnBg      = AppColors.onPrimary.withValues(alpha: 0.15);
    final btnFg      = AppColors.onPrimary;
    final btnBorder  = AppColors.onPrimary.withValues(alpha: 0.4);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.gradientEnd,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: AppColors.onPrimary.withValues(alpha: 
                  isDark ? 0.08 : 0.15),
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.shield, size: 40,
                    color: iconColor),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text('MP',
                    style: TextStyle(
                      color: mpColor,
                      fontSize: AppTextStyles.sizeDefault,
                      fontWeight: FontWeight.w900,
                      height: 1,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text(statusText,
              style: TextStyle(
                fontSize: AppTextStyles.sizeHeader,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.onPrimary.withValues(alpha: 0.95)
                    : AppColors.onPrimary,
              )),
              
          const SizedBox(height: 8),
          Text(
            state.lastScanDate.isEmpty
                ? l10n.homeNeverScanned
                : '${l10n.homeLastScan}: ${state.lastScanDate}',
              style: TextStyle(
                fontSize: AppTextStyles.sizeDefault,
                color: AppColors.onPrimary.withValues(alpha: 
                    isDark ? 0.6 : 0.8),
              )),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.onPrimary.withValues(alpha: isDark ? 0.08 : 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.security, size: 18,
                    color: AppColors.onPrimary.withValues(alpha: 0.9)),
                const SizedBox(width: 8),
                Text(
                  '${l10n.homeActiveModules}: ${modules.activeModulesCount} / 5',
                  style: TextStyle(
                    fontSize: AppTextStyles.sizeDefault,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onPrimary.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onScanPressed,
              style: OutlinedButton.styleFrom(
                backgroundColor: btnBg,
                foregroundColor: btnFg,
                side: BorderSide(color: btnBorder, width: 1),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 20, color: btnFg),
                  const SizedBox(width: 8),
                  Text(l10n.homeStartScan,
                      style: TextStyle(
                        fontSize: AppTextStyles.sizeLabel,
                        fontWeight: FontWeight.w600,
                        color: btnFg,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

