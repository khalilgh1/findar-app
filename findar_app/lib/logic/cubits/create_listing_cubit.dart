import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findar/core/repositories/abstract_listing_repo.dart';

/// CreateListingCubit handles property listing creation
/// 
/// State structure:
/// {
///   'data': Listing | null,       // Created listing data
///   'state': 'initial|loading|done|error',
///   'message': 'success or error message'
/// }
class CreateListingCubit extends Cubit<Map<String, dynamic>> {
  final ListingRepository listingsRepository;

  CreateListingCubit(this.listingsRepository) : super({
    'data': null,
    'state': 'initial',
    'message': ''
  });

  /// Create a new property listing
  /// 
  /// Validates all required fields, calls repository, emits states
  /// - Loading state shown to UI (ProgressButton shows spinner)
  /// - Success/error states with messages
  Future<void> createListing({
    required String title,
    required String description,
    required double price,
    required String location,
    required int bedrooms,
    required int bathrooms,
    required String classification,
    required String propertyType,
    String? image,
  }) async {
    // 1. Show loading state
    emit({
      ...state,
      'state': 'loading',
      'message': ''
    });

    try {
      // 2. Call repository method (returns ReturnResult)
      final result = await listingsRepository.createListing(
        title: title,
        description: description,
        price: price,
        location: location,
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        classification: classification,
        propertyType: propertyType,
        image: image ?? '',
      );

      // 3. Check result.state
      if (result.state) {
        // Success: listing created
        emit({
          ...state,
          'data': {
            'title': title,
            'description': description,
            'price': price,
            'location': location,
            'bedrooms': bedrooms,
            'bathrooms': bathrooms,
            'classification': classification,
            'propertyType': propertyType,
          },
          'state': 'done',
          'message': result.message,  // "Listing created successfully"
        });
      } else {
        // Failure: validation or API error
        emit({
          ...state,
          'state': 'error',
          'message': result.message,
        });
      }
    } catch (e) {
      // 4. Handle unexpected errors
      emit({
        ...state,
        'state': 'error',
        'message': 'Creation error: ${e.toString()}',
      });
    }
  }

  /// Update existing listing
  /// 
  /// Only provided fields will be updated
  Future<void> updateListing(
    int listingId, {
    String? title,
    String? description,
    double? price,
    String? location,
    int? bedrooms,
    int? bathrooms,
    String? image,
  }) async {
    emit({
      ...state,
      'state': 'loading',
      'message': ''
    });

    try {
      final result = await listingsRepository.editListing(
        id: listingId,
        title: title,
        description: description,
        price: price,
        location: location,
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        classification: null,
        propertyType: null,
        image: image ?? '',
      );

      if (result.state) {
        emit({
          ...state,
          'state': 'done',
          'message': result.message,
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
        'message': 'Update error: ${e.toString()}',
      });
    }
  }

  /// Delete a listing
  Future<void> deleteListing(int listingId) async {
    emit({
      ...state,
      'state': 'loading',
      'message': ''
    });

    try {
      final result = await listingsRepository.deleteListing(listingId);

      if (result.state) {
        emit({
          ...state,
          'state': 'done',
          'message': result.message,
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
        'message': 'Delete error: ${e.toString()}',
      });
    }
  }

  /// Get current state type
  String get stateType => state['state'] as String;

  /// Get current message
  String get message => state['message'] as String;

  /// Check if listing was created successfully
  bool get isCreated => stateType == 'done';

  /// Get created listing data
  get createdListing => state['data'];
}
