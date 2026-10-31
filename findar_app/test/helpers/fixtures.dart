import 'package:findar/core/models/property_listing_model.dart';

/// A listing exactly as the backend's `PostSerializers` returns it
/// (`fields = "__all__"` + `owner_details`). Keep in sync with
/// findar_backend/api/serializers.py — `api/test_flows.py` asserts the same
/// key set on the server side.
Map<String, dynamic> apiPost({
  int id = 7,
  String title = 'Sunny flat',
  bool active = true,
  bool boosted = false,
  int ownerId = 3,
  String? mainPic = 'https://res.cloudinary.com/x/main.jpg',
  int? bedrooms = 2,
  String? buildingType = 'apartment',
  String? listingType = 'rent',
  double price = 45000.0,
}) =>
    {
      'id': id,
      'owner_details': {
        'id': ownerId,
        'username': 'owner_user',
        'email': 'owner@example.com',
        'phone': '0555000000',
        'profile_pic': null,
        'account_type': 'agency',
      },
      'title': title,
      'price': price,
      'description': 'Bright two-bedroom flat',
      'address': 'Hydra, Algiers',
      'created_at': '2026-10-30T10:00:00.123456Z',
      'active': active,
      'boosted': boosted,
      'main_pic': mainPic,
      'pics': ['https://res.cloudinary.com/x/1.jpg'],
      'latitude': 36.75,
      'longitude': 3.06,
      'bedrooms': bedrooms,
      'bathrooms': 1,
      'livingrooms': 1,
      'area': 85.5,
      'listing_type': listingType,
      'building_type': buildingType,
      'owner': ownerId,
    };

PropertyListing listing({
  int id = 1,
  String title = 'Listing',
  bool isOnline = true,
  bool isBoosted = false,
  int? ownerId = 3,
}) =>
    PropertyListing(
      id: id,
      title: title,
      description: 'd',
      price: 1000,
      location: 'Algiers',
      bedrooms: 1,
      bathrooms: 1,
      classification: 'rent',
      propertyType: 'apartment',
      image: '',
      isOnline: isOnline,
      isBoosted: isBoosted,
      ownerId: ownerId,
      ownerName: ownerId == null ? null : 'owner_$ownerId',
    );
