import 'package:findar/core/models/property_listing_model.dart';

class Property {
  final int id;
  final String title;
  final String image;
  final String price;
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
  static Property convertListing(PropertyListing p) {
    return Property(
      id: p.id,
      title: p.title,
      image: p.image,
      price: "${p.price.toString()}\$",
      address: p.location,
      details: "${p.bedrooms} beds • ${p.bathrooms} baths •",
      bookmarked: false,
    );
  }
}
