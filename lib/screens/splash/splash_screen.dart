import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../router/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const double _logoWidthFactor = 0.6;
  static const double _logoHeightFactor = 0.6;

  final FirebaseAnalytics firebaseAnalytics = FirebaseAnalytics.instance;
  Future<void>? _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _init();
  }

  Future<void> _init() async {
    await Future<void>.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    
    final prefs = await SharedPreferences.getInstance();
    final String? email = prefs.getString("email");
    
    if (email != null) {
      await firebaseAnalytics.logEvent(
        name: "home_screen",
        parameters: {'time': DateTime.now().toIso8601String()},
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRouter.homeScreen);
    } else {
      await firebaseAnalytics.logEvent(
        name: "login_screen",
        parameters: {'time': DateTime.now().toIso8601String()},
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRouter.loginScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: _buildLogo(size),
    );
  }

  Widget _buildLogo(Size size) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logo = Image.asset(
      'assets/images/logo.png',
      width: size.width * _logoWidthFactor,
      height: size.height * _logoHeightFactor,
      fit: BoxFit.contain,
    );

    return Center(
      child: isDark
          ? ColorFiltered(
        colorFilter: const ColorFilter.mode(
          Colors.white,
          BlendMode.srcIn,
        ),
        child: logo,
      )
          : logo,
    );
  }
}
