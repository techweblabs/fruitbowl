// lib/profile/basic_details.dart
import 'package:flutter/material.dart';
import 'package:flutter_starter_kit/screens/LocationFetchScreen/location_fetch_screen.dart';
import 'package:flutter_starter_kit/utils/brutal_decoration.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_starter_kit/utils/helpers/twl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../providers/apiProvider.dart';

class BasicDetailsBody extends StatefulWidget {
  const BasicDetailsBody({Key? key}) : super(key: key);

  @override
  State<BasicDetailsBody> createState() => _BasicDetailsBodyState();
}

class _BasicDetailsBodyState extends State<BasicDetailsBody> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late var _selectedGender;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _ageController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isLoading = false;

  // Since this is a fresh profile, we default the BMI values.
  final double _bmi = 0.0;
  final String _bmiCategory = "N/A";
  final Color _bmiColor = Colors.black;
  String contactno = "";

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: "");
    _emailController = TextEditingController(text: "");
    _phoneController = TextEditingController(text: "");
    _ageController = TextEditingController(text: "");
    _selectedGender = "Male"; // default gender
    _heightController = TextEditingController(text: "");
    _weightController = TextEditingController(text: "");

    loadcontactno(); // This will update the phone number later
    // All fields are empty by default.
  }

  loadcontactno() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      contactno = prefs.getString('contactNo') ?? "";
      _phoneController.text = contactno;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
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
                  Color(0xFFE0F7FA), // Light cyan/teal
                  Color(0xFFE8F5E9), // Light mint green
                  Color(0xFFE3F2FD), // Light blue
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
                            _buildPersonalInfoSection(),
                            const SizedBox(height: 24),
                            _buildHealthInfoSection(),
                            const SizedBox(height: 32),
                            _buildSaveButton(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: Container(
          width: 200,
          height: 200,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black, width: 3),
            boxShadow: const [
              BoxShadow(offset: Offset(6, 6), color: Colors.black),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBrutalLoadingAnimation(),
              const SizedBox(height: 20),
              Text(
                "SAVING...",
                style: GoogleFonts.bangers(
                  fontSize: 24,
                  letterSpacing: 2.0,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrutalLoadingAnimation() {
    return SizedBox(
      height: 100,
      width: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(seconds: 2),
            builder: (_, double value, __) {
              return Transform.rotate(
                angle: value * 2 * 3.14,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black, width: 3),
                    boxShadow: const [
                      BoxShadow(offset: Offset(4, 4), color: Colors.black),
                    ],
                  ),
                ),
              );
            },
            onEnd: () {
              setState(() {}); // Rebuild to continue animation
            },
          ),
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(seconds: 1),
            builder: (_, double value, __) {
              return Transform.rotate(
                angle: -value * 2 * 3.14,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.7),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.black, width: 2),
                    boxShadow: const [
                      BoxShadow(offset: Offset(3, 3), color: Colors.black),
                    ],
                  ),
                ),
              );
            },
            onEnd: () {
              setState(() {}); // Rebuild to continue animation
            },
          ),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
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
          // GestureDetector(
          //   onTap: () => Navigator.pop(context),
          //   child: Container(
          //     padding: const EdgeInsets.all(8),
          //     decoration: BoxDecoration(
          //       color: Colors.white.withOpacity(0.8),
          //       borderRadius: BorderRadius.circular(8),
          //       border: Border.all(color: Colors.black, width: 1.5),
          //       boxShadow: const [
          //         BoxShadow(offset: Offset(2, 2), color: Colors.black),
          //       ],
          //     ),
          //     child: const Icon(Icons.arrow_back, color: Colors.black),
          //   ),
          // ),
          Expanded(
            child: Center(
              child: Text(
                "BASIC DETAILS",
                style: GoogleFonts.bangers(
                  fontSize: 28,
                  letterSpacing: 2.0,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          // Container(
          //   padding: const EdgeInsets.all(8),
          //   decoration: BoxDecoration(
          //     color: _isEditing
          //         ? Colors.green.withOpacity(0.2)
          //         : Colors.white.withOpacity(0.8),
          //     borderRadius: BorderRadius.circular(8),
          //     border: Border.all(
          //         color: _isEditing ? Colors.green[700]! : Colors.black,
          //         width: 1.5),
          //     boxShadow: const [
          //       BoxShadow(offset: Offset(2, 2), color: Colors.black),
          //     ],
          //   ),
          //   child: Icon(
          //     _isEditing ? Icons.check : Icons.edit,
          //     color: _isEditing ? Colors.green[700] : Colors.black,
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BrutalDecoration.brutalBox(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BrutalDecoration.brutalBox(),
            child: const Text(
              "Personal Information",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField(
            readonly: false,
            controller: _nameController,
            label: "Full Name",
            icon: Icons.person,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Name cannot be empty";
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            readonly: false,
            controller: _emailController,
            label: "Email",
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Email cannot be empty";
              }
              if (!value.contains('@') || !value.contains('.')) {
                return "Please enter a valid email address";
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildTextField(
            readonly: true,
            controller: _phoneController,
            label: "Phone Number",
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Phone number cannot be empty";
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Gender",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildGenderOption("Male"),
                  const SizedBox(width: 12),
                  _buildGenderOption("Female"),
                  const SizedBox(width: 12),
                  _buildGenderOption("Other"),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BrutalDecoration.brutalBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BrutalDecoration.brutalBox(),
            child: const Text(
              "Health Information",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField(
            readonly: false,
            controller: _ageController,
            label: "Age",
            icon: Icons.cake,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Age cannot be empty";
              }
              if (int.tryParse(value) == null) {
                return "Please enter a valid number";
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  readonly: false,
                  controller: _heightController,
                  label: "Height (cm)",
                  icon: Icons.height,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Height cannot be empty";
                    }
                    if (double.tryParse(value) == null) {
                      return "Please enter a valid number";
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  readonly: false,
                  controller: _weightController,
                  label: "Weight (kg)",
                  icon: Icons.monitor_weight,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Weight cannot be empty";
                    }
                    if (double.tryParse(value) == null) {
                      return "Please enter a valid number";
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[400]!),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "BMI will be automatically recalculated",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Current BMI: ${_bmi.toStringAsFixed(1)} (${_bmiCategory})",
                        style: TextStyle(
                          fontSize: 12,
                          color: _bmiColor,
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

  Widget _buildTextField({
    required bool readonly,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
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
          child: TextFormField(
            readOnly: readonly,
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              prefixIcon: Icon(icon),
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

  Widget _buildGenderOption(String gender) {
    final bool isSelected = _selectedGender == gender;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedGender = gender;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue[100] : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.blue[700]! : Colors.grey[400]!,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        offset: const Offset(2, 2),
                        color: Colors.blue[900]!.withOpacity(0.3))
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              gender,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.blue[700] : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _saveProfile,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF4CAF50).withOpacity(0.7),
              const Color(0xFF2E7D32).withOpacity(0.7),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: const [
            BoxShadow(offset: Offset(4, 4), color: Colors.black)
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Text(
              "Save Profile",
              style: GoogleFonts.bangers(
                color: Colors.white,
                fontSize: 24,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isEditing = true;
        _isLoading = true;
      });

      // Prepare the parameters as before.
      Map<String, dynamic> params = {
        'name': _nameController.text,
        'email': _emailController.text,
        'phoneNumber': _phoneController.text,
        'gender': _selectedGender == "Male" ? 1 : 2,
        'height': _heightController.text,
        'weight': _weightController.text,
        'age': _ageController.text,
      };

      Provider.of<apiProvider>(context, listen: false).name =
          _nameController.text;
      Provider.of<apiProvider>(context, listen: false).email =
          _emailController.text;
      Provider.of<apiProvider>(context, listen: false).gender =
          _selectedGender == "Male" ? 1 : 2;
      Provider.of<apiProvider>(context, listen: false).height =
          _heightController.text;
      Provider.of<apiProvider>(context, listen: false).weight =
          _weightController.text;
      Provider.of<apiProvider>(context, listen: false).age =
          _ageController.text;

      print(params);

      await Provider.of<apiProvider>(context, listen: false)
          .UpdateProfile(context);

      setState(() {
        _isLoading = false;
        _isEditing = false;
      });

      Twl.navigateToScreenAnimated(LocationFetchScreen(), context: context);
    }
  }
}
