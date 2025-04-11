import 'package:flutter/material.dart';
import 'package:flutter_starter_kit/screens/home/home_screen.dart';
import 'package:flutter_starter_kit/utils/helpers/twl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'location_widget.dart';
import 'package:flutter_starter_kit/screens/ProfielScreen/user_profile_page.dart';

class CustomAppBar extends StatefulWidget {
  final String username;

  const CustomAppBar({
    Key? key,
    required this.username,
  }) : super(key: key);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar>
    with WidgetsBindingObserver {
  String location = ''; // Storage for current location

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadLocation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Reload location when app is resumed
      _loadLocation();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This will ensure location is reloaded when returning from other screens
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final savedLocation = prefs.getString('location') ?? '';

    if (mounted) {
      setState(() {
        location = savedLocation;
      });
    }
  }

  // This function will save the location when it's changed
  Future<void> _saveLocation(String newLocation) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('location', newLocation);

    if (mounted) {
      setState(() {
        location = newLocation;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Location icon and address
        LocationWidget(
          initialLocation: location,
          onLocationChanged: (newLocation) {
            // Save the new location when it's selected in the LocationWidget
            _saveLocation(newLocation);
          },
        ),
        // Right icons
        Row(
          children: [
            // Profile icon
            _buildIconContainer(
              icon: Icons.person,
              onTap: () {
                // Save the current location before navigating
                _saveLocation(location);

                Twl.navigateToScreenAnimated(
                    const HomeScreen(
                      initialIndex: 3,
                    ),
                    context: context);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIconContainer({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(3, 3),
              blurRadius: 0,
            ),
            BoxShadow(
              color: Colors.white24,
              offset: Offset(-1, -1),
              blurRadius: 0,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.black,
          size: 24,
        ),
      ),
    );
  }
}
