import 'package:flutter/material.dart';
import '../../../ffi/core_service.dart';
import '../../../providers/app_state_provider.dart';
import '../../../theme/spacing.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_theme.dart';

class ActiveEnginesChip extends StatefulWidget {
  const ActiveEnginesChip({super.key});

  @override
  State<ActiveEnginesChip> createState() => _ActiveEnginesChipState();
}

class _ActiveEnginesChipState extends State<ActiveEnginesChip> {
  List<String> _engines = const [];

  static const Map<String, IconData> _engineIcons = {
    'signatures': Icons.fingerprint,
    'heuristic': Icons.psychology,
    'yara': Icons.rule,
    'bloom_filter': Icons.filter_list,
  };

  @override
  void initState() {
    super.initState();
    _engines = CoreService().getActiveEngines();
  }

  @override
  Widget build(BuildContext context) {
    if (_engines.isEmpty) return const SizedBox.shrink();

    final state = context.watch<AppStateProvider>();
    final colors = state.colors;
    final l10n = state.strings;

    final labelOf = <String, String>{
      'signatures': l10n.engineSignatures,
      'heuristic': l10n.engineHeuristic,
      'yara': l10n.engineYara,
      'bloom_filter': l10n.engineBloom,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.activeEnginesLabel,
          style: TextStyle(
            fontSize: AppTextStyles.sizeDefault,
            fontWeight: FontWeight.w600,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: Spacing.s),
        Wrap(
          spacing: Spacing.s,
          runSpacing: Spacing.xs,
          children: _engines.map((e) {
            return Chip(
              avatar: Icon(
                _engineIcons[e] ?? Icons.extension,
                size: 14,
                color: colors.primary,
              ),
              label: Text(
                labelOf[e] ?? e,
                style: TextStyle(
                  fontSize: AppTextStyles.sizeSmall,
                  color: colors.textPrimary,
                ),
              ),
              backgroundColor: colors.primary.withValues(alpha: 0.08),
              side: BorderSide(color: colors.primary.withValues(alpha: 0.2)),
              padding: EdgeInsets.symmetric(horizontal: Spacing.xs),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            );
          }).toList(),
        ),
      ],
    );
  }
}

