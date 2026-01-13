import 'package:findar/core/services/findar_api_service.dart';
import 'package:findar/core/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'auth_manager.dart';
import 'package:findar/core/config/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:findar/core/models/return_result.dart';

class Custom_User {
  final int id;
  final String username;
  final String email;
  final String phone;
  final String? profilePic;
  final String accountType;
  final int credits;

  const Custom_User({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
    this.profilePic,
    required this.accountType,
    required this.credits,
  });

  factory Custom_User.fromJson(Map<String, dynamic> json) {
    return Custom_User(
      id: json['id'] ?? 0,
      username: json['username'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      profilePic: json['profile_pic'] ?? "",
      accountType: json['account_type'] ?? 'normal',
      credits: json['credits'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone': phone,
      'profile_pic': profilePic,
      'account_type': accountType,
      'credits': credits,
    };
  }
}



class FirebaseOAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final AuthManager _authManager = AuthManager();
  final http.Client _client = http.Client();

  // GOOGLE SIGN IN
  Future<void> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw 'Google sign-in cancelled';
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      final User? user = userCredential.user;
      if (user != null) {
        final idToken = await user.getIdToken();
        await _authenticateWithBackend(idToken, 'google', user.email);
      }
    } catch (e) {
      print(e);
      throw '$e';
    }
  }

  // Authenticate with backend using Firebase ID token
  Future<void> _authenticateWithBackend(
    String? idToken,
    String provider,
    String? email,
  ) async {
    if (idToken == null) {
      throw 'No ID token received';
    }

    try {
      final res = await _client.post(
        Uri.parse(ApiConfig.getUrl('/api/auth/oauth/')),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id_token': idToken,
          'provider': provider,
          'email': email,
        }),
      );

      if (res.statusCode == 401) {
        throw 'Firebase authentication failed';
      }

      if (res.statusCode != 200) {
        throw 'Backend authentication failed';
      }

      final json = jsonDecode(res.body);
      final result = await login_Oauth(
        response: json,
      );

    } catch (e) {
      throw '$e';
    }
  }


  Future<ReturnResult> login_Oauth({
    required response,
  }) async {
    try {
      // Store user data
      final currentUser = response['data']['user'] != null ? Custom_User.fromJson(response['data']['user']) : null;

      // Store tokens securely (NEW)
      await AuthManager().setTokens(
        AuthTokens(
          accessToken: response['data']['access'],
          refreshToken: response['data']['refresh'],
        ),
      );

      NotificationService.registerDeviceAfterLogin();
      FirebaseMessaging.instance.subscribeToTopic(currentUser!.accountType == 'agency' ? 'agency' : 'individual');


      return ReturnResult(
        state: true,
        message: 'Login successful',
      );
    } catch (e) {
      return ReturnResult(
        state: false,
        message: 'Login error: ${e.toString()}',
      );
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
      await _authManager.clear();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  // Get current user
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  // Check if user is authenticated
  bool isAuthenticated() {
    return _firebaseAuth.currentUser != null;
  }
}
