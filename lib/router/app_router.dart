import 'package:flutter/material.dart';
import '../models/todo/todo_model.dart';
import '../screens/home/home_screen.dart';
import '../screens/movies/movie_details_screen.dart';
import '../screens/movies/movie_list_screen.dart';
import '../screens/todo/settings_screen.dart';
import '../screens/todo/task_details_screen.dart';
import '../screens/todo/tasks_screen.dart';

class AppRouter {
  // Route names
  static const moviesList = 'movies_list_screen';
  static const movieDetails = 'movie_details_screen';
  static const homeScreen = "home_screen";
  static const tasksList = 'tasks_list_screen';
  static const taskDetails = 'task_details_screen';
  static const settings = 'settings_screen';

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case moviesList:
        return MaterialPageRoute(builder: (_) => const MoviesListScreen());
      case movieDetails:
        final arguments = settings.arguments;
        if (arguments is int) {
          return MaterialPageRoute(
            builder: (_) => MovieDetailsScreen(movieId: arguments),
          );
        }
        return MaterialPageRoute(
          builder: (_) => _buildInvalidArgumentsScreen(),
        );
      case homeScreen:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case tasksList:
        return MaterialPageRoute(builder: (_) => TasksScreen());
      case taskDetails:
        final todo = settings.arguments;
        if (todo is Todo) {
          return MaterialPageRoute(
            builder: (_) => TaskDetailsScreen(todo: todo),
          );
        }
        return MaterialPageRoute(
          builder: (_) => _buildInvalidArgumentsScreen(),
        );
      case AppRouter.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      default:
        return MaterialPageRoute(builder: (_) => _buildRouteNotFoundScreen());
    }
  }

  static Widget _buildInvalidArgumentsScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text("Error", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                const Text(
                  "Invalid Argument",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  "Something went wrong.",
                  style: TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildRouteNotFoundScreen() {
    return Scaffold(body: Center(child: Text("Route not found")));
  }
}
