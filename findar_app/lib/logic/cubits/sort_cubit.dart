import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/cubits/base_state.dart';

/// Sort options for property listings
enum SortOption {
  priceLowToHigh('Price: Low to High'),
  priceHighToLow('Price: High to Low'),
  newest('Newest'),
  oldest('Oldest'),
  mostPopular('Most Popular'),
  sqftLowToHigh('Size: Small to Large'),
  sqftHighToLow('Size: Large to Small'),
  bedroomsLowToHigh('Bedrooms: Low to High'),
  bedroomsHighToLow('Bedrooms: High to Low');

  final String displayName;
  const SortOption(this.displayName);
}

/// SortCubit manages the current sort option for property listings
/// Uses BaseState for consistent state management
class SortCubit extends Cubit<BaseState> {
  SortCubit() : super(const BaseSuccess(SortOption.newest));

  /// Get current sort option
  SortOption get currentSort {
    final currentState = state;
    if (currentState is BaseSuccess<SortOption>) {
      return currentState.data;
    }
    return SortOption.newest; // Default fallback
  }

  /// Update sort option
  void updateSort(SortOption sortOption) {
    emit(BaseSuccess(sortOption));
  }

  /// Reset to default sort (newest)
  void resetSort() {
    emit(const BaseSuccess(SortOption.newest));
  }

  /// Sort a list of properties based on current sort option
  List<Map<String, dynamic>> sortProperties(
    List<Map<String, dynamic>> properties,
  ) {
    final sorted = List<Map<String, dynamic>>.from(properties);

    switch (currentSort) {
      case SortOption.priceLowToHigh:
        sorted.sort((a, b) => _extractPrice(a).compareTo(_extractPrice(b)));
        break;

      case SortOption.priceHighToLow:
        sorted.sort((a, b) => _extractPrice(b).compareTo(_extractPrice(a)));
        break;

      case SortOption.newest:
        // Assuming properties have a 'createdAt' or 'id' field
        // Higher ID means newer (or use actual date if available)
        sorted.sort((a, b) {
          final aDate = a['createdAt'] ?? a['id']?.toString() ?? '0';
          final bDate = b['createdAt'] ?? b['id']?.toString() ?? '0';
          return bDate.toString().compareTo(aDate.toString());
        });
        break;

      case SortOption.oldest:
        sorted.sort((a, b) {
          final aDate = a['createdAt'] ?? a['id']?.toString() ?? '0';
          final bDate = b['createdAt'] ?? b['id']?.toString() ?? '0';
          return aDate.toString().compareTo(bDate.toString());
        });
        break;

      case SortOption.mostPopular:
        // Assuming properties have a 'views' or 'saves' field
        sorted.sort((a, b) {
          final aPopularity = (a['views'] ?? 0) + (a['saves'] ?? 0);
          final bPopularity = (b['views'] ?? 0) + (b['saves'] ?? 0);
          return bPopularity.compareTo(aPopularity);
        });
        break;

      case SortOption.sqftLowToHigh:
        sorted.sort((a, b) => _extractSqft(a).compareTo(_extractSqft(b)));
        break;

      case SortOption.sqftHighToLow:
        sorted.sort((a, b) => _extractSqft(b).compareTo(_extractSqft(a)));
        break;

      case SortOption.bedroomsLowToHigh:
        sorted.sort((a, b) {
          final aBeds = a['beds'] ?? a['bedrooms'] ?? 0;
          final bBeds = b['beds'] ?? b['bedrooms'] ?? 0;
          return aBeds.compareTo(bBeds);
        });
        break;

      case SortOption.bedroomsHighToLow:
        sorted.sort((a, b) {
          final aBeds = a['beds'] ?? a['bedrooms'] ?? 0;
          final bBeds = b['beds'] ?? b['bedrooms'] ?? 0;
          return bBeds.compareTo(aBeds);
        });
        break;
    }

    return sorted;
  }

  /// Extract price from property data
  /// Handles both numeric and string formats like "$500,000"
  double _extractPrice(Map<String, dynamic> property) {
    final price = property['price'];
    if (price is num) return price.toDouble();
    if (price is String) {
      // Remove $ and commas, then parse
      final cleanPrice = price.replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(cleanPrice) ?? 0;
    }
    return 0;
  }

  /// Extract square footage from property data
  /// Handles both numeric and string formats like "1,500 sqft"
  double _extractSqft(Map<String, dynamic> property) {
    final sqft = property['sqft'] ?? property['area'];
    if (sqft is num) return sqft.toDouble();
    if (sqft is String) {
      // Remove commas and "sqft", then parse
      final cleanSqft = sqft.replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(cleanSqft) ?? 0;
    }
    return 0;
  }
}
