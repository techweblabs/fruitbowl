// lib/checkout/components/address_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_starter_kit/apiServices/apiApi.dart';
import 'package:flutter_starter_kit/screens/AddressScreen/components/add_address_page.dart';
import 'package:flutter_starter_kit/screens/CheckoutScreen/components/edit_address.dart';
import 'package:flutter_starter_kit/screens/ProfielScreen/models/user_profile.dart';
import 'package:flutter_starter_kit/utils/helpers/twl.dart';
import 'package:sizer/sizer.dart';
import '../../../utils/brutal_decoration.dart';

import 'section_title.dart';

class AddressForm extends StatefulWidget {
  // Add the callback parameter
  final Function(Map<String, String>)? onAddressChanged;

  const AddressForm({
    super.key,
    this.onAddressChanged,
  });

  @override
  State<AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<AddressForm> {
  @override
  void initState() {
    super.initState();
    getAddress();
  }

  final UserProfile _user = UserProfile(
    name: "Rahul Sharma",
    email: "rahul.sharma@example.com",
    profileImage: "assets/images/profile.png",
    gender: "Male",
    bmi: 28.4,
    weight: 86.2,
    height: 174,
  );

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();
  final TextEditingController _specialInstructionsController =
      TextEditingController();

  bool _saveAddress = true;
  String? _selectedAddressId;

  List<Map<String, dynamic>>? userAddresses;

  // Method to update the parent widget with selected address
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

  Future<void> getAddress() async {
    try {
      var res = await apiApi().GetAddress();

      if (res['status'] == 'OK' && res['details'] != null) {
        if (mounted) {
          // Check if widget is still mounted
          setState(() {
            userAddresses = List<Map<String, dynamic>>.from(res['details']);

            // If we have addresses but none selected, select one
            if (userAddresses!.isNotEmpty && _selectedAddressId == null) {
              // Try to find default address
              final defaultAddr = userAddresses!.firstWhere(
                (addr) => addr['isDefault'] == true,
                orElse: () => userAddresses!.first,
              );
              _selectedAddressId = defaultAddr['_id'];
            }

            // Call update method after setting initial address
            _updateSelectedAddress();
          });
        }
      } else {
        print('Error: ${res['message']}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _specialInstructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BrutalDecoration.brutalBox(color: Colors.white),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: "Delivery Address"),
          SizedBox(height: 3.h),
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

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedAddressId = address['_id'];
                          // Update parent when address is selected
                          _updateSelectedAddress();
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.black, width: isSelected ? 2 : 1),
                          color: isSelected
                              ? Colors.yellow[100]
                              : isDefault
                                  ? Colors.green[50]
                                  : Colors.white,
                          boxShadow: const [
                            BoxShadow(offset: Offset(3, 3), color: Colors.black)
                          ],
                        ),
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
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Text(
                                          "Default",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12),
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
                                  // In your ListView.builder where the "Edit" button is defined
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
                                      if (res != null &&
                                          res['status'] == 'OK') {
                                        // Update the current address object in the userAddresses list.
                                        final updatedAddress = res['details'];
                                        setState(() {
                                          // Find the index of the current address using the _id.
                                          int index = userAddresses!.indexWhere(
                                              (addr) =>
                                                  addr['_id'] ==
                                                  address['_id']);
                                          if (index != -1) {
                                            userAddresses![index] =
                                                updatedAddress;
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
                                        border: Border.all(
                                            color: Colors.grey[400]!),
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
                                        builder: (context) => AlertDialog(
                                          title: const Text('Delete Address'),
                                          content: const Text(
                                              'Are you sure you want to delete this address?'),
                                          actions: [
                                            TextButton(
                                              child: const Text('Cancel'),
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                            ),
                                            TextButton(
                                              child: const Text('Delete'),
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(true),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true) {
                                        try {
                                          var res =
                                              await apiApi().DeleteAddress({
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
                                              // Update parent after deletion
                                              _updateSelectedAddress();
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
                                        border:
                                            Border.all(color: Colors.red[300]!),
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
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                )
              : const Center(child: CircularProgressIndicator()),
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddAddressPage(),
                ),
              );

              // Refresh addresses regardless of return value
              // This ensures we always get the latest data
              getAddress();
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              margin: const EdgeInsets.only(top: 16),
              decoration: BrutalDecoration.sectionTitle(),
              child: const Text(
                'Add New Address',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
