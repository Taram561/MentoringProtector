class SmartCacheStats {
  final int hits;
  final int misses;
  final int entries;
  final int invalidations;
  final double hitRate;

  const SmartCacheStats({required this.hits, required this.misses, required this.entries, required this.invalidations, required this.hitRate});

  factory SmartCacheStats.fromJson(Map<String, dynamic> json) {
    return SmartCacheStats(
      hits: json['hits'] as int? ?? 0,
      misses: json['misses'] as int? ?? 0,
      entries: json['entries'] as int? ?? 0,
      invalidations: json['invalidations'] as int? ?? 0,
      hitRate: (json['hit_rate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  factory SmartCacheStats.empty() => const SmartCacheStats(hits: 0, misses: 0, entries: 0, invalidations: 0, hitRate: 0.0);
}
