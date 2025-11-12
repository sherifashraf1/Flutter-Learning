import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/Auth/app_text_field.dart';
import '../../shared-enums/shared_enums.dart';
import '../../shared/empty_state/data_state.dart';
import '../../shared/empty_state/data_state_widget.dart';
import '../../providers/auth_provider.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();


  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  void _handleRegistration() {
    ref.read(registrationStateProvider.notifier).register(
          emailController.text,
          passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final registrationState = ref.watch(registrationStateProvider);
    final isLoading = registrationState.state == ViewState.loading;

    // Listen to state changes and handle UI side effects
    ref.listen<DataState<void>>(registrationStateProvider, (previous, next) {
      // Handle success state - navigate back
      if (next.state == ViewState.success && previous?.state != ViewState.success) {
        Navigator.pop(context);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('SignUp'),
      ),
      body: SafeArea(
        child: DataStateWidget<void>(
          dataState: registrationState,
          childBuilder: (_) => _buildRegistrationForm(isLoading),
        ),
      ),
    );
  }

  Widget _buildRegistrationForm(bool isLoading) {
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
          const SizedBox(height: 40),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: ElevatedButton(
              onPressed: isLoading ? null : _handleRegistration,
              child: const Text("Register"),
            ),
          ),
        ],
      ),
    );
  }
}