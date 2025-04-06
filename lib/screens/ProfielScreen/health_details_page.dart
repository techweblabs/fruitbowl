// lib/profile/health_details_page.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_starter_kit/utils/helpers/twl.dart';

import '../../utils/brutal_decoration.dart';
import 'models/user_profile.dart';
import 'components/weight_chart.dart';
import 'components/goal_setting_section.dart';

class HealthDetailsPage extends StatefulWidget {
  final UserProfile user;

  const HealthDetailsPage({
    super.key,
    required this.user,
  });

  @override
  State<HealthDetailsPage> createState() => _HealthDetailsPageState();
}

class _HealthDetailsPageState extends State<HealthDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        title: Text(
          "HEALTH DETAILS",
          style: GoogleFonts.bangers(
            fontSize: 28,
            color: Colors.black,
            letterSpacing: 2,
          ),
        ),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BrutalDecoration.brutalBox(),
            child: const Icon(Icons.arrow_back, color: Colors.black),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: Colors.yellow[600],
          indicatorWeight: 3.0,
          tabs: const [
            Tab(text: "OVERVIEW"),
            Tab(text: "PROGRESS"),
            Tab(text: "GOALS"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildProgressTab(),
          GoalSettingSection(user: widget.user),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BMI Card
          _buildBmiDetailsCard(),
          const SizedBox(height: 20),

          // Health Metrics
          _buildHealthMetricsCard(),
          const SizedBox(height: 20),

          // Activity Level
          _buildActivityLevelCard(),
          const SizedBox(height: 20),

          // Nutritional Recommendations
          _buildNutritionalRecommendationsCard(),
        ],
      ),
    );
  }

  Widget _buildBmiDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BrutalDecoration.brutalBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "BMI Details",
            style: GoogleFonts.bangers(
              fontSize: 20,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user.bmi.toStringAsFixed(1),
                    style: GoogleFonts.bangers(
                      fontSize: 40,
                      color: widget.user.bmiColor,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: widget.user.bmiColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: widget.user.bmiColor),
                    ),
                    child: Text(
                      widget.user.bmiCategory,
                      style: TextStyle(
                        color: widget.user.bmiColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 2),
                  boxShadow: const [
                    BoxShadow(offset: Offset(3, 3), color: Colors.black)
                  ],
                ),
                child: Center(
                  child: _buildBmiChart(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // BMI Scale explanation
          Text(
            "BMI Scale",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          _buildBmiScale(),

          const SizedBox(height: 16),

          // BMI Details text
          Text(
            _getBmiExplanation(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBmiChart() {
    // This would be a more advanced visualization in a real app
    return CustomPaint(
      size: const Size(100, 100),
      painter: BMIGaugePainter(
        bmi: widget.user.bmi,
      ),
    );
  }

  Widget _buildBmiScale() {
    return Container(
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(7),
                  bottomLeft: Radius.circular(7),
                ),
              ),
              child: const Center(
                child: Text(
                  "Underweight",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: 1,
            color: Colors.black,
            height: double.infinity,
          ),
          Expanded(
            flex: 6,
            child: Container(
              color: Colors.green,
              child: const Center(
                child: Text(
                  "Normal",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: 1,
            color: Colors.black,
            height: double.infinity,
          ),
          Expanded(
            flex: 5,
            child: Container(
              color: Colors.orange,
              child: const Center(
                child: Text(
                  "Overweight",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: 1,
            color: Colors.black,
            height: double.infinity,
          ),
          Expanded(
            flex: 5,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(7),
                  bottomRight: Radius.circular(7),
                ),
              ),
              child: const Center(
                child: Text(
                  "Obese",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthMetricsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BrutalDecoration.brutalBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Health Metrics",
            style: GoogleFonts.bangers(
              fontSize: 20,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),

          // Metrics grid
          Row(
            children: [
              Expanded(
                child: _buildMetricBox(
                  label: "Weight",
                  value: "${widget.user.weight} kg",
                  icon: Icons.monitor_weight,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricBox(
                  label: "Height",
                  value: "${widget.user.height} cm",
                  icon: Icons.height,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricBox(
                  label: "Target Weight",
                  value: "${widget.user.targetWeight} kg",
                  icon: Icons.flag,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricBox(
                  label: "Weekly Goal",
                  value: "${widget.user.weeklyGoal} kg",
                  icon: Icons.speed,
                  color: Colors.purple,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          _buildUpdateMeasurementsButton(),
        ],
      ),
    );
  }

  Widget _buildMetricBox({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            offset: const Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
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
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateMeasurementsButton() {
    return GestureDetector(
      onTap: () {
        // Show measurement update modal
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.yellow[600],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black, width: 1.5),
          boxShadow: const [
            BoxShadow(offset: Offset(3, 3), color: Colors.black)
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit, size: 18),
            SizedBox(width: 8),
            Text(
              "Update Measurements",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityLevelCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BrutalDecoration.brutalBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Activity Level",
            style: GoogleFonts.bangers(
              fontSize: 20,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          _buildActivityLevelSelector(),
          const SizedBox(height: 16),
          Text(
            _getActivityDescription(widget.user.activityLevel),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityLevelSelector() {
    final activityLevels = [
      'Sedentary',
      'Light',
      'Moderate',
      'Very Active',
    ];

    final currentIndex = activityLevels.indexOf(widget.user.activityLevel);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var level in activityLevels)
              Text(
                level.split(' ').first,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: level == widget.user.activityLevel
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: level == widget.user.activityLevel
                      ? Colors.black
                      : Colors.grey[600],
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 30,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.black),
          ),
          child: Stack(
            children: [
              // Activity level segments
              Row(
                children: [
                  for (var i = 0; i < activityLevels.length; i++)
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: i <= currentIndex
                              ? Colors.blue.withOpacity(0.2 + (i * 0.2))
                              : Colors.transparent,
                          borderRadius: BorderRadius.horizontal(
                            left: i == 0
                                ? const Radius.circular(15)
                                : Radius.zero,
                            right: i == activityLevels.length - 1
                                ? const Radius.circular(15)
                                : Radius.zero,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // Current indicator
              Positioned(
                left: (MediaQuery.of(context).size.width - 72) *
                    (currentIndex / (activityLevels.length - 1)),
                top: 0,
                bottom: 0,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2),
                    boxShadow: const [
                      BoxShadow(offset: Offset(1, 1), color: Colors.black),
                    ],
                  ),
                  child: const Icon(
                    Icons.directions_run,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionalRecommendationsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BrutalDecoration.brutalBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Nutritional Recommendations",
            style: GoogleFonts.bangers(
              fontSize: 20,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),

          // Macronutrient breakdown
          _buildMacronutrientBreakdown(),
          const SizedBox(height: 16),

          // Daily calorie recommendation
          _buildCalorieRecommendation(),
          const SizedBox(height: 16),

          // Food recommendations based on goals
          _buildFoodRecommendations(),
        ],
      ),
    );
  }

  Widget _buildMacronutrientBreakdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Recommended Macronutrient Breakdown",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 4,
              child: _buildMacroBar(
                label: "Protein",
                percentage: 30,
                color: Colors.red,
              ),
            ),
            Expanded(
              flex: 4,
              child: _buildMacroBar(
                label: "Carbs",
                percentage: 40,
                color: Colors.blue,
              ),
            ),
            Expanded(
              flex: 3,
              child: _buildMacroBar(
                label: "Fats",
                percentage: 30,
                color: Colors.yellow[700]!,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMacroBar({
    required String label,
    required int percentage,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          height: 80,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: 80 * (percentage / 100),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(7),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "$percentage%",
          style: const TextStyle(
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildCalorieRecommendation() {
    // Simple calorie calculation based on user metrics
    // This is a simplified example and not medically accurate
    final bmr = widget.user.gender == 'Male'
        ? 88.362 +
            (13.397 * widget.user.weight) +
            (4.799 * widget.user.height) -
            (5.677 * 30) // Assuming age 30
        : 447.593 +
            (9.247 * widget.user.weight) +
            (3.098 * widget.user.height) -
            (4.330 * 30); // Assuming age 30

    double activityMultiplier;

    switch (widget.user.activityLevel) {
      case 'Sedentary':
        activityMultiplier = 1.2;
        break;
      case 'Light':
        activityMultiplier = 1.375;
        break;
      case 'Moderate':
        activityMultiplier = 1.55;
        break;
      case 'Very Active':
        activityMultiplier = 1.725;
        break;
      default:
        activityMultiplier = 1.2;
    }

    final maintenanceCalories = bmr * activityMultiplier;

    // Adjust based on goal
    int goalAdjustment;

    switch (widget.user.goalType) {
      case 'Weight Loss':
        goalAdjustment = -500; // 500 calorie deficit
        break;
      case 'Weight Gain':
        goalAdjustment = 500; // 500 calorie surplus
        break;
      default:
        goalAdjustment = 0;
    }

    final recommendedCalories = maintenanceCalories + goalAdjustment;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[800]!, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.green[800]!.withOpacity(0.3),
            offset: const Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Recommended Daily Calories",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                recommendedCalories.toInt().toString(),
                style: GoogleFonts.bangers(
                  fontSize: 36,
                  color: Colors.green[800],
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  "calories/day",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green[800],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getCalorieDescription(),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFoodRecommendations() {
    final recommendations = _getFoodRecommendations();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Recommended Foods",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: recommendations.map((food) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green[700]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green[700]!.withOpacity(0.2),
                    offset: const Offset(1, 1),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Text(
                food,
                style: TextStyle(
                  color: Colors.green[800],
                  fontSize: 12,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildProgressTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weight progress chart
          WeightChart(user: widget.user),
          const SizedBox(height: 20),

          // Progress stats
          _buildProgressStatsCard(),
          const SizedBox(height: 20),

          // Add weight entry
          _buildAddWeightEntryCard(),
        ],
      ),
    );
  }

  Widget _buildProgressStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BrutalDecoration.brutalBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Progress Statistics",
            style: GoogleFonts.bangers(
              fontSize: 20,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),

          // Stats grid
          Row(
            children: [
              Expanded(
                child: _buildStatBox(
                  label: "Starting Weight",
                  value: "90.5 kg",
                  trend: "",
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatBox(
                  label: "Current Weight",
                  value: "${widget.user.weight} kg",
                  trend: "-4.3 kg",
                  trendDown: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatBox(
                  label: "Goal Weight",
                  value: "${widget.user.targetWeight} kg",
                  trend: "",
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatBox(
                  label: "Remaining",
                  value:
                      "${widget.user.weightDifference.abs().toStringAsFixed(1)} kg",
                  trend:
                      "${((widget.user.weight - widget.user.targetWeight) / (90.5 - widget.user.targetWeight) * 100).toInt()}%",
                  trendDown: false,
                  showProgressBar: true,
                  progress: 1 -
                      (widget.user.weightDifference.abs() /
                          (90.5 - widget.user.targetWeight)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox({
    required String label,
    required String value,
    required String trend,
    bool trendDown = false,
    bool showProgressBar = false,
    double progress = 0,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black),
        boxShadow: const [BoxShadow(offset: Offset(2, 2), color: Colors.black)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          if (trend.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  trendDown ? Icons.arrow_downward : Icons.arrow_upward,
                  size: 12,
                  color: trendDown ? Colors.green : Colors.blue,
                ),
                const SizedBox(width: 4),
                Text(
                  trend,
                  style: TextStyle(
                    fontSize: 12,
                    color: trendDown ? Colors.green : Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
          if (showProgressBar) ...[
            const SizedBox(height: 8),
            Container(
              height: 6,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAddWeightEntryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BrutalDecoration.brutalBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Track Your Progress",
            style: GoogleFonts.bangers(
              fontSize: 20,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Current Weight",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black),
                        boxShadow: const [
                          BoxShadow(offset: Offset(2, 2), color: Colors.black)
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: "Enter weight",
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const Text(
                            "kg",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Date",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black),
                        boxShadow: const [
                          BoxShadow(offset: Offset(2, 2), color: Colors.black)
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          const Icon(Icons.calendar_today, size: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          GestureDetector(
            onTap: () {
              // Save weight entry
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.yellow[600],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black, width: 1.5),
                boxShadow: const [
                  BoxShadow(offset: Offset(3, 3), color: Colors.black)
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_chart, size: 18),
                  SizedBox(width: 8),
                  Text(
                    "Save Weight Entry",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Progress tips
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[700]!),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_outline,
                        color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      "Progress Tip",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "For the most accurate tracking, weigh yourself at the same time each day, preferably in the morning before eating.",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getBmiExplanation() {
    if (widget.user.bmi < 18.5) {
      return "A BMI under 18.5 indicates you are underweight. This may be associated with certain health issues. Consider consulting with a healthcare provider for personalized advice on gaining weight in a healthy way.";
    } else if (widget.user.bmi < 25) {
      return "A BMI between 18.5 and 24.9 indicates you are at a healthy weight for your height. By maintaining a healthy weight, you're reducing your risk of serious health problems.";
    } else if (widget.user.bmi < 30) {
      return "A BMI between 25 and 29.9 indicates you are overweight. Being overweight may increase your risk of health problems. Small changes to your diet and physical activity can help you achieve a healthier weight.";
    } else {
      return "A BMI of 30 or higher indicates obesity. Obesity is associated with a higher risk of serious health problems. Consider consulting with a healthcare provider for personalized advice on losing weight in a healthy way.";
    }
  }

  String _getActivityDescription(String level) {
    switch (level) {
      case 'Sedentary':
        return "Your activity level is classified as Sedentary, which typically means minimal or no exercise and spending most of the day sitting (e.g., desk job with no additional physical activity).";
      case 'Light':
        return "Your activity level is classified as Light, which typically means light exercise or sports 1-3 days per week, or a job that involves some walking or standing.";
      case 'Moderate':
        return "Your activity level is classified as Moderate, which typically means moderate exercise or sports 3-5 days per week, or a job with significant physical demands.";
      case 'Very Active':
        return "Your activity level is classified as Very Active, which typically means hard exercise or sports 6-7 days per week, or a very physically demanding job combined with additional exercise.";
      default:
        return "";
    }
  }

  String _getCalorieDescription() {
    switch (widget.user.goalType) {
      case 'Weight Loss':
        return "This calorie target creates a moderate deficit to support gradual, sustainable weight loss.";
      case 'Weight Gain':
        return "This calorie target creates a moderate surplus to support muscle growth and healthy weight gain.";
      default: // Maintenance
        return "This calorie target is designed to maintain your current weight.";
    }
  }

  List<String> _getFoodRecommendations() {
    if (widget.user.goalType == 'Weight Loss') {
      return [
        'Lean Protein',
        'Non-starchy Vegetables',
        'Berries',
        'Greek Yogurt',
        'Eggs',
        'Leafy Greens',
        'Lentils',
        'Quinoa',
        'Fish',
        'Avocado',
      ];
    } else if (widget.user.goalType == 'Weight Gain') {
      return [
        'Nuts & Seeds',
        'Nut Butters',
        'Oats',
        'Whole Grain Bread',
        'Brown Rice',
        'Salmon',
        'Lean Meats',
        'Sweet Potatoes',
        'Dairy Products',
        'Dried Fruits',
      ];
    } else {
      // Maintenance
      return [
        'Whole Grains',
        'Lean Proteins',
        'Healthy Fats',
        'Fruits',
        'Vegetables',
        'Legumes',
        'Low-fat Dairy',
        'Nuts',
        'Seeds',
        'Fish',
      ];
    }
  }
}

// Custom painter for BMI gauge
class BMIGaugePainter extends CustomPainter {
  final double bmi;

  BMIGaugePainter({required this.bmi});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw gauge background
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0;

    // Gauge colors
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.orange,
      Colors.red,
    ];

    // Calculate angles
    const startAngle = -150 * (3.14 / 180); // -150 degrees in radians
    const sweepAngle = 300 * (3.14 / 180); // 300 degrees in radians

    // Draw colored arcs
    for (int i = 0; i < colors.length; i++) {
      final segmentAngle = sweepAngle / colors.length;
      final segmentStart = startAngle + (i * segmentAngle);

      paint.color = colors[i];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 5),
        segmentStart,
        segmentAngle,
        false,
        paint,
      );
    }

    // Calculate needle position
    final needleAngle =
        startAngle + (min(max(bmi, 10), 40) - 10) / 30 * sweepAngle;

    // Draw needle
    final needlePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawLine(
      center,
      Offset(
        center.dx + cos(needleAngle) * (radius - 15),
        center.dy + sin(needleAngle) * (radius - 15),
      ),
      needlePaint,
    );

    // Draw center circle
    final centerPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 5, centerPaint);

    // Draw bmi value
    final textPainter = TextPainter(
      text: TextSpan(
        text: bmi.toStringAsFixed(1),
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy + radius / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
