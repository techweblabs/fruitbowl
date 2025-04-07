import 'package:flutter/material.dart';
import 'package:flutter_starter_kit/screens/ProfielScreen/user_profile_page.dart';
import 'package:flutter_starter_kit/utils/helpers/twl.dart';
import 'package:sizer/sizer.dart';

class BMISection extends StatelessWidget {
  const BMISection({Key? key}) : super(key: key);

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
          gradient: const LinearGradient(
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
            // Image section on the left with 3D effect
            Stack(
              clipBehavior: Clip.none, // Allow the image to overflow
              children: [
                Container(
                  width: 160,
                  height: 250,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
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
                ),
                // Positioned person image with enhanced 3D effect
                Positioned(
                  top: -40, // Position more of the person above the container
                  left: 15,
                  bottom: 0, // Adjust horizontal position
                  child: _build3DImage(),
                ),
              ],
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

                    const Text(
                      'Monitor your health stats',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Calculate button
                    _buildCalculateButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _build3DImage() {
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.002) // Increased perspective for stronger 3D
        ..rotateY(-0.08) // Slight rotation for 3D effect
        ..rotateX(0.05), // Add slight X rotation for better standing pose
      alignment: Alignment.center,
      child: Container(
        width: 180,
        height: 150,
        decoration: BoxDecoration(),
        child: Image.asset(
          'assets/images/bmi_person-removebg-preview.png',
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Stack(
      children: [
        // Shadow text

        // Main text
        Text(
          'CHECK YOUR BMI',
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

  Widget _buildCalculateButton() {
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.0005)
        ..rotateX(0.005),
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () {
          Twl.navigateToScreen(UserProfilePage());

          // Handle profile
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 2.h,
            vertical: 1.w,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
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
          child: Text(
            'Calculate Now',
            style: TextStyle(
              color: Colors.black,
              fontSize: 9.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
