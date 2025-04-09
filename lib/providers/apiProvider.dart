import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../apiServices/apiApi.dart';
import '../screens/LocationFetchScreen/location_fetch_screen.dart';
import '../screens/ProfielScreen/models/user_profile.dart';
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
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final params = {
        'name': _name,
        'weight': _weight,
        'height': _height,
        'age': _age,
        'email': _email,
        'gender': _gender,
        'profile_image': "https://avatar.iran.liara.run/public/15",
      };
      final response = await apiApi().UpdateProfile(params);
      print(response);
      if (response['status'] == "OK") {
        prefs.setString('weight', response['details']['weight'].toString());
        prefs.setString('height', response['details']['height'].toString());
        prefs.setString('BMI', response['details']['BMI'].toString());
        prefs.setString(
            'contactNo', response['details']['contactNo'].toString());
        prefs.setString(
            'bmiCategory', response['details']['bmiCategory'].toString());
        prefs.setBool("Bmicheck", true);
        prefs.setString('name', response['details']['name'].toString());
        prefs.setString('email', response['details']['email'].toString());
        prefs.setString(
            'profileimage', response['details']['profile_image'].toString());
        prefs.setString('gender', response['details']['gender'].toString());
        prefs.setInt('age', response['details']['age']);
        UserProfile(
          age: prefs.getInt("age") ?? 1,
          phoneNumber: prefs.getString("contactNo") ?? "",
          name: prefs.getString('name').toString(),
          email: prefs.getString('email').toString(),
          profileImage: prefs.getString('profileimage').toString(),
          gender: prefs.getString('gender').toString(),
          bmi: double.tryParse(prefs.getString('BMI').toString()) ?? 0,
          weight: double.tryParse(prefs.getString('weight').toString()) ?? 0,
          height: double.tryParse(prefs.getString('height').toString()) ?? 0,
        );
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
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      final params = {
        'age': _age,
        'height': _height,
        'weight': _weight,
        'gender': _gender,
      };
      final response = await apiApi().CheckBmi(params);
      if (response['status'] == "OK") {
        prefs.setString('weight', response['details']['weight'].toString());
        prefs.setString('height', response['details']['height'].toString());
        prefs.setString('BMI', response['details']['BMI'].toString());
        prefs.setString(
            'bmiCategory', response['details']['bmiCategory'].toString());
        prefs.setBool("Bmicheck", true);
        prefs.setString('name', response['details']['name'].toString());
        prefs.setString('email', response['details']['email'].toString());
        prefs.setString(
            'profileimage', response['details']['profile_image'].toString());
      }
      print(response);
      return response;
    } catch (e) {
      print('Error: $e');
    }
  }
}
