import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/secure_error_handler.dart';
import '/models/movie_details_model.dart';
import '/models/generic_response_model.dart';
import '/models/movie_model.dart';
import '/models/movie_credits_model.dart';

class MoviesService {
  final String baseUrl = 'https://api.themoviedb.org/3';
  final String apiKey = '5af01490e5f50397189600f40cbce99f';

  Future<GenericResponse<Movie>> getNowPlayingMovies(int page) async {
    final url = Uri.parse('$baseUrl/movie/now_playing?api_key=$apiKey&page=$page');
    
    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return GenericResponse<Movie>.fromJson(data, (json) => Movie.fromJson(json));
      } else {
        throw Exception('Failed to fetch movies: ${response.statusCode}');
      }
    } catch (error) {
      SecureErrorHandler.logError(error, context: 'getNowPlayingMovies');
      throw Exception(SecureErrorHandler.handleError(error, context: 'getNowPlayingMovies'));
    }
  }

  Future<MovieDetails> getMovieDetails(int movieId) async {
    final url = Uri.parse("$baseUrl/movie/$movieId?api_key=$apiKey");
    
    await Future.delayed(const Duration(seconds: 1));
    
    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return MovieDetails.fromJson(data);
      } else {
        throw Exception('Failed to fetch movie details: ${response.statusCode}');
      }
    } catch (error) {
      SecureErrorHandler.logError(error, context: 'getMovieDetails');
      throw Exception(SecureErrorHandler.handleError(error, context: 'getMovieDetails'));
    }
  }

  Future<MovieCredits> getActorsForMovie(int id) async {
    final url = Uri.parse("$baseUrl/movie/$id/credits?api_key=$apiKey");
    
    await Future.delayed(const Duration(seconds: 2));
    
    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return MovieCredits.fromJson(data);
      } else {
        throw Exception('Failed to load credits: ${response.statusCode}');
      }
    } catch (error) {
      SecureErrorHandler.logError(error, context: 'getActorsForMovie');
      throw Exception(SecureErrorHandler.handleError(error, context: 'getActorsForMovie'));
    }
  }

  Future<GenericResponse<Movie>> getSimilarMovies(int id, int page) async {
    final url = Uri.parse('$baseUrl/movie/$id/similar?api_key=$apiKey&page=$page');
    
    await Future.delayed(const Duration(seconds: 2));
    
    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return GenericResponse<Movie>.fromJson(data, (json) => Movie.fromJson(json));
      } else {
        throw Exception('Failed to load similar movies: ${response.statusCode}');
      }
    } catch (error) {
      SecureErrorHandler.logError(error, context: 'getSimilarMovies');
      throw Exception(SecureErrorHandler.handleError(error, context: 'getSimilarMovies'));
    }
  }

  Future<GenericResponse<Movie>> getRecommendations(int id, int page) async {
    final url = Uri.parse('$baseUrl/movie/$id/recommendations?api_key=$apiKey&page=$page');
    
    await Future.delayed(const Duration(seconds: 2));
    
    try {
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return GenericResponse<Movie>.fromJson(data, (json) => Movie.fromJson(json));
      } else {
        throw Exception('Failed to load recommendations: ${response.statusCode}');
      }
    } catch (error) {
      SecureErrorHandler.logError(error, context: 'getRecommendations');
      throw Exception(SecureErrorHandler.handleError(error, context: 'getRecommendations'));
    }
  }
}
