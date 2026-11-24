import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../constants/app_dimens.dart';

class RingProgress extends StatelessWidget {
  const RingProgress({
    super.key,
    required this.value,
    required this.color,
    required this.trackColor,
    this.size = 56,
    this.strokeWidth = 6,
    this.child,
  });

  final double value;
  final Color color;
  final Color trackColor;
  final double size;
  final double strokeWidth;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
      duration: AppDurations.slow,
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, child) {
        return CustomPaint(
          painter: _RingPainter(
            value: animatedValue,
            color: color,
            trackColor: trackColor,
            strokeWidth: strokeWidth,
          ),
          child: SizedBox.square(
            dimension: size,
            child: Center(child: child),
          ),
        );
      },
      child: child,
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.value,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  final double value;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: (size.shortestSide - strokeWidth) / 2,
    );
    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawArc(rect, 0, math.pi * 2, false, track);

    if (value <= 0) return;
    final progress = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * value, false, progress);
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.color != color ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.strokeWidth != strokeWidth;
}
