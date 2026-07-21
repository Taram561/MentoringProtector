import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_state_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/spacing.dart';
import '../../../widgets/app_card.dart';

class ScanTargetSelector extends StatelessWidget {
  final void Function(String path) onFileSelected;
  final void Function(String path) onDirectorySelected;
  final bool enabled;

  const ScanTargetSelector({
    super.key,
    required this.onFileSelected,
    required this.onDirectorySelected,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final state  = context.watch<AppStateProvider>();
    final l10n   = state.strings;
    final colors = state.colors;

    return AppCard(
      margin: EdgeInsets.zero,
      padding: Spacing.cardPadding,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.scanSelectTarget,
                style: TextStyle(
                    fontSize: AppTextStyles.sizeSubtitle,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _TargetButton(
                    icon: Icons.insert_drive_file_outlined,
                    label: l10n.scanFile,
                    enabled: enabled,
                    colors: colors,
                    onTap: _pickFile,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TargetButton(
                    icon: Icons.folder_outlined,
                    label: l10n.scanFolder,
                    enabled: enabled,
                    colors: colors,
                    onTap: _pickDirectory,
                  ),
                ),
              ],
            ),
          ],
        ),
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles();
    final path   = result?.files.single.path;
    if (path != null) onFileSelected(path);
  }

  Future<void> _pickDirectory() async {
    final path = await FilePicker.getDirectoryPath();
    if (path != null) onDirectorySelected(path);
  }
}

class _TargetButton extends StatelessWidget {
  final IconData       icon;
  final String         label;
  final bool           enabled;
  final VoidCallback   onTap;
  final AdaptiveColors colors;

  const _TargetButton({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: Spacing.l),
        decoration: BoxDecoration(
          color: enabled
              ? colors.primary.withValues(alpha: 0.08)
              : colors.divider.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: enabled
                ? colors.primary.withValues(alpha: 0.4)
                : colors.divider,
          ),
        ),
        child: Column(
          children: [
            Icon(icon,
                size: 28,
                color: enabled ? colors.primary : colors.textHint),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    fontSize: AppTextStyles.sizeBody,
                    color: enabled ? colors.primary : colors.textHint,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

