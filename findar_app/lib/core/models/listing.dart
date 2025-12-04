class Listing {
  final int id;
  final String title;
  final String description;
  final double price;
  final String location;
  final int bedrooms;
  final int bathrooms;
  final String classification; // 'For Sale', 'For Rent'
  final String propertyType; // 'Apartment', 'House', etc.
  final String image;
  final bool isOnline;
  final String? createdAt;
  final String? updatedAt;

  Listing({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    required this.bedrooms,
    required this.bathrooms,
    required this.classification,
    required this.propertyType,
    required this.image,
    this.isOnline = true,
    this.createdAt,
    this.updatedAt,
  });

  /// Create Listing from JSON
  factory Listing.fromJson(Map<String, dynamic> json) {
    return Listing(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      location: json['location'] as String? ?? '',
      bedrooms: json['bedrooms'] as int? ?? 0,
      bathrooms: json['bathrooms'] as int? ?? 0,
      classification: json['classification'] as String? ?? 'For Sale',
      propertyType: json['property_type'] as String? ?? 'Apartment',
      image: json['image'] as String? ?? '',
      isOnline: json['is_online'] as bool? ?? true,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  /// Convert Listing to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'location': location,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'classification': classification,
      'property_type': propertyType,
      'image': image,
      'is_online': isOnline,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    };
  }

  /// Create a copy with modified fields
  Listing copyWith({
    int? id,
    String? title,
    String? description,
    double? price,
    String? location,
    int? bedrooms,
    int? bathrooms,
    String? classification,
    String? propertyType,
    String? image,
    bool? isOnline,
    String? createdAt,
    String? updatedAt,
  }) {
    return Listing(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      location: location ?? this.location,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      classification: classification ?? this.classification,
      propertyType: propertyType ?? this.propertyType,
      image: image ?? this.image,
      isOnline: isOnline ?? this.isOnline,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
