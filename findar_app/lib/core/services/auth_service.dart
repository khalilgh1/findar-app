import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:findar/core/config/api_config.dart';
import 'auth_manager.dart';

class AuthService {
  final http.Client _client = http.Client();
  final AuthManager _auth = AuthManager();

  /// LOGIN
  Future<void> login(String email, String password) async {
    final res = await _client.post(
      Uri.parse(ApiConfig.getUrl('/auth/login')),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Invalid credentials');
    }

    final json = jsonDecode(res.body);
    await _auth.setTokens(
      AuthTokens(
        accessToken: json['access'],
        refreshToken: json['refresh'],
      ),
    );
  }

  Future<String?> getAccessToken() async {
    return _auth.accessToken;
  }
  
  /// REFRESH TOKEN
  Future<bool> refreshToken() async {
    if (_auth.refreshToken == null) return false;

    final res = await _client.post(
      Uri.parse(ApiConfig.getUrl('/auth/refresh')),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': _auth.refreshToken}),
    );

    if (res.statusCode != 200) return false;

    final json = jsonDecode(res.body);
    await _auth.setTokens(
      AuthTokens(
        accessToken: json['access'],
        refreshToken: json['refresh'],
      ),
    );
    return true;
  }

  Future<void> logout() async {
    await _auth.clear();
  }
}
