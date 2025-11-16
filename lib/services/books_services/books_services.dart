import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../utils/secure_error_handler.dart';
import '../../models/books_models/book_model.dart';

class BooksService {
  final String? _baseUrl = dotenv.env['BOOKS_BASE_URL'];

  Future<BookResponse> getBooks({
    required String query,
    String? subject,
    int startIndex = 0,
    int maxResults = 20,
  }) async {
    try {
      final searchQuery = subject != null
          ? '$query+subject:${Uri.encodeComponent(subject)}'
          : query;
      final url = Uri.parse(
        '$_baseUrl/v1/volumes?q=$searchQuery&startIndex=$startIndex&maxResults=$maxResults',
      );

      // Debug log request
      if (kDebugMode) {
        debugPrint('***** [BooksService] GET Request: $url *****');
      }

      final response = await http.get(url);

      // Debug log response
      if (kDebugMode) {
        debugPrint('***** [BooksService] Response: *****');
        debugPrint('***** Status Code: ${response.statusCode} *****');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final items = data['items'] as List<dynamic>? ?? [];
        final books = items.map((item) => Book.fromJson(item)).toList();
        final totalItems = data['totalItems'] as int? ?? 0;

        // Debug log success
        if (kDebugMode) {
          debugPrint('***** [BooksService] Success: *****');
        }

        return BookResponse(
          books: books,
          totalItems: totalItems,
          startIndex: startIndex,
        );
      } else {
        throw Exception('Failed to fetch books: ${response.statusCode}');
      }
    } catch (error, stackTrace) {
      SecureErrorHandler.logNonFatalError(
        error,
        context: 'getBooks',
        stackTrace: stackTrace,
        additionalInfo: {
          'query': query,
          'subject': subject,
          'startIndex': startIndex,
          'maxResults': maxResults,
        },
      );
      throw Exception(
        SecureErrorHandler.handleError(error, context: 'getBooks'),
      );
    }
  }

  Future<Book> getBookDetails(String volumeId) async {
    try {
      final url = Uri.parse('$_baseUrl/v1/volumes/$volumeId');

      // Debug log request
      if (kDebugMode) {
        debugPrint('***** [BooksService] GET Book Details: $url *****');
      }

      final response = await http.get(url);

      // Debug log response
      if (kDebugMode) {
        debugPrint('***** [BooksService] Book Details Response: *****');
        debugPrint('***** Status Code: ${response.statusCode} *****');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final book = Book.fromJson(data);

        // Debug log success
        if (kDebugMode) {
          debugPrint('***** [BooksService] Book Details Success: *****');
        }

        return book;
      } else {
        throw Exception('Failed to fetch book details: ${response.statusCode}');
      }
    } catch (error, stackTrace) {
      SecureErrorHandler.logNonFatalError(
        error,
        context: 'getBookDetails',
        stackTrace: stackTrace,
        additionalInfo: {'volumeId': volumeId},
      );
      throw Exception(
        SecureErrorHandler.handleError(error, context: 'getBookDetails'),
      );
    }
  }
}
