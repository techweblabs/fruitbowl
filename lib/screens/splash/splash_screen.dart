import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_starter_kit/screens/BasicDetailsScreen/basic_details_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../../services/storage_service.dart';
import '../../utils/helpers/twl.dart';
import '../LocationFetchScreen/location_fetch_screen.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Create animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    // Start animation
    _animationController.forward();

    // Navigate after delay
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    // Get the user name from SharedPreferences.
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String name = prefs.getString('name') ?? "";

    // Check if user has seen onboarding and is logged in using StorageService.
    final bool hasSeenOnboarding = StorageService.getBool('hasSeenOnboarding');
    final bool isLoggedIn = StorageService.getBool('isLoggedIn');

    // Wait for animation to complete.
    await Future.delayed(const Duration(seconds: 2));

    // Navigate to the appropriate screen based on conditions.
    if (!hasSeenOnboarding) {
      // If onboarding hasn't been seen, navigate to onboarding.
      return Twl.navigateToScreenReplace(const OnboardingScreen());
    }

    if (!isLoggedIn) {
      // If user is not logged in, navigate to onboarding (or consider a login screen).
      return Twl.navigateToScreenReplace(const OnboardingScreen());
    }

    // At this point, the user has seen onboarding and is logged in.
    if (name.isEmpty) {
      // If no basic details are present, navigate to BasicDetails.
      return Twl.navigateToScreenReplace(BasicDetails());
    }

    // Finally, navigate to the next screen.
    return Twl.navigateToScreenReplace(LocationFetchScreen());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo with fade animation
            FadeTransition(
              opacity: _animation,
              child: ScaleTransition(
                scale: _animation,
                child: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.flash_on,
                      size: 25.w,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 5.h),
            // App name with fade animation
            FadeTransition(
              opacity: _animation,
              child: Text(
                'Flutter Starter Kit',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 10.h),
            // Loading indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 1.w,
            ),
          ],
        ),
      ),
    );
  }
}
