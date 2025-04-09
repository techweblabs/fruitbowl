import 'package:flutter/material.dart';
import 'package:flutter_starter_kit/apiServices/apiApi.dart';
import 'package:flutter_starter_kit/utils/brutal_decoration.dart';
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
  String _addressType = 'Home'; // Default value

  // For map location
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    // Prepopulate controllers with existing address details
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

  void _navigateToMap() async {
    // Navigate to map screen and get result back
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapLocationPicker(
          initialLatitude: _latitude,
          initialLongitude: _longitude,
        ),
      ),
    );

    // If result is not null, update address fields
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _latitude = result['latitude'];
        _longitude = result['longitude'];

        // Update address fields if provided
        if (result['fullAddress'] != null) {
          _fullAddressController.text = result['fullAddress'];
        }
        if (result['city'] != null) {
          _cityController.text = result['city'];
        }
        if (result['state'] != null) {
          _stateController.text = result['state'];
        }
        if (result['pincode'] != null) {
          _pincodeController.text = result['pincode'];
        }
        if (result['area'] != null) {
          _areaController.text = result['area'];
        }
      });
    }
  }

  // Call this method on form submission to update the address details.
  Future<void> _updateAddress() async {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> payload = {
        'addressId': widget.addressData['_id'] ?? '',
        'fullAddress': _fullAddressController.text,
        'flatNumber': _flatNumberController.text,
        'landmark': _landmarkController.text,
        'area': _areaController.text,
        'city': _cityController.text,
        'state': _stateController.text,
        'pincode': _pincodeController.text,
        'addressType': _addressType,
        'isDefault': _isDefault,
        'deliveryPreference': {
          'leaveAtDoor': _leaveAtDoor,
          'avoidCalling': _avoidCalling,
          'deliveryInstructions': _specialInstructionsController.text,
        },
      };

      // Add latitude and longitude if available
      if (_latitude != null && _longitude != null) {
        payload['latitude'] = _latitude;
        payload['longitude'] = _longitude;
      }

      try {
        final res = await apiApi().UpdateAddress(payload);
        if (!mounted) return; // Check right after await

        if (res['status'] == 'OK') {
          print("Message>>>>>>>>>>>>>>>>>>>>>>$res['message']");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res['message'] ?? 'Address updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, res);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res['message'] ?? 'Failed to update address'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BrutalDecoration.brutalBox(),
            child: const Icon(Icons.arrow_back, color: Colors.black),
          ),
        ),
        title: const Text('Edit Address'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BrutalDecoration.brutalBox(color: Colors.white),
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Address Type Selection
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                    ],
                  ),
                ),

                const Text(
                  "FULL ADDRESS",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ), // Full Address Field with Map Icon
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

                SizedBox(height: 2.h),
                const Text(
                  "Flat/House Number",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                // Flat/House Number Field
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

                SizedBox(height: 2.h),
                const Text(
                  "Landmark",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                // Landmark Field
                Container(
                  decoration: BrutalDecoration.brutalBox(),
                  child: TextFormField(
                    controller: _landmarkController,
                    decoration: const InputDecoration(
                      hintText: 'E.g., Near City Park',
                    ),
                  ),
                ),

                SizedBox(height: 2.h),
                Text(
                  "Area/Locality",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),

                // Area Field
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

                SizedBox(height: 2.h),
                Text(
                  "City",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                // City Field
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

                SizedBox(height: 2.h),
                Text(
                  "State",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                // State Field
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

                SizedBox(height: 2.h),

                // Pincode Field
                Text(
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
                    decoration: const InputDecoration(),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the pincode';
                      }
                      return null;
                    },
                  ),
                ),

                SizedBox(height: 3.h),

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

                      SizedBox(height: 1.h),

                      // Leave at door
                      SwitchListTile(
                        title: const Text('Leave package at door'),
                        subtitle: const Text('Contactless delivery'),
                        value: _leaveAtDoor,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (bool value) {
                          setState(() {
                            _leaveAtDoor = value;
                          });
                        },
                      ),

                      // Avoid calling
                      SwitchListTile(
                        title: const Text('Avoid calling'),
                        subtitle: const Text('Prefer communication via app'),
                        value: _avoidCalling,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (bool value) {
                          setState(() {
                            _avoidCalling = value;
                          });
                        },
                      ),

                      SizedBox(height: 1.h),

                      // Special Instructions Field
                      TextFormField(
                        controller: _specialInstructionsController,
                        decoration: const InputDecoration(
                          labelText: 'Special Instructions',
                          hintText: 'Additional delivery instructions',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 2.h),

                // Set as default address
                CheckboxListTile(
                  title: const Text(
                    'Set as default address',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  value: _isDefault,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (bool? value) {
                    setState(() {
                      _isDefault = value ?? false;
                    });
                  },
                ),

                SizedBox(height: 3.h),

                // Coordinates display (optional - for debugging)
                // if (_latitude != null && _longitude != null)
                //   Container(
                //     padding: const EdgeInsets.all(8),
                //     decoration: BoxDecoration(
                //       color: Colors.grey[200],
                //       borderRadius: BorderRadius.circular(4),
                //     ),
                //     child: Text(
                //       'Location: $_latitude, $_longitude',
                //       style: TextStyle(color: Colors.grey[700], fontSize: 12),
                //     ),
                //   ),

                SizedBox(height: 2.h),

                // Update Button
                ElevatedButton(
                  onPressed: _updateAddress,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'UPDATE ADDRESS',
                    style: TextStyle(fontWeight: FontWeight.bold),
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
// You'll need to implement this using your preferred map package
class MapLocationPicker extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;

  const MapLocationPicker(
      {Key? key, this.initialLatitude, this.initialLongitude})
      : super(key: key);

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  double? latitude;
  double? longitude;
  String? address;

  @override
  void initState() {
    super.initState();
    latitude = widget.initialLatitude;
    longitude = widget.initialLongitude;

    // Initialize map when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMap();
    });
  }

  Future<void> _initializeMap() async {
    // Here you would initialize your map with the initial coordinates
    // This is where you would set up the Google Maps / MapBox / other map provider

    // If latitude and longitude are not provided, get user's current location
    if (latitude == null || longitude == null) {
      // Get user's current location
      // This is placeholder code - replace with actual location retrieval
      setState(() {
        latitude = 17.385044; // Default to Hyderabad coordinates
        longitude = 78.486671;
      });
    }

    // Optionally reverse geocode to get address details
    _getAddressFromCoordinates(latitude!, longitude!);
  }

  Future<void> _getAddressFromCoordinates(double lat, double lng) async {
    // This is where you would implement reverse geocoding
    // Using Google Maps Geocoding API or other services

    // Placeholder implementation
    setState(() {
      address = "Address would be fetched here using reverse geocoding";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        actions: [
          TextButton(
            onPressed: () {
              // Return selected location data to previous screen
              Navigator.pop(context, {
                'latitude': latitude,
                'longitude': longitude,
                'fullAddress': address,
                // You would also return other address components like
                // city, state, pincode, etc. from geocoding results
              });
            },
            child: const Text(
              'CONFIRM',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'This is a placeholder for the map view.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'You would implement this using:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10),
            Text(
              '• google_maps_flutter\n• flutter_map (with MapBox)\n• Other map solutions',
              style: TextStyle(color: Colors.blue[700]),
            ),
            const SizedBox(height: 30),
            Text(
              latitude != null && longitude != null
                  ? 'Selected Coordinates: $latitude, $longitude'
                  : 'No coordinates selected',
            ),
            const SizedBox(height: 10),
            if (address != null) Text('Address: $address'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Get current location
          setState(() {
            latitude = 17.385044; // Simulated current location
            longitude = 78.486671;
            address = "123 Main St, Hyderabad";
          });
        },
        tooltip: 'Get current location',
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
