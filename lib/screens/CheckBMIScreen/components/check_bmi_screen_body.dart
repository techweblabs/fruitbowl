import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../providers/apiProvider.dart';
import '../../ProfielScreen/models/user_profile.dart';

class CheckBMIBody extends StatefulWidget {
  const CheckBMIBody({super.key});

  @override
  _CheckBMIBodyState createState() => _CheckBMIBodyState();
}

class _CheckBMIBodyState extends State<CheckBMIBody>
    with SingleTickerProviderStateMixin {
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  String selectedGender = 'Male';
  String bmiResult = '';
  String bmiCategory = '';
  late AnimationController _animationController;
  late Animation<double> _buttonAnimation;
  bool _isCalculating = false;
  bool _showBmiCard = false;
  UserProfile? userProfile;
  List user = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _buttonAnimation = Tween<double>(begin: 0, end: 6).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    heightController.dispose();
    weightController.dispose();
    ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 5.h,
          ),
          // Fancy Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD600), Color(0xFFFFAB00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black, width: 3),
              boxShadow: const [
                BoxShadow(
                    offset: Offset(6, 6), color: Colors.black, blurRadius: 0)
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'BMI CHECKER',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Find your body mass index',
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSmallInfoBadge('Fast', Icons.speed),
                    const SizedBox(width: 12),
                    _buildSmallInfoBadge('Accurate', Icons.check_circle),
                    const SizedBox(width: 12),
                    _buildSmallInfoBadge('Simple', Icons.star),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Height Input with visual scale indicator
          _buildTextField(
            controller: heightController,
            label: 'HEIGHT (cm)',
            icon: Icons.height,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your height';
              }
              return null;
            },
            suffix: _buildHeightVisualization(),
          ),

          const SizedBox(height: 20),

          // Weight Input with visual scale indicator
          _buildTextField(
            controller: weightController,
            label: 'WEIGHT (kg)',
            icon: Icons.fitness_center,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your weight';
              }
              return null;
            },
            suffix: _buildWeightVisualization(),
          ),

          const SizedBox(height: 20),

          // Age Input with themed decoration
          _buildTextField(
            controller: ageController,
            label: 'AGE',
            icon: Icons.cake,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your age';
              }
              return null;
            },
            suffix: _buildAgeVisualization(),
          ),

          const SizedBox(height: 20),

          // Gender Selection with improved styling
          const Text(
            'GENDER',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black, width: 1.5),
              boxShadow: const [
                BoxShadow(offset: Offset(2, 2), color: Colors.black)
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedGender = 'Male';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: selectedGender == 'Male'
                            ? const LinearGradient(
                                colors: [Color(0xFFBBDEFB), Color(0xFF90CAF9)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              )
                            : null,
                        color: selectedGender == 'Male' ? null : Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          bottomLeft: Radius.circular(6),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.male,
                              color: selectedGender == 'Male'
                                  ? Colors.blue.shade800
                                  : Colors.blue.shade300,
                              size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'Male',
                            style: TextStyle(
                              fontWeight: selectedGender == 'Male'
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: selectedGender == 'Male'
                                  ? Colors.blue.shade800
                                  : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 1.5,
                  height: 46,
                  color: Colors.black,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedGender = 'Female';
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: selectedGender == 'Female'
                            ? const LinearGradient(
                                colors: [Color(0xFFF8BBD0), Color(0xFFF48FB1)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              )
                            : null,
                        color: selectedGender == 'Female' ? null : Colors.white,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(6),
                          bottomRight: Radius.circular(6),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.female,
                              color: selectedGender == 'Female'
                                  ? Colors.pink.shade800
                                  : Colors.pink.shade300,
                              size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'Female',
                            style: TextStyle(
                              fontWeight: selectedGender == 'Female'
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: selectedGender == 'Female'
                                  ? Colors.pink.shade800
                                  : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Show either BMI Card or Calculate Button
          _showBmiCard && userProfile != null
              ? BmiCard(
                  user: userProfile!,
                  bmiCategory: bmiCategory,
                  onRecalculate: () {
                    setState(() {
                      _showBmiCard = false;
                    });
                  },
                )
              : AnimatedBuilder(
                  animation: _buttonAnimation,
                  builder: (context, child) {
                    return GestureDetector(
                      onTap: () async {
                        setState(() {
                          _isCalculating = true;
                        });

                        // Set the provider values.
                        final apiProv =
                            Provider.of<apiProvider>(context, listen: false);
                        apiProv.gender = selectedGender == "Male" ? 1 : 2;
                        apiProv.height = heightController.text;
                        apiProv.weight = weightController.text;
                        apiProv.age = ageController.text;

                        // Start the button animation.
                        _animationController.forward();

                        try {
                          // Execute the BMI check.
                          var result = await apiProv.CheckBmi();

                          // Validate the result.
                          if (result == null ||
                              !result.containsKey('status') ||
                              result['status'] == "NOK") {
                            // You could show an error message to the user.
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    "Error retrieving BMI data. Please try again."),
                              ),
                            );
                          } else if (result['status'] == "OK") {
                            // Handle the successful response.
                            setState(() {
                              bmiResult = result['details']['BMI'];
                              bmiCategory =
                                  result['details']['bmiCategory'].toString();
                              userProfile = UserProfile(
                                name: result['details']['name'],
                                email: result['details']['email'],
                                profileImage: result['details']
                                    ['profile_image'],
                                gender: result['details']['gender'] == "1"
                                    ? "Male"
                                    : "Female",
                                bmi: result['details']['BMI'],
                                weight: double.tryParse(result['details']
                                            ['weight']
                                        .toString()) ??
                                    0,
                                height: double.tryParse(result['details']
                                            ['height']
                                        .toString()) ??
                                    0,
                              );
                              _showBmiCard = true;
                            });
                          }
                        } catch (e) {
                          // Handle any unexpected errors.
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text("An unexpected error occurred: $e")),
                          );
                        } finally {
                          // Ensure the loading indicator is removed.
                          setState(() {
                            _isCalculating = false;
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF4CAF50).withOpacity(0.9),
                              const Color(0xFF2E7D32).withOpacity(0.9),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black, width: 2),
                          boxShadow: [
                            BoxShadow(
                              offset: Offset(4 + _buttonAnimation.value,
                                  4 + _buttonAnimation.value),
                              color: Colors.black,
                              blurRadius: 0,
                            )
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _isCalculating
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 3),
                                  )
                                : const Icon(Icons.calculate,
                                    color: Colors.white),
                            const SizedBox(width: 12),
                            const Text(
                              'CHECK BMI',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

          const SizedBox(height: 30),

          // Footer with attribution
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black, width: 1),
            ),
            child: const Column(
              children: [
                Text(
                  'BMI is just one measure of health',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4),
                Text(
                  'Always consult with healthcare professionals',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallInfoBadge(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeightVisualization() {
    return Container(
      height: 24,
      width: 30,
      margin: const EdgeInsets.only(right: 8),
      child: CustomPaint(
        painter: RulerPainter(),
      ),
    );
  }

  Widget _buildWeightVisualization() {
    return Container(
      height: 24,
      width: 30,
      margin: const EdgeInsets.only(right: 8),
      child: const Icon(
        Icons.monitor_weight_outlined,
        color: Colors.grey,
        size: 20,
      ),
    );
  }

  Widget _buildAgeVisualization() {
    return Container(
      height: 24,
      width: 30,
      margin: const EdgeInsets.only(right: 8),
      child: const Icon(
        Icons.calendar_month,
        color: Colors.grey,
        size: 20,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.black87),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black, width: 1.5),
            boxShadow: const [
              BoxShadow(offset: Offset(2, 2), color: Colors.black)
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              prefixIcon: Icon(icon),
              suffixIcon: suffix,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Implementation of BMI Card Widget
class BmiCard extends StatelessWidget {
  final UserProfile user;
  final String bmiCategory;
  final VoidCallback onRecalculate;

  const BmiCard({
    Key? key,
    required this.user,
    required this.bmiCategory,
    required this.onRecalculate,
  }) : super(key: key);

  Color _getBmiCategoryColor() {
    switch (bmiCategory.toLowerCase()) {
      case 'underweight':
        return Colors.blue.shade300;
      case 'normal':
        return Colors.green.shade400;
      case 'overweight':
        return Colors.orange.shade300;
      case 'obese':
        return Colors.red.shade300;
      default:
        return Colors.grey.shade400;
    }
  }

  IconData _getBmiCategoryIcon() {
    switch (bmiCategory.toLowerCase()) {
      case 'underweight':
        return Icons.arrow_downward;
      case 'normal':
        return Icons.check_circle;
      case 'overweight':
        return Icons.arrow_upward;
      case 'obese':
        return Icons.warning;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getBmiCategoryColor().withOpacity(0.6),
            _getBmiCategoryColor(),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(offset: Offset(5, 5), color: Colors.black, blurRadius: 0)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header with user info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
              border: const Border(
                bottom: BorderSide(color: Colors.black, width: 2),
              ),
            ),
            child: Row(
              children: [
                // Profile Image or Avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: user.gender == "Male"
                        ? Colors.blue.shade100
                        : Colors.pink.shade100,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                  child: Center(
                    child: Icon(
                      user.gender == "Male" ? Icons.male : Icons.female,
                      color: user.gender == "Male"
                          ? Colors.blue.shade800
                          : Colors.pink.shade800,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // User Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            '${user.height.toStringAsFixed(0)} cm',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${user.weight.toStringAsFixed(1)} kg',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // BMI Result Display
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getBmiCategoryIcon(),
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      bmiCategory.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'BMI:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        user.bmi.toString(),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // BMI Category Description
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getBmiDescription(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Recalculate Button
          GestureDetector(
            onTap: onRecalculate,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
                border: Border(
                  top: BorderSide(color: Colors.black, width: 2),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh),
                  SizedBox(width: 8),
                  Text(
                    'RECALCULATE',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getBmiDescription() {
    switch (bmiCategory.toLowerCase()) {
      case 'underweight':
        return 'You are underweight. Consider consulting with a healthcare provider about healthy ways to gain weight.';
      case 'normal':
        return 'You have a normal body weight. Good job maintaining a healthy weight!';
      case 'overweight':
        return 'You are overweight. Consider making lifestyle changes including diet and exercise.';
      case 'obese':
        return 'You are in the obese category. It\'s recommended to consult with a healthcare provider.';
      default:
        return 'BMI is just one measure of health. Consider consulting with a healthcare provider for personalized advice.';
    }
  }
}

class RulerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1.0;

    // Draw a ruler-like pattern
    for (int i = 0; i < 5; i++) {
      double height = i % 2 == 0 ? size.height * 0.6 : size.height * 0.4;
      double x = size.width * i / 4;
      canvas.drawLine(
          Offset(x, size.height - height), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
