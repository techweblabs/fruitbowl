// lib/profile/components/bmi_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/brutal_decoration.dart';
import '../models/user_profile.dart';

class BmiCard extends StatelessWidget {
  final UserProfile user;

  const BmiCard({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BrutalDecoration.brutalBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Health Metrics",
                style: GoogleFonts.bangers(
                  fontSize: 20,
                  letterSpacing: 1.2,
                ),
              ),
              // GestureDetector(
              //   onTap: () {
              //     Twl.navigateToScreenAnimated(
              //         HealthDetailsPage(
              //           user: user,
              //         ),
              //         context: context);
              //     // Navigate to detailed health metrics
              //   },
              //   child: Container(
              //     padding: const EdgeInsets.symmetric(
              //       horizontal: 10,
              //       vertical: 4,
              //     ),
              //     decoration: BoxDecoration(
              //       color: Colors.blue[50],
              //       borderRadius: BorderRadius.circular(20),
              //       border: Border.all(color: Colors.blue[700]!, width: 1.5),
              //       boxShadow: [
              //         BoxShadow(
              //           color: Colors.blue[700]!.withOpacity(0.4),
              //           offset: const Offset(2, 2),
              //           blurRadius: 0,
              //         ),
              //       ],
              //     ),
              //     child: Text(
              //       "View More",
              //       style: TextStyle(
              //         fontSize: 12,
              //         fontWeight: FontWeight.bold,
              //         color: Colors.blue[700],
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
          const SizedBox(height: 16),

          // BMI display
          _buildBmiDisplay(context),
          const SizedBox(height: 20),

          // Basic metrics
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricItem("Height", "${user.height} cm", Icons.height),
              _buildMetricItem(
                  "Weight", "${user.weight} kg", Icons.monitor_weight),
              // _buildMetricItem("Goal", "${user.targetWeight} kg", Icons.flag),
            ],
          ),
          const SizedBox(height: 16),
          // const Divider(),
          // const SizedBox(height: 16),

          // Goal progress
          // _buildGoalProgress(),
        ],
      ),
    );
  }

  Widget _buildBmiDisplay(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Row(
        children: [
          // BMI gauge
          Container(
            width: 120,
            height: 120,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
              boxShadow: const [
                BoxShadow(offset: Offset(3, 3), color: Colors.black),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Gauge background
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const SweepGradient(
                      colors: [
                        Colors.blue,
                        Colors.green,
                        Colors.yellow,
                        Colors.orange,
                        Colors.red,
                        Colors.purple,
                      ],
                      stops: [0.0, 0.25, 0.4, 0.6, 0.8, 1.0],
                      startAngle: 3.14 * 1.2,
                      endAngle: 3.14 * 3.2,
                    ),
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                ),

                // White center
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 1),
                  ),
                ),

                // BMI value
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      user.bmi.toStringAsFixed(1),
                      style: GoogleFonts.bangers(
                        fontSize: 28,
                        color: user.bmiColor,
                      ),
                    ),
                    Text(
                      "BMI",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                // Indicator needle
                Transform.rotate(
                  angle: 3.14 * 1.2 + (user.bmi / 50 * 2 * 3.14),
                  child: Container(
                    height: 50,
                    width: 2,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    margin: const EdgeInsets.only(bottom: 50),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // BMI explanation
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: user.bmiColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: user.bmiColor),
                      ),
                      child: Text(
                        user.bmiCategory,
                        style: TextStyle(
                          color: user.bmiColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "Ideal Weight Range:",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  user.idealWeightRange,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getBmiRecommendation(),
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black),
            boxShadow: const [
              BoxShadow(offset: Offset(2, 2), color: Colors.black),
            ],
          ),
          child: Icon(icon, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildGoalProgress() {
    final goalText = user.weightDifference > 0
        ? "Need to lose ${user.weightDifference.toStringAsFixed(1)} kg"
        : user.weightDifference < 0
            ? "Need to gain ${user.weightDifference.abs().toStringAsFixed(1)} kg"
            : "You've reached your goal weight!";

    final progressPercentage = user.targetWeight == user.weight
        ? 1.0
        : (1 - (user.weightDifference.abs() / (user.weight * 0.15)))
            .clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Goal Progress",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              "${(progressPercentage * 100).toInt()}%",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.green[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 16,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progressPercentage,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(7),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          goalText,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Estimated time to goal: ${user.estimatedTimeToGoal}",
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // Navigate to weight tracking
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.yellow[600],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black, width: 1.5),
                    boxShadow: const [
                      BoxShadow(offset: Offset(2, 2), color: Colors.black),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_chart, size: 16),
                      SizedBox(width: 6),
                      Text(
                        "Update Weight",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // Navigate to goal settings
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black, width: 1.5),
                    boxShadow: const [
                      BoxShadow(offset: Offset(2, 2), color: Colors.black),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit, size: 16),
                      SizedBox(width: 6),
                      Text(
                        "Change Goal",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getBmiRecommendation() {
    if (user.bmi < 18.5) {
      return "Your BMI indicates you're underweight. Focus on nutritious meals to gain weight healthily.";
    } else if (user.bmi < 25) {
      return "Your BMI is in the healthy range. Maintain your balanced diet and regular physical activity.";
    } else if (user.bmi < 30) {
      return "Your BMI indicates you're overweight. Our meal plans can help you achieve a healthier weight.";
    } else {
      return "Your BMI indicates obesity. Our specially designed meal plans can support your weight loss journey.";
    }
  }
}
