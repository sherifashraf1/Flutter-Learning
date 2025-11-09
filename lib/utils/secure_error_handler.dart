import 'package:flutter/foundation.dart';

class SecureErrorHandler {
  /// Returns a user-friendly error message while logging the actual error for debugging
  static String handleError(dynamic error, {String? context}) {
    // Log the actual error for debugging (only in debug mode)
    if (kDebugMode) {
      debugPrint('Error${context != null ? ' in $context' : ''}: $error');
    }
    
    // Return user-friendly messages based on error type
    if (error.toString().contains('SocketException') || 
        error.toString().contains('HandshakeException')) {
      return 'Please check your internet connection and try again.';
    }
    
    if (error.toString().contains('404')) {
      return 'The requested information could not be found.';
    }
    
    if (error.toString().contains('401') || error.toString().contains('403')) {
      return 'Access denied. Please try again later.';
    }
    
    if (error.toString().contains('500') || error.toString().contains('502') || 
        error.toString().contains('503')) {
      return 'Server is temporarily unavailable. Please try again later.';
    }
    
    if (error.toString().contains('TimeoutException')) {
      return 'Request timed out. Please try again.';
    }
    
    // Generic fallback message
    return 'Something went wrong. Please try again.';
  }
  
  /// Logs error details for debugging without exposing to users
  static void logError(dynamic error, {String? context, StackTrace? stackTrace}) {
    if (kDebugMode) {
      debugPrint('=== ERROR LOG ===');
      debugPrint('Context: ${context ?? 'Unknown'}');
      debugPrint('Error: $error');
      if (stackTrace != null) {
        debugPrint('StackTrace: $stackTrace');
      }
      debugPrint('=================');
    }
  }
}
