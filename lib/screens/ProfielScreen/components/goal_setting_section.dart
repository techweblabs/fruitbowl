// lib/profile/components/goal_setting_section.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/brutal_decoration.dart';
import '../models/user_profile.dart';

class GoalSettingSection extends StatefulWidget {
  final UserProfile user;

  const GoalSettingSection({
    super.key,
    required this.user,
  });

  @override
  State<GoalSettingSection> createState() => _GoalSettingState();
}

class _GoalSettingState extends State<GoalSettingSection> {
  late String _selectedGoalType;
  late double _targetWeight;
  late double _weeklyGoal;
  late String _activityLevel;

  @override
  void initState() {
    super.initState();
    _selectedGoalType = widget.user.goalType;
    _targetWeight = widget.user.targetWeight;
    _weeklyGoal = widget.user.weeklyGoal;
    _activityLevel = widget.user.activityLevel;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGoalTypeCard(),
          const SizedBox(height: 20),
          _buildTargetWeightCard(),
          const SizedBox(height: 20),
          _buildWeeklyGoalCard(),
          const SizedBox(height: 20),
          _buildActivityLevelCard(),
          const SizedBox(height: 20),
          _buildSummaryCard(),
          const SizedBox(height: 20),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildGoalTypeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BrutalDecoration.brutalBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Goal Type",
            style: GoogleFonts.bangers(
              fontSize: 20,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildGoalTypeOption(
                  'Weight Loss',
                  Icons.trending_down,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGoalTypeOption(
                  'Maintenance',
                  Icons.balance,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGoalTypeOption(
                  'Weight Gain',
                  Icons.trending_up,
                  Colors.orange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Goal type description
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[400]!),
            ),
            child: Text(
              _getGoalTypeDescription(_selectedGoalType),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalTypeOption(String goalType, IconData icon, Color color) {
    final isSelected = _selectedGoalType == goalType;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGoalType = goalType;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey[400]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    offset: const Offset(3, 3),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(
              goalType,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetWeightCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BrutalDecoration.brutalBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Target Weight",
            style: GoogleFonts.bangers(
              fontSize: 20,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black),
                    boxShadow: const [
                      BoxShadow(offset: Offset(2, 2), color: Colors.black)
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Current Weight",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        "${widget.user.weight} kg",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  _selectedGoalType == 'Weight Loss'
                      ? Icons.arrow_downward
                      : _selectedGoalType == 'Weight Gain'
                          ? Icons.arrow_upward
                          : Icons.arrow_forward,
                  color: _selectedGoalType == 'Weight Loss'
                      ? Colors.blue
                      : _selectedGoalType == 'Weight Gain'
                          ? Colors.orange
                          : Colors.green,
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.yellow[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black),
                    boxShadow: const [
                      BoxShadow(offset: Offset(2, 2), color: Colors.black)
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Target Weight",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (_targetWeight > 30) {
                                  _targetWeight -= 0.5;
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black),
                              ),
                              child: const Icon(Icons.remove, size: 16),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              "$_targetWeight kg",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (_targetWeight < 250) {
                                  _targetWeight += 0.5;
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black),
                              ),
                              child: const Icon(Icons.add, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Weight difference info
          Row(
            children: [
              Icon(
                widget.user.weightDifference > 0
                    ? Icons.trending_down
                    : Icons.trending_up,
                size: 16,
                color: widget.user.weightDifference > 0
                    ? Colors.blue
                    : Colors.orange,
              ),
              const SizedBox(width: 4),
              Text(
                widget.user.weightDifference > 0
                    ? "Need to lose ${widget.user.weightDifference.toStringAsFixed(1)} kg"
                    : widget.user.weightDifference < 0
                        ? "Need to gain ${widget.user.weightDifference.abs().toStringAsFixed(1)} kg"
                        : "Already at target weight",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Target weight info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 16),
                    const SizedBox(width: 6),
                    const Text(
                      "Target Weight Info",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "A healthy weight range for your height (${widget.user.height} cm) is approximately ${widget.user.idealWeightRange}",
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

  Widget _buildWeeklyGoalCard() {
    // Only show weekly goal card for weight loss/gain goals
    if (_selectedGoalType == 'Maintenance') {
      return Container(); // Return empty container for maintenance goal
    }

    final isWeightLoss = _selectedGoalType == 'Weight Loss';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BrutalDecoration.brutalBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Weekly Goal",
            style: GoogleFonts.bangers(
              fontSize: 20,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isWeightLoss
                ? "How much weight do you want to lose per week?"
                : "How much weight do you want to gain per week?",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 16),

          // Weekly goal slider
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "0.25 kg",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: _weeklyGoal == 0.25
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  Text(
                    "0.5 kg",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: _weeklyGoal == 0.5
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  Text(
                    "0.75 kg",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: _weeklyGoal == 0.75
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  Text(
                    "1.0 kg",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: _weeklyGoal == 1.0
                          ? FontWeight.bold
                          : FontWeight.normal,
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
                    // Weekly goal segments
                    Row(
                      children: [
                        for (var i = 0; i < 4; i++)
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: i <= (_weeklyGoal * 4 - 1).round()
                                    ? (isWeightLoss
                                            ? Colors.blue
                                            : Colors.orange)
                                        .withOpacity(0.2 + (i * 0.2))
                                    : Colors.transparent,
                                borderRadius: BorderRadius.horizontal(
                                  left: i == 0
                                      ? const Radius.circular(15)
                                      : Radius.zero,
                                  right: i == 3
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
                      left: (MediaQuery.of(context).size.width - 92) *
                          ((_weeklyGoal - 0.25) / 0.75),
                      top: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onHorizontalDragUpdate: (details) {
                          // Update weekly goal based on drag position
                          final RenderBox box =
                              context.findRenderObject() as RenderBox;
                          final width = box.size.width - 92;
                          final position =
                              details.localPosition.dx.clamp(0, width);
                          final newValue = 0.25 + (position / width * 0.75);

                          setState(() {
                            // Round to nearest 0.25
                            _weeklyGoal = (newValue * 4).round() / 4;
                          });
                        },
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: isWeightLoss ? Colors.blue : Colors.orange,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 2),
                            boxShadow: const [
                              BoxShadow(
                                  offset: Offset(1, 1), color: Colors.black),
                            ],
                          ),
                          child: Icon(
                            isWeightLoss
                                ? Icons.trending_down
                                : Icons.trending_up,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Weekly goal info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[400]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.grey[700],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isWeightLoss ? "Weight Loss Rate" : "Weight Gain Rate",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  isWeightLoss
                      ? "A moderate weight loss of 0.5-1 kg per week is generally considered safe and sustainable."
                      : "A moderate weight gain of 0.25-0.5 kg per week is generally considered healthy for muscle growth.",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Estimated time to reach goal: ${_getEstimatedTime()}",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[900],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityLevelCard() {
    final activityLevels = [
      'Sedentary',
      'Light',
      'Moderate',
      'Very Active',
    ];

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

          // Activity level options
          ...activityLevels.map((level) => _buildActivityOption(level)),

          const SizedBox(height: 16),

          // Activity level description
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[400]!),
            ),
            child: Text(
              _getActivityDescription(_activityLevel),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityOption(String level) {
    final isSelected = _activityLevel == level;

    return GestureDetector(
      onTap: () {
        setState(() {
          _activityLevel = level;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[400]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    offset: const Offset(2, 2),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey[400]!,
                  width: 2,
                ),
                color: isSelected ? Colors.blue : Colors.transparent,
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              level,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.yellow[50],
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(offset: Offset(4, 4), color: Colors.black)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.summarize, color: Colors.yellow[800]),
              const SizedBox(width: 8),
              Text(
                "Goal Summary",
                style: GoogleFonts.bangers(
                  fontSize: 20,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Summary items
          _buildSummaryItem(
            "Goal Type",
            _selectedGoalType,
            _selectedGoalType == 'Weight Loss'
                ? Icons.trending_down
                : _selectedGoalType == 'Weight Gain'
                    ? Icons.trending_up
                    : Icons.balance,
          ),
          const SizedBox(height: 8),
          _buildSummaryItem(
            "Current Weight",
            "${widget.user.weight} kg",
            Icons.monitor_weight,
          ),
          const SizedBox(height: 8),
          _buildSummaryItem(
            "Target Weight",
            "$_targetWeight kg",
            Icons.flag,
          ),
          if (_selectedGoalType != 'Maintenance') ...[
            const SizedBox(height: 8),
            _buildSummaryItem(
              "Weekly Goal",
              "$_weeklyGoal kg per week",
              Icons.speed,
            ),
          ],
          const SizedBox(height: 8),
          _buildSummaryItem(
            "Activity Level",
            _activityLevel,
            Icons.directions_run,
          ),
          const SizedBox(height: 8),
          _buildSummaryItem(
            "Estimated Time",
            _getEstimatedTime(),
            Icons.access_time,
          ),

          const SizedBox(height: 16),

          // Important info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[400]!),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey[700]),
                    const SizedBox(width: 8),
                    const Text(
                      "Important Information",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "These goals are used to personalize your meal plans and nutritional recommendations. Remember that weight management is a journey. Consistency and sustainable habits are key to long-term success.",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black),
          ),
          child: Icon(icon, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
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
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: () {
        // Save goal settings
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Health goals updated successfully"),
            backgroundColor: Colors.green,
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.green[600],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: const [
            BoxShadow(offset: Offset(4, 4), color: Colors.black)
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text(
              "Save Health Goals",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGoalTypeDescription(String goalType) {
    switch (goalType) {
      case 'Weight Loss':
        return "Weight loss focuses on losing body fat while preserving lean muscle mass. This is achieved through a calorie deficit, which means consuming fewer calories than you burn.";
      case 'Weight Gain':
        return "Weight gain focuses on building muscle and increasing body weight in a healthy way. This is achieved through a calorie surplus combined with strength training.";
      case 'Maintenance':
        return "Maintenance focuses on keeping your current weight stable. This is achieved by consuming roughly the same number of calories as you burn each day.";
      default:
        return "";
    }
  }

  String _getActivityDescription(String level) {
    switch (level) {
      case 'Sedentary':
        return "Sedentary lifestyle involves minimal physical activity, mostly sitting throughout the day with little to no deliberate exercise.";
      case 'Light':
        return "Light activity includes light exercise or sports 1-3 days per week, or a job that involves some walking or standing.";
      case 'Moderate':
        return "Moderate activity includes moderate exercise or sports 3-5 days per week, or a job with significant physical demands.";
      case 'Very Active':
        return "Very active lifestyle includes hard exercise or sports 6-7 days per week, or a very physically demanding job combined with additional exercise.";
      default:
        return "";
    }
  }

  String _getEstimatedTime() {
    if (_selectedGoalType == 'Maintenance') {
      return "Ongoing";
    }

    // Check if weekly goal is set
    if (_weeklyGoal <= 0) {
      return "N/A";
    }

    // Calculate weight difference
    final weightDifference = (_targetWeight - widget.user.weight).abs();

    // Calculate weeks needed
    final weeks = weightDifference / _weeklyGoal;

    // Format result
    if (weeks < 1) {
      return "Less than 1 week";
    } else if (weeks < 4) {
      return "${weeks.round()} weeks";
    } else {
      final months = (weeks / 4).ceil();
      return "$months months";
    }
  }
}
