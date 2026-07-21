import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum AppButtonType { primary, secondary, ghost }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonType type;
  final AdaptiveColors colors;

  const AppButton({
    super.key,
    required this.label,
    required this.colors,
    this.onPressed,
    this.icon,
    this.type = AppButtonType.primary,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case AppButtonType.primary:
        return icon != null
            ? ElevatedButton.icon(
                onPressed: onPressed,
                icon: Icon(icon, size: 18),
                label: Text(label),
              )
            : ElevatedButton(
                onPressed: onPressed,
                child: Text(label),
              );
      case AppButtonType.secondary:
        return icon != null
            ? ElevatedButton.icon(
                onPressed: onPressed,
                icon: Icon(icon, size: 18),
                label: Text(label),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      colors.primary.withValues(alpha: 0.12),
                  foregroundColor: colors.primary,
                  elevation: 0,
                ),
              )
            : ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      colors.primary.withValues(alpha: 0.12),
                  foregroundColor: colors.primary,
                  elevation: 0,
                ),
                child: Text(label),
              );
      case AppButtonType.ghost:
        return icon != null
            ? OutlinedButton.icon(
                onPressed: onPressed,
                icon: Icon(icon, size: 18),
                label: Text(label),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.primary,
                  side: BorderSide(color: colors.primary),
                ),
              )
            : OutlinedButton(
                onPressed: onPressed,
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.primary,
                  side: BorderSide(color: colors.primary),
                ),
                child: Text(label),
              );
    }
  }
}

