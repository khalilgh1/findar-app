import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findar/core/models/return_result.dart';
import 'package:findar/core/repositories/abstract_listing_repo.dart';

/// PropertyDetailsCubit handles displaying detailed information about a property
/// State: {id: int?, data: {}, state: 'initial|loading|done|notFound|error', message: ''}
class PropertyDetailsCubit extends Cubit<Map<String, dynamic>> {
  final ListingRepository listingsRepository;

  /// Cache of already-fetched property details to avoid re-fetching
  final Map<int, Map<String, dynamic>> _cache = {};

  PropertyDetailsCubit(this.listingsRepository)
      : super({'id': null, 'data': {}, 'state': 'initial', 'message': ''});

  /// Fetch property details by ID
  Future<void> fetchPropertyDetails(int propertyId,
      {bool forceRefresh = false}) async {
    if (forceRefresh) _cache.remove(propertyId);

    // Return cached data immediately if available
    if (_cache.containsKey(propertyId)) {
      emit({
        'id': propertyId,
        'data': _cache[propertyId]!,
        'state': 'done',
        'message': '',
      });
      return;
    }

    // Clear the previous property so it never flashes under the new id.
    emit({'id': propertyId, 'data': {}, 'state': 'loading', 'message': ''});

    try {
      final property = await listingsRepository.getListingById(propertyId);
      if (state['id'] != propertyId) return; // user already opened another

      if (property == null) {
        emit({...state, 'state': 'notFound', 'message': ''});
        return;
      }

      final propertyJson = property.toJson();
      _cache[propertyId] = propertyJson;

      emit({...state, 'data': propertyJson, 'state': 'done', 'message': ''});
    } catch (e) {
      if (state['id'] != propertyId) return;
      emit({
        ...state,
        'state': 'error',
        'message': e.toString(),
      });
    }
  }

  /// Retry loading the property currently shown.
  Future<void> retry() async {
    final id = state['id'] as int?;
    if (id != null) await fetchPropertyDetails(id, forceRefresh: true);
  }

  /// Invalidate cache for a specific property (e.g., after editing)
  void invalidateCache(int propertyId) {
    _cache.remove(propertyId);
  }

  /// Clear all cached data
  void clearCache() {
    _cache.clear();
  }

  /// Forget everything (logout).
  void reset() {
    _cache.clear();
    emit({'id': null, 'data': {}, 'state': 'initial', 'message': ''});
  }

  /// Report a listing to the moderators.
  Future<ReturnResult> reportListing({
    required int propertyId,
    required String reason,
  }) async {
    try {
      return await listingsRepository.reportListing(
        listingId: propertyId,
        reason: reason,
      );
    } catch (e) {
      return ReturnResult(state: false, message: e.toString());
    }
  }
}
