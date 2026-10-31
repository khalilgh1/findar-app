import 'package:findar/core/exceptions/network_exception.dart';
import 'package:findar/core/models/property_listing_model.dart';
import 'package:findar/core/models/return_result.dart';
import 'package:findar/core/repositories/composite_listing_repo.dart';
import 'package:findar/core/repositories/database_listing_repo.dart';
import 'package:findar/core/repositories/remote_listing_repo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/fixtures.dart';

class MockLocal extends Mock implements LocalListingRepository {}

class MockRemote extends Mock implements RemoteListingRepository {}

class MockConnection extends Mock implements InternetConnection {}

void main() {
  late MockLocal local;
  late MockRemote remote;
  late MockConnection connection;
  late CompositeListingRepository repo;

  void online(bool value) =>
      when(() => connection.hasInternetAccess).thenAnswer((_) async => value);

  setUp(() {
    local = MockLocal();
    remote = MockRemote();
    connection = MockConnection();
    repo = CompositeListingRepository(local, remote, connection);
    when(() => local.cacheListings(any())).thenAnswer((_) async {});
    when(() => local.cacheSavedListings(any())).thenAnswer((_) async {});
    when(() => local.cacheUserListings(any())).thenAnswer((_) async {});
  });

  group('offline-first reads', () {
    test('emits cache, then server data, and caches the server data', () async {
      online(true);
      final cached = [listing(id: 1, title: 'cached')];
      final fresh = [listing(id: 2, title: 'fresh')];
      when(() => local.getRecentListings(
          query: any(named: 'query'),
          listingType: any(named: 'listingType'))).thenAnswer((_) async => cached);
      when(() => remote.getRecentListings(
          query: any(named: 'query'),
          listingType: any(named: 'listingType'))).thenAnswer((_) async => fresh);

      final updates = <List<PropertyListing>>[];
      await repo.getRecentListings(onUpdate: updates.add);

      expect(updates.map((u) => u.single.title), ['cached', 'fresh']);
      verify(() => local.cacheListings(fresh)).called(1);
    });

    test('offline with an empty cache still reports an (empty) result', () async {
      online(false);
      when(() => local.getSavedListings()).thenAnswer((_) async => []);

      final updates = <List<PropertyListing>>[];
      await repo.getSavedListings(onUpdate: updates.add);

      expect(updates, [isEmpty]);
      verifyNever(() => remote.getSavedListings());
    });

    test('server failure with a cache keeps showing the cache', () async {
      online(true);
      final cached = [listing(id: 1)];
      when(() => local.getSponsoredListings()).thenAnswer((_) async => cached);
      when(() => remote.getSponsoredListings())
          .thenThrow(Exception('API error: 503'));

      final updates = <List<PropertyListing>>[];
      final result = await repo.getSponsoredListings(onUpdate: updates.add);

      expect(updates, [cached]);
      expect(result, cached);
    });

    // Regression: a fresh install while the server was down left the home
    // feed spinning forever (no onUpdate, no error).
    test('server failure with nothing cached surfaces the error', () async {
      online(true);
      when(() => local.getRecentListings(
          query: any(named: 'query'),
          listingType: any(named: 'listingType'))).thenAnswer((_) async => []);
      when(() => remote.getRecentListings(
              query: any(named: 'query'), listingType: any(named: 'listingType')))
          .thenThrow(Exception('API error: 503'));
      when(() => local.getSponsoredListings()).thenAnswer((_) async => []);
      when(() => remote.getSponsoredListings()).thenThrow(Exception('503'));
      when(() => local.getSavedListings()).thenAnswer((_) async => []);
      when(() => remote.getSavedListings()).thenThrow(Exception('503'));
      when(() => local.getUserListings())
          .thenAnswer((_) async => {'active': [], 'inactive': []});
      when(() => remote.getUserListings()).thenThrow(Exception('503'));

      await expectLater(repo.getRecentListings(onUpdate: (_) {}), throwsException);
      await expectLater(repo.getSponsoredListings(onUpdate: (_) {}), throwsException);
      await expectLater(repo.getSavedListings(onUpdate: (_) {}), throwsException);
      await expectLater(repo.getUserListings(onUpdate: (_) {}), throwsException);
    });
  });

  group('writes need a connection', () {
    setUp(() => online(false));

    test('create / delete / save / report throw NetworkException offline',
        () async {
      await expectLater(
        repo.createListing(
          title: 't', description: 'd', price: 1, location: '', bedrooms: 1,
          bathrooms: 1, classification: 'rent', propertyType: 'house', image: '',
        ),
        throwsA(isA<NetworkException>()),
      );
      await expectLater(repo.deleteListing(1), throwsA(isA<NetworkException>()));
      await expectLater(repo.saveListing(1), throwsA(isA<NetworkException>()));
      await expectLater(
        repo.reportListing(listingId: 1, reason: 'x'),
        throwsA(isA<NetworkException>()),
      );
      verifyZeroInteractions(remote);
    });
  });

  group('cache follows successful writes only', () {
    setUp(() => online(true));

    test('save', () async {
      when(() => remote.saveListing(5))
          .thenAnswer((_) async => ReturnResult(state: true, message: 'ok'));
      when(() => local.saveListing(5))
          .thenAnswer((_) async => ReturnResult(state: true, message: 'ok'));
      await repo.saveListing(5);
      verify(() => local.saveListing(5)).called(1);
    });

    test('failed delete leaves the cache alone', () async {
      when(() => remote.deleteListing(5)).thenAnswer(
          (_) async => ReturnResult(state: false, message: 'dont have permission'));
      final res = await repo.deleteListing(5);
      expect(res.state, isFalse);
      verifyNever(() => local.deleteListing(any()));
    });
  });

  group('search filters', () {
    setUp(() {
      online(true);
      when(() => remote.getFilteredListings(
            latitude: any(named: 'latitude'),
            longitude: any(named: 'longitude'),
            minPrice: any(named: 'minPrice'),
            maxPrice: any(named: 'maxPrice'),
            listingType: any(named: 'listingType'),
            buildingType: any(named: 'buildingType'),
            numBedrooms: any(named: 'numBedrooms'),
            numBathrooms: any(named: 'numBathrooms'),
            minSqft: any(named: 'minSqft'),
            maxSqft: any(named: 'maxSqft'),
            listedBy: any(named: 'listedBy'),
            sortBy: any(named: 'sortBy'),
          )).thenAnswer((_) async => []);
    });

    test('UI labels are mapped to backend values', () async {
      await repo.getFilteredListings(
        listingType: 'For Rent',
        listedBy: 'Real Estate Agent',
        buildingType: 'Villa',
      );
      verify(() => remote.getFilteredListings(
            listingType: 'rent',
            listedBy: 'agency',
            buildingType: 'villa',
          )).called(1);
    });

    test('"Any" filters become no filter', () async {
      await repo.getFilteredListings(listingType: 'Any', listedBy: 'Any');
      verify(() => remote.getFilteredListings(
            listingType: null,
            listedBy: null,
          )).called(1);
    });
  });

  test('details offline without a cached copy throws NetworkException', () async {
    online(false);
    when(() => local.getListingById(9)).thenAnswer((_) async => null);
    await expectLater(repo.getListingById(9), throwsA(isA<NetworkException>()));
  });
}
