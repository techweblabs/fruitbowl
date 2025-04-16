// lib/screens/address/location_picker_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_starter_kit/providers/apiProvider.dart';
import 'package:flutter_starter_kit/utils/brutal_decoration.dart';
import 'package:flutter_starter_kit/utils/helpers/twl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:provider/provider.dart';

class AddressModel {
  final String id;
  final String title;
  final String fullAddress;
  final String streetAddress;
  final String houseNumber;
  final String apartment;
  final String landmark;
  final String city;
  final String state;
  final String zipCode;
  final double latitude;
  final double longitude;
  final bool isDefault;
  final String addressType; // "Home", "Work", "Other"

  AddressModel({
    required this.id,
    required this.title,
    required this.fullAddress,
    required this.streetAddress,
    this.houseNumber = '',
    this.apartment = '',
    this.landmark = '',
    required this.city,
    required this.state,
    required this.zipCode,
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
    this.addressType = 'Home',
  });

  Map<String, String> toJson() {
    return {
      'id': id,
      'title': title,
      'fullAddress': fullAddress,
      'streetAddress': streetAddress,
      'houseNumber': houseNumber,
      'apartment': apartment,
      'landmark': landmark,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'isDefault': isDefault.toString(),
      'addressType': addressType,
    };
  }
}

class PlaceAutocompletePrediction {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;

  PlaceAutocompletePrediction({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });

  factory PlaceAutocompletePrediction.fromJson(Map<String, dynamic> json) {
    return PlaceAutocompletePrediction(
      placeId: json['place_id'] as String,
      description: json['description'] as String,
      mainText: json['structured_formatting']['main_text'] as String,
      secondaryText: json['structured_formatting']['secondary_text'] as String,
    );
  }
}

enum AddressPickerStep { mapSelection, addressDetails }

class AddAddressPage extends StatefulWidget {
  const AddAddressPage({Key? key}) : super(key: key);

