import '../models/quarantine_entry.dart';

sealed class QuarantineOperationResult {
  const QuarantineOperationResult();
}

final class QuarantineSuccess extends QuarantineOperationResult {
  final String entryId;
  const QuarantineSuccess({required this.entryId});
}

final class QuarantineFailure extends QuarantineOperationResult {
  final String message;
  final int statusCode;
  const QuarantineFailure({required this.message, required this.statusCode});
}

class QuarantineList {
  final int count;
  final int totalSize;
  final List<QuarantineEntry> entries;

  const QuarantineList({required this.count, required this.totalSize, required this.entries});

  factory QuarantineList.fromJson(Map<String, dynamic> json) {
    final entriesJson = json['entries'] as List<dynamic>? ?? [];
    return QuarantineList(count: json['count'] as int? ?? 0, totalSize: json['total_size'] as int? ?? 0, entries: entriesJson.map((e) => QuarantineEntry.fromJson(e as Map<String, dynamic>)).toList());
  }

  factory QuarantineList.empty() => const QuarantineList(count: 0, totalSize: 0, entries: []);

  String get totalSizeLabel => switch (totalSize) { < 1024 => '$totalSize Б', < 1024 * 1024 => '${(totalSize / 1024).toStringAsFixed(1)} КБ', _ => '${(totalSize / (1024 * 1024)).toStringAsFixed(1)} МБ' };
}

