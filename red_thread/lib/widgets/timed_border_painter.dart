import 'package:flutter/material.dart';
import 'dart:math';

class TimedBorderPainter extends CustomPainter {
  final double timeRemaining;
  final double duration;

  TimedBorderPainter({required this.timeRemaining, required this.duration});

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Paint paint = Paint()
      ..color = const Color(0xFFAA6059)
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // calculate startAngle and sweepAngle based off of time remaining and duration

    canvas.drawArc(rect, 9 * pi / 16, 14 * pi / 16, false, paint);
  }

  @override
  bool shouldRepaint(TimedBorderPainter oldDelegate) {
    return timeRemaining != oldDelegate.timeRemaining;
  }
}
