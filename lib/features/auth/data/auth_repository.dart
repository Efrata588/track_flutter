import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import '../models/auth_user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider));
});

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<({String token, AuthUser user})> login({
    required String email,
    required String password,
    String deviceName = 'Flutter Mobile App',
  }) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {'email': email, 'password': password, 'device_name': deviceName},
      );

      final data = response.data as Map<String, dynamic>;
      final token = data['token'] as String;
      final user = AuthUser.fromJson(data['user'] as Map<String, dynamic>);

      return (token: token, user: user);
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error!;
      }
      throw mapDioException(e);
    }
  }

  Future<AuthUser> getCurrentUser() async {
    try {
      final response = await _dio.get('/user');
      return AuthUser.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error!;
      }
      throw mapDioException(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/logout');
    } catch (_) {
      // Ignore logout API failures as instructed: token will be deleted locally
    }
  }

  Future<String> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        '/forgot-password',
        data: {'email': email, 'client': 'mobile'},
      );
      final data = response.data as Map<String, dynamic>;
      return data['message'] as String? ??
          'If that email is registered, a reset link has been sent.';
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error!;
      }
      throw mapDioException(e);
    }
  }

  Future<String> resetPassword({
    required String token,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _dio.post(
        '/reset-password',
        data: {
          'token': token,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
      final data = response.data as Map<String, dynamic>;
      return data['message'] as String? ?? 'Password has been reset.';
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error!;
      }
      throw mapDioException(e);
    }
  }
}
