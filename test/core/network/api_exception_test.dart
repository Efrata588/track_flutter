import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager_mobile/core/network/api_exception.dart';
import 'package:task_manager_mobile/core/network/dio_client.dart';

void main() {
  group('Dio Exception Mapping Tests', () {
    final dummyRequestOptions = RequestOptions(path: '/test');

    test('maps 422 with errors to ValidationException', () {
      final dioException = DioException(
        requestOptions: dummyRequestOptions,
        response: Response(
          requestOptions: dummyRequestOptions,
          statusCode: 422,
          data: {
            'message': 'The given data was invalid.',
            'errors': {
              'email': ['The email field is required.'],
              'password': ['The password must be at least 8 characters.'],
            },
          },
        ),
      );

      final mapped = mapDioException(dioException);
      expect(mapped, isA<ValidationException>());
      final valEx = mapped as ValidationException;
      expect(valEx.firstErrorFor('email'), equals('The email field is required.'));
      expect(valEx.firstErrorFor('password'), equals('The password must be at least 8 characters.'));
    });

    test('maps 401 to UnauthorizedException', () {
      final dioException = DioException(
        requestOptions: dummyRequestOptions,
        response: Response(
          requestOptions: dummyRequestOptions,
          statusCode: 401,
          data: {'message': 'Unauthenticated.'},
        ),
      );

      final mapped = mapDioException(dioException);
      expect(mapped, isA<UnauthorizedException>());
    });

    test('maps 403 unverified email to ForbiddenException with flag', () {
      final dioException = DioException(
        requestOptions: dummyRequestOptions,
        response: Response(
          requestOptions: dummyRequestOptions,
          statusCode: 403,
          data: {'message': 'Your email address is not verified.'},
        ),
      );

      final mapped = mapDioException(dioException);
      expect(mapped, isA<ForbiddenException>());
      final forbEx = mapped as ForbiddenException;
      expect(forbEx.isUnverifiedEmail, isTrue);
    });

    test('maps 429 to ThrottledException with friendly message', () {
      final dioException = DioException(
        requestOptions: dummyRequestOptions,
        response: Response(
          requestOptions: dummyRequestOptions,
          statusCode: 429,
          data: {'message': 'Too Many Attempts.'},
        ),
      );

      final mapped = mapDioException(dioException);
      expect(mapped, isA<ThrottledException>());
      expect(mapped.message, contains('Too many attempts'));
    });

    test('maps 500 to ServerException', () {
      final dioException = DioException(
        requestOptions: dummyRequestOptions,
        response: Response(
          requestOptions: dummyRequestOptions,
          statusCode: 500,
          data: {'message': 'Internal Server Error'},
        ),
      );

      final mapped = mapDioException(dioException);
      expect(mapped, isA<ServerException>());
      expect((mapped as ServerException).statusCode, equals(500));
    });

    test('maps connection timeout to NetworkException', () {
      final dioException = DioException(
        requestOptions: dummyRequestOptions,
        type: DioExceptionType.connectionTimeout,
      );

      final mapped = mapDioException(dioException);
      expect(mapped, isA<NetworkException>());
    });
  });
}
