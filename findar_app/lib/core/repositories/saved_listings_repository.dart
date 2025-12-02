import 'package:findar/core/models/return_result.dart';
import 'package:findar/core/services/api_service.dart';

/// Repository for saved listings (favorites)
/// Handles fetching and managing user's saved/favorited listings
/// Currently uses mock data - will connect to real API when backend is complete
class SavedListingsRepository {
  final ApiService apiService;

  SavedListingsRepository({required this.apiService});

  /// Fetch all saved listings for current user
  /// 
  /// Returns: ReturnResult with saved listings if successful
  Future<ReturnResult> fetchSavedListings() async {
    try {
      final response = await apiService.get('/saved-listings/');

      if (response['success'] != true) {
        return ReturnResult(
          state: false,
          message: response['message'] ?? 'Failed to fetch saved listings',
        );
      }

      return ReturnResult(
        state: true,
        message: 'Saved listings loaded successfully',
      );
    } catch (e) {
      return ReturnResult(
        state: false,
        message: 'Error fetching saved listings: ${e.toString()}',
      );
    }
  }

  /// Add listing to saved/favorites
  /// 
  /// Returns: ReturnResult with success state and message
  Future<ReturnResult> saveListing(int listingId) async {
    try {
      final response = await apiService.post(
        '/saved-listings/add',
        body: {'listing_id': listingId},
      );

      if (response['success'] != true) {
        return ReturnResult(
          state: false,
          message: response['message'] ?? 'Failed to save listing',
        );
      }

      return ReturnResult(
        state: true,
        message: 'Listing saved successfully',
      );
    } catch (e) {
      return ReturnResult(
        state: false,
        message: 'Error saving listing: ${e.toString()}',
      );
    }
  }

  /// Remove listing from saved/favorites
  /// 
  /// Returns: ReturnResult with success state and message
  Future<ReturnResult> unsaveListing(int listingId) async {
    try {
      await apiService.delete('/saved-listings/$listingId');
      
      return ReturnResult(
        state: true,
        message: 'Listing removed from saved successfully',
      );
    } catch (e) {
      return ReturnResult(
        state: false,
        message: 'Error removing listing: ${e.toString()}',
      );
    }
  }

  /// Get count of saved listings
  /// 
  /// Returns: Number of saved listings
  Future<int> getSavedListingsCount() async {
    try {
      final response = await apiService.get('/saved-listings/count');

      if (response['success'] == true) {
        return response['data']['count'] as int? ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Clear all saved listings
  /// 
  /// Returns: ReturnResult with success state and message
  Future<ReturnResult> clearAllSavedListings() async {
    try {
      final response = await apiService.post(
        '/saved-listings/clear',
        body: {},
      );

      if (response['success'] != true) {
        return ReturnResult(
          state: false,
          message: response['message'] ?? 'Failed to clear saved listings',
        );
      }

      return ReturnResult(
        state: true,
        message: 'All saved listings cleared successfully',
      );
    } catch (e) {
      return ReturnResult(
        state: false,
        message: 'Error clearing saved listings: ${e.toString()}',
      );
    }
  }
}
