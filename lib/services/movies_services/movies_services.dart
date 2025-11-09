import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../utils/secure_error_handler.dart';
import '/models/movies_models/movie_details_model.dart';
import '../../models/movies_models/generic_response_model.dart';
import '../../models/movies_models/movie_model.dart';
import '../../models/movies_models/movie_credits_model.dart';

class MoviesService {
  final String? baseUrl = dotenv.env['BASE_URL'];
  final String? apiKey = dotenv.env['API_KEY'];

  Uri _buildUri(String path, [Map<String, String>? params]) {
    if (baseUrl == null || apiKey == null) {
      throw Exception('API configuration missing');
    }
    final queryParams = {
      'api_key' : apiKey!,
      if (params != null) ...params,
    };
      return Uri.parse('$baseUrl$path').replace(queryParameters: queryParams);
    }

  Future<GenericResponse<Movie>> getNowPlayingMovies(int page) async {
    final url = _buildUri('/movie/now_playing', {'page': '$page'});
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return GenericResponse<Movie>.fromJson(
          data,
          (json) => Movie.fromJson(json),
        );
      } else {
        throw Exception('Failed to fetch movies: ${response.statusCode}');
      }
    } catch (error) {
      SecureErrorHandler.logError(error, context: 'getNowPlayingMovies');
      throw Exception(
        SecureErrorHandler.handleError(error, context: 'getNowPlayingMovies'),
      );
    }
  }

  Future<MovieDetails> getMovieDetails(int movieId) async {
    final url = _buildUri("/movie/$movieId");
    await simulateNetworkDelay(Duration(seconds: 1));
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return MovieDetails.fromJson(data);
      } else {
        throw Exception(
          'Failed to fetch movie details: ${response.statusCode}',
        );
      }
    } catch (error) {
      SecureErrorHandler.logError(error, context: 'getMovieDetails');
      throw Exception(
        SecureErrorHandler.handleError(error, context: 'getMovieDetails'),
      );
    }
  }

  Future<MovieCredits> getActorsForMovie(int id) async {
    final url = _buildUri("/movie/$id/credits");
    await simulateNetworkDelay();
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
      throw Exception(
        SecureErrorHandler.handleError(error, context: 'getActorsForMovie'),
      );
    }
  }

  Future<GenericResponse<Movie>> getSimilarMovies(int id, int page) async {
    final url = _buildUri("/movie/$id/similar", {'page': '$page'});
    await simulateNetworkDelay();
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return GenericResponse<Movie>.fromJson(
          data,
          (json) => Movie.fromJson(json),
        );
      } else {
        throw Exception(
          'Failed to load similar movies: ${response.statusCode}',
        );
      }
    } catch (error) {
      SecureErrorHandler.logError(error, context: 'getSimilarMovies');
      throw Exception(
        SecureErrorHandler.handleError(error, context: 'getSimilarMovies'),
      );
    }
  }

  Future<GenericResponse<Movie>> getRecommendations(int id, int page) async {
    final url = _buildUri("/movie/$id/recommendations", {'page': '$page'});
    await simulateNetworkDelay();
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return GenericResponse<Movie>.fromJson(
          data,
          (json) => Movie.fromJson(json),
        );
      } else {
        throw Exception(
          'Failed to load recommendations: ${response.statusCode}',
        );
      }
    } catch (error) {
      SecureErrorHandler.logError(error, context: 'getRecommendations');
      throw Exception(
        SecureErrorHandler.handleError(error, context: 'getRecommendations'),
      );
    }
  }

  Future<void> simulateNetworkDelay([Duration duration = const Duration(seconds: 2)]) async {
    if (kDebugMode) await Future.delayed(duration);
  }
}
