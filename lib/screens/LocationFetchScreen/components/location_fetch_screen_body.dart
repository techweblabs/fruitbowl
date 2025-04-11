import 'package:flutter/material.dart';
import 'package:flutter_starter_kit/screens/home/home_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

import '../../../providers/firestore_api_provider.dart';

class LocationFetchScreenBody extends StatefulWidget {
  @override
  _LocationFetchScreenBodyState createState() =>
      _LocationFetchScreenBodyState();
}

class _LocationFetchScreenBodyState extends State<LocationFetchScreenBody>
    with SingleTickerProviderStateMixin {
  String _locationString = "Fetching location...";
  late AnimationController _animationController;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    loadfirestoreapidata();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    // Start location process
    _determinePosition();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void loadfirestoreapidata() async {
    var pro = Provider.of<FirestoreApiProvider>(context, listen: false);
    await pro.fetchFruitBowls();
    await pro.fetchrecommededfruitbowls();
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
            color: const Color(0xFF8ECAE6),
            onPressed: () async {
              await Geolocator.openLocationSettings();
              Navigator.of(context).pop();
              _determinePosition();
            },
          ),
          _buildNeuBrutalismButton(
            label: 'RETRY',
            color: const Color(0xFF219EBC),
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
            color: const Color(0xFF8ECAE6),
            onPressed: () async {
              await Geolocator.openAppSettings();
              Navigator.of(context).pop();
              _determinePosition();
            },
          ),
          _buildNeuBrutalismButton(
            label: 'RETRY',
            color: const Color(0xFF219EBC),
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
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main dialog content
          Container(
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
                // Title with background
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8ECAE6).withOpacity(0.3),
                    border: Border.all(color: Colors.black, width: 3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
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
        ],
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
      child: Transform.translate(
        offset: const Offset(0, 0),
        child: Stack(
          children: [
            // Button shadow
            Transform.translate(
              offset: const Offset(4, 4),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            // Button itself
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: color,
                border: Border.all(color: Colors.black, width: 3),
                borderRadius: BorderRadius.circular(4),
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
          ],
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8ECAE6), Color(0xFF219EBC), Color(0xFF023047)],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: EnhancedBackgroundPainter(),
            ),
          ),
          CustomPaint(
            size: Size(
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height,
            ),
            painter: DoodlePainter(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with gradient
          _buildBackground(),

          // Main content
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Shadow container (offset)
                Transform.translate(
                  offset: const Offset(12, 12),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.85,
                    height: MediaQuery.of(context).size.height * 0.4,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                // Main container
                Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  padding:
                      const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title with bold styling
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8ECAE6).withOpacity(0.3),
                          border: Border.all(color: Colors.black, width: 3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "YOUR LOCATION",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Location display
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black, width: 3),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black,
                              offset: Offset(4, 4),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Text(
                          _locationString,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF023047),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Animated progress indicator
                      _buildAnimatedProgressIndicator(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedProgressIndicator() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 3),
            borderRadius: BorderRadius.circular(35),
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
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  strokeWidth: 6,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color(0xFF219EBC)),
                  backgroundColor: Colors.grey[200],
                ),
                // Add a small ping animation
                Opacity(
                  opacity: 1 - _animationController.value,
                  child: Container(
                    width: 20 + 15 * _animationController.value,
                    height: 20 + 15 * _animationController.value,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8ECAE6).withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF219EBC),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Enhanced Background Painter
class EnhancedBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Add geometric patterns for neu brutalism aesthetic
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw grid lines
    final gridSpacing = 60.0;
    for (double i = 0; i < size.width; i += gridSpacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }

    for (double i = 0; i < size.height; i += gridSpacing) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }

    // Draw circles at intersections
    final dotPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    for (double x = 0; x < size.width; x += gridSpacing) {
      for (double y = 0; y < size.height; y += gridSpacing) {
        canvas.drawCircle(Offset(x, y), 3, dotPaint);
      }
    }

    // Draw some larger decorative elements
    final decorPaint = Paint()
      ..color = Colors.white.withOpacity(0.07)
      ..style = PaintingStyle.fill;

    // Add a few larger circles
    canvas.drawCircle(
        Offset(size.width * 0.2, size.height * 0.3), 50, decorPaint);
    canvas.drawCircle(
        Offset(size.width * 0.8, size.height * 0.7), 70, decorPaint);

    // Add a few rectangles
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.1, size.height * 0.6, 100, 100),
      decorPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.7, size.height * 0.2, 120, 80),
      decorPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Doodle Painter for fun elements
class DoodlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // Draw some doodle elements

    // Location pin
    final path1 = Path();
    final pinX = size.width * 0.15;
    final pinY = size.height * 0.15;

    path1.moveTo(pinX, pinY);
    path1.addOval(Rect.fromCircle(center: Offset(pinX, pinY), radius: 15));
    path1.moveTo(pinX, pinY + 15);
    path1.quadraticBezierTo(pinX, pinY + 40, pinX - 20, pinY + 50);

    // Compass
    final compassX = size.width * 0.85;
    final compassY = size.height * 0.2;

    final path2 = Path();
    path2.addOval(
        Rect.fromCircle(center: Offset(compassX, compassY), radius: 25));
    path2.moveTo(compassX, compassY - 25);
    path2.lineTo(compassX, compassY + 25);
    path2.moveTo(compassX - 25, compassY);
    path2.lineTo(compassX + 25, compassY);

    // Map route
    final path3 = Path();
    path3.moveTo(size.width * 0.2, size.height * 0.8);
    path3.lineTo(size.width * 0.3, size.height * 0.7);
    path3.lineTo(size.width * 0.5, size.height * 0.75);
    path3.lineTo(size.width * 0.7, size.height * 0.65);
    path3.lineTo(size.width * 0.8, size.height * 0.8);

    // Draw all paths
    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
    canvas.drawPath(path3, paint);

    // Add some stars/sparkles
    final sparkle = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.3), 3, sparkle);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.4), 2, sparkle);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.7), 4, sparkle);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.5), 2, sparkle);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.3), 3, sparkle);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
