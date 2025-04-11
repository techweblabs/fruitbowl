import 'dart:developer';

import 'package:flutter_starter_kit/apiConstants.dart';
import 'package:quickapi/quickapi.dart';

import 'package:shared_preferences/shared_preferences.dart';

class apiApi {
  final QuickApi _api = QuickApi(baseUrl: ApiConstants.baseUrl);

  Future<dynamic> SendOtp(Map<String, dynamic> params) async {
    try {
      final result = await _api.typePost(ApiConstants.SEND_OTP, params);
      print('URL >>>>>>>${ApiConstants.SEND_OTP}');
      return result;
    } catch (e) {
      throw Exception('Error: \function(){i.e(t,r,s,arguments)}');
    }
  }

  Future<dynamic> VerifyOtp(Map<String, dynamic> params) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      final result = await _api.typePost(ApiConstants.VERIFY_OTP, params);
      print('URL >>>>>>>${ApiConstants.VERIFY_OTP}');
      if (result['status'] == "OK") {
        prefs.setString('authcode', result['details']['authCode']);
      }
      return result;
    } catch (e) {
      throw Exception('Error: \function(){i.e(t,r,s,arguments)}');
    }
  }

  Future<dynamic> UpdateProfile(Map<String, dynamic> params) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String authCode = prefs.getString('authcode').toString();

    try {
      Map<String, String> headers = {
        'authCode': authCode,
        'Content-Type': 'application/json',
      };
      final result = await _api.typePost(ApiConstants.UPDATE_PROFILE, params,
          headers: headers);
      print('URL >>>>>>>${ApiConstants.UPDATE_PROFILE}');
      return result;
    } catch (e) {
      print(e);
      throw Exception('Error: \function(){i.e(t,r,s,arguments)}');
    }
  }

  Future<dynamic> CheckBmi(Map<String, dynamic> params) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String authCode = prefs.getString('authcode').toString();

    try {
      Map<String, String> headers = {
        'authCode': authCode,
        'Content-Type': 'application/json',
      };
      final result =
          await _api.typePost(ApiConstants.CHECK_BMI, params, headers: headers);
      print('URL >>>>>>>${ApiConstants.CHECK_BMI}');
      print("Authcode>>>>>>>>$headers");

      return result;
    } catch (e) {
      throw Exception('Error: \function(){i.e(t,r,s,arguments)}');
    }
  }

  Future<dynamic> AddAddress(Map<String, dynamic> params) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String authCode = prefs.getString('authcode').toString();
    try {
      Map<String, String> headers = {
        'authCode': authCode,
        'Content-Type': 'application/json',
      };
      log("$authCode");
   

      final result = await _api.typePost(ApiConstants.ADD_ADDRESS, params,
          headers: headers);
      return result;
    } catch (e) {
      throw Exception('Error: \function(){i.e(t,r,s,arguments)}');
    }
  }

  Future<dynamic> GetAddress() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String authCode = prefs.getString('authcode').toString();
    try {
      Map<String, String> headers = {
        'authCode': authCode,
        'Content-Type': 'application/json',
      };
      log("$authCode");
      
      final result =
          await _api.typeGet(ApiConstants.GET_ADDRESS, headers: headers);
      return result;
    } catch (e) {
      throw Exception('Error: \function(){i.e(t,r,s,arguments)}');
    }
  }

  Future<dynamic> DeleteAddress(Map<String, dynamic> params) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String authCode = prefs.getString('authcode').toString();

    try {
      Map<String, String> headers = {
        'authCode': authCode,
        'Content-Type': 'application/json',
      };

      print('AuthCode >>>>>>> $authCode');
      print('URL >>>>>>> ${ApiConstants.DELETE_ADDRESS}');
      print("params >>>>>>>>>>>>> $params");

      final result = await _api.typePost(
        ApiConstants.DELETE_ADDRESS,
        params,
        headers: headers,
      );

      return result;
    } catch (e) {
      print("DeleteAddress error: $e");
      throw Exception('Error while deleting address: $e');
    }
  }

  Future<dynamic> UpdateAddress(Map<String, dynamic> params) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String authCode = prefs.getString('authcode').toString();
    try {
      Map<String, String> headers = {
        'authCode': authCode,
        'Content-Type': 'application/json',
      };
      print('AuthCode >>>>>>> $authCode');
      print('URL >>>>>>> ${ApiConstants.UPDATE_ADDRESS}');
      print("params >>>>>>>>>>>>> $params");
      final result = await _api.typePost(
        ApiConstants.UPDATE_ADDRESS,
        params,
        headers: headers,
      );
      return result;
    } catch (e) {
      throw Exception('Error: \function(){i.e(t,r,s,arguments)}');
    }
  }
}
