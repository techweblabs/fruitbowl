// lib/checkout/components/address_form.dart
import 'package:flutter/material.dart';
import 'package:flutter_starter_kit/screens/AddressScreen/components/add_address_page.dart';
import 'package:flutter_starter_kit/screens/ProfielScreen/components/address_card.dart';
import 'package:flutter_starter_kit/screens/ProfielScreen/models/user_profile.dart';
import 'package:flutter_starter_kit/utils/helpers/twl.dart';
import 'package:sizer/sizer.dart';
import '../../../utils/brutal_decoration.dart';

import 'section_title.dart';

class AddressForm extends StatefulWidget {
  const AddressForm({super.key});

  @override
  State<AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<AddressForm> {
  final UserProfile _user = UserProfile(
    name: "Rahul Sharma",
    email: "rahul.sharma@example.com",
    // phoneNumber: "+91 98765 43210",
    profileImage: "assets/images/profile.png",
    gender: "Male", // Added gender field
    // age: 32, // Added age field
    bmi: 28.4,
    weight: 86.2,
    height: 174,
  );
  // Form controllers
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();
  final TextEditingController _specialInstructionsController =
      TextEditingController();

  // Save address for future orders
  bool _saveAddress = true;

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
          SizedBox(
            height: 3.h,
          ),
          // const SizedBox(height: 16),
          // _buildAddressForm(),
          // const SizedBox(height: 24),
          // _buildSaveAddressOption(),
          // const SizedBox(height: 24),
          // _buildSpecialInstructions(),
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
          GestureDetector(
            onTap: () {
              Twl.navigateToScreenAnimated(const AddAddressPage(), context: context);
              // AddAddressPage
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BrutalDecoration.sectionTitle(),
              child: const Text(
                'Add New Address',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(offset: Offset(4, 4), color: Colors.black)],
      ),
      child: Column(
        children: [
          _buildTextField(
            controller: _addressController,
            label: "Street Address",
            hint: "Enter your street address",
            icon: Icons.home,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _cityController,
            label: "City",
            hint: "Enter your city",
            icon: Icons.location_city,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _stateController,
                  label: "State",
                  hint: "State",
                  icon: Icons.map,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _zipController,
                  label: "Zip Code",
                  hint: "Zip",
                  icon: Icons.pin_drop,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BrutalDecoration.textField(),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              prefixIcon: Icon(icon),
              hintText: hint,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveAddressOption() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _saveAddress = !_saveAddress;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border.all(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(offset: Offset(3, 3), color: Colors.black)
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BrutalDecoration.checkbox(isChecked: _saveAddress),
              child: _saveAddress
                  ? const Center(
                      child: Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                "Save this address for future orders",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(offset: Offset(3, 3), color: Colors.black)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Special Instructions (Optional)",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 100,
            padding: const EdgeInsets.all(12),
            decoration: BrutalDecoration.textField(),
            child: TextField(
              controller: _specialInstructionsController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: "E.g. Door code, landmark, etc.",
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
