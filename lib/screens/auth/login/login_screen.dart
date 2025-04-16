// ignore_for_file: deprecated_member_use, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_starter_kit/providers/apiProvider.dart';
import 'package:flutter_starter_kit/screens/auth/otp_verification/otp_verification_screen.dart';
import 'package:flutter_starter_kit/utils/helpers/twl.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({Key? key}) : super(key: key);

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen>
    with SingleTickerProviderStateMixin {
  final String _phoneNumber = '';
  List<String> phoneDigits = [];
  bool _isLoading = false;

  // Animation controller for the icon
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    // Setup animations
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _rotationAnimation = Tween<double>(
      begin: -0.05,
      end: 0.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _addDigit(String digit) {
    if (phoneDigits.length < 10) {
      setState(() {
        phoneDigits.add(digit);
        // Auto-submit when 10 digits are entered
        if (phoneDigits.length == 10) {
          _handleContinue();
        }
      });
    }
  }

  void _removeDigit() {
    if (phoneDigits.isNotEmpty) {
      setState(() {
        phoneDigits.removeLast();
      });
    }
  }

  void _clearDigits() {
    setState(() {
      phoneDigits.clear();
    });
  }

  void _handleContinue() async {
    setState(() {
      _isLoading = true;
    });

    if (phoneDigits.length == 10) {
      Provider.of<apiProvider>(context, listen: false).contactNo =
          phoneDigits.join();

      var result =
          await Provider.of<apiProvider>(context, listen: false).SendOtp();

      if (result != null && result['status'] == "OK") {
        Twl.navigateToScreenAnimated(
          context: Twl.currentContext,
          OtpVerificationScreen(
            phoneNumber: '+91 ${phoneDigits.join()}',
          ),
        );
      } else {
        Twl.showErrorAlert();
        // Twl.showAlert(context, 'Failed to send OTP. Please try again.');
      }
    } else {
      Twl.showErrorAlert();
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Doodle Background
            Positioned.fill(
              child: CustomPaint(
                painter: DoodleBackgroundPainter(),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.7),
                        Colors.orange.shade50.withOpacity(0.5),
                        Colors.green.shade50.withOpacity(0.5),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Main Content - Using Column with Expanded for fixed layout
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Back Button
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                offset: Offset(3, 3),
                                blurRadius: 0,
                              )
                            ],
                          ),
                          child: IconButton(
                            icon: Icon(Icons.arrow_back, size: 6.w),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ),

                      // Animated Phone Icon
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.h),
                        child: AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _rotationAnimation.value,
                              child: Transform.scale(
                                scale: _bounceAnimation.value,
                                child: Container(
                                  width: 25.w,
                                  height: 25.w,
                                  decoration: BoxDecoration(
                                    color: Colors.yellow.shade200,
                                    border: Border.all(
                                        color: Colors.black, width: 3),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        offset: Offset(6, 6),
                                        blurRadius: 0,
                                      )
                                    ],
                                  ),
                                  child: Center(
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Icon(
                                          Icons.phone_android,
                                          size: 12.w,
                                          color: Colors.black,
                                        ),
                                        Positioned(
                                          top: 5.w,
                                          right: 5.w,
                                          child: Container(
                                            width: 5.w,
                                            height: 5.w,
                                            decoration: BoxDecoration(
                                              color: Colors.pink,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: Colors.black,
                                                  width: 1.5),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 5.w,
                                          left: 5.w,
                                          child: Container(
                                            width: 3.w,
                                            height: 3.w,
                                            decoration: BoxDecoration(
                                              color: Colors.cyan,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: Colors.black,
                                                  width: 1.5),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Subtitle
                      Text(
                        'Enter your phone number to continue',
                        style: GoogleFonts.kalam(
                          fontSize: 16.sp,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 2.h),

                      // Phone Number Display
                      Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 2.h, horizontal: 4.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: Offset(5, 5),
                              blurRadius: 0,
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            Text(
                              '+91 ',
                              style: GoogleFonts.kalam(
                                fontSize: 18.sp,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                phoneDigits.join(''),
                                style: GoogleFonts.kalam(
                                  fontSize: 18.sp,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: _clearDigits,
                              child: Container(
                                padding: EdgeInsets.all(1.w),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade300,
                                  border: Border.all(
                                      color: Colors.black, width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      offset: Offset(2, 2),
                                      blurRadius: 0,
                                    )
                                  ],
                                ),
                                child: Icon(Icons.clear, size: 5.w),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Number pad in an expanded container to fix position
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: GridView.builder(
                      physics:
                          NeverScrollableScrollPhysics(), // Prevent scrolling
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1.5,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: 12,
                      itemBuilder: (context, index) {
                        // Define button content based on index
                        Widget buttonContent;
                        VoidCallback? onPressed;
                        Color buttonColor;

                        // Assign funky colors to buttons
                        List<Color> funkyColors = [
                          Colors.yellow.shade200,
                          Colors.pink.shade100,
                          Colors.green.shade100,
                          Colors.orange.shade100,
                          Colors.blue.shade100,
                          Colors.purple.shade100,
                        ];

                        // Use math.Random for consistent colors
                        final random = math.Random(index);
                        buttonColor =
                            funkyColors[random.nextInt(funkyColors.length)];

                        if (index == 9) {
                          // Clear button
                          buttonContent = Icon(Icons.clear, size: 9.w);
                          onPressed = _clearDigits;
                        } else if (index == 10) {
                          // 0 button
                          buttonContent = Text(
                            '0',
                            style: GoogleFonts.kalam(
                              fontSize: 27.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                          onPressed = () => _addDigit('0');
                        } else if (index == 11) {
                          // Backspace button
                          buttonContent = Icon(Icons.backspace, size: 9.w);
                          onPressed = _removeDigit;
                        } else {
                          // Number buttons 1-9
                          buttonContent = Text(
                            '${index + 1}',
                            style: GoogleFonts.kalam(
                              fontSize: 27.sp, // 50% larger number text
                              fontWeight: FontWeight.bold,
                            ),
                          );
                          onPressed = () => _addDigit('${index + 1}');
                        }

                        return Container(
                          decoration: BoxDecoration(
                            color: buttonColor,
                            border: Border.all(
                              color: Colors.black,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                offset: Offset(4, 4),
                                blurRadius: 0,
                              )
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: onPressed,
                              child: Center(child: buttonContent),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.2),
                child: Center(
                  child: Container(
                    width: 15.w,
                    height: 15.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: Offset(4, 4),
                          blurRadius: 0,
                        )
                      ],
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Custom doodle background painter
class DoodleBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw some random doodle-like lines
    _drawRandomLines(canvas, size, paint);
    _drawDoodleCircles(canvas, size, paint);
    _drawFunkyShapes(canvas, size);
  }

  void _drawRandomLines(Canvas canvas, Size size, Paint paint) {
    final double random =
        (DateTime.now().millisecondsSinceEpoch % 10).toDouble();
    for (int i = 0; i < 20; i++) {
      final path = Path();
      final double startX = (random * i * 17) % size.width;
      final double startY = (random * i * 23) % size.height;

      path.moveTo(startX, startY);
      path.cubicTo(
          startX + (random * 10),
          startY + (random * 15),
          startX - (random * 5),
          startY + (random * 20),
          startX + (random * 8),
          startY + (random * 25));

      canvas.drawPath(path, paint);
    }
  }

  void _drawDoodleCircles(Canvas canvas, Size size, Paint paint) {
    final double random =
        (DateTime.now().millisecondsSinceEpoch % 10).toDouble();
    for (int i = 0; i < 10; i++) {
      final double centerX = (random * i * 37) % size.width;
      final double centerY = (random * i * 53) % size.height;

      canvas.drawCircle(Offset(centerX, centerY), (random * 5), paint);
    }
  }

  void _drawFunkyShapes(Canvas canvas, Size size) {
    // Add more neobrutalism style shapes
    final funkyPaint = Paint()..style = PaintingStyle.fill;

    // Draw triangles
    for (int i = 0; i < 5; i++) {
      final path = Path();
      final double centerX = (i * 73) % size.width;
      final double centerY = (i * 91) % size.height;
      final double shapeSize = 20.0;

      path.moveTo(centerX, centerY);
      path.lineTo(centerX + shapeSize, centerY + shapeSize);
      path.lineTo(centerX - shapeSize, centerY + shapeSize);
      path.close();

      funkyPaint.color = [
        Colors.yellow,
        Colors.pink,
        Colors.cyan,
        Colors.green,
        Colors.orange
      ][i % 5]
          .withOpacity(0.1);

      canvas.drawPath(path, funkyPaint);
    }

    // Draw zigzag lines
    for (int i = 0; i < 3; i++) {
      final path = Path();
      final double startX = i * 100.0;
      final double startY = (i * 150 + 50) % size.height;

      path.moveTo(startX, startY);
      for (int j = 0; j < 5; j++) {
        path.lineTo(startX + (j + 1) * 30, startY + (j % 2 == 0 ? 30 : -30));
      }

      funkyPaint.color =
          [Colors.purple, Colors.blue, Colors.red][i % 3].withOpacity(0.1);
      funkyPaint.style = PaintingStyle.stroke;
      funkyPaint.strokeWidth = 3;

      canvas.drawPath(path, funkyPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
