import 'package:flutter/material.dart';
import 'package:flutter_starter_kit/screens/MyOrdersScreen/my_orders_screen.dart';
import 'package:flutter_starter_kit/screens/ProfielScreen/models/user_profile.dart';
import 'package:flutter_starter_kit/screens/ProfielScreen/user_profile_page.dart';
import 'package:flutter_starter_kit/screens/home/tabs/job.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tabs/home_tab.dart';
import 'tabs/explore_tab.dart';
import 'tabs/favorites_tab.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;
  const HomeScreen({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String username = "";
  UserProfile? userProfile;

  @override
  void initState() {
    super.initState();
    loadCheckBMI();
  }

  Future<void> loadCheckBMI() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('name') ?? "";
    });

    userProfile = UserProfile(
      age: prefs.getInt("age") ?? 1,
      phoneNumber: prefs.getString("contactNo") ?? "",
      name: prefs.getString('name') ?? "",
      email: prefs.getString('email') ?? "",
      profileImage: prefs.getString('profileimage') ?? "",
      gender: prefs.getString('gender') ?? "",
      bmi: double.tryParse(prefs.getString('BMI') ?? "0") ?? 0,
      weight: double.tryParse(prefs.getString('weight') ?? "0") ?? 0,
      height: double.tryParse(prefs.getString('height') ?? "0") ?? 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return NeobrutalistBottomNavigation(
      initialIndex: widget.initialIndex,
      items: [
        BottomNavigationItem(
            label: 'home'.tr,
            icon: Icons.home_rounded,
            activeColor: Colors.yellow.shade200,
            screenBuilder: () => HomeTab()
            // HomeTab(
            //   username: username,
            // ),
            ),
        BottomNavigationItem(
          label: 'my_orders'.tr,
          icon: Icons.food_bank,
          activeColor: Colors.green.shade100,
          screenBuilder: () => const OrdersPage(),
        ),
        BottomNavigationItem(
          label: 'favorites'.tr,
          icon: Icons.favorite_rounded,
          activeColor: Colors.pink.shade100,
          screenBuilder: () => const FavoritesTab(),
        ),
        BottomNavigationItem(
          label: 'account'.tr,
          icon: Icons.person_rounded,
          activeColor: Colors.orange.shade100,
          screenBuilder: () => const UserProfilePage(),
        ),
      ],
    );
  }
}

class BottomNavigationItem {
  final String label;
  final IconData icon;
  final Color activeColor;
  final Widget Function() screenBuilder;

  BottomNavigationItem({
    required this.label,
    required this.icon,
    required this.screenBuilder,
    required this.activeColor,
  });
}

class NeobrutalistBottomNavigation extends StatefulWidget {
  final List<BottomNavigationItem> items;
  final int initialIndex;

  const NeobrutalistBottomNavigation({
    Key? key,
    required this.items,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<NeobrutalistBottomNavigation> createState() =>
      _NeobrutalistBottomNavigationState();
}

class _NeobrutalistBottomNavigationState
    extends State<NeobrutalistBottomNavigation>
    with SingleTickerProviderStateMixin {
  late int _currentIndex;
  late AnimationController _animationController;
  late List<Animation<double>> _iconScales;

  @override
  void initState() {
    super.initState();

    _currentIndex = widget.initialIndex;

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Create an animation scale for each navigation item
    _iconScales = List.generate(
      widget.items.length,
      (index) =>
          Tween<double>(begin: 1.0, end: 1.0).animate(_animationController),
    );

    // Set the initial selected item animation
    _updateIconScales(_currentIndex);
  }

  void _updateIconScales(int selectedIndex) {
    for (int i = 0; i < _iconScales.length; i++) {
      _iconScales[i] = Tween<double>(
        begin: i == selectedIndex ? 1.0 : 1.0,
        end: i == selectedIndex ? 1.2 : 1.0,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.elasticOut,
        ),
      );
    }

    _animationController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Disable back button when at initial index (0)
        if (_currentIndex == 0) {
          return false;
        }
        // Allow switching to initial index on back press for other tabs
        setState(() {
          _currentIndex = 0;
          _updateIconScales(0);
        });
        return false; // Prevent default back navigation
      },
      child: Scaffold(
        body: Stack(
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
            // Current Tab Content using an IndexedStack
            Positioned.fill(
              child: IndexedStack(
                index: _currentIndex,
                children:
                    widget.items.map((item) => item.screenBuilder()).toList(),
              ),
            ),
            // Bottom Navigation
            Positioned(
              left: 4.w,
              right: 4.w,
              bottom: 2.h,
              child: Container(
                height: 10.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 2.5),
                  borderRadius: BorderRadius.circular(0),
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
                  children: List.generate(widget.items.length, (index) {
                    final item = widget.items[index];
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _currentIndex = index;
                            _updateIconScales(index);
                          });
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          margin: EdgeInsets.all(1.w),
                          decoration: BoxDecoration(
                            color: _currentIndex == index
                                ? item.activeColor
                                : Colors.white,
                            border: Border.all(
                              color: Colors.black,
                              width: _currentIndex == index ? 2 : 0,
                            ),
                            boxShadow: _currentIndex == index
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      offset: Offset(2, 2),
                                      blurRadius: 0,
                                    )
                                  ]
                                : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedBuilder(
                                animation: _animationController,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _iconScales[index].value,
                                    child: Icon(
                                      item.icon,
                                      color: Colors.black,
                                      size: 7.w,
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: 0.8.h),
                              Text(
                                item.label,
                                style: GoogleFonts.kalam(
                                  fontSize: 10.sp,
                                  color: Colors.black,
                                  fontWeight: _currentIndex == index
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Enhanced doodle background painter with more variety
class DoodleBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw random doodle-like lines
    _drawRandomLines(canvas, size, paint);
    _drawDoodleCircles(canvas, size, paint);
    _drawFunkyShapes(canvas, size);
  }

  void _drawRandomLines(Canvas canvas, Size size, Paint paint) {
    final double random =
        (DateTime.now().millisecondsSinceEpoch % 10).toDouble();
    for (int i = 0; i < 15; i++) {
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
    for (int i = 0; i < 8; i++) {
      final double centerX = (random * i * 37) % size.width;
      final double centerY = (random * i * 53) % size.height;

      canvas.drawCircle(Offset(centerX, centerY), (random * 5), paint);
    }
  }

  void _drawFunkyShapes(Canvas canvas, Size size) {
    final funkyPaint = Paint()..style = PaintingStyle.fill;

    // Draw triangles
    for (int i = 0; i < 4; i++) {
      final path = Path();
      final double centerX = (i * 73) % size.width;
      final double centerY = (i * 91) % size.height;
      final double shapeSize = 15.0;

      path.moveTo(centerX, centerY);
      path.lineTo(centerX + shapeSize, centerY + shapeSize);
      path.lineTo(centerX - shapeSize, centerY + shapeSize);
      path.close();

      funkyPaint.color = [
        Colors.yellow,
        Colors.pink,
        Colors.green,
        Colors.orange
      ][i % 4]
          .withOpacity(0.05);

      canvas.drawPath(path, funkyPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
