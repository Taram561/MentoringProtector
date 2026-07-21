import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import '../../providers/app_state_provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/user_profile_provider.dart';
import '../../models/user_profile.dart';
import '../../l10n/app_localizations.g.dart';
import '../../models/scan_result.dart';
import '../../ffi/core_result.dart';
import '../../ffi/core_bindings.dart';
import '../../ffi/core_service.dart';
import '../../services/scan_action_service.dart';
import '../../theme/spacing.dart';
import '../../utils/snack.dart';
import '../../widgets/confirm_dialog.dart';
import 'scan_controller.dart';
import '../hygiene/quiz_suggestion.dart';
import 'widgets/scan_target_selector.dart';
import 'widgets/scan_progress_card.dart';
import 'widgets/scan_results_widget.dart';
import 'widgets/threat_detail_sheet.dart';
import 'widgets/sandbox_report_sheet.dart';
import '../../services/sandbox_service.dart';
import '../../services/exclusion_service.dart';
import '../threat_library/threat_library_screen.dart';


class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});
  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  late final ScanController _controller;
  final SandboxService _sandboxService = SandboxService();
  final _scrollController = ScrollController();

  int _activeEnginesCount = 3;

  @override
  void initState() {
    super.initState();
    _controller = ScanController();
    _controller.addListener(() {
      setState(() {});
      if (_controller.state is ScanFinished) {
        context.read<AppStateProvider>().saveLastScanDate();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _scrollController.hasClients && _scrollController.position.maxScrollExtent > 0) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });
    if (CoreBindings.isInitialized) {
      final engines = CoreService().getActiveEngines();
      if (engines.isNotEmpty) _activeEnginesCount = engines.length;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startComputerScan() {
    _controller.scanComputer();
  }

  @override
  Widget build(BuildContext context) {
    final state      = context.watch<AppStateProvider>();
    final l10n       = state.strings;
    final colors     = state.colors;
    final isScanning = _controller.state is ScanRunning;

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverPadding(
            padding: Spacing.screenPadding,
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                _ComputerScanButton(
                  onTap: isScanning ? null : _startComputerScan,
                ),
                const SizedBox(height: Spacing.l),

                Row(
                  children: [
                    Expanded(child: Divider(color: colors.divider)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Spacing.m),
                      child: Text(
                        l10n.scanSelectTarget,
                        style: TextStyle(
                          fontSize: AppTextStyles.sizeSmall,
                          color: colors.textPrimary.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: colors.divider)),
                  ],
                ),
                const SizedBox(height: Spacing.m),

                ScanTargetSelector(
                  enabled: !isScanning,
                  onFileSelected: (path) {
                    _controller.reset();
                    _controller.scanFile(path);
                  },
                  onDirectorySelected: (path) {
                    _controller.reset();
                    _controller.scanDirectory(path);
                  },
                ),
                const SizedBox(height: Spacing.m),

                ScanProgressCard(
                  state: _controller.state,
                  onCancel: isScanning ? _controller.cancel : null,
                  onPause: isScanning && !_controller.isPaused ? _controller.pause : null,
                  onResume: isScanning && _controller.isPaused ? _controller.resume : null,
                  isPaused: _controller.isPaused,
                  onReset: _controller.state is ScanFinished ? _controller.reset : null,
                  driveLabel: _controller.isComputerScan ? _controller.computerScanDrive : null,
                ),
                const SizedBox(height: Spacing.m),

                if (_controller.results.isNotEmpty)
                  ScanResultsWidget(
                    allResults: _controller.results,
                    threats: _controller.threats,
                    filesScanned: _controller.results.length,
                    elapsed: _controller.state is ScanFinished
                        ? (_controller.state as ScanFinished).elapsed
                        : null,
                    activeEngines: _activeEnginesCount,
                    onThreatTap: (r) => _showThreatDetails(r, l10n),
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showThreatDetails(ScanResult result, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: Spacing.xl, vertical: Spacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540, maxHeight: 700),
          child: ThreatDetailSheet(
            result: result,
            l10n: l10n,
            onQuarantine: () {
              Navigator.pop(ctx);
              _quarantineFile(result, l10n);
            },
            onDelete: () {
              Navigator.pop(ctx);
              _deleteFile(result, l10n);
            },
            onIgnore: () {
              Navigator.pop(ctx);
              _ignoreResult(result);
            },
            onSandbox: result.dangerLevel >= 3 || (result.detectionMethod == DetectionMethod.archiveScan && result.isInfected)
                ? () {
                    Navigator.pop(ctx);
                    _runSandbox(result, l10n);
                  }
                : null,
            onWhitelist: () {
              Navigator.pop(ctx);
              _whitelistFile(result, l10n);
            },
            onLearn: () {
              Navigator.pop(ctx);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const ThreatLibraryScreen()));
            },
          ),
        ),
      ),
    );
  }

  Future<void> _quarantineFile(
      ScanResult result, AppLocalizations l10n) async {
    final service = context.read<ScanActionService>();
    final outcome = await service.quarantineFile(scanResult: result);
    if (!mounted) return;

    switch (outcome) {
      case QuarantineSuccess():
        context.read<UserProfileProvider>().recordEvent(
              RiskEventType.threatQuarantined,
              detail: result.filePath,
            );
        _controller.results
            .removeWhere((r) => r.filePath == result.filePath);
        setState(() {});
        Snack.success(context, l10n.scanQuarantineSuccess);
      case QuarantineFailure(:final message):
        Snack.error(context, l10n.processErrorPrefix(message));
    }
  }

  Future<void> _deleteFile(ScanResult result, AppLocalizations l10n) async {
    final colors = context.read<AppStateProvider>().colors;
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: l10n.scanDeleteFile,
      message: l10n.scanDeleteConfirm,
      confirmLabel: l10n.scanDeleteFile,
      cancelLabel: l10n.btnCancel,
      colors: colors,
      isDestructive: true,
    );
    if (!mounted || !confirmed) return;

    final service = context.read<ScanActionService>();
    try {
      await service.deletePhysicalFile(result.filePath);
      if (!mounted) return;
      _controller.results.removeWhere((r) => r.filePath == result.filePath);
      setState(() {});
      Snack.success(context, l10n.scanDeleteSuccess);
    } catch (e) {
      if (!mounted) return;
      Snack.error(context, l10n.processErrorPrefix(e.toString()));
    }
  }

  void _ignoreResult(ScanResult result) {
    context.read<UserProfileProvider>().recordEvent(
      RiskEventType.scanThreatIgnored,
      detail: result.filePath,
    );
    _controller.results.removeWhere(
        (r) => r.filePath == result.filePath);
    setState(() {});
    suggestQuizForEvent(context, RiskEventType.scanThreatIgnored);
  }

  Future<void> _whitelistFile(ScanResult result, AppLocalizations l10n) async {
    final ok = await ExclusionService().addExclusion(result.filePath);
    if (!mounted) return;
    if (ok) {
      context.read<UserProfileProvider>().recordEvent(
            RiskEventType.threatWhitelisted,
            detail: result.filePath,
          );
      _controller.results.removeWhere((r) => r.filePath == result.filePath);
      setState(() {});
      Snack.success(context, l10n.incidentWhitelistSuccess);
    } else {
      Snack.error(context, l10n.incidentWhitelistFailed);
    }
  }

  Future<String?> _extractForSandbox(ScanResult result) async {
    final innerPath = result.archiveInnerPath;
    if (innerPath == null || innerPath.isEmpty) return null;
    try {
      final bytes = await File(result.filePath).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      final normalized = innerPath.replaceAll('\\', '/');
      ArchiveFile? entry;
      for (final f in archive) {
        final name = f.name.replaceAll('\\', '/');
        if (name == normalized || name.endsWith('/$normalized')) {
          entry = f;
          break;
        }
      }
      if (entry == null || !entry.isFile) return null;
      final basename = normalized.split('/').last;
      final destPath = p.join(p.dirname(result.filePath), '_mp_sandbox_$basename');
      await File(destPath).writeAsBytes(entry.content as List<int>);
      return destPath;
    } catch (_) {
      return null;
    }
  }

  Future<void> _runSandbox(ScanResult result, AppLocalizations l10n) async {
    String targetPath = result.filePath;
    String? stagingFile;

    if (result.detectionMethod == DetectionMethod.archiveScan) {
      stagingFile = await _extractForSandbox(result);
      if (!mounted) return;
      if (stagingFile == null) {
        Snack.error(context, l10n.sandboxArchiveExtractFirst);
        return;
      }
      const _execExts = {'.exe', '.ps1', '.bat', '.cmd', '.vbs', '.js'};
      if (!_execExts.contains(p.extension(stagingFile).toLowerCase())) {
        try { await File(stagingFile).delete(); } catch (_) {}
        Snack.info(context, l10n.sandboxArchiveNotExecutable);
        return;
      }
      targetPath = stagingFile;
    }

    try {
      final supported = await _sandboxService.isSupported();
      if (!mounted) return;
      if (!supported) {
        Snack.error(context, l10n.sandboxRequiresAdmin);
        return;
      }
      final res = await _sandboxService.run(targetPath);
      if (!mounted) return;
      if (!res.success) {
        Snack.error(context, _sandboxErrorText(res.errorCode, l10n));
        return;
      }
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => SandboxReportSheet(
          service: _sandboxService,
          l10n: l10n,
          scanResult: result,
        ),
      );
    } finally {
      if (stagingFile != null) {
        try { await File(stagingFile).delete(); } catch (_) {}
      }
    }
  }

  String _sandboxErrorText(String? code, AppLocalizations l10n) {
    if (code != null && code.startsWith('copy_failed:')) {
      return l10n.sandboxErrorCopyFailed;
    }
    switch (code) {
      case 'unsupported_file_type':
        return l10n.sandboxErrorUnsupported;
      case 'bad_exe_format':
        return l10n.sandboxErrorBadFormat;
      case 'file_not_found':
        return l10n.sandboxErrorFileNotFound;
      case 'access_denied':
        return l10n.sandboxErrorAccessDenied;
      case 'access_denied_initial':
      case 'access_denied_after_fallback':
        return l10n.sandboxErrorBlocked;
      case 'already_running':
        return l10n.sandboxErrorAlreadyRunning;
      case 'dll_entry_unknown':
        return l10n.sandboxErrorDllUnsupported;
      case 'nested_jobs_unsupported':
        return l10n.sandboxErrorNestedJobsUnsupported;
      case 'app_container_profile_failed':
        return l10n.sandboxErrorAppContainerProfile;
      case 'app_container_ace_failed':
        return l10n.sandboxErrorAppContainerAce;
      default:
        return l10n.sandboxErrorGeneric(code ?? 'unknown');
    }
  }
}

class _ComputerScanButton extends StatelessWidget {
  final VoidCallback? onTap;
  const _ComputerScanButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final state  = context.watch<AppStateProvider>();
    final l10n   = state.strings;
    final colors = state.colors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colors.gradientEnd,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.onPrimary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.computer_rounded,
                  color: AppColors.onPrimary, size: 28),
            ),
            const SizedBox(width: Spacing.l),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.computerScanTitle,
                    style: TextStyle(
                      color: AppColors.onPrimary,
                      fontSize: AppTextStyles.sizeSubtitle,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    l10n.computerScanDescription,
                    style: TextStyle(
                      color: AppColors.onPrimary.withValues(alpha: 0.8),
                      fontSize: AppTextStyles.sizeSmall,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: AppColors.onPrimary, size: 16),
          ],
        ),
      ),
    );
  }
}

