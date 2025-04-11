// ignore_for_file: deprecated_member_use, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_starter_kit/screens/CheckBMIScreen/check_bmi_screen.dart';
import 'package:flutter_starter_kit/screens/CheckBMIScreen/components/check_bmi_screen_body.dart';
import 'package:flutter_starter_kit/screens/ProfielScreen/components/bmi_card.dart';
import 'package:flutter_starter_kit/screens/home/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  String _bmiString = "";

  // /// Static program data (unchanged)
  // final List<ProgramItem> programs = [
  //   ProgramItem(
  //     title: 'Large Bowl Program',
  //     description:
  //         'A nutritious program with large portions for active lifestyles.',
  //     coverImage: 'assets/images/large_bowl.png',
  //     color: Color(0xFFFFF59D), // Pale yellow
  //     progress: 0.5,
  //   ),
  //   ProgramItem(
  //     title: 'Small Bowl Diet',
  //     description: 'Perfect for portion control and mindful eating habits.',
  //     coverImage: 'assets/images/small_bowl.png',
  //     color: Color(0xFFFFCCBC), // Pale orange
  //     progress: 0.75,
  //   ),
  //   ProgramItem(
  //     title: 'Medium Bowl Plan',
  //     description:
  //         'Balanced nutrition with moderate portions for everyday wellness.',
  //     coverImage: 'assets/images/medium_bowl.png',
  //     color: Color(0xFFB3E5FC), // Pale blue
  //     progress: 0.3,
  //   ),
  // ];

  // // Fruit bowl items data
  // final List<FruitBowlItem> fruitBowls = [
  //   FruitBowlItem(
  //     title: 'Berry Blast Bowl',
  //     description: 'Mixed berries with granola and honey drizzle',
  //     coverImage: 'assets/images/large_bowl.png',
  //     color: const Color(0xFFE1BEE7), // Light purple
  //     calories: 320,
  //     price: 7.99,
  //   ),
  //   FruitBowlItem(
  //     title: 'Tropical Paradise',
  //     description: 'Mango, pineapple, and coconut with chia seeds',
  //     coverImage: 'assets/images/small_bowl.png',
  //     color: const Color(0xFFFFE082), // Light amber
  //     calories: 280,
  //     price: 8.49,
  //   ),
  //   FruitBowlItem(
  //     title: 'Green Energy Bowl',
  //     description: 'Kiwi, green apple, and spinach with flax seeds',
  //     coverImage: 'assets/images/medium_bowl.png',
  //     color: const Color(0xFFC8E6C9), // Light green
  //     calories: 250,
  //     price: 7.49,
  //   ),
  //   FruitBowlItem(
  //     title: 'Citrus Refresh',
  //     description: 'Orange, grapefruit, and lemon with mint leaves',
  //     coverImage: 'assets/images/large_bowl.png',
  //     color: const Color(0xFFFFECB3), // Light orange
  //     calories: 230,
  //     price: 6.99,
  //   ),
  // ];

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
    setState(() {
      _checkbmi = prefs.getBool('Bmicheck') ?? false;
      _bmiString = prefs.getString('BMIStr') ?? "";

      userProfile = UserProfile(
        phoneNumber: prefs.getString("contactNo") ?? "",
        age: prefs.getInt('age') ?? 1,
        name: prefs.getString('name') ?? "",
        email: prefs.getString('email') ?? "",
        profileImage: prefs.getString('profileimage') ?? "",
        gender: prefs.getString('gender') ?? "",
        bmi: double.tryParse(prefs.getString('BMI') ?? "0") ?? 0,
        weight: double.tryParse(prefs.getString('weight') ?? "0") ?? 0,
        height: double.tryParse(prefs.getString('height') ?? "0") ?? 0,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Fetch dynamic fruit bowls data from Firestore.
  /// For each "size" doc in `fruitBowls -> obese -> sizes`, we also fetch its `items` subcollection
  /// to sum up the total calories from each item. That sum becomes the bowl's final `calories` value.
  Future<List<FruitBowlItem>> fetchFruitBowls() async {
    // 1) Query the 'sizes' documents under 'obese' (or whichever BMI doc you need).
    QuerySnapshot sizesSnapshot = await FirebaseFirestore.instance
        .collection('fruitBowls')
        .doc(_bmiString) // adjust if needed
        .collection('sizes')
        .get();

    List<FruitBowlItem> bowls = [];

    // 2) Loop through each size doc and fetch its items subcollection to sum calories.
    for (final sizeDoc in sizesSnapshot.docs) {
      final data = sizeDoc.data() as Map<String, dynamic>;

      // Safely parse numeric fields (dailyPrice, discount, weight) if needed:
      final dailyPrice = (data['dailyPrice'] is num)
          ? (data['dailyPrice'] as num).toDouble()
          : double.tryParse(data['dailyPrice']?.toString() ?? '0') ?? 0.0;

      // If you want discount and weight too, parse them here similarly:
      // final discount = ...
      // final weight = ...

      // 3) Now fetch the 'items' subcollection to compute total calories:
      final itemsSnapshot = await sizeDoc.reference.collection('items').get();
      int totalCalories = 0;

      for (final itemDoc in itemsSnapshot.docs) {
        final itemData = itemDoc.data();
        // The 'calories' field of each item doc might be an int or a double. Safely parse:
        final itemCalories = (itemData['calories'] is num)
            ? (itemData['calories'] as num).toInt()
            : int.tryParse(itemData['calories']?.toString() ?? '0') ?? 0;

        totalCalories += itemCalories;
      }

      // 4) Build a FruitBowlItem using the doc id as the title, plus the computed total calories.
      bowls.add(
        FruitBowlItem(
          title: sizeDoc.id, // e.g., 'small', 'medium', 'large'
          description: data['description'] ?? 'Healthy fruit bowl',
          coverImage: 'assets/images/medium_bowl.png',
          color: data['color'] != null
              ? Color(int.parse(data['color']))
              : Colors.white,
          calories: totalCalories,
          price: dailyPrice,
        ),
      );
    }

    // 5) Return the final list of FruitBowlItem objects
    return bowls;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Fixed background behind everything
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
                                    offset: Offset(4, 4),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                            ),
                            // Main text
                            Text(
                              'Hello, ${widget.username}',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        // BMI card or prompt
                        _checkbmi
                            ? GestureDetector(
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => CheckBMIBody()),
                                  );
                                  if (result == true) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            HomeScreen(initialIndex: 0),
                                      ),
                                    );
                                  }
                                },
                                child: BmiCard(user: userProfile!),
                              )
                            : GestureDetector(
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => CheckBMIBody()),
                                  );
                                  if (result == true) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            HomeScreen(initialIndex: 0),
                                      ),
                                    );
                                  }
                                },
                                child: BMISection(),
                              ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),

                  // White container with dynamic RecommendedSection data
                  Container(
                    width: double.infinity,
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
                        // Fetch dynamic fruit bowls and feed them to recommended sections
                        FutureBuilder<List<FruitBowlItem>>(
                          future: fetchFruitBowls(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            if (snapshot.hasError) {
                              return Center(
                                child:
                                    Text('Error: ${snapshot.error.toString()}'),
                              );
                            }

                            final dynamicFruitBowls = snapshot.data ?? [];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RecommendedSection(
                                  fruitBowls: dynamicFruitBowls,
                                  title: 'Recommended Fruit Bowls',
                                ),
                                SizedBox(
                                  height: 100,
                                )
                                // RecommendedSection(
                                //   fruitBowls: fruitBowls,
                                //   title: 'Popular Fruit Bowls',
                                // ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // If you want to keep showing the "sample" BowlSizeList
                  // BowlSizeList(bmiType: "obese"),
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
      decoration: BoxDecoration(
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

/// Sample widget that shows how you might list the doc fields plus items subcollection.
/// This portion is purely optional for additional detail.
class BowlSizeList extends StatelessWidget {
  final String bmiType;
  const BowlSizeList({super.key, required this.bmiType});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('fruitBowls')
          .doc(bmiType)
          .collection('sizes')
          .get(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print(snapshot.error);
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final sizes = snapshot.data!.docs;

        return Container(
          color: Colors.white,
          child: ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: sizes.length,
            itemBuilder: (context, index) {
              final sizeDoc = sizes[index];
              final sizeData = sizeDoc.data() as Map<String, dynamic>;
              final bowlSize = sizeDoc.id;
              final weight = sizeData['weight'];
              final price = sizeData['dailyPrice'];
              final discount = sizeData['discount'];

              return Card(
                margin: EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ExpansionTile(
                  title: Text('${bowlSize.toUpperCase()} Bowl - ₹$price/day'),
                  subtitle: Text('Weight: ${weight}g | Discount: $discount%'),
                  children: [
                    FutureBuilder<QuerySnapshot>(
                      future: sizeDoc.reference.collection('items').get(),
                      builder: (context, itemSnapshot) {
                        if (!itemSnapshot.hasData) {
                          return CircularProgressIndicator();
                        }
                        final items = itemSnapshot.data!.docs;

                        return Column(
                          children: items.map((item) {
                            final data = item.data() as Map<String, dynamic>;
                            return ListTile(
                              title: Text(data['name'] ?? 'Unknown Fruit'),
                              subtitle: Text(
                                '${data['qty'] ?? 0}g • '
                                '${data['calories'] ?? 0} cal • '
                                '${data['protein'] ?? 0}g protein',
                              ),
                            );
                          }).toList(),
                        );
                      },
                    )
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
