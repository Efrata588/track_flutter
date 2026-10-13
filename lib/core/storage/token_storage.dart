import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage(ref.watch(secureStorageProvider));
});

class TokenStorage {
  TokenStorage(this._storage);

  final FlutterSecureStorage _storage;
  static const String _kTokenKey = 'sanctum_auth_token';

  Future<String?> getToken() async {
    try {
      return await _storage.read(key: _kTokenKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: _kTokenKey, value: token);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _kTokenKey);
  }
}
