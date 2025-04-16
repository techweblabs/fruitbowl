import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TranslationService extends Translations {
  static const String LANGUAGE_KEY = 'language_key';
  static const String ENGLISH = 'en';
  static const String SPANISH = 'es';
  static const String FRENCH = 'fr';
  static const String ARABIC = 'ar';

  static const Locale ENGLISH_LOCALE = Locale('en', 'US');
  static const Locale SPANISH_LOCALE = Locale('es', 'ES');
  static const Locale FRENCH_LOCALE = Locale('fr', 'FR');
  static const Locale ARABIC_LOCALE = Locale('ar', 'SA');

  static final List<Locale> supportedLocales = [
    ENGLISH_LOCALE,
    SPANISH_LOCALE,
    FRENCH_LOCALE,
    ARABIC_LOCALE,
  ];

  static final Map<String, Map<String, String>> translationsKeys = {
    'en_US': {
      'hello': 'Hello',
      'welcome': 'Welcome to Flutter Starter Kit',
      'continue': 'Continue',
      'skip': 'Skip',
      'next': 'Next',
      'getStarted': 'Get Started',
      'login': 'Login',
      'register': 'Register',
      'phoneNumber': 'Phone Number',
      'enterPhoneNumber': 'Enter your phone number',
      'enterOtp': 'Enter OTP',
      'verifyOtp': 'Verify OTP',
      'resendOtp': 'Resend OTP',
      'verifyingOtp': 'Verifying OTP...',
      'profile': 'Profile',
      'editProfile': 'Edit Profile',
      'settings': 'Settings',
      'changeTheme': 'Change Theme',
      'darkMode': 'Dark Mode',
      'lightMode': 'Light Mode',
      'changeLanguage': 'Change Language',
      'english': 'English',
      'spanish': 'Spanish',
      'french': 'French',
      'arabic': 'Arabic',
      'logout': 'Logout',
      'logoutConfirm': 'Are you sure you want to logout?',
      'yes': 'Yes',
      'no': 'No',
      'cancel': 'Cancel',
      'save': 'Save',
      'done': 'Done',
      'error': 'Error',
      'success': 'Success',
      'warning': 'Warning',
      'info': 'Information',
      'noInternet': 'No Internet Connection',
      'tryAgain': 'Try Again',
      'somethingWentWrong': 'Something went wrong',
      'pleaseTryAgain': 'Please try again later',
      'home': 'Home',
      'explore': 'Explore',
      'my_orders': 'My Orders',
      'favorites': 'Favorites',
      'account': 'Account',
      'testFeatures': 'Test Features',
      'darkTheme': 'Dark Theme',
      'changeLanguage': 'Change Language',
      'testConnectivity': 'Test Connectivity',
      'testAlerts': 'Test Alerts',
    },
    'es_ES': {
      'hello': 'Hola',
      'welcome': 'Bienvenido a Flutter Starter Kit',
      'continue': 'Continuar',
      'skip': 'Omitir',
      'next': 'Siguiente',
      'getStarted': 'Comenzar',
      'login': 'Iniciar Sesión',
      'register': 'Registrarse',
      'phoneNumber': 'Número de Teléfono',
      'enterPhoneNumber': 'Ingrese su número de teléfono',
      'enterOtp': 'Ingrese OTP',
      'verifyOtp': 'Verificar OTP',
      'resendOtp': 'Reenviar OTP',
      'verifyingOtp': 'Verificando OTP...',
      'profile': 'Perfil',
      'editProfile': 'Editar Perfil',
      'settings': 'Configuración',
      'changeTheme': 'Cambiar Tema',
      'darkMode': 'Modo Oscuro',
      'lightMode': 'Modo Claro',
      'changeLanguage': 'Cambiar Idioma',
      'english': 'Inglés',
      'spanish': 'Español',
      'french': 'Francés',
      'arabic': 'Árabe',
      'logout': 'Cerrar Sesión',
      'logoutConfirm': '¿Estás seguro de que quieres cerrar sesión?',
      'yes': 'Sí',
      'no': 'No',
      'cancel': 'Cancelar',
      'save': 'Guardar',
      'done': 'Hecho',
      'error': 'Error',
      'success': 'Éxito',
      'warning': 'Advertencia',
      'info': 'Información',
      'noInternet': 'Sin Conexión a Internet',
      'tryAgain': 'Intentar de Nuevo',
      'somethingWentWrong': 'Algo salió mal',
      'pleaseTryAgain': 'Por favor, inténtelo de nuevo más tarde',
      'home': 'Inicio',
      'explore': 'Explorar',
      'favorites': 'Favoritos',
      'account': 'Cuenta',
      'testFeatures': 'Probar Funciones',
      'darkTheme': 'Tema Oscuro',
      'changeLanguage': 'Cambiar Idioma',
      'testConnectivity': 'Probar Conectividad',
      'testAlerts': 'Probar Alertas',
    },
    'fr_FR': {
      'hello': 'Bonjour',
      'welcome': 'Bienvenue sur Flutter Starter Kit',
      'continue': 'Continuer',
      'skip': 'Passer',
      'next': 'Suivant',
      'getStarted': 'Commencer',
      'login': 'Connexion',
      'register': 'S\'inscrire',
      'phoneNumber': 'Numéro de Téléphone',
      'enterPhoneNumber': 'Entrez votre numéro de téléphone',
      'enterOtp': 'Entrez OTP',
      'verifyOtp': 'Vérifier OTP',
      'resendOtp': 'Renvoyer OTP',
      'verifyingOtp': 'Vérification OTP...',
      'profile': 'Profil',
      'editProfile': 'Modifier le Profil',
      'settings': 'Paramètres',
      'changeTheme': 'Changer de Thème',
      'darkMode': 'Mode Sombre',
      'lightMode': 'Mode Clair',
      'changeLanguage': 'Changer de Langue',
      'english': 'Anglais',
      'spanish': 'Espagnol',
      'french': 'Français',
      'arabic': 'Arabe',
      'logout': 'Déconnexion',
      'logoutConfirm': 'Êtes-vous sûr de vouloir vous déconnecter?',
      'yes': 'Oui',
      'no': 'Non',
      'cancel': 'Annuler',
      'save': 'Enregistrer',
      'done': 'Terminé',
      'error': 'Erreur',
      'success': 'Succès',
      'warning': 'Avertissement',
      'info': 'Information',
      'noInternet': 'Pas de Connexion Internet',
      'tryAgain': 'Réessayer',
      'somethingWentWrong': 'Quelque chose s\'est mal passé',
      'pleaseTryAgain': 'Veuillez réessayer plus tard',
      'home': 'Accueil',
      'explore': 'Explorer',
      'favorites': 'Favoris',
      'account': 'Compte',
      'testFeatures': 'Tester Fonctionnalités',
      'darkTheme': 'Thème Sombre',
      'changeLanguage': 'Changer de Langue',
      'testConnectivity': 'Tester la Connectivité',
      'testAlerts': 'Tester les Alertes',
    },
    'ar_SA': {
      'hello': 'مرحبا',
      'welcome': 'مرحبًا بك في Flutter Starter Kit',
      'continue': 'استمر',
      'skip': 'تخطى',
      'next': 'التالي',
      'getStarted': 'البدء',
      'login': 'تسجيل الدخول',
      'register': 'تسجيل',
      'phoneNumber': 'رقم الهاتف',
      'enterPhoneNumber': 'أدخل رقم هاتفك',
      'enterOtp': 'أدخل رمز التحقق',
      'verifyOtp': 'تحقق من الرمز',
      'resendOtp': 'إعادة إرسال الرمز',
      'verifyingOtp': 'جاري التحقق من الرمز...',
      'profile': 'الملف الشخصي',
      'editProfile': 'تعديل الملف الشخصي',
      'settings': 'الإعدادات',
      'changeTheme': 'تغيير المظهر',
      'darkMode': 'الوضع الداكن',
      'lightMode': 'الوضع الفاتح',
      'changeLanguage': 'تغيير اللغة',
      'english': 'الإنجليزية',
      'spanish': 'الإسبانية',
      'french': 'الفرنسية',
      'arabic': 'العربية',
      'logout': 'تسجيل الخروج',
      'logoutConfirm': 'هل أنت متأكد أنك تريد تسجيل الخروج؟',
      'yes': 'نعم',
      'no': 'لا',
      'cancel': 'إلغاء',
      'save': 'حفظ',
      'done': 'تم',
      'error': 'خطأ',
      'success': 'نجاح',
      'warning': 'تحذير',
      'info': 'معلومات',
      'noInternet': 'لا يوجد اتصال بالإنترنت',
      'tryAgain': 'حاول مرة أخرى',
      'somethingWentWrong': 'حدث خطأ ما',
      'pleaseTryAgain': 'يرجى المحاولة مرة أخرى لاحقًا',
      'home': 'الرئيسية',
      'explore': 'استكشاف',
      'favorites': 'المفضلة',
      'account': 'الحساب',
      'testFeatures': 'اختبار الميزات',
      'darkTheme': 'المظهر الداكن',
      'changeLanguage': 'تغيير اللغة',
      'testConnectivity': 'اختبار الاتصال',
      'testAlerts': 'اختبار التنبيهات',
    },
  };

  @override
  Map<String, Map<String, String>> get keys => translationsKeys;

  // Get locale name
  static String getLocaleName(String localeKey) {
    switch (localeKey) {
      case ENGLISH:
        return 'English';
      case SPANISH:
        return 'Spanish';
      case FRENCH:
        return 'French';
      case ARABIC:
        return 'Arabic';
      default:
        return 'English';
    }
  }

  // Get locale from string
  static Locale getLocaleFromString(String localeKey) {
    switch (localeKey) {
      case ENGLISH:
        return ENGLISH_LOCALE;
      case SPANISH:
        return SPANISH_LOCALE;
      case FRENCH:
        return FRENCH_LOCALE;
      case ARABIC:
        return ARABIC_LOCALE;
      default:
        return ENGLISH_LOCALE;
    }
  }

  // Save selected language
  static Future<void> saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(LANGUAGE_KEY, language);
  }

  // Get saved language
  static Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(LANGUAGE_KEY) ?? ENGLISH;
  }

  // Change locale
  static Future<void> changeLocale(String languageCode) async {
    final locale = getLocaleFromString(languageCode);
    await saveLanguage(languageCode);
    Get.updateLocale(locale);
  }
}
