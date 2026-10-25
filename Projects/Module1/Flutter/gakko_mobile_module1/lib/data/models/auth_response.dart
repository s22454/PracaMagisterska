class AuthResponse {
  final String token;

  AuthResponse({
    required this.token
  });

  AuthResponse.fromJson(Map<String, dynamic> json):
    token = json['token'] as String;
}
