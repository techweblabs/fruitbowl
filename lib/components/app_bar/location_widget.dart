import 'package:flutter/material.dart';
import 'package:flutter_starter_kit/apiServices/apiApi.dart';
import 'package:flutter_starter_kit/screens/AddressScreen/components/add_address_page.dart';
import 'package:flutter_starter_kit/utils/brutal_decoration.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationWidget extends StatefulWidget {
  final String initialLocation;
  final Function(String)? onLocationChanged;

  const LocationWidget({
    Key? key,
    required this.initialLocation,
    this.onLocationChanged,
  }) : super(key: key);

  @override
  State<LocationWidget> createState() => _LocationWidgetState();
}

class _LocationWidgetState extends State<LocationWidget> {
  late String currentLocation;
  List<Map<String, dynamic>>? userAddresses;
  String? _selectedAddressId;
  bool _isLoadingInitialLocation = false;

  @override
  void initState() {
    super.initState();
    currentLocation = widget.initialLocation;

    // Only fetch addresses on first load, but don't auto-select or change anything
    if (userAddresses == null) {
      _prefetchAddresses();
    }
  }

  @override
  void didUpdateWidget(LocationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update currentLocation if initialLocation changes
    if (oldWidget.initialLocation != widget.initialLocation) {
      setState(() {
        currentLocation = widget.initialLocation;
      });
    }
  }

  // This just loads the addresses in the background but doesn't change the selection
  Future<void> _prefetchAddresses() async {
    if (_isLoadingInitialLocation) return;

    setState(() {
      _isLoadingInitialLocation = true;
    });

    try {
      await getAddress();
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingInitialLocation = false;
        });
      }
    }
  }

  Future<void> getAddress() async {
    try {
      var res = await apiApi().GetAddress();

      if (res['status'] == 'OK' && res['details'] != null) {
        if (mounted) {
          setState(() {
            userAddresses = List<Map<String, dynamic>>.from(res['details']);

            // If we have a saved address, find its ID
            if (currentLocation.isNotEmpty && userAddresses != null) {
              final matchingAddress = userAddresses!.firstWhere(
                (addr) => addr['fullAddress'] == currentLocation,
                orElse: () => {'_id': null},
              );
              _selectedAddressId = matchingAddress['_id'];
            }
          });
        }
      } else {
        print('Error: ${res['message']}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  void _showAddressBottomSheet() async {
    // Fetch addresses if not already loaded
    if (userAddresses == null) {
      await getAddress();
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        child: const Text(
                          'Select Your Address',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
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
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BrutalDecoration.miniButton(),
                            child: const Icon(Icons.add, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Addresses list
                  Expanded(
                    child: userAddresses != null
                        ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: userAddresses!.length,
                            itemBuilder: (context, index) {
                              final address = userAddresses![index];
                              final isDefault = address['isDefault'];
                              final isHome = (address['addressType'] ?? '')
                                      .toLowerCase() ==
                                  'home';
                              final isSelected =
                                  _selectedAddressId == address['_id'];

                              return GestureDetector(
                                onTap: () async {
                                  setState(() {
                                    _selectedAddressId = address['_id'];
                                  });

                                  // Update the current location in the parent widget
                                  final fullAddress =
                                      address['fullAddress'] ?? '';
                                  this.setState(() {
                                    currentLocation = fullAddress;
                                  });

                                  // Save to SharedPreferences
                                  final SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setString(
                                      'location', fullAddress);

                                  // Notify parent widget if callback exists
                                  if (widget.onLocationChanged != null) {
                                    widget.onLocationChanged!(fullAddress);
                                  }

                                  // Close the bottom sheet
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.black,
                                        width: isSelected ? 2 : 1),
                                    color: isSelected
                                        ? Colors.yellow[100]
                                        : isDefault
                                            ? Colors.green[50]
                                            : Colors.white,
                                    boxShadow: const [
                                      BoxShadow(
                                          offset: Offset(3, 3),
                                          color: Colors.black)
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.grey[200],
                                                border: Border.all(
                                                    color: Colors.black),
                                              ),
                                              child: Icon(
                                                isHome
                                                    ? Icons.home
                                                    : Icons.work,
                                                color: Colors.blue,
                                                size: 16,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              address['addressType'] ??
                                                  'Address',
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(width: 8),
                                            if (isDefault)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
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
                                        const SizedBox(height: 8),
                                        Text(
                                          address['fullAddress'] ?? '',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : const Center(child: CircularProgressIndicator()),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: _showAddressBottomSheet,
      child: Row(
        children: [
          Container(
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
            child: const Icon(
              Icons.location_on,
              color: Colors.black,
              size: 24,
            ),
          ),
          const SizedBox(width: 8),

          // Add a fixed max width so text doesn't overflow the Row
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: screenWidth * 0.65, // Adjust this to fit your layout
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Location',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  currentLocation.isEmpty
                      ? 'Tap to select location'
                      : currentLocation,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
