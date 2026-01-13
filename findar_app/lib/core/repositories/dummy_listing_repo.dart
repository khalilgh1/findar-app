import 'package:findar/core/models/property_listing_model.dart';
import 'package:findar/core/models/return_result.dart';
import 'package:findar/core/repositories/abstract_listing_repo.dart';

/// Dummy implementation of ListingRepository for testing and development
class DummyListingRepository implements ListingRepository {
  // In-memory storage for listings
  final List<PropertyListing> _listings = [];
  final Set<int> _savedListingIds = {}; // Track saved listing IDs
  final List<int> _myListingIds = []; // Track user's own listing IDs
  int _nextId = 1;

  DummyListingRepository() {
    _initializeDummyData();
    // Don't auto-initialize saved listings - let users save them manually
  }

  /// Initialize with dummy data
  void _initializeDummyData() {
    _listings.addAll([
      PropertyListing(
        id: _nextId++,
        title: 'Modern Family Home',
        description:
            'Beautiful and spacious modern family home in a quiet neighborhood. Features open-concept living area, gourmet kitchen, and large backyard.',
        price: 550000,
        location: '123 Sunshine Avenue, Meadowville',
        bedrooms: 4,
        bathrooms: 3,
        classification: 'For Sale',
        propertyType: 'House',
        image: 'assets/house1.jpg',
        isOnline: true,
        createdAt: '2024-12-01T10:00:00Z',
      ),
      PropertyListing(
        id: _nextId++,
        title: 'Luxury Downtown Apartment',
        description:
            'Stunning apartment in the heart of downtown with breathtaking city views. Modern amenities and close to all conveniences.',
        price: 2500,
        location: '456 City Center, Downtown',
        bedrooms: 2,
        bathrooms: 2,
        classification: 'For Rent',
        propertyType: 'Apartment',
        image: 'assets/house2.jpg',
        isOnline: true,
        createdAt: '2024-12-02T14:30:00Z',
      ),
      PropertyListing(
        id: _nextId++,
        title: 'Cozy Suburban Villa',
        description:
            'Charming villa with private pool and garden. Perfect for families looking for peace and comfort.',
        price: 850000,
        location: '789 Suburb Road, Austin, TX',
        bedrooms: 5,
        bathrooms: 4,
        classification: 'For Sale',
        propertyType: 'Villa',
        image: 'assets/house3.jpg',
        isOnline: true,
        createdAt: '2024-12-03T09:15:00Z',
      ),
      PropertyListing(
        id: _nextId++,
        title: 'Studio in Tech District',
        description:
            'Compact and efficient studio apartment. Ideal for young professionals working in the tech hub.',
        price: 1200,
        location: '101 Tech Park, Silicon Valley',
        bedrooms: 1,
        bathrooms: 1,
        classification: 'For Rent',
        propertyType: 'Studio',
        image: 'assets/find-dar-test1.jpg',
        isOnline: true,
        createdAt: '2024-12-04T16:45:00Z',
      ),
      PropertyListing(
        id: _nextId++,
        title: 'Beachfront Condo',
        description:
            'Luxurious beachfront condo with panoramic ocean views. Resort-style living at its finest.',
        price: 1200000,
        location: '202 Ocean Drive, Miami Beach, FL',
        bedrooms: 3,
        bathrooms: 3,
        classification: 'For Sale',
        propertyType: 'Condo',
        image: 'assets/find-dar-test2.jpg',
        isOnline: true,
        createdAt: '2024-12-05T11:20:00Z',
      ),
      PropertyListing(
        id: _nextId++,
        title: 'Spacious Family Home',
        description:
            'Well-maintained family home with large yard and updated kitchen. Great neighborhood with excellent schools.',
        price: 425000,
        location: '303 Maple Street, Portland, OR',
        bedrooms: 4,
        bathrooms: 2,
        classification: 'For Sale',
        propertyType: 'House',
        image: 'assets/find-dar-test3.jpg',
        isOnline: true,
        createdAt: '2024-11-28T08:00:00Z',
      ),
      PropertyListing(
        id: _nextId++,
        title: 'Historic Townhouse',
        description:
            'Beautifully restored historic townhouse with modern amenities. Walkable to restaurants and shops.',
        price: 3800,
        location: '404 Heritage Lane, Boston, MA',
        bedrooms: 3,
        bathrooms: 2,
        classification: 'For Rent',
        propertyType: 'House',
        image: 'assets/house1.jpg',
        isOnline: false,
        createdAt: '2024-11-25T13:30:00Z',
      ),
      PropertyListing(
        id: _nextId++,
        title: 'Penthouse Suite',
        description:
            'Ultra-luxury penthouse with private elevator, rooftop terrace, and 360-degree city views.',
        price: 5000000,
        location: '505 Sky Tower, New York, NY',
        bedrooms: 5,
        bathrooms: 5,
        classification: 'For Sale',
        propertyType: 'Apartment',
        image: 'assets/house2.jpg',
        isOnline: true,
        createdAt: '2024-11-30T15:00:00Z',
      ),
    ]);
  }

