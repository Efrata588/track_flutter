import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/state/auth_controller.dart';
import '../../features/auth/ui/forgot_password_screen.dart';
import '../../features/auth/ui/login_screen.dart';
import '../../features/auth/ui/reset_password_screen.dart';
import '../../features/auth/ui/welcome_screen.dart';
import '../../features/settings/ui/appearance_screen.dart';
import '../../features/settings/ui/profile_screen.dart';
import '../../features/settings/ui/security_screen.dart';
import '../../features/tasks/ui/dashboard_screen.dart';
import '../widgets/splash_screen.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AuthState>(
      authControllerProvider,
      (_, _) => notifyListeners(),
    );
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final status = authState.status;
      final location = state.uri.path;

      // When checking session on startup, remain on splash
      if (status == AuthStatus.initial) {
        return location == '/splash' ? null : '/splash';
      }

      final isPublicRoute = location == '/welcome' ||
          location == '/login' ||
          location == '/forgot-password' ||
          location == '/reset-password';

      // Unauthenticated users can only access public auth screens
      if (status == AuthStatus.unauthenticated) {
        return isPublicRoute ? null : '/welcome';
      }

      // Authenticated users are redirected away from auth screens and splash
      if (status == AuthStatus.authenticated) {
        if (isPublicRoute || location == '/splash') {
          return '/dashboard';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'];
          final token = state.uri.queryParameters['token'];
          return ResetPasswordScreen(
            initialEmail: email,
            initialToken: token,
          );
        },
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/settings/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings/appearance',
        builder: (context, state) => const AppearanceScreen(),
      ),
      GoRoute(
        path: '/settings/security',
        builder: (context, state) => const SecurityScreen(),
      ),
    ],
  );
});
