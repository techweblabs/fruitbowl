import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import 'package:sizer/sizer.dart';
import '../../constants/theme_constants.dart';
import '../../services/connectivity_service.dart';

/// TWL (The Widget Library) - Common utility functions for the app
class Twl {
  /// Private constructor to prevent instantiation
  Twl._();

  /// Global navigator key for navigation without context
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  /// Get the current BuildContext
  static BuildContext? get currentContext => navigatorKey.currentContext;

  /// Get the current Theme
  static ThemeData get theme => Theme.of(currentContext!);

  /// Get MediaQuery data
  static MediaQueryData get mediaQuery => MediaQuery.of(currentContext!);

  /// Get screen size
  static Size get screenSize => mediaQuery.size;

  /// Get screen width
  static double get screenWidth => screenSize.width;

  /// Get screen height
  static double get screenHeight => screenSize.height;

  /// Connectivity service instance
 // static final ConnectivityService _connectivityService = ConnectivityService();

  /// Stream of connectivity changes
  // static Stream<bool> get connectivityStream =>
  //     _connectivityService.connectionChange;

  // /// Check connectivity status
  // static Future<bool> checkConnectivity() async {
  //   return await _connectivityService.isConnected();
  // }

  static void navigateToScreenAnimated(Widget page, {BuildContext? context}) {
    if (context == null) return;

    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, animation, __) => page,
        transitionsBuilder: (_, animation, __, child) {
          const begin = Offset(0.0, 1.0); // Slide from bottom
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          final tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  /// Navigate using MaterialPageRoute (direct navigation)
  static Future<dynamic> navigateToScreen(Widget screen) {
    return navigatorKey.currentState!.push(
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  /// Navigate using MaterialPageRoute and replace current screen
  static Future<dynamic> navigateToScreenReplace(Widget screen) {
    return navigatorKey.currentState!.pushReplacement(
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  /// Navigate using MaterialPageRoute and clear all previous screens
  static Future<dynamic> navigateToScreenClearStack(Widget screen) {
    return navigatorKey.currentState!.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => screen),
      (Route<dynamic> route) => false,
    );
  }

  /// Navigate to a named route
  static Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!
        .pushNamed(routeName, arguments: arguments);
  }

  /// Navigate to a route and replace the current one
  static Future<dynamic> navigateToReplace(String routeName,
      {Object? arguments}) {
    return navigatorKey.currentState!
        .pushReplacementNamed(routeName, arguments: arguments);
  }

  /// Navigate to a route and remove all previous routes
  static Future<dynamic> navigateToAndRemoveUntil(String routeName,
      {Object? arguments}) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(
        routeName, (Route<dynamic> route) => false,
        arguments: arguments);
  }

  /// Navigate back
  static void navigateBack({dynamic result}) {
    if (navigatorKey.currentState!.canPop()) {
      navigatorKey.currentState!.pop(result);
    }
  }

  /// Show a snackbar
  static void showSnackbar(
    String message, {
    Duration duration = const Duration(seconds: 3),
    Color backgroundColor = Colors.black87,
    Color textColor = Colors.white,
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(currentContext!).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: textColor),
        ),
        duration: duration,
        backgroundColor: backgroundColor,
        action: action,
      ),
    );
  }

  /// Show success snackbar
  static void showSuccessSnackbar(
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    showSnackbar(
      message,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      duration: duration,
      action: action,
    );
  }

  /// Show error snackbar
  static void showErrorSnackbar(
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    showSnackbar(
      message,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      duration: duration,
      action: action,
    );
  }

  /// Show a QuickAlert dialog
  static Future<bool?> showQuickAlert({
    required QuickAlertType type,
    String title = '',
    String text = '',
    bool showCancelBtn = false,
    String confirmBtnText = 'OK',
    String cancelBtnText = 'Cancel',
    VoidCallback? onConfirmBtnTap,
    VoidCallback? onCancelBtnTap,
    Widget? widget,
  }) async {
    return await QuickAlert.show(
      context: currentContext!,
      type: type,
      title: title,
      text: text,
      confirmBtnText: confirmBtnText,
      cancelBtnText: cancelBtnText,
      showCancelBtn: showCancelBtn,
      onConfirmBtnTap: onConfirmBtnTap,
      onCancelBtnTap: onCancelBtnTap,
      widget: widget,
    );
  }

  /// Show a success alert
  static Future<bool?> showSuccessAlert({
    String title = 'Success!',
    String text = 'Operation completed successfully',
    String confirmBtnText = 'OK',
    VoidCallback? onConfirmBtnTap,
  }) async {
    return await showQuickAlert(
      type: QuickAlertType.success,
      title: title,
      text: text,
      confirmBtnText: confirmBtnText,
      onConfirmBtnTap: onConfirmBtnTap,
    );
  }

  /// Show an error alert
  static Future<bool?> showErrorAlert({
    String title = 'Error!',
    String text = 'Something went wrong',
    String confirmBtnText = 'OK',
    VoidCallback? onConfirmBtnTap,
  }) async {
    return await showQuickAlert(
      type: QuickAlertType.error,
      title: title,
      text: text,
      confirmBtnText: confirmBtnText,
      onConfirmBtnTap: onConfirmBtnTap,
    );
  }

  /// Show a confirmation alert
  static Future<bool?> showConfirmationAlert({
    String title = 'Confirm',
    String text = 'Are you sure you want to proceed?',
    String confirmBtnText = 'Yes',
    String cancelBtnText = 'No',
    VoidCallback? onConfirmBtnTap,
    VoidCallback? onCancelBtnTap,
  }) async {
    return await showQuickAlert(
      type: QuickAlertType.confirm,
      title: title,
      text: text,
      confirmBtnText: confirmBtnText,
      cancelBtnText: cancelBtnText,
      showCancelBtn: true,
      onConfirmBtnTap: onConfirmBtnTap,
      onCancelBtnTap: onCancelBtnTap,
    );
  }

  /// Show a loading dialog
  static Future<bool?> showLoadingAlert({
    String title = 'Loading',
    String text = 'Please wait...',
  }) async {
    return await showQuickAlert(
      type: QuickAlertType.loading,
      title: title,
      text: text,
    );
  }

  /// Dismiss the current dialog
  static void dismissDialog() {
    if (navigatorKey.currentState!.canPop()) {
      navigatorKey.currentState!.pop();
    }
  }

  /// Show a loading overlay
  static OverlayEntry? loadingOverlay;

  static void showLoading({String message = 'Loading...'}) {
    if (loadingOverlay != null) {
      return;
    }

    loadingOverlay = OverlayEntry(
      builder: (context) => Container(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(5.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                SizedBox(height: 4.w),
                Text(message),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(currentContext!).insert(loadingOverlay!);
  }

  /// Hide the loading overlay
  static void hideLoading() {
    loadingOverlay?.remove();
    loadingOverlay = null;
  }

  /// Format a DateTime object to a string
  static String formatDateTime(DateTime dateTime,
      {String format = 'yyyy-MM-dd'}) {
    // Simple format implementation - for production, use intl package
    if (format == 'yyyy-MM-dd') {
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    } else if (format == 'dd/MM/yyyy') {
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
    } else if (format == 'HH:mm') {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
    return dateTime.toString();
  }

  /// Format a phone number
  static String formatPhoneNumber(String phoneNumber) {
    if (phoneNumber.length == 10) {
      return '${phoneNumber.substring(0, 3)}-${phoneNumber.substring(3, 6)}-${phoneNumber.substring(6)}';
    }
    return phoneNumber;
  }

  /// Validate an email address
  static bool isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegExp.hasMatch(email);
  }

  /// Validate a phone number
  static bool isValidPhoneNumber(String phoneNumber) {
    final phoneRegExp = RegExp(r'^\d{10}$');
    return phoneRegExp.hasMatch(phoneNumber);
  }

  /// Get initials from a name
  static String getInitials(String name) {
    List<String> nameParts = name.split(' ');
    String initials = '';

    if (nameParts.isNotEmpty) {
      if (nameParts[0].isNotEmpty) {
        initials += nameParts[0][0];
      }

      if (nameParts.length > 1 && nameParts[1].isNotEmpty) {
        initials += nameParts[1][0];
      }
    }

    return initials.toUpperCase();
  }

  /// Check if the device is in dark mode
  static bool get isDarkMode => theme.brightness == Brightness.dark;

  /// Get a color based on the current theme
  static Color getThemedColor(Color lightColor, Color darkColor) {
    return isDarkMode ? darkColor : lightColor;
  }

  /// Add delay to a function
  static Future<void> delay(int milliseconds) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
  }

  /// Responsive size helpers that use Sizer package
  static double get responsiveSmallText => 10.sp;
  static double get responsiveNormalText => 12.sp;
  static double get responsiveMediumText => 14.sp;
  static double get responsiveLargeText => 16.sp;
  static double get responsiveExtraLargeText => 18.sp;

  static double get responsiveIconSmall => 18.sp;
  static double get responsiveIconMedium => 24.sp;
  static double get responsiveIconLarge => 30.sp;

  static double get responsivePaddingSmall => 2.w;
  static double get responsivePaddingMedium => 4.w;
  static double get responsivePaddingLarge => 6.w;

  static double get responsiveMarginSmall => 1.h;
  static double get responsiveMarginMedium => 2.h;
  static double get responsiveMarginLarge => 3.h;

  static double get responsiveButtonHeight => 6.h;
  static double get responsiveCardRadius => 2.w;
}
