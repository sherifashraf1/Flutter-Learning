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

  // Constants
  static const double _logoWidthFactor = 0.6;
  static const double _logoHeightFactor = 0.6;

  FirebaseAnalytics firebaseAnalytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    init();
    super.initState();
  }

 void init() async {
    Future.delayed(const Duration(seconds: 3), () async {
      final prefs = await SharedPreferences.getInstance();
      String? email = prefs.getString("email");
      if (email != null) {
        firebaseAnalytics.logEvent(name: "Home screen", parameters: {'time': DateTime.now().toIso8601String()});
        Navigator.pushReplacementNamed(context, AppRouter.homeScreen);
      } else {
        firebaseAnalytics.logEvent(name: "Login screen", parameters: {'time': DateTime.now().toIso8601String()});
        Navigator.pushReplacementNamed(context, AppRouter.loginScreen);
      }
    });
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
