// lib/profile/user_profile_page.dart
// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_starter_kit/screens/AddressScreen/components/add_address_page.dart';
import 'package:flutter_starter_kit/screens/MyOrdersScreen/my_orders_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_starter_kit/utils/helpers/twl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../utils/brutal_decoration.dart';
import '../CheckBMIScreen/check_bmi_screen.dart';
import 'components/profile_header.dart';
import 'components/profile_option.dart';
import 'components/bmi_card.dart';
import 'components/address_card.dart';
import 'models/user_profile.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  // Initialize _user with default values. Adjust addresses, dietaryPreferences, and allergies
  // as necessary if you store these in SharedPreferences.
  UserProfile _user = UserProfile(
    age: 1,
    phoneNumber: "",
    name: "",
    email: "",
    profileImage: "",
    gender: "",
    bmi: 0,
    weight: 0,
    height: 0,
  );

  @override
  void initState() {
    super.initState();
    loaddata();
  }

  void loaddata() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Update _user with loaded preferences using setState so that the UI refreshes.
    setState(() {
      _user = UserProfile(
        age: prefs.getInt("age") ?? 1,
        phoneNumber: prefs.getString("contactNo") ?? "",
        name: prefs.getString('name') ?? "",
        email: prefs.getString('email') ?? "",
        profileImage: prefs.getString('profileimage') ?? "",
        gender: prefs.getString('gender') ?? "",
        bmi: double.tryParse(prefs.getString('BMI') ?? "0") ?? 0,
        weight: double.tryParse(prefs.getString('weight') ?? "0") ?? 0,
        height: double.tryParse(prefs.getString('height') ?? "0") ?? 0,

        // Here we use empty lists as defaults; update as needed if you store these values.
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFE0F7FA), // Light cyan/teal
              const Color(0xFFE8F5E9), // Light mint green
              const Color(0xFFE3F2FD), // Light blue
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile header with user info
                ProfileHeader(user: _user),
                const SizedBox(height: 24),

                // BMI and Health metrics
                GestureDetector(
                  onTap: () {
                    Twl.navigateToScreenAnimated(CheckBMI(), context: context);
                  },
                  child: BmiCard(user: _user),
                ),
                const SizedBox(height: 24),

                // Menu options section
                _buildMenuSection(),
                const SizedBox(height: 24),

                // Address section
                _buildAddressSection(),
                const SizedBox(height: 24),

                // Dietary preferences section
                _buildDietarySection(),
                const SizedBox(height: 24),

                // Settings and logout
                _buildSettingsSection(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Menu",
          style: GoogleFonts.bangers(
            fontSize: 24,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BrutalDecoration.brutalBox(),
          child: Column(
            children: [
              ProfileOption(
                icon: Icons.shopping_bag,
                title: "My Orders",
                subtitle: "View your order history",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const OrdersPage()),
                  );
                },
              ),
              const Divider(height: 1, thickness: 1),
              ProfileOption(
                icon: Icons.calendar_month,
                title: "Delivery Schedule",
                subtitle: "Check upcoming deliveries",
                onTap: () {
                  // Navigate to delivery calendar
                },
              ),
              const Divider(height: 1, thickness: 1),
              // ProfileOption(
              //   icon: Icons.medical_services,
              //   title: "Health Goals",
              //   subtitle: "Track your progress",
              //   onTap: () {
              //     // Navigate to health goals
              //   },
              // ),
              const Divider(height: 1, thickness: 1),
              ProfileOption(
                icon: Icons.favorite,
                title: "Favorite Bowls",
                subtitle: "Your preferred meal selections",
                onTap: () {
                  // Navigate to favorites
                },
              ),
              const Divider(height: 1, thickness: 1),
              // ProfileOption(
              //   icon: Icons.payment,
              //   title: "Payment Methods",
              //   subtitle: "Manage your payment options",
              //   onTap: () {
              //     // Navigate to payment methods
              //   },
              // ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Your Addresses",
              style: GoogleFonts.bangers(
                fontSize: 24,
                letterSpacing: 1.2,
              ),
            ),
            GestureDetector(
              onTap: () {
                Twl.navigateToScreenAnimated(AddAddressPage(),
                    context: context);
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BrutalDecoration.miniButton(),
                child: const Icon(Icons.add, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._user.addresses.map((address) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AddressCard(
                address: address,
                onEdit: () {
                  // Edit address
                },
                onDelete: () {
                  // Delete address
                },
                onSetDefault: () {
                  // Set as default
                },
              ),
            )),
      ],
    );
  }

  Widget _buildDietarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Dietary Preferences",
          style: GoogleFonts.bangers(
            fontSize: 24,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BrutalDecoration.brutalBox(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preferences
              const Text(
                "Diet Type",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _user.dietaryPreferences.map((pref) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green[800]!),
                    ),
                    child: Text(pref),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              // Allergies
              const Text(
                "Allergies",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _user.allergies.map((allergy) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.red[800]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.dangerous, size: 14, color: Colors.red[800]),
                        const SizedBox(width: 4),
                        Text(allergy),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.yellow[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black, width: 1.5),
                  boxShadow: const [
                    BoxShadow(offset: Offset(2, 2), color: Colors.black),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit, size: 16),
                    SizedBox(width: 8),
                    Text(
                      "Update Preferences",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Settings",
          style: GoogleFonts.bangers(
            fontSize: 24,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BrutalDecoration.brutalBox(),
          child: Column(
            children: [
              ProfileOption(
                icon: Icons.notifications,
                title: "Notifications",
                subtitle: "Manage notifications preferences",
                onTap: () {
                  // Navigate to notifications settings
                },
              ),
              const Divider(height: 1, thickness: 1),
              // ProfileOption(
              //   icon: Icons.security,
              //   title: "Privacy & Security",
              //   subtitle: "Manage your account security",
              //   onTap: () {
              //     // Navigate to privacy settings
              //   },
              // ),
              const Divider(height: 1, thickness: 1),
              ProfileOption(
                icon: Icons.help,
                title: "Help & Support",
                subtitle: "Get help or contact us",
                onTap: () {
                  // Navigate to help center
                },
              ),
              const Divider(height: 1, thickness: 1),
              ProfileOption(
                icon: Icons.info,
                title: "About",
                subtitle: "Learn about the app and policies",
                onTap: () {
                  // Navigate to about page
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () {
            // Logout action
            _showLogoutDialog(context);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red[700]!, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.red[700]!.withOpacity(0.4),
                  offset: const Offset(4, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout, color: Colors.red[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  "Logout",
                  style: TextStyle(
                    color: Colors.red[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 10.h,
        )
      ],
    );
  }

  // Use showDialog with a transparent Dialog + your Container:
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        child: Container(
          decoration: BrutalDecoration.brutalBox(),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Are you sure you want to logout?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  // CANCEL
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BrutalDecoration.brutalBox(
                          color: const Color(0xFFD0D0D0),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // LOGOUT
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        // TODO: perform logout
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BrutalDecoration.brutalBox(
                          color: const Color(0xFFFF5C5C),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
