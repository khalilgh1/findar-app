import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findar/core/repositories/abstract_listing_repo.dart';
/// MyListingsCubit manages the current user's listings
class MyListingsCubit extends Cubit<Map<String, dynamic>> {
  final ListingRepository repository;

  MyListingsCubit(this.repository)
    : super({
        'data': {'active': [], 'inactive': []},
        'state': 'initial',
        'message': '',
      }) {
    //for now use DummyListingRepository
  }

  /// Fetch user's listings
  Future<void> fetchMyListings() async {
    emit({...state, 'state': 'loading', 'message': ''});

    try {
      final listings = await repository.getUserListings();

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
  Future<void> deleteListing(int id) async {
    emit({...state, 'state': 'loading', 'message': ''});

    try {
      final result = await repository.deleteListing(id);

      if (result.state) {
        final listings = await repository.getUserListings();
        emit({
          ...state,
          'data': listings,
          'state': 'done',
          'message': result.message,
        });
      } else {
        emit({...state, 'state': 'error', 'message': result.message});
      }
    } catch (e) {
      emit({
        ...state,
        'state': 'error',
        'message': 'Failed to delete: ${e.toString()}',
      });
    }
  }

  /// Edit a listing
  Future<void> editListing({
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
    bool? isOnline,
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
        emit({...state, 'state': 'error', 'message': result.message});
      }
    } catch (e) {
      emit({
        ...state,
        'state': 'error',
        'message': 'Failed to edit: ${e.toString()}',
      });
    }
  }

  /// Create a new listing
  Future<void> createListing({
    required String title,
    required String description,
    required double price,
    required String location,
    required int bedrooms,
    required int bathrooms,
    required String classification,
    required String propertyType,
    required String image,
    double? latitude,
    double? longitude,
    int? livingrooms,
    double? area,
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
        latitude: latitude,
        longitude: longitude,
        livingrooms: livingrooms,
        area: area,
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
        emit({...state, 'state': 'error', 'message': result.message});
      }
    } catch (e) {
      emit({
        ...state,
        'state': 'error',
        'message': 'Failed to create: ${e.toString()}',
      });
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
