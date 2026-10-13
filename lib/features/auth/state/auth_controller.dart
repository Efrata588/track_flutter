import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/token_storage.dart';
import '../data/auth_repository.dart';
import '../models/auth_user.dart';

enum AuthStatus { initial, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final AuthUser? user;
  final String? token;
  final bool isLoading;
  final ApiException? error;

  const AuthState({
    required this.status,
    this.user,
    this.token,
    this.isLoading = false,
    this.error,
  });

  factory AuthState.initial() => const AuthState(status: AuthStatus.initial);

  factory AuthState.authenticated(AuthUser user, String token) {
    return AuthState(
      status: AuthStatus.authenticated,
      user: user,
      token: token,
      isLoading: false,
    );
  }

  factory AuthState.unauthenticated([ApiException? error]) {
    return AuthState(
      status: AuthStatus.unauthenticated,
      isLoading: false,
      error: error,
    );
  }

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    String? token,
    bool? isLoading,
    ApiException? error,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      token: token ?? this.token,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthController extends Notifier<AuthState> {
  late final AuthRepository _authRepository;
  late final TokenStorage _tokenStorage;

  @override
  AuthState build() {
    _authRepository = ref.watch(authRepositoryProvider);
    _tokenStorage = ref.watch(tokenStorageProvider);
    return AuthState.initial();
  }

  Future<void> initialize() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final token = await _tokenStorage.getToken();
      if (token == null || token.isEmpty) {
        state = AuthState.unauthenticated();
        return;
      }

      final user = await _authRepository.getCurrentUser();
      state = AuthState.authenticated(user, token);
    } catch (e) {
      await _tokenStorage.deleteToken();
      state = AuthState.unauthenticated();
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _authRepository.login(
        email: email.trim(),
        password: password,
      );
      await _tokenStorage.saveToken(result.token);
      state = AuthState.authenticated(result.user, result.token);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e);
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ServerException(e.toString()),
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await _authRepository.logout();
    } finally {
      await _tokenStorage.deleteToken();
      state = AuthState.unauthenticated();
    }
  }

  void handleUnauthorized() {
    state = AuthState.unauthenticated();
  }

  void clearError() {
    if (state.error != null) {
      state = state.copyWith(clearError: true);
    }
  }
}
