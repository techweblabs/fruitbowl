import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import '../../constants/image_constants.dart';
import '../../constants/string_constants.dart';
import '../../services/storage_service.dart';
import '../../utils/helpers/twl.dart';
import '../auth/login/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _onboardingItems = [
    OnboardingItem(
      image: Icons.local_shipping_outlined,
      title: 'Fresh Fruits\nDelivered',
      description: 'Enjoy farm-fresh fruits\nstraight to your doorstep',
      backgroundColor: Color(0xFFFFF3E0),
      iconColor: Color(0xFFFF6B4E),
      gradientColors: [
        Color(0xFFFFD700).withOpacity(0.3),
        Color(0xFFFF6B4E).withOpacity(0.3),
      ],
      backgroundIcons: [
        Icons.apple_outlined,
        Icons.local_shipping_outlined,
        Icons.apple,
      ],
    ),
    OnboardingItem(
      image: Icons.local_dining_outlined,
      title: 'Curated\nSelection',
      description: 'Handpicked, premium fruits\nfrom local farmers',
      backgroundColor: Color(0xFFE6F3E6),
      iconColor: Color(0xFF4CAF50),
      gradientColors: [
        Color(0xFF4CAF50).withOpacity(0.3),
        Color(0xFF81C784).withOpacity(0.3),
      ],
      backgroundIcons: [
        Icons.agriculture_outlined,
        Icons.local_florist_outlined,
        Icons.apple_rounded,
      ],
    ),
    OnboardingItem(
      image: Icons.check_circle_outline,
      title: 'Quality\nGuaranteed',
      description: 'Freshness, taste, and\nnutrition in every bite',
      backgroundColor: Color(0xFFF0E6FF),
      iconColor: Color(0xFF673AB7),
      gradientColors: [
        Color(0xFF673AB7).withOpacity(0.3),
        Color(0xFF9C27B0).withOpacity(0.3),
      ],
      backgroundIcons: [
        Icons.verified_outlined,
        Icons.emoji_food_beverage_outlined,
        Icons.local_dining_outlined,
      ],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextPage() {
    if (_currentPage < _onboardingItems.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() async {
    await StorageService.setBool('hasSeenOnboarding', true);
    Twl.navigateToScreenReplace(PhoneLoginScreen());
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
                        Colors.purple.shade50.withOpacity(0.5),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Column(
              children: [
                // Skip button with hand-drawn style
                Padding(
                  padding: EdgeInsets.all(2.w),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: Offset(4, 4),
                            blurRadius: 6,
                          )
                        ],
                      ),
                      child: TextButton(
                        onPressed: _completeOnboarding,
                        child: Text(
                          'skip'.tr,
                          style: GoogleFonts.kalam(
                            fontSize: 16.sp,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Page view
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _onboardingItems.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return _buildPage(_onboardingItems[index]);
                    },
                  ),
                ),

                // Indicators with doodle style
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingItems.length,
                      (index) => _buildDotIndicator(index),
                    ),
                  ),
                ),

                // Next/Get Started button with hand-drawn style
                Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: Offset(6, 6),
                          blurRadius: 8,
                        )
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 6.h,
                      child: ElevatedButton(
                        onPressed: _onNextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          side: BorderSide(color: Colors.black, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _currentPage == _onboardingItems.length - 1
                              ? 'Get Started'.tr
                              : 'Next'.tr,
                          style: GoogleFonts.kalam(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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

  Widget _buildPage(OnboardingItem item) {
    return Padding(
      padding: EdgeInsets.all(6.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image Container with enhanced 3D effect
          Stack(
            children: [
              // Background doodle icons
              Positioned.fill(
                child: _buildBackgroundIcons(item.backgroundIcons ?? []),
              ),
              // Main container with 3D gradient effect
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: item.gradientColors ??
                        [
                          Colors.white,
                          Colors.white.withOpacity(0.8),
                        ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: Offset(8, 8),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5),
                      offset: Offset(-5, -5),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    item.image,
                    size: 30.w,
                    color: item.iconColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),

          // Title with Kalam font
          Text(
            item.title,
            style: GoogleFonts.kalam(
              fontSize: 26.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),

          // Description with Kalam font
          Text(
            item.description,
            style: GoogleFonts.kalam(
              fontSize: 16.sp,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundIcons(List<IconData> icons) {
    if (icons.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: icons.asMap().entries.map((entry) {
            final index = entry.key;
            final icon = entry.value;
            return Positioned(
              left: (index * constraints.maxWidth / icons.length) +
                  (Random().nextDouble() * 50 - 25), // Random horizontal offset
              top: Random().nextDouble() *
                  constraints.maxHeight, // Random vertical position
              child: Icon(
                icon,
                size: 24,
                color: Colors.black.withOpacity(0.1),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildDotIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: EdgeInsets.symmetric(horizontal: 1.w),
      width: _currentPage == index ? 5.w : 3.w,
      height: 1.h,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.black : Colors.grey.shade300,
        shape: BoxShape.circle,
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
    final random = DateTime.now().millisecondsSinceEpoch % 10;
    for (int i = 0; i < 20; i++) {
      final path = Path();
      final startX = (random * i * 17) % size.width;
      final startY = (random * i * 23) % size.height;

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
    final random = DateTime.now().millisecondsSinceEpoch % 10;
    for (int i = 0; i < 10; i++) {
      final centerX = (random * i * 37) % size.width;
      final centerY = (random * i * 53) % size.height;

      canvas.drawCircle(
          Offset(centerX, centerY), (random * 5).toDouble(), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class OnboardingItem {
  final IconData image;
  final String title;
  final String description;
  final Color backgroundColor;
  final Color iconColor;
  final List<IconData>? backgroundIcons;
  final List<Color>? gradientColors;

  OnboardingItem({
    required this.image,
    required this.title,
    required this.description,
    required this.backgroundColor,
    required this.iconColor,
    this.backgroundIcons,
    this.gradientColors,
  });
}
