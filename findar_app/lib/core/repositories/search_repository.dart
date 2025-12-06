import 'package:findar/core/models/return_result.dart';
import 'package:findar/core/services/api_service.dart';

/// Repository for search operations
/// Handles filtering, searching, and retrieving filtered listings
/// Currently uses mock data - will connect to real API when backend is complete
class SearchRepository {
  final ApiService apiService;

  SearchRepository({required this.apiService});

  /// Search listings with filters
  /// 
  /// Returns: ReturnResult with search results if successful
  Future<ReturnResult> search({
    String? query,
    String? location,
    double? minPrice,
    double? maxPrice,
    int? minBedrooms,
    int? maxBedrooms,
    String? propertyType,
    String? classification,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      
      if (query != null && query.isNotEmpty) {
        queryParams['q'] = query;
      }
      if (location != null && location.isNotEmpty) {
        queryParams['location'] = location;
      }
      if (minPrice != null) {
        queryParams['min_price'] = minPrice;
      }
      if (maxPrice != null) {
        queryParams['max_price'] = maxPrice;
      }
      if (minBedrooms != null) {
        queryParams['min_bedrooms'] = minBedrooms;
      }
      if (maxBedrooms != null) {
        queryParams['max_bedrooms'] = maxBedrooms;
      }
      if (propertyType != null && propertyType.isNotEmpty) {
        queryParams['property_type'] = propertyType;
      }
      if (classification != null && classification.isNotEmpty) {
        queryParams['classification'] = classification;
      }

      // Build endpoint with query parameters
      String endpoint = '/listings/search';
      if (queryParams.isNotEmpty) {
        final params = queryParams.entries
            .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
            .join('&');
        endpoint += '?$params';
      }

      final response = await apiService.get(endpoint);

      if (response['success'] != true) {
        return ReturnResult(
          state: false,
          message: response['message'] ?? 'Search failed',
        );
      }

      return ReturnResult(
        state: true,
        message: 'Search completed successfully',
      );
    } catch (e) {
      return ReturnResult(
        state: false,
        message: 'Search error: ${e.toString()}',
      );
    }
  }

  /// Get search suggestions
  /// 
  /// Returns: ReturnResult with suggestions list if successful
  Future<ReturnResult> getSearchSuggestions() async {
    try {
      final response = await apiService.get('/listings/search/suggestions');

      if (response['success'] != true) {
        return ReturnResult(
          state: false,
          message: response['message'] ?? 'Failed to fetch suggestions',
        );
      }

      return ReturnResult(
        state: true,
        message: 'Suggestions loaded successfully',
      );
    } catch (e) {
      return ReturnResult(
        state: false,
        message: 'Error fetching suggestions: ${e.toString()}',
      );
    }
  }

  /// Get available filter options
  /// 
  /// Returns: ReturnResult with filter options if successful
  Future<ReturnResult> getFilterOptions() async {
    try {
      final response = await apiService.get('/listings/filters');

      if (response['success'] != true) {
        return ReturnResult(
          state: false,
          message: response['message'] ?? 'Failed to fetch filter options',
        );
      }

      return ReturnResult(
        state: true,
        message: 'Filter options loaded successfully',
      );
    } catch (e) {
      return ReturnResult(
        state: false,
        message: 'Error fetching filter options: ${e.toString()}',
      );
    }
  }

  /// Save search filter
  /// 
  /// Returns: ReturnResult with success state and message
  Future<ReturnResult> saveFilter({
    required String name,
    required Map<String, dynamic> filters,
  }) async {
    try {
      if (name.isEmpty) {
        return ReturnResult(
          state: false,
          message: 'Filter name is required',
        );
      }

      final response = await apiService.post(
        '/listings/filters/save',
        body: {
          'name': name,
          'filters': filters,
        },
      );

      if (response['success'] != true) {
        return ReturnResult(
          state: false,
          message: response['message'] ?? 'Failed to save filter',
        );
      }

      return ReturnResult(
        state: true,
        message: 'Filter saved successfully',
      );
    } catch (e) {
      return ReturnResult(
        state: false,
        message: 'Error saving filter: ${e.toString()}',
      );
    }
  }

  /// Remove saved search filter
  /// 
  /// Returns: ReturnResult with success state and message
  Future<ReturnResult> removeFilter(int filterId) async {
    try {
      await apiService.delete('/listings/filters/$filterId');

      return ReturnResult(
        state: true,
        message: 'Filter removed successfully',
      );
    } catch (e) {
      return ReturnResult(
        state: false,
        message: 'Error removing filter: ${e.toString()}',
      );
    }
  }

  /// Get all saved filters for user
  /// 
  /// Returns: ReturnResult with saved filters if successful
  Future<ReturnResult> getSavedFilters() async {
    try {
      // TODO: Connect to real API when backend is ready
      return ReturnResult(
        state: true,
        message: 'Saved filters loaded successfully',
      );
    } catch (e) {
      return ReturnResult(
        state: false,
        message: 'Error fetching saved filters: ${e.toString()}',
      );
    }
  }
}
