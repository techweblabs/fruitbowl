// ignore_for_file: prefer_const_constructors

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:morphable_shape/morphable_shape.dart';

class JobListingScreen extends StatelessWidget {
  const JobListingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              // Reduce card size slightly to accommodate for the larger notch radius
              final cardSize = (width - 56) / 2;

              // Calculate the central area for the button
              final centerSize = 100.0;
              final offset = (width - centerSize) / 2;

              return Stack(
                alignment: Alignment.center,
                children: [
                  // Custom layout for cards around central button
                  SizedBox(
                    width: width,
                    height: width, // Making it square
                    child: Stack(
                      children: [
                        // Top left card
                        Positioned(
                          top: 0,
                          left: 0,
                          child: CurvedCornerCard(
                            size: cardSize,
                            curvePosition: CurvePosition.bottomRight,
                          ),
                        ),

                        // Top right card
                        Positioned(
                          top: 0,
                          right: 0,
                          child: CurvedCornerCard(
                            size: cardSize,
                            curvePosition: CurvePosition.bottomLeft,
                          ),
                        ),

                        // Bottom left card
                        Positioned(
                          bottom: 0,
                          left: 0,
                          child: CurvedCornerCard(
                            size: cardSize,
                            curvePosition: CurvePosition.topRight,
                          ),
                        ),

                        // Bottom right card
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CurvedCornerCard(
                            size: cardSize,
                            curvePosition: CurvePosition.topLeft,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // White background circle to mask any artifacts
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),

                  // Centered "See More" button
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Color(0xFF7667E5),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF7667E5).withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'See More',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

enum CurvePosition { topLeft, topRight, bottomLeft, bottomRight }

class CurvedCornerCard extends StatelessWidget {
  final double size;
  final CurvePosition curvePosition;

  const CurvedCornerCard({
    Key? key,
    required this.size,
    required this.curvePosition,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use ClipPath to ensure no content spills outside the curved shape
    return ClipPath(
      clipper: CardShapeClipper(curvePosition: curvePosition),
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: CurvedCornerPainter(curvePosition: curvePosition),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon with orange background
                Container(
                  height: 40,
                  width: 40,
                  padding: EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.computer,
                    size: 24,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 16),

                // Job Title
                Text(
                  'Data Entry',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),

                // Job Count
                Text(
                  '(450 Jobs)',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 22,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '4.2',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom clipper to ensure content doesn't exceed the card bounds
class CardShapeClipper extends CustomClipper<Path> {
  final CurvePosition curvePosition;

  CardShapeClipper({required this.curvePosition});

  @override
  Path getClip(Size size) {
    final double cornerRadius = 24.0;
    final double notchRadius = 48.0;

    final Path path = Path();

    switch (curvePosition) {
      case CurvePosition.bottomRight:
        // Start from bottom right in clockwise direction
        path.moveTo(size.width - cornerRadius, size.height);

        // Bottom edge
        path.lineTo(notchRadius, size.height);

        // Bottom left corner with standard radius
        path.arcToPoint(
          Offset(0, size.height - cornerRadius),
          radius: Radius.circular(cornerRadius),
          clockwise: true,
        );

        // Left edge
        path.lineTo(0, cornerRadius);

        // Top left corner
        path.arcToPoint(
          Offset(cornerRadius, 0),
          radius: Radius.circular(cornerRadius),
          clockwise: true,
        );

        // Top edge
        path.lineTo(size.width - cornerRadius, 0);

        // Top right corner
        path.arcToPoint(
          Offset(size.width, cornerRadius),
          radius: Radius.circular(cornerRadius),
          clockwise: true,
        );

        // Right edge
        path.lineTo(size.width, size.height - notchRadius);

        // Bottom right notch - THE KEY PART
        path.arcToPoint(
          Offset(size.width - notchRadius, size.height),
          radius: Radius.circular(notchRadius),
          clockwise: false, // This creates the inward curve
        );
        break;

      case CurvePosition.bottomLeft:
        // Start from bottom left in clockwise direction
        path.moveTo(notchRadius, size.height);

        // Draw the notch curve at bottom left
        path.arcToPoint(
          Offset(0, size.height - notchRadius),
          radius: Radius.circular(notchRadius),
          clockwise: false,
        );

        // Left edge
        path.lineTo(0, cornerRadius);

        // Top left corner
        path.arcToPoint(
          Offset(cornerRadius, 0),
          radius: Radius.circular(cornerRadius),
          clockwise: true,
        );

        // Top edge
        path.lineTo(size.width - cornerRadius, 0);

        // Top right corner
        path.arcToPoint(
          Offset(size.width, cornerRadius),
          radius: Radius.circular(cornerRadius),
          clockwise: true,
        );

        // Right edge
        path.lineTo(size.width, size.height - cornerRadius);

        // Bottom right corner
        path.arcToPoint(
          Offset(size.width - cornerRadius, size.height),
          radius: Radius.circular(cornerRadius),
          clockwise: true,
        );

        // Bottom edge
        path.lineTo(notchRadius, size.height);
        break;

      case CurvePosition.topRight:
        // Start from top-right corner with the notch
        path.moveTo(size.width - notchRadius, 0);

        // Create the notched inner corner
        path.arcToPoint(
          Offset(size.width, notchRadius),
          radius: Radius.circular(notchRadius),
          clockwise: false, // This creates the inward curve
        );

        // Right edge
        path.lineTo(size.width, size.height - cornerRadius);

        // Bottom right corner (standard rounded)
        path.arcToPoint(
          Offset(size.width - cornerRadius, size.height),
          radius: Radius.circular(cornerRadius),
          clockwise: true,
        );

        // Bottom edge
        path.lineTo(cornerRadius, size.height);

        // Bottom left corner (standard rounded)
        path.arcToPoint(
          Offset(0, size.height - cornerRadius),
          radius: Radius.circular(cornerRadius),
          clockwise: true,
        );

        // Left edge
        path.lineTo(0, cornerRadius);

        // Top left corner (standard rounded)
        path.arcToPoint(
          Offset(cornerRadius, 0),
          radius: Radius.circular(cornerRadius),
          clockwise: true,
        );

        // Top edge back to start
        path.lineTo(size.width - notchRadius, 0);
        break;

      case CurvePosition.topLeft:
        // Start from top left in clockwise direction
        path.moveTo(cornerRadius, 0);

        // Top edge
        path.lineTo(size.width - cornerRadius, 0);

        // Top right corner
        path.arcToPoint(
          Offset(size.width, cornerRadius),
          radius: Radius.circular(cornerRadius),
          clockwise: true,
        );

        // Right edge
        path.lineTo(size.width, size.height - cornerRadius);

        // Bottom right corner
        path.arcToPoint(
          Offset(size.width - cornerRadius, size.height),
          radius: Radius.circular(cornerRadius),
          clockwise: true,
        );

        // Bottom edge
        path.lineTo(cornerRadius, size.height);

        // Bottom left corner
        path.arcToPoint(
          Offset(0, size.height - cornerRadius),
          radius: Radius.circular(cornerRadius),
          clockwise: true,
        );

        // Left edge
        path.lineTo(0, notchRadius);

        // Draw the notch curve at top left
        path.arcToPoint(
          Offset(notchRadius, 0),
          radius: Radius.circular(notchRadius),
          clockwise: false,
        );
        break;
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

class CurvedCornerPainter extends CustomPainter {
  final CurvePosition curvePosition;

  CurvedCornerPainter({required this.curvePosition});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8);

    final double cornerRadius = 24.0;
    final double notchRadius = 48.0;

    final Path path = Path();

    switch (curvePosition) {
      case CurvePosition.bottomRight:
        // Start from bottom right in clockwise direction
        path.moveTo(size.width - cornerRadius, size.height);

        // Bottom edge
        path.lineTo(notchRadius, size.height);

        // Bottom left corner with standard radius
        path.arcToPoint(
          Offset(0, size.height - cornerRadius),
          radius: Radius.circular(cornerRadius),
          clockwise: true,
        );

        // Left edge
        path.lineTo(0, cornerRadius);

        // Top left corner
        path.arcToPoint(
          Offset(cornerRadius, 0),
          radius: Radius.circular(cornerRadius),
          clockwise: true,
        );

        // Top edge
        path.lineTo(size.width - cornerRadius, 0);

        // Top right corner
        path.arcToPoint(
          Offset(size.width, cornerRadius),
          radius: Radius.circular(cornerRadius),
          clockwise: true,
        );

        // Right edge
        path.lineTo(size.width, size.height - notchRadius);

        // Bottom right notch - THE KEY PART
        path.arcToPoint(
          Offset(size.width - notchRadius, size.height),
          radius: Radius.circular(notchRadius),
          clockwise: false, // This creates the inward curve
        );
        break;

      case CurvePosition.bottomLeft:
        // Start from bottom left in clockwise direction
        path.moveTo(notchRadius, size.height);

        // Draw the notch curve at bottom left
        path.arcToPoint(
          Offset(0, size.height - notchRadius),
          radius: Radius.circular(notchRadius),
          clockwise: false,
        );

        // Left edge
        path.lineTo(0, cornerRadius);

        // Top left corner
        path.arcToPoint(
          Offset(cornerRadius, 0),
          radius: Radius.circular(cornerRadius),
          clockwise: true,
        );

        // Top edge
        path.lineTo(size.width - cornerRadius, 0);

        // Top right corner
        path.arcToPoint(
          Offset(size.width, cornerRadius),
          radius: Radius.circular(cornerRadius),
          clockwise: true,
        );

        // Right edge
        path.lineTo(size.width, size.height - cornerRadius);

        // Bottom right corner
        path.arcToPoint(
          Offset(size.width - cornerRadius, size.height),
          radius: Radius.circular(cornerRadius),
          clockwise: true,
        );

        // Bottom edge
        path.lineTo(notchRadius, size.height);
        break;

      case CurvePosition.topRight:
        // Start from top-right corner with the notch
        path.moveTo(size.width - notchRadius, 0);

        // Create the notched inner corner
        path.arcToPoint(
          Offset(size.width, notchRadius),
          radius: Radius.circular(notchRadius),
          clockwise: false, // This creates the inward curve
        );

        // Right edge
        path.lineTo(size.width, size.height - cornerRadius);

        // Bottom right corner (standard rounded)
        path.arcToPoint(
          Offset(size.width - cornerRadius, size.height),
          radius: Radius.circular(cornerRadius),
          clockwise: true,
        );

        // Bottom edge
        path.lineTo(cornerRadius, size.height);

        // Bottom left corner (standard rounded)
        path.arcToPoint(
          Offset(0, size.height - cornerRadius),
          radius: Radius.circular(cornerRadius),
          clockwise: true,
        );

        // Left edge
        path.lineTo(0, cornerRadius);

        // Top left corner (standard rounded)
        path.arcToPoint(
          Offset(cornerRadius, 0),
          radius: Radius.circular(cornerRadius),
          clockwise: true,
        );

        // Top edge back to start
        path.lineTo(size.width - notchRadius, 0);
        break;

      case CurvePosition.topLeft:
        // Start from top left in clockwise direction
        path.moveTo(cornerRadius, 0);

        // Top edge
        path.lineTo(size.width - cornerRadius, 0);

        // Top right corner
        path.arcToPoint(
          Offset(size.width, cornerRadius),
          radius: Radius.circular(cornerRadius),
          clockwise: true,
        );

        // Right edge
        path.lineTo(size.width, size.height - cornerRadius);

        // Bottom right corner
        path.arcToPoint(
          Offset(size.width - cornerRadius, size.height),
          radius: Radius.circular(cornerRadius),
          clockwise: true,
        );

        // Bottom edge
        path.lineTo(cornerRadius, size.height);

        // Bottom left corner
        path.arcToPoint(
          Offset(0, size.height - cornerRadius),
          radius: Radius.circular(cornerRadius),
          clockwise: true,
        );

        // Left edge
        path.lineTo(0, notchRadius);

        // Draw the notch curve at top left
        path.arcToPoint(
          Offset(notchRadius, 0),
          radius: Radius.circular(notchRadius),
          clockwise: false,
        );
        break;
    }

    path.close();

    // Draw shadow first
    final Path shadowPath = Path()..addPath(path, Offset(0, 2));
    canvas.drawPath(shadowPath, shadowPaint);

    // Then draw the card
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
