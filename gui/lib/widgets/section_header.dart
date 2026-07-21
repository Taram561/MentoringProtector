import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum SectionHeaderStyle { iconUppercase, compact }

class SectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final AdaptiveColors colors;
  final SectionHeaderStyle style;

  const SectionHeader({
    super.key,
    required this.title,
    this.icon,
    required this.colors,
    this.style = SectionHeaderStyle.iconUppercase,
  });

  @override
  Widget build(BuildContext context) {
    if (style == SectionHeaderStyle.compact) {
      return Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
        child: Text(
          title,
          style: AppTextStyles.caption.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: colors.primary),
            const SizedBox(width: 8),
          ],
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: AppTextStyles.sizeSmall,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: colors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Divider(
              color: colors.primary.withValues(alpha: 0.2),
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }
}

