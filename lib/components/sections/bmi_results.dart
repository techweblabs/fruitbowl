import 'package:flutter/material.dart';

class CompactBMIResultsSection extends StatelessWidget {
  final double bmiValue;
  final String bmiCategory;
  final double height; // in cm
  final double weight; // in kg

  const CompactBMIResultsSection(
      {Key? key,
      required this.bmiValue,
      required this.bmiCategory,
      required this.height,
      required this.weight})
      : super(key: key);

  // Get color based on BMI category
  Color get categoryColor {
    if (bmiCategory == 'Underweight') return Color(0xFF64B5F6); // Blue
    if (bmiCategory == 'Normal') return Color(0xFF81C784); // Green
    if (bmiCategory == 'Overweight') return Color(0xFFFFB74D); // Orange
    if (bmiCategory == 'Obese') return Color(0xFFE57373); // Red
    return Color(0xFF9575CD); // Default purple
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001) // perspective
        ..rotateX(0.01)
        ..rotateY(-0.01),
      alignment: Alignment.center,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF689), Color(0xFFFFD966)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: [
            // Main shadow
            const BoxShadow(
              color: Colors.black,
              offset: Offset(8, 8),
              blurRadius: 0,
            ),
            // Inner highlight
            BoxShadow(
              color: Colors.white.withOpacity(0.3),
              offset: const Offset(-2, -2),
              blurRadius: 0,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          children: [
            // Left section with gauge - enhanced 3D style
            Container(
              width: 160,
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFDBAC), Color(0xFFFFB171)],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(13),
                  bottomLeft: Radius.circular(13),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    offset: const Offset(2, 0),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // BMI Gauge with 3D effect
                  Center(
                    child: _buildBMIGauge(),
                  ),
                ],
              ),
            ),

            // Content on the right
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Heading with 3D text effect
                    _buildTitle(),

                    const SizedBox(height: 8),

                    // Stats row (height and weight)
                    _buildStatsRow(),

                    const SizedBox(height: 16),

                    // View details button
                    _buildViewDetailsButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBMIGauge() {
    return Container(
      width: 140,
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Colored circle background with 3D effect
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  categoryColor.withOpacity(0.7),
                  categoryColor.withOpacity(0.3),
                ],
                stops: [0.4, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: Offset(4, 4),
                ),
              ],
            ),
          ),

          // BMI value with 3D effect
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                bmiValue.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(2, 2),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),

              // BMI Category
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  bmiCategory.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: categoryColor,
                  ),
                ),
              ),
            ],
          ),

          // Circular progress indicator (white ring)
          SizedBox(
            width: 130,
            height: 130,
            child: CircularProgressIndicator(
              value: _getBMIProgress(),
              strokeWidth: 8,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Calculate progress percentage based on BMI value
  double _getBMIProgress() {
    // BMI scale from 16 to 40
    if (bmiValue < 16) return 0;
    if (bmiValue > 40) return 1;
    return (bmiValue - 16) / (40 - 16);
  }

  Widget _buildTitle() {
    return Stack(
      children: const [
        // Shadow text
        Text(
          'YOUR BMI RESULT',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            color: Colors.transparent,
            shadows: [
              Shadow(
                color: Colors.black45,
                offset: Offset(2, 2),
                blurRadius: 0,
              ),
            ],
          ),
        ),
        // Main text
        Text(
          'YOUR BMI RESULT',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        // Height stat
        _buildStatItem(Icons.height, 'Height', '${height.toInt()} cm'),

        SizedBox(width: 16),

        // Weight stat
        _buildStatItem(Icons.monitor_weight_outlined, 'Weight',
            '${weight.toStringAsFixed(1)} kg'),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.black54,
        ),
        SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildViewDetailsButton() {
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.0005)
        ..rotateX(0.005),
      alignment: Alignment.center,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7AFCFF), Color(0xFF56D0D5)],
          ),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'View Details',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 4),
            Icon(
              Icons.arrow_forward,
              size: 16,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}
