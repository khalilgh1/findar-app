import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findar/core/models/property_listing_model.dart';
import 'package:findar/core/models/return_result.dart';
import 'package:findar/core/repositories/abstract_listing_repo.dart';

/// SearchCubit handles searching/filtering listings and saving a listing
/// State shape: { data: List<PropertyListing>, state: 'initial|loading|done|error', message: '' }
class SearchCubit extends Cubit<Map<String, dynamic>> {
  final ListingRepository repository;

  SearchCubit(this.repository)
    : super({'data': <PropertyListing>[], 'state': 'initial', 'message': ''});

  /// Fetch filtered listings using the abstract repository
  Future<void> getFilteredListings({
    double? latitude,
    double? longitude,
    double? minPrice,
    double? maxPrice,
    String? listingType,
    String? buildingType,
    int? numBedrooms,
    int? numBathrooms,
    double? minSqft,
    double? maxSqft,
    String? listedBy,
  }) async {
    emit({...state, 'state': 'loading', 'message': ''});
    try {
      final listings = await repository.getFilteredListings(
        latitude: latitude,
        longitude: longitude,
        minPrice: minPrice,
        maxPrice: maxPrice,
        listingType: listingType,
        buildingType: buildingType,
        numBedrooms: numBedrooms,
        numBathrooms: numBathrooms,
        minSqft: minSqft,
        maxSqft: maxSqft,
        listedBy: listedBy,
      );

      emit({
        ...state,
        'data': listings,
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

  //search by query
  Future<void> getrecentListings(String query) async {
    emit({...state, 'state': 'loading', 'message': ''});

    try {
      final recentListings = await repository.getRecentListings(query: query);
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
