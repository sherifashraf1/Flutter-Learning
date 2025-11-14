import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:profile_demo_app_with_flutter/firebase_options.dart';
import 'package:profile_demo_app_with_flutter/router/app_router.dart';
import 'package:profile_demo_app_with_flutter/widgets/todo/keyboard_dismisser.dart';
import 'package:profile_demo_app_with_flutter/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await _initializeApp();
  
  final themeMode = await _loadThemeMode();
  _setupErrorHandling();
  
  runApp(ProviderScope(child: MyApp(savedThemeMode: themeMode)));
}

/// Initializes all app dependencies
Future<void> _initializeApp() async {
  await _loadEnvironmentVariables();
  await _initializeFirebase();
  await _initializeHive();
}

/// Loads environment variables from .env file
Future<void> _loadEnvironmentVariables() async {
  await dotenv.load(fileName: ".env");
}

/// Initializes Firebase if not already initialized
Future<void> _initializeFirebase() async {
  try {
    // Check if default Firebase app already exists
    Firebase.app();
  } catch (_) {
    // Default app doesn't exist, initialize it
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (error) {
      // Ignore duplicate app errors (can happen during hot reload)
      if (!error.toString().contains('duplicate-app')) {
        rethrow;
      }
    }
  }
}

/// Initializes Hive and opens required boxes
Future<void> _initializeHive() async {
  await Hive.initFlutter();
  await Future.wait([
    Hive.openBox('todosBox'),
    Hive.openBox('auditLogsBox'),
  ]);
}

/// Loads the saved theme mode or returns light as default
Future<AdaptiveThemeMode> _loadThemeMode() async {
  try {
    final savedThemeMode = await AdaptiveTheme.getThemeMode();
    return savedThemeMode ?? AdaptiveThemeMode.light;
  } catch (_) {
    return AdaptiveThemeMode.light;
  }
}

/// Sets up global error handling for Crashlytics
void _setupErrorHandling() {
  // Sync errors (main thread)
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  // Async errors (platform specific errors, API request errors)
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
}

class MyApp extends StatelessWidget {
  final AdaptiveThemeMode savedThemeMode;

  const MyApp({super.key, required this.savedThemeMode});

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: AppTheme.buildLightTheme(),
      dark: AppTheme.buildDarkTheme(),
      initial: savedThemeMode,
      builder: (theme, darkTheme) => MaterialApp(
        title: "Flutter Learning",
        theme: theme,
        darkTheme: darkTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: AppRouter.splashScreen,
        onGenerateRoute: AppRouter.generateRoute,
        builder: (context, child) {
          return KeyboardDismisser(child: child!);
        },
      ),
    );
  }
}