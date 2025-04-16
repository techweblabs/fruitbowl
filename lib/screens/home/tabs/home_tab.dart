

import 'package:flutter/material.dart';
import 'package:flutter_starter_kit/screens/CheckBMIScreen/components/check_bmi_screen_body.dart';
import 'package:flutter_starter_kit/screens/ProfielScreen/components/bmi_card.dart';
import 'package:flutter_starter_kit/screens/home/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../components/app_bar/custom_app_bar.dart';
import '../../../components/decorations/background_painters.dart';
import '../../../components/decorations/doodle_painters.dart';
import '../../../components/sections/bmi_section.dart';
import '../../../components/sections/recommended_section.dart';
import '../../../providers/firestore_api_provider.dart';
import '../../ProfielScreen/models/user_profile.dart';

class HomeTab extends StatefulWidget {
  final String username;
  const HomeTab({Key? key, this.username = "User"}) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;
  bool _checkbmi = false;
  UserProfile? userProfile;
  String _bmiString = "";

  // Still declared but no longer used by any FutureBuilder.
  // Future<List<FruitBowlItem>>? _futureFruitBowls;

  @override
  void initState() {
    super.initState();
    loadCheckBMI(); // This will update _bmiString and then assign _futureFruitBowls.
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
    // var pro = Provider.of<FirestoreApiProvider>(context, listen: false);
    final loadedBMIString = prefs.getString('BMIStr') ?? "";
    setState(() {
      _checkbmi = prefs.getBool('Bmicheck') ?? false;
      _bmiString = loadedBMIString;
      userProfile = UserProfile(
        phoneNumber: prefs.getString("contactNo") ?? "",
        age: prefs.getInt('age') ?? 1,
        name: prefs.getString('name') ?? "User",
        email: prefs.getString('email') ?? "exampleuser@email.com",
        profileImage: prefs.getString('profileimage') ?? "",
        gender: prefs.getString('gender') ?? "",
        bmi: double.tryParse(prefs.getString('BMI') ?? "0") ?? 0,
        weight: double.tryParse(prefs.getString('weight') ?? "0") ?? 0,
        height: double.tryParse(prefs.getString('height') ?? "0") ?? 0,
      );
      // Now that _bmiString is ready, cache the future.
      // _futureFruitBowls = pro.bowls;
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
          Positioned.fill(child: _buildBackground()),
          Positioned.fill(
            top: MediaQuery.of(context).padding.top + kToolbarHeight,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
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
                        const SizedBox(height: 30),
                        _checkbmi
                            ? GestureDetector(
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const CheckBMIBody()),
                                  );
                                  if (result == true) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const HomeScreen(initialIndex: 0),
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
                                        builder: (context) => const CheckBMIBody()),
                                  );
                                  if (result == true) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const HomeScreen(initialIndex: 0),
                                      ),
                                    );
                                  }
                                },
                                child: const BMISection(),
                              ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
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
                        // Removed FutureBuilders and use Provider directly instead.
                        Consumer<FirestoreApiProvider>(
                          builder: (context, pro, child) {
                            final recommendedFruitBowls =
                                pro.bowls; // Adjust property name if needed.
                            if (recommendedFruitBowls == null ||
                                recommendedFruitBowls.isEmpty) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RecommendedSection(
                                  fruitBowls: recommendedFruitBowls,
                                  title: 'Recommended Fruit Bowls',
                                ),
                                const SizedBox(height: 100),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
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
          colors: [
            Color(0xFF8ECAE6),
            Color(0xFF219EBC),
            Color(0xFF023047),
          ],
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



  // Future<List<FruitBowlItem>> fetchFruitBowls() async {
  //   // Ensure _bmiString is valid before performing the query.
  //   QuerySnapshot sizesSnapshot = await FirebaseFirestore.instance
  //       .collection('fruitBowls')
  //       .doc(_bmiString)
  //       .collection('sizes')
  //       .get();

  //   List<FruitBowlItem> bowls = [];

  //   for (final sizeDoc in sizesSnapshot.docs) {
  //     final data = sizeDoc.data() as Map<String, dynamic>;
  //     final dailyPrice = (data['dailyPrice'] is num)
  //         ? (data['dailyPrice'] as num).toDouble()
  //         : double.tryParse(data['dailyPrice']?.toString() ?? '0') ?? 0.0;

  //     final itemsSnapshot = await sizeDoc.reference.collection('items').get();
  //     int totalCalories = 0;
  //     for (final itemDoc in itemsSnapshot.docs) {
  //       final itemData = itemDoc.data();
  //       final itemCalories = (itemData['calories'] is num)
  //           ? (itemData['calories'] as num).toInt()
  //           : int.tryParse(itemData['calories']?.toString() ?? '0') ?? 0;
  //       totalCalories += itemCalories;
  //     }

  //     String sizeid = sizeDoc.id.toUpperCase();

  //     bowls.add(
  //       FruitBowlItem(
  //         title: '$sizeid BOWL',
  //         description: data['description'] ?? 'Healthy fruit bowl',
  //         coverImage: 'assets/images/medium_bowl.png',
  //         color: data['color'] != null
  //             ? Color(int.parse(data['color']))
  //             : Colors.white,
  //         calories: totalCalories,
  //         price: dailyPrice,
  //       ),
  //     );
  //   }

  //   return bowls;
  // }
