import 'dart:convert';
import 'dart:io';

import 'package:findar/core/models/return_result.dart';
import 'package:findar/core/services/auth_manager.dart';
import 'package:findar/core/services/findar_api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

http.Response json(Object body, int status) => http.Response(
      jsonEncode(body),
      status,
      headers: {'content-type': 'application/json'},
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    await AuthManager().setTokens(
      AuthTokens(accessToken: 'old-access', refreshToken: 'old-refresh'),
    );
  });

  test('2xx returns the decoded body', () async {
    final api = FindarApiService(
      client: MockClient((req) async => json([1, 2], 200)),
    );
    expect(await api.get('/api/recent-listings/'), [1, 2]);
  });

  test('sends the bearer token', () async {
    String? auth;
    final api = FindarApiService(client: MockClient((req) async {
      auth = req.headers['Authorization'];
      return json({}, 200);
    }));
    await api.get('/api/my_listings/');
    expect(auth, 'Bearer old-access');
  });

  test('401 refreshes once, replays with the new token and rotates refresh',
      () async {
    final seen = <String>[];
    final api = FindarApiService(client: MockClient((req) async {
      if (req.url.path == '/api/auth/refresh') {
        expect(jsonDecode(req.body), {'refresh': 'old-refresh'});
        return json({'access': 'new-access', 'refresh': 'new-refresh'}, 200);
      }
      seen.add(req.headers['Authorization']!);
      return req.headers['Authorization'] == 'Bearer new-access'
          ? json({'ok': true}, 200)
          : json({'detail': 'expired'}, 401);
    }));

    expect(await api.get('/api/my_listings/'), {'ok': true});
    expect(seen, ['Bearer old-access', 'Bearer new-access']);
    expect(AuthManager().accessToken, 'new-access');
    expect(AuthManager().refreshToken, 'new-refresh');
  });

  test('parallel 401s share a single refresh call', () async {
    var refreshCalls = 0;
    final api = FindarApiService(client: MockClient((req) async {
      if (req.url.path == '/api/auth/refresh') {
        refreshCalls++;
        await Future<void>.delayed(const Duration(milliseconds: 20));
        return json({'access': 'new-access', 'refresh': 'new-refresh'}, 200);
      }
      return req.headers['Authorization'] == 'Bearer new-access'
          ? json({}, 200)
          : json({'detail': 'expired'}, 401);
    }));

    await Future.wait([
      api.get('/api/recent-listings/'),
      api.get('/api/sponsored-listings/'),
      api.get('/api/saved-listings/'),
    ]);
    expect(refreshCalls, 1);
  });

  test('rejected refresh token ends the session', () async {
    var expired = false;
    final sub = AuthManager().onSessionExpired.listen((_) => expired = true);
    addTearDown(sub.cancel);

    final api = FindarApiService(client: MockClient((req) async {
      if (req.url.path == '/api/auth/refresh') {
        return json({'detail': 'Token is blacklisted'}, 401);
      }
      return json({'detail': 'expired'}, 401);
    }));

    final res = await api.get('/api/my_listings/');
    await Future<void>.delayed(Duration.zero);

    expect(res, isA<ReturnResult>().having((r) => r.state, 'state', false));
    expect(AuthManager().isAuthenticated, isFalse);
    expect(expired, isTrue);
  });

  test('network error during refresh does not log the user out', () async {
    final api = FindarApiService(client: MockClient((req) async {
      if (req.url.path == '/api/auth/refresh') {
        throw const SocketException('offline');
      }
      return json({'detail': 'expired'}, 401);
    }));

    final res = await api.get('/api/my_listings/');
    expect(res, isA<ReturnResult>());
    expect(AuthManager().accessToken, 'old-access');
  });

  test('login 400 is not treated as an expired session', () async {
    var refreshCalls = 0;
    final api = FindarApiService(client: MockClient((req) async {
      if (req.url.path == '/api/auth/refresh') refreshCalls++;
      return json({'success': false, 'message': 'incorrect email or password'},
          400);
    }));
    final res = await api.post('/api/auth/login', body: {});
    expect((res as ReturnResult).message, 'incorrect email or password');
    expect(refreshCalls, 0);
  });

  group('error messages', () {
    Future<String> messageFor(http.Response response) async {
      final api = FindarApiService(client: MockClient((_) async => response));
      final res = await api.post('/api/create-listing/', body: {});
      return (res as ReturnResult).message;
    }

    test('DRF field errors are flattened', () async {
      expect(
        await messageFor(json({
          'email': ['custom user with this email already exists.'],
          'password': ['Password must contain at least one digit.'],
        }, 400)),
        'email: custom user with this email already exists.\n'
        'password: Password must contain at least one digit.',
      );
    });

    test('error / message / detail keys win', () async {
      expect(await messageFor(json({'error': 'dont have permission'}, 403)),
          'dont have permission');
      expect(await messageFor(json({'detail': 'Not found.'}, 404)),
          'Not found.');
    });

    test('HTML error pages fall back to the status code', () async {
      expect(
        await messageFor(http.Response('<html>500</html>', 500)),
        'Request failed (500)',
      );
    });
  });

  test('socket errors name the server', () async {
    final api = FindarApiService(
      client: MockClient((_) async => throw const SocketException('down')),
    );
    final res = await api.get('/api/recent-listings/') as ReturnResult;
    expect(res.message, startsWith('Cannot reach server'));
  });
}