  @override
  Future<ReturnResult> createListing({
    required String title,
    required String description,
    required double price,
    required String location,
    required int bedrooms,
    required int bathrooms,
    required String classification,
    required String propertyType,
    required String image,
    List<String>? additionalImages,
    double? latitude,
    double? longitude,
    int? livingrooms,
    double? area,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final newListing = PropertyListing(
        id: _nextId++,
        title: title,
        description: description,
        price: price,
        location: location,
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        classification: classification,
        propertyType: propertyType,
        image: image,
        isOnline: true,
        createdAt: DateTime.now().toIso8601String(),
      );

      _listings.add(newListing);
      _myListingIds.add(newListing.id);

      return ReturnResult(state: true, message: 'Listing created successfully');
    } catch (e) {
      return ReturnResult(
        state: false,
        message: 'Failed to create listing: ${e.toString()}',
      );
    }
  }

  @override
  Future<ReturnResult> editListing({
    required int id,
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
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final index = _listings.indexWhere((listing) => listing.id == id);
      if (index == -1) {
        return ReturnResult(state: false, message: 'Listing not found');
      }

      final existingListing = _listings[index];
      final updatedListing = existingListing.copyWith(
        title: title,
        description: description,
        price: price,
        location: location,
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        classification: classification,
        propertyType: propertyType,
        image: image,
        isOnline: isOnline,
      );

      _listings[index] = updatedListing;

      return ReturnResult(state: true, message: 'Listing updated successfully');
    } catch (e) {
      return ReturnResult(
        state: false,
        message: 'Failed to update listing: ${e.toString()}',
      );
    }
  }

