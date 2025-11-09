import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:profile_demo_app_with_flutter/router/app_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = AdaptiveTheme.of(context).mode == AdaptiveThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
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
          SizedBox(height: 12),
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, AppRouter.profile);
            },
            child: Card(
              child: Padding(padding: EdgeInsets.all(16),
                child: Row(
                  spacing: 8,
                  children: [
                    Icon(Icons.person),
                    Text("Profile", style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),)
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


