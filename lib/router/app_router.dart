import 'package:flutter/material.dart';
import '../screens/movies/movie_details_screen.dart';
import '../screens/movies/movie_list_screen.dart';

class AppRouter {
  // Route names
  static const moviesList = 'movies_list_screen';
  static const movieDetails = 'movie_details_screen';

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case moviesList:
        return MaterialPageRoute(builder: (_) => const MoviesListScreen());
      case movieDetails:
        final movieId = settings.arguments as int;
        return MaterialPageRoute(builder: (_) =>
            MovieDetailsScreen(movieId: movieId),
        );
      default:
        return MaterialPageRoute(builder: (_) =>
        const Scaffold(body: Center(child: Text("Route not found"))),
        );
    }
  }
}
