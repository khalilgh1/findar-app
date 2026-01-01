/// API Configuration for the Findar app
///
/// This file was adapted from another project. The `baseUrl` can be
/// supplied at build/runtime via `--dart-define=API_BASE_URL="https://..."`.
/// Default is set to `10.0.2.2` which points to host machine from Android emulator.
class ApiConfig {
  // Use a compile-time environment variable when available, otherwise default
  // to a sensible local-development host for emulators. For phone testing,
  // replace with your machine IP or pass `--dart-define`.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://192.168.1.111:8000',
  );

  static String get apiBaseUrl => baseUrl;

  static const Duration requestTimeout = Duration(seconds: 10);
  static const Duration connectionTimeout = Duration(seconds: 10);

  // API endpoints (all prefixed with /api/) — adapted to your Django urlpatterns
  // Listings
  static const String createListing = '/api/create-listing/';
  static String getListing(int id) => '/api/get-listing/$id';
  static String editListing(int id) => '/api/edit-listing/$id';
  static const String myListings = '/api/my_listings/';
  static String toggleActiveListing(int id) => '/api/toggle_active_listing/$id';
  static String saveListing(int id) => '/api/save_listing/$id';
  static const String savedListings = '/api/saved-listings/';
  static String listingDetails(int id) => '/api/listing-details/$id';
  static const String sponsoredListings = '/api/sponsored-listings/';
  static const String recentListings = '/api/recent-listings/';
  static const String advancedSearch = '/api/advanced-search/';

  // Auth
  static const String loginEndpoint = '/api/login/';
  static const String registerEndpoint = '/api/register/';

  // Notifications
  static const String notificationsRegisterDeviceEndpoint =
      '/api/notifications/register-device/';
  static const String notificationsListEndpoint = '/api/notifications/list/';

  // Helpers
  static String getUrl(String endpoint) => '$apiBaseUrl$endpoint';

  static String getUrlWithParams(String endpoint, String params) =>
      '$apiBaseUrl$endpoint/$params';

  static String getUrlWithQuery(
      String endpoint, Map<String, dynamic> queryParams) {
    final uri = Uri.parse('$apiBaseUrl$endpoint');
    final newUri = uri.replace(
      queryParameters: queryParams.map((k, v) => MapEntry(k, v.toString())),
    );
    return newUri.toString();
  }

  static Map<String, String> getHeaders({String? token}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Feature flags
  static const bool useMockData = false;
  static const bool enableApiLogging = true;
}
