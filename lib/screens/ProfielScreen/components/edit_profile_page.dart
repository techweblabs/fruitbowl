// lib/profile/edit_profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_starter_kit/screens/ProfielScreen/models/user_profile.dart';
import 'package:flutter_starter_kit/screens/home/home_screen.dart';
import 'package:flutter_starter_kit/utils/brutal_decoration.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_starter_kit/utils/helpers/twl.dart';
import 'package:provider/provider.dart';

import '../../../providers/apiProvider.dart';

class EditProfilePage extends StatefulWidget {
  final UserProfile user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  // ignore: prefer_typing_uninitialized_variables
  late var _selectedGender;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _ageController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phoneNumber);
    _ageController = TextEditingController(text: widget.user.age.toString());
    _selectedGender = widget.user.gender == "1"
        ? "Male"
        : widget.user.gender == "2"
            ? "Female"
            : "Other";
    _heightController =
        TextEditingController(text: widget.user.height.toString());
    _weightController =
        TextEditingController(text: widget.user.weight.toString());
    _ageController = TextEditingController(text: widget.user.age.toString());
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
                            //_buildProfileImageSection(),
                            // const SizedBox(height: 24),
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
          // Loading overlay
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
              // Animated Loading Icon with neo-brutalism style
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
          // Outer rotating container
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
          // Inner rotating container (opposite direction)
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
          // Center dot
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
                "EDIT PROFILE",
                style: GoogleFonts.bangers(
                  fontSize: 28,
                  letterSpacing: 2.0,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _isEditing
                  ? Colors.green.withOpacity(0.2)
                  : Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: _isEditing ? Colors.green[700]! : Colors.black,
                  width: 1.5),
              boxShadow: const [
                BoxShadow(offset: Offset(2, 2), color: Colors.black),
              ],
            ),
            child: Icon(
              _isEditing ? Icons.check : Icons.edit,
              color: _isEditing ? Colors.green[700] : Colors.black,
            ),
          ),
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

          // Name field
          _buildTextField(
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

          // Email field
          _buildTextField(
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

          // Phone field
          _buildTextField(
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

          // Gender selection
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

          // Age field
          _buildTextField(
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

          // Height and Weight row
          Row(
            children: [
              // Height field
              Expanded(
                child: _buildTextField(
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

              // Weight field
              Expanded(
                child: _buildTextField(
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

          // Auto-calculated BMI
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
                        "Current BMI: ${widget.user.bmi.toStringAsFixed(1)} (${widget.user.bmiCategory})",
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.user.bmiColor,
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
    final isSelected = _selectedGender == gender;

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

      // In a real app, you would update the user profile here
      Map<String, dynamic> params = {
        'name': _nameController.text,
        'email': _emailController.text,
        'phoneNumber': _phoneController.text,
        'gender': _selectedGender == "Male"
            ? 1
            : _selectedGender == "Female"
                ? 2
                : 3,
        'height': _heightController.text,
        'weight': _weightController.text,
        'age': _ageController.text,
      };

      Provider.of<apiProvider>(context, listen: false).name =
          _nameController.text;
      Provider.of<apiProvider>(context, listen: false).email =
          _emailController.text;
      Provider.of<apiProvider>(context, listen: false).gender =
          _selectedGender == "Male"
              ? 1
              : _selectedGender == "Female"
                  ? 2
                  : 3;

      Provider.of<apiProvider>(context, listen: false).height =
          _heightController.text;
      Provider.of<apiProvider>(context, listen: false).weight =
          _weightController.text;
      Provider.of<apiProvider>(context, listen: false).age =
          _ageController.text;

      // Print the values in JSON format
      print(params);

      await Provider.of<apiProvider>(context, listen: false)
          .UpdateProfile(context);

      setState(() {
        _isLoading = false;
        _isEditing = false;
      });

      Twl.navigateToScreenAnimated(
          const HomeScreen(
            initialIndex: 3,
          ),
          // ignore: use_build_context_synchronously
          context: context);
    }
  }
}
