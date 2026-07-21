import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../ffi/core_bindings.dart';
import '../../services/helper_bridge.dart';
import '../../ffi/app_paths.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../models/user_profile.dart';
import '../../theme/app_theme.dart';
import '../../theme/spacing.dart';
import '../../l10n/app_localizations.g.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_title_bar.dart';
import '../../widgets/confirm_dialog.dart';
import '../../utils/snack.dart';
import '../hygiene/quiz_suggestion.dart';

class _UrlCheckEvent {
  final String url;
  final String domain;
  final bool safe;
  final int score;
  final String reason;
  final String detail;
  final bool isHomoglyph;
  final String impersonatedBrand;
  final List<String> reasons;
  final DateTime time;

  _UrlCheckEvent({
    required this.url,
    required this.domain,
    required this.safe,
    required this.score,
    required this.reason,
    this.detail = '',
    this.isHomoglyph = false,
    this.impersonatedBrand = '',
    this.reasons = const [],
    required this.time,
  });
}

class WebProtectionScreen extends StatefulWidget {
  const WebProtectionScreen({super.key});
  @override
  State<WebProtectionScreen> createState() => _WebProtectionScreenState();
}

class _WebProtectionScreenState extends State<WebProtectionScreen> {
  final CoreBindings _bindings = CoreBindings.instance;
  final TextEditingController _urlController = TextEditingController();

  bool _isRunning = false;
  int _threatsCount = 0;
  String _authToken = '';
  Timer? _statusTimer;
  final List<_UrlCheckEvent> _events = [];

  @override
  void initState() {
    super.initState();
    _refreshStatus();
    _statusTimer = Timer.periodic(
        const Duration(seconds: 3), (_) => _refreshStatus());
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _urlController.dispose();
    super.dispose();
  }

  void _refreshStatus() {
    if (!mounted) return;
    final wasRunning = _isRunning;
    bool running = false;
    int threats = 0;

    if (_bindings.webProtectionIsRunning != null) {
      running = _bindings.webProtectionIsRunning!() == 1;
    }
    if (_bindings.webProtectionThreatsCount != null) {
      threats = _bindings.webProtectionThreatsCount!();
    }

    if (running != wasRunning || threats != _threatsCount) {
      setState(() {
        _isRunning = running;
        _threatsCount = threats;
      });
    }

    if (running && _authToken.isEmpty) {
      _loadToken();
    }
  }

  void _loadToken() {
    if (_bindings.webProtectionGetAuthToken == null) return;
    try {
      final token = _bindings.callReturningString(
          _bindings.webProtectionGetAuthToken!);
      if (token.isNotEmpty && mounted) {
        setState(() => _authToken = token);
      }
    } catch (e) {
      debugPrint('[MP] web_protection error: $e');
    }
  }

  Future<void> _startServer() async {
    if (CoreBindings.isInitialized && CoreBindings.instance.serviceHosting) {
      final res = await HelperBridge.runServiceCmd('web_start');
      if (!mounted) return;
      if (res.userCancelled) return;
      if (!res.ok) {
        debugPrint('[MP] runServiceCmd failed: ok=${res.ok} message=${res.message}');
        Snack.error(context, context.read<AppStateProvider>().strings.serviceCmdFailed);
        return;
      }
      _refreshStatus();
      _loadToken();
      context.read<UserProfileProvider>().recordEvent(
        RiskEventType.protectionEnabled, detail: 'web_protection');
      return;
    }
    if (_bindings.webProtectionStart == null) {
      Snack.error(context, 'Web protection unavailable in current DLL');
      return;
    }
    try {
      final result = await Future.microtask(() =>
          _bindings.callStartWeb(
            _bindings.webProtectionStart!,
            AppPaths.phishingDomainsPath,
            AppPaths.safeDomainsPath,
          ));
      if (!mounted) return;
      if (result == 1) {
        _refreshStatus();
        _loadToken();
        context.read<UserProfileProvider>().recordEvent(
          RiskEventType.protectionEnabled,
          detail: 'web_protection',
        );
      } else {
        Snack.error(context, 'Failed to start web protection server');
      }
    } catch (e) {
      if (!mounted) return;
      Snack.error(context, e.toString());
    }
  }

