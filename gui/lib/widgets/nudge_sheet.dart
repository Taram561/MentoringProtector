
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/nudge.dart';
import '../models/nudge_education.dart';
import '../providers/app_state_provider.dart';
import '../providers/nudge_provider.dart';
import '../l10n/app_localizations.g.dart';
import '../theme/app_theme.dart';
import 'bottom_sheet_shell.dart';

class NudgeSheet extends StatelessWidget {
  final Nudge          nudge;
  final VoidCallback?  onScanFile;
  final VoidCallback?  onQuarantine;

  const NudgeSheet({
    super.key,
    required this.nudge,
    this.onScanFile,
    this.onQuarantine,
  });

  static void show({
    required BuildContext context,
    required Nudge nudge,
    VoidCallback? onScanFile,
    VoidCallback? onQuarantine,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NudgeSheet(
        nudge: nudge,
        onScanFile: onScanFile,
        onQuarantine: onQuarantine,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state    = context.read<AppStateProvider>();
    final l10n     = state.strings;
    final colors   = state.colors;
    final edu      = NudgeEducation.of(nudge.category);
    final isUsb    = nudge.category == NudgeCategory.usbDevice;
    final usbState = isUsb
        ? context.watch<NudgeProvider>().usbScans[nudge.detail]
        : null;

    return BottomSheetShell(
      colors: colors,
      title: _resolveKey(l10n, edu.titleKey),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (nudge.detail.isNotEmpty) ...[
              _FileBadge(detail: nudge.detail, colors: colors),
              const SizedBox(height: 12),
            ],

            if (usbState != null) ...[
              _UsbScanStatus(state: usbState, colors: colors, l10n: l10n),
              const SizedBox(height: 12),
            ],

            if (nudge.context.isNotEmpty && nudge.category != NudgeCategory.suspiciousScript) ...[
              _ContextRow(label: l10n.nudgeSource, value: nudge.context, colors: colors),
              const SizedBox(height: 12),
            ],

            _TipCard(tip: _resolveKey(l10n, edu.tipKey), colors: colors),
            const SizedBox(height: 16),

            _SectionHeader(text: l10n.nudgeChecklist, colors: colors),
            ...edu.checklistKeys.map(
              (k) => _ChecklistItem(text: _resolveKey(l10n, k), colors: colors),
            ),
            const SizedBox(height: 16),

            _SectionHeader(text: l10n.nudgeWhatToDo, colors: colors),
            ...edu.actionKeys.map(
              (k) => _ActionItem(text: _resolveKey(l10n, k), colors: colors),
            ),
            const SizedBox(height: 20),

            _ActionButtons(
              nudge: nudge,
              l10n: l10n,
              colors: colors,
              onScanFile: onScanFile,
              onQuarantine: onQuarantine,
            ),
          ],
        ),
      ),
    );
  }

  static String _resolveKey(AppLocalizations l10n, String key) {
    switch (key) {
      case 'nudgeDownloadedExeTitle': return l10n.nudgeDownloadedExeTitle;
      case 'nudgeDownloadedExeTip': return l10n.nudgeDownloadedExeTip;
      case 'nudgeDownloadedExeCheck1': return l10n.nudgeDownloadedExeCheck1;
      case 'nudgeDownloadedExeCheck2': return l10n.nudgeDownloadedExeCheck2;
      case 'nudgeDownloadedExeCheck3': return l10n.nudgeDownloadedExeCheck3;
      case 'nudgeDownloadedExeAction1': return l10n.nudgeDownloadedExeAction1;
      case 'nudgeDownloadedExeAction2': return l10n.nudgeDownloadedExeAction2;

      case 'nudgeMacroDocumentTitle': return l10n.nudgeMacroDocumentTitle;
      case 'nudgeMacroDocumentTip': return l10n.nudgeMacroDocumentTip;
      case 'nudgeMacroDocumentCheck1': return l10n.nudgeMacroDocumentCheck1;
      case 'nudgeMacroDocumentCheck2': return l10n.nudgeMacroDocumentCheck2;
      case 'nudgeMacroDocumentCheck3': return l10n.nudgeMacroDocumentCheck3;
      case 'nudgeMacroDocumentAction1': return l10n.nudgeMacroDocumentAction1;
      case 'nudgeMacroDocumentAction2': return l10n.nudgeMacroDocumentAction2;

      case 'nudgeSuspiciousScriptTitle': return l10n.nudgeSuspiciousScriptTitle;
      case 'nudgeSuspiciousScriptTip': return l10n.nudgeSuspiciousScriptTip;
      case 'nudgeSuspiciousScriptCheck1': return l10n.nudgeSuspiciousScriptCheck1;
      case 'nudgeSuspiciousScriptCheck2': return l10n.nudgeSuspiciousScriptCheck2;
      case 'nudgeSuspiciousScriptCheck3': return l10n.nudgeSuspiciousScriptCheck3;
      case 'nudgeSuspiciousScriptAction1': return l10n.nudgeSuspiciousScriptAction1;
      case 'nudgeSuspiciousScriptAction2': return l10n.nudgeSuspiciousScriptAction2;

      case 'nudgeUsbDeviceTitle': return l10n.nudgeUsbDeviceTitle;
      case 'nudgeUsbDeviceTip': return l10n.nudgeUsbDeviceTip;
      case 'nudgeUsbDeviceCheck1': return l10n.nudgeUsbDeviceCheck1;
      case 'nudgeUsbDeviceCheck2': return l10n.nudgeUsbDeviceCheck2;
      case 'nudgeUsbDeviceCheck3': return l10n.nudgeUsbDeviceCheck3;
      case 'nudgeUsbDeviceAction1': return l10n.nudgeUsbDeviceAction1;
      case 'nudgeUsbDeviceAction2': return l10n.nudgeUsbDeviceAction2;

      case 'nudgeDownloadedContainerTitle': return l10n.nudgeDownloadedContainerTitle;
      case 'nudgeDownloadedContainerTip': return l10n.nudgeDownloadedContainerTip;
      case 'nudgeDownloadedContainerCheck1': return l10n.nudgeDownloadedContainerCheck1;
      case 'nudgeDownloadedContainerCheck2': return l10n.nudgeDownloadedContainerCheck2;
      case 'nudgeDownloadedContainerCheck3': return l10n.nudgeDownloadedContainerCheck3;
      case 'nudgeDownloadedContainerAction1': return l10n.nudgeDownloadedContainerAction1;
      case 'nudgeDownloadedContainerAction2': return l10n.nudgeDownloadedContainerAction2;

      default: return key;
    }
  }
}


