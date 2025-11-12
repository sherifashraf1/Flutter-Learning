import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:profile_demo_app_with_flutter/router/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString("email");
    setState(() {
      _isLoggedIn = email != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Card(
            child: SwitchListTile(
              title: const Text("Dark Mode",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
              subtitle: const Text('Switch between light and dark theme',
                  style: TextStyle(fontSize: 14)),
              value: isDarkMode,
              onChanged: (value) {
                if (value) {
                  AdaptiveTheme.of(context).setDark();
                } else {
                  AdaptiveTheme.of(context).setLight();
                }
              },
              secondary: Icon(
                isDarkMode ? Icons.dark_mode : Icons.light_mode,
              ),
            ),
          ),
          
          // Show Profile only if user is logged in
          if (_isLoggedIn)
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, AppRouter.profile);
              },
              child: Card(
                child: Padding(padding: EdgeInsets.all(16),
                  child: Row(
                    children: const [
                      Icon(Icons.person),
                      SizedBox(width: 8),
                      Text("Profile", style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),)
                    ],
                  ),
                ),
              ),
            ),

          // Show Logout if logged in, Login if not logged in
          InkWell(
            onTap: () async {
              if (_isLoggedIn) {
                // Logout
                final prefs = await SharedPreferences.getInstance();
                prefs.remove("email");
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRouter.loginScreen,
                  (route) => false,
                );
              } else {
                // Login
                Navigator.pushNamed(context, AppRouter.loginScreen);
              }
            },
            child: Card(
              child: Padding(padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(_isLoggedIn ? Icons.logout : Icons.login),
                    const SizedBox(width: 8),
                    Text(
                      _isLoggedIn ? "Logout" : "Login",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}