  Future<void> _stopServer() async {
    if (CoreBindings.isInitialized && CoreBindings.instance.serviceHosting) {
      final res = await HelperBridge.runServiceCmd('web_stop');
      if (!mounted) return;
      if (res.userCancelled) return;
      if (!res.ok) {
        debugPrint('[MP] runServiceCmd failed: ok=${res.ok} message=${res.message}');
        Snack.error(context, context.read<AppStateProvider>().strings.serviceCmdFailed);
        return;
      }
      context.read<UserProfileProvider>().recordEvent(
        RiskEventType.protectionDisabled, detail: 'web_protection');
      suggestQuizForEvent(context, RiskEventType.protectionDisabled);
      setState(() {
        _isRunning = false;
        _authToken = '';
      });
      return;
    }
    if (_bindings.webProtectionStop == null) return;
    try {
      await Future.microtask(() => _bindings.webProtectionStop!());
      if (!mounted) return;
      context.read<UserProfileProvider>().recordEvent(
        RiskEventType.protectionDisabled,
        detail: 'web_protection',
      );
      suggestQuizForEvent(context, RiskEventType.protectionDisabled);
      setState(() {
        _isRunning = false;
        _authToken = '';
      });
    } catch (e) {
      if (!mounted) return;
      Snack.error(context, e.toString());
    }
  }

