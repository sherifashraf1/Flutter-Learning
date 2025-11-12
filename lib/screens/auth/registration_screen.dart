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
  // Form controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Validation state
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Focus nodes
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  // Constants
  static const double _logoWidthFactor = 0.4;
  static const double _logoHeightFactor = 0.13;
  static const double _horizontalPadding = 24.0;
  static const double _verticalSpacing = 16.0;
  static const double _sectionSpacing = 24.0;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeFocusNodes();
    _setupValidationListeners();
    _setupFocusListeners();
    _unfocusOnInit();
  }

  void _initializeControllers() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  void _initializeFocusNodes() {
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _confirmPasswordFocusNode = FocusNode();
  }

  void _setupValidationListeners() {
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validatePassword);
    _confirmPasswordController.addListener(_validateConfirmPassword);
  }

  void _setupFocusListeners() {
    _emailFocusNode.addListener(() {
      if (_emailFocusNode.hasFocus) {
        setState(() => _emailError = null);
      }
    });
    _passwordFocusNode.addListener(() {
      if (_passwordFocusNode.hasFocus) {
        setState(() => _passwordError = null);
      }
    });
    _confirmPasswordFocusNode.addListener(() {
      if (_confirmPasswordFocusNode.hasFocus) {
        setState(() => _confirmPasswordError = null);
      }
    });
  }

  void _unfocusOnInit() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _unfocusAllFields();
      _clearErrorsIfFieldsEmpty();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final route = ModalRoute.of(context);
      if (route != null && !route.isCurrent) {
        _unfocusAllFields();
        _clearErrorsIfFieldsEmpty();
      }
    });
  }

  @override
  void dispose() {
    _unfocusAllFields();
    _emailController.removeListener(_validateEmail);
    _passwordController.removeListener(_validatePassword);
    _confirmPasswordController.removeListener(_validateConfirmPassword);
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
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

  void _validateConfirmPassword() {
    setState(() {
      _confirmPasswordError = ValidationManager.confirmPassword(
        _confirmPasswordController.text,
        _passwordController.text,
      );
    });
  }

  void _validateAllFields() {
    setState(() {
      _emailError = ValidationManager.email(_emailController.text);
      _passwordError = ValidationManager.password(_passwordController.text);
      _confirmPasswordError = ValidationManager.confirmPassword(
        _confirmPasswordController.text,
        _passwordController.text,
      );
    });
  }

  bool get _isFormValid =>
      _emailError == null &&
      _passwordError == null &&
      _confirmPasswordError == null;

  // Helper methods
  void _unfocusAllFields() {
    _emailFocusNode.unfocus();
    _passwordFocusNode.unfocus();
    _confirmPasswordFocusNode.unfocus();
    FocusScope.of(context).unfocus();
  }

  void _clearErrorsIfFieldsEmpty() {
    if (_emailController.text.isEmpty && _emailError != null) {
      setState(() => _emailError = null);
    }
    if (_passwordController.text.isEmpty && _passwordError != null) {
      setState(() => _passwordError = null);
    }
    if (_confirmPasswordController.text.isEmpty &&
        _confirmPasswordError != null) {
      setState(() => _confirmPasswordError = null);
    }
  }

  // Action handlers
  void _handleRegistration() {
    _validateAllFields();
    if (_isFormValid) {
      ref
          .read(registrationStateProvider.notifier)
          .register(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
    }
  }

  void _togglePasswordVisibility() {
    setState(() => _obscurePassword = !_obscurePassword);
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
  }

  @override
  Widget build(BuildContext context) {
    final registrationState = ref.watch(registrationStateProvider);

    ref.listen<DataState<void>>(registrationStateProvider, (previous, next) {
      if (next.state == ViewState.success &&
          previous?.state != ViewState.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Account created successfully"),
            backgroundColor: Colors.green,
          ),
        );
        // Pop after showing the message
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('SignUp')),
      body: SafeArea(
        child: DataStateWidget<void>(
          dataState: registrationState,
          childBuilder: (_) => _buildRegistrationForm(),
        ),
      ),
    );
  }

  Widget _buildRegistrationForm() {
    final size = MediaQuery.of(context).size;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: size.height * 0.05),
                  _buildLogo(size),
                  SizedBox(height: _sectionSpacing * 1.5),
                  _buildEmailField(),
                  SizedBox(height: _verticalSpacing),
                  _buildPasswordField(),
                  SizedBox(height: _verticalSpacing),
                  _buildConfirmPasswordField(),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: _sectionSpacing,
                      bottom: _horizontalPadding,
                    ),
                    child: _buildRegisterButton(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
          _obscurePassword
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
        ),
        onPressed: _togglePasswordVisibility,
      ),
      errorText: _passwordError,
      validator: ValidationManager.password,
    );
  }

  Widget _buildConfirmPasswordField() {
    return AppTextFormFieldWidget(
      label: "Confirm Password",
      controller: _confirmPasswordController,
      focusNode: _confirmPasswordFocusNode,
      prefixIcon: const Icon(Icons.lock_outline),
      obscure: _obscureConfirmPassword,
      suffixIcon: IconButton(
        icon: Icon(
          _obscureConfirmPassword
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
        ),
        onPressed: _toggleConfirmPasswordVisibility,
      ),
      errorText: _confirmPasswordError,
      validator: (value) =>
          ValidationManager.confirmPassword(value, _passwordController.text),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: _handleRegistration,
        child: const Text("Register"),
      ),
    );
  }
}
