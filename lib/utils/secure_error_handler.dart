import 'package:firebase_crashlytics/firebase_crashlytics.dart';
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
  
  /// Logs error details for debugging and monitoring
  /// - In debug mode: logs to console
  /// - In production: logs to Firebase Crashlytics for monitoring
  /// - Always captures stack trace when available for better debugging
  static void logError(
    dynamic error, {
    String? context,
    StackTrace? stackTrace,
    bool fatal = false,
    Map<String, dynamic>? additionalInfo,
  }) {
    final errorContext = context ?? 'Unknown';
    final errorMessage = error.toString();
    
    // Always log to console in debug mode
    if (kDebugMode) {
      debugPrint('=== ERROR LOG ===');
      debugPrint('Context: $errorContext');
      debugPrint('Error: $errorMessage');
      if (stackTrace != null) {
        debugPrint('StackTrace: $stackTrace');
      }
      if (additionalInfo != null) {
        debugPrint('Additional Info: $additionalInfo');
      }
      debugPrint('=================');
    }
    
    // Log to Firebase Crashlytics for production monitoring
    // This ensures errors are tracked even when UI handles them gracefully
    try {
      // Set custom key for context
      FirebaseCrashlytics.instance.setCustomKey('error_context', errorContext);
      
      // Add additional info as custom keys if provided
      if (additionalInfo != null) {
        additionalInfo.forEach((key, value) {
          FirebaseCrashlytics.instance.setCustomKey(key, value.toString());
        });
      }
      
      // Record error to Crashlytics
      // Use fatal: false for handled errors (non-fatal) so they don't crash the app
      // but are still tracked for monitoring
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace ?? StackTrace.current,
        fatal: fatal,
        reason: 'Error in $errorContext: $errorMessage',
      );
    } catch (e) {
      // Silently fail Crashlytics logging to not break the app
      // This can happen if Firebase isn't initialized or Crashlytics isn't available
      if (kDebugMode) {
        debugPrint('Failed to log to Crashlytics: $e');
      }
    }
  }
  
  /// Logs a non-fatal error (handled gracefully by UI)
  /// Use this for errors that are caught and handled by the UI
  static void logNonFatalError(
    dynamic error, {
    String? context,
    StackTrace? stackTrace,
    Map<String, dynamic>? additionalInfo,
  }) {
    logError(
      error,
      context: context,
      stackTrace: stackTrace,
      fatal: false,
      additionalInfo: additionalInfo,
    );
  }
  
  /// Logs a fatal error (should crash the app)
  /// Use this for unexpected errors that indicate a serious problem
  static void logFatalError(
    dynamic error, {
    String? context,
    StackTrace? stackTrace,
    Map<String, dynamic>? additionalInfo,
  }) {
    logError(
      error,
      context: context,
      stackTrace: stackTrace,
      fatal: true,
      additionalInfo: additionalInfo,
    );
  }
}
