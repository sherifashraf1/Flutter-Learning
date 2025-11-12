import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/validation_manager.dart';
import '../../widgets/Auth/app_text_form_field.dart';
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
  TextEditingController confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  bool _hasAttemptedValidation = false;
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Clear errors when screen is opened, especially if fields are empty
    if (emailController.text.isEmpty) {
      _emailError = null;
    }
    if (passwordController.text.isEmpty) {
      _passwordError = null;
    }
    if (confirmPasswordController.text.isEmpty) {
      _confirmPasswordError = null;
    }
    _hasAttemptedValidation = false;
    // Add listeners for real-time validation
    emailController.addListener(_validateEmail);
    passwordController.addListener(_validatePassword);
    confirmPasswordController.addListener(_validateConfirmPassword);
    // Clear errors when fields get focus
    _emailFocusNode.addListener(() {
      if (_emailFocusNode.hasFocus) {
        setState(() {
          _emailError = null;
        });
      }
    });
    _passwordFocusNode.addListener(() {
      if (_passwordFocusNode.hasFocus) {
        setState(() {
          _passwordError = null;
        });
      }
    });
    _confirmPasswordFocusNode.addListener(() {
      if (_confirmPasswordFocusNode.hasFocus) {
        setState(() {
          _confirmPasswordError = null;
        });
      }
    });
    // Unfocus any fields when screen is opened and clear errors if fields are empty
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _emailFocusNode.unfocus();
      _passwordFocusNode.unfocus();
      _confirmPasswordFocusNode.unfocus();
      FocusScope.of(context).unfocus();
      // Clear errors if fields are empty after navigation
      if (emailController.text.isEmpty && _emailError != null) {
        setState(() {
          _emailError = null;
        });
      }
      if (passwordController.text.isEmpty && _passwordError != null) {
        setState(() {
          _passwordError = null;
        });
      }
      if (confirmPasswordController.text.isEmpty && _confirmPasswordError != null) {
        setState(() {
          _confirmPasswordError = null;
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
        _passwordFocusNode.unfocus();
        _confirmPasswordFocusNode.unfocus();
        FocusScope.of(context).unfocus();
        // Clear errors if fields are empty when navigating away
        if (emailController.text.isEmpty && _emailError != null) {
          setState(() {
            _emailError = null;
          });
        }
        if (passwordController.text.isEmpty && _passwordError != null) {
          setState(() {
            _passwordError = null;
          });
        }
        if (confirmPasswordController.text.isEmpty && _confirmPasswordError != null) {
          setState(() {
            _confirmPasswordError = null;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    // Unfocus fields before disposing
    _emailFocusNode.unfocus();
    _passwordFocusNode.unfocus();
    _confirmPasswordFocusNode.unfocus();
    // Remove listeners before disposing
    emailController.removeListener(_validateEmail);
    passwordController.removeListener(_validatePassword);
    confirmPasswordController.removeListener(_validateConfirmPassword);
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
  }

  void _validateEmail() {
    setState(() {
      _emailError = ValidationManager.email(emailController.text);
    });
  }

  void _validatePassword() {
    setState(() {
      _passwordError = ValidationManager.password(passwordController.text);
    });
  }

  void _validateConfirmPassword() {
    setState(() {
      _confirmPasswordError = ValidationManager.confirmPassword(
        confirmPasswordController.text,
        passwordController.text,
      );
    });
  }

  void _handleRegistration() {
    setState(() {
      _hasAttemptedValidation = true;
      _emailError = ValidationManager.email(emailController.text);
      _passwordError = ValidationManager.password(passwordController.text);
      _confirmPasswordError = ValidationManager.confirmPassword(
        confirmPasswordController.text,
        passwordController.text,
      );
    });

    if (_emailError == null && _passwordError == null && _confirmPasswordError == null) {
      ref.read(registrationStateProvider.notifier).register(
        emailController.text,
        passwordController.text,
      );
    }
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
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: isLoading ? null : _handleRegistration,
          child: const Text("Register"),
        ),
      ),
    );
  }

  Widget _buildRegistrationForm(bool isLoading) {
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

          const SizedBox(height: 16),

          AppTextFormFieldWidget(
              label: "Password",
              controller: passwordController,
              focusNode: _passwordFocusNode,
              prefixIcon: const Icon(Icons.lock),
              obscure: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () =>
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    }),
              ),
              errorText: _passwordError,
              validator: ValidationManager.password
          ),

          const SizedBox(height: 16),

          AppTextFormFieldWidget(
              label: "Confirm Password",
              controller: confirmPasswordController,
              focusNode: _confirmPasswordFocusNode,
              prefixIcon: const Icon(Icons.lock_outline),
              obscure: _obscureConfirmPassword,
              suffixIcon: IconButton(
                  icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons
                      .visibility),
                  onPressed: () =>
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      },)),
              errorText: _confirmPasswordError,
              validator: (value) =>
                  ValidationManager.confirmPassword(value, passwordController.text)
          ),

          const SizedBox(height: 40),

          // SizedBox(
          //   width: MediaQuery.of(context).size.width,
          //   child: ElevatedButton(
          //     onPressed: isLoading ? null : _handleRegistration,
          //     child: const Text("Register"),
          //   ),
          // ),
        ],
        ),
      ),
    );
  }
}