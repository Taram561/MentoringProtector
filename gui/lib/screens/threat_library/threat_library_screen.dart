import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../theme/spacing.dart';
import '../../services/threat_education_service.dart';
import '../../models/threat_info.dart';
import '../../widgets/app_title_bar.dart';
import '../../widgets/empty_state.dart';
import 'widgets/threat_card.dart';
import 'widgets/threat_filters.dart';
import '../../theme/app_theme.dart';

class ThreatLibraryScreen extends StatefulWidget {
  const ThreatLibraryScreen({super.key});

  @override
  State<ThreatLibraryScreen> createState() => _ThreatLibraryScreenState();
}

class _ThreatLibraryScreenState extends State<ThreatLibraryScreen> {
  final _service = ThreatEducationService.instance;
  final _queryController = TextEditingController();
  String? _selectedType;
  String? _selectedCategory;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _queryController.addListener(() => setState(() {}));
    _service.load().then((_) {
      if (mounted) setState(() => _loaded = true);
    });
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  List<ThreatInfo> get _filtered {
    if (!_loaded) return const [];
    final query = _queryController.text.toLowerCase();
    return _service.all.where((t) {
      final matchesQuery = query.isEmpty || t.displayName.toLowerCase().contains(query) || t.descriptionShort.toLowerCase().contains(query) || t.name.toLowerCase().contains(query);
      final matchesType = _selectedType == null || t.type.toLowerCase() == _selectedType;
      final matchesCategory = _selectedCategory == null || t.hygieneCategory.toLowerCase() == _selectedCategory;
      return matchesQuery && matchesType && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final colors = state.colors;
    final l10n = state.strings;
    final filtered = _filtered;

    return AppTitleBarScaffold(
      title: l10n.threatLibraryTitle,
      colors: colors,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                Spacing.l, Spacing.m, Spacing.l, 0),
            child: ThreatFilters(
              queryController: _queryController,
              selectedType: _selectedType,
              selectedCategory: _selectedCategory,
              onTypeChanged: (v) => setState(() => _selectedType = v),
              onCategoryChanged: (v) => setState(() => _selectedCategory = v),
            ),
          ),
          if (_loaded)
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.l, vertical: Spacing.xs),
              child: Text(
                l10n.threatLibraryCount(filtered.length, _service.all.length),
                style: TextStyle(fontSize: AppTextStyles.sizeXSmall, color: colors.textHint),
              ),
            ),
          Expanded(
            child: !_loaded
                ? Center(
                    child: CircularProgressIndicator(
                      color: colors.primary,
                      strokeWidth: 2,
                    ),
                  )
                : filtered.isEmpty
                    ? EmptyState(
                        icon: Icons.search_off_outlined,
                        title: l10n.threatLibraryEmpty,
                        colors: colors,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                            Spacing.l, Spacing.xs, Spacing.l, Spacing.xl),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) => ThreatCard(info: filtered[i]),
                      ),
          ),
        ],
      ),
    );
  }
}

