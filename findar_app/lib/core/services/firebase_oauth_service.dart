import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Google sign-in through Firebase. Only produces a Firebase ID token; the
/// backend exchange and session handling live in AuthRepository.
class FirebaseOAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Runs the Google account picker and returns a Firebase ID token, or null
  /// if the user cancelled.
  Future<String?> getGoogleIdToken() async {
    // Always show the account picker instead of silently reusing the last
    // Google account.
    await _googleSignIn.signOut();

    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    final idToken = await userCredential.user?.getIdToken();
    if (idToken == null) {
      throw Exception('No ID token received from Firebase');
    }
    return idToken;
  }

  /// Signs out of Firebase/Google. Best effort.
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint('Firebase sign out failed: $e');
    }
  }
}
