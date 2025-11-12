import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:profile_demo_app_with_flutter/router/app_router.dart';
import '../../widgets/Auth/app_text_form_field.dart';
import '../../shared-enums/shared_enums.dart';
import '../../shared/empty_state/data_state.dart';
import '../../shared/empty_state/data_state_widget.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validation_manager.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  bool _obscurePassword = true;
  bool _hasAttemptedValidation = false;
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

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
    _hasAttemptedValidation = false;
    // Add listeners for real-time validation
    emailController.addListener(_validateEmail);
    passwordController.addListener(_validatePassword);
    // Clear errors when field gets focus
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
    // Unfocus any fields when screen is opened and clear errors if fields are empty
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _emailFocusNode.unfocus();
      _passwordFocusNode.unfocus();
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
      }
    });
  }

  @override
  void dispose() {
    // Unfocus fields before disposing
    _emailFocusNode.unfocus();
    _passwordFocusNode.unfocus();
    // Remove listeners before disposing
    emailController.removeListener(_validateEmail);
    passwordController.removeListener(_validatePassword);
    emailController.dispose();
    passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
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

  void _validateFields() {
    setState(() {
      _hasAttemptedValidation = true;
      _emailError = ValidationManager.email(emailController.text);
      _passwordError = ValidationManager.password(passwordController.text);
    });
  }

  void _handleLogin() {
    _validateFields();
    if (_emailError == null && _passwordError == null) {
      ref
          .read(loginStateProvider.notifier)
          .login(emailController.text, passwordController.text);
    }
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
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRouter.homeScreen,
              (route) => false,
        );
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
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
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () => setState(() {
                    _obscurePassword = !_obscurePassword;
                  }),
                ),
                errorText: _passwordError,
                validator: ValidationManager.password,
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Unfocus fields before navigating
                    _emailFocusNode.unfocus();
                    _passwordFocusNode.unfocus();
                    FocusScope.of(context).unfocus();
                    Navigator.pushNamed(
                      context,
                      AppRouter.forgetPasswordScreen,
                    );
                  },
                  child: const Text(
                    "Forget Password ?",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: screenWidth,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleLogin,
                  child: const Text("Login"),
                ),
              ),

              const SizedBox(height: 24),

              // "Didn't have Account? Sign up" text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 8,
                children: [
                  const Text("Don't have an account? "),
                  GestureDetector(
                    onTap: () {
                      // Unfocus fields before navigating
                      _emailFocusNode.unfocus();
                      _passwordFocusNode.unfocus();
                      FocusScope.of(context).unfocus();
                      Navigator.pushNamed(context, AppRouter.registerScreen);
                    },
                    child: const Text(
                      "Sign up",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // OR separator
              Row(
                children: [
                  Expanded(
                    child: Divider(color: Colors.grey[400], thickness: 2),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text("OR", style: TextStyle(fontSize: 14)),
                  ),
                  Expanded(
                    child: Divider(color: Colors.grey[400], thickness: 2),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Social login buttons
              SizedBox(
                width: screenWidth,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement Facebook login
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text("Sign in with Facebook"),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: screenWidth,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement Google login
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text("Sign in with Google"),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: screenWidth,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement Apple login
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text("Sign in with Apple"),
                ),
              ),

              const SizedBox(height: 12),

              // Skip Login link at the bottom
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: GestureDetector(
                    onTap: () {
                      // TODO: Implement skip login functionality
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRouter.homeScreen,
                            (route) => false,
                      );
                    },
                    child: Text("Skip Login"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

