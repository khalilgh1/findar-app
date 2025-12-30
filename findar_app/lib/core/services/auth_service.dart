
// Temporary stub until AuthService is implemented
class AuthService {
  Future<String?> getAccessToken() async => null;
  Future<bool> refreshTokenIfPossible() async => false;
  Future<void> logout() async {}
}