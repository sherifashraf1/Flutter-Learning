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
  AdaptiveThemeMode currentThemeMode = AdaptiveThemeMode.light;
  
  // Load environment variables for services that use dotenv (BooksService, MoviesService, etc.)
  await dotenv.load(fileName: ".env");
  
  // Initialize Firebase only if it hasn't been initialized yet
  try {
    // Check if default Firebase app already exists
    Firebase.app();
  } catch (e) {
    // Default app doesn't exist, initialize it
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    } catch (initError) {
      // If initialization fails due to duplicate app, ignore it
      // This can happen during hot reload or if Firebase was auto-initialized
      if (!initError.toString().contains('duplicate-app')) {
        rethrow;
      }
    }
  }
  await Hive.initFlutter();

  // Open the boxes before the app starts to ensure they're ready
  await Hive.openBox('todosBox');
  await Hive.openBox('auditLogsBox');

  try {
    final savedThemeMode = await AdaptiveTheme.getThemeMode();
    currentThemeMode = savedThemeMode!;
  } catch (e) {
    currentThemeMode = AdaptiveThemeMode.light;
  }

  // sync errors (main thread)
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  // async errors (paltform specific errors, api request errors)
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(ProviderScope(child: MyApp(savedThemeMode: currentThemeMode)));
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
        title: "Todo Task Demo",
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