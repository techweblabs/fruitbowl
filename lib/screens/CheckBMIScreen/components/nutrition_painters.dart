import 'package:flutter/material.dart';
import 'dart:math' as math;

// Custom painter for the nutrition-themed background
class NutritionBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Paint for the abstract nutrition shapes
    final shapePaint = Paint()
      ..color = Colors.white.withOpacity(0.07)
      ..style = PaintingStyle.fill;

    // Draw abstract fruit and vegetable shapes

    // Apple shape
    final appleRect =
        Rect.fromLTWH(width * 0.1, height * 0.15, width * 0.2, width * 0.2);
    canvas.drawOval(appleRect, shapePaint);

    // Leaf
    final leafPath = Path()
      ..moveTo(width * 0.2, height * 0.15)
      ..quadraticBezierTo(
          width * 0.25, height * 0.1, width * 0.3, height * 0.13)
      ..quadraticBezierTo(
          width * 0.25, height * 0.17, width * 0.2, height * 0.15);
    canvas.drawPath(leafPath, shapePaint);

    // Carrot shape
    final carrotPath = Path()
      ..moveTo(width * 0.7, height * 0.25)
      ..lineTo(width * 0.8, height * 0.35)
      ..lineTo(width * 0.75, height * 0.4)
      ..lineTo(width * 0.65, height * 0.3)
      ..close();
    canvas.drawPath(carrotPath, shapePaint);

    // Banana shape
    final bananaPath = Path()
      ..moveTo(width * 0.15, height * 0.6)
      ..quadraticBezierTo(width * 0.3, height * 0.5, width * 0.4, height * 0.7)
      ..quadraticBezierTo(
          width * 0.35, height * 0.7, width * 0.2, height * 0.75)
      ..quadraticBezierTo(
          width * 0.1, height * 0.7, width * 0.15, height * 0.6);
    canvas.drawPath(bananaPath, shapePaint);

    // Orange circle
    canvas.drawCircle(
        Offset(width * 0.75, height * 0.65), width * 0.1, shapePaint);

    // Broccoli-like shape
    for (int i = 0; i < 5; i++) {
      final broccoliX = width * 0.6;
      final broccoliY = height * 0.8;
      final radius = width * 0.05;
      final angle = i * math.pi / 3;
      canvas.drawCircle(
          Offset(broccoliX + radius * math.cos(angle),
              broccoliY + radius * math.sin(angle)),
          radius * 0.7,
          shapePaint);
    }

    // Add some abstract shapes
    for (int i = 0; i < 10; i++) {
      final random = math.Random(i);
      final x = random.nextDouble() * width;
      final y = random.nextDouble() * height;
      final size = random.nextDouble() * width * 0.06 + width * 0.02;

      if (i % 3 == 0) {
        // Circles
        canvas.drawCircle(Offset(x, y), size, shapePaint);
      } else if (i % 3 == 1) {
        // Squares
        canvas.drawRect(Rect.fromLTWH(x, y, size, size), shapePaint);
      } else {
        // Triangles
        final trianglePath = Path()
          ..moveTo(x, y)
          ..lineTo(x + size, y + size)
          ..lineTo(x - size, y + size)
          ..close();
        canvas.drawPath(trianglePath, shapePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for the animated dots background
class DotsPainter extends CustomPainter {
  final double animationValue;

  DotsPainter({this.animationValue = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Paint for dots
    final dotPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Draw dots pattern
    final random = math.Random(42); // Fixed seed for consistent pattern
    for (int i = 0; i < 150; i++) {
      final x = random.nextDouble() * width;
      final y = random.nextDouble() * height;

      // Apply subtle animation movement
      final offsetX = math.sin(animationValue + i * 0.1) * 5;
      final offsetY = math.cos(animationValue + i * 0.1) * 5;

      // Random dot size
      final dotSize = random.nextDouble() * 4 + 1;

      canvas.drawCircle(Offset(x + offsetX, y + offsetY), dotSize, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant DotsPainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

// Enhanced ruler painter
class EnhancedRulerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.shade700
      ..strokeWidth = 1.5;

    // Draw a ruler-like pattern with better visual design
    for (int i = 0; i < 5; i++) {
      double height = i % 2 == 0 ? size.height * 0.75 : size.height * 0.5;
      double x = size.width * i / 4;
      canvas.drawLine(
        Offset(x, size.height - height),
        Offset(x, size.height),
        paint,
      );
    }

    // Add a horizontal line at the bottom
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      paint..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for drawing food icons pattern
class FoodPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // Draw simplified food icon shapes

    // Apple
    _drawApple(canvas, Offset(size.width * 0.2, size.height * 0.2),
        size.width * 0.1, paint);

    // Banana
    _drawBanana(canvas, Offset(size.width * 0.7, size.height * 0.3),
        size.width * 0.12, paint);

    // Carrot
    _drawCarrot(canvas, Offset(size.width * 0.3, size.height * 0.6),
        size.width * 0.1, paint);

    // Orange
    canvas.drawCircle(
        Offset(size.width * 0.7, size.height * 0.7), size.width * 0.08, paint);
  }

  void _drawApple(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path()
      ..addOval(
          Rect.fromCenter(center: center, width: size, height: size * 1.1));

    // Add stem
    path.moveTo(center.dx, center.dy - size * 0.55);
    path.lineTo(center.dx, center.dy - size * 0.7);

    canvas.drawPath(path, paint);
  }

  void _drawBanana(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path()
      ..moveTo(center.dx - size * 0.5, center.dy)
      ..quadraticBezierTo(
          center.dx, center.dy - size * 0.8, center.dx + size * 0.5, center.dy)
      ..quadraticBezierTo(
          center.dx, center.dy + size * 0.2, center.dx - size * 0.5, center.dy);

    canvas.drawPath(path, paint);
  }

  void _drawCarrot(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path()
      ..moveTo(center.dx, center.dy - size * 0.5)
      ..lineTo(center.dx + size * 0.3, center.dy + size * 0.5)
      ..lineTo(center.dx - size * 0.3, center.dy + size * 0.5)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
