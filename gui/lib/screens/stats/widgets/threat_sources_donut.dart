
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../models/threat_sources_aggregate.dart';
import '../../../models/threat_stats.dart';
import '../../../theme/spacing.dart';
import '../../../theme/app_theme.dart';

class ThreatSourcesDonut extends StatelessWidget {
  final ThreatSourcesAggregate sources;
  final Map<ThreatSource, Color> colorMap;
  final Map<ThreatSource, String> labelMap;
  final Color centerLabelColor;
  final Color centerSubLabelColor;
  final Color zeroOutlineColor;

  const ThreatSourcesDonut({
    super.key,
    required this.sources,
    required this.colorMap,
    required this.labelMap,
    required this.centerLabelColor,
    required this.centerSubLabelColor,
    required this.zeroOutlineColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 170,
          height: 170,
          child: CustomPaint(
            painter: _DonutPainter(
              sources: sources,
              colorMap: colorMap,
              zeroOutlineColor: zeroOutlineColor,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    sources.total.toString(),
                    style: TextStyle(
                      fontSize: AppTextStyles.sizeHero,
                      fontWeight: FontWeight.w700,
                      color: centerLabelColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: Spacing.l),
        Expanded(
          child: _Legend(
            sources: sources,
            colorMap: colorMap,
            labelMap: labelMap,
            textColor: centerLabelColor,
            subTextColor: centerSubLabelColor,
          ),
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  final ThreatSourcesAggregate sources;
  final Map<ThreatSource, Color> colorMap;
  final Color zeroOutlineColor;

  static const double _kOuterRadius = 80;
  static const double _kInnerRadius = 50;

  _DonutPainter({
    required this.sources,
    required this.colorMap,
    required this.zeroOutlineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final ringWidth = _kOuterRadius - _kInnerRadius;
    final radius = _kInnerRadius + ringWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    if (sources.total == 0) {
      final p = Paint()
        ..color = zeroOutlineColor
        ..strokeWidth = ringWidth
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(center, radius, p);
      return;
    }

    final segments = <_Segment>[
      _Segment(sources.scan, colorMap[ThreatSource.scan]!),
      _Segment(sources.realtime, colorMap[ThreatSource.realtime]!),
      _Segment(sources.memory, colorMap[ThreatSource.memory]!),
      _Segment(sources.web, colorMap[ThreatSource.web]!),
    ];

    var startAngle = -math.pi / 2;
    for (final s in segments) {
      if (s.value == 0) continue;
      final sweep = (s.value / sources.total) * 2 * math.pi;
      final paint = Paint()
        ..color = s.color
        ..strokeWidth = ringWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) {
    return old.sources.total != sources.total || old.sources.scan != sources.scan || old.sources.realtime != sources.realtime || old.sources.memory != sources.memory || old.sources.web != sources.web || old.zeroOutlineColor != zeroOutlineColor;
  }
}

class _Segment {
  final int value;
  final Color color;
  const _Segment(this.value, this.color);
}

class _Legend extends StatelessWidget {
  final ThreatSourcesAggregate sources;
  final Map<ThreatSource, Color> colorMap;
  final Map<ThreatSource, String> labelMap;
  final Color textColor;
  final Color subTextColor;

  const _Legend({
    required this.sources,
    required this.colorMap,
    required this.labelMap,
    required this.textColor,
    required this.subTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final entries = <_LegendEntry>[
      _LegendEntry(ThreatSource.scan, sources.scan),
      _LegendEntry(ThreatSource.realtime, sources.realtime),
      _LegendEntry(ThreatSource.memory, sources.memory),
      _LegendEntry(ThreatSource.web, sources.web),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final e in entries) ...[
          _LegendRow(
            color: colorMap[e.source]!,
            label: labelMap[e.source]!,
            count: e.value,
            percent: sources.total == 0
                ? 0
                : (e.value / sources.total) * 100,
            textColor: textColor,
            subTextColor: subTextColor,
          ),
          const SizedBox(height: Spacing.s),
        ],
      ],
    );
  }
}

class _LegendEntry {
  final ThreatSource source;
  final int value;
  const _LegendEntry(this.source, this.value);
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final int count;
  final double percent;
  final Color textColor;
  final Color subTextColor;

  const _LegendRow({
    required this.color,
    required this.label,
    required this.count,
    required this.percent,
    required this.textColor,
    required this.subTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: Spacing.s),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: AppTextStyles.sizeDefault,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: Spacing.s),
        Text(
          '$count',
          style: TextStyle(
            fontSize: AppTextStyles.sizeDefault,
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: Spacing.xs),
        Text(
          '${percent.toStringAsFixed(0)}%',
          style: TextStyle(
            fontSize: AppTextStyles.sizeXSmall,
            color: subTextColor,
          ),
        ),
      ],
    );
  }
}

