import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
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
