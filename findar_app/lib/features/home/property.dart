import 'package:findar/core/models/property_listing_model.dart';
import 'package:findar/l10n/app_localizations.dart';

class Property {
  final int id;
  final String title;
  final String image;
  final double price;
  final String address;
  final String details;
  bool bookmarked;

  Property({
    required this.id,
    required this.title,
    required this.image,
    required this.price,
    required this.address,
    required this.details,
    required this.bookmarked,
  });
  static Property convertListing(
    PropertyListing p,
    AppLocalizations l10n, {
    bool bookmarked = false,
  }) {
    return Property(
      id: p.id,
      title: p.title,
      image: p.image,
      price: p.price,
      address: p.location,
      details:
          "${l10n.bedroomsCount(p.bedrooms)} • ${l10n.bathroomsCount(p.bathrooms)} • ${_localizedPropertyType(p.propertyType, l10n)}",
      bookmarked: bookmarked,
    );
  }

  static String _localizedPropertyType(
    String propertyType,
    AppLocalizations l10n,
  ) {
    switch (propertyType.toLowerCase()) {
      case 'house':
        return l10n.house;
      case 'apartment':
        return l10n.apartment;
      case 'villa':
        return l10n.villa;
      case 'studio':
        return l10n.studio;
      case 'office':
        return l10n.office;
      default:
        return propertyType;
    }
  }
}
