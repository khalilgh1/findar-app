class PropertyListing {
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
  final bool isBoosted;
  final DateTime? boostExpiryDate;
  final String? sponsorshipPlanId;

  const PropertyListing({
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
    this.isBoosted = false,
    this.boostExpiryDate,
    this.sponsorshipPlanId,
  });

  /// Create PropertyListing from JSON
  factory PropertyListing.fromJson(Map<String, dynamic> json) {
    // Handle is_online - can be bool, int (0/1), or string ('0'/'1')
    bool isOnline = true;
    final isOnlineValue = json['is_online'];
    if (isOnlineValue is bool) {
      isOnline = isOnlineValue;
    } else if (isOnlineValue is int) {
      isOnline = isOnlineValue == 1;
    } else if (isOnlineValue is String) {
      isOnline = isOnlineValue == '1' || isOnlineValue.toLowerCase() == 'true';
    }

    return PropertyListing(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      location: json['location'] as String? ?? '',
      bedrooms: (json['bedrooms'] as num?)?.toInt() ?? 0,
      bathrooms: (json['bathrooms'] as num?)?.toInt() ?? 0,
      classification: json['classification'] as String? ?? 'For Sale',
      propertyType: json['property_type'] as String? ?? 'Apartment',
      image: json['image'] as String? ?? '',
      isOnline: isOnline,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      isBoosted: json['is_boosted'] as bool? ?? false,
      boostExpiryDate: json['boost_expiry_date'] != null 
          ? DateTime.tryParse(json['boost_expiry_date'] as String)
          : null,
      sponsorshipPlanId: json['sponsorship_plan_id'] as String?,
    );
  }

  /// Convert PropertyListing to JSON
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
      'is_boosted': isBoosted,
      if (boostExpiryDate != null) 'boost_expiry_date': boostExpiryDate!.toIso8601String(),
      if (sponsorshipPlanId != null) 'sponsorship_plan_id': sponsorshipPlanId,
    };
  }

  PropertyListing copyWith({
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
    bool? isBoosted,
    DateTime? boostExpiryDate,
    String? sponsorshipPlanId,
  }) {
    return PropertyListing(
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
      isBoosted: isBoosted ?? this.isBoosted,
      boostExpiryDate: boostExpiryDate ?? this.boostExpiryDate,
      sponsorshipPlanId: sponsorshipPlanId ?? this.sponsorshipPlanId,
    );
  }
}