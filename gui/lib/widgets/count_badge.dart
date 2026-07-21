import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CountBadge extends StatelessWidget {
  final int count;
  final Color color;
  final bool showZero;

  const CountBadge({
    super.key,
    required this.count,
    required this.color,
    this.showZero = false,
  });

  @override
  Widget build(BuildContext context) {
    if (count == 0 && !showZero) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count.toString(),
        style: TextStyle(
          fontSize: AppTextStyles.sizeSmall,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

