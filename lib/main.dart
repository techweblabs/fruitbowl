import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:flutter/services.dart';
import 'package:flutter_starter_kit/providers/apiProvider.dart';
import 'package:flutter_starter_kit/providers/firestore_api_provider.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'providers/theme_provider.dart';
import 'services/storage_service.dart';
import 'services/translation_service.dart';
import 'utils/helpers/twl.dart';
import 'screens/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize other services
  await StorageService.init();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Get saved language
  final String languageCode = await TranslationService.getLanguage();

  // Run app
  runApp(MyApp(
      initialLocale: TranslationService.getLocaleFromString(languageCode)));
}

class MyApp extends StatelessWidget {
  final Locale initialLocale;

  const MyApp({Key? key, required this.initialLocale}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => apiProvider()),
            ChangeNotifierProvider(create: (_) => FirestoreApiProvider()),
          ],
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return GetMaterialApp(
                title: 'Flutter Starter Kit',
                debugShowCheckedModeBanner: false,
                navigatorKey: Twl.navigatorKey,
                theme: themeProvider.lightTheme,
                darkTheme: themeProvider.darkTheme,
                themeMode: themeProvider.themeMode,
                locale: initialLocale,
                translations: TranslationService(),
                fallbackLocale: TranslationService.ENGLISH_LOCALE,
                supportedLocales: TranslationService.supportedLocales,
                home: const SplashScreen(),
              );
            },
          ),
        );
      },
    );
  }
}
