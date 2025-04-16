// lib/profile/components/profile_header.dart
import 'package:flutter/material.dart';
import 'package:flutter_starter_kit/screens/ProfielScreen/components/edit_profile_page.dart';
import 'package:flutter_starter_kit/utils/brutal_decoration.dart';
import 'package:flutter_starter_kit/utils/helpers/twl.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/user_profile.dart';

class ProfileHeader extends StatelessWidget {
  final UserProfile user;
  final VoidCallback? onEditProfile;

  const ProfileHeader({
    super.key,
    required this.user,
    this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BrutalDecoration.brutalBox(),
      child: Row(
        children: [
          // Profile image
          _buildProfileImage(),
          const SizedBox(width: 20),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name ,
                  style: GoogleFonts.bangers(
                    fontSize: 24,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                _buildInfoRow(Icons.email, user.email),
                const SizedBox(height: 2),
                _buildInfoRow(Icons.phone, user.phoneNumber),
                const SizedBox(height: 8),
                _buildEditButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: const [
          BoxShadow(offset: Offset(4, 4), color: Colors.black),
        ],
        image: DecorationImage(
          image: NetworkImage(user.profileImage),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[700]),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEditButton(context) {
    return GestureDetector(
      onTap: () async {
        Twl.navigateToScreenAnimated(EditProfilePage(user: user),
            context: context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: Colors.purple[50],
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.purple[700]!, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.purple[700]!.withOpacity(0.4),
              offset: const Offset(2, 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit, size: 14, color: Colors.purple[700]),
            const SizedBox(width: 4),
            Text(
              "Edit Profile",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.purple[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
