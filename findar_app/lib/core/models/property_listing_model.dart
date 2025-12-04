

class PropertyListing {
  final String id;
  final String imageUrl;
  final String price;
  final String location;
  final int beds;
  final int baths;
  final int sqft;
  final String? title; // Optional, for My Listings screen
  final bool isSaved;

  const PropertyListing({
    required this.id,
    required this.imageUrl,
    required this.price,
    required this.location,
    required this.beds,
    required this.baths,
    required this.sqft,
    this.title,
    this.isSaved = false,
  });

  PropertyListing copyWith({
    String? id,
    String? imageUrl,
    String? price,
    String? location,
    int? beds,
    int? baths,
    int? sqft,
    String? title,
    bool? isSaved,
  }) {
    return PropertyListing(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      location: location ?? this.location,
      beds: beds ?? this.beds,
      baths: baths ?? this.baths,
      sqft: sqft ?? this.sqft,
      title: title ?? this.title,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}