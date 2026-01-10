import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findar/core/services/findar_api_service.dart';
import 'package:findar/core/config/api_config.dart';

/// BoostCubit handles listing boost operations
/// State: {data: {...}, state: 'initial|loading|done|error', message: ''}
class BoostCubit extends Cubit<Map<String, dynamic>> {
  final FindarApiService _apiService;

  BoostCubit({FindarApiService? apiService})
      : _apiService = apiService ?? FindarApiService(),
        super({
          'data': null,
          'state': 'initial',
          'message': '',
        });

  /// Boost a listing with card information
  Future<void> boostListing({
    required int listingId,
    required String planId,
    required int durationMonths,
    required String cardNumber,
    required String cardHolder,
    required String expiryDate,
    required String cvv,
  }) async {
    emit({...state, 'state': 'loading', 'message': 'Processing payment...'});

    try {
      // Call the backend API to boost the listing
      final response = await _apiService.post(
        ApiConfig.boostListing(listingId),
        body: {
          'card_number': cardNumber,
          'card_holder': cardHolder,
          'expiry_date': expiryDate,
          'cvv': cvv,
        },
      );

      if (response['error'] != null) {
        emit({
          ...state,
          'state': 'error',
          'message': response['error'],
        });
        return;
      }

      // Calculate boost expiry date
      final expiryDateCalc = DateTime.now().add(Duration(days: durationMonths * 30));

      // Create boosted listing data
      final boostedData = {
        'listingId': listingId,
        'sponsorshipPlanId': planId,
        'boostExpiryDate': expiryDateCalc.toIso8601String(),
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
