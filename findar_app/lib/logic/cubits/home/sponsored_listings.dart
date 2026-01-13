import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findar/core/models/return_result.dart';
import 'package:findar/core/repositories/abstract_listing_repo.dart';

/// SponsoredCubit handles searching/ (filtering based on type) listings and saving a listing
/// State shape: { data: List<PropertyListing>, state: 'initial|loading|done|error', message: '', savedIds: Set<int> }
class SponsoredCubit extends Cubit<Map<String, dynamic>> {
  final ListingRepository repository;
  bool _hasFetched = false;

  SponsoredCubit(this.repository)
      : super({
          'data': [],
          'state': 'initial',
          'message': '',
          'savedIds': <int>{}
        });

  /// Fetch filtered listings using the abstract repository
  Future<void> getSponsoredListings(
      {String? listingType, bool forceRefresh = false}) async {
    // Skip fetch if already fetched and not forcing refresh
    if (_hasFetched && !forceRefresh) {
      return;
    }

    emit({...state, 'state': 'loading', 'message': ''});

    try {
      final savedIds = await repository.getSavedListingIds();

      final sponsoredListings = await repository.getSponsoredListings(
        onUpdate: (listings) {
          // Called first with local data, then with remote data
          emit({
            ...state,
            'data': listings,
            'savedIds': savedIds,
            'state': 'done',
            'message': 'Listings loaded',
          });
        },
      );

      _hasFetched = true;
      emit({
        ...state,
        'data': sponsoredListings,
        'savedIds': savedIds,
        'state': 'done',
        'message': 'Listings loaded',
      });
    } catch (e) {
      emit({
        ...state,
        'state': 'error',
        'message': 'Failed to load listings: ${e.toString()}',
      });
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
