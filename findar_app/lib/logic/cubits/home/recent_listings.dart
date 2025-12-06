import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findar/core/models/return_result.dart';
import 'package:findar/core/repositories/abstract_listing_repo.dart';

/// RecentCubit handles searching/ (filtering based on type) listings and saving a listing
/// State shape: { data: List<PropertyListing>, state: 'initial|loading|done|error', message: '' }
class RecentCubit extends Cubit<Map<String, dynamic>> {
  final ListingRepository repository;

  RecentCubit(this.repository)
    : super({'data': [], 'state': 'initial', 'message': ''});

  /// Fetch filtered listings using the abstract repository
  Future<void> getRecentListings({String? listingType}) async {
    emit({...state, 'state': 'loading', 'message': ''});

    try {
      final recentListings = await repository.getRecentListings(
        listingType: listingType, 
      );

      emit({
        ...state,
        'data': recentListings,
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
        emit({...state, 'message': result.message});
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
}
