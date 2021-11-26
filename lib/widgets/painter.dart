import 'package:flutter/material.dart';

class Painter extends CustomPainter {
  // String path;
  Color color;
  double start;
  double sweep;
  double width;
  StrokeCap cap;

  Painter({
    required this.start,
    required this.sweep,
    required this.width,
    required this.color,
    required this.cap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTRB(0, 0, size.width, size.height);
    final startAngle = start;
    final sweepAngle = sweep;
    const useCenter = false;
    final paint = Paint()
      ..strokeCap = cap
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    canvas.drawArc(rect, startAngle, sweepAngle, useCenter, paint);
  }

  @override
  // ignore: avoid_renaming_method_parameters
  bool shouldRepaint(CustomPainter old) {
    return false;
  }
}
