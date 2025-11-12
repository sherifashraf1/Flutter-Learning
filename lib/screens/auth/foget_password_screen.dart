import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/Auth/app_text_field.dart';
import '../../shared-enums/shared_enums.dart';
import '../../shared/empty_state/data_state.dart';
import '../../shared/empty_state/data_state_widget.dart';
import '../../providers/auth_provider.dart';

class ForgetPasswordScreen extends ConsumerStatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  ConsumerState<ForgetPasswordScreen> createState() =>
      _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends ConsumerState<ForgetPasswordScreen> {
  TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
  }

  void _handleResetPassword() {
    ref
        .read(resetPasswordStateProvider.notifier)
        .resetPassword(emailController.text);
  }

  @override
  Widget build(BuildContext context) {
    final resetPasswordState = ref.watch(resetPasswordStateProvider);
    final isLoading = resetPasswordState.state == ViewState.loading;

    // Listen to state changes and handle UI side effects
    ref.listen<DataState<void>>(resetPasswordStateProvider, (previous, next) {
      // Handle success state - show success snackbar
      if (next.state == ViewState.success &&
          previous?.state != ViewState.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Email sent successfully"),
            backgroundColor: Colors.green,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Forget Password')),
      body: SafeArea(
        child: DataStateWidget<void>(
          dataState: resetPasswordState,
          childBuilder: (_) => _buildResetPasswordForm(isLoading),
        ),
      ),
    );
  }

  Widget _buildResetPasswordForm(bool isLoading) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          AppTextFieldWidget(controller: emailController, hint: "Email"),
          const SizedBox(height: 40),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: ElevatedButton(
              onPressed: isLoading ? null : _handleResetPassword,
              child: const Text("Confirm"),
            ),
          ),
        ],
      ),
    );
  }
}
