import 'package:flutter/material.dart';
import '../apiServices/apiApi.dart';
import '../screens/LocationFetchScreen/location_fetch_screen.dart';
import '../services/storage_service.dart';
import '../utils/helpers/twl.dart';

class apiProvider with ChangeNotifier {
  String _profileImage = '';
  String get profileImage => _profileImage;
  set profileImage(String value) {
    _profileImage = value;
    notifyListeners();
  }

  int _gender = 0;
  int get gender => _gender;
  set gender(int value) {
    _gender = value;
    print("gender >>>>> $_gender");
    notifyListeners();
  }

  String _email = '';
  String get email => _email;
  set email(String value) {
    _email = value;
    notifyListeners();
  }

  String _age = '';
  String get age => _age;
  set age(String value) {
    _age = value;
    notifyListeners();
  }

  String _height = '';
  String get height => _height;
  set height(String value) {
    _height = value;
    notifyListeners();
  }

  String _weight = '';
  String get weight => _weight;
  set weight(String value) {
    _weight = value;
    notifyListeners();
  }

  String _name = '';
  String get name => _name;
  set name(String value) {
    _name = value;
    notifyListeners();
  }

  String _sessionCode = '';
  String get sessionCode => _sessionCode;
  set sessionCode(String value) {
    _sessionCode = value;
    print("Session code set to: $_sessionCode"); // Print to console
    notifyListeners();
  }

  String _otp = '';
  String get otp => _otp;
  set otp(String value) {
    _otp = value;
    notifyListeners();
  }

  String _contactNo = '';
  String get contactNo => _contactNo;
  set contactNo(String value) {
    _contactNo = value;
    print("contact no >>>> $_contactNo");
    notifyListeners();
  }

  Future SendOtp() async {
    try {
      final params = {
        'contactNo': _contactNo,
      };
      final response = await apiApi().SendOtp(params);
      print(response);
      sessionCode = response['details'];
      return response;
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> VerifyOtp() async {
    try {
      final params = {
        'contactNo': _contactNo,
        'otp': _otp,
        'session_code': _sessionCode,
      };
      final response = await apiApi().VerifyOtp(params);

      print(response);
      if (response['status'] == "OK") {
        // Navigate to home
        Twl.navigateToScreenClearStack(LocationFetchScreen());
        await StorageService.setBool('isLoggedIn', true);
        // Show success message
        Twl.showSuccessSnackbar('Successfully verified');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> UpdateProfile(BuildContext context) async {
    try {
      final params = {
        'name': _name,
        'weight': _weight,
        'height': _height,
        'age': _age,
        'email': _email,
        'gender': _gender,
        'profile_image':
            "https://www.google.com/url?sa=i&url=https%3A%2F%2Fpngtree.com%2Ffreepng%2Fuser-profile-avatar_13369988.html&psig=AOvVaw0WqYZF2RWdnr5LCXuqN1K5&ust=1744107133021000&source=images&cd=vfe&opi=89978449&ved=0CBEQjRxqFwoTCIjhkMPXxYwDFQAAAAAdAAAAABAJ",
      };
      final response = await apiApi().UpdateProfile(params);
      print(response);
      if (response['status'] == "OK") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text("Profile updated successfully"),
                ],
              ),
            ),
            backgroundColor: Colors.green[700],
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
      if (response['status'] == "NOK") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text("OOOPS"),
                ],
              ),
            ),
            backgroundColor: Colors.green[700],
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future CheckBmi() async {
    try {
      final params = {
        'age': _age,
        'height': _height,
        'weight': _weight,
        'gender': _gender,
      };
      final response = await apiApi().CheckBmi(params);
      print(response);
      return response;
    } catch (e) {
      print('Error: $e');
    }
  }
}
