import 'dart:convert';
import 'package:http/http.dart' as http;
import '/models/movie_details_model.dart';
import '/models/generic_response_model.dart';
import '/models/movie_model.dart';
import '/models/movie_credits_model.dart';

class MoviesService {
  final String? baseUrl = 'https://api.themoviedb.org/3';
  final String? apiKey = '5af01490e5f50397189600f40cbce99f';

  Future<GenericResponse<Movie>> getNowPlayingMovies(int page) async {
    final url = Uri.parse('$baseUrl/movie/now_playing?api_key=$apiKey&page=$page');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return GenericResponse<Movie>.fromJson(
          jsonDecode(response.body), (json) => Movie.fromJson(json));
    } else {
      throw Exception(
          "Failed to fetch now playing movies: ${response.statusCode})");
    }
  }

  Future<MovieDetails> getMovieDetails(int movieId) async {
    final url = Uri.parse("$baseUrl/movie/$movieId?api_key=$apiKey");
    await Future.delayed(const Duration(seconds: 1));
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return MovieDetails.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to fetch movie details: ${response.statusCode}");
    }
  }

  Future<MovieCredits> getActorsForMovie(int id) async {
    await Future.delayed(const Duration(seconds: 2));
    final url = Uri.parse("$baseUrl/movie/$id/credits?api_key=$apiKey");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return MovieCredits.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to load credits");
    }
  }

  Future<GenericResponse<Movie>> getSimilarMovies(int id, int page) async {
    await Future.delayed(const Duration(seconds: 2));
    final url = Uri.parse('$baseUrl/movie/$id/similar?api_key=$apiKey&page=$page');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return GenericResponse<Movie>.fromJson(
          jsonDecode(response.body), (json) => Movie.fromJson(json));
    } else {
      throw Exception("Failed to load similar movies");
    }
  }

  Future<GenericResponse<Movie>> getRecommendations(int id, int page) async {
    await Future.delayed(const Duration(seconds: 2));
    final url = Uri.parse('$baseUrl/movie/$id/recommendations?api_key=$apiKey&page=$page');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return GenericResponse<Movie>.fromJson(
          jsonDecode(response.body), (json) => Movie.fromJson(json)
      );
    } else {
      throw Exception("Failed to load recommendations");
    }
  }
}