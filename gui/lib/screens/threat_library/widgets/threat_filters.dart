import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_state_provider.dart';
import '../../../theme/spacing.dart';
import '../../../theme/app_theme.dart';

class ThreatFilters extends StatelessWidget {
  final TextEditingController queryController;
  final String? selectedType;
  final String? selectedCategory;
  final ValueChanged<String?> onTypeChanged;
  final ValueChanged<String?> onCategoryChanged;

  const ThreatFilters({
    super.key,
    required this.queryController,
    required this.selectedType,
    required this.selectedCategory,
    required this.onTypeChanged,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppStateProvider>();
    final colors = state.colors;
    final l10n = state.strings;

    final types = [
      (null,          l10n.threatLibraryFilterAll),
      ('trojan',      l10n.threatTypeTrojan),
      ('spyware',     l10n.threatTypeSpyware),
      ('phishing',    l10n.threatTypePhishing),
      ('ransomware',  l10n.threatTypeRansomware),
      ('worm',        l10n.threatTypeWorm),
      ('adware',      l10n.threatTypeAdware),
      ('exploit',     l10n.threatTypeExploit),
      ('pup',         l10n.threatTypePup),
      ('backdoor',    l10n.threatTypeBackdoor),
      ('rootkit',     l10n.threatTypeRootkit),
    ];

    final categories = [
      (null,                 l10n.threatLibraryFilterAll),
      ('safe_downloads',     l10n.hygieneCategorySafeDownloads),
      ('general',            l10n.hygieneCategoryGeneral),
      ('phishing',           l10n.hygieneCategoryPhishing),
      ('backups',            l10n.hygieneCategoryBackups),
      ('network_security',   l10n.hygieneCategoryNetworkSecurity),
      ('system_monitoring',  l10n.hygieneCategorySystemMonitoring),
      ('passwords',          l10n.hygieneCategoryPasswords),
      ('removable_media',    l10n.hygieneCategoryRemovableMedia),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: queryController,
          style: TextStyle(fontSize: AppTextStyles.sizeDefault, color: colors.textPrimary),
          decoration: InputDecoration(
            hintText: l10n.threatLibrarySearchHint,
            hintStyle: TextStyle(color: colors.textHint, fontSize: AppTextStyles.sizeDefault),
            prefixIcon: Icon(Icons.search, color: colors.textHint, size: 20),
            suffixIcon: queryController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: colors.textHint, size: 18),
                    onPressed: () => queryController.clear(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: Spacing.m, vertical: Spacing.s),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.textHint.withValues(alpha: 0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: colors.textHint.withValues(alpha: 0.25)),
            ),
            filled: true,
            fillColor: colors.surface,
          ),
        ),
        const SizedBox(height: Spacing.m),
        Text(
          l10n.threatLibraryFilterType,
          style: TextStyle(
            fontSize: AppTextStyles.sizeXSmall,
            fontWeight: FontWeight.w600,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: Spacing.s),
        Wrap(
          spacing: Spacing.s,
          runSpacing: Spacing.xs,
          children: types.map((t) {
            final value = t.$1;
            final label = t.$2;
            final isSelected = selectedType == value;
            return FilterChip(
              label: Text(label, style: const TextStyle(fontSize: AppTextStyles.sizeXSmall)),
              selected: isSelected,
              onSelected: (_) => onTypeChanged(value),
              selectedColor: colors.primary.withValues(alpha: 0.15),
              checkmarkColor: colors.primary,
              labelStyle: TextStyle(
                color: isSelected ? colors.primary : colors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              side: BorderSide(
                color: isSelected
                    ? colors.primary.withValues(alpha: 0.4)
                    : colors.textHint.withValues(alpha: 0.2),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: Spacing.m),
        Text(
          l10n.threatLibraryFilterCategory,
          style: TextStyle(
            fontSize: AppTextStyles.sizeXSmall,
            fontWeight: FontWeight.w600,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: Spacing.s),
        Wrap(
          spacing: Spacing.s,
          runSpacing: Spacing.xs,
          children: categories.map((c) {
            final value = c.$1;
            final label = c.$2;
            final isSelected = selectedCategory == value;
            return FilterChip(
              label: Text(label, style: const TextStyle(fontSize: AppTextStyles.sizeXSmall)),
              selected: isSelected,
              onSelected: (_) => onCategoryChanged(value),
              selectedColor: colors.primary.withValues(alpha: 0.15),
              checkmarkColor: colors.primary,
              labelStyle: TextStyle(
                color: isSelected ? colors.primary : colors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              side: BorderSide(
                color: isSelected
                    ? colors.primary.withValues(alpha: 0.4)
                    : colors.textHint.withValues(alpha: 0.2),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: Spacing.m),
      ],
    );
  }
}

