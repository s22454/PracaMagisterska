import 'package:gakko_mobile_module1/data/services/biometric_service.dart';

class BiometricRepository {
  final BiometricService _biometricService;

  BiometricRepository({
    BiometricService? biometricService
  }) : _biometricService = biometricService ?? BiometricService();

  Future<bool> isAvailable() async {
    return await _biometricService.isAvailable();
  }

  Future<bool> authenticate() async {
    return await _biometricService.authenticate();
  }
}
