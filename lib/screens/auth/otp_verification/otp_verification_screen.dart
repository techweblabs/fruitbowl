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
  final bool isRegistration; // Add flag to determine verification context

  const OtpVerificationScreen({
    Key? key,
    required this.phoneNumber,
    this.isRegistration = true, // Default is registration flow
  }) : super(key: key);

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  List<String> otpDigits = [];
  bool _isLoading = false;
  bool _isVerifying = false; // Separate state for verification in progress
  bool _hasError = false; // Track verification errors
  String _errorMessage = ''; // Store error messages
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
    if (otpDigits.length < 6 && !_isVerifying) {
      setState(() {
        otpDigits.add(digit);
        _hasError = false; // Clear any previous errors
        _errorMessage = '';

        // Auto-verify when all 6 digits are entered
        if (otpDigits.length == 6) {
          _verifyOtp();
        }
      });
    }
  }

  void _removeDigit() {
    if (otpDigits.isNotEmpty && !_isVerifying) {
      setState(() {
        otpDigits.removeLast();
        _hasError = false; // Clear any previous errors
        _errorMessage = '';
      });
    }
  }

  void _clearDigits() {
    if (!_isVerifying) {
      setState(() {
        otpDigits.clear();
        _hasError = false;
        _errorMessage = '';
      });
    }
  }

  void _verifyOtp() async {
    if (otpDigits.length == 6) {
      // Show loading and verifying state
      setState(() {
        _isLoading = true;
        _isVerifying = true;
        _hasError = false;
      });

      try {
        final apiProv = Provider.of<apiProvider>(context, listen: false);
        apiProv.otp = otpDigits.join();

        // Call the API to verify OTP
        final result = await apiProv.VerifyOtp();

        // Handle success case
        if (result == true) {
          // Show success animation briefly before navigating
          if (mounted) {
            setState(() {
              _isVerifying = false;
              _hasError = false;
            });

            // Wait briefly to show success state
            await Future.delayed(const Duration(milliseconds: 800));

            // Navigate to the appropriate screen based on context
            if (widget.isRegistration) {
              // Registration flow - go to homepage or next onboarding step
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => HomeScreen()),
                (route) => false,
              );
            } else {
              // Login or password reset flow - pop back to previous screen with success
              Navigator.of(context).pop(true);
            }
          }
        } else {
          // API returned false
          _handleVerificationError('Invalid OTP. Please try again.');
        }
      } catch (e) {
        _handleVerificationError('Failed to verify OTP. Please try again.');
      }
    }
  }

  void _handleVerificationError(String message) {
    if (mounted) {
      setState(() {
        otpDigits.clear();
        _isLoading = false;
        _isVerifying = false;
        _hasError = true;
        _errorMessage = message;
      });
      Twl.showErrorSnackbar(message);
    }
  }

  void _resendOtp() async {
    if (_resendSeconds > 0 || _isVerifying) return;

    // Show loading
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      // Call API to resend OTP
      await Provider.of<apiProvider>(context, listen: false).SendOtp();

      // Show success message
      Twl.showSuccessSnackbar('OTP resent successfully');

      // Clear current OTP and restart timer
      _clearDigits();
      _startResendTimer();
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to resend OTP. Please try again.';
      });
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
    return WillPopScope(
      onWillPop: () async {
        // Prevent back navigation during verification
        return !_isVerifying;
      },
      child: Scaffold(
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
                              onPressed: _isVerifying
                                  ? null // Disable during verification
                                  : () => Navigator.of(context).pop(),
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
                            border: Border.all(
                                color: _hasError ? Colors.red : Colors.black,
                                width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: (_hasError ? Colors.red : Colors.black)
                                    .withOpacity(0.3),
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
                                      ? (_hasError
                                          ? Colors.red.shade100
                                          : Colors.yellow.shade100)
                                      : Colors.grey.shade100,
                                  border: Border.all(
                                      color:
                                          _hasError ? Colors.red : Colors.black,
                                      width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (_hasError
                                              ? Colors.red
                                              : Colors.black)
                                          .withOpacity(0.2),
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
                        AnimatedSwitcher(
                          duration: Duration(milliseconds: 300),
                          child: _buildStatusMessage(),
                        ),

                        SizedBox(height: 2.h),

                        // Resend OTP
                        TextButton(
                          onPressed: (_resendSeconds > 0 || _isVerifying)
                              ? null
                              : _resendOtp,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 1.h, horizontal: 4.w),
                            decoration: (_resendSeconds > 0 || _isVerifying)
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
                                fontWeight: (_resendSeconds > 0 || _isVerifying)
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                                color: (_resendSeconds > 0 || _isVerifying)
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
                            onPressed = (_isLoading || _isVerifying)
                                ? null
                                : _clearDigits;
                          } else if (index == 10) {
                            // 0 button
                            buttonContent = Text(
                              '0',
                              style: GoogleFonts.kalam(
                                fontSize: 27.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                            onPressed = (_isLoading || _isVerifying)
                                ? null
                                : () => _addDigit('0');
                          } else if (index == 11) {
                            // Backspace button
                            buttonContent = Icon(Icons.backspace, size: 9.w);
                            onPressed = (_isLoading || _isVerifying)
                                ? null
                                : _removeDigit;
                          } else {
                            // Number buttons 1-9
                            buttonContent = Text(
                              '${index + 1}',
                              style: GoogleFonts.kalam(
                                fontSize: 27.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                            onPressed = (_isLoading || _isVerifying)
                                ? null
                                : () => _addDigit('${index + 1}');
                          }

                          return Container(
                            decoration: BoxDecoration(
                              color: (_isLoading || _isVerifying)
                                  ? buttonColor.withOpacity(0.5)
                                  : buttonColor,
                              border: Border.all(color: Colors.black, width: 2),
                              boxShadow: (_isLoading || _isVerifying)
                                  ? []
                                  : [
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

              // Loading indicator overlay
              if (_isLoading) _buildLoadingOverlay(),

              // Success animation overlay
              if (!_isLoading && _isVerifying && !_hasError)
                _buildSuccessOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusMessage() {
    if (_hasError) {
      return Container(
        key: ValueKey('error'),
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          border: Border.all(color: Colors.red, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: Offset(2, 2),
              blurRadius: 0,
            )
          ],
        ),
        child: Text(
          _errorMessage.isNotEmpty
              ? _errorMessage
              : 'Invalid OTP. Please try again.',
          style: GoogleFonts.kalam(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.red.shade900,
          ),
        ),
      );
    } else if (otpDigits.length == 6 && !_isLoading && !_isVerifying) {
      return Container(
        key: ValueKey('verifying'),
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
      );
    } else {
      return SizedBox(key: ValueKey('empty'), height: 0);
    }
  }

  Widget _buildLoadingOverlay() {
    return Container(
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
    );
  }

  Widget _buildSuccessOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.2),
      child: Center(
        child: Container(
          width: 20.w,
          height: 20.w,
          decoration: BoxDecoration(
            color: Colors.green.shade100,
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
            child: Icon(
              Icons.check_circle,
              color: Colors.green.shade700,
              size: 12.w,
            ),
          ),
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