class _FileBadge extends StatelessWidget {
  final String detail;
  final AdaptiveColors colors;
  const _FileBadge({required this.detail, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.insert_drive_file_outlined, size: 16, color: colors.textSecondary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(detail,
              style: TextStyle(fontSize: AppTextStyles.sizeSmall, color: colors.textSecondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContextRow extends StatelessWidget {
  final String label, value;
  final AdaptiveColors colors;
  const _ContextRow({required this.label, required this.value, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label ', style: TextStyle(fontSize: AppTextStyles.sizeSmall, color: colors.textHint)),
        Expanded(
          child: Text(value,
            style: TextStyle(fontSize: AppTextStyles.sizeSmall, color: colors.textSecondary),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _TipCard extends StatelessWidget {
  final String tip;
  final AdaptiveColors colors;
  const _TipCard({required this.tip, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, size: 18, color: colors.warning),
          const SizedBox(width: 10),
          Expanded(
            child: Text(tip,
              style: TextStyle(fontSize: AppTextStyles.sizeBody, color: colors.textPrimary, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  final AdaptiveColors colors;
  const _SectionHeader({required this.text, required this.colors});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text,
      style: TextStyle(
        fontSize: AppTextStyles.sizeSmall,
        fontWeight: FontWeight.w600,
        color: colors.textHint,
        letterSpacing: 0.5,
      ),
    ),
  );
}

class _ChecklistItem extends StatelessWidget {
  final String text;
  final AdaptiveColors colors;
  const _ChecklistItem({required this.text, required this.colors});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle_outline, size: 16, color: colors.success),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
            style: TextStyle(fontSize: AppTextStyles.sizeBody, color: colors.textPrimary, height: 1.4),
          ),
        ),
      ],
    ),
  );
}

class _ActionItem extends StatelessWidget {
  final String text;
  final AdaptiveColors colors;
  const _ActionItem({required this.text, required this.colors});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.arrow_right, size: 18, color: colors.primary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text,
            style: TextStyle(fontSize: AppTextStyles.sizeBody, color: colors.textPrimary, height: 1.4),
          ),
        ),
      ],
    ),
  );
}

class _ActionButtons extends StatelessWidget {
  final Nudge          nudge;
  final AppLocalizations l10n;
  final AdaptiveColors colors;
  final VoidCallback?  onScanFile;
  final VoidCallback?  onQuarantine;

