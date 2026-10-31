import 'package:findar/core/models/property_listing_model.dart';
import 'package:findar/core/repositories/remote_listing_repo.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fixtures.dart';

void main() {
  group('RemoteListingRepository.parseListing', () {
    test('maps a real backend payload onto the model', () {
      final l = RemoteListingRepository.parseListing(apiPost());

      expect(l.id, 7);
      expect(l.title, 'Sunny flat');
      expect(l.location, 'Hydra, Algiers');
      expect(l.price, 45000.0);
      expect(l.bedrooms, 2);
      expect(l.bathrooms, 1);
      expect(l.area, 85.5);
      expect(l.classification, 'rent');
      expect(l.propertyType, 'apartment');
      expect(l.image, 'https://res.cloudinary.com/x/main.jpg');
      expect(l.additionalImages, ['https://res.cloudinary.com/x/1.jpg']);
      expect(l.createdAt, '2026-10-30T10:00:00.123456Z');
      expect(l.ownerId, 3);
      expect(l.ownerName, 'owner_user');
      expect(l.ownerEmail, 'owner@example.com');
      expect(l.ownerAccountType, 'agency');
    });

    test('reads active / boosted (not is_online / is_boosted)', () {
      expect(RemoteListingRepository.parseListing(apiPost(active: false)).isOnline,
          isFalse);
      expect(RemoteListingRepository.parseListing(apiPost(boosted: true)).isBoosted,
          isTrue);
      expect(RemoteListingRepository.parseListing(apiPost()).isOnline, isTrue);
      expect(RemoteListingRepository.parseListing(apiPost()).isBoosted, isFalse);
    });

    test('tolerates nullable server columns', () {
      final l = RemoteListingRepository.parseListing(
        apiPost(mainPic: null, bedrooms: null, buildingType: null, listingType: null),
      );
      expect(l.image, '');
      expect(l.bedrooms, 0);
      expect(l.propertyType, 'apartment');
      expect(l.classification, 'rent');
    });

    test('integer prices from the API parse as doubles', () {
      final raw = apiPost()..['price'] = 1200;
      expect(RemoteListingRepository.parseListing(raw).price, 1200.0);
    });

    test('falls back to the bare owner id when owner_details is absent', () {
      final raw = apiPost()..remove('owner_details');
      final l = RemoteListingRepository.parseListing(raw);
      expect(l.ownerId, 3);
      expect(l.ownerName, isNull);
    });
  });

  group('PropertyListing JSON', () {
    test('round-trips through toJson / fromJson (property details cache)', () {
      final original = RemoteListingRepository.parseListing(apiPost(boosted: true));
      final copy = PropertyListing.fromJson(original.toJson());
      expect(copy.id, original.id);
      expect(copy.isBoosted, isTrue);
      expect(copy.isOnline, isTrue);
      expect(copy.ownerName, original.ownerName);
      expect(copy.additionalImages, original.additionalImages);
    });

    test('accepts SQLite 0/1 booleans', () {
      final json = listing().toJson()
        ..['is_online'] = 0
        ..['is_boosted'] = 1;
      final l = PropertyListing.fromJson(json);
      expect(l.isOnline, isFalse);
      expect(l.isBoosted, isTrue);
    });
  });
}
