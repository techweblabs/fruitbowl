import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

class BottomNavigationItem {
  final String label;
  final IconData icon;
  final Widget Function() screenBuilder;

  BottomNavigationItem({
    required this.label,
    required this.icon,
    required this.screenBuilder,
  });
}

class AppBottomNavigation extends StatefulWidget {
  final List<BottomNavigationItem> items;
  final int initialIndex;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? backgroundColor;

  const AppBottomNavigation({
    Key? key,
    required this.items,
    this.initialIndex = 0,
    this.activeColor,
    this.inactiveColor,
    this.backgroundColor,
  }) : super(key: key);

  @override
  State<AppBottomNavigation> createState() => _AppBottomNavigationState();
}

class _AppBottomNavigationState extends State<AppBottomNavigation> {
  late int _currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      _pageController.animateToPage(
        index, 
        duration: const Duration(milliseconds: 300), 
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: widget.items.map((item) => item.screenBuilder()).toList(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: widget.backgroundColor ?? theme.scaffoldBackgroundColor,
          selectedItemColor: widget.activeColor ?? theme.primaryColor,
          unselectedItemColor: widget.inactiveColor ?? Colors.grey,
          selectedLabelStyle: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 10.sp,
          ),
          elevation: 8,
          items: widget.items.map((item) => 
            BottomNavigationBarItem(
              icon: Icon(item.icon),
              label: item.label.tr,
            )
          ).toList(),
        ),
      ),
    );
  }
}
