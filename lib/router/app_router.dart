import 'package:flutter/material.dart';
import '../screens/movies/movie_list_screen.dart';

class AppRouter {
  // Route names
  static const moviesList = 'movies_list_screen';

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case moviesList:
        return MaterialPageRoute(builder: (_) => MoviesListScreen());
      default:
        return MaterialPageRoute(builder: (_) =>
        const Scaffold(body: Center(child: Text("Route not found"))),
        );
    }
  }
}
