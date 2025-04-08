import 'package:flutter/material.dart';
import 'package:flutter_starter_kit/screens/home/home_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationFetchScreenBody extends StatefulWidget {
  @override
  _LocationFetchScreenBodyState createState() =>
      _LocationFetchScreenBodyState();
}

class _LocationFetchScreenBodyState extends State<LocationFetchScreenBody> {
  String _locationString = "Fetching location...";

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // If not enabled, show a dialog asking the user to enable location services.
      _showLocationServiceDisabledDialog();
      return;
    }

    // Check location permissions.
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        // If still denied, show a dialog asking the user to grant permission.
        _showPermissionDeniedDialog();
        return;
      }
    }

    try {
      // Permissions granted. Get the current position.
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Convert lat/long to human-readable address.
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks.first;

      String humanReadableAddress = "";
      if (place.name != null && place.name!.isNotEmpty) {
        humanReadableAddress += place.name!;
      }
      if (place.street != null && place.street!.isNotEmpty) {
        humanReadableAddress += ", ${place.street!}";
      }
      if (place.locality != null && place.locality!.isNotEmpty) {
        humanReadableAddress += ", ${place.locality!}";
      }
      if (place.administrativeArea != null &&
          place.administrativeArea!.isNotEmpty) {
        humanReadableAddress += ", ${place.administrativeArea!}";
      }
      if (place.country != null && place.country!.isNotEmpty) {
        humanReadableAddress += ", ${place.country!}";
      }

      print(humanReadableAddress); // Print to console

      setState(() {
        _locationString = humanReadableAddress;
      });

      // After a short delay, navigate to the next screen.
      Future.delayed(const Duration(seconds: 2), () async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('location', _locationString);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      });
    } catch (e) {
      print("Error obtaining location: $e");
      setState(() {
        _locationString = "Error obtaining location.";
      });
    }
  }

  void _showLocationServiceDisabledDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildNeuBrutalismDialog(
        title: 'LOCATION SERVICES DISABLED',
        content: 'Please enable location services in your device settings.',
        actions: [
          _buildNeuBrutalismButton(
            label: 'SETTINGS',
            color: Colors.orange,
            onPressed: () async {
              await Geolocator.openLocationSettings();
              Navigator.of(context).pop();
              _determinePosition();
            },
          ),
          _buildNeuBrutalismButton(
            label: 'RETRY',
            color: Colors.cyan,
            onPressed: () async {
              Navigator.of(context).pop();
              _determinePosition();
            },
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildNeuBrutalismDialog(
        title: 'LOCATION PERMISSION DENIED',
        content: 'Please grant location permission to proceed.',
        actions: [
          _buildNeuBrutalismButton(
            label: 'SETTINGS',
            color: Colors.orange,
            onPressed: () async {
              await Geolocator.openAppSettings();
              Navigator.of(context).pop();
              _determinePosition();
            },
          ),
          _buildNeuBrutalismButton(
            label: 'RETRY',
            color: Colors.cyan,
            onPressed: () async {
              Navigator.of(context).pop();
              _determinePosition();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNeuBrutalismDialog({
    required String title,
    required String content,
    required List<Widget> actions,
  }) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 4),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(8, 8),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              content,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: actions,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNeuBrutalismButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.black, width: 3),
          borderRadius: BorderRadius.circular(4),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              offset: Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[100],
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 4),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                offset: Offset(10, 10),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "YOUR LOCATION",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.lime[100],
                  border: Border.all(color: Colors.black, width: 3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _locationString,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
              _buildNeuBrutalismProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNeuBrutalismProgressIndicator() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 3),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircularProgressIndicator(
          strokeWidth: 5,
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.pink),
          backgroundColor: Colors.grey[300],
        ),
      ),
    );
  }
}
