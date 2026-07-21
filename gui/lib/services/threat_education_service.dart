
import 'dart:convert';
import 'dart:io';
import '../models/threat_info.dart';
import '../ffi/app_paths.dart';

class ThreatEducation {
  final ThreatInfo info;
  final int level;

  const ThreatEducation({required this.info, required this.level});

  bool get isSignatureLevel => level == 1;
  bool get isFamilyLevel => level == 2;
  bool get isCategoryLevel => level == 3;

  bool get hasContent => info.removalSteps.isNotEmpty || info.preventionTips.isNotEmpty || info.howItSpreads.isNotEmpty;
}

class ThreatEducationService {
  ThreatEducationService._();
  static final ThreatEducationService instance = ThreatEducationService._();

  bool _loaded = false;
  final List<ThreatInfo> _all = [];
  final Map<String, ThreatInfo> _byName = {};
  final Map<String, ThreatInfo> _byType = {};

  List<ThreatInfo> get all => List.unmodifiable(_all);

  Future<void> load() async {
    if (_loaded) return;

    try {
      final path = AppPaths.threatDatabasePath;
      final file = File(path);
      if (!await file.exists()) return;

      final raw = await file.readAsString(encoding: utf8);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final threats = json['threats'] as List<dynamic>? ?? [];

      for (final entry in threats) {
        final map = entry as Map<String, dynamic>;
        final adapted = <String, dynamic>{ 'threat_name': map['name'], 'display_name': map['display_name'], 'threat_type': map['type'], 'danger_level': map['danger_level'], 'description_short': map['description_short'], 'description_full': map['description_full'], 'how_it_spreads': map['how_it_spreads'], 'what_it_does': map['what_it_does'], 'recommended_action': map['recommended_action'], 'removal_steps': map['removal_steps'], 'prevention_tips': map['prevention_tips'], 'hygiene_category': map['hygiene_category'], 'is_found': true };

        final info = ThreatInfo.fromJson(adapted);
        final name = info.name.toLowerCase();
        final type = info.type.toLowerCase();

        _all.add(info);
        _byName[name] = info;

        if (!_byType.containsKey(type)) {
          _byType[type] = info;
        }
      }

      _loaded = true;
    } catch (e) {
    }
  }

  ThreatEducation lookup({required ThreatInfo threatInfo, required String threatName, required String threatType}) {
    if (threatInfo.isFound && _hasContent(threatInfo)) {
      return ThreatEducation(info: threatInfo, level: 1);
    }

    final nameLower = threatName.toLowerCase();
    final byName = _byName[nameLower];
    if (byName != null && _hasContent(byName)) {
      return ThreatEducation(info: byName, level: 1);
    }

    final typeLower = _normalizeType(threatType);
    final byType = _byType[typeLower];
    if (byType != null && _hasContent(byType)) {
      return ThreatEducation(info: byType, level: 2);
    }

    return ThreatEducation(info: threatInfo, level: 3);
  }

  String _normalizeType(String type) {
    final lower = type.toLowerCase();
    if (lower.contains('trojan') || lower.contains('backdoor')) return 'trojan';
    if (lower.contains('ransom')) return 'ransomware';
    if (lower.contains('spyware') || lower.contains('keylog')) return 'spyware';
    if (lower.contains('worm')) return 'worm';
    if (lower.contains('adware')) return 'adware';
    if (lower.contains('pup') || lower.contains('pua')) return 'pup';
    if (lower.contains('rootkit')) return 'rootkit';
    if (lower.contains('exploit')) return 'exploit';
    if (lower.contains('phish')) return 'phishing';
    return lower;
  }

  bool _hasContent(ThreatInfo info) => info.removalSteps.isNotEmpty || info.howItSpreads.isNotEmpty;
}

