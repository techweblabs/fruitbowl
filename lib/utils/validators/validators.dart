// lib/utils/validators/validators.dart

/// A utility class for form validation
class Validators {
  Validators._();
  
  /// Validates if string is empty
  static String? validateRequired(String? value, {String? message}) {
    if (value == null || value.isEmpty) {
      return message ?? 'This field is required';
    }
    return null;
  }
  
  /// Validates email format
  static String? validateEmail(String? value, {String? message}) {
    if (value == null || value.isEmpty) {
      return message ?? 'Email is required';
    }
    
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(value)) {
      return message ?? 'Please enter a valid email address';
    }
    
    return null;
  }
  
  /// Validates phone number format
  static String? validatePhoneNumber(String? value, {String? message}) {
    if (value == null || value.isEmpty) {
      return message ?? 'Phone number is required';
    }
    
    // Basic validation for 10 digits
    final phoneRegExp = RegExp(r'^\d{10}$');
    if (!phoneRegExp.hasMatch(value)) {
      return message ?? 'Please enter a valid 10-digit phone number';
    }
    
    return null;
  }
  
  /// Validates password strength
  static String? validatePassword(String? value, {
    String? message,
    int minLength = 8,
    bool requireUppercase = true,
    bool requireLowercase = true,
    bool requireNumbers = true,
    bool requireSpecialChars = true,
  }) {
    if (value == null || value.isEmpty) {
      return message ?? 'Password is required';
    }
    
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    
    if (requireUppercase && !value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    
    if (requireLowercase && !value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    
    if (requireNumbers && !value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    
    if (requireSpecialChars && !value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    
    return null;
  }
  
  /// Validates if passwords match
  static String? validatePasswordMatch(String? password, String? confirmPassword) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    
    return null;
  }
  
  /// Validates OTP format
  static String? validateOtp(String? value, {int length = 6, String? message}) {
    if (value == null || value.isEmpty) {
      return message ?? 'OTP is required';
    }
    
    if (value.length != length) {
      return 'OTP must be $length digits';
    }
    
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'OTP must contain only digits';
    }
    
    return null;
  }
  
  /// Validates name format
  static String? validateName(String? value, {String? message}) {
    if (value == null || value.isEmpty) {
      return message ?? 'Name is required';
    }
    
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    return null;
  }
  
  /// Validates URL format
  static String? validateUrl(String? value, {String? message}) {
    if (value == null || value.isEmpty) {
      return null; // URL is optional
    }
    
    final urlRegExp = RegExp(
      r'^(http|https)://([\w-]+\.)+[\w-]+(/[\w- ./?%&=]*)?$',
      caseSensitive: false,
    );
    
    if (!urlRegExp.hasMatch(value)) {
      return message ?? 'Please enter a valid URL';
    }
    
    return null;
  }
  
  /// Validates date format
  static String? validateDate(String? value, {String? message}) {
    if (value == null || value.isEmpty) {
      return message ?? 'Date is required';
    }
    
    // Match date format: DD/MM/YYYY
    final dateRegex = RegExp(r'^(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[012])/\d{4}$');
    if (!dateRegex.hasMatch(value)) {
      return message ?? 'Please enter a valid date in DD/MM/YYYY format';
    }
    
    return null;
  }
  
  /// Validates number range
  static String? validateNumberRange(String? value, {
    double? min,
    double? max,
    String? message,
  }) {
    if (value == null || value.isEmpty) {
      return message ?? 'This field is required';
    }
    
    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }
    
    if (min != null && number < min) {
      return 'Value must be greater than or equal to $min';
    }
    
    if (max != null && number > max) {
      return 'Value must be less than or equal to $max';
    }
    
    return null;
  }
  
  /// Validates postal/zip code format (basic US/UK format)
  static String? validatePostalCode(String? value, {String? message}) {
    if (value == null || value.isEmpty) {
      return message ?? 'Postal code is required';
    }
    
    // Basic US/UK postal code pattern
    final postalRegex = RegExp(r'^[a-zA-Z0-9\s]{3,10}$');
    if (!postalRegex.hasMatch(value)) {
      return message ?? 'Please enter a valid postal code';
    }
    
    return null;
  }
  
  /// Validates username format
  static String? validateUsername(String? value, {
    int minLength = 3,
    int maxLength = 20,
    String? message,
  }) {
    if (value == null || value.isEmpty) {
      return message ?? 'Username is required';
    }
    
    if (value.length < minLength) {
      return 'Username must be at least $minLength characters';
    }
    
    if (value.length > maxLength) {
      return 'Username must not exceed $maxLength characters';
    }
    
    // Allow letters, numbers, underscore and hyphen
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_-]+$');
    if (!usernameRegex.hasMatch(value)) {
      return 'Username can only contain letters, numbers, underscores and hyphens';
    }
    
    return null;
  }
  
  /// Validates credit card number using Luhn algorithm
  static String? validateCreditCard(String? value, {String? message}) {
    if (value == null || value.isEmpty) {
      return message ?? 'Credit card number is required';
    }
    
    // Remove spaces and hyphens
    final sanitized = value.replaceAll(RegExp(r'[\s-]'), '');
    
    if (!RegExp(r'^\d{13,19}$').hasMatch(sanitized)) {
      return 'Please enter a valid credit card number';
    }
    
    // Luhn algorithm
    int sum = 0;
    bool alternate = false;
    for (int i = sanitized.length - 1; i >= 0; i--) {
      int n = int.parse(sanitized.substring(i, i + 1));
      if (alternate) {
        n *= 2;
        if (n > 9) {
          n = (n % 10) + 1;
        }
      }
      sum += n;
      alternate = !alternate;
    }
    
    if (sum % 10 != 0) {
      return 'Please enter a valid credit card number';
    }
    
    return null;
  }
}
