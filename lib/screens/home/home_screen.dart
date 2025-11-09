import 'package:flutter/material.dart';
import 'package:profile_demo_app_with_flutter/screens/todo/settings_screen.dart';
import 'package:profile_demo_app_with_flutter/screens/todo/tasks_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 2,
      child: Scaffold(
        body: TabBarView(children: [TasksScreen(), SettingsScreen()]),
        bottomNavigationBar: TabBar(
          tabs: [
            Tab(icon: Icon(Icons.home), text: "Home"),
            Tab(icon: Icon(Icons.settings), text: "Settings"),
          ],
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.transparent,
        ),
      ),
    );
  }
}
