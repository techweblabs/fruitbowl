// ignore_for_file: deprecated_member_use, prefer_const_constructors

import 'package:flutter/material.dart';

import '../../../components/app_bar/custom_app_bar.dart';
import '../../../components/decorations/background_painters.dart';
import '../../../components/decorations/doodle_painters.dart';
import '../../../components/sections/bmi_results.dart';
import '../../../components/sections/bmi_section.dart';
import '../../../components/sections/recommended_section.dart';
import '../../../models/fruit_bowl_item.dart';
import '../../../models/program_item.dart';

class HomeTab extends StatefulWidget {
  final String username;

  const HomeTab({Key? key, required this.username}) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;

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
    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
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
          // Top section with background
          _buildTopSection(),

          // Main content with curved top that overlaps the top section
          SingleChildScrollView(
            child: Column(
              children: [
                // Spacer to position the content below the app bar and header
                SizedBox(height: MediaQuery.of(context).size.height * 0.48),

                // Curved container that holds all content sections
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Small padding at the top
                      // SizedBox(height: 20),

                      // BMI Section is now inside the curved container for overlap effect
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      //   child: BMISection(),
                      // ),

                      // SizedBox(height: 20),

                      // Recommendations sections
                      RecommendedSection(
                          fruitBowls: fruitBowls,
                          title: 'Recommended Fruit Bowls'),

                      RecommendedSection(
                          fruitBowls: fruitBowls, title: 'Popular Fruit Bowls'),

                      // Add extra padding at the bottom for scrolling
                      SizedBox(height: 20),
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

  Widget _buildTopSection() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      width: double.infinity,
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
          // Enhanced 3D background effect with multiple layers
          Positioned.fill(
            child: CustomPaint(
              painter: EnhancedBackgroundPainter(),
            ),
          ),

          // Background doodles of fruits and clouds with enhanced 3D effect
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width,
                MediaQuery.of(context).size.height * 0.5),
            painter: DoodlePainter(),
          ),

          // Safe area padding
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              left: 16.0,
              right: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Bar with navigation and search
                CustomAppBar(username: widget.username),

                const SizedBox(height: 32),

                // Welcome heading - bold and modern with enhanced 3D effect
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

                BMISection(),
                // CompactBMIResultsSection(
                //   bmiValue: 23.7,
                //   bmiCategory: "Normal",
                //   height: 175,
                //   weight: 72.5,
                // ),
                SizedBox(height: 10),
                // BMI section is moved to the curved container to create overlap
              ],
            ),
          ),
        ],
      ),
    );
  }
}
