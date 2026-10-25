import 'package:gakko_mobile_module1/data/models/auth_request.dart';
import 'package:gakko_mobile_module1/data/services/auth_service.dart';
import 'package:gakko_mobile_module1/data/services/token_storage_service.dart';

class AuthRepository {
  final AuthService _authService;
  final TokenStorageService _tokenStorageService;

  static final AuthRepository _instance = AuthRepository._internal();
  factory AuthRepository() => _instance;

  bool isSessionUnlocked = false;

  AuthRepository._internal()
      : _authService =  AuthService(),
      _tokenStorageService = TokenStorageService();

    Future<void> signIn(AuthRequest credentials) async {
      try {
        final status = await _authService.signin(credentials);
        await _tokenStorageService.saveToken(status.token);
        isSessionUnlocked = true;
      } catch (e) {
        throw Exception(e);
      }
    }

    Future<bool> hasSavedToken() async {
      return await _tokenStorageService.hasToken();
    }

    Future<bool> isSignedIn() async {
      return await _tokenStorageService.hasToken() && isSessionUnlocked;
    }

    Future<void> signOut() async {
      await _tokenStorageService.deleteToken();
      isSessionUnlocked = false;
    }
}
