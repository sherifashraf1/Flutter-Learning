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
  // Form key and controllers
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Validation state
  String? _emailError;
  String? _passwordError;
  bool _obscurePassword = true;

  // Focus nodes
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  // Riverpod listener subscriptions (for manual management)
  ProviderSubscription<DataState<void>>? _loginSubscription;
  ProviderSubscription<DataState<void>>? _googleSignInSubscription;

  // Constants
  static const double _logoWidthFactor = 0.4;
  static const double _logoHeightFactor = 0.13;
  static const double _horizontalPadding = 24.0;
  static const double _verticalSpacing = 16.0;
  static const double _sectionSpacing = 24.0;

  @override
  void initState() {
    super.initState();
    _setupValidationListeners();
    _setupFocusListeners();
    _unfocusOnInit();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Set up Riverpod listeners after the widget is built
    // Using listenManual to set up listeners outside of build method
    _loginSubscription ??= ref.listenManual<DataState<void>>(
        loginStateProvider,
        (previous, next) => _handleAuthStateChange(previous, next),
      );
    
    _googleSignInSubscription ??= ref.listenManual<DataState<void>>(
        googleSignInStateProvider,
        (previous, next) => _handleAuthStateChange(previous, next),
      );
    
    // Handle route changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final route = ModalRoute.of(context);
      if (route != null && !route.isCurrent) {
        _unfocusAllFields();
        _clearErrorsIfFieldsEmpty();
      }
    });
  }

  void _setupValidationListeners() {
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validatePassword);
  }

  void _setupFocusListeners() {
    _emailFocusNode.addListener(_onEmailFocusChange);
    _passwordFocusNode.addListener(_onPasswordFocusChange);
  }

  void _onEmailFocusChange() {
    if (_emailFocusNode.hasFocus) {
      setState(() => _emailError = null);
    }
  }

  void _onPasswordFocusChange() {
    if (_passwordFocusNode.hasFocus) {
      setState(() => _passwordError = null);
    }
  }

  void _unfocusOnInit() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _unfocusAllFields();
      _clearErrorsIfFieldsEmpty();
    });
  }

  @override
  void dispose() {
    _unfocusAllFields();
    _emailController.removeListener(_validateEmail);
    _passwordController.removeListener(_validatePassword);
    _emailFocusNode.removeListener(_onEmailFocusChange);
    _passwordFocusNode.removeListener(_onPasswordFocusChange);
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    
    // Dispose Riverpod listener subscriptions
    _loginSubscription?.close();
    _googleSignInSubscription?.close();
    
    super.dispose();
  }

  // Validation methods
  void _validateEmail() {
    setState(() {
      _emailError = ValidationManager.email(_emailController.text);
    });
  }

  void _validatePassword() {
    setState(() {
      _passwordError = ValidationManager.password(_passwordController.text);
    });
  }

  void _validateAllFields() {
    setState(() {
      _emailError = ValidationManager.email(_emailController.text);
      _passwordError = ValidationManager.password(_passwordController.text);
    });
  }

  bool get _isFormValid => _emailError == null && _passwordError == null;

  // Helper methods
  void _unfocusAllFields() {
    _emailFocusNode.unfocus();
    _passwordFocusNode.unfocus();
    FocusScope.of(context).unfocus();
  }

  void _clearErrorsIfFieldsEmpty() {
    if (_emailController.text.isEmpty && _emailError != null) {
      setState(() => _emailError = null);
    }
    if (_passwordController.text.isEmpty && _passwordError != null) {
      setState(() => _passwordError = null);
    }
  }

  void _navigateToForgetPassword() {
    _unfocusAllFields();
    Navigator.pushNamed(context, AppRouter.forgetPasswordScreen);
  }

  void _navigateToSignUp() {
    _unfocusAllFields();
    Navigator.pushNamed(context, AppRouter.registerScreen);
  }

  void _handleGoogleSignIn() {
    ref.read(googleSignInStateProvider.notifier).signInWithGoogle();
  }

  void _navigateToHome() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRouter.homeScreen,
          (route) => false,
    );
  }

  // Action handlers
  void _handleLogin() {
    _validateAllFields();
    if (_isFormValid) {
      ref.read(loginStateProvider.notifier).login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    }
  }

  void _togglePasswordVisibility() {
    setState(() => _obscurePassword = !_obscurePassword);
  }

  /// Checks if an alert dialog should be shown for the error state
  /// Only shows when transitioning INTO error state (not when already in error)
  bool _shouldShowAlertDialog(DataState<void>? previous, DataState<void> next) {
    if (!mounted) return false;
    
    final isErrorState = next.state == ViewState.error;
    final isAlertType = next.errorType == ErrorType.alert;
    final isTransitioningToError = previous?.state != ViewState.error;
    final hasDescription = next.description != null;
    
    return isErrorState && isAlertType && isTransitioningToError && hasDescription;
  }

  /// Shows an alert dialog for error states
  void _showAlertDialog(DataState<void> state) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(state.title ?? 'Error'),
          content: Text(state.description!),
          actions: [
            if (state.onRetry != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  state.onRetry?.call();
                },
                child: const Text('Retry'),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
    });
  }

  /// Handles state changes for authentication providers
  void _handleAuthStateChange(
    DataState<void>? previous,
    DataState<void> next,
  ) {
    // Navigate to home on successful authentication
    if (next.state == ViewState.success &&
        previous?.state != ViewState.success) {
      _navigateToHome();
    }
    // Show alert dialog for alert-type errors
    if (_shouldShowAlertDialog(previous, next)) {
      _showAlertDialog(next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginStateProvider);
    final googleSignInState = ref.watch(googleSignInStateProvider);

    // Use Google Sign-In state if it's loading, otherwise use login state
    final currentState = googleSignInState.state == ViewState.loading 
        ? googleSignInState 
        : loginState;
    
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SafeArea(
        child: DataStateWidget<void>(
          dataState: currentState,
          childBuilder: (_) => _buildLoginForm(),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: size.height * 0.05),
            _buildLogo(size),
            SizedBox(height: _sectionSpacing * 1.5),
            _buildEmailField(),
            SizedBox(height: _verticalSpacing),
            _buildPasswordField(),
            SizedBox(height: _verticalSpacing / 2),
            _buildForgetPasswordLink(),
            SizedBox(height: _sectionSpacing),
            _buildLoginButton(),
            SizedBox(height: _sectionSpacing),
            _buildSignUpLink(),
            SizedBox(height: _sectionSpacing),
            _buildDivider(theme),
            SizedBox(height: _sectionSpacing),
            _buildSocialLoginButtons(size),
            SizedBox(height: size.height * 0.01),
            _buildSkipLoginLink(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(Size size) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logo = Image.asset(
      'assets/images/logo.png',
      width: size.width * _logoWidthFactor,
      height: size.height * _logoHeightFactor,
      fit: BoxFit.contain,
    );

    return Center(
      child: isDark
          ? ColorFiltered(
        colorFilter: const ColorFilter.mode(
          Colors.white,
          BlendMode.srcIn,
        ),
        child: logo,
      )
          : logo,
    );
  }

  Widget _buildEmailField() {
    return AppTextFormFieldWidget(
      label: "Email",
      controller: _emailController,
      focusNode: _emailFocusNode,
      prefixIcon: const Icon(Icons.email_outlined),
      errorText: _emailError,
      validator: ValidationManager.email,
    );
  }

  Widget _buildPasswordField() {
    return AppTextFormFieldWidget(
      label: "Password",
      controller: _passwordController,
      focusNode: _passwordFocusNode,
      prefixIcon: const Icon(Icons.lock_outline),
      obscure: _obscurePassword,
      suffixIcon: IconButton(
        icon: Icon(
          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        ),
        onPressed: _togglePasswordVisibility,
      ),
      errorText: _passwordError,
      validator: ValidationManager.password,
    );
  }

  Widget _buildForgetPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: _navigateToForgetPassword,
        child: const Text(
          "Forgot Password?",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: _handleLogin,
        child: const Text("Login")
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have account? ",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withAlpha(170),
          ),
        ),
        GestureDetector(
          onTap: _navigateToSignUp,
          child: Text(
            "Sign up",
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: theme.colorScheme.onSurface,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "OR",
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: theme.colorScheme.onSurface,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLoginButtons(Size size) {
    return Column(
      children: [
        _buildSocialButton(
          label: "Sign in with Facebook",
          icon: Icons.facebook,
          backgroundColor: const Color(0xFF1877F2),
          onPressed: () {
            // TODO: Implement Facebook login
          },
        ),
        const SizedBox(height: 12),
        _buildSocialButton(
          label: "Sign in with Google",
          icon: Icons.g_mobiledata_outlined,
          iconSize: 28,
          backgroundColor: const Color(0xFFDB4437),
          onPressed: _handleGoogleSignIn,
        ),
        const SizedBox(height: 12),
        _buildAppleButton(),
      ],
    );
  }

  Widget _buildSocialButton({
    required String label,
    required IconData icon,
    double iconSize = 24,
    required Color backgroundColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: iconSize),
            const SizedBox(width: 12),
            Text(label),
          ],
        ),
      ),
    );
  }

  Widget _buildAppleButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.white : Colors.black;
    final foregroundColor = isDark ? Colors.black : Colors.white;

    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          // TODO: Implement Apple login
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.apple, size: 24, color: foregroundColor),
            const SizedBox(width: 12),
            Text(
              "Sign in with Apple",
              style: TextStyle(color: foregroundColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkipLoginLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: _navigateToHome,
        child: Text(
          "Skip Login",
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withAlpha(170),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

