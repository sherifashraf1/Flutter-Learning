import 'package:flutter_test/flutter_test.dart';
import 'package:profile_demo_app_with_flutter/providers/auth_provider.dart';
import 'package:profile_demo_app_with_flutter/shared/empty_state/data_state.dart';
import 'package:profile_demo_app_with_flutter/shared-enums/shared_enums.dart';

void main() {
  group('LoginNotifier Tests', () {
    late LoginNotifier loginNotifier;

    setUp(() {
      loginNotifier = LoginNotifier();
    });

    test('should initialize with success state', () {
      // Assert: Initial state should be success
      expect(loginNotifier.state.state, ViewState.success);
    });

    test('should have login method', () {
      // Assert: login method should exist
      expect(loginNotifier.login, isA<Function>());
    });

    test('login should set loading state when called', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';

      // Act: Call login (will fail but should set loading state)
      loginNotifier.login(email, password);

      // Assert: State should be loading
      // Note: Firebase authentication would need mocking for full integration test
      expect(loginNotifier.state.state, ViewState.loading);
      expect(loginNotifier.state.loadingType, LoadingType.overlayLoading);
    });
  });
}

