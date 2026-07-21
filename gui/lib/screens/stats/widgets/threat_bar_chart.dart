
import 'package:flutter/material.dart';
import '../../../models/threat_stats.dart';

class ThreatBarChart extends StatelessWidget {
  final List<DailyStats> daily;
  final Color barColor;
  final Color gridColor;
  final Color textColor;
  final double height;

  const ThreatBarChart({
    super.key,
    required this.daily,
    required this.barColor,
    required this.gridColor,
    required this.textColor,
    this.height = 140,
  });

  @override
  Widget build(BuildContext context) {
    final buckets = _aggregateForPeriod(daily);
    final maxValue = buckets.isEmpty
        ? 0
        : buckets.map((b) => b.value).fold<int>(0, (a, b) => a > b ? a : b);

    return SizedBox(
      height: height,
      child: CustomPaint(
        size: Size.infinite,
        painter: _BarChartPainter(
          buckets: buckets,
          maxValue: maxValue,
          barColor: barColor,
          gridColor: gridColor,
          textColor: textColor,
        ),
      ),
    );
  }

  static List<_Bucket> _aggregateForPeriod(List<DailyStats> input) {
    if (input.isEmpty) return const [];
    final period = input.length;

    if (period <= 30) {
      return input
          .map((d) => _Bucket(label: d.date, value: d.threats))
          .toList();
    }

    const targetBuckets = 13;
    final perBucket = (period / targetBuckets).ceil();
    final out = <_Bucket>[];
    for (var i = 0; i < input.length; i += perBucket) {
      final end =
          (i + perBucket > input.length) ? input.length : i + perBucket;
      var sum = 0;
      for (var j = i; j < end; j++) {
        sum += input[j].threats;
      }
      out.add(_Bucket(label: input[i].date, value: sum));
    }
    return out;
  }
}

class _Bucket {
  final DateTime label;
  final int value;
  const _Bucket({required this.label, required this.value});
}

class _BarChartPainter extends CustomPainter {
  final List<_Bucket> buckets;
  final int maxValue;
  final Color barColor;
  final Color gridColor;
  final Color textColor;

  static const double _kYAxisLabelGutter = 28;
  static const double _kXAxisLabelGutter = 16;

  _BarChartPainter({
    required this.buckets,
    required this.maxValue,
    required this.barColor,
    required this.gridColor,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final chartWidth = size.width - _kYAxisLabelGutter;
    final chartHeight = size.height - _kXAxisLabelGutter;

    _drawGrid(canvas, chartWidth, chartHeight);

    if (buckets.isEmpty || maxValue == 0) {
      _drawBaseline(canvas, chartWidth, chartHeight);
      return;
    }

    _drawBars(canvas, chartWidth, chartHeight);
    _drawXAxisLabels(canvas, chartWidth, size.height);
  }

  void _drawGrid(Canvas canvas, double w, double h) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5;

    for (var i = 0; i < 4; i++) {
      final y = h - (i / 3.0) * h;
      canvas.drawLine(Offset(0, y), Offset(w, y), paint);

      if (maxValue > 0) {
        final value = (maxValue * (i / 3.0)).round();
        _drawText(canvas, value.toString(), Offset(w + 4, y - 6), 9, textColor);
      }
    }
  }

  void _drawBaseline(Canvas canvas, double w, double h) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(0, h), Offset(w, h), paint);
  }

  void _drawBars(Canvas canvas, double w, double h) {
    if (buckets.isEmpty) return;
    final slotWidth = w / buckets.length;
    final barWidth = slotWidth * 0.6;
    final pad = (slotWidth - barWidth) / 2;

    final paint = Paint()..color = barColor;

    for (var i = 0; i < buckets.length; i++) {
      final v = buckets[i].value;
      if (v == 0) continue;
      final barHeight = (v / maxValue) * h;
      final left = i * slotWidth + pad;
      final top = h - barHeight;
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(left, top, barWidth, barHeight),
        topLeft: const Radius.circular(2),
        topRight: const Radius.circular(2),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  void _drawXAxisLabels(Canvas canvas, double w, double totalH) {
    if (buckets.isEmpty) return;
    final positions = <int>[0];
    if (buckets.length > 2) positions.add(buckets.length ~/ 2);
    if (buckets.length > 1) positions.add(buckets.length - 1);

    final slotWidth = w / buckets.length;
    final y = totalH - _kXAxisLabelGutter + 2;

    for (final i in positions) {
      final label = _formatDate(buckets[i].label);
      final x = i * slotWidth + slotWidth / 2 - 14;
      _drawText(canvas, label, Offset(x, y), 9, textColor);
    }
  }

  String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd.$mm';
  }

  void _drawText(
      Canvas canvas, String text, Offset offset, double fontSize, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: fontSize, color: color),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter old) {
    if (old.buckets.length != buckets.length) return true;
    if (old.maxValue != maxValue) return true;
    if (old.barColor != barColor || old.gridColor != gridColor || old.textColor != textColor) return true;
    if (buckets.isNotEmpty && old.buckets.isNotEmpty && old.buckets.last.label.millisecondsSinceEpoch != buckets.last.label.millisecondsSinceEpoch) return true;
    return false;
  }
}