  Future<void> _regenerateToken(AppLocalizations l10n, AdaptiveColors colors) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: l10n.webRegenerateToken,
      message: l10n.webRegenerateConfirm,
      confirmLabel: l10n.btnOk,
      cancelLabel: l10n.btnCancel,
      colors: colors,
      isDestructive: false,
    );
    if (!mounted) return;
    if (!confirmed) return;
    if (_bindings.webProtectionRegenerateToken != null) {
      final ok = _bindings.webProtectionRegenerateToken!();
      if (ok == 1) _loadToken();
    }
  }

  void _checkUrl() {
    final url = _urlController.text.trim();
    if (url.isEmpty || _bindings.webProtectionCheckUrl == null) return;

    try {
      final json = _bindings.callWithOneStringArg(
          _bindings.webProtectionCheckUrl!, url);
      if (json.isEmpty) return;

      final map = jsonDecode(json) as Map<String, dynamic>;
      final rawReasons = map['reasons'];
      final reasonsList = rawReasons is List
          ? rawReasons.map((e) => e.toString()).toList()
          : <String>[];
      final event = _UrlCheckEvent(
        url: url,
        domain: map['domain'] as String? ?? '',
        safe: map['safe'] as bool? ?? true,
        score: map['score'] as int? ?? 0,
        reason: map['reason'] as String? ?? '',
        detail: map['detail'] as String? ?? '',
        isHomoglyph: map['is_homoglyph'] as bool? ?? false,
        impersonatedBrand: map['impersonated_brand'] as String? ?? '',
        reasons: reasonsList,
        time: DateTime.now(),
      );

      setState(() {
        _events.insert(0, event);
        if (_events.length > 50) _events.removeLast();
      });

      _urlController.clear();
    } catch (e) {
      Snack.error(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final l10n = state.strings;
    final colors = state.colors;

    return AppTitleBarScaffold(
      title: l10n.webTitle,
      colors: colors,
      body: ListView(
        padding: EdgeInsets.all(Spacing.l),
        children: [
          _buildStatusCard(l10n, colors),
          SizedBox(height: Spacing.m),
          if (_isRunning) ...[
            _buildTokenCard(l10n, colors),
            SizedBox(height: Spacing.m),
            _buildUrlChecker(l10n, colors),
            SizedBox(height: Spacing.m),
            _buildEventsList(l10n, colors),
          ] else
            _buildHintCard(l10n, colors),
        ],
      ),
    );
  }

  Widget _buildStatusCard(AppLocalizations l10n, AdaptiveColors colors) {
    return AppCard(
      padding: EdgeInsets.all(Spacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.language,
                color: _isRunning ? colors.success : colors.textHint,
                size: 28,
              ),
              SizedBox(width: Spacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isRunning
                          ? l10n.webServerRunning
                          : l10n.webServerStopped,
                      style: TextStyle(
                        fontSize: AppTextStyles.sizeSubtitle,
                        fontWeight: FontWeight.w600,
                        color: _isRunning ? colors.success : colors.textPrimary,
                      ),
                    ),
                    if (_isRunning)
                      Text(
                        '${l10n.webThreatsLoaded}: $_threatsCount',
                        style: TextStyle(
                            fontSize: AppTextStyles.sizeDefault, color: colors.textSecondary),
                      ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: Spacing.xs),
          Text(
            l10n.webDescription,
            style: TextStyle(fontSize: AppTextStyles.sizeDefault, color: colors.textSecondary),
          ),
          SizedBox(height: Spacing.l),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isRunning ? _stopServer : _startServer,
              icon: Icon(_isRunning ? Icons.stop : Icons.play_arrow),
              label: Text(_isRunning ? l10n.webStop : l10n.webStart),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isRunning ? colors.danger : colors.primary,
                foregroundColor: colors.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTokenCard(AppLocalizations l10n, AdaptiveColors colors) {
    return AppCard(
      padding: EdgeInsets.all(Spacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.webAuthToken,
            style: TextStyle(
                fontSize: AppTextStyles.sizeLabel,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary),
          ),
          SizedBox(height: Spacing.s),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colors.surfaceVariant.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _authToken.isEmpty ? '...' : _authToken,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: AppTextStyles.sizeXSmall,
                color: colors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: Spacing.s),
          Text(
            l10n.webExtensionHint,
            style: TextStyle(fontSize: AppTextStyles.sizeSmall, color: colors.textSecondary),
          ),
          SizedBox(height: Spacing.m),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _authToken.isEmpty
                      ? null
                      : () {
                          Clipboard.setData(
                              ClipboardData(text: _authToken));
                          Snack.info(context, l10n.webTokenCopied);
                        },
                  icon: const Icon(Icons.copy, size: 18),
                  label: Text(l10n.webCopyToken),
                ),
              ),
              SizedBox(width: Spacing.s),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _regenerateToken(l10n, colors),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(l10n.webRegenerateToken,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUrlChecker(AppLocalizations l10n, AdaptiveColors colors) {
    return AppCard(
      padding: EdgeInsets.all(Spacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.webCheckUrl,
            style: TextStyle(
                fontSize: AppTextStyles.sizeLabel,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary),
          ),
          SizedBox(height: Spacing.s),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _urlController,
                  decoration: InputDecoration(
                    hintText: l10n.webCheckUrlHint,
                    isDense: true,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                  ),
                  onSubmitted: (_) => _checkUrl(),
                ),
              ),
              SizedBox(width: Spacing.s),
              IconButton.filled(
                onPressed: _checkUrl,
                icon: const Icon(Icons.search),
                style: IconButton.styleFrom(
                  backgroundColor: colors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList(AppLocalizations l10n, AdaptiveColors colors) {
    return AppCard(
      padding: EdgeInsets.all(Spacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.webEventsTitle,
            style: TextStyle(
                fontSize: AppTextStyles.sizeLabel,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary),
          ),
          SizedBox(height: Spacing.s),
          if (_events.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(Spacing.xl),
                child: Column(
                  children: [
                    Icon(Icons.checklist,
                        size: 40, color: colors.textHint),
                    SizedBox(height: Spacing.s),
                    Text(l10n.webNoEvents,
                        style: TextStyle(
                            color: colors.textSecondary, fontSize: AppTextStyles.sizeDefault)),
                  ],
                ),
              ),
            )
          else
            ...(_events.take(20).map((e) => _buildEventTile(e, l10n, colors))),
        ],
      ),
    );
  }

  Widget _buildEventTile(_UrlCheckEvent event, AppLocalizations l10n,
      AdaptiveColors colors) {
    final color = event.safe ? colors.success : colors.danger;
    final icon = event.safe
        ? Icons.check_circle_outline
        : Icons.warning_amber_rounded;

    final timeStr =
        '${event.time.hour.toString().padLeft(2, '0')}:'
        '${event.time.minute.toString().padLeft(2, '0')}:'
        '${event.time.second.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: () => _showEventDetail(event, l10n, colors),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.domain.isNotEmpty ? event.domain : event.url,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: AppTextStyles.sizeDefault,
                        color: colors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${l10n.webScore}: ${event.score} | '
                    '${l10n.webReason}: ${event.reason}',
                    style: TextStyle(fontSize: AppTextStyles.sizeXSmall, color: color),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    event.safe ? l10n.webResultSafe : l10n.webResultDanger,
                    style: TextStyle(
                        fontSize: AppTextStyles.sizeTiny,
                        fontWeight: FontWeight.w700,
                        color: color),
                  ),
                ),
                const SizedBox(height: 2),
                Text(timeStr,
                    style: TextStyle(
                        fontSize: AppTextStyles.sizeTiny, color: colors.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEventDetail(_UrlCheckEvent event, AppLocalizations l10n,
      AdaptiveColors colors) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: Spacing.xl, vertical: Spacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540, maxHeight: 700),
          child: _WebThreatDetailSheet(
            event: event,
            l10n: l10n,
            colors: colors,
          ),
        ),
      ),
    );
  }

  Widget _buildHintCard(AppLocalizations l10n, AdaptiveColors colors) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.language,
                size: 64, color: colors.textHint),
            SizedBox(height: Spacing.l),
            Text(
              l10n.webDescription,
              style: TextStyle(
                  fontSize: AppTextStyles.sizeBody, color: colors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _WebThreatDetailSheet extends StatelessWidget {
  final _UrlCheckEvent event;
  final AppLocalizations l10n;
  final AdaptiveColors colors;

  const _WebThreatDetailSheet({
    required this.event,
    required this.l10n,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  event.safe ? Icons.verified_user : Icons.gpp_bad,
                  color: event.safe ? colors.success : colors.danger,
                  size: 28,
                ),
                SizedBox(width: Spacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.webDetailTitle,
                        style: TextStyle(
                          fontSize: AppTextStyles.sizeSubheader,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      Text(
                        event.domain.isNotEmpty ? event.domain : event.url,
                        style: TextStyle(
                          fontSize: AppTextStyles.sizeDefault,
                          color: colors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: Spacing.l),
            _buildScoreBar(),
            SizedBox(height: Spacing.l),
            Wrap(
              spacing: Spacing.s,
              runSpacing: Spacing.s,
              children: [
                _buildChip(
                  l10n.webDetailThreatType,
                  _localizedReason(),
                  _reasonColor(),
                ),
                _buildChip(
                  l10n.webDetailDomain,
                  event.domain,
                  colors.primary,
                ),
              ],
            ),
            SizedBox(height: Spacing.l),

            if (event.detail.isNotEmpty) ...[
              Text(
                event.detail,
                style: TextStyle(
                  fontSize: AppTextStyles.sizeDefault,
                  color: colors.textSecondary,
                ),
              ),
              SizedBox(height: Spacing.l),
            ],

            if (event.isHomoglyph) ...[
              _buildHomoglyphCard(),
              SizedBox(height: Spacing.l),
            ],

            if (event.reasons.isNotEmpty) ...[
              _buildSectionHeader(
                l10n.webDetailAnalysis,
                Icons.analytics_outlined,
              ),
              SizedBox(height: Spacing.s),
              ...event.reasons.map((r) => _buildReasonTile(r)),
              SizedBox(height: Spacing.l),
            ],

            _buildTeachableMoment(),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBar() {
    final label = _scoreLabel();
    final scoreColor = _scoreColor();
    final fraction = (event.score / 100).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.webDetailRiskScore,
              style: TextStyle(
                fontSize: AppTextStyles.sizeDefault,
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: scoreColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${event.score}/100 - $label',
                style: TextStyle(
                  fontSize: AppTextStyles.sizeSmall,
                  fontWeight: FontWeight.w700,
                  color: scoreColor,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: Spacing.xs + 2),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 8,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: colors.divider.withValues(alpha: 0.3),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: fraction,
                  child: Container(
                    decoration: BoxDecoration(
                      color: scoreColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: AppTextStyles.sizeSmall,
              color: colors.textSecondary.withValues(alpha: 0.6),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: AppTextStyles.sizeSmall,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomoglyphCard() {
    return Container(
      padding: const EdgeInsets.all(Spacing.m),
      decoration: BoxDecoration(
        color: colors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.warning.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded,
              color: colors.warning, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.webDetailHomoglyphTitle,
                  style: TextStyle(
                    fontSize: AppTextStyles.sizeBody,
                    fontWeight: FontWeight.w700,
                    color: colors.warning,
                  ),
                ),
                SizedBox(height: Spacing.xs),
                Text(
                  l10n.webDetailHomoglyphDesc(
                    event.impersonatedBrand.isNotEmpty
                        ? event.impersonatedBrand
                        : event.domain,
                  ),
                  style: TextStyle(
                    fontSize: AppTextStyles.sizeSmall,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: colors.primary),
        SizedBox(width: Spacing.s),
        Text(
          title,
          style: TextStyle(
            fontSize: AppTextStyles.sizeBody,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
        SizedBox(width: Spacing.s),
        Expanded(
          child: Divider(color: colors.divider),
        ),
      ],
    );
  }

  Widget _buildReasonTile(String reason) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: Spacing.xs / 2),
            child: Icon(Icons.arrow_right_rounded,
                size: 18, color: colors.danger.withValues(alpha: 0.7)),
          ),
          SizedBox(width: Spacing.xs),
          Expanded(
            child: Text(
              reason,
              style: TextStyle(
                fontSize: AppTextStyles.sizeSmall,
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeachableMoment() {
    final tip = _teachableTip();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.school_outlined,
                  size: 20, color: colors.primary),
              SizedBox(width: Spacing.s),
              Text(
                l10n.webDetailTeachableTitle,
                style: TextStyle(
                  fontSize: AppTextStyles.sizeBody,
                  fontWeight: FontWeight.w700,
                  color: colors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: Spacing.s),
          Text(
            tip,
            style: TextStyle(
              fontSize: AppTextStyles.sizeDefault,
              height: 1.5,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _localizedReason() {
    switch (event.reason) {
      case 'phishing': return l10n.webReasonPhishing;
      case 'malware': return l10n.webReasonMalware;
      case 'scam': return l10n.webReasonScam;
      case 'cryptominer': return l10n.webReasonCryptominer;
      case 'tracking': return l10n.webReasonTracking;
      case 'suspicious': return l10n.webReasonSuspicious;
      case 'clean': return l10n.webReasonClean;
      default: return event.reason;
    }
  }

  Color _reasonColor() {
    return switch (event.reason) { 'phishing' => colors.danger, 'malware' => colors.danger, 'scam' => colors.warning, 'cryptominer' => colors.accentPurple, 'tracking' => colors.textSecondary, 'suspicious' => colors.warning, _ => colors.success };
  }

  String _scoreLabel() {
    if (event.score >= 70) return l10n.webDetailCritical;
    if (event.score >= 50) return l10n.webDetailHigh;
    if (event.score >= 30) return l10n.webDetailMedium;
    if (event.score > 0)   return l10n.webDetailLow;
    return l10n.webDetailSafe;
  }

  Color _scoreColor() {
    if (event.score >= 70) return colors.severityCritical;
    if (event.score >= 50) return colors.severityHigh;
    if (event.score >= 30) return colors.warning;
    return colors.success;
  }

  String _teachableTip() {
    if (event.isHomoglyph) return l10n.webTipHomoglyph;
    switch (event.reason) {
      case 'phishing': return l10n.webTipPhishing;
      case 'malware': return l10n.webTipMalware;
      case 'scam': return l10n.webTipScam;
      case 'cryptominer': return l10n.webTipCryptominer;
      case 'tracking': return l10n.webTipTracking;
      case 'suspicious': return l10n.webTipSuspicious;
      default: return l10n.webTipGeneral;
    }
  }
}

