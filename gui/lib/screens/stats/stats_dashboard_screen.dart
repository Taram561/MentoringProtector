
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.g.dart';
import '../../models/threat_stats.dart';
import '../../models/threat_sources_aggregate.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/module_status_provider.dart';
import '../../providers/stats_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/spacing.dart';
import '../../widgets/app_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_state.dart';
import '../../widgets/loading_state.dart';
import '../../widgets/section_header.dart';
import '../../widgets/sparkline_generic.dart';
import '../../widgets/stat_chip.dart';
import 'widgets/reports_history_view.dart';
import 'widgets/stats_period_selector.dart';
import 'widgets/threat_bar_chart.dart';
import 'widgets/threat_sources_donut.dart';

class StatsDashboardScreen extends StatefulWidget {
  const StatsDashboardScreen({super.key});

  @override
  State<StatsDashboardScreen> createState() => _StatsDashboardScreenState();
}

class _StatsDashboardScreenState extends State<StatsDashboardScreen> {
  int _periodDays = 30;
  bool _loading = false;
  bool _initialFetchDone = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_initialFetchDone) {
        _load(_periodDays);
      }
    });
  }

  Future<void> _load(int days) async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _periodDays = days;
    });
    try {
      await context.read<StatsProvider>().refreshStats(days);
    } catch (e) {
      debugPrint('[MP] Stats: dashboard load error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _initialFetchDone = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state      = context.watch<AppStateProvider>();
    final statsState = context.watch<StatsProvider>();
    final colors     = state.colors;
    final l10n       = state.strings;

    final dashboard = _buildBody(statsState, colors, l10n);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Material(
            color: colors.background,
            child: TabBar(
              labelColor: colors.primary,
              unselectedLabelColor: colors.textSecondary,
              indicatorColor: colors.primary,
              tabs: [
                Tab(text: l10n.statsTabDashboard),
                Tab(text: l10n.statsTabHistory),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            dashboard,
            const ReportsHistoryView(),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
      StatsProvider statsState, AdaptiveColors colors, AppLocalizations l10n) {
    if (_loading && !_initialFetchDone) {
      return LoadingState(colors: colors);
    }
    if (statsState.statsError != null) {
      return ErrorState(
        colors: colors,
        message: l10n.statsLoadingError,
        retryLabel: l10n.statsLoadingError,
        onRetry: () => _load(_periodDays),
      );
    }

    final stats = statsState.threatStats;
    final history = statsState.scanHistory;
    final isEmpty = (stats?.total ?? 0) == 0 && (history?.totalScans ?? 0) == 0;

    return ListView(
      padding: Spacing.screenPadding,
      children: [
        StatsPeriodSelector(
          selectedDays: _periodDays,
          onChanged: _load,
          colors: colors,
          l10n: l10n,
        ),
        const SizedBox(height: Spacing.l),
        if (isEmpty) ...[
          EmptyState(
            colors: colors,
            icon: Icons.insights_outlined,
            title: l10n.statsRunScanHint,
          ),
        ] else ...[
          _HygieneSection(colors: colors, l10n: l10n),
          const SizedBox(height: Spacing.xl),
          _ThreatsActivitySection(
            colors: colors,
            l10n: l10n,
            daily: stats?.daily ?? const [],
            total: stats?.total ?? 0,
          ),
          const SizedBox(height: Spacing.xl),
          const _EnginesSection(),
          const SizedBox(height: Spacing.xl),
          _ThreatSourcesSection(colors: colors, l10n: l10n, sources: statsState.threatSources),
        ],
      ],
    );
  }
}

class _HygieneSection extends StatelessWidget {
  final AdaptiveColors colors;
  final AppLocalizations l10n;

  const _HygieneSection({required this.colors, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProfileProvider>();
    final history = profile.hygieneHistory;
    final hasHistory = history.length >= 2;

    final points = history.map((s) => s.score.toDouble()).toList();
    final currentScore = history.isEmpty ? 0 : history.last.score;
    final delta = hasHistory ? history.last.score - history.first.score : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: l10n.statsHygieneTrendTitle,
          icon: Icons.health_and_safety_outlined,
          colors: colors,
        ),
        AppCard(
          padding: Spacing.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currentScore.toString(),
                    style: TextStyle(
                      fontSize: AppTextStyles.sizeHero,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: Spacing.xs),
                  Padding(
                    padding: const EdgeInsets.only(bottom: Spacing.s),
                    child: Text(
                      '/100',
                      style: TextStyle(
                        fontSize: AppTextStyles.sizeDefault,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (hasHistory)
                    _DeltaBadge(delta: delta, colors: colors),
                ],
              ),
              const SizedBox(height: Spacing.s),
              if (hasHistory)
                GenericSparkline(
                  points: points,
                  minValue: 0,
                  maxValue: 100,
                  lineColor: colors.primary,
                  fillColor: colors.primary.withValues(alpha: 0.12),
                  dotCenterColor: colors.surface,
                  height: 60,
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: Spacing.m),
                  child: Text(
                    l10n.statsHygieneTrendEmpty,
                    style: TextStyle(
                      fontSize: AppTextStyles.sizeSmall,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DeltaBadge extends StatelessWidget {
  final int delta;
  final AdaptiveColors colors;

  const _DeltaBadge({required this.delta, required this.colors});

  @override
  Widget build(BuildContext context) {
    final positive = delta >= 0;
    final color = positive ? colors.success : colors.danger;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: Spacing.s, vertical: Spacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            positive ? Icons.trending_up : Icons.trending_down,
            size: 14,
            color: color,
          ),
          const SizedBox(width: Spacing.xs),
          Text(
            '${positive ? '+' : ''}$delta',
            style: TextStyle(
              fontSize: AppTextStyles.sizeSmall,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThreatsActivitySection extends StatelessWidget {
  final AdaptiveColors colors;
  final AppLocalizations l10n;
  final List<DailyStats> daily;
  final int total;

  const _ThreatsActivitySection({
    required this.colors,
    required this.l10n,
    required this.daily,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: l10n.statsThreatsActivityTitle,
          icon: Icons.bar_chart_outlined,
          colors: colors,
        ),
        AppCard(
          padding: Spacing.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      total == 0
                          ? l10n.statsThreatsActivityEmpty
                          : '${l10n.statsThreatsTotal}: $total',
                      style: TextStyle(
                        fontSize: AppTextStyles.sizeSmall,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                  if (total > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.s, vertical: Spacing.xs),
                      decoration: BoxDecoration(
                        color: colors.danger.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        total.toString(),
                        style: TextStyle(
                          fontSize: AppTextStyles.sizeSmall,
                          fontWeight: FontWeight.w700,
                          color: colors.danger,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: Spacing.m),
              ThreatBarChart(
                daily: daily,
                barColor: colors.danger,
                gridColor: colors.divider,
                textColor: colors.textHint,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EnginesSection extends StatelessWidget {
  const _EnginesSection();

  @override
  Widget build(BuildContext context) {
    final state   = context.watch<AppStateProvider>();
    final modules = context.watch<ModuleStatusProvider>();
    final colors  = state.colors;
    final l10n    = state.strings;
    final cache   = modules.smartCacheStats;
    final hitRate = cache.hitRate.clamp(0.0, 100.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: l10n.statsEnginesPerformanceTitle,
          icon: Icons.speed_outlined,
          colors: colors,
        ),
        AppCard(
          padding: Spacing.cardPadding,
          child: Row(
            children: [
              Expanded(
                child: StatChip(
                  icon: Icons.percent_outlined,
                  value: '${hitRate.toStringAsFixed(1)}%',
                  label: l10n.statsCacheHitRate,
                  color: colors.success,
                ),
              ),
              const SizedBox(width: Spacing.s),
              Expanded(
                child: StatChip(
                  icon: Icons.storage_outlined,
                  value: cache.entries.toString(),
                  label: l10n.statsCacheEntries,
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: Spacing.s),
              Expanded(
                child: StatChip(
                  icon: Icons.rule_folder_outlined,
                  value: modules.yaraRulesCount.toString(),
                  label: l10n.statsYaraRules,
                  color: colors.accentPurple,
                ),
              ),
              const SizedBox(width: Spacing.s),
              Expanded(
                child: StatChip(
                  icon: Icons.shield_outlined,
                  value: modules.quarantineCount.toString(),
                  label: l10n.statsQuarantineCount,
                  color: colors.warning,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ThreatSourcesSection extends StatelessWidget {
  final AdaptiveColors colors;
  final AppLocalizations l10n;
  final ThreatSourcesAggregate? sources;

  const _ThreatSourcesSection({
    required this.colors,
    required this.l10n,
    required this.sources,
  });

  @override
  Widget build(BuildContext context) {
    final colorMap = {
      ThreatSource.scan: colors.primary,
      ThreatSource.realtime: colors.accentTeal,
      ThreatSource.memory: colors.accentPurple,
      ThreatSource.web: colors.warning,
    };
    final labelMap = {
      ThreatSource.scan: l10n.statsSourceScan,
      ThreatSource.realtime: l10n.statsSourceRealtime,
      ThreatSource.memory: l10n.statsSourceMemory,
      ThreatSource.web: l10n.statsSourceWeb,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: l10n.statsThreatSourcesTitle,
          icon: Icons.pie_chart_outline,
          colors: colors,
        ),
        AppCard(
          padding: Spacing.cardPadding,
          child: sources == null
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: Spacing.m),
                  child: Text(
                    l10n.statsThreatSourcesEmpty,
                    style: TextStyle(
                      fontSize: AppTextStyles.sizeSmall,
                      color: colors.textSecondary,
                    ),
                  ),
                )
              : ThreatSourcesDonut(
                  sources: sources!,
                  colorMap: colorMap,
                  labelMap: labelMap,
                  centerLabelColor: colors.textPrimary,
                  centerSubLabelColor: colors.textSecondary,
                  zeroOutlineColor:
                      colors.textHint.withValues(alpha: 0.2),
                ),
        ),
      ],
    );
  }
}

