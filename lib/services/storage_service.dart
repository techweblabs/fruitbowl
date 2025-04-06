import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static late final SharedPreferences _prefs;
  
  // Initialize SharedPreferences
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  // String operations
  static Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }
  
  static String getString(String key, {String defaultValue = ''}) {
    return _prefs.getString(key) ?? defaultValue;
  }
  
  // Boolean operations
  static Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }
  
  static bool getBool(String key, {bool defaultValue = false}) {
    return _prefs.getBool(key) ?? defaultValue;
  }
  
  // Integer operations
  static Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }
  
  static int getInt(String key, {int defaultValue = 0}) {
    return _prefs.getInt(key) ?? defaultValue;
  }
  
  // Double operations
  static Future<bool> setDouble(String key, double value) async {
    return await _prefs.setDouble(key, value);
  }
  
  static double getDouble(String key, {double defaultValue = 0.0}) {
    return _prefs.getDouble(key) ?? defaultValue;
  }
  
  // Object operations - serialize to JSON
  static Future<bool> setObject(String key, Object value) async {
    return await _prefs.setString(key, jsonEncode(value));
  }
  
  static Map<String, dynamic>? getObject(String key) {
    final String? jsonString = _prefs.getString(key);
    if (jsonString == null) return null;
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }
  
  // List operations - serialize to JSON
  static Future<bool> setList(String key, List<dynamic> value) async {
    return await _prefs.setString(key, jsonEncode(value));
  }
  
  static List<dynamic>? getList(String key) {
    final String? jsonString = _prefs.getString(key);
    if (jsonString == null) return null;
    return jsonDecode(jsonString) as List<dynamic>;
  }
  
  // Check if key exists
  static bool hasKey(String key) {
    return _prefs.containsKey(key);
  }
  
  // Remove a specific key
  static Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }
  
  // Clear all data
  static Future<bool> clear() async {
    return await _prefs.clear();
  }
}
