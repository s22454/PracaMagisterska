import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> isAvailable() async {
    try {
      return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Use biometric to authenticate',
        biometricOnly: false
      );
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

}
