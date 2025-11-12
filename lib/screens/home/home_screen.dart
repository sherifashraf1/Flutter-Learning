import 'package:flutter/material.dart';
import 'package:profile_demo_app_with_flutter/screens/firebase/book_list_screen.dart';
import 'package:profile_demo_app_with_flutter/screens/movies/movie_list_screen.dart';
import 'package:profile_demo_app_with_flutter/screens/todo/settings_screen.dart';
import 'package:profile_demo_app_with_flutter/screens/todo/tasks_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: const TabBarView(
          physics: NeverScrollableScrollPhysics(),
          children: [
            BookListScreen(),
            TasksScreen(),
            MoviesListScreen(),
            SettingsScreen()
          ],
        ),
        bottomNavigationBar: TabBar(
          tabs: const [
            Tab(icon: Icon(Icons.book), text: "Books"),
            Tab(icon: Icon(Icons.home), text: "Tasks"),
            Tab(icon: Icon(Icons.movie_creation_outlined), text: "Movies",),
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
