import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String themeKey = 'theme_mode';
  
  // Get the current theme mode
  static Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(themeKey) ?? 0;
    return ThemeMode.values[themeIndex];
  }
  
  // Save the theme mode
  static Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(themeKey, mode.index);
  }
  
  // Toggle between light and dark theme
  static Future<ThemeMode> toggleTheme() async {
    final currentMode = await getThemeMode();
    final newMode = currentMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newMode);
    return newMode;
  }
  
  // Check if the theme is dark
  static Future<bool> isDarkMode() async {
    final currentMode = await getThemeMode();
    return currentMode == ThemeMode.dark;
  }
}
