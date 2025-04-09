// ignore_for_file: deprecated_member_use, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_starter_kit/screens/CheckBMIScreen/check_bmi_screen.dart';
import 'package:flutter_starter_kit/screens/ProfielScreen/components/bmi_card.dart';
import 'package:flutter_starter_kit/screens/home/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../../../components/app_bar/custom_app_bar.dart';
import '../../../components/decorations/background_painters.dart';
import '../../../components/decorations/doodle_painters.dart';
import '../../../components/sections/bmi_section.dart';
import '../../../components/sections/recommended_section.dart';
import '../../../models/fruit_bowl_item.dart';
import '../../../models/program_item.dart';
import '../../ProfielScreen/models/user_profile.dart';

class HomeTab extends StatefulWidget {
  final String username;

  const HomeTab({Key? key, required this.username}) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;
  bool _checkbmi = false;
  UserProfile? userProfile;

  // Program Item data
  final List<ProgramItem> programs = [
    ProgramItem(
      title: 'Large Bowl Program',
      description:
          'A nutritious program with large portions for active lifestyles.',
      coverImage: 'assets/images/large_bowl.png',
      color: const Color(0xFFFFF59D), // Pale yellow
      progress: 0.5,
    ),
    ProgramItem(
      title: 'Small Bowl Diet',
      description: 'Perfect for portion control and mindful eating habits.',
      coverImage: 'assets/images/small_bowl.png',
      color: const Color(0xFFFFCCBC), // Pale orange
      progress: 0.75,
    ),
    ProgramItem(
      title: 'Medium Bowl Plan',
      description:
          'Balanced nutrition with moderate portions for everyday wellness.',
      coverImage: 'assets/images/medium_bowl.png',
      color: const Color(0xFFB3E5FC), // Pale blue
      progress: 0.3,
    ),
  ];

  // Fruit bowl items data
  final List<FruitBowlItem> fruitBowls = [
    FruitBowlItem(
      title: 'Berry Blast Bowl',
      description: 'Mixed berries with granola and honey drizzle',
      coverImage: 'assets/images/large_bowl.png',
      color: const Color(0xFFE1BEE7), // Light purple
      calories: 320,
      price: 7.99,
    ),
    FruitBowlItem(
      title: 'Tropical Paradise',
      description: 'Mango, pineapple, and coconut with chia seeds',
      coverImage: 'assets/images/small_bowl.png',
      color: const Color(0xFFFFE082), // Light amber
      calories: 280,
      price: 8.49,
    ),
    FruitBowlItem(
      title: 'Green Energy Bowl',
      description: 'Kiwi, green apple, and spinach with flax seeds',
      coverImage: 'assets/images/medium_bowl.png',
      color: const Color(0xFFC8E6C9), // Light green
      calories: 250,
      price: 7.49,
    ),
    FruitBowlItem(
      title: 'Citrus Refresh',
      description: 'Orange, grapefruit, and lemon with mint leaves',
      coverImage: 'assets/images/large_bowl.png',
      color: const Color(0xFFFFECB3), // Light orange
      calories: 230,
      price: 6.99,
    ),
  ];

  @override
  void initState() {
    super.initState();
    loadCheckBMI();
    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    });
  }

  Future<void> loadCheckBMI() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Use setState to update the location so the widget rebuilds immediately
    setState(() {
      _checkbmi = prefs.getBool('Bmicheck')!;
      userProfile = UserProfile(
        phoneNumber: prefs.getString("contactNo") ?? "",
        age: prefs.getInt('age') ?? 1,
        name: prefs.getString('name').toString(),
        email: prefs.getString('email').toString(),
        profileImage: prefs.getString('profileimage').toString(),
        gender: prefs.getString('gender').toString(),
        bmi: double.tryParse(prefs.getString('BMI').toString()) ?? 0,
        weight: double.tryParse(prefs.getString('weight').toString()) ?? 0,
        height: double.tryParse(prefs.getString('height').toString()) ?? 0,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background stays fixed behind everything
          Positioned.fill(
            child: _buildBackground(),
          ),

          Positioned.fill(
            top: MediaQuery.of(context).padding.top + kToolbarHeight,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 20),

                  // Greeting & BMI section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            // Shadow text for 3D effect
                            Text(
                              'Hello, ${widget.username}',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 6
                                  ..color = Colors.black.withOpacity(0.4),
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    offset: const Offset(4, 4),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                            ),
                            // Main text
                            Text(
                              'Hello, ${widget.username}',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        _checkbmi
                            ? GestureDetector(
                                onTap: () async {
                                  final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => CheckBMI()));
                                  if (result == true) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => HomeScreen(
                                                  initialIndex: 0,
                                                )));
                                  }
                                },
                                child: BmiCard(user: userProfile!))
                            : GestureDetector(
                                onTap: () async {
                                  final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => CheckBMI()));
                                  if (result == true) {
                                    // print('setting state');
                                    // loadCheckBMI();
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => HomeScreen(
                                                  initialIndex: 0,
                                                )));
                                  }
                                },
                                child: BMISection()),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                  // White content container
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RecommendedSection(
                          fruitBowls: fruitBowls,
                          title: 'Recommended Fruit Bowls',
                        ),
                        RecommendedSection(
                          fruitBowls: fruitBowls,
                          title: 'Popular Fruit Bowls',
                        ),
                        SizedBox(height: 10.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Pinned app bar at the top
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CustomAppBar(username: widget.username),
            ),
          ),
        ],
      ),
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
