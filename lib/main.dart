import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:profile_demo_app_with_flutter/router/app_router.dart';
import 'package:profile_demo_app_with_flutter/widgets/todo/keyboard_dismisser.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AdaptiveThemeMode currentThemeMode = AdaptiveThemeMode.light;

  await dotenv.load(fileName: ".env");
  await Hive.initFlutter();

  // Open the box before the app starts to ensure it's ready
  await Hive.openBox('todosBox');

  try {
    final savedThemeMode = await AdaptiveTheme.getThemeMode();
    currentThemeMode = savedThemeMode!;
  } catch (e) {
    currentThemeMode = AdaptiveThemeMode.light;
  }

  runApp(ProviderScope(child: MyApp(savedThemeMode: currentThemeMode)));
}

class MyApp extends StatelessWidget {
  final AdaptiveThemeMode savedThemeMode;

  const MyApp({super.key, required this.savedThemeMode});

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF00BFA5),
          onPrimary: Colors.white,
          secondary: Color(0xFF26A69A),
          onSecondary: Colors.white,
          surface: Colors.white,
          onSurface: Color(0xFF1A1A1A),
          onSurfaceVariant: Color(0xFF424242),
          error: Color(0xFFD32F2F),
          onError: Colors.white,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          bodyMedium: TextStyle(
            color: Color(0xFF424242),
          ),
        ),
      ),
      dark: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: const ColorScheme.dark(
          primary: Colors.greenAccent,
          onPrimary: Colors.white,
          secondary: Color(0xFF26A69A),
          onSecondary: Colors.white,
          surface: Color(0xFF1E293B),
          onSurface: Colors.white,
          onSurfaceVariant: Color(0xFF424242),
          error: Color(0xFFD32F2F),
          onError: Colors.white,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          bodyMedium: TextStyle(
            color: Colors.white70,
          ),
        ),
      ),
      initial: savedThemeMode,
      builder: (theme, darkTheme) => MaterialApp(
        title: "Todo Task Demo",
        theme: theme,
        darkTheme: darkTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: AppRouter.homeScreen,
        onGenerateRoute: AppRouter.generateRoute,
        builder: (context, child) {
          return KeyboardDismisser(child: child!);
        },
      ),
    );
  }
}