  @override
  State<AddAddressPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<AddAddressPage> {
  // Current step in the flow
  AddressPickerStep _currentStep = AddressPickerStep.mapSelection;

  Future<void> _fetchAndFillAddress(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;

        setState(() {
          _landmarkController.text = place.subLocality ?? ""; // Area
          _cityController.text = place.locality ?? "";
          _stateController.text = place.administrativeArea ?? "";
          _zipCodeController.text = place.postalCode ?? "";
        });
      }
    } catch (e) {
      print("Error fetching address: $e");
      // Show toast/snackbar if needed
    }
  }

  // Form controllers and keys
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _houseNumberController = TextEditingController();
  final TextEditingController _apartmentController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  bool _leaveAtDoor = false;
  bool _avoidCalling = false;
  bool _isDefaultAddress = false;

  final TextEditingController _deliveryInstructionsController =
      TextEditingController();

  // Map related variables
  final Completer<GoogleMapController> _mapControllerCompleter = Completer();
  GoogleMapController? _mapController;
  LatLng _currentPosition =
      const LatLng(37.4219999, -122.0840575); // Default to Google HQ
  Set<Marker> _markers = {};
  bool _isLoading = false;
  bool _isDragging = false;
  bool _isCameraMoving = false;
  bool _isMapInitialized = false;
  String _addressType = 'Home'; // Default address type

  // Place search API key
  final String _apiKey = "AIzaSyBut5HqGXswofazEpjsi_ta8i1lwkah4TU";
  List<PlaceAutocompletePrediction> _placeResults = [];
  bool _showPlaceResults = false;
  String _formattedAddress = "";
  FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _searchFocusNode.addListener(() {
      setState(() {
        _showPlaceResults =
            _searchFocusNode.hasFocus && _searchController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _cityController.dispose();
    _stateController.dispose();
    _searchController.dispose();
    _streetController.dispose();
    _zipCodeController.dispose();
    _houseNumberController.dispose();
    _apartmentController.dispose();
    _landmarkController.dispose();
    _searchFocusNode.dispose();
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
        _updateMarker(latLng);
      });

      // Get address from current location
      _getAddressFromLatLng(latLng);

      // Move camera to current location
      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: latLng,
              zoom: 16.0,
            ),
          ),
        );
      }
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

  void _updateMarker(LatLng position) {
    setState(() {
      _markers = {
        Marker(
          markerId: const MarkerId('selectedLocation'),
          position: position,
          draggable: true,
          onDragStart: (_) {
            setState(() {
              _isDragging = true;
            });
          },
          onDragEnd: (newPosition) {
            setState(() {
              _currentPosition = newPosition;
              _isDragging = false;
            });
            _getAddressFromLatLng(newPosition);
          },
          // Use custom marker icon - could add this later
          // icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      };
    });
  }

  // Get address from lat lng
  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      setState(() {
        _isLoading = true;
      });

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        String street = place.street ?? '';
        String city = place.locality ?? '';
        String state = place.administrativeArea ?? '';
        String postalCode = place.postalCode ?? '';

        setState(() {
          _streetController.text = street;
          _cityController.text = city;
          _stateController.text = state;
          _zipCodeController.text = postalCode;

          // Update formatted address for display
          _formattedAddress = '$city, $state, $postalCode';

          // Set the search controller text to display the full address
          _searchController.text = '$street, $city, $state $postalCode';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting address: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Search for Google Places - fixed implementation
  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty) {
      setState(() {
        _placeResults = [];
        _showPlaceResults = false;
      });
      return;
    }

    setState(() {
      _showPlaceResults = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://maps.googleapis.com/maps/api/place/autocomplete/json'
            '?input=$query'
            '&key=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);

        if (result['status'] == 'OK') {
          final predictions = result['predictions'] as List;

          // Make sure predictions have structured_formatting
          final validPredictions = predictions
              .where((p) =>
                  p['structured_formatting'] != null &&
                  p['structured_formatting']['main_text'] != null &&
                  p['structured_formatting']['secondary_text'] != null)
              .toList();

          setState(() {
            _placeResults = validPredictions
                .map((p) => PlaceAutocompletePrediction.fromJson(p))
                .toList();
          });

          print("Found ${_placeResults.length} valid place suggestions");
        } else {
          print("Places API error: ${result['status']}");
          setState(() {
            _placeResults = [];
          });
        }
      }
    } catch (e) {
      print("Error searching places: $e");
      setState(() {
        _placeResults = [];
      });
    }
  }

  // Get details for a specific place
  Future<void> _getPlaceDetails(String placeId) async {
    // Hide search results
    setState(() {
      _showPlaceResults = false;
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://maps.googleapis.com/maps/api/place/details/json'
            '?place_id=$placeId'
            '&fields=geometry,formatted_address,address_component'
            '&key=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);

        if (result['status'] == 'OK') {
          // Get the geometry data
          final geometry = result['result']['geometry'];
          final location = geometry['location'];
          final formattedAddress = result['result']['formatted_address'];

          LatLng latLng = LatLng(
            location['lat'] as double,
            location['lng'] as double,
          );

          // Update marker and move camera
          setState(() {
            _currentPosition = latLng;
            _updateMarker(latLng);
            _searchController.text = formattedAddress;
          });

          _mapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: latLng,
                zoom: 16.0,
              ),
            ),
          );

          // Get detailed address components
          _getAddressFromLatLng(latLng);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching place details: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onCameraMove(CameraPosition position) {
    setState(() {
      _isCameraMoving = true;
      _currentPosition = position.target;
    });
  }

  void _onCameraIdle() {
    setState(() {
      _isCameraMoving = false;
    });

    if (!_isDragging && _isMapInitialized) {
      _updateMarker(_currentPosition);
      _getAddressFromLatLng(_currentPosition);
    }
  }

  void _saveAddress() {
    if (_formKey.currentState!.validate()) {
      final varpro = Provider.of<apiProvider>(context, listen: false);

      varpro.addressType =
          _addressType; // Assuming this is a TextEditingController
      varpro.fullAddress =
          '${_houseNumberController.text}, ${_streetController.text}, ${_cityController.text}, ${_stateController.text} ${_zipCodeController.text}';

      varpro.landmark = _apartmentController.text;
      varpro.area = _landmarkController.text;
      varpro.flatNumber = _houseNumberController.text;
      varpro.city = _cityController.text;
      varpro.state = _stateController.text;
      varpro.pincode = _zipCodeController.text;
      varpro.latitude = _currentPosition.latitude.toString();
      varpro.deliveryPreference = {
        'leaveAtDoor': _leaveAtDoor,
        'avoidCalling': _avoidCalling,
        'deliveryInstructions': _deliveryInstructionsController.text.trim(),
      };
      varpro.isDefault =
          _isDefaultAddress.toString(); // Converted to string for consistency
      varpro.longitude = _currentPosition.longitude.toString();

      varpro.AddAddress(context); // Same here

// If needed, trigger API call or any logic after setting the values

      // Print address data
      //  print(address.toJson());

      // Show success message
    }
  }

  void _proceedToAddressDetails() async {
    await _fetchAndFillAddress(
        _currentPosition.latitude, _currentPosition.longitude);

    setState(() {
      _currentStep = AddressPickerStep.addressDetails;
    });
  }

  void _goBackToMap() {
    setState(() {
      _currentStep = AddressPickerStep.mapSelection;
    });
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
          child: _currentStep == AddressPickerStep.mapSelection
              ? _buildMapSelectionStep()
              : _buildAddressDetailsStep(),
        ),
      ),
    );
  }

  Widget _buildMapSelectionStep() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildMapSelectionHeader(),
          Expanded(
            child: Stack(
              children: [
                // Main content
                Column(
                  children: [
                    Flexible(
                      child: _buildMapSection(),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black, width: 2),
                          boxShadow: const [
                            BoxShadow(offset: Offset(4, 4), color: Colors.black)
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.location_on,
                                    color: Colors.redAccent, size: 24),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _formattedAddress.isNotEmpty
                                            ? _formattedAddress
                                            : "Selected Location",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _streetController.text,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                // Container(
                                //   padding: const EdgeInsets.symmetric(
                                //       horizontal: 12, vertical: 6),
                                //   decoration: BoxDecoration(
                                //     color: Colors.orange.withOpacity(0.2),
                                //     borderRadius: BorderRadius.circular(8),
                                //     border: Border.all(
                                //         color: Colors.orange, width: 1),
                                //   ),
                                //   child: const Text(
                                //     "CHANGE",
                                //     style: TextStyle(
                                //       fontSize: 12,
                                //       fontWeight: FontWeight.bold,
                                //       color: Colors.orange,
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _buildNextButton(
                          "CONFIRM LOCATION", _proceedToAddressDetails),
                    ),
                  ],
                ),

                // Loading indicator
                if (_isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressDetailsStep() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildAddressDetailsHeader(),
          Expanded(
            child: Stack(
              children: [
                // Main content scrollview
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Selected address display at top
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black, width: 2),
                          boxShadow: const [
                            BoxShadow(offset: Offset(4, 4), color: Colors.black)
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on,
                                color: Colors.redAccent, size: 24),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _formattedAddress.isNotEmpty
                                        ? _formattedAddress
                                        : "Selected Location",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _streetController.text,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: _goBackToMap,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: Colors.orange, width: 1),
                                ),
                                child: const Text(
                                  "CHANGE",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Container(
                      //   padding: const EdgeInsets.all(12),
                      //   decoration: BoxDecoration(
                      //     color: Colors.yellow[50],
                      //     borderRadius: BorderRadius.circular(8),
                      //     border: Border.all(color: Colors.amber, width: 1.5),
                      //   ),
                      //   child: const Row(
                      //     children: [
                      //       Icon(Icons.info_outline, color: Colors.amber),
                      //       SizedBox(width: 8),
                      //       Expanded(
                      //         child: Text(
                      //           "A detailed address will help our Delivery Partner reach your doorstep easily",
                      //           style: TextStyle(fontSize: 13),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      const SizedBox(height: 20),
                      _buildAddressForm(),
                      const SizedBox(height: 32),
                      _buildNextButton("SAVE AND PROCEED", _saveAddress),
                      const SizedBox(height: 20), // Bottom padding
                    ],
                  ),
                ),

                // Loading indicator
                if (_isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: const [
            BoxShadow(offset: Offset(4, 4), color: Colors.black)
          ],
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildMapSelectionHeader() {
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
          const Expanded(
            child: Center(
              child: Text(
                "SELECT DELIVERY LOCATION",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: _getCurrentLocation,
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
              child: const Icon(Icons.my_location, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressDetailsHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: _goBackToMap,
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
          const Expanded(
            child: Center(
              child: Text(
                "ADD ADDRESS DETAILS",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
          const SizedBox(width: 40), // For balanced spacing
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      height: 500,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 16.0,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (controller) {
              _mapController = controller;
              _mapControllerCompleter.complete(controller);
              setState(() {
                _isMapInitialized = true;
                _updateMarker(_currentPosition);
              });
            },
            onCameraMove: _onCameraMove,
            onCameraIdle: _onCameraIdle,
            onTap: (position) {
              setState(() {
                _currentPosition = position;
                _updateMarker(position);
                _showPlaceResults =
                    false; // Hide search results when map is tapped
              });
              _getAddressFromLatLng(position);
            },
          ),

          // Message on map
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Order will be delivered here",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Center marker indicator when moving the map
          if (_isCameraMoving)
            const Center(
              child: Icon(
                Icons.location_on,
                color: Colors.red,
                size: 36,
              ),
            ),

          // Search bar at the top
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          decoration: const InputDecoration(
                            hintText: "Search for an address",
                            prefixIcon: Icon(Icons.search),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                          ),
                          onChanged: (value) {
                            print(value);
                            _searchPlaces(value);
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _showPlaceResults = false;
                            _placeResults = [];
                          });
                        },
                      ),
                    ],
                  ),
                ),

                // Search results
                if (_showPlaceResults && _placeResults.isNotEmpty)
                  Container(
                    height: 250,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _placeResults.length,
                      itemBuilder: (context, index) {
                        final prediction = _placeResults[index];
                        return GestureDetector(
                          onTap: () {
                            _getPlaceDetails(prediction.placeId);
                            _searchFocusNode.unfocus();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: index < _placeResults.length - 1
                                  ? Border(
                                      bottom: BorderSide(
                                          color: Colors.grey.shade300),
                                    )
                                  : null,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.location_on_outlined,
                                    size: 20, color: Colors.grey),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        prediction.mainText,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        prediction.secondaryText,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Map controls
          Positioned(
            right: 16,
            bottom: 80,
            child: Column(
              children: [
                // Zoom in button
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 2,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () {
                      _mapController?.animateCamera(CameraUpdate.zoomIn());
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(Icons.add, size: 24),
                    ),
                  ),
                ),

                // Zoom out button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 2,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () {
                      _mapController?.animateCamera(CameraUpdate.zoomOut());
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(Icons.remove, size: 24),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BrutalDecoration.brutalBox(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BrutalDecoration.brutalBox(),
            child: const Text(
              "Address Information",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Area field
          _buildTextField(
            readonly: false,
            controller: _landmarkController,
            label: "Area",
            icon: Icons.location_on,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Area cannot be empty";
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Landmark field
          _buildTextField(
            readonly: false,
            controller: _apartmentController,
            label: "Landmark",
            icon: Icons.tour,
          ),
          const SizedBox(height: 16),

          // Flat Number field
          _buildTextField(
            readonly: false,
            controller: _houseNumberController,
            label: "Flat Number",
            icon: Icons.home,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Flat number cannot be empty";
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // City field
          _buildTextField(
            readonly: false,
            controller: _cityController,
            label: "City",
            icon: Icons.location_city,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "City cannot be empty";
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // State field
          _buildTextField(
            readonly: false,
            controller: _stateController,
            label: "State",
            icon: Icons.map,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "State cannot be empty";
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Pincode field
          _buildTextField(
            readonly: false,
            controller: _zipCodeController,
            label: "Pincode",
            icon: Icons.pin_drop,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Pincode cannot be empty";
              }
              if (value.length != 6) {
                return "Pincode must be 6 digits";
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Delivery preferences section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BrutalDecoration.brutalBox(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.delivery_dining, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      "Delivery Preferences",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Checkbox(
                      value: _leaveAtDoor,
                      onChanged: (value) {
                        setState(() {
                          _leaveAtDoor = value!;
                        });
                      },
                    ),
                    const Text("Leave at door"),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Checkbox(
                      value: _avoidCalling,
                      onChanged: (value) {
                        setState(() {
                          _avoidCalling = value!;
                        });
                      },
                    ),
                    const Text("Avoid calling"),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Delivery instructions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BrutalDecoration.brutalBox(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.speaker_notes, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      "Delivery Instructions",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BrutalDecoration.brutalBox(),
                  child: TextFormField(
                    controller: _deliveryInstructionsController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText:
                          "e.g. Please leave near the door or under the mat",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Default address checkbox
          GestureDetector(
            onTap: () {
              setState(() {
                _isDefaultAddress = !_isDefaultAddress;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BrutalDecoration.brutalBox(
                color: _isDefaultAddress ? Colors.green : Colors.white,
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: _isDefaultAddress,
                    activeColor: Colors.green,
                    onChanged: (value) {
                      setState(() {
                        _isDefaultAddress = value!;
                      });
                    },
                  ),
                  const Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 8),
                  const Text(
                    "Mark as default address",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Address type selection
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BrutalDecoration.brutalBox(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.label, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      "Address Type",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildAddressTypeOption("Home", Icons.home),
                        _buildAddressTypeOption("Work", Icons.work),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildAddressTypeOption("Friend", Icons.person),
                        _buildAddressTypeOption("Others", Icons.other_houses),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required bool readonly,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black, width: 1.5),
            boxShadow: const [
              BoxShadow(offset: Offset(2, 2), color: Colors.black)
            ],
          ),
          child: TextFormField(
            readOnly: readonly,
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
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

// Helper method for address type option buttons

  Widget _buildAddressTypeOption(String type, IconData icon) {
    final isSelected = _addressType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _addressType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey[200] : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  const BoxShadow(
                    offset: Offset(2, 2),
                    color: Colors.black,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.black : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              type,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
