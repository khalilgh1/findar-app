import 'package:flutter_bloc/flutter_bloc.dart';

/// BoostCubit handles listing boost operations
/// State: {data: {...}, state: 'initial|loading|done|error', message: ''}
class BoostCubit extends Cubit<Map<String, dynamic>> {
  BoostCubit()
      : super({
          'data': null,
          'state': 'initial',
          'message': '',
        });

  /// Boost a listing with selected sponsorship plan
  /// Simulates payment processing with 2-3 second delay
  Future<void> boostListing({
    required int listingId,
    required String planId,
    required int durationMonths,
  }) async {
    emit({...state, 'state': 'loading', 'message': 'Processing payment...'});

    try {
      // Simulate payment processing delay
      await Future.delayed(const Duration(seconds: 2));

      // Calculate boost expiry date
      final expiryDate = DateTime.now().add(Duration(days: durationMonths * 30));

      // Create boosted listing data
      final boostedData = {
        'listingId': listingId,
        'sponsorshipPlanId': planId,
        'boostExpiryDate': expiryDate.toIso8601String(),
        'isBoosted': true,
      };

      emit({
        ...state,
        'data': boostedData,
        'state': 'done',
        'message': 'Property boosted successfully!',
      });
    } catch (e) {
      emit({
        ...state,
        'state': 'error',
        'message': 'Error boosting property: ${e.toString()}',
      });
    }
  }

  /// Reset boost state
  void reset() {
    emit({
      'data': null,
      'state': 'initial',
      'message': '',
    });
  }
}
