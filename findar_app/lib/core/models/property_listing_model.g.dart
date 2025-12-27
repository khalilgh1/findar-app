// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'property_listing_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PropertyListing _$PropertyListingFromJson(Map<String, dynamic> json) =>
    PropertyListing(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      location: json['location'] as String? ?? 'Unknown',
      bedrooms: (json['bedrooms'] as num).toInt(),
      bathrooms: (json['bathrooms'] as num).toInt(),
      classification: json['listing_type'] as String,
      propertyType: json['building_type'] as String,
      image: json['image'] as String,
      isOnline: json['is_online'] == null
          ? true
          : PropertyListing._boolFromInt((json['is_online'] as num).toInt()),
      createdAt: json['created_at'] as String?,
      isBoosted: json['is_boosted'] == null
          ? false
          : PropertyListing._boolFromInt((json['is_boosted'] as num).toInt()),
      boostExpiryDate: json['boost_expiry_date'] == null
          ? null
          : DateTime.parse(json['boost_expiry_date'] as String),
      sponsorshipPlanId: json['sponsorship_plan_id'] as String?,
      ownerName: json['owner_name'] as String?,
      ownerImage: json['owner_image'] as String?,
      ownerPhone: json['owner_phone'] as String?,
    );

Map<String, dynamic> _$PropertyListingToJson(PropertyListing instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'price': instance.price,
      'location': instance.location,
      'bedrooms': instance.bedrooms,
      'bathrooms': instance.bathrooms,
      'listing_type': instance.classification,
      'building_type': instance.propertyType,
      'image': instance.image,
      'is_online': PropertyListing._boolToInt(instance.isOnline),
      'created_at': instance.createdAt,
      'is_boosted': PropertyListing._boolToInt(instance.isBoosted),
      'boost_expiry_date': instance.boostExpiryDate?.toIso8601String(),
      'sponsorship_plan_id': instance.sponsorshipPlanId,
      'owner_name': instance.ownerName,
      'owner_image': instance.ownerImage,
      'owner_phone': instance.ownerPhone,
    };
