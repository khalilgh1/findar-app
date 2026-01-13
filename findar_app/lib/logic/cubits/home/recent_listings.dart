import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findar/core/models/return_result.dart';
import 'package:findar/core/repositories/abstract_listing_repo.dart';

/// RecentCubit handles searching/ (filtering based on type) listings and saving a listing
/// State shape: { data: List<PropertyListing>, state: 'initial|loading|done|error', message: '', savedIds: Set<int> }
class RecentCubit extends Cubit<Map<String, dynamic>> {
  final ListingRepository repository;
  bool _hasFetched = false;
  bool _isFetching = false;

  RecentCubit(this.repository)
      : super({
          'data': [],
          'state': 'initial',
          'message': '',
          'savedIds': <int>{}
        });

  /// Fetch filtered listings using the abstract repository
  Future<void> getRecentListings(
      {String? listingType, bool forceRefresh = false}) async {
    // Skip fetch if already fetched and not forcing refresh
    if (_hasFetched && !forceRefresh) {
      return;
    }

    // Prevent concurrent fetches
    if (_isFetching) {
      return;
    }

    // Set flags immediately to prevent duplicate calls
    _isFetching = true;
    _hasFetched = true;

    emit({...state, 'state': 'loading', 'message': ''});

    try {
      // Load saved listing IDs first
      final savedIds = await repository.getSavedListingIds();

      await repository.getRecentListings(
        listingType: listingType,
        onUpdate: (listings) {
          // Called first with local data, then with remote data
          // This is the source of truth for displaying listings
          emit({
            ...state,
            'data': listings,
            'savedIds': savedIds,
            'state': 'done',
            'message': 'Listings loaded',
          });
        },
      );

      // Don't emit again - onUpdate already handled all updates
    } catch (e) {
      _hasFetched = false; // Reset on error so retry is possible
      emit({
        ...state,
        'state': 'error',
        'message': 'Failed to load listings: ${e.toString()}',
      });
    } finally {
      _isFetching = false;
    }
  }

  /// Save a listing (add to favorites) using the abstract repository
  Future<ReturnResult> saveListing(int listingId) async {
    try {
      final result = await repository.saveListing(listingId);

      if (result.state) {
        // Update savedIds in state
        final currentSavedIds = Set<int>.from(state['savedIds'] as Set<int>);
        currentSavedIds.add(listingId);
        emit(
            {...state, 'message': result.message, 'savedIds': currentSavedIds});
      } else {
        emit({...state, 'message': result.message});
      }

      return result;
    } catch (e) {
      final err = ReturnResult(
        state: false,
        message: 'Failed to save listing: ${e.toString()}',
      );
      emit({...state, 'message': err.message});
      return err;
    }
  }

  /// Unsave a listing (remove from favorites) using the abstract repository
  Future<ReturnResult> unsaveListing(int listingId) async {
    try {
      final result = await repository.unsaveListing(listingId);

      if (result.state) {
        // Update savedIds in state
        final currentSavedIds = Set<int>.from(state['savedIds'] as Set<int>);
        currentSavedIds.remove(listingId);
        emit(
            {...state, 'message': result.message, 'savedIds': currentSavedIds});
      } else {
        emit({...state, 'message': result.message});
      }

      return result;
    } catch (e) {
      final err = ReturnResult(
        state: false,
        message: 'Failed to unsave listing: ${e.toString()}',
      );
      emit({...state, 'message': err.message});
      return err;
    }
  }
}
