import 'dart:math';
import 'package:flutter/material.dart';

// Enhanced 3D background painter
class EnhancedBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Create a multi-layered 3D background effect

    // Layer 1: Diagonal lines
    final Paint linePaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < 20; i++) {
      double y = i * size.height / 10;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y - size.height * 0.3),
        linePaint,
      );
    }

    // Layer 2: Circular gradient highlights
    final Paint circlePaint = Paint()..style = PaintingStyle.fill;

    // Top left glow
    final Rect topLeftRect = Rect.fromCenter(
      center: Offset(size.width * 0.2, size.height * 0.2),
      width: size.width * 0.8,
      height: size.height * 0.8,
    );

    final Gradient topLeftGradient = RadialGradient(
      center: Alignment.topLeft,
      radius: 0.8,
      colors: [
        Colors.white.withOpacity(0.1),
        Colors.transparent,
      ],
      stops: const [0.0, 1.0],
    );

    circlePaint.shader = topLeftGradient.createShader(topLeftRect);
    canvas.drawOval(topLeftRect, circlePaint);

    // Bottom right glow
    final Rect bottomRightRect = Rect.fromCenter(
      center: Offset(size.width * 0.8, size.height * 0.9),
      width: size.width * 0.6,
      height: size.height * 0.4,
    );

    final Gradient bottomRightGradient = RadialGradient(
      center: Alignment.bottomRight,
      radius: 0.8,
      colors: [
        Colors.cyanAccent.withOpacity(0.05),
        Colors.transparent,
      ],
      stops: const [0.0, 1.0],
    );

    circlePaint.shader = bottomRightGradient.createShader(bottomRightRect);
    canvas.drawOval(bottomRightRect, circlePaint);

    // Layer 3: Subtle grid
    final Paint gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Horizontal grid lines
    for (int i = 0; i < 15; i++) {
      double y = i * size.height / 15;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Vertical grid lines
    for (int i = 0; i < 15; i++) {
      double x = i * size.width / 15;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }

    // Layer 4: Decorative circles with depth
    final Paint circleBorderPaint = Paint()
      ..color = Colors.white.withOpacity(0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw large circle with offset for 3D effect
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.6),
      size.width * 0.15,
      circleBorderPaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.2 + 3, size.height * 0.6 + 3),
      size.width * 0.15,
      circleBorderPaint..color = Colors.white.withOpacity(0.03),
    );

    // Another decorative element
    canvas.drawCircle(
      Offset(size.width * 0.7, size.height * 0.2),
      size.width * 0.1,
      circleBorderPaint..color = Colors.white.withOpacity(0.05),
    );

    canvas.drawCircle(
      Offset(size.width * 0.7 + 2, size.height * 0.2 + 2),
      size.width * 0.1,
      circleBorderPaint..color = Colors.white.withOpacity(0.02),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for the card cutout shape
class CutoutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, 0);

    // Create the curve
    path.moveTo(size.width * 0.6, 0);
    path.quadraticBezierTo(
      size.width * 0.65,
      size.height * 0.5,
      size.width * 0.6,
      size.height,
    );

    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
