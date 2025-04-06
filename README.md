# Flutter Starter Kit

A complete Flutter starter kit with essential components and helpers for quick project setup.

## Features

- Provider state management
- Theme switching (Light/Darkmode)
- Internationalization with GetX
- Phone number authentication with OTP
- Splash and Onboarding screens
- Network connectivity handling
- Shimmer loading effects
- QuickAlert dependency based alerts
- Google Fonts integration
- Responsive UI with Sizer
- Bottom Navigation
- Utility helpers (TWL - The Widget Library)
- Form validation

## Project Structure

```
lib/
├── components/         # Reusable UI components
├── constants/          # App constants
├── models/             # Data models
├── providers/          # Provider state management
├── screens/            # App screens
│   ├── auth/           # Authentication screens
│   ├── home/           # Home and tab screens
│   ├── onboarding/     # Onboarding screens
│   ├── profile/        # Profile screens
│   ├── settings/       # Settings screens
│   └── splash/         # Splash screen
├── services/           # Services
├── utils/              # Utilities and helpers
└── main.dart           # Entry point
```

## Getting Started

1. Clone this repository
2. Run `flutter pub get` to install dependencies
3. Run the app using `flutter run`

## Dependencies

- provider: State management
- get: Routing and internationalization
- shared_preferences: Local storage
- connectivity_plus: Network connectivity
- shimmer: Loading effects
- quickalert: Alert dialogs
- google_fonts: Custom fonts
- sizer: Responsive UI design
- And more...

## How to Use This Starter Kit

### Theming
Use the ThemeProvider to modify the light and dark themes of your app:
```dart
// Toggle between light and dark theme
context.read<ThemeProvider>().toggleTheme();

// Check if the current theme is dark
bool isDark = context.watch<ThemeProvider>().isDarkMode;
```

### Translations
Change the app language using the TranslationService:
```dart
// Change to Spanish
TranslationService.changeLocale(TranslationService.SPANISH);

// Use translations
Text('hello'.tr);
```

### Navigation
Use the TWL utility class for navigation:
```dart
// Navigate to a screen
Twl.navigateToScreen(const SecondScreen());

// Go back
Twl.navigateBack();
```

### Alerts and Dialogs
Show alerts using the TWL utility class:
```dart
// Show success alert
Twl.showSuccessAlert(title: 'Success', text: 'Operation completed');

// Show error snackbar
Twl.showErrorSnackbar('Something went wrong');
```

### Responsive Design
Use Sizer for responsive UI:
```dart
// Font sizes
Text('Hello', style: TextStyle(fontSize: 14.sp));

// Paddings and margins
Padding(padding: EdgeInsets.all(4.w), child: ...);

// Responsive heights
Container(height: 10.h, ...);
```

## License

This project is licensed under the MIT License.
