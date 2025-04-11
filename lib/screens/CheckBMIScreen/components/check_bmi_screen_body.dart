import 'package:flutter/material.dart';
import 'package:flutter_starter_kit/components/loaders/card_loading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../components/decorations/background_painters.dart';
import '../../../components/decorations/doodle_painters.dart';
import '../../../providers/apiProvider.dart';
import '../../../providers/firestore_api_provider.dart';
import '../../ProfielScreen/components/bmi_card.dart';
import '../../ProfielScreen/models/user_profile.dart';
// Update the import to match your project structure.

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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
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
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFB2EBF2), // Medium light cyan
                  Color.fromARGB(255, 187, 214, 188), // Soft green
                  Color(0xFF90CAF9), // Light steel blue
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
            child: SafeArea(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 5.h),
                            const BMICheckerWidget(),
                            const SizedBox(height: 30),
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
                                border:
                                    Border.all(color: Colors.black, width: 1.5),
                                boxShadow: const [
                                  BoxShadow(
                                      offset: Offset(2, 2), color: Colors.black)
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Male option
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedGender = 'Male';
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        decoration: BoxDecoration(
                                          gradient: selectedGender == 'Male'
                                              ? const LinearGradient(
                                                  colors: [
                                                    Color(0xFFBBDEFB),
                                                    Color(0xFF90CAF9)
                                                  ],
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                )
                                              : null,
                                          color: selectedGender == 'Male'
                                              ? null
                                              : Colors.white,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(6),
                                            bottomLeft: Radius.circular(6),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.male,
                                                color: selectedGender == 'Male'
                                                    ? Colors.blue.shade800
                                                    : Colors.blue.shade300,
                                                size: 22),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Male',
                                              style: TextStyle(
                                                fontWeight:
                                                    selectedGender == 'Male'
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                color: selectedGender == 'Male'
                                                    ? Colors.blue.shade800
                                                    : Colors.black54,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Divider
                                  Container(
                                    width: 1.5,
                                    height: 46,
                                    color: Colors.black,
                                  ),

                                  // Female option
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedGender = 'Female';
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        decoration: BoxDecoration(
                                          gradient: selectedGender == 'Female'
                                              ? const LinearGradient(
                                                  colors: [
                                                    Color(0xFFF8BBD0),
                                                    Color(0xFFF48FB1)
                                                  ],
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                )
                                              : null,
                                          color: selectedGender == 'Female'
                                              ? null
                                              : Colors.white,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.female,
                                                color:
                                                    selectedGender == 'Female'
                                                        ? Colors.pink.shade800
                                                        : Colors.pink.shade300,
                                                size: 22),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Female',
                                              style: TextStyle(
                                                fontWeight:
                                                    selectedGender == 'Female'
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                color:
                                                    selectedGender == 'Female'
                                                        ? Colors.pink.shade800
                                                        : Colors.black54,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Divider
                                  Container(
                                    width: 1.5,
                                    height: 46,
                                    color: Colors.black,
                                  ),

                                  // Other option
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedGender = 'Other';
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        decoration: BoxDecoration(
                                          gradient: selectedGender == 'Other'
                                              ? const LinearGradient(
                                                  colors: [
                                                    Color(0xFFE0E0E0),
                                                    Color(0xFFBDBDBD)
                                                  ],
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                )
                                              : null,
                                          color: selectedGender == 'Other'
                                              ? null
                                              : Colors.white,
                                          borderRadius: const BorderRadius.only(
                                            topRight: Radius.circular(6),
                                            bottomRight: Radius.circular(6),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.person,
                                                color: selectedGender == 'Other'
                                                    ? Colors.purple.shade800
                                                    : Colors.purple.shade300,
                                                size: 22),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Other',
                                              style: TextStyle(
                                                fontWeight:
                                                    selectedGender == 'Other'
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                color: selectedGender == 'Other'
                                                    ? Colors.purple.shade800
                                                    : Colors.black54,
                                                fontSize: 13,
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
                            _showBmiCard && userProfile != null
                                ? Bmicard(user: userProfile!)
                                : AnimatedBuilder(
                                    animation: _buttonAnimation,
                                    builder: (context, child) {
                                      return GestureDetector(
                                        onTap: () async {
                                          if (_formKey.currentState!
                                                  .validate() &&
                                              selectedGender != null) {
                                            setState(() {
                                              _isCalculating = true;
                                            });

                                            final apiProv =
                                                Provider.of<apiProvider>(
                                                    context,
                                                    listen: false);
                                            apiProv.gender = selectedGender ==
                                                    "Male"
                                                ? 1
                                                : (selectedGender == "Female"
                                                    ? 2
                                                    : 3); // 3 for "Other"
                                            apiProv.height =
                                                heightController.text;
                                            apiProv.weight =
                                                weightController.text;
                                            apiProv.age = ageController.text;

                                            _animationController.forward();

                                            try {
                                              var result =
                                                  await apiProv.CheckBmi(context);

                                              if (result == null ||
                                                  !result
                                                      .containsKey('status') ||
                                                  result['status'] == "NOK") {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        "Error retrieving BMI data. Please try again."),
                                                  ),
                                                );
                                              } else if (result['status'] ==
                                                  "OK") {
                                                setState(() {
                                                  bmiResult =
                                                      result['details']['BMI'];
                                                  bmiCategory =
                                                      result['details']
                                                              ['bmiCategory']
                                                          .toString();
                                                  userProfile = UserProfile(
                                                    age: result['details']
                                                        ['age'],
                                                    phoneNumber:
                                                        result['details']
                                                                ['contactNo']
                                                            .toString(),
                                                    name: result['details']
                                                        ['name'],
                                                    email: result['details']
                                                        ['email'],
                                                    profileImage:
                                                        result['details']
                                                            ['profile_image'],
                                                    gender: result['details']
                                                                ['gender'] ==
                                                            "1"
                                                        ? "Male"
                                                        : (result['details'][
                                                                    'gender'] ==
                                                                "2"
                                                            ? "Female"
                                                            : "Other"),
                                                    bmi: double.tryParse(
                                                            result['details']
                                                                    ['BMI']
                                                                .toString()) ??
                                                        0,
                                                    weight: double.tryParse(
                                                            result['details']
                                                                    ['weight']
                                                                .toString()) ??
                                                        0,
                                                    height: double.tryParse(
                                                            result['details']
                                                                    ['height']
                                                                .toString()) ??
                                                        0,
                                                  );
                                                  _showBmiCard = true;
                                                });
                                              }
                                            } catch (e) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        "An unexpected error occurred: $e")),
                                              );
                                            } finally {
                                              setState(() {
                                                _isCalculating = false;
                                              });
                                            }
                                          }
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                const Color(0xFF4CAF50)
                                                    .withOpacity(0.9),
                                                const Color(0xFF2E7D32)
                                                    .withOpacity(0.9),
                                              ],
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                                color: Colors.black, width: 2),
                                            boxShadow: [
                                              BoxShadow(
                                                offset: Offset(
                                                    4 + _buttonAnimation.value,
                                                    4 + _buttonAnimation.value),
                                                color: Colors.black,
                                                blurRadius: 0,
                                              )
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              _isCalculating
                                                  ? const SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child:
                                                          CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 3,
                                                      ),
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
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: Colors.black, width: 1),
                              ),
                              child: const Column(
                                children: [
                                  Text(
                                    'Your BMI helps us recommend the ideal fruit combination',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Different body types benefit from different nutrients',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Always consult with healthcare professionals about dietary choices',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isCalculating)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withOpacity(0.1),
              child: const Center(
                child: CardLoading(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black, width: 1.5),
                boxShadow: const [
                  BoxShadow(offset: Offset(2, 2), color: Colors.black),
                ],
              ),
              child: const Icon(Icons.arrow_back, color: Colors.black),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                "CHECK BMI",
                style: GoogleFonts.bangers(
                  fontSize: 28,
                  letterSpacing: 2.0,
                  color: Colors.black,
                ),
              ),
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
            //Icon(icon, size: 16, color: Colors.black87),
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
              // suffixIcon: suffix,
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

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8ECAE6), Color(0xFF219EBC), Color(0xFF023047)],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: EnhancedBackgroundPainter(),
            ),
          ),
          CustomPaint(
            size: Size(
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height,
            ),
            painter: DoodlePainter(),
          ),
        ],
      ),
    );
  }
}

