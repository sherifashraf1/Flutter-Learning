import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/validation_manager.dart';
import '../../widgets/Auth/app_text_form_field.dart';
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
  final FocusNode _emailFocusNode = FocusNode();

  String? _emailError;
  bool _hasAttemptedValidation = false;

  @override
  void initState() {
    super.initState();
    // Clear errors when screen is opened, especially if field is empty
    if (emailController.text.isEmpty) {
      _emailError = null;
    }
    _hasAttemptedValidation = false;
    // Add listener for real-time validation
    emailController.addListener(_validateEmail);
    // Clear errors when field gets focus
    _emailFocusNode.addListener(() {
      if (_emailFocusNode.hasFocus) {
        setState(() {
          _emailError = null;
        });
      }
    });
    // Unfocus any fields when screen is opened and clear errors if field is empty
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _emailFocusNode.unfocus();
      FocusScope.of(context).unfocus();
      // Clear error if field is empty after navigation
      if (emailController.text.isEmpty && _emailError != null) {
        setState(() {
          _emailError = null;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Unfocus fields when route becomes inactive (navigating away)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final route = ModalRoute.of(context);
      if (route != null && !route.isCurrent) {
        _emailFocusNode.unfocus();
        FocusScope.of(context).unfocus();
        // Clear error if field is empty when navigating away
        if (emailController.text.isEmpty && _emailError != null) {
          setState(() {
            _emailError = null;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    // Unfocus field before disposing
    _emailFocusNode.unfocus();
    // Remove listener before disposing
    emailController.removeListener(_validateEmail);
    emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  void _validateEmail() {
    setState(() {
      _emailError = ValidationManager.email(emailController.text);
    });
  }

  void _handleResetPassword() {
    setState(() {
      _hasAttemptedValidation = true;
      _emailError = ValidationManager.email(emailController.text);
    });
    
    if (_emailError == null) {
      ref
          .read(resetPasswordStateProvider.notifier)
          .resetPassword(emailController.text);
    }
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
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: isLoading ? null : _handleResetPassword,
          child: const Text("Confirm"),
        ),
      ),
    );
  }

  Widget _buildResetPasswordForm(bool isLoading) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

          Theme.of(context).brightness == Brightness.dark
              ? ColorFiltered(
            colorFilter: const ColorFilter.mode(
              Colors.white,
              BlendMode.srcIn,
            ),
            child: Image.asset(
              'assets/images/logo.png',
              width: screenWidth * 0.4,
              height: screenHeight * 0.13,
              fit: BoxFit.contain,
            ),
          )
              : Image.asset(
            'assets/images/logo.png',
            width: screenWidth * 0.4,
            height: screenHeight * 0.13,
            fit: BoxFit.contain,
          ),

          const SizedBox(height: 16),

          AppTextFormFieldWidget(
            label: "Email",
            controller: emailController,
            focusNode: _emailFocusNode,
            prefixIcon: const Icon(Icons.email),
            errorText: _emailError,
            validator: ValidationManager.email,
          ),

        ],
        ),
      ),
    );
  }
}
