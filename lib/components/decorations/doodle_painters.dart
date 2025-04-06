import 'dart:math';
import 'package:flutter/material.dart';
import '../../utils/color_extensions.dart';

// Custom painter for doodle background with fruits and clouds
class DoodlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint linePaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    final Paint fruitPaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    // Draw more cloud doodles
    _drawCloud(canvas, Offset(size.width * 0.1, size.height * 0.15),
        size.width * 0.2, linePaint);
    _drawCloud(canvas, Offset(size.width * 0.7, size.height * 0.1),
        size.width * 0.15, linePaint);
    _drawCloud(canvas, Offset(size.width * 0.5, size.height * 0.75),
        size.width * 0.25, linePaint);
    _drawCloud(canvas, Offset(size.width * 0.25, size.height * 0.4),
        size.width * 0.18, linePaint);
    _drawCloud(canvas, Offset(size.width * 0.8, size.height * 0.5),
        size.width * 0.17, linePaint);
    _drawCloud(canvas, Offset(size.width * 0.4, size.height * 0.2),
        size.width * 0.12, linePaint);

    // Draw apple doodles
    _drawApple(
        canvas, Offset(size.width * 0.15, size.height * 0.6), fruitPaint);
    _drawApple(
        canvas, Offset(size.width * 0.85, size.height * 0.3), fruitPaint);

    // Draw banana doodles
    _drawBanana(
        canvas, Offset(size.width * 0.75, size.height * 0.7), fruitPaint);
    _drawBanana(
        canvas, Offset(size.width * 0.2, size.height * 0.8), fruitPaint);

    // Draw orange/circle fruit doodles
    _drawOrange(
        canvas, Offset(size.width * 0.25, size.height * 0.3), fruitPaint);
    _drawOrange(
        canvas, Offset(size.width * 0.6, size.height * 0.5), fruitPaint);
    _drawOrange(
        canvas, Offset(size.width * 0.85, size.height * 0.8), fruitPaint);

    // Draw some random decorative lines
    for (int i = 0; i < 12; i++) {
      final double startX = Random().nextDouble() * size.width;
      final double startY = Random().nextDouble() * size.height;
      final double length = Random().nextDouble() * 30 + 10;
      final double angle = Random().nextDouble() * 2 * pi;

      canvas.drawLine(
        Offset(startX, startY),
        Offset(startX + cos(angle) * length, startY + sin(angle) * length),
        linePaint,
      );
    }
  }

  void _drawCloud(Canvas canvas, Offset position, double size, Paint paint) {
    final Path path = Path();

    // Main cloud body
    path.addOval(Rect.fromCenter(
      center: position,
      width: size,
      height: size * 0.6,
    ));

    // Cloud bumps
    path.addOval(Rect.fromCenter(
      center: Offset(position.dx - size * 0.3, position.dy),
      width: size * 0.5,
      height: size * 0.5,
    ));

    path.addOval(Rect.fromCenter(
      center: Offset(position.dx + size * 0.3, position.dy),
      width: size * 0.6,
      height: size * 0.4,
    ));

    path.addOval(Rect.fromCenter(
      center: Offset(position.dx, position.dy - size * 0.2),
      width: size * 0.7,
      height: size * 0.5,
    ));

    canvas.drawPath(path, paint);
  }

  void _drawApple(Canvas canvas, Offset position, Paint paint) {
    final double size = 20.0;

    // Apple body
    canvas.drawCircle(position, size, paint);

    // Apple stem
    canvas.drawLine(
      Offset(position.dx, position.dy - size),
      Offset(position.dx, position.dy - size - 10),
      paint,
    );

    // Apple leaf
    final Path leafPath = Path();
    leafPath.moveTo(position.dx, position.dy - size - 5);
    leafPath.quadraticBezierTo(
      position.dx + 8,
      position.dy - size - 15,
      position.dx + 15,
      position.dy - size - 10,
    );
    leafPath.quadraticBezierTo(
      position.dx + 5,
      position.dy - size - 5,
      position.dx,
      position.dy - size - 5,
    );

    canvas.drawPath(leafPath, paint);
  }

  void _drawBanana(Canvas canvas, Offset position, Paint paint) {
    final Path path = Path();
    final double size = 25.0;

    path.moveTo(position.dx - size * 0.5, position.dy - size * 0.2);
    path.quadraticBezierTo(
      position.dx,
      position.dy - size,
      position.dx + size * 0.5,
      position.dy - size * 0.2,
    );
    path.quadraticBezierTo(
      position.dx + size * 0.7,
      position.dy + size * 0.5,
      position.dx,
      position.dy + size * 0.6,
    );
    path.quadraticBezierTo(
      position.dx - size * 0.7,
      position.dy + size * 0.5,
      position.dx - size * 0.5,
      position.dy - size * 0.2,
    );

    canvas.drawPath(path, paint);
  }

  void _drawOrange(Canvas canvas, Offset position, Paint paint) {
    final double size = 15.0;

    // Orange circle
    canvas.drawCircle(position, size, paint);

    // Orange segments lines
    for (int i = 0; i < 4; i++) {
      final double angle = i * pi / 4;
      canvas.drawLine(
        position,
        Offset(
          position.dx + cos(angle) * size,
          position.dy + sin(angle) * size,
        ),
        paint,
      );
    }

    // Small leaf at top
    final Path leafPath = Path();
    leafPath.moveTo(position.dx, position.dy - size);
    leafPath.quadraticBezierTo(
      position.dx + 5,
      position.dy - size - 8,
      position.dx + 10,
      position.dy - size - 5,
    );
    leafPath.quadraticBezierTo(
      position.dx + 5,
      position.dy - size - 3,
      position.dx,
      position.dy - size,
    );

    canvas.drawPath(leafPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for health and BMI doodles
class HealthDoodlePainter extends CustomPainter {
  final bool shadow;
  final Offset offset;

  HealthDoodlePainter({this.shadow = false, this.offset = Offset.zero});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = shadow ? Colors.black.withOpacity(0.2) : Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Apply offset for shadow effect if needed
    canvas.save();
    if (shadow) {
      canvas.translate(offset.dx, offset.dy);
    }

    // Draw a simple scale/weight icon
    _drawScale(canvas, Offset(size.width * 0.5, size.height * 0.3),
        size.width * 0.3, paint);

    // Draw an apple for healthy eating
    _drawApple(canvas, Offset(size.width * 0.3, size.height * 0.7), 15, paint);

    // Draw a dumbbell for exercise
    _drawDumbbell(canvas, Offset(size.width * 0.7, size.height * 0.6),
        size.width * 0.2, paint);

    // Draw a measuring tape
    _drawMeasuringTape(canvas, Offset(size.width * 0.2, size.height * 0.5),
        size.width * 0.25, paint);

    // Draw BMI indicators
    _drawBMIIndicator(canvas, Offset(size.width * 0.7, size.height * 0.3),
        size.width * 0.15, paint);

    canvas.restore();
  }

  void _drawScale(Canvas canvas, Offset position, double size, Paint paint) {
    // Base of scale
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: position, width: size, height: size * 0.4),
        Radius.circular(size * 0.1),
      ),
      paint,
    );

    // Top platform
    canvas.drawLine(
      Offset(position.dx - size * 0.4, position.dy - size * 0.3),
      Offset(position.dx + size * 0.4, position.dy - size * 0.3),
      paint,
    );

    // Display screen
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(position.dx, position.dy),
          width: size * 0.6,
          height: size * 0.2,
        ),
        Radius.circular(size * 0.05),
      ),
      paint,
    );
  }

  void _drawApple(Canvas canvas, Offset position, double size, Paint paint) {
    // Apple body
    canvas.drawCircle(position, size, paint);

    // Apple stem
    canvas.drawLine(
      Offset(position.dx, position.dy - size),
      Offset(position.dx, position.dy - size - 6),
      paint,
    );

    // Apple leaf
    final Path leafPath = Path();
    leafPath.moveTo(position.dx, position.dy - size - 3);
    leafPath.quadraticBezierTo(
      position.dx + 6,
      position.dy - size - 8,
      position.dx + 10,
      position.dy - size - 6,
    );
    leafPath.quadraticBezierTo(
      position.dx + 4,
      position.dy - size - 3,
      position.dx,
      position.dy - size - 3,
    );

    canvas.drawPath(leafPath, paint);
  }

  void _drawDumbbell(Canvas canvas, Offset position, double size, Paint paint) {
    // Left weight
    canvas.drawCircle(
      Offset(position.dx - size * 0.4, position.dy),
      size * 0.2,
      paint,
    );

    // Right weight
    canvas.drawCircle(
      Offset(position.dx + size * 0.4, position.dy),
      size * 0.2,
      paint,
    );

    // Bar connecting weights
    canvas.drawLine(
      Offset(position.dx - size * 0.3, position.dy),
      Offset(position.dx + size * 0.3, position.dy),
      paint,
    );
  }

  void _drawMeasuringTape(
      Canvas canvas, Offset position, double size, Paint paint) {
    // Tape shape
    final Path path = Path();
    path.addArc(
      Rect.fromCenter(center: position, width: size, height: size),
      -0.3,
      -pi * 1.4,
    );

    canvas.drawPath(path, paint);

    // Add small marks for measurement
    for (int i = 0; i < 6; i++) {
      double angle = -0.3 - (i * pi * 1.4 / 5);
      double x1 = position.dx + (size / 2) * cos(angle);
      double y1 = position.dy + (size / 2) * sin(angle);
      double x2 = position.dx + (size / 2 - 5) * cos(angle);
      double y2 = position.dy + (size / 2 - 5) * sin(angle);

      canvas.drawLine(
        Offset(x1, y1),
        Offset(x2, y2),
        paint,
      );
    }
  }

  void _drawBMIIndicator(
      Canvas canvas, Offset position, double size, Paint paint) {
    // Draw a simple BMI indicator chart
    final rect = Rect.fromCenter(
      center: position,
      width: size,
      height: size * 0.5,
    );

    // Draw the outline
    canvas.drawRect(rect, paint);

    // Draw the dividing lines for different BMI categories
    canvas.drawLine(
      Offset(position.dx - size * 0.25, position.dy - size * 0.25),
      Offset(position.dx - size * 0.25, position.dy + size * 0.25),
      paint,
    );

    canvas.drawLine(
      Offset(position.dx, position.dy - size * 0.25),
      Offset(position.dx, position.dy + size * 0.25),
      paint,
    );

    canvas.drawLine(
      Offset(position.dx + size * 0.25, position.dy - size * 0.25),
      Offset(position.dx + size * 0.25, position.dy + size * 0.25),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for fruit doodles in the card background
class FruitDoodlePainter extends CustomPainter {
  final Color baseColor;

  FruitDoodlePainter(this.baseColor);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = baseColor.darker(20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    // Draw decorative fruit shapes
    _drawSimpleFruits(canvas, size, paint);

    // Add some decorative dots
    _drawDecorativeDots(canvas, size, paint);
  }

  void _drawSimpleFruits(Canvas canvas, Size size, Paint paint) {
    // Draw a few simple fruit shapes

    // Apple in bottom left
    _drawSimpleApple(canvas, Offset(size.width * 0.15, size.height * 0.85),
        size.width * 0.06, paint);

    // Banana in top right
    _drawSimpleBanana(canvas, Offset(size.width * 0.85, size.height * 0.25),
        size.width * 0.1, paint);

    // Orange/circle in middle left
    _drawSimpleOrange(canvas, Offset(size.width * 0.15, size.height * 0.45),
        size.width * 0.05, paint);

    // Small berry top left
    canvas.drawCircle(
      Offset(size.width * 0.25, size.height * 0.2),
      size.width * 0.02,
      paint,
    );

    // Another small berry next to it
    canvas.drawCircle(
      Offset(size.width * 0.35, size.height * 0.15),
      size.width * 0.025,
      paint,
    );
  }

  void _drawDecorativeDots(Canvas canvas, Size size, Paint paint) {
    // Draw a few decorative dots
    final Random random = Random(42); // Fixed seed for consistency

    for (int i = 0; i < 12; i++) {
      final double x = random.nextDouble() * size.width;
      final double y = random.nextDouble() * size.height;

      if ((x > size.width * 0.3 && x < size.width * 0.7) ||
          (y > size.height * 0.3 && y < size.height * 0.7)) {
        // Avoid the center area where the bowl image would be
        canvas.drawCircle(
          Offset(x, y),
          random.nextDouble() * 2 + 1,
          paint,
        );
      }
    }
  }

  void _drawSimpleApple(
      Canvas canvas, Offset position, double size, Paint paint) {
    // Simple apple shape
    canvas.drawCircle(position, size, paint);

    // Apple stem
    canvas.drawLine(
      Offset(position.dx, position.dy - size),
      Offset(position.dx, position.dy - size - size * 0.5),
      paint,
    );

    // Simple leaf
    final Path leafPath = Path();
    leafPath.moveTo(position.dx, position.dy - size - size * 0.3);
    leafPath.quadraticBezierTo(
      position.dx + size * 0.5,
      position.dy - size - size * 0.7,
      position.dx + size * 0.7,
      position.dy - size - size * 0.4,
    );
    leafPath.quadraticBezierTo(
      position.dx + size * 0.3,
      position.dy - size - size * 0.3,
      position.dx,
      position.dy - size - size * 0.3,
    );

    canvas.drawPath(leafPath, paint);
  }

  void _drawSimpleBanana(
      Canvas canvas, Offset position, double size, Paint paint) {
    final Path path = Path();

    path.moveTo(position.dx - size * 0.5, position.dy);
    path.quadraticBezierTo(
      position.dx,
      position.dy - size * 0.7,
      position.dx + size * 0.5,
      position.dy,
    );
    path.quadraticBezierTo(
      position.dx,
      position.dy + size * 0.3,
      position.dx - size * 0.5,
      position.dy,
    );

    canvas.drawPath(path, paint);
  }

  void _drawSimpleOrange(
      Canvas canvas, Offset position, double size, Paint paint) {
    // Circle for orange
    canvas.drawCircle(position, size, paint);

    // A few lines for segments
    for (int i = 0; i < 3; i++) {
      final double angle = i * pi / 3;
      canvas.drawLine(
        position,
        Offset(
          position.dx + cos(angle) * size,
          position.dy + sin(angle) * size,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
