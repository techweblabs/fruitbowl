import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import '../constants/theme_constants.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  // Always return light mode regardless of the stored value.
  ThemeMode get themeMode => ThemeMode.light;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    // Although this loads from your service, its value is overridden in the getter.
    _themeMode = await ThemeService.getThemeMode();
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await ThemeService.setThemeMode(mode);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode = await ThemeService.toggleTheme();
    notifyListeners();
  }

  // Override isDarkMode to always return false so that the light theme is enforced.
  bool get isDarkMode => false;

  // Create light theme
  ThemeData get lightTheme {
    return ThemeData(
      primaryColor: ThemeConstants.primaryColorLight,
      colorScheme: const ColorScheme.light(
        primary: ThemeConstants.primaryColorLight,
        secondary: ThemeConstants.accentColorLight,
        error: ThemeConstants.errorColorLight,
        surface: ThemeConstants.surfaceColorLight,
        background: ThemeConstants.backgroundColorLight,
      ),
      scaffoldBackgroundColor: ThemeConstants.backgroundColorLight,
      fontFamily: GoogleFonts.poppins().fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: ThemeConstants.primaryColorLight,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: ThemeConstants.textColorLight,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: ThemeConstants.textColorLight,
        ),
        displaySmall: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: ThemeConstants.textColorLight,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: ThemeConstants.textColorLight,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16,
          color: ThemeConstants.textColorLight,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          color: ThemeConstants.textColorLight,
        ),
      ),
      iconTheme: const IconThemeData(
        color: ThemeConstants.primaryColorLight,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeConstants.primaryColorLight,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: ThemeConstants.paddingRegular,
            vertical: ThemeConstants.paddingRegular,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(ThemeConstants.borderRadiusRegular),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ThemeConstants.primaryColorLight,
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ThemeConstants.primaryColorLight,
          side: const BorderSide(color: ThemeConstants.primaryColorLight),
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: ThemeConstants.paddingRegular,
            vertical: ThemeConstants.paddingRegular,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(ThemeConstants.borderRadiusRegular),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(ThemeConstants.borderRadiusRegular),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(ThemeConstants.borderRadiusRegular),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(ThemeConstants.borderRadiusRegular),
          borderSide: const BorderSide(
              color: ThemeConstants.primaryColorLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(ThemeConstants.borderRadiusRegular),
          borderSide: const BorderSide(color: ThemeConstants.errorColorLight),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ThemeConstants.paddingRegular,
          vertical: ThemeConstants.paddingRegular,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(ThemeConstants.borderRadiusRegular),
        ),
      ),
    );
  }

  // The darkTheme is left intact, but will never be used.
  ThemeData get darkTheme {
    return ThemeData(
      primaryColor: ThemeConstants.primaryColorDark,
      colorScheme: const ColorScheme.dark(
        primary: ThemeConstants.primaryColorDark,
        secondary: ThemeConstants.accentColorDark,
        error: ThemeConstants.errorColorDark,
        surface: ThemeConstants.surfaceColorDark,
        background: ThemeConstants.backgroundColorDark,
      ),
      scaffoldBackgroundColor: ThemeConstants.backgroundColorDark,
      fontFamily: GoogleFonts.poppins().fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: ThemeConstants.surfaceColorDark,
        foregroundColor: ThemeConstants.textColorDark,
        elevation: 0,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: ThemeConstants.textColorDark,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: ThemeConstants.textColorDark,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: ThemeConstants.textColorDark,
        ),
        displaySmall: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: ThemeConstants.textColorDark,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: ThemeConstants.textColorDark,
        ),
        bodyLarge: GoogleFonts.poppins(
          fontSize: 16,
          color: ThemeConstants.textColorDark,
        ),
        bodyMedium: GoogleFonts.poppins(
          fontSize: 14,
          color: ThemeConstants.textColorDark,
        ),
      ),
      iconTheme: const IconThemeData(
        color: ThemeConstants.primaryColorDark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ThemeConstants.primaryColorDark,
          foregroundColor: Colors.black,
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: ThemeConstants.paddingRegular,
            vertical: ThemeConstants.paddingRegular,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(ThemeConstants.borderRadiusRegular),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ThemeConstants.primaryColorDark,
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ThemeConstants.primaryColorDark,
          side: const BorderSide(color: ThemeConstants.primaryColorDark),
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: ThemeConstants.paddingRegular,
            vertical: ThemeConstants.paddingRegular,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(ThemeConstants.borderRadiusRegular),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ThemeConstants.surfaceColorDark,
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(ThemeConstants.borderRadiusRegular),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(ThemeConstants.borderRadiusRegular),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(ThemeConstants.borderRadiusRegular),
          borderSide: const BorderSide(
              color: ThemeConstants.primaryColorDark, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(ThemeConstants.borderRadiusRegular),
          borderSide: const BorderSide(color: ThemeConstants.errorColorDark),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ThemeConstants.paddingRegular,
          vertical: ThemeConstants.paddingRegular,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(ThemeConstants.borderRadiusRegular),
        ),
        color: ThemeConstants.surfaceColorDark,
      ),
    );
  }
}