  @override
  Future<ReturnResult> deleteListing(int id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final index = _listings.indexWhere((listing) => listing.id == id);

      if (index == -1) {
        return ReturnResult(state: false, message: 'Listing not found');
      }

      _listings.removeAt(index);

      return ReturnResult(state: true, message: 'Listing deleted successfully');
    } catch (e) {
      return ReturnResult(
        state: false,
        message: 'Failed to delete listing: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<PropertyListing>> getFilteredListings({
    double? latitude,
    double? longitude,
    double? minPrice,
    double? maxPrice,
    String? listingType,
    String? buildingType,
    int? numBedrooms,
    int? numBathrooms,
    double? minSqft,
    double? maxSqft,
    String? listedBy,
    String? sortBy,
    OnDataUpdate<List<PropertyListing>>? onUpdate,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    var filtered = _listings.where((listing) => listing.isOnline).toList();

    // Apply filters
    if (minPrice != null) {
      filtered = filtered.where((l) => l.price >= minPrice).toList();
    }
    if (maxPrice != null) {
      filtered = filtered.where((l) => l.price <= maxPrice).toList();
    }
    if (listingType != null) {
      filtered = filtered
          .where(
            (l) => l.classification.toLowerCase().contains(
                  listingType.toLowerCase(),
                ),
          )
          .toList();
    }
    if (buildingType != null) {
      filtered = filtered
          .where(
            (l) => l.propertyType.toLowerCase() == buildingType.toLowerCase(),
          )
          .toList();
    }
    if (numBedrooms != null) {
      filtered = filtered.where((l) => l.bedrooms >= numBedrooms).toList();
    }
    if (numBathrooms != null) {
      filtered = filtered.where((l) => l.bathrooms >= numBathrooms).toList();
    }

    return filtered;
  }

  @override
  Future<Map<String, List<PropertyListing>>> getUserListings({
    OnDataUpdate<Map<String, List<PropertyListing>>>? onUpdate,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    //get current user's listings
    final active = _listings
        .where((l) => _myListingIds.contains(l.id) && l.isOnline)
        .toList();
    final inactive = _listings
        .where((l) => _myListingIds.contains(l.id) && !l.isOnline)
        .toList();

    return {'active': active, 'inactive': inactive};
  }

  @override
  Future<List<PropertyListing>> getRecentListings({
    String? query,
    String? listingType,
    OnDataUpdate<List<PropertyListing>>? onUpdate,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    var recent = _listings.where((l) => l.isOnline).toList();

    // Apply query filter
    if (query != null && query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      recent = recent
          .where(
            (l) =>
                l.title.toLowerCase().contains(lowerQuery) ||
                l.description.toLowerCase().contains(lowerQuery) ||
                l.location.toLowerCase().contains(lowerQuery),
          )
          .toList();
    }

    // Apply listing type filter
    if (listingType != null) {
      recent = recent
          .where(
            (l) => l.classification.toLowerCase().contains(
                  listingType.toLowerCase(),
                ),
          )
          .toList();
    }

    // Sort by created date (most recent first) and limit to 20
    recent.sort((a, b) {
      final aDate = DateTime.tryParse(a.createdAt ?? '') ?? DateTime(2000);
      final bDate = DateTime.tryParse(b.createdAt ?? '') ?? DateTime(2000);
      return bDate.compareTo(aDate);
    });

    return recent.take(20).toList();
  }

  @override
  Future<List<PropertyListing>> getSponsoredListings({
    OnDataUpdate<List<PropertyListing>>? onUpdate,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    // In a real implementation, this would filter by a 'boosted' or 'sponsored' flag
    // For now, return the most expensive listings as "sponsored"
    final sponsored = _listings.where((l) => l.isOnline).toList()
      ..sort((a, b) => b.price.compareTo(a.price));

    return sponsored.take(3).toList();
  }

  // Additional utility methods for testing

  /// Get a single listing by ID
  @override
  Future<PropertyListing?> getListingById(int id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      return _listings.firstWhere((listing) => listing.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get all listings (for debugging)
  List<PropertyListing> getAllListings() {
    return List.unmodifiable(_listings);
  }

  /// Clear all listings
  void clearAllListings() {
    _listings.clear();
    _nextId = 1;
  }

  @override
  Future<ReturnResult> saveListing(int listingId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final index = _listings.indexWhere((l) => l.id == listingId);
      if (index == -1) {
        return ReturnResult(state: false, message: 'Listing not found');
      }

      // Add to saved listings
      _savedListingIds.add(listingId);
      return ReturnResult(state: true, message: 'Listing saved successfully');
    } catch (e) {
      return ReturnResult(
        state: false,
        message: 'Failed to save listing: ${e.toString()}',
      );
    }
  }

  @override
  Future<ReturnResult> unsaveListing(int listingId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      if (!_savedListingIds.contains(listingId)) {
        return ReturnResult(state: false, message: 'Listing not in saved');
      }

      // Remove from saved listings
      _savedListingIds.remove(listingId);
      return ReturnResult(state: true, message: 'Listing removed from saved');
    } catch (e) {
      return ReturnResult(
        state: false,
        message: 'Failed to unsave listing: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<PropertyListing>> getSavedListings({
    OnDataUpdate<List<PropertyListing>>? onUpdate,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // Return all listings that are in the saved set
      final savedListings = _listings
          .where((listing) => _savedListingIds.contains(listing.id))
          .toList();

      return savedListings;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Set<int>> getSavedListingIds() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));

    // Return the saved listing IDs without auto-initialization
    return Set.from(_savedListingIds);
  }

  @override
  Future<ReturnResult> toggleActiveListing(int id) async {
    throw UnimplementedError();
  }

  /// Reset to initial dummy data
  void resetToInitialData() {
    _listings.clear();
    _nextId = 1;
    _initializeDummyData();
  }
}
