import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/app_state_provider.dart';
import '../../services/exclusion_service.dart';
import '../../l10n/app_localizations.g.dart';
import '../../theme/app_theme.dart';
import '../../theme/spacing.dart';
import '../../widgets/app_title_bar.dart';
import '../../widgets/bottom_sheet_shell.dart';
import '../../widgets/icon_tile.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/confirm_dialog.dart';

class ExclusionListScreen extends StatefulWidget {
  const ExclusionListScreen({super.key});

  @override
  State<ExclusionListScreen> createState() => _ExclusionListScreenState();
}

class _ExclusionListScreenState extends State<ExclusionListScreen> {
  List<String> _exclusions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadExclusions();
    });
  }

  Future<void> _loadExclusions() async {
    final svc = context.read<ExclusionService>();
    final list = await svc.getExclusions();
    if (!mounted) return;
    setState(() {
      _exclusions = list;
      _loading = false;
    });
  }

  Future<void> _addExclusion(String path) async {
    if (path.trim().isEmpty) return;
    final svc = context.read<ExclusionService>();
    final ok = await svc.addExclusion(path.trim());
    if (!mounted) return;
    if (ok) await _loadExclusions();
  }

  Future<void> _removeExclusion(String path) async {
    final svc = context.read<ExclusionService>();
    final ok = await svc.removeExclusion(path);
    if (!mounted) return;
    if (ok) await _loadExclusions();
  }

  void _showAddDialog(AppLocalizations l10n, AdaptiveColors colors) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BottomSheetShell(
        colors: colors,
        title: l10n.exclusionListAdd,
        child: _AddExclusionSheetContent(
          l10n: l10n,
          colors: colors,
          onAddPath: _addExclusion,
        ),
      ),
    );
  }

  Future<void> _confirmRemove(
      String path, AppLocalizations l10n, AdaptiveColors colors) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: l10n.exclusionListRemoveConfirm,
      message: path,
      confirmLabel: l10n.quarantineDelete,
      cancelLabel: l10n.btnCancel,
      colors: colors,
      isDestructive: true,
    );
    if (!mounted) return;
    if (!confirmed) return;
    await _removeExclusion(path);
  }

  @override
  Widget build(BuildContext context) {
    final state  = context.watch<AppStateProvider>();
    final l10n   = state.strings;
    final colors = state.colors;

    return AppTitleBarScaffold(
      title: l10n.exclusionListTitle,
      colors: colors,
      body: Stack(
        children: [
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _exclusions.isEmpty
                  ? EmptyState(
                      icon: Icons.playlist_add_check,
                      title: l10n.exclusionListEmpty,
                      description: l10n.exclusionListDesc,
                      colors: colors,
                    )
                  : ListView.builder(
                      padding: Spacing.screenPadding,
                      itemCount: _exclusions.length,
                      itemBuilder: (context, index) {
                        final path = _exclusions[index];
                        final isMask = path.startsWith('*.');
                        final isFolder =
                            path.endsWith('\\') || path.endsWith('/');
                        final icon = isMask
                            ? Icons.filter_alt_outlined
                            : isFolder
                                ? Icons.folder_outlined
                                : Icons.insert_drive_file_outlined;
                        final typeLabel = isMask
                            ? l10n.exclusionMaskType
                            : isFolder
                                ? l10n.exclusionFolderType
                                : l10n.exclusionPathType;
                        return IconTile(
                          icon: icon,
                          title: path,
                          subtitle: typeLabel,
                          colors: colors,
                          trailing: IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: colors.danger,
                              size: 20,
                            ),
                            onPressed: () =>
                                _confirmRemove(path, l10n, colors),
                          ),
                          onTap: null,
                        );
                      },
                    ),
          Positioned(
            right: Spacing.l,
            bottom: Spacing.l,
            child: FloatingActionButton(
              onPressed: () => _showAddDialog(l10n, colors),
              backgroundColor: colors.primary,
              child: Icon(Icons.add, color: colors.onPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddExclusionSheetContent extends StatefulWidget {
  final AppLocalizations l10n;
  final AdaptiveColors colors;
  final Future<void> Function(String) onAddPath;

  const _AddExclusionSheetContent({
    required this.l10n,
    required this.colors,
    required this.onAddPath,
  });

  @override
  State<_AddExclusionSheetContent> createState() =>
      _AddExclusionSheetContentState();
}

class _AddExclusionSheetContentState
    extends State<_AddExclusionSheetContent> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        Spacing.xl,
        Spacing.s,
        Spacing.xl,
        MediaQuery.of(context).viewInsets.bottom + Spacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.folder_open, size: 18),
                  label: Text(l10n.exclusionListFolder),
                  onPressed: () async {
                    final nav = Navigator.of(context);
                    final result = await FilePicker.getDirectoryPath();
                    if (!mounted) return;
                    if (result != null) {
                      nav.pop();
                      await widget.onAddPath(result);
                    }
                  },
                ),
              ),
              const SizedBox(width: Spacing.s),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.insert_drive_file_outlined,
                      size: 18),
                  label: Text(l10n.exclusionListFile),
                  onPressed: () async {
                    final nav = Navigator.of(context);
                    final result = await FilePicker.pickFiles();
                    if (!mounted) return;
                    if (result != null && result.files.single.path != null) {
                      nav.pop();
                      await widget.onAddPath(result.files.single.path!);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.m),

          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: l10n.exclusionListMask,
              hintText: l10n.exclusionListAddHint,
              prefixIcon: const Icon(Icons.filter_alt_outlined),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () async {
                  if (_controller.text.trim().isNotEmpty) {
                    Navigator.pop(context);
                    await widget.onAddPath(_controller.text);
                  }
                },
              ),
            ),
            onSubmitted: (val) async {
              if (val.trim().isNotEmpty) {
                Navigator.pop(context);
                await widget.onAddPath(val);
              }
            },
          ),
          const SizedBox(height: Spacing.s),
        ],
      ),
    );
  }
}

