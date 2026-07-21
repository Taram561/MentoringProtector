import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../ffi/core_bindings.dart';
import '../../../models/process_analysis.dart';
import '../../../providers/app_state_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/spacing.dart';
import '../../../utils/snack.dart';

class ProcessInspectSheet extends StatefulWidget {
  final int pid;
  const ProcessInspectSheet({super.key, required this.pid});

  @override
  State<ProcessInspectSheet> createState() => _ProcessInspectSheetState();
}

class _ProcessInspectSheetState extends State<ProcessInspectSheet> {
  ProcessAnalysis? _analysis;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final bindings = CoreBindings.instance;
      if (bindings.analyzeProcessByPid == null) {
        setState(() { _error = 'FFI not available'; _loading = false; });
        return;
      }
      final json = bindings.callWithIntArg(
          bindings.analyzeProcessByPid!, widget.pid);
      final map = jsonDecode(json) as Map<String, dynamic>;
      setState(() {
        _analysis = ProcessAnalysis.fromJson(map);
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _copy(BuildContext ctx, String value) {
    Clipboard.setData(ClipboardData(text: value));
    final l10n = context.read<AppStateProvider>().strings;
    Snack.info(ctx, l10n.copiedToClipboard,
        duration: const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<AppStateProvider>().colors;
    final l10n   = context.watch<AppStateProvider>().strings;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.92,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: colors.textHint.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  Spacing.m, 0, Spacing.m, Spacing.s),
              child: Row(children: [
                Icon(Icons.manage_search_rounded,
                    color: colors.primary, size: 22),
                const SizedBox(width: 8),
                Text(l10n.inspectTitle,
                    style: AppTextStyles.title.copyWith(
                        color: colors.textPrimary)),
              ]),
            ),
            const Divider(height: 1),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text(_error!,
                          style: TextStyle(color: colors.danger)))
                      : _buildContent(controller, colors, l10n),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
      ScrollController controller, AdaptiveColors colors, dynamic l10n) {
    final a = _analysis!;
    return ListView(
      controller: controller,
      padding: const EdgeInsets.all(Spacing.m),
      children: [
        _Section(title: l10n.inspectBasicInfo, colors: colors, children: [
          _Row(label: 'PID',           value: '${a.pid}', colors: colors),
          _Row(label: l10n.inspectParentPid, value: '${a.parentPid}', colors: colors),
          _Row(label: l10n.inspectProcessName, value: a.processName, colors: colors),
          _Row(label: l10n.processVerdictLabel, value: a.verdict, colors: colors),
          _Row(label: l10n.processSuspicionScore, value: '${a.score}/100', colors: colors),
          _Row(label: l10n.inspectSignature,
               value: a.digitalSignature.isEmpty ? '-' : a.digitalSignature,
               colors: colors,
               valueColor: a.digitalSignature == 'signed'
                   ? colors.success : colors.warning),
        ]),
        const SizedBox(height: Spacing.m),
        _Section(title: l10n.inspectCmdline, colors: colors, children: [
          _CopyableRow(
            value: a.cmdline.isEmpty ? '-' : a.cmdline,
            colors: colors,
            onCopy: () => _copy(context, a.cmdline),
          ),
        ]),
        const SizedBox(height: Spacing.m),
        _Section(title: l10n.inspectFileHash, colors: colors, children: [
          _CopyableRow(
            value: a.fileHash.isEmpty ? '-' : a.fileHash,
            colors: colors,
            onCopy: () => _copy(context, a.fileHash),
          ),
        ]),
        if (a.modules.isNotEmpty) ...[
          const SizedBox(height: Spacing.m),
          _Section(
            title: l10n.inspectModules(a.modules.length),
            colors: colors,
            children: a.modules.take(20).map((m) => _ModuleRow(
              module: m,
              colors: colors,
              onCopy: () => _copy(context, m.name),
            )).toList(),
          ),
        ],
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final AdaptiveColors colors;
  final List<Widget> children;

  const _Section({
    required this.title,
    required this.colors,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: AppTextStyles.sizeSmall,
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
                letterSpacing: 0.5)),
        const SizedBox(height: Spacing.xs),
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.divider),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final AdaptiveColors colors;
  final Color? valueColor;

  const _Row({
    required this.label,
    required this.value,
    required this.colors,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: Spacing.m, vertical: Spacing.s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label,
                style: TextStyle(
                    fontSize: AppTextStyles.sizeSmall, color: colors.textSecondary)),
          ),
          Expanded(
            child: Text(value,
                style: TextStyle(
                    fontSize: AppTextStyles.sizeSmall,
                    fontFamily: 'monospace',
                    color: valueColor ?? colors.textPrimary)),
          ),
        ],
      ),
    );
  }
}

class _CopyableRow extends StatelessWidget {
  final String value;
  final AdaptiveColors colors;
  final VoidCallback onCopy;

  const _CopyableRow({
    required this.value,
    required this.colors,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: Spacing.m, vertical: Spacing.s),
      child: Row(children: [
        Expanded(
          child: SelectableText(value,
              style: TextStyle(
                  fontSize: AppTextStyles.sizeSmall,
                  fontFamily: 'monospace',
                  color: colors.textPrimary)),
        ),
        if (value != '-')
          IconButton(
            icon: const Icon(Icons.copy, size: 14),
            onPressed: onCopy,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            style: IconButton.styleFrom(foregroundColor: colors.primary),
          ),
      ]),
    );
  }
}

class _ModuleRow extends StatelessWidget {
  final ProcessModule module;
  final AdaptiveColors colors;
  final VoidCallback onCopy;

  const _ModuleRow({
    required this.module,
    required this.colors,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final size = '${(module.size / 1024).toStringAsFixed(1)} KB';
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: Spacing.m, vertical: Spacing.xs),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(module.name,
                  style: TextStyle(
                      fontSize: AppTextStyles.sizeSmall, color: colors.textPrimary,
                      fontWeight: FontWeight.w500)),
              Text(size,
                  style: TextStyle(
                      fontSize: AppTextStyles.sizeXSmall, color: colors.textSecondary,
                      fontFamily: 'monospace')),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy, size: 12),
          onPressed: onCopy,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          style: IconButton.styleFrom(foregroundColor: colors.textHint),
        ),
      ]),
    );
  }
}

