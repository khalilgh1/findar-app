import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:findar/core/models/return_result.dart';
import 'package:findar/core/repositories/abstract_listing_repo.dart';

/// MyListingsCubit manages the current user's listings
class MyListingsCubit extends Cubit<Map<String, dynamic>> {
  final ListingRepository repository;
  bool _hasFetched = false;

  MyListingsCubit(this.repository)
      : super({
          'data': {'active': [], 'inactive': []},
          'state': 'initial',
          'message': '',
        });

  /// Forget the signed-out user's listings.
  void reset() {
    _hasFetched = false;
    emit({
      'data': {'active': [], 'inactive': []},
      'state': 'initial',
      'message': '',
    });
  }

  /// Fetch user's listings
  Future<void> fetchMyListings({bool forceRefresh = false}) async {
    // Skip fetch if already fetched and not forcing refresh
    if (_hasFetched && !forceRefresh) {
      return;
    }

    emit({...state, 'state': 'loading', 'message': ''});

    try {
      final listings = await repository.getUserListings(
        onUpdate: (data) {
          // Called first with local data, then with remote data
          emit({
            ...state,
            'data': data,
            'state': 'done',
            'message': 'Listings loaded',
          });
        },
      );

      _hasFetched = true;
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

  /// Delete a listing
  Future<ReturnResult> deleteListing(int id) {
    return _mutate(() => repository.deleteListing(id), 'Failed to delete');
  }

  /// Toggle active status of a listing
  Future<ReturnResult> toggleActiveListing(int id) {
    return _mutate(
        () => repository.toggleActiveListing(id), 'Failed to toggle status');
  }

  /// Runs a write, then reloads the list. A failed write keeps showing the
  /// current list ('done') — the caller shows the returned message — instead
  /// of replacing it with an error page.
  Future<ReturnResult> _mutate(
    Future<ReturnResult> Function() action,
    String failurePrefix,
  ) async {
    emit({...state, 'state': 'loading', 'message': ''});

    try {
      final result = await action();

      if (result.state) {
        final listings = await repository.getUserListings();
        emit({
          ...state,
          'data': listings,
          'state': 'done',
          'message': result.message,
        });
      } else {
        emit({...state, 'state': 'done', 'message': result.message});
      }
      return result;
    } catch (e) {
      final message = '$failurePrefix: ${e.toString()}';
      emit({...state, 'state': 'done', 'message': message});
      return ReturnResult(state: false, message: message);
    }
  }

  /// Edit a listing
  Future<ReturnResult> editListing({
    required int id,
    String? title,
    String? description,
    double? price,
    String? location,
    int? bedrooms,
    int? bathrooms,
    String? classification,
    String? propertyType,
    String? image,
    List<String>? additionalImages,
    bool? isOnline,
    double? area,
    double? latitude,
    double? longitude,
  }) async {
    emit({...state, 'state': 'loading', 'message': ''});

    try {
      final result = await repository.editListing(
        id: id,
        title: title,
        description: description,
        price: price,
        location: location,
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        classification: classification,
        propertyType: propertyType,
        image: image,
        additionalImages: additionalImages,
        isOnline: isOnline,
        area: area,
        latitude: latitude,
        longitude: longitude,
      );

      if (result.state) {
        final listings = await repository.getUserListings();
        emit({
          ...state,
          'data': listings,
          'state': 'done',
          'message': result.message,
        });
      } else {
        emit({...state, 'state': 'done', 'message': result.message});
      }
      return result;
    } catch (e) {
      final message = 'Failed to edit: ${e.toString()}';
      emit({...state, 'state': 'done', 'message': message});
      return ReturnResult(state: false, message: message);
    }
  }

  /// Create a new listing
  Future<ReturnResult> createListing({
    required String title,
    required String description,
    required double price,
    required String location,
    required int bedrooms,
    required int bathrooms,
    required String classification,
    required String propertyType,
    required String image,
    List<String>? additionalImages,
    double? latitude,
    double? longitude,
    int? livingrooms,
    double? area,
    bool isOnline = true,
  }) async {
    emit({...state, 'state': 'loading', 'message': ''});
    try {
      final result = await repository.createListing(
        title: title,
        description: description,
        price: price,
        location: location,
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        classification: classification,
        propertyType: propertyType,
        image: image,
        additionalImages: additionalImages,
        latitude: latitude,
        longitude: longitude,
        livingrooms: livingrooms,
        area: area,
        isOnline: isOnline,
      );
      if (result.state) {
        final listings = await repository.getUserListings();
        emit({
          ...state,
          'data': listings,
          'state': 'done',
          'message': result.message,
        });
      } else {
        emit({...state, 'state': 'done', 'message': result.message});
      }
      return result;
    } catch (e) {
      final message = 'Failed to create: ${e.toString()}';
      emit({...state, 'state': 'done', 'message': message});
      return ReturnResult(state: false, message: message);
    }
  }

  /// Get online (active) listings
  List<dynamic> get onlineListings {
    final data = state['data'] as Map<String, dynamic>? ?? {};
    return data['active'] as List<dynamic>? ?? [];
  }

  /// Get offline (inactive) listings
  List<dynamic> get offlineListings {
    final data = state['data'] as Map<String, dynamic>? ?? {};
    return data['inactive'] as List<dynamic>? ?? [];
  }
}
