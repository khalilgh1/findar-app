import 'package:json_annotation/json_annotation.dart';

part 'property_listing_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class PropertyListing {
  final int id;
  final String title;
  final String description;
  final double price;
  final String location;
  final int bedrooms;
  final int bathrooms;
  final String classification;
  final String propertyType;
  final String image;


  @JsonKey(
    fromJson: _boolFromInt,
    toJson: _boolToInt,
  )
  final bool isOnline;
  final String? createdAt;
  final String? updatedAt;


  @JsonKey(
    fromJson: _boolFromInt,
    toJson: _boolToInt,
  )
  final bool isBoosted;
  final DateTime? boostExpiryDate;
  final String? sponsorshipPlanId;
  final String? ownerName;
  final String? ownerImage;
  final String? ownerPhone;

  //sqlite stores bool as int 0/1, so we need to convert
  @JsonKey(
    fromJson: _boolFromInt,
    toJson: _boolToInt,
  )

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
    this.ownerName,
    this.ownerImage,
    this.ownerPhone,
  });

  factory PropertyListing.fromJson(Map<String, dynamic> json) => 
      _$PropertyListingFromJson(json);

  Map<String, dynamic> toJson() => _$PropertyListingToJson(this);

  static bool _boolFromInt(int value) => value == 1;
  static int _boolToInt(bool value) => value ? 1 : 0;

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
    String? ownerName,
    String? ownerImage,
    String? ownerPhone,
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
      ownerName: ownerName ?? this.ownerName,
      ownerImage: ownerImage ?? this.ownerImage,
      ownerPhone: ownerPhone ?? this.ownerPhone,
    );
  }
}