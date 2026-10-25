import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorageService {
  final _secureStorage = const FlutterSecureStorage();

  static const String _tokenKey = 'auth_token';

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<bool> hasToken() async {
    if (!await _secureStorage.containsKey(key: _tokenKey)) {
      return false;
    }

    String token = (await getToken()) ?? '';

    return token.isNotEmpty;
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }
}
