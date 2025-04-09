// lib/profile/user_profile_page.dart
// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_starter_kit/apiServices/apiApi.dart';
import 'package:flutter_starter_kit/screens/AddressScreen/components/add_address_page.dart';
import 'package:flutter_starter_kit/screens/CheckoutScreen/components/edit_address.dart';
import 'package:flutter_starter_kit/screens/MyOrdersScreen/my_orders_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../../utils/brutal_decoration.dart';
import '../CheckBMIScreen/check_bmi_screen.dart';
import '../home/home_screen.dart';
import 'components/profile_header.dart';
import 'components/profile_option.dart';
import 'components/bmi_card.dart';
import 'components/address_card.dart';
import 'models/user_profile.dart';

class UserProfilePage extends StatefulWidget {
  final Function(Map<String, String>)? onAddressChanged;
  const UserProfilePage({super.key, this.onAddressChanged});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  @override
  void initState() {
    super.initState();
    getAddress();
    loaddata();
  }

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

  String? _selectedAddressId;

  List<Map<String, dynamic>>? userAddresses;
  void _updateSelectedAddress() {
    if (widget.onAddressChanged != null &&
        _selectedAddressId != null &&
        userAddresses != null) {
      final selectedAddress = userAddresses!.firstWhere(
        (addr) => addr['_id'] == _selectedAddressId,
        orElse: () => {},
      );

      if (selectedAddress.isNotEmpty) {
        widget.onAddressChanged!({
          'id': selectedAddress['_id'] ?? '',
          'fullAddress': selectedAddress['fullAddress'] ?? '',
          'addressType': selectedAddress['addressType'] ?? '',
          'isDefault': (selectedAddress['isDefault'] ?? false).toString(),
        });
      }
    }
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

  Future<void> getAddress() async {
    try {
      var res = await apiApi().GetAddress();

      if (res['status'] == 'OK' && res['details'] != null && mounted) {
        setState(() {
          userAddresses = List<Map<String, dynamic>>.from(res['details']);
          // Only set selected address if we actually have addresses
          if (userAddresses != null && userAddresses!.isNotEmpty) {
            final defaultAddr = userAddresses!.firstWhere(
              (addr) => addr['isDefault'] == true,
              orElse: () => userAddresses!.first,
            );
            _selectedAddressId = defaultAddr['_id'];
          }
        });
      } else {
        print('Error: ${res['message']}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  // Sample user data
  // Sample user data with added gender and age fields
  bool _saveAddress = true;

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
                  onTap: () async {
                    final result = await Navigator.push(context,
                        MaterialPageRoute(builder: (context) => CheckBMI()));
                    if (result == true) {
                      // print('setting state');
                      // loadCheckBMI();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomeScreen(
                                    initialIndex: 3,
                                  )));
                    }
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

                // // Dietary preferences section
                // _buildDietarySection(),
                // const SizedBox(height: 24),

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
              ProfileOption(
                icon: Icons.medical_services,
                title: "Health Goals",
                subtitle: "Track your progress",
                onTap: () {
                  // Navigate to health goals
                },
              ),
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
              ProfileOption(
                icon: Icons.payment,
                title: "Payment Methods",
                subtitle: "Manage your payment options",
                onTap: () {
                  // Navigate to payment methods
                },
              ),
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
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddAddressPage(),
                  ),
                );

                // Always refresh the address list when returning, regardless of result
                getAddress();
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
        userAddresses != null
            ? ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: userAddresses!.length,
                itemBuilder: (context, index) {
                  final address = userAddresses![index];
                  final isDefault = address['isDefault'];
                  final isHome =
                      (address['addressType'] ?? '').toLowerCase() == 'home';
                  final isSelected = _selectedAddressId == address['_id'];

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BrutalDecoration.brutalBox(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey[200],
                                    border: Border.all(color: Colors.black),
                                  ),
                                  child: Icon(
                                    isHome ? Icons.home : Icons.work,
                                    color: Colors.blue,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  address['addressType'] ?? 'Address',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 8),
                                if (isDefault)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      "Default",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12),
                                    ),
                                  )
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            address['fullAddress'] ?? '',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // EDIT BUTTON
                              GestureDetector(
                                onTap: () async {
                                  // Push the EditAddress page passing the current address data.
                                  final res = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EditAddress(addressData: address),
                                    ),
                                  );

                                  // Check if the API response is returned and indicates success.
                                  if (res != null && res['status'] == 'OK') {
                                    // Update the current address object in the userAddresses list.
                                    final updatedAddress = res['details'];
                                    setState(() {
                                      // Find the index of the current address using the _id.
                                      int index = userAddresses!.indexWhere(
                                          (addr) =>
                                              addr['_id'] == address['_id']);
                                      if (index != -1) {
                                        userAddresses![index] = updatedAddress;
                                        _selectedAddressId =
                                            updatedAddress['_id'];
                                        // Optionally, update the parent widget with the new address info.
                                        _updateSelectedAddress();
                                      }
                                    });
                                  } else {
                                    // Fallback: in case no valid response is returned, refresh addresses from API.
                                    getAddress();
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(6),
                                    border:
                                        Border.all(color: Colors.grey[400]!),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit,
                                          size: 16, color: Colors.black),
                                      const SizedBox(width: 4),
                                      const Text(
                                        'Edit',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),

                              // DELETE BUTTON
                              GestureDetector(
                                onTap: () async {
                                  bool? confirm = await showDialog(
                                    context: context,
                                    barrierDismissible: true,
                                    builder: (context) {
                                      return Dialog(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16)),
                                        backgroundColor: Colors.transparent,
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BrutalDecoration
                                              .brutalBox(), // Your custom brutal style
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text(
                                                'Delete Address',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              const Text(
                                                'Are you sure you want to delete this address?',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(fontSize: 16),
                                              ),
                                              const SizedBox(height: 24),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: GestureDetector(
                                                      onTap: () =>
                                                          Navigator.of(context)
                                                              .pop(false),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 12),
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.grey[300],
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                          boxShadow: const [
                                                            BoxShadow(
                                                              color:
                                                                  Colors.black,
                                                              offset:
                                                                  Offset(4, 4),
                                                            ),
                                                          ],
                                                        ),
                                                        alignment:
                                                            Alignment.center,
                                                        child: const Text(
                                                          'Cancel',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: GestureDetector(
                                                      onTap: () =>
                                                          Navigator.of(context)
                                                              .pop(true),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical: 10),
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Colors.red[300],
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                          boxShadow: const [
                                                            BoxShadow(
                                                              color:
                                                                  Colors.black,
                                                              offset:
                                                                  Offset(4, 4),
                                                            ),
                                                          ],
                                                        ),
                                                        alignment:
                                                            Alignment.center,
                                                        child: const Text(
                                                          'Delete',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16,
                                                            color: Colors.black,
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
                                      );
                                    },
                                  );

                                  if (confirm == true) {
                                    try {
                                      var res = await apiApi().DeleteAddress({
                                        'addressId': address['_id'],
                                      });

                                      print('DeleteAddress response: $res');
                                      if (res['status'] == 'OK') {
                                        setState(() {
                                          userAddresses!.removeAt(index);
                                          if (_selectedAddressId ==
                                              address['_id']) {
                                            _selectedAddressId = null;
                                          }
                                        });
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(res['message'] ??
                                                'Address deleted'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(res['message'] ??
                                                'Failed to delete'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'An error occurred while deleting the address'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.red[300]!),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete,
                                          size: 16, color: Colors.red),
                                      const SizedBox(width: 4),
                                      const Text(
                                        'Delete',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
            : const Center(child: CircularProgressIndicator()),
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
              ProfileOption(
                icon: Icons.security,
                title: "Privacy & Security",
                subtitle: "Manage your account security",
                onTap: () {
                  // Navigate to privacy settings
                },
              ),
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
        SizedBox(height: 10.h),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BrutalDecoration.brutalBox(), // Your custom decoration
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Are you sure you want to logout?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: const Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        // Perform logout action
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.red[300],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: const Center(
                          child: Text(
                            'Logout',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
