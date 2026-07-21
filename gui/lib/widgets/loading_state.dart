import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LoadingState extends StatelessWidget {
  final String? message;
  final AdaptiveColors colors;

  const LoadingState({super.key, this.message, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: colors.primary),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(fontSize: AppTextStyles.sizeBody, color: colors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

