import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profile_demo_app_with_flutter/router/app_router.dart';
import '../../widgets/Auth/app_text_field.dart';
import '../../shared-enums/shared_enums.dart';
import '../../shared/empty_state/data_state.dart';
import '../../shared/empty_state/data_state_widget.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  void _handleLogin() {
    ref.read(loginStateProvider.notifier).login(
          emailController.text,
          passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginStateProvider);
    final isLoading = loginState.state == ViewState.loading;
    // Listen to state changes and handle UI side effects (navigation)
    ref.listen<DataState<void>>(loginStateProvider, (previous, next) {
      // Handle success state - navigate to home
      if (next.state == ViewState.success &&
          previous?.state != ViewState.success) {
       print("should show home screen");
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SafeArea(
        child: DataStateWidget<void>(
          dataState: loginState,
          childBuilder: (_) => _buildLoginForm(isLoading),
        ),
      ),
    );
  }

  Widget _buildLoginForm(bool isLoading) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          AppTextFieldWidget(
            controller: emailController,
            hint: "Email",
          ),
          const SizedBox(height: 16),
          AppTextFieldWidget(
            controller: passwordController,
            hint: "Password",
            obscure: true,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                print("should show forget password screen");
              },
              child: const Text("Forget Password ?"),
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: ElevatedButton(
              onPressed: isLoading ? null : _handleLogin,
              child: const Text("Login"),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: ElevatedButton(
              onPressed: () {
                print("should show create account screen");
              },
              child: const Text("Create new account"),
            ),
          ),
        ],
      ),
    );
  }
}
