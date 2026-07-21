
import 'package:flutter/material.dart';
import '../../../models/user_profile.dart';
import '../../../theme/app_theme.dart';

class HygieneSparkline extends StatelessWidget {
  final List<HygieneSnapshot> history;
  final Color color;
  final double height;
  final Color dotCenter;

  const HygieneSparkline({
    super.key,
    required this.history,
    required this.color,
    this.height = 60,
    this.dotCenter = AppColors.surface,
  });

  @override
  Widget build(BuildContext context) {
    if (history.length < 2) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            '...',
            style: TextStyle(
              color: color.withValues(alpha: 0.3),
              fontSize: AppTextStyles.sizeSmall,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: CustomPaint(
        size: Size.infinite,
        painter: _SparklinePainter(
          points: history.map((s) => s.score.toDouble()).toList(),
          color: color,
          dotCenter: dotCenter,
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> points;
  final Color color;
  final Color dotCenter;

  _SparklinePainter({
    required this.points,
    required this.color,
    required this.dotCenter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final maxVal = 100.0;
    final minVal = 0.0;
    final range = maxVal - minVal;

    final stepX = size.width / (points.length - 1);

    final linePath = Path();
    final fillPath = Path();

    for (var i = 0; i < points.length; i++) {
      final x = i * stepX;
      final y = size.height - ((points[i] - minVal) / range) * size.height;

      if (i == 0) {
        linePath.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        linePath.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.12);

    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(linePath, linePaint);

    final lastX = (points.length - 1) * stepX;
    final lastY = size.height -
        ((points.last - minVal) / range) * size.height;

    canvas.drawCircle(
      Offset(lastX, lastY),
      3.5,
      Paint()..color = color,
    );
    canvas.drawCircle(
      Offset(lastX, lastY),
      2.0,
      Paint()..color = dotCenter,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) =>
      old.points != points || old.color != color || old.dotCenter != dotCenter;
}

