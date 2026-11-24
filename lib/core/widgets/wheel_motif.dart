import 'dart:math' as math;

import 'package:flutter/material.dart';

class WheelMotif extends StatelessWidget {
  const WheelMotif({
    super.key,
    required this.size,
    required this.color,
    this.strokeWidth = 1.4,
  });

  final double size;
  final Color color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _WheelPainter(color: color, strokeWidth: strokeWidth),
    );
  }
}

class _WheelPainter extends CustomPainter {
  const _WheelPainter({required this.color, required this.strokeWidth});

  final Color color;
  final double strokeWidth;

  static const int _spokeCount = 12;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - strokeWidth;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    for (final factor in const [1.0, 0.7, 0.4]) {
      canvas.drawCircle(center, radius * factor, stroke);
    }
    for (var index = 0; index < _spokeCount; index++) {
      final angle = index * 2 * math.pi / _spokeCount;
      final direction = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(
        center + direction * radius * 0.4,
        center + direction * radius * 0.7,
        stroke,
      );
    }
    canvas.drawCircle(center, radius * 0.14, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_WheelPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}
