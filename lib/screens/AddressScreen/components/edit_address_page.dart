// lib/screens/address/edit_address_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_starter_kit/utils/brutal_decoration.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class AddressModel {
  final String id;
  final String title;
  final String fullAddress;
  final String streetAddress;
  final String city;
  final String state;
  final String zipCode;
  final double latitude;
  final double longitude;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.title,
    required this.fullAddress,
    required this.streetAddress,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'fullAddress': fullAddress,
      'streetAddress': streetAddress,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'latitude': latitude,
      'longitude': longitude,
      'isDefault': isDefault,
    };
  }

  AddressModel copyWith({
    String? id,
    String? title,
    String? fullAddress,
    String? streetAddress,
    String? city,
    String? state,
    String? zipCode,
    double? latitude,
    double? longitude,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      title: title ?? this.title,
      fullAddress: fullAddress ?? this.fullAddress,
      streetAddress: streetAddress ?? this.streetAddress,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

class EditAddressPage extends StatefulWidget {
  final AddressModel address;

  const EditAddressPage({Key? key, required this.address}) : super(key: key);

  @override
  State<EditAddressPage> createState() => _EditAddressPageState();
}

class _EditAddressPageState extends State<EditAddressPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _titleController;
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _zipCodeController;

  // Map related variables
  GoogleMapController? _mapController;
  late LatLng _currentPosition;
  late Set<Marker> _markers;
  bool _isLoading = false;
  late bool _isDefault;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data
    _titleController = TextEditingController(text: widget.address.title);
    _streetController =
        TextEditingController(text: widget.address.streetAddress);
    _cityController = TextEditingController(text: widget.address.city);
    _stateController = TextEditingController(text: widget.address.state);
    _zipCodeController = TextEditingController(text: widget.address.zipCode);
    _isDefault = widget.address.isDefault;

    // Initialize map position and marker
    _currentPosition =
        LatLng(widget.address.latitude, widget.address.longitude);
    _markers = {
      Marker(
        markerId: const MarkerId('currentLocation'),
        position: _currentPosition,
        draggable: true,
        onDragEnd: (newPosition) {
          setState(() {
            _currentPosition = newPosition;
          });
          _getAddressFromLatLng(newPosition);
        },
      ),
    };
  }

  @override
  void dispose() {
    _titleController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  // Get current location
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      LatLng latLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _currentPosition = latLng;
        _markers = {
          Marker(
            markerId: const MarkerId('currentLocation'),
            position: latLng,
            draggable: true,
            onDragEnd: (newPosition) {
              setState(() {
                _currentPosition = newPosition;
              });
              _getAddressFromLatLng(newPosition);
            },
          ),
        };
      });

      // Get address from current location
      _getAddressFromLatLng(_currentPosition);

      // Animate camera to current location
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _currentPosition,
            zoom: 16.0,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting location: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Get address from lat lng
  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _streetController.text = '${place.street}';
          _cityController.text = '${place.locality}';
          _stateController.text = '${place.administrativeArea}';
          _zipCodeController.text = '${place.postalCode}';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting address: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Search location by address
  Future<void> _searchLocation(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);

      if (locations.isNotEmpty) {
        Location location = locations[0];
        LatLng latLng = LatLng(location.latitude, location.longitude);

        setState(() {
          _currentPosition = latLng;
          _markers = {
            Marker(
              markerId: const MarkerId('searchedLocation'),
              position: latLng,
              draggable: true,
              onDragEnd: (newPosition) {
                setState(() {
                  _currentPosition = newPosition;
                });
                _getAddressFromLatLng(newPosition);
              },
            ),
          };
        });

        _mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: latLng,
              zoom: 16.0,
            ),
          ),
        );

        _getAddressFromLatLng(latLng);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error searching location: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _updateAddress() {
    if (_formKey.currentState!.validate()) {
      // Create updated address model
      final AddressModel updatedAddress = widget.address.copyWith(
        title: _titleController.text,
        fullAddress:
            '${_streetController.text}, ${_cityController.text}, ${_stateController.text} ${_zipCodeController.text}',
        streetAddress: _streetController.text,
        city: _cityController.text,
        state: _stateController.text,
        zipCode: _zipCodeController.text,
        latitude: _currentPosition.latitude,
        longitude: _currentPosition.longitude,
        isDefault: _isDefault,
      );

      // Print updated address data
      print(updatedAddress.toJson());

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text("Address updated successfully"),
              ],
            ),
          ),
          backgroundColor: Colors.green[700],
          duration: const Duration(seconds: 2),
        ),
      );

      // Navigate back with updated address
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context, updatedAddress);
      });
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
              Color(0xFFE0F7FA), // Light cyan/teal
              Color(0xFFE8F5E9), // Light mint green
              Color(0xFFE3F2FD), // Light blue
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMapSection(),
                        const SizedBox(height: 24),
                        _buildSearchBar(),
                        const SizedBox(height: 24),
                        _buildAddressForm(),
                        const SizedBox(height: 32),
                        _buildUpdateButton(),
                      ],
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

  Widget _buildHeader() {
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
          GestureDetector(
            onTap: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isEditing
                    ? Colors.green.withOpacity(0.2)
                    : Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: _isEditing ? Colors.green[700]! : Colors.black,
                    width: 1.5),
                boxShadow: const [
                  BoxShadow(offset: Offset(2, 2), color: Colors.black),
                ],
              ),
              child: Icon(
                _isEditing ? Icons.check : Icons.edit,
                color: _isEditing ? Colors.green[700] : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [BoxShadow(offset: Offset(4, 4), color: Colors.black)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition,
                zoom: 16.0,
              ),
              markers: _markers,
              onMapCreated: (controller) {
                _mapController = controller;
              },
              onTap: (position) {
                if (_isEditing) {
                  setState(() {
                    _currentPosition = position;
                    _markers = {
                      Marker(
                        markerId: const MarkerId('selectedLocation'),
                        position: position,
                        draggable: true,
                        onDragEnd: (newPosition) {
                          setState(() {
                            _currentPosition = newPosition;
                          });
                          _getAddressFromLatLng(newPosition);
                        },
                      ),
                    };
                  });
                  _getAddressFromLatLng(position);
                }
              },
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            if (!_isEditing)
              Container(
                color: Colors.transparent,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [BoxShadow(offset: Offset(4, 4), color: Colors.black)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BrutalDecoration.brutalBox(),
            child: const Text(
              "Search Location",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: _isEditing ? Colors.white : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isEditing ? Colors.black : Colors.grey[400]!,
                      width: _isEditing ? 1.5 : 1,
                    ),
                    boxShadow: _isEditing
                        ? const [
                            BoxShadow(offset: Offset(2, 2), color: Colors.black)
                          ]
                        : null,
                  ),
                  child: TextFormField(
                    enabled: _isEditing,
                    decoration: const InputDecoration(
                      hintText: "Search for an address",
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    onFieldSubmitted: (value) {
                      if (value.isNotEmpty && _isEditing) {
                        _searchLocation(value);
                      }
                    },
                  ),
                ),
              ),
              if (_isEditing)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  child: GestureDetector(
                    onTap: _getCurrentLocation,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: Colors.blue[700]!, width: 1.5),
                        boxShadow: const [
                          BoxShadow(offset: Offset(2, 2), color: Colors.black)
                        ],
                      ),
                      child: Icon(Icons.my_location, color: Colors.blue[700]),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [BoxShadow(offset: Offset(4, 4), color: Colors.black)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BrutalDecoration.brutalBox(),
            child: const Text(
              "Address Details",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Address Title
          _buildTextField(
            controller: _titleController,
            label: "Address Title (e.g. Home, Work)",
            icon: Icons.title,
            enabled: _isEditing,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Title cannot be empty";
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Street Address
          _buildTextField(
            controller: _streetController,
            label: "Street Address",
            icon: Icons.home,
            enabled: _isEditing,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Street address cannot be empty";
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // City and State
          Row(
            children: [
              // City field
              Expanded(
                child: _buildTextField(
                  controller: _cityController,
                  label: "City",
                  icon: Icons.location_city,
                  enabled: _isEditing,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "City cannot be empty";
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),

              // State field
              Expanded(
                child: _buildTextField(
                  controller: _stateController,
                  label: "State",
                  icon: Icons.map,
                  enabled: _isEditing,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "State cannot be empty";
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Zip Code
          _buildTextField(
            controller: _zipCodeController,
            label: "Zip Code",
            icon: Icons.pin,
            keyboardType: TextInputType.number,
            enabled: _isEditing,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Zip code cannot be empty";
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Default Address Checkbox
          GestureDetector(
            onTap: () {
              if (_isEditing) {
                setState(() {
                  _isDefault = !_isDefault;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isDefault ? Colors.blue[50] : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isDefault ? Colors.blue[700]! : Colors.grey[400]!,
                  width: _isDefault ? 2 : 1,
                ),
                boxShadow: _isDefault
                    ? [
                        BoxShadow(
                            offset: const Offset(2, 2),
                            color: Colors.blue[900]!.withOpacity(0.3))
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _isDefault ? Colors.blue[700] : Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color:
                            _isDefault ? Colors.blue[700]! : Colors.grey[400]!,
                      ),
                    ),
                    child: _isDefault
                        ? const Icon(
                            Icons.check,
                            size: 18,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Set as default address",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: enabled ? Colors.white : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: enabled ? Colors.black : Colors.grey[400]!,
              width: enabled ? 1.5 : 1,
            ),
            boxShadow: enabled
                ? const [BoxShadow(offset: Offset(2, 2), color: Colors.black)]
                : null,
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            enabled: enabled,
            decoration: InputDecoration(
              prefixIcon: Icon(icon),
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

  Widget _buildUpdateButton() {
    return GestureDetector(
      onTap: _isEditing
          ? _updateAddress
          : () {
              setState(() {
                _isEditing = true;
              });
            },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isEditing
                ? [
                    const Color(0xFF4CAF50).withOpacity(0.7),
                    const Color(0xFF2E7D32).withOpacity(0.7),
                  ]
                : [
                    const Color(0xFF2196F3).withOpacity(0.7),
                    const Color(0xFF1976D2).withOpacity(0.7),
                  ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: const [
            BoxShadow(offset: Offset(4, 4), color: Colors.black)
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isEditing ? Icons.check_circle : Icons.edit,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              _isEditing ? "Update Address" : "Edit Address",
              style: GoogleFonts.bangers(
                color: Colors.white,
                fontSize: 24,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
