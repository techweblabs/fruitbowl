import 'package:flutter/material.dart';
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

class _CustomAppBarState extends State<CustomAppBar> {
  String location = ''; // Moved inside the state

  @override
  void initState() {
    super.initState();
    // No need for Future.delayed; you can call the async function directly
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Use setState to update the location so the widget rebuilds immediately
    setState(() {
      location = prefs.getString('location') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Location icon and address
        LocationWidget(
          location: location,
        ),
        // Right icons
        Row(
          children: [
            // Profile icon
            _buildIconContainer(
              icon: Icons.person,
              onTap: () {
                Twl.navigateToScreen(UserProfilePage());

                // Handle profile
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
