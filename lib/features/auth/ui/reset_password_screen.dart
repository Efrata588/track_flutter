import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/password_field.dart';
import '../../../core/widgets/status_alert.dart';
import '../data/auth_repository.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String? initialEmail;
  final String? initialToken;

  const ResetPasswordScreen({
    super.key,
    this.initialEmail,
    this.initialToken,
  });

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _tokenController;
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  String? _emailError;
  String? _tokenError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
    _tokenController = TextEditingController(text: widget.initialToken ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim();
    final token = _tokenController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (email.isEmpty || token.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields.')),
      );
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _confirmPasswordError = 'The password confirmation does not match.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _emailError = null;
      _tokenError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });

    try {
      final msg = await ref.read(authRepositoryProvider).resetPassword(
            token: token,
            email: email,
            password: password,
            passwordConfirmation: confirmPassword,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: const Color(0xFF059669),
          ),
        );
        context.go('/login');
      }
    } on ValidationException catch (e) {
      if (mounted) {
        setState(() {
          _emailError = e.firstErrorFor('email');
          _tokenError = e.firstErrorFor('token');
          _passwordError = e.firstErrorFor('password');
          _confirmPasswordError = e.firstErrorFor('password_confirmation');
          if (_emailError == null &&
              _tokenError == null &&
              _passwordError == null &&
              _confirmPasswordError == null) {
            _errorMessage = e.message;
          }
          _isLoading = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = 'An unexpected error occurred.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(
                    child: AppLogo(
                      iconSize: 36,
                      showText: false,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Reset password',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.4,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Please enter your new password below',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                        ),
                  ),
                  const SizedBox(height: 24),

                  if (_errorMessage != null) ...[
                    StatusAlert(
                      message: _errorMessage!,
                      variant: StatusAlertVariant.error,
                    ),
                    const SizedBox(height: 20),
                  ],

                  AppTextField(
                    label: 'Email address',
                    placeholder: 'email@example.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    errorText: _emailError,
                  ),
                  const SizedBox(height: 16),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextField(
                        label: 'Reset token',
                        placeholder: 'Paste the token from your reset email',
                        controller: _tokenController,
                        textInputAction: TextInputAction.next,
                        errorText: _tokenError,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Paste the token from your reset email',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  PasswordField(
                    label: 'New password',
                    placeholder: 'Password',
                    controller: _passwordController,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.newPassword],
                    errorText: _passwordError,
                  ),
                  const SizedBox(height: 16),

                  PasswordField(
                    label: 'Confirm password',
                    placeholder: 'Confirm password',
                    controller: _confirmPasswordController,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.newPassword],
                    errorText: _confirmPasswordError,
                  ),
                  const SizedBox(height: 24),

                  AppButton(
                    label: 'Reset password',
                    isLoading: _isLoading,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
