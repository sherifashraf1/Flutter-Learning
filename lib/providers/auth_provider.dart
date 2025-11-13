import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../shared/empty_state/data_state.dart';
import '../shared-enums/shared_enums.dart';
import '../services/firebase_services/firebase_services.dart';
import '../utils/secure_error_handler.dart';

// Login Provider
final loginStateProvider = StateNotifierProvider<LoginNotifier, DataState<void>>((ref) {
  return LoginNotifier();
});

class LoginNotifier extends StateNotifier<DataState<void>> {
  LoginNotifier() : super(DataState.success(null));

  Future<void> login(String email, String password) async {
    state = DataState.loading(LoadingType.overlayLoading);

    try {
      await FirebaseServices.signIn(email.trim(), password.trim());
      final prefs = await SharedPreferences.getInstance();
      final user = FirebaseAuth.instance.currentUser;
      
      // Save user data from Firebase
      await prefs.setString("email", user?.email ?? email);
      await prefs.setString("name", user?.displayName ?? '');
      await prefs.setString("profileImageUrl", user?.photoURL ?? '');
      
      state = DataState.success(null);
    } catch (e) {
      SecureErrorHandler.logError(e, context: 'login');
      state = DataState.error(
        title: "Login Failed",
        description: SecureErrorHandler.handleError(e, context: 'login'),
        onRetry: () => login(email, password),
        errorType: ErrorType.alert,
      );
    }
  }
}

// Registration Provider
final registrationStateProvider = StateNotifierProvider<RegistrationNotifier, DataState<void>>((ref) {
  return RegistrationNotifier();
});

class RegistrationNotifier extends StateNotifier<DataState<void>> {
  RegistrationNotifier() : super(DataState.success(null));

  Future<void> register(String email, String password) async {
    state = DataState.loading(LoadingType.overlayLoading);

    try {
      await FirebaseServices.createAccount(email.trim(), password.trim());
      state = DataState.success(null);
    } catch (e) {
      SecureErrorHandler.logError(e, context: 'registration');
      state = DataState.error(
        title: "Registration Failed",
        description: SecureErrorHandler.handleError(e, context: 'registration'),
        onRetry: () => register(email, password),
        errorType: ErrorType.alert,
      );
    }
  }
}

// Google Sign-In Provider
final googleSignInStateProvider = StateNotifierProvider<GoogleSignInNotifier, DataState<void>>((ref) {
  return GoogleSignInNotifier();
});

class GoogleSignInNotifier extends StateNotifier<DataState<void>> {
  GoogleSignInNotifier() : super(DataState.success(null));

  Future<void> signInWithGoogle() async {
    state = DataState.loading(LoadingType.overlayLoading);

    try {
      final userCredential = await FirebaseServices.signInWithGoogle();
      if (userCredential != null && userCredential.user != null) {
        final user = FirebaseAuth.instance.currentUser;
        final prefs = await SharedPreferences.getInstance();
        
        // Save user data to SharedPreferences
        await prefs.setString("email", user?.email ?? userCredential.user!.email ?? '');
        await prefs.setString("name", user?.displayName ?? userCredential.user!.displayName ?? '');
        await prefs.setString("profileImageUrl", user?.photoURL ?? userCredential.user!.photoURL ?? '');
        
        state = DataState.success(null);
      } else {
        throw Exception("Failed to get user credentials");
      }
    } catch (e) {
      SecureErrorHandler.logError(e, context: 'googleSignIn');
      state = DataState.error(
        title: "Google Sign In Failed",
        description: SecureErrorHandler.handleError(e, context: 'googleSignIn'),
        onRetry: () => signInWithGoogle(),
        errorType: ErrorType.alert,
      );
    }
  }
}

// Reset Password Provider
final resetPasswordStateProvider = StateNotifierProvider<ResetPasswordNotifier, DataState<void>>((ref) {
  return ResetPasswordNotifier();
});

class ResetPasswordNotifier extends StateNotifier<DataState<void>> {
  ResetPasswordNotifier() : super(DataState.success(null));

  Future<void> resetPassword(String email) async {
    state = DataState.loading(LoadingType.overlayLoading);

    try {
      await FirebaseServices.resetPassword(email.trim());
      state = DataState.success(null);
    } catch (e) {
      SecureErrorHandler.logError(e, context: 'resetPassword');
      state = DataState.error(
        title: "Failed to Send Email",
        description: SecureErrorHandler.handleError(e, context: 'resetPassword'),
        onRetry: () => resetPassword(email),
        errorType: ErrorType.alert,
      );
    }
  }
}
