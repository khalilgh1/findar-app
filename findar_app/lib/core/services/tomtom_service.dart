import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationResult {
  final String address;
  final double latitude;
  final double longitude;

  LocationResult({
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  @override
  String toString() => address;
}

class TomTomService {
  static const String _apiKey = 'T2rF8bW6YArgxfvKiYIsbkgfmlOkvqEQ';
  static const String _baseUrl = 'https://api.tomtom.com/search/2/search';

  static Future<List<LocationResult>> autocomplete(String query) async {
    // Focus search on Algeria (countrySet=DZ)
    final url = Uri.parse('$_baseUrl/$query.json?key=$_apiKey&limit=5&countrySet=DZ');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List<dynamic>;
      return results.map((item) {
        final position = item['position'];
        return LocationResult(
          address: item['address']['freeformAddress'] as String,
          latitude: position['lat'] as double,
          longitude: position['lon'] as double,
        );
      }).toList();
    } else {
      return [];
    }
  }
}
