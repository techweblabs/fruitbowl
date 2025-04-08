import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../providers/apiProvider.dart';
import '../../../utils/helpers/twl.dart';
import '../../../utils/validators/validators.dart';
import '../../../services/storage_service.dart';
import '../../../screens/home/home_screen.dart';
import 'dart:math' as math;

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({
    Key? key,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  List<String> otpDigits = [];
  bool _isLoading = false;
  int _resendSeconds = 30;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    _resendSeconds = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds > 0) {
        setState(() {
          _resendSeconds--;
        });
      } else {
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _addDigit(String digit) {
    if (otpDigits.length < 6) {
      setState(() {
        otpDigits.add(digit);
        // Auto-verify when all 6 digits are entered
        if (otpDigits.length == 6) {
          _verifyOtp();
        }
      });
    }
  }

  void _removeDigit() {
    if (otpDigits.isNotEmpty) {
      setState(() {
        otpDigits.removeLast();
      });
    }
  }

  void _clearDigits() {
    setState(() {
      otpDigits.clear();
    });
  }

  void _verifyOtp() async {
    
    if (otpDigits.length == 6) {
      // Show loading
      setState(() {
        _isLoading = true;
      });

      try {
        // Simulate API call
        Provider.of<apiProvider>(context, listen: false).otp = otpDigits.join();
        await Provider.of<apiProvider>(context, listen: false).VerifyOtp();
      } catch (e) {
        Twl.showErrorSnackbar('Failed to verify OTP. Please try again.');
        // Clear digits on failure to let user try again
        setState(() {
          otpDigits.clear();
          _isLoading = false;
        });
      }
    }
  }

  void _resendOtp() async {
    if (_resendSeconds > 0) return;

    // Show loading
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call
      // await Future.delayed(const Duration(seconds: 1));
      Provider.of<apiProvider>(context, listen: false).SendOtp();
      // Show success message
      Twl.showSuccessSnackbar('OTP resent successfully');

      // Clear current OTP and restart timer
      _clearDigits();
      _startResendTimer();
    } catch (e) {
      Twl.showErrorSnackbar('Failed to resend OTP. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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

            // Loading indicator overlay
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

            // Main Content - Fixed layout using Column with Expanded
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
                                offset: Offset(4, 4),
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

                      SizedBox(height: 4.h),

                      // Title
                      Text(
                        'Verify OTP',
                        style: GoogleFonts.kalam(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),

                      SizedBox(height: 1.h),

                      // Subtitle
                      Text(
                        'Enter the 6-digit code sent to ${widget.phoneNumber}',
                        style: GoogleFonts.kalam(
                          fontSize: 14.sp,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 3.h),

                      // OTP Display
                      Container(
                        width: double.infinity,
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
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(6, (index) {
                            return Container(
                              width: 12.w,
                              height: 12.w,
                              decoration: BoxDecoration(
                                color: index < otpDigits.length
                                    ? Colors.yellow.shade100
                                    : Colors.grey.shade100,
                                border:
                                    Border.all(color: Colors.black, width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    offset: Offset(2, 2),
                                    blurRadius: 0,
                                  )
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  index < otpDigits.length
                                      ? otpDigits[index]
                                      : '',
                                  style: GoogleFonts.kalam(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),

                      SizedBox(height: 2.h),

                      // Status message
                      if (otpDigits.length == 6 && !_isLoading)
                        Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            border: Border.all(color: Colors.black, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                offset: Offset(2, 2),
                                blurRadius: 0,
                              )
                            ],
                          ),
                          child: Text(
                            'Verifying...',
                            style: GoogleFonts.kalam(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),

                      SizedBox(height: 2.h),

                      // Resend OTP
                      TextButton(
                        onPressed: _resendSeconds > 0 ? null : _resendOtp,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 1.h, horizontal: 4.w),
                          decoration: _resendSeconds > 0
                              ? null
                              : BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                      color: Colors.black, width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      offset: Offset(2, 2),
                                      blurRadius: 0,
                                    )
                                  ],
                                ),
                          child: Text(
                            _resendSeconds > 0
                                ? 'Resend OTP in ${_resendSeconds}s'
                                : 'Resend OTP',
                            style: GoogleFonts.kalam(
                              fontSize: 14.sp,
                              fontWeight: _resendSeconds > 0
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                              color: _resendSeconds > 0
                                  ? Colors.grey
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Number pad for OTP entry
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1.8,
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
                          onPressed = _isLoading ? null : _clearDigits;
                        } else if (index == 10) {
                          // 0 button
                          buttonContent = Text(
                            '0',
                            style: GoogleFonts.kalam(
                              fontSize: 27.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                          onPressed = _isLoading ? null : () => _addDigit('0');
                        } else if (index == 11) {
                          // Backspace button
                          buttonContent = Icon(Icons.backspace, size: 9.w);
                          onPressed = _isLoading ? null : _removeDigit;
                        } else {
                          // Number buttons 1-9
                          buttonContent = Text(
                            '${index + 1}',
                            style: GoogleFonts.kalam(
                              fontSize: 27.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                          onPressed = _isLoading
                              ? null
                              : () => _addDigit('${index + 1}');
                        }

                        return Container(
                          decoration: BoxDecoration(
                            color: buttonColor,
                            border: Border.all(color: Colors.black, width: 2),
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

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
