import 'package:flutter/material.dart';
import 'package:profile_demo_app_with_flutter/screens/auth/forget_password_screen.dart';
import 'package:profile_demo_app_with_flutter/screens/auth/login_screen.dart';
import 'package:profile_demo_app_with_flutter/screens/auth/registration_screen.dart';
import 'package:profile_demo_app_with_flutter/screens/firebase/book_list_screen.dart';
import 'package:profile_demo_app_with_flutter/screens/profile/profile_screen.dart';
import '../models/todo/todo_model.dart';
import '../screens/home/home_screen.dart';
import '../screens/movies/movie_details_screen.dart';
import '../screens/movies/movie_list_screen.dart';
import '../screens/todo/settings_screen.dart';
import '../screens/todo/task_details_screen.dart';
import '../screens/todo/tasks_screen.dart';

class AppRouter {
  // Route names
  static const loginScreen = "login_screen";
  static const registerScreen = "register_screen";
  static const forgetPasswordScreen = "forget_password_screen";
  static const moviesList = 'movies_list_screen';
  static const movieDetails = 'movie_details_screen';
  static const homeScreen = "home_screen";
  static const booksListScreen = "books_list_screen";
  static const tasksList = 'tasks_list_screen';
  static const taskDetails = 'task_details_screen';
  static const settingsScreen = 'settings_screen';
  static const profile = 'profile_screen';

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case loginScreen:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case registerScreen:
        return MaterialPageRoute(builder: (_) => const RegistrationScreen());
      case forgetPasswordScreen:
        return MaterialPageRoute(builder: (_) => const ForgetPasswordScreen());
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
      case booksListScreen:
        return MaterialPageRoute(builder: (_) => BookListScreen());
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
      case settingsScreen:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => ProfileScreen());
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
