import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';
import '../storage/token_storage.dart';
import 'api_exception.dart';

final onUnauthorizedEventProvider = Provider<void Function()?>((ref) => null);

ApiException mapDioException(DioException error) {
  if (error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.sendTimeout ||
      error.type == DioExceptionType.receiveTimeout ||
      error.type == DioExceptionType.connectionError) {
    return const NetworkException();
  }

  final response = error.response;
  if (response != null) {
    final status = response.statusCode;
    final data = response.data;
    String message = 'An unexpected error occurred.';

    if (data is Map<String, dynamic>) {
      if (data['message'] is String && (data['message'] as String).isNotEmpty) {
        message = data['message'] as String;
      }
    }

    if (status == 422) {
      final errorsMap = <String, List<String>>{};
      if (data is Map<String, dynamic> && data['errors'] is Map) {
        final rawErrors = data['errors'] as Map;
        for (final entry in rawErrors.entries) {
          final key = entry.key.toString();
          final val = entry.value;
          if (val is List) {
            errorsMap[key] = val.map((e) => e.toString()).toList();
          } else if (val is String) {
            errorsMap[key] = [val];
          }
        }
      }
      return ValidationException(message, errors: errorsMap);
    }

    if (status == 401) {
      return UnauthorizedException(message);
    }

    if (status == 403) {
      final isUnverified =
          message.toLowerCase().contains('not verified') ||
          message.toLowerCase().contains("isn't verified") ||
          message.toLowerCase().contains('unverified');
      return ForbiddenException(
        message: isUnverified
            ? "Your email isn't verified. Verify it from the web app, then log in again."
            : message,
        isUnverifiedEmail: isUnverified,
      );
    }

    if (status == 429) {
      return const ThrottledException();
    }

    if (status != null && status >= 500) {
      return ServerException(message, status);
    }

    return ServerException(message, status);
  }

  return NetworkException(error.message ?? 'Network communication error.');
}

final dioProvider = Provider<Dio>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'User-Agent': 'TrackMobileApp/1.0',
      },
    ),
  );

  bool isHandling401 = false;

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await tokenStorage.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException error, handler) async {
        // Guard against interceptor loops and handle 401
        if (error.response?.statusCode == 401 && !isHandling401) {
          isHandling401 = true;
          try {
            await tokenStorage.deleteToken();
            final onUnauthorized = ref.read(onUnauthorizedEventProvider);
            onUnauthorized?.call();
          } finally {
            isHandling401 = false;
          }
        }

        final mapped = mapDioException(error);
        return handler.reject(
          DioException(
            requestOptions: error.requestOptions,
            response: error.response,
            type: error.type,
            error: mapped,
            message: mapped.message,
          ),
        );
      },
    ),
  );

  return dio;
});