  const _ActionButtons({
    required this.nudge,
    required this.l10n,
    required this.colors,
    this.onScanFile,
    this.onQuarantine,
  });

  @override
  Widget build(BuildContext context) {
    final nudgeProv = context.read<NudgeProvider>();
    final isSecurity = nudge.category.isSecurity;
    final isUsb = nudge.category == NudgeCategory.usbDevice;
    final usbState = isUsb
        ? nudgeProv.usbScans[nudge.detail]
        : null;
    final usbScanning = usbState?.status == UsbScanStatus.scanning;

    void close({bool engaged = false}) {
      Navigator.of(context).pop();
      if (engaged) {
        nudgeProv.onEngaged(nudge);
      } else {
        nudgeProv.onIgnored(nudge);
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isUsb)
          ElevatedButton.icon(
            onPressed: usbScanning ? null : () {
              close(engaged: true);
              onScanFile?.call();
            },
            icon: const Icon(Icons.search, size: 18),
            label: Text(usbScanning
                ? l10n.nudgeUsbScanning
                : (usbState?.isComplete == true
                    ? l10n.nudgeUsbRescan
                    : l10n.nudgeCheckDrive)),
            style: ElevatedButton.styleFrom(backgroundColor: colors.primary),
          )
        else ...[
          ElevatedButton.icon(
            onPressed: () {
              close(engaged: true);
              onScanFile?.call();
            },
            icon: const Icon(Icons.search, size: 18),
            label: Text(l10n.nudgeScanFile),
            style: ElevatedButton.styleFrom(backgroundColor: colors.primary),
          ),
          if (isSecurity) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                close(engaged: true);
                onQuarantine?.call();
              },
              icon: const Icon(Icons.lock_outline, size: 18),
              label: Text(l10n.nudgeQuarantine),
            ),
          ],
        ],
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => close(engaged: false),
          child: Text(l10n.nudgeDismiss,
              style: TextStyle(color: colors.textHint)),
        ),
      ],
    );
  }
}


class _UsbScanStatus extends StatelessWidget {
  final UsbScanState       state;
  final AdaptiveColors     colors;
  final AppLocalizations   l10n;
  const _UsbScanStatus({
    required this.state,
    required this.colors,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return switch (state.status) {
      UsbScanStatus.scanning => _buildScanning(),
      UsbScanStatus.complete when state.isClean => _buildClean(),
      UsbScanStatus.complete => _buildThreats(),
      UsbScanStatus.error    => _buildError(),
    };
  }

  Widget _buildScanning() {
    final label = state.total > 0
        ? '${l10n.nudgeUsbScanning} ${state.scanned}/${state.total}'
        : l10n.nudgeUsbScanning;
    return Row(
      children: [
        SizedBox(
          width: 16, height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2, color: colors.primary),
        ),
        const SizedBox(width: 10),
        Text(label,
          style: TextStyle(
              fontSize: AppTextStyles.sizeSmall, color: colors.textSecondary)),
      ],
    );
  }

  Widget _buildClean() => Row(
    children: [
      Icon(Icons.check_circle, size: 16, color: colors.success),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          '${l10n.nudgeUsbNoThreats} (${state.scanned} файлов)',
          style: TextStyle(
              fontSize: AppTextStyles.sizeSmall, color: colors.success),
        ),
      ),
    ],
  );

  Widget _buildThreats() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [
        Icon(Icons.warning_amber_rounded, size: 16, color: colors.warning),
        const SizedBox(width: 8),
        Text('${l10n.nudgeUsbThreats}: ${state.threats}',
          style: TextStyle(
              fontSize: AppTextStyles.sizeSmall,
              color: colors.warning,
              fontWeight: FontWeight.w600)),
      ]),
      ...state.threatNames.take(5).map((name) => Padding(
        padding: const EdgeInsets.only(left: 24, top: 3),
        child: Text(name,
          style: TextStyle(
              fontSize: AppTextStyles.sizeSmall, color: colors.textSecondary)),
      )),
    ],
  );

  Widget _buildError() => Text(
    'Не удалось проверить диск',
    style: TextStyle(fontSize: AppTextStyles.sizeSmall, color: colors.textHint),
  );
}

