import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../theme/spacing.dart';
import '../../widgets/app_card.dart';
import 'threat_library_screen.dart';
import '../../theme/app_theme.dart';

class ThreatLibraryEntryCard extends StatelessWidget {
  const ThreatLibraryEntryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final colors = state.colors;
    final l10n = state.strings;

    return AppCard(
      padding: Spacing.cardPadding,
      onTap: () => Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const ThreatLibraryScreen(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 200),
          reverseTransitionDuration: const Duration(milliseconds: 150),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.menu_book_outlined, color: colors.primary, size: 20),
          ),
          const SizedBox(width: Spacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.threatLibraryHomeTitle,
                  style: TextStyle(
                    fontSize: AppTextStyles.sizeDefault,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.threatLibraryHomeSubtitle,
                  style: TextStyle(fontSize: AppTextStyles.sizeXSmall, color: colors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.s),
          Icon(Icons.chevron_right, color: colors.textHint, size: 20),
        ],
      ),
    );
  }
}

