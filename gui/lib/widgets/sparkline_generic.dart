
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GenericSparkline extends StatelessWidget {
  final List<double> points;
  final double minValue;
  final double maxValue;
  final Color lineColor;
  final Color fillColor;
  final Color dotCenterColor;
  final double height;
  final bool showLastDot;

  const GenericSparkline({
    super.key,
    required this.points,
    required this.minValue,
    required this.maxValue,
    required this.lineColor,
    required this.fillColor,
    required this.dotCenterColor,
    this.height = 60,
    this.showLastDot = true,
  });

  @override
  Widget build(BuildContext context) {
    if (points.length < 2) {
      return SizedBox(
        height: height,
        child: Center(
          child: Text(
            '-',
            style: TextStyle(
              color: lineColor.withValues(alpha: 0.3),
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
        painter: _GenericSparklinePainter(
          points: points,
          minValue: minValue,
          maxValue: maxValue,
          lineColor: lineColor,
          fillColor: fillColor,
          dotCenterColor: dotCenterColor,
          showLastDot: showLastDot,
        ),
      ),
    );
  }
}

class _GenericSparklinePainter extends CustomPainter {
  final List<double> points;
  final double minValue;
  final double maxValue;
  final Color lineColor;
  final Color fillColor;
  final Color dotCenterColor;
  final bool showLastDot;

  _GenericSparklinePainter({
    required this.points,
    required this.minValue,
    required this.maxValue,
    required this.lineColor,
    required this.fillColor,
    required this.dotCenterColor,
    required this.showLastDot,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final range = maxValue - minValue;
    final stepX = size.width / (points.length - 1);

    final linePath = Path();
    final fillPath = Path();

    for (var i = 0; i < points.length; i++) {
      final x = i * stepX;
      final double y = range == 0 ? size.height / 2 : size.height - ((points[i] - minValue) / range) * size.height;

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

    final fillPaint = Paint()..color = fillColor;
    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()..color = lineColor..strokeWidth = 2.0..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round;
    canvas.drawPath(linePath, linePaint);

    if (showLastDot) {
      final lastX = (points.length - 1) * stepX;
      final double lastY = range == 0 ? size.height / 2 : size.height - ((points.last - minValue) / range) * size.height;

      canvas.drawCircle(Offset(lastX, lastY), 3.5, Paint()..color = lineColor);
      canvas.drawCircle(Offset(lastX, lastY), 2.0, Paint()..color = dotCenterColor);
    }
  }

  @override
  bool shouldRepaint(covariant _GenericSparklinePainter old) {
    if (old.points.length != points.length) return true;
    if (old.minValue != minValue || old.maxValue != maxValue) return true;
    if (old.lineColor != lineColor || old.fillColor != fillColor || old.dotCenterColor != dotCenterColor) return true;
    if (old.showLastDot != showLastDot) return true;
    for (var i = 0; i < points.length; i++) {
      if (old.points[i] != points[i]) return true;
    }
    return false;
  }
}

