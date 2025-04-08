import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'dart:math' as math;

import '../../../providers/apiProvider.dart';
import '../../ProfielScreen/components/bmi_card.dart';
import '../../ProfielScreen/models/user_profile.dart';

class CheckBMIBody extends StatefulWidget {
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
          // Enhanced BMI Result Display
          // if (bmiResult.isNotEmpty)
          //   Container(
          //     width: double.infinity,
          //     padding: const EdgeInsets.all(16),
          //     decoration: BoxDecoration(
          //       gradient: LinearGradient(
          //         colors: _getBmiCategoryGradient(),
          //         begin: Alignment.topLeft,
          //         end: Alignment.bottomRight,
          //       ),
          //       borderRadius: BorderRadius.circular(12),
          //       border: Border.all(color: Colors.black, width: 3),
          //       boxShadow: const [
          //         BoxShadow(
          //             offset: Offset(4, 4), color: Colors.black, blurRadius: 0)
          //       ],
          //     ),
          //     child: Column(
          //       children: [
          //         const Text(
          //           'YOUR BMI',
          //           style: TextStyle(
          //             fontSize: 20,
          //             fontWeight: FontWeight.bold,
          //           ),
          //         ),
          //         const SizedBox(height: 12),
          //         Container(
          //           width: 120,
          //           height: 120,
          //           decoration: BoxDecoration(
          //             shape: BoxShape.circle,
          //             color: Colors.white,
          //             border: Border.all(color: Colors.black, width: 2),
          //             boxShadow: const [
          //               BoxShadow(offset: Offset(2, 2), color: Colors.black)
          //             ],
          //           ),
          //           child: Center(
          //             child: Text(
          //               bmiResult,
          //               style: const TextStyle(
          //                 fontSize: 36,
          //                 fontWeight: FontWeight.bold,
          //               ),
          //             ),
          //           ),
          //         ),
          //         const SizedBox(height: 12),
          //         Container(
          //           padding:
          //               const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          //           decoration: BoxDecoration(
          //             color: Colors.white.withOpacity(0.7),
          //             borderRadius: BorderRadius.circular(20),
          //             border: Border.all(color: Colors.black, width: 1),
          //           ),
          //           child: Text(
          //             bmiCategory,
          //             style: TextStyle(
          //               fontSize: 18,
          //               fontWeight: FontWeight.bold,
          //               color: _getBmiCategoryTextColor(),
          //             ),
          //           ),
          //         ),
          //         const SizedBox(height: 15),
          //         _buildBmiAdvice(),
          //       ],
          //     ),
          //   ),

          const SizedBox(height: 30),

          // Animated Calculate BMI Button
          AnimatedBuilder(
              animation: _buttonAnimation,
              builder: (context, child) {
                return GestureDetector(
                  onTap: () async {
                    Provider.of<apiProvider>(context, listen: false).gender =
                        selectedGender == "Male" ? 1 : 2;

                    Provider.of<apiProvider>(context, listen: false).height =
                        heightController.text;
                    Provider.of<apiProvider>(context, listen: false).weight =
                        weightController.text;
                    Provider.of<apiProvider>(context, listen: false).age =
                        ageController.text;
                    _animationController.forward();
                    // _calculateBMI();
                    var result =
                        await Provider.of<apiProvider>(context, listen: false)
                            .CheckBmi();
                    if (result['status'] == "OK") {
                      setState(() {
                        bmiResult = result['details']['BMI'];
                        bmiCategory =
                            result['details']['bmiCategory'].toString();
                        final UserProfile user = UserProfile(
                          name: result['details']['name'],
                          email: result['details']['email'],
                          profileImage: result['details']['profile_image'],
                          gender: result['details']['gender'] == "1"
                              ? "Male"
                              : "Female", // Added gender field

                          bmi: 28.4,
                          weight: 86.2,
                          height: 174,
                        );
                        BmiCard(
                          user: user,
                        );
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
                            : const Icon(Icons.calculate, color: Colors.white),
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

  Widget _buildBmiAdvice() {
    String advice = '';
    if (bmiCategory == '1') {
      advice = 'Consider increasing caloric intake';
    } else if (bmiCategory == '2') {
      advice = 'Great job! Maintain healthy habits';
    } else if (bmiCategory == '3') {
      advice = 'Consider moderate exercise & balanced diet';
    } else if (bmiCategory == '4') {
      advice = 'Consult a healthcare professional';
    }

    if (advice.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black.withOpacity(0.5), width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              advice,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
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

  void _calculateBMI() {
    setState(() {
      _isCalculating = true;
    });

    // Simulate a brief calculation time
    Future.delayed(const Duration(milliseconds: 500), () {
      final height = double.tryParse(heightController.text) ?? 0;
      final weight = double.tryParse(weightController.text) ?? 0;

      if (height <= 0 || weight <= 0) {
        setState(() {
          bmiResult = 'Invalid Input';
          bmiCategory = 'Please enter valid height and weight';
          _isCalculating = false;
        });
        return;
      }

      // BMI formula: weight (kg) / (height (m))²
      final heightInMeters = height / 100;
      final bmi = weight / (heightInMeters * heightInMeters);

      setState(() {
        bmiResult = bmi.toStringAsFixed(1);
        bmiCategory = _getBmiCategory(bmi);
        _isCalculating = false;
      });
    });
  }

  String _getBmiCategory(double bmi) {
    if (bmi < 18.5) {
      return 'Underweight';
    } else if (bmi < 25) {
      return 'Normal';
    } else if (bmi < 30) {
      return 'Overweight';
    } else {
      return 'Obese';
    }
  }

  Color _getBmiCategoryColor() {
    if (bmiCategory == '1') {
      return Colors.blue.shade200;
    } else if (bmiCategory == '2') {
      return Colors.green.shade200;
    } else if (bmiCategory == '3') {
      return Colors.orange.shade200;
    } else if (bmiCategory == '4') {
      return Colors.red.shade200;
    } else {
      return Colors.grey.shade200;
    }
  }

  Color _getBmiCategoryTextColor() {
    if (bmiCategory == '1') {
      return Colors.blue.shade900;
    } else if (bmiCategory == '2') {
      return Colors.green.shade900;
    } else if (bmiCategory == '3') {
      return Colors.orange.shade900;
    } else if (bmiCategory == '4') {
      return Colors.red.shade900;
    } else {
      return Colors.grey.shade900;
    }
  }

  List<Color> _getBmiCategoryGradient() {
    if (bmiCategory == '1') {
      return [Colors.blue.shade100, Colors.blue.shade300];
    } else if (bmiCategory == '2') {
      return [Colors.green.shade100, Colors.green.shade300];
    } else if (bmiCategory == '3') {
      return [Colors.orange.shade100, Colors.orange.shade300];
    } else if (bmiCategory == '4') {
      return [Colors.red.shade100, Colors.red.shade300];
    } else {
      return [Colors.grey.shade100, Colors.grey.shade300];
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
