import 'package:flutter/material.dart';
import 'dart:math';

class WavyPainter extends CustomPainter {
  final double waveHeight;
  final double waveFrequency;
  final double phaseShift;

  WavyPainter({
    required this.waveHeight,
    required this.waveFrequency,
    required this.phaseShift,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF4081).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.3);

    for (double x = 0; x <= size.width; x++) {
      final y = waveHeight * sin((x * waveFrequency) + phaseShift) +
          size.height * 0.8;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
