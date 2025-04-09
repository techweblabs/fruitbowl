// lib/profile/models/user_profile.dart
import 'package:flutter/material.dart';

class UserProfile {
  final String name;
  final String email;
  final String phoneNumber;
  final String profileImage;
  final String gender; // Added gender field
  final double bmi;
  final double weight;
  final double height;
  final List<UserAddress> addresses;
  final List<String> dietaryPreferences;
  final List<String> allergies;
  final String goalType; // Weight Loss, Maintenance, Weight Gain
  final double targetWeight;
  final double weeklyGoal;
  final String activityLevel; // Sedentary, Light, Moderate, Very Active
  final int age; // Added age field for more accurate calculations

  UserProfile({
    required this.name,
    required this.email,
    required this.profileImage,
    required this.gender,
    required this.bmi,
    required this.weight,
    required this.height,
    required this.phoneNumber,
    required this.age,
  })  : addresses = const [],
        dietaryPreferences = const [],
        allergies = const [],
        goalType = 'Maintenance',
        targetWeight = 0,
        weeklyGoal = 0,
        activityLevel = 'Sedentary';

  // Get BMI category
  String get bmiCategory {
    if (bmi < 18.5) {
      return "Underweight";
    } else if (bmi < 25) {
      return "Normal";
    } else if (bmi < 30) {
      return "Overweight";
    } else {
      return "Obese";
    }
  }

  // Get BMI category color
  Color get bmiColor {
    if (bmi < 18.5) {
      return Colors.blue;
    } else if (bmi < 25) {
      return Colors.green;
    } else if (bmi < 30) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  // Get ideal weight range
  String get idealWeightRange {
    // Simple calculation based on height (in cm)
    // This is a basic approximation and not medically accurate
    double minWeight = (height - 100) * 0.9;
    double maxWeight = (height - 100) * 1.1;
    return "${minWeight.toStringAsFixed(1)} - ${maxWeight.toStringAsFixed(1)} kg";
  }

  // Get weight to lose/gain
  double get weightDifference {
    return weight - targetWeight;
  }

  // Get estimated time to reach goal
  String get estimatedTimeToGoal {
    if (weeklyGoal <= 0) return "N/A";

    double absDifference = weightDifference.abs();
    int weeks = (absDifference / weeklyGoal).ceil();

    if (weeks < 4) {
      return "$weeks weeks";
    } else {
      int months = (weeks / 4).ceil();
      return "$months months";
    }
  }

  // Get default address
  UserAddress? get defaultAddress {
    try {
      return addresses.firstWhere((address) => address.isDefault);
    } catch (e) {
      return addresses.isNotEmpty ? addresses.first : null;
    }
  }

  // Calculate BMR (Basal Metabolic Rate)
  double get bmr {
    if (gender == 'Male') {
      return 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    } else {
      return 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    }
  }

  // Get activity multiplier
  double get activityMultiplier {
    switch (activityLevel) {
      case 'Sedentary':
        return 1.2;
      case 'Light':
        return 1.375;
      case 'Moderate':
        return 1.55;
      case 'Very Active':
        return 1.725;
      default:
        return 1.2;
    }
  }

  // Calculate maintenance calories
  double get maintenanceCalories {
    return bmr * activityMultiplier;
  }

  // Calculate recommended daily calories based on goal
  double get recommendedCalories {
    int goalAdjustment;

    switch (goalType) {
      case 'Weight Loss':
        goalAdjustment = -500; // 500 calorie deficit
        break;
      case 'Weight Gain':
        goalAdjustment = 500; // 500 calorie surplus
        break;
      default:
        goalAdjustment = 0; // Maintenance
    }

    return maintenanceCalories + goalAdjustment;
  }
}

class UserAddress {
  final int id;
  final String type; // Home, Work, Other
  final String line1;
  final String line2;
  final String city;
  final String state;
  final String pinCode;
  final bool isDefault;

  UserAddress({
    required this.id,
    required this.type,
    required this.line1,
    required this.line2,
    required this.city,
    required this.state,
    required this.pinCode,
    required this.isDefault,
  });

  // Get full address as string
  String get fullAddress {
    return "$line1, $line2, $city, $state - $pinCode";
  }

  // Short address
  String get shortAddress {
    return "$line1, $city";
  }
}
