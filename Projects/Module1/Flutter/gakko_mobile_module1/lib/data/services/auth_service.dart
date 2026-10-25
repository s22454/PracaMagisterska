import 'dart:convert';

import 'package:gakko_mobile_module1/data/models/auth_request.dart';
import 'package:gakko_mobile_module1/data/models/auth_response.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _apiBaseUrl = 'https://manor-armhole-wolf.ngrok-free.dev';
  static const String _apiSigninPath = 'api/auth/login';

  final http.Client _client;

  AuthService({http.Client? client})
    : _client = client = client ?? http.Client();

  Future<AuthResponse> signin(AuthRequest credentials) async {
    final response = await _client.post(
      Uri.parse('$_apiBaseUrl/$_apiSigninPath'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(credentials.toJson()),
    );

    if (response.statusCode == 200) {
      return AuthResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to sign in. Api error');
    }
  }
}
