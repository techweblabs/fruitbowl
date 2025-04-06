import 'package:flutter/material.dart';
import 'location_widget.dart';

class CustomAppBar extends StatelessWidget {
  final String username;

  const CustomAppBar({
    Key? key,
    required this.username,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Location icon and address
        LocationWidget(
          location: 'San Francisco, CA',
        ),

        // Right icons
        Row(
          children: [
            // Profile icon
            _buildIconContainer(
              icon: Icons.person,
              onTap: () {
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
