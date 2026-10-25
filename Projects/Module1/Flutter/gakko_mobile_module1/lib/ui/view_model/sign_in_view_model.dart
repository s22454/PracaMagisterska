import 'package:flutter/material.dart';
import 'package:gakko_mobile_module1/data/models/auth_request.dart';
import 'package:gakko_mobile_module1/data/repositories/auth_repository.dart';
import 'package:gakko_mobile_module1/data/repositories/biometric_repository.dart';

class SignInViewModel extends ChangeNotifier{
  final AuthRepository _authRepository;
  final BiometricRepository _biometricRepository;

  bool _isLoading = false;
  String? _errorMessage;

  SignInViewModel({
    AuthRepository? authRepository,
    BiometricRepository? biometricRepository
  }) : _authRepository = authRepository ?? AuthRepository(),
      _biometricRepository = biometricRepository ?? BiometricRepository();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool _hasSavedToken = false;
  bool get hasSavedToken => _hasSavedToken;

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  Future<bool> signInWithCredentials(AuthRequest credentials) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _authRepository.signIn(credentials);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Sign in error: ${e.toString()}';
      _setLoading(false);
      return false;
    }
  }

  Future<void> checkSavedToken() async {
    _hasSavedToken = await _authRepository.hasSavedToken();
    notifyListeners();
  }

  Future<bool> signInWithBiometric() async {
    final isAvailable = await _biometricRepository.isAvailable();

    if (!isAvailable) {
      _errorMessage = 'Biometric authentication is unavailable';
      notifyListeners();
      return false;
    }

    final success = await _biometricRepository.authenticate();

    if (success) {
      _authRepository.isSessionUnlocked = true;
      return true;
    }

    _errorMessage = 'Biometric authentication failed';
    notifyListeners();
    return false;
  }
}
