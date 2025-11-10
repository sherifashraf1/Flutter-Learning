import 'package:flutter/material.dart';
import 'package:profile_demo_app_with_flutter/screens/todo/settings_screen.dart';
import 'package:profile_demo_app_with_flutter/screens/todo/tasks_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: const TabBarView(children: [TasksScreen(), SettingsScreen()]),
        bottomNavigationBar: TabBar(
          tabs: const [
            Tab(icon: Icon(Icons.home), text: "Home"),
            Tab(icon: Icon(Icons.settings), text: "Settings"),
          ],
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          indicatorColor: Colors.transparent,
        ),
      ),
    );
  }
}
