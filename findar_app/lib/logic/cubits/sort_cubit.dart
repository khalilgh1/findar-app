import 'package:flutter_bloc/flutter_bloc.dart';

/// Sort options for property listings
/// Maps to backend sort_by values: price_asc, price_desc, date_newest, date_oldest, area_asc, area_desc
enum SortOption {
  priceLowToHigh('Price: Low to High', 'price_asc'),
  priceHighToLow('Price: High to Low', 'price_desc'),
  newest('Newest', 'date_newest'),
  oldest('Oldest', 'date_oldest'),
  sqftLowToHigh('Size: Small to Large', 'area_asc'),
  sqftHighToLow('Size: Large to Small', 'area_desc');

  final String displayName;
  final String backendValue;
  const SortOption(this.displayName, this.backendValue);
}

/// SortCubit manages the current sort option for property listings
class SortCubit extends Cubit<SortOption> {
  SortCubit() : super(SortOption.newest);

  /// Get current sort option
  SortOption get currentSort => state;

  /// Update sort option
  void updateSort(SortOption sortOption) {
    emit(sortOption);
  }

  /// Reset to default sort (newest)
  void resetSort() {
    emit(SortOption.newest);
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

      case SortOption.sqftLowToHigh:
        sorted.sort((a, b) => _extractSqft(a).compareTo(_extractSqft(b)));
        break;

      case SortOption.sqftHighToLow:
        sorted.sort((a, b) => _extractSqft(b).compareTo(_extractSqft(a)));
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
