import 'dart:convert';
import 'package:findar/core/services/notification_service.dart';
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

  Future<void> sendOtpcode(String email) async {
    final res = await _client.post(
      Uri.parse(ApiConfig.getUrl('/api/auth/send-register-otp/')),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to send OTP code');
    }
  }

  Future<void> confirmEmailOtp(String email,String username , String phone , String password , String account_type String otp) async {
    final res = await _client.post(
      Uri.parse(ApiConfig.getUrl('/api/auth/verify-register-otp/')),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'username':username,
        'phine' : phone,
        'password':password,
        "account_type":account_type,
        'otp': otp,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Invalid OTP code');
    }
  }

  Future<String?> getAccessToken() async {
    return _auth.accessToken;
  }
  
  /// REFRESH TOKEN
  Future<bool> refreshToken() async {
    if (_auth.refreshToken == null) return false;

    final res = await _client.post(
      Uri.parse(ApiConfig.getUrl('/api/auth/refresh')),
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

    final token = NotificationService.getFCMToken();
    final res = await _client.post(
      Uri.parse(ApiConfig.getUrl('/api/auth/logout/')),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'device_token': token , "refresh":_auth.refreshToken}),
    ); 
    await NotificationService.removeTokenOnLogout();
    if (res.statusCode != 200) {
      throw Exception('Logout failed');
    }
    await _auth.clear();
    
  }

  /// SEND RESET CODE
  Future<Map<String, dynamic>> sendResetCode(String email) async {
    final res = await _client.post(
      Uri.parse(ApiConfig.getUrl('/api/auth/password-reset/request/')),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to send reset code');
    }

    return jsonDecode(res.body);
  }

  /// CHECK RESET CODE
  Future<Map<String, dynamic>> checkResetCode(String email, String code) async {
    final res = await _client.post(
      Uri.parse(ApiConfig.getUrl('/api/auth/password-reset/verify/')),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'code': code,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Invalid verification code');
    }

    return jsonDecode(res.body);
  }

  /// RESET PASSWORD / SET NEW PASSWORD
  Future<Map<String, dynamic>> resetPassword(
    String email,
    String code,
    String newPassword,
  ) async {
    final res = await _client.post(
      Uri.parse(ApiConfig.getUrl('/api/auth/password-reset/confirm/')),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'code': code,
        'new_password': newPassword,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to reset password');
    }

    return jsonDecode(res.body);
  }
}
