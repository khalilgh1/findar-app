import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findar/core/repositories/saved_listings_repository.dart';
import 'package:findar/core/services/api_service.dart';

/// SavedListingsCubit handles user's saved/favorite listings
/// State: {data: [], state: 'loading|done|error', message: '', count: 0}
class SavedListingsCubit extends Cubit<Map<String, dynamic>> {
  late final SavedListingsRepository savedListingsRepository;

  SavedListingsCubit()
      : super({
          'data': [],
          'state': 'initial',
          'message': '',
          'count': 0,
        }) {
    savedListingsRepository =
        SavedListingsRepository(apiService: ApiService());
  }

  /// Fetch all saved listings for current user
  Future<void> fetchSavedListings() async {
    emit({...state, 'state': 'loading', 'message': ''});

    try {
      final result = await savedListingsRepository.fetchSavedListings();

      if (result.state) {
        // In real app, would parse listings from response
        final count = await savedListingsRepository.getSavedListingsCount();

        emit({
          ...state,
          'data': [], // Would contain saved listings
          'state': 'done',
          'message': result.message,
          'count': count,
        });
      } else {
        emit({
          ...state,
          'state': 'error',
          'message': result.message,
        });
      }
    } catch (e) {
      emit({
        ...state,
        'state': 'error',
        'message': 'Error fetching saved listings: ${e.toString()}',
      });
    }
  }

  /// Add listing to saved/favorites
  Future<void> saveListing(int listingId) async {
    // Don't show loading for individual operations
    try {
      final result = await savedListingsRepository.saveListing(listingId);

      if (result.state) {
        // Update count
        final count = await savedListingsRepository.getSavedListingsCount();
        emit({
          ...state,
          'count': count,
          'message': result.message,
        });
      } else {
        emit({
          ...state,
          'message': result.message,
        });
      }
    } catch (e) {
      emit({
        ...state,
        'message': 'Error saving listing: ${e.toString()}',
      });
    }
  }

  /// Remove listing from saved/favorites
  Future<void> unsaveListing(int listingId) async {
    // Don't show loading for individual operations
    try {
      final result = await savedListingsRepository.unsaveListing(listingId);

      if (result.state) {
        // Update count
        final count = await savedListingsRepository.getSavedListingsCount();
        emit({
          ...state,
          'count': count,
          'message': result.message,
        });
      } else {
        emit({
          ...state,
          'message': result.message,
        });
      }
    } catch (e) {
      emit({
        ...state,
        'message': 'Error removing listing: ${e.toString()}',
      });
    }
  }

  /// Get count of saved listings
  Future<int> getSavedCount() async {
    try {
      final count = await savedListingsRepository.getSavedListingsCount();
      emit({...state, 'count': count});
      return count;
    } catch (e) {
      return state['count'] as int;
    }
  }

  /// Clear all saved listings
  Future<void> clearAllSavedListings() async {
    emit({...state, 'state': 'loading', 'message': ''});

    try {
      final result =
          await savedListingsRepository.clearAllSavedListings();

      if (result.state) {
        emit({
          ...state,
          'data': [],
          'state': 'done',
          'message': result.message,
          'count': 0,
        });
      } else {
        emit({
          ...state,
          'state': 'error',
          'message': result.message,
        });
      }
    } catch (e) {
      emit({
        ...state,
        'state': 'error',
        'message': 'Error clearing saved listings: ${e.toString()}',
      });
    }
  }
}