// Implementation of BMI Card Widget
class Bmicard extends StatelessWidget {
  final UserProfile user;
  const Bmicard({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BmiCard(user: user);
  }
}

class RulerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1.0;

    // Draw a ruler-like pattern.
    for (int i = 0; i < 5; i++) {
      double height = i % 2 == 0 ? size.height * 0.6 : size.height * 0.4;
      double x = size.width * i / 4;
      canvas.drawLine(
        Offset(x, size.height - height),
        Offset(x, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class BMICheckerWidget extends StatelessWidget {
  const BMICheckerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
            offset: Offset(6, 6),
            color: Colors.black,
            blurRadius: 0,
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.fitness_center,
                size: 28,
                color: Colors.black,
              ),
              SizedBox(width: 8),
              Text(
                'FRUIT BOWL',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(width: 8),
              Icon(
                Icons.food_bank,
                size: 28,
                color: Colors.black,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Get your perfect fruit mix based on your BMI',
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
              _buildSmallInfoBadge('Personalized', Icons.person),
              const SizedBox(width: 8),
              _buildSmallInfoBadge('Nutritious', Icons.favorite),
              const SizedBox(width: 8),
              _buildSmallInfoBadge('Healthy', Icons.eco),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black),
            ),
            child: const Text(
              'Complete your profile for a tailored fruit recommendation',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallInfoBadge(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.black),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildSmallInfoBadge(String label, IconData icon) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.black),
      boxShadow: const [
        BoxShadow(
          color: Colors.black,
          offset: Offset(2, 2),
          blurRadius: 0,
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.black),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black,
          ),
        ),
      ],
    ),
  );
}
