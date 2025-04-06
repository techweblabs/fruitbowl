// lib/profile/components/weight_chart.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/brutal_decoration.dart';
import '../models/user_profile.dart';

class WeightChart extends StatelessWidget {
  final UserProfile user;

  const WeightChart({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    // Generate sample weight data
    final weightData = _generateSampleWeightData();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BrutalDecoration.brutalBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Weight Progress",
            style: GoogleFonts.bangers(
              fontSize: 20,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),

          // Chart period selector
          _buildChartPeriodSelector(),

          const SizedBox(height: 20),

          // Chart
          _buildWeightChart(context, weightData),

          const SizedBox(height: 16),

          // Chart legend
          _buildChartLegend(),
        ],
      ),
    );
  }

  Widget _buildChartPeriodSelector() {
    return Row(
      children: [
        _buildPeriodOption("1W", true),
        _buildPeriodOption("1M", false),
        _buildPeriodOption("3M", false),
        _buildPeriodOption("6M", false),
        _buildPeriodOption("1Y", false),
        _buildPeriodOption("All", false),
      ],
    );
  }

  Widget _buildPeriodOption(String label, bool isSelected) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey[400]!,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? const [BoxShadow(offset: Offset(1, 1), color: Colors.black)]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildWeightChart(BuildContext context, List<WeightEntry> data) {
    // Find min and max values
    final minWeight =
        data.map((e) => e.weight).reduce((a, b) => a < b ? a : b) - 1;
    final maxWeight =
        data.map((e) => e.weight).reduce((a, b) => a > b ? a : b) + 1;

    // Chart height
    const chartHeight = 200.0;

    // Chart width
    final chartWidth = MediaQuery.of(context).size.width - 80;

    return Container(
      height: chartHeight + 30,
      width: double.infinity,
      padding: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          // Y-axis (weight)
          Positioned(
            left: 0,
            top: 0,
            bottom: 30,
            width: 40,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${maxWeight.toStringAsFixed(1)} kg",
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  "${((minWeight + maxWeight) / 2).toStringAsFixed(1)} kg",
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  "${minWeight.toStringAsFixed(1)} kg",
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Chart content
          Positioned(
            left: 40,
            top: 0,
            right: 0,
            bottom: 0,
            child: Column(
              children: [
                // Chart area
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomPaint(
                      size: Size(chartWidth, chartHeight),
                      painter: WeightChartPainter(
                        data: data,
                        minWeight: minWeight,
                        maxWeight: maxWeight,
                        targetWeight: user.targetWeight,
                      ),
                    ),
                  ),
                ),

                // X-axis (dates)
                SizedBox(
                  height: 30,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (int i = 0; i < data.length; i += data.length ~/ 6)
                        if (i < data.length)
                          Text(
                            _formatDate(data[i].date),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem("Weight", Colors.blue),
        const SizedBox(width: 24),
        _buildLegendItem("Target", Colors.green),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 3,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}";
  }

  List<WeightEntry> _generateSampleWeightData() {
    // Generate sample weight data for last 30 days
    final now = DateTime.now();
    final data = <WeightEntry>[];

    // Start weight
    const startWeight = 90.5;

    // Current weight
    final currentWeight = user.weight;

    // Generate entries
    for (int i = 30; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);

      // Calculate weight using simple interpolation
      final progress = 1 - (i / 30);
      final weight = startWeight - (startWeight - currentWeight) * progress;

      // Add some random variation
      final randomVariation = (i % 2 == 0 ? 1 : -1) * (i % 3) * 0.1;

      data.add(WeightEntry(
        date: date,
        weight: weight + randomVariation,
      ));
    }

    return data;
  }
}

class WeightEntry {
  final DateTime date;
  final double weight;

  WeightEntry({
    required this.date,
    required this.weight,
  });
}

class WeightChartPainter extends CustomPainter {
  final List<WeightEntry> data;
  final double minWeight;
  final double maxWeight;
  final double targetWeight;

  WeightChartPainter({
    required this.data,
    required this.minWeight,
    required this.maxWeight,
    required this.targetWeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    // Setup
    final weightRange = maxWeight - minWeight;
    final width = size.width;
    final height = size.height;

    // Calculate x and y positions
    final List<Offset> points = [];

    for (int i = 0; i < data.length; i++) {
      final x = i / (data.length - 1) * width;
      final normalizedWeight = (data[i].weight - minWeight) / weightRange;
      final y = height - normalizedWeight * height;

      points.add(Offset(x, y));
    }

    // Draw target weight line
    final targetY =
        height - ((targetWeight - minWeight) / weightRange) * height;

    final targetPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Draw dashed line
    final dashWidth = 5.0;
    final dashSpace = 5.0;
    var startX = 0.0;

    while (startX < width) {
      canvas.drawLine(
        Offset(startX, targetY),
        Offset(startX + dashWidth, targetY),
        targetPaint,
      );
      startX += dashWidth + dashSpace;
    }

    // Draw target weight label
    final textPainter = TextPainter(
      text: TextSpan(
        text: "${targetWeight.toStringAsFixed(1)} kg",
        style: const TextStyle(
          color: Colors.green,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(width - textPainter.width - 4, targetY - textPainter.height - 2),
    );

    // Draw grid lines
    final gridPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Horizontal grid lines
    for (int i = 1; i < 4; i++) {
      final y = height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(width, y), gridPaint);
    }

    // Vertical grid lines
    for (int i = 1; i < 7; i++) {
      final x = width * (i / 7);
      canvas.drawLine(Offset(x, 0), Offset(x, height), gridPaint);
    }

    // Draw weight line
    final linePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      // Use a slight curve for a smoother line
      final prevPoint = points[i - 1];
      final currentPoint = points[i];

      // Control points for the curve
      final controlX = (prevPoint.dx + currentPoint.dx) / 2;

      path.cubicTo(
        controlX,
        prevPoint.dy,
        controlX,
        currentPoint.dy,
        currentPoint.dx,
        currentPoint.dy,
      );
    }

    canvas.drawPath(path, linePaint);

    // Draw points
    final pointPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final pointStrokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw only a few points to avoid clutter
    for (int i = 0; i < points.length; i += points.length ~/ 7) {
      if (i < points.length) {
        canvas.drawCircle(points[i], 4, pointPaint);
        canvas.drawCircle(points[i], 4, pointStrokePaint);
      }
    }

    // Always draw the last point
    canvas.drawCircle(points.last, 5, pointPaint);
    canvas.drawCircle(points.last, 5, pointStrokePaint);

    // Draw current weight label
    final weightTextPainter = TextPainter(
      text: TextSpan(
        text: "${data.last.weight.toStringAsFixed(1)} kg",
        style: const TextStyle(
          color: Colors.blue,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    weightTextPainter.layout();
    weightTextPainter.paint(
      canvas,
      Offset(
        width - weightTextPainter.width - 4,
        points.last.dy - weightTextPainter.height - 8,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
