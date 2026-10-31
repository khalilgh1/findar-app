import 'dart:convert';

import 'package:findar/core/repositories/auth_repository.dart';
import 'package:findar/core/repositories/local_user_store.dart';
import 'package:findar/core/services/auth_manager.dart';
import 'package:findar/core/services/findar_api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic> userJson(int id, {String name = 'tester'}) => {
      'id': id,
      'username': name,
      'email': '$name@example.com',
      'phone': '0555000000',
      'profile_pic': null,
      'account_type': 'individual',
      'credits': 0,
    };

/// Same envelope as the backend's login/register views.
http.Response session(int id) => http.Response(
      jsonEncode({
        'success': true,
        'data': {'access': 'a$id', 'refresh': 'r$id', 'user': userJson(id)},
      }),
      200,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<http.Request> requests;
  late http.Response Function(http.Request) handler;
  late int cleared;
  late AuthRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    await AuthManager().clear();
    requests = [];
    cleared = 0;
    handler = (_) => http.Response('{}', 200);
    repo = AuthRepository(
      apiService: FindarApiService(client: MockClient((req) async {
        requests.add(req);
        return handler(req);
      })),
      clearUserData: () async => cleared++,
    );
  });

  test('login stores tokens and the user', () async {
    handler = (_) => session(5);
    final res = await repo.login(email: 'tester@example.com', password: 'Passw0rdX');

    expect(res.state, isTrue, reason: res.message);
    expect(requests.single.url.path, '/api/auth/login');
    expect(AuthManager().accessToken, 'a5');
    expect(AuthManager().refreshToken, 'r5');
    expect(repo.getCurrentUser()!.id, 5);
    expect((await LocalUserStore().loadUser())!.id, 5);
  });

  test('login failure shows the server message', () async {
    handler = (_) => http.Response(
        jsonEncode({'success': false, 'message': 'incorrect email or password'}), 400);
    final res = await repo.login(email: 'tester@example.com', password: 'bad');
    expect(res.state, isFalse);
    expect(res.message, 'incorrect email or password');
    expect(AuthManager().isAuthenticated, isFalse);
  });

  test('client-side validation runs before any request', () async {
    expect((await repo.login(email: 'nope', password: 'x')).state, isFalse);
    expect(
      (await repo.register(
              name: 'ab', email: 'a@b.c', phone: '1', password: 'Passw0rdX',
              accountType: 'individual'))
          .state,
      isFalse,
    );
    expect(requests, isEmpty);
  });

  test('register sends the backend field names', () async {
    handler = (_) => session(6);
    final res = await repo.register(
      name: 'new_user', email: 'new@example.com', phone: '0555123456',
      password: 'Passw0rdX', accountType: 'agency',
    );
    expect(res.state, isTrue, reason: res.message);
    expect(requests.single.url.path, '/api/auth/register');
    expect(jsonDecode(requests.single.body), {
      'username': 'new_user',
      'email': 'new@example.com',
      'phone': '0555123456',
      'password': 'Passw0rdX',
      'account_type': 'agency',
    });
  });

  test('signing in as a different account clears the previous cache', () async {
    handler = (_) => session(1);
    await repo.login(email: 'a@example.com', password: 'Passw0rdX');
    expect(cleared, 0);

    await repo.login(email: 'a@example.com', password: 'Passw0rdX');
    expect(cleared, 0, reason: 'same user again keeps the cache');

    handler = (_) => session(2);
    await repo.login(email: 'b@example.com', password: 'Passw0rdX');
    expect(cleared, 1);
  });

  test('refreshProfile unwraps {success, data}', () async {
    handler = (_) => http.Response(
          jsonEncode({
            'success': true,
            'data': {...userJson(9, name: 'from_server'), 'credits': 40, 'listings': []},
          }),
          200,
        );
    final res = await repo.refreshProfile();
    expect(res.state, isTrue, reason: res.message);
    expect(repo.getCurrentUser()!.username, 'from_server');
    expect(repo.getCurrentUser()!.credits, 40);
  });

  test('updateProfile sends username and stores the returned user', () async {
    handler = (_) => http.Response(
          jsonEncode({'success': true, 'data': userJson(9, name: 'renamed')}),
          200,
        );
    final res = await repo.updateProfile(name: 'renamed', phone: '0555999999');
    expect(res.state, isTrue, reason: res.message);
    expect(requests.single.method, 'PUT');
    expect(jsonDecode(requests.single.body),
        {'username': 'renamed', 'phone': '0555999999'});
    expect(repo.getCurrentUser()!.username, 'renamed');
  });

  test('updateProfile surfaces validation errors', () async {
    handler = (_) => http.Response(
          jsonEncode({'success': false, 'message': ['This username is already taken.']}),
          400,
        );
    final res = await repo.updateProfile(name: 'taken');
    expect(res.state, isFalse);
    expect(res.message, 'This username is already taken.');
  });
}
