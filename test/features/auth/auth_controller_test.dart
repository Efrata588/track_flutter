import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:task_manager_mobile/core/network/api_exception.dart';
import 'package:task_manager_mobile/core/storage/token_storage.dart';
import 'package:task_manager_mobile/features/auth/data/auth_repository.dart';
import 'package:task_manager_mobile/features/auth/models/auth_user.dart';
import 'package:task_manager_mobile/features/auth/state/auth_controller.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockTokenStorage extends Mock implements TokenStorage {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockTokenStorage mockTokenStorage;
  late ProviderContainer container;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockTokenStorage = MockTokenStorage();

    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
        tokenStorageProvider.overrideWithValue(mockTokenStorage),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AuthController Tests', () {
    final testUser = AuthUser(
      id: 1,
      name: 'Test User',
      email: 'test@example.com',
      emailVerifiedAt: DateTime(2026, 1, 1),
    );
    const testToken = '1|sample_sanctum_token';

    test('initial state is AuthStatus.initial', () {
      final state = container.read(authControllerProvider);
      expect(state.status, equals(AuthStatus.initial));
      expect(state.user, isNull);
      expect(state.token, isNull);
    });

    test('initialize restores session when valid token exists', () async {
      when(() => mockTokenStorage.getToken()).thenAnswer((_) async => testToken);
      when(() => mockAuthRepository.getCurrentUser()).thenAnswer((_) async => testUser);

      await container.read(authControllerProvider.notifier).initialize();

      final state = container.read(authControllerProvider);
      expect(state.status, equals(AuthStatus.authenticated));
      expect(state.user, equals(testUser));
      expect(state.token, equals(testToken));
    });

    test('initialize sets unauthenticated when no token is saved', () async {
      when(() => mockTokenStorage.getToken()).thenAnswer((_) async => null);

      await container.read(authControllerProvider.notifier).initialize();

      final state = container.read(authControllerProvider);
      expect(state.status, equals(AuthStatus.unauthenticated));
      expect(state.user, isNull);
    });

    test('login success saves token and updates state to authenticated', () async {
      when(() => mockAuthRepository.login(
            email: 'test@example.com',
            password: 'password',
          )).thenAnswer((_) async => (user: testUser, token: testToken));
      when(() => mockTokenStorage.saveToken(testToken)).thenAnswer((_) async {});

      final success = await container.read(authControllerProvider.notifier).login(
            email: 'test@example.com',
            password: 'password',
          );

      expect(success, isTrue);
      final state = container.read(authControllerProvider);
      expect(state.status, equals(AuthStatus.authenticated));
      expect(state.user, equals(testUser));
      verify(() => mockTokenStorage.saveToken(testToken)).called(1);
    });

    test('login failure with 422 sets error and stays unauthenticated', () async {
      const validationError = ValidationException('Invalid credentials', errors: {
        'email': ['These credentials do not match our records.'],
      });

      when(() => mockAuthRepository.login(
            email: 'wrong@example.com',
            password: 'password',
          )).thenThrow(validationError);

      final success = await container.read(authControllerProvider.notifier).login(
            email: 'wrong@example.com',
            password: 'password',
          );

      expect(success, isFalse);
      final state = container.read(authControllerProvider);
      expect(state.status, equals(AuthStatus.initial));
      expect(state.error, equals(validationError));
    });

    test('logout deletes token and resets state to unauthenticated', () async {
      when(() => mockAuthRepository.logout()).thenAnswer((_) async {});
      when(() => mockTokenStorage.deleteToken()).thenAnswer((_) async {});

      await container.read(authControllerProvider.notifier).logout();

      final state = container.read(authControllerProvider);
      expect(state.status, equals(AuthStatus.unauthenticated));
      verify(() => mockTokenStorage.deleteToken()).called(1);
    });
  });
}
