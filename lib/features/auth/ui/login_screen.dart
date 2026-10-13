import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/password_field.dart';
import '../../../core/widgets/status_alert.dart';
import '../state/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both email and password.')),
      );
      return;
    }

    final success = await ref.read(authControllerProvider.notifier).login(
          email: email,
          password: password,
        );

    if (success && mounted) {
      context.go('/dashboard');
    }
  }

  Future<void> _openWebUrl() async {
    final uri = Uri.parse(AppConfig.webUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authControllerProvider);
    final error = authState.error;

    String? emailError;
    String? passwordError;
    String? alertMessage;
    StatusAlertVariant alertVariant = StatusAlertVariant.error;

    if (error is ValidationException) {
      emailError = error.firstErrorFor('email');
      passwordError = error.firstErrorFor('password');
      if (emailError == null && passwordError == null) {
        alertMessage = error.message;
      }
    } else if (error is ForbiddenException) {
      alertMessage = error.message;
      alertVariant = StatusAlertVariant.warning;
    } else if (error is ThrottledException) {
      alertMessage = error.message;
      alertVariant = StatusAlertVariant.warning;
    } else if (error != null) {
      alertMessage = error.message;
      alertVariant = StatusAlertVariant.error;
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/welcome'),
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
                    'Log in to your account',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.4,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Enter your email and password below to log in',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                        ),
                  ),
                  const SizedBox(height: 24),

                  if (alertMessage != null) ...[
                    StatusAlert(
                      message: alertMessage,
                      variant: alertVariant,
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
                    errorText: emailError,
                  ),
                  const SizedBox(height: 16),

                  PasswordField(
                    label: 'Password',
                    placeholder: 'Password',
                    controller: _passwordController,
                    textInputAction: TextInputAction.done,
                    errorText: passwordError,
                    trailingHeaderAction: GestureDetector(
                      onTap: () => context.push('/forgot-password'),
                      child: Text(
                        'Forgot your password?',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  AppButton(
                    label: 'Log in',
                    isLoading: authState.isLoading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 24),

                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
                            height: 1.4,
                          ),
                      children: [
                        const TextSpan(
                          text: "Don't have an account? Create one on the web at ",
                        ),
                        TextSpan(
                          text: AppConfig.webUrl,
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()..onTap = _openWebUrl,
                        ),
                      ],
                    ),
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
