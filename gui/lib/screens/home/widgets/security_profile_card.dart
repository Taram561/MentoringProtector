import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.g.dart';
import '../../../providers/user_profile_provider.dart';
import '../../../models/user_profile.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/spacing.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/stat_chip.dart';

class SecurityProfileCard extends StatelessWidget {
  final AdaptiveColors colors;
  final AppLocalizations l10n;

  const SecurityProfileCard({
    super.key,
    required this.colors,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final pp = context.watch<UserProfileProvider>();
    final riskScore = pp.riskScore;
    final safetyScore = 100 - riskScore;
    final tier = pp.riskTier;
    final level = pp.level;

    final tierLabel = switch (tier) {
      RiskTier.safe      => l10n.profileRiskTierSafe,
      RiskTier.cautious  => l10n.profileRiskTierCautious,
      RiskTier.risky     => l10n.profileRiskTierRisky,
      RiskTier.dangerous => l10n.profileRiskTierDangerous,
    };

    final tierColor = switch (tier) {
      RiskTier.safe      => colors.success,
      RiskTier.cautious  => colors.warning,
      RiskTier.risky     => colors.severityHigh,
      RiskTier.dangerous => colors.danger,
    };

    final levelLabel = switch (level) {
      UserLevel.beginner => l10n.onboardingBeginner,
      UserLevel.regular  => l10n.onboardingRegular,
      UserLevel.advanced => l10n.onboardingAdvanced,
    };

    return AppCard(
      margin: EdgeInsets.zero,
      padding: Spacing.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person_outlined, color: colors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${l10n.profileLevel}: $levelLabel',
                  style: TextStyle(
                    fontSize: AppTextStyles.sizeBody,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.profileSafetyScore,
                  style: TextStyle(fontSize: AppTextStyles.sizeDefault, color: colors.textSecondary),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.s, vertical: Spacing.xs),
                  decoration: BoxDecoration(
                    color: tierColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$safetyScore/100 - $tierLabel',
                    style: TextStyle(
                      fontSize: AppTextStyles.sizeSmall,
                      fontWeight: FontWeight.w600,
                      color: tierColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 6,
                child: Stack(
                  children: [
                    Container(
                      color: colors.divider.withValues(alpha: 0.3),
                    ),
                    FractionallySizedBox(
                      widthFactor: (safetyScore / 100).clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: tierColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(child: StatChip(
                  icon: Icons.check_circle_outline,
                  label: l10n.profilePositiveActions,
                  value: '${pp.profile.positiveActions}',
                  color: colors.success,
                )),
                const SizedBox(width: Spacing.m),
                Expanded(child: StatChip(
                  icon: Icons.warning_amber_rounded,
                  label: l10n.profileRiskyActions,
                  value: '${pp.profile.riskyActions}',
                  color: colors.danger,
                )),
              ],
            ),
          ],
        ),
    );
  }
}

