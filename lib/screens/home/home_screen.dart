import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:profile_demo_app_with_flutter/screens/firebase/book_list_screen.dart';
import 'package:profile_demo_app_with_flutter/screens/movies/movie_list_screen.dart';
import 'package:profile_demo_app_with_flutter/screens/todo/settings_screen.dart';
import 'package:profile_demo_app_with_flutter/screens/todo/tasks_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoggedIn = false;
  int _tabLength = 4;

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
      _tabLength = _isLoggedIn ? 4 : 3; // Hide Tasks tab if not logged in
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabLength,
      child: Scaffold(
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: _buildTabViews(),
        ),
        bottomNavigationBar: TabBar(
          tabs: _buildTabs(),
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          indicatorColor: Colors.transparent,
        ),
      ),
    );
  }

  List<Widget> _buildTabViews() {
    if (_isLoggedIn) {
      return const [
        BookListScreen(),
        TasksScreen(),
        MoviesListScreen(),
        SettingsScreen(),
      ];
    } else {
      return const [
        BookListScreen(),
        MoviesListScreen(),
        SettingsScreen(),
      ];
    }
  }

  List<Widget> _buildTabs() {
    if (_isLoggedIn) {
      return const [
        Tab(icon: Icon(Icons.book), text: "Books"),
        Tab(icon: Icon(Icons.home), text: "Tasks"),
        Tab(icon: Icon(Icons.movie_creation_outlined), text: "Movies"),
        Tab(icon: Icon(Icons.settings), text: "Settings"),
      ];
    } else {
      return const [
        Tab(icon: Icon(Icons.book), text: "Books"),
        Tab(icon: Icon(Icons.movie_creation_outlined), text: "Movies"),
        Tab(icon: Icon(Icons.settings), text: "Settings"),
      ];
    }
  }
}
