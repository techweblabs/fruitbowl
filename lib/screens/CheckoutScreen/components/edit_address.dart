import 'package:flutter/material.dart';
import 'package:flutter_starter_kit/apiServices/apiApi.dart';
import 'package:flutter_starter_kit/providers/apiProvider.dart';
import 'package:flutter_starter_kit/screens/home/home_screen.dart';
import 'package:flutter_starter_kit/utils/brutal_decoration.dart';
import 'package:flutter_starter_kit/utils/helpers/twl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class EditAddress extends StatefulWidget {
  /// Pass the address data you want to edit.
  final Map<String, dynamic> addressData;

  const EditAddress({Key? key, required this.addressData}) : super(key: key);

  @override
  State<EditAddress> createState() => _EditAddressState();
}

class _EditAddressState extends State<EditAddress> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _fullAddressController;
  late TextEditingController _flatNumberController;
  late TextEditingController _landmarkController;
  late TextEditingController _areaController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _pincodeController;
  late TextEditingController _specialInstructionsController;

  // For delivery preferences
  bool _leaveAtDoor = false;
  bool _avoidCalling = false;
  bool _isDefault = false;
  bool _isloading = true;
  String _addressType = 'Home';
  late String _userId;

  // For map location
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    // Prepopulate controllers with existing address details
    _userId = widget.addressData['userId'] ?? '';
    _fullAddressController = TextEditingController(
      text: widget.addressData['fullAddress'] ?? '',
    );
    _flatNumberController = TextEditingController(
      text: widget.addressData['flatNumber'] ?? '',
    );
    _landmarkController = TextEditingController(
      text: widget.addressData['landmark'] ?? '',
    );
    _areaController = TextEditingController(
      text: widget.addressData['area'] ?? '',
    );
    _cityController = TextEditingController(
      text: widget.addressData['city'] ?? '',
    );
    _stateController = TextEditingController(
      text: widget.addressData['state'] ?? '',
    );
    _pincodeController = TextEditingController(
      text: widget.addressData['pincode'] ?? '',
    );
    _specialInstructionsController = TextEditingController(
      text: widget.addressData['deliveryPreference']?['deliveryInstructions'] ??
          '',
    );

    // Set delivery preference values
    _leaveAtDoor =
        widget.addressData['deliveryPreference']?['leaveAtDoor'] ?? false;
    _avoidCalling =
        widget.addressData['deliveryPreference']?['avoidCalling'] ?? false;
    _isDefault = widget.addressData['isDefault'] ?? false;
    _addressType = widget.addressData['addressType'] ?? 'Home';

    // Set map coordinates
    _latitude = widget.addressData['latitude'];
    _longitude = widget.addressData['longitude'];
  }

  @override
  void dispose() {
    _fullAddressController.dispose();
    _flatNumberController.dispose();
    _landmarkController.dispose();
    _areaController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _specialInstructionsController.dispose();
    super.dispose();
  }

  // Call this method on form submission to update the address details.
  void _updateAddress() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isloading = true;
      });

      final provider = Provider.of<apiProvider>(context, listen: false);

      provider.addressId = widget.addressData['_id'] ?? '';
      provider.userId = _userId ?? '';

      provider.fullAddress = _fullAddressController.text;
      provider.flatNumber = _flatNumberController.text;
      provider.landmark = _landmarkController.text;
      provider.area = _areaController.text;
      provider.city = _cityController.text;
      provider.state = _stateController.text;
      provider.pincode = _pincodeController.text;
      provider.addressType = _addressType;
      provider.isDefault = _isDefault.toString(); // Convert bool to String
      provider.latitude = _latitude?.toString() ?? '';
      provider.longitude = _longitude?.toString() ?? '';

      provider.status = 'Active';
      provider.deliveryPreference = {
        'leaveAtDoor': _leaveAtDoor,
        'avoidCalling': _avoidCalling,
        'deliveryInstructions': _specialInstructionsController.text,
      };

      await provider.UpdateAddress(context);

      setState(() {
        _isloading = false;
      });

      Twl.navigateToScreenAnimated(
        const HomeScreen(initialIndex: 3),
        context: context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFB2EBF2), // Medium light cyan
              Color.fromARGB(255, 187, 214, 188), // Soft green
              Color(0xFF90CAF9), // Light steel blue
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildHeader(context), // Custom header at the top
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      decoration:
                          BrutalDecoration.brutalBox(color: Colors.white),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Address Type
                          const Text(
                            'Address Type',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildAddressTypeButton('Home'),
                              const SizedBox(width: 12),
                              _buildAddressTypeButton('Work'),
                              const SizedBox(width: 12),
                              _buildAddressTypeButton('Other'),
                            ],
                          ),
                          const SizedBox(height: 16),

                          const Text(
                            "FULL ADDRESS",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          Container(
                            decoration: BrutalDecoration.brutalBox(),
                            child: TextFormField(
                              controller: _fullAddressController,
                              maxLines: 2,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter full address';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: 16),

                          const Text(
                            "Flat/House Number",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          Container(
                            decoration: BrutalDecoration.brutalBox(),
                            child: TextFormField(
                              controller: _flatNumberController,
                              decoration: const InputDecoration(
                                hintText: 'E.g., Apt 301, Villa 42',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter flat/house number';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: 16),

                          const Text(
                            "Landmark",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          Container(
                            decoration: BrutalDecoration.brutalBox(),
                            child: TextFormField(
                              controller: _landmarkController,
                              decoration: const InputDecoration(
                                hintText: 'E.g., Near City Park',
                              ),
                            ),
                          ),
                          SizedBox(height: 16),

                          const Text(
                            "Area/Locality",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          Container(
                            decoration: BrutalDecoration.brutalBox(),
                            child: TextFormField(
                              controller: _areaController,
                              decoration: const InputDecoration(
                                hintText: 'E.g., Jubilee Hills',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter area/locality';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: 16),

                          const Text(
                            "City",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          Container(
                            decoration: BrutalDecoration.brutalBox(),
                            child: TextFormField(
                              controller: _cityController,
                              decoration: const InputDecoration(),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the city';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: 16),

                          const Text(
                            "State",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          Container(
                            decoration: BrutalDecoration.brutalBox(),
                            child: TextFormField(
                              controller: _stateController,
                              decoration: const InputDecoration(),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the state';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: 16),

                          const Text(
                            "Pincode",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          Container(
                            decoration: BrutalDecoration.brutalBox(),
                            child: TextFormField(
                              controller: _pincodeController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the pincode';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(height: 24),

                          // Delivery Preferences
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BrutalDecoration.brutalBox(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Delivery Preferences',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SwitchListTile(
                                  title: const Text('Leave package at door'),
                                  subtitle: const Text('Contactless delivery'),
                                  value: _leaveAtDoor,
                                  contentPadding: EdgeInsets.zero,
                                  onChanged: (value) {
                                    setState(() {
                                      _leaveAtDoor = value;
                                    });
                                  },
                                ),
                                SwitchListTile(
                                  title: const Text('Avoid calling'),
                                  subtitle: const Text(
                                      'Prefer communication via app'),
                                  value: _avoidCalling,
                                  contentPadding: EdgeInsets.zero,
                                  onChanged: (value) {
                                    setState(() {
                                      _avoidCalling = value;
                                    });
                                  },
                                ),
                                TextFormField(
                                  controller: _specialInstructionsController,
                                  decoration: const InputDecoration(
                                    labelText: 'Special Instructions',
                                    hintText:
                                        'Additional delivery instructions',
                                    border: OutlineInputBorder(),
                                  ),
                                  maxLines: 3,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16),

                          CheckboxListTile(
                            title: const Text(
                              'Set as default address',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            value: _isDefault,
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            onChanged: (value) {
                              setState(() {
                                _isDefault = value ?? false;
                              });
                            },
                          ),
                          SizedBox(height: 24),

                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF4CAF50).withOpacity(0.7),
                                  const Color(0xFF2E7D32).withOpacity(0.7),
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.black, width: 2),
                              boxShadow: const [
                                BoxShadow(
                                    offset: Offset(4, 4), color: Colors.black)
                              ],
                            ),
                            child: GestureDetector(
                              onTap: _updateAddress,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: Text(
                                    'UPDATE ADDRESS',
                                    style: GoogleFonts.bangers(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build address type selector buttons
  Widget _buildAddressTypeButton(String type) {
    bool isSelected = _addressType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _addressType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue.shade700 : Colors.grey.shade400,
          ),
        ),
        child: Row(
          children: [
            Icon(
              type == 'Home'
                  ? Icons.home
                  : type == 'Work'
                      ? Icons.work
                      : Icons.location_on,
              color: isSelected ? Colors.white : Colors.black,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              type,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// This is a placeholder for the map location picker

Widget _buildHeader(BuildContext context) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    child: Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black, width: 1.5),
              boxShadow: const [
                BoxShadow(offset: Offset(2, 2), color: Colors.black),
              ],
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black),
          ),
        ),
        Expanded(
          child: Center(
            child: Text(
              "EDIT ADDRESS",
              style: GoogleFonts.bangers(
                fontSize: 28,
                letterSpacing: 2.0,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
