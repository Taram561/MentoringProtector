class SignatureInfo {
  final bool isValid;
  final bool isRevoked;
  final String signerName;
  final String issuer;
  final String expiryDate;
  final String thumbprint;
  final String revocationStatus;

  const SignatureInfo({
    this.isValid = false,
    this.isRevoked = false,
    this.signerName = '',
    this.issuer = '',
    this.expiryDate = '',
    this.thumbprint = '',
    this.revocationStatus = 'unknown',
  });

  factory SignatureInfo.fromJson(Map<String, dynamic> json) {
    return SignatureInfo(
      isValid: json['has_signature'] as bool? ?? false,
      isRevoked: json['is_revoked'] as bool? ?? false,
      signerName: json['signer_name'] as String? ?? '',
      issuer: json['signer_issuer'] as String? ?? '',
      expiryDate: json['signature_expiry'] as String? ?? '',
      thumbprint: json['signature_thumbprint'] as String? ?? '',
      revocationStatus: json['revocation_status'] as String? ?? 'unknown',
    );
  }

  bool get hasInfo => signerName.isNotEmpty;
}

class YaraMatchResult {
  final String ruleName;
  final String ruleNamespace;
  final String metaAuthor;
  final String metaDesc;
  final String metaSeverity;
  final String metaReference;
  final List<String> tags;
  final List<String> matchedStrings;

  const YaraMatchResult({
    this.ruleName = '',
    this.ruleNamespace = '',
    this.metaAuthor = '',
    this.metaDesc = '',
    this.metaSeverity = '',
    this.metaReference = '',
    this.tags = const [],
    this.matchedStrings = const [],
  });

  factory YaraMatchResult.fromJson(Map<String, dynamic> json) {
    return YaraMatchResult(
      ruleName: json['rule_name'] as String? ?? '',
      ruleNamespace: json['rule_namespace'] as String? ?? '',
      metaAuthor: json['meta_author'] as String? ?? '',
      metaDesc: json['meta_desc'] as String? ?? '',
      metaSeverity: json['meta_severity'] as String? ?? '',
      metaReference: json['meta_reference'] as String? ?? '',
      tags: _parseList(json['tags']),
      matchedStrings: _parseList(json['matched_strings']),
    );
  }

  static List<String> _parseList(dynamic value) {
    if (value is List) return value.cast<String>();
    return const [];
  }
}

class HeuristicResult {
  final int suspicionScore;
  final String verdict;
  final int dangerLevel;
  final double entropy;
  final bool isPeFile;
  final bool isPacked;
  final bool hasSignature;
  final SignatureInfo signature;
  final List<String> triggeredRules;
  final List<String> suspiciousImports;
  final List<String> suspiciousStrings;
  final bool analyzed;
  final int yaraScore;
  final int yaraScanTimeMs;
  final List<YaraMatchResult> yaraMatches;

  const HeuristicResult({
    required this.suspicionScore,
    required this.verdict,
    required this.dangerLevel,
    required this.entropy,
    required this.isPeFile,
    required this.isPacked,
    required this.hasSignature,
    required this.signature,
    required this.triggeredRules,
    required this.suspiciousImports,
    required this.suspiciousStrings,
    required this.analyzed,
    this.yaraScore = 0,
    this.yaraScanTimeMs = 0,
    this.yaraMatches = const [],
  });

  factory HeuristicResult.fromJson(Map<String, dynamic> json) {
    return HeuristicResult(
      suspicionScore: json['heuristic_score'] as int? ?? 0,
      verdict: json['heuristic_verdict'] as String? ?? 'clean',
      dangerLevel: json['heuristic_danger'] as int? ?? 0,
      entropy: (json['entropy'] as num?)?.toDouble() ?? 0.0,
      isPeFile: json['is_pe_file'] as bool? ?? false,
      isPacked: json['is_packed'] as bool? ?? false,
      hasSignature: json['has_signature'] as bool? ?? false,
      signature: SignatureInfo.fromJson(json),
      triggeredRules: _parseStringList(json['triggered_rules']),
      suspiciousImports: _parseStringList(json['suspicious_imports']),
      suspiciousStrings: _parseStringList(json['suspicious_strings']),
      analyzed: json['heuristic_score'] != null,
      yaraScore: json['yara_score'] as int? ?? 0,
      yaraScanTimeMs: json['yara_scan_time_ms'] as int? ?? 0,
      yaraMatches: _parseYaraMatches(json['yara_matches']),
    );
  }

  factory HeuristicResult.empty() {
    return const HeuristicResult(
      suspicionScore: 0, verdict: 'clean', dangerLevel: 0,
      entropy: 0.0, isPeFile: false, isPacked: false, hasSignature: false,
      signature: SignatureInfo(),
      triggeredRules: [], suspiciousImports: [], suspiciousStrings: [],
      analyzed: false,
      yaraScore: 0, yaraScanTimeMs: 0, yaraMatches: [],
    );
  }

  String verdictLabelLocalized(dynamic l10n) => switch (verdict) { 'clean' => l10n.threatVerdictClean, 'suspicious' => l10n.threatVerdictSuspicious, 'likely_malicious' => l10n.threatVerdictLikelyMalicious, 'malicious' => l10n.threatVerdictMalicious, _ => l10n.threatVerdictUnknown };

  static List<String> _parseStringList(dynamic value) {
    if (value is List) return value.cast<String>();
    return const [];
  }

  static List<YaraMatchResult> _parseYaraMatches(dynamic value) {
    if (value is List) return value.whereType<Map<String, dynamic>>().map(YaraMatchResult.fromJson).toList();
    return const [];
  }
}
