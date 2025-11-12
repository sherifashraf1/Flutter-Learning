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
  // Form controller
  final TextEditingController _emailController = TextEditingController();

  // Validation state
  String? _emailError;

  // Focus node
  final FocusNode _emailFocusNode = FocusNode();

  // Constants
  static const double _logoWidthFactor = 0.4;
  static const double _logoHeightFactor = 0.13;
  static const double _horizontalPadding = 24.0;
  static const double _verticalSpacing = 16.0;
  static const double _sectionSpacing = 24.0;

  @override
  void initState() {
    super.initState();
    _setupValidationListener();
    _setupFocusListener();
    _unfocusOnInit();
  }

  void _setupValidationListener() {
    _emailController.addListener(_validateEmail);
  }

  void _setupFocusListener() {
    _emailFocusNode.addListener(() {
      if (_emailFocusNode.hasFocus) {
        setState(() => _emailError = null);
      }
    });
  }

  void _unfocusOnInit() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _unfocusAllFields();
      _clearErrorsIfFieldEmpty();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final route = ModalRoute.of(context);
      if (route != null && !route.isCurrent) {
        _unfocusAllFields();
        _clearErrorsIfFieldEmpty();
      }
    });
  }

  @override
  void dispose() {
    _unfocusAllFields();
    _emailController.removeListener(_validateEmail);
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  // Validation methods
  void _validateEmail() {
    setState(() {
      _emailError = ValidationManager.email(_emailController.text);
    });
  }

  void _validateAllFields() {
    setState(() {
      _emailError = ValidationManager.email(_emailController.text);
    });
  }

  bool get _isFormValid => _emailError == null;

  // Helper methods
  void _unfocusAllFields() {
    _emailFocusNode.unfocus();
    FocusScope.of(context).unfocus();
  }

  void _clearErrorsIfFieldEmpty() {
    if (_emailController.text.isEmpty && _emailError != null) {
      setState(() => _emailError = null);
    }
  }

  // Action handlers
  void _handleResetPassword() {
    _validateAllFields();
    if (_isFormValid) {
      ref.read(resetPasswordStateProvider.notifier).resetPassword(
            _emailController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final resetPasswordState = ref.watch(resetPasswordStateProvider);

    ref.listen<DataState<void>>(resetPasswordStateProvider, (previous, next) {
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
          childBuilder: (_) => _buildResetPasswordForm(),
        ),
      ),
    );
  }

  Widget _buildResetPasswordForm() {
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
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: _sectionSpacing,
                      bottom: _horizontalPadding,
                    ),
                    child: _buildConfirmButton(),
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

  Widget _buildConfirmButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: _handleResetPassword,
        child: const Text("Confirm"),
      ),
    );
  }
}
