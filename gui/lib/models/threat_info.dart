
class ThreatInfo {
  final String name;
  final String displayName;
  final String type;
  final int dangerLevel;
  final String descriptionShort;
  final String descriptionFull;
  final String howItSpreads;
  final String whatItDoes;
  final String recommendedAction;
  final List<String> removalSteps;
  final List<String> preventionTips;
  final String hygieneCategory;
  final bool isFound;

  const ThreatInfo({required this.name, required this.displayName, required this.type, required this.dangerLevel, required this.descriptionShort, required this.descriptionFull, required this.howItSpreads, required this.whatItDoes, required this.recommendedAction, required this.removalSteps, required this.preventionTips, required this.hygieneCategory, required this.isFound});

  factory ThreatInfo.fromJson(Map<String, dynamic> json) {
    return ThreatInfo(name: json['threat_name'] as String? ?? '', displayName: json['display_name'] as String? ?? '', type: json['threat_type'] as String? ?? 'unknown', dangerLevel: json['danger_level'] as int? ?? 0, descriptionShort: json['description_short'] as String? ?? '', descriptionFull: json['description_full'] as String? ?? '', howItSpreads: json['how_it_spreads'] as String? ?? '', whatItDoes: json['what_it_does'] as String? ?? '', recommendedAction: json['recommended_action'] as String? ?? 'quarantine', removalSteps: _parseStringList(json['removal_steps']), preventionTips: _parseStringList(json['prevention_tips']), hygieneCategory: json['hygiene_category'] as String? ?? 'general', isFound: json['is_found'] as bool? ?? false);
  }

  factory ThreatInfo.unknown(String name) {
    return ThreatInfo(name: name, displayName: '', type: 'unknown', dangerLevel: 5, descriptionShort: '', descriptionFull: '', howItSpreads: '', whatItDoes: '', recommendedAction: 'quarantine', removalSteps: const [], preventionTips: const [], hygieneCategory: 'general', isFound: false);
  }

  factory ThreatInfo.empty() {
    return const ThreatInfo(name: '', displayName: '', type: '', dangerLevel: 0, descriptionShort: '', descriptionFull: '', howItSpreads: '', whatItDoes: '', recommendedAction: '', removalSteps: [], preventionTips: [], hygieneCategory: '', isFound: false);
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is List) return value.cast<String>();
    return const [];
  }
}
