import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findar/core/repositories/abstract_listing_repo.dart';

/// SavedListingsCubit handles user's saved/favorite listings
/// State: {data: [], state: 'loading|done|error', message: '', count: 0}
class SavedListingsCubit extends Cubit<Map<String, dynamic>> {
  final ListingRepository listingRepository;
  bool _hasFetched = false;

  SavedListingsCubit(this.listingRepository)
      : super({
          'data': [],
          'state': 'initial',
          'message': '',
          'count': 0,
        });

  /// Fetch all saved listings for current user
  Future<void> fetchSavedListings({bool forceRefresh = false}) async {
    // Skip fetch if already fetched and not forcing refresh
    if (_hasFetched && !forceRefresh) {
      return;
    }

    emit({...state, 'state': 'loading', 'message': ''});

    try {
      // Get saved listings from repository with onUpdate callback
      final listings = await listingRepository.getSavedListings(
        onUpdate: (data) {
          // Called first with local data, then with remote data
          emit({
            ...state,
            'data': data,
            'state': 'done',
            'message': 'Saved listings fetched successfully',
            'count': data.length,
          });
        },
      );

      _hasFetched = true;
      emit({
        ...state,
        'data': listings,
        'state': 'done',
        'message': 'Saved listings fetched successfully',
        'count': listings.length,
      });
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
    try {
      final result = await listingRepository.saveListing(listingId);

      if (result.state) {
        // Reset _hasFetched to force refetch
        _hasFetched = false;
        await fetchSavedListings(forceRefresh: true);

        emit({
          ...state,
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
    try {
      // Call repository to unsave the listing
      final result = await listingRepository.unsaveListing(listingId);

      if (result.state) {
        // Remove from local state
        final currentData = state['data'] as List;
        final updatedData =
            currentData.where((listing) => listing.id != listingId).toList();

        emit({
          ...state,
          'data': updatedData,
          'count': updatedData.length,
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
      final data = state['data'] as List;
      final count = data.length;
      emit({...state, 'count': count});
      return count;
    } catch (e) {
      return state['count'] as int? ?? 0;
    }
  }

  /// Clear all saved listings
  Future<void> clearAllSavedListings() async {
    emit({...state, 'state': 'loading', 'message': ''});

    try {
      // In a real implementation, would call an API endpoint
      // For now, just clear local state
      emit({
        ...state,
        'data': [],
        'state': 'done',
        'message': 'All saved listings cleared',
        'count': 0,
      });
    } catch (e) {
      emit({
        ...state,
        'state': 'error',
        'message': 'Error clearing saved listings: ${e.toString()}',
      });
    }
  }
}
