import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findar/core/models/return_result.dart';
import 'package:findar/core/repositories/abstract_listing_repo.dart';

/// SponsoredCubit handles searching/ (filtering based on type) listings and saving a listing
/// State shape: { data: List<PropertyListing>, state: 'initial|loading|done|error', message: '' }
class SponsoredCubit extends Cubit<Map<String, dynamic>> {
  final ListingRepository repository;

  SponsoredCubit(this.repository)
    : super({'data': [], 'state': 'initial', 'message': ''});

  /// Fetch filtered listings using the abstract repository
  Future<void> getSponsoredListings({String? listingType}) async {
    emit({...state, 'state': 'loading', 'message': ''});

    try {
      final sponsoredListings = await repository.getSponsoredListings();

      emit({
        ...state,
        'data': sponsoredListings,
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
