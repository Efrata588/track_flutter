import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/status_alert.dart';
import '../data/auth_repository.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _successMessage;
  String? _errorMessage;
  String? _emailError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _emailError = 'Please enter your email address.';
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _emailError = null;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final msg =
          await ref.read(authRepositoryProvider).forgotPassword(email);
      if (mounted) {
        setState(() {
          _successMessage = msg;
          _isLoading = false;
        });
      }
    } on ValidationException catch (e) {
      if (mounted) {
        setState(() {
          _emailError = e.firstErrorFor('email');
          _errorMessage = _emailError == null ? e.message : null;
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
    } catch (e) {
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
                    'Forgot password',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.4,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Enter your email to receive a password reset link',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                        ),
                  ),
                  const SizedBox(height: 24),

                  if (_successMessage != null) ...[
                    StatusAlert(
                      message: _successMessage!,
                      variant: StatusAlertVariant.success,
                    ),
                    const SizedBox(height: 20),
                  ],

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
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.email],
                    errorText: _emailError,
                  ),
                  const SizedBox(height: 24),

                  AppButton(
                    label: 'Email password reset link',
                    isLoading: _isLoading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Or, return to ',
                        style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                            ),
                      ),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Text(
                          'log in',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
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
