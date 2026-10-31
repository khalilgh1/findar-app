import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:findar/core/models/property_listing_model.dart';
import 'package:findar/core/models/return_result.dart';
import 'package:findar/core/repositories/abstract_listing_repo.dart';
import 'package:findar/logic/cubits/home/recent_listings.dart';
import 'package:findar/logic/cubits/my_listings_cubit.dart';
import 'package:findar/logic/cubits/property_details_cubit.dart';
import 'package:findar/logic/cubits/saved_listings_cubit.dart';
import 'package:findar/logic/cubits/search_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/fixtures.dart';

class MockRepo extends Mock implements ListingRepository {}

ReturnResult ok([String m = 'ok']) => ReturnResult(state: true, message: m);
ReturnResult fail(String m) => ReturnResult(state: false, message: m);

TypeMatcher<Map<String, dynamic>> hasState(String s) =>
    isA<Map<String, dynamic>>().having((m) => m['state'], 'state', s);

void main() {
  late MockRepo repo;

  setUp(() {
    repo = MockRepo();
    when(() => repo.getSavedListingIds()).thenAnswer((_) async => {2});
  });

  group('RecentCubit', () {
    void recentReturns(Future<List<PropertyListing>> Function(Invocation) answer) {
      when(() => repo.getRecentListings(
            query: any(named: 'query'),
            listingType: any(named: 'listingType'),
            onUpdate: any(named: 'onUpdate'),
          )).thenAnswer(answer);
    }

    blocTest<RecentCubit, Map<String, dynamic>>(
      'cache then server: loading → done(cached) → done(fresh)',
      build: () {
        recentReturns((inv) async {
          final onUpdate = inv.namedArguments[#onUpdate]
              as OnDataUpdate<List<PropertyListing>>;
          onUpdate([listing(id: 1)]);
          onUpdate([listing(id: 1), listing(id: 2)]);
          return [];
        });
        return RecentCubit(repo);
      },
      act: (c) => c.getRecentListings(),
      expect: () => [
        hasState('loading'),
        hasState('done').having((m) => (m['data'] as List).length, 'n', 1),
        hasState('done')
            .having((m) => (m['data'] as List).length, 'n', 2)
            .having((m) => m['savedIds'], 'savedIds', {2}),
      ],
    );

    blocTest<RecentCubit, Map<String, dynamic>>(
      'server down with no cache → error, and retry is allowed',
      build: () {
        recentReturns((_) async => throw Exception('API error: 503'));
        return RecentCubit(repo);
      },
      act: (c) async {
        await c.getRecentListings();
        await c.getRecentListings(); // not swallowed by the _hasFetched guard
      },
      expect: () => [
        hasState('loading'),
        hasState('error'),
        hasState('loading'),
        hasState('error'),
      ],
    );

    blocTest<RecentCubit, Map<String, dynamic>>(
      'save / unsave update savedIds only on success',
      build: () {
        when(() => repo.saveListing(5)).thenAnswer((_) async => ok());
        when(() => repo.saveListing(6))
            .thenAnswer((_) async => fail('you cant save your posts'));
        when(() => repo.unsaveListing(5)).thenAnswer((_) async => ok());
        return RecentCubit(repo);
      },
      act: (c) async {
        await c.saveListing(5);
        await c.saveListing(6);
        await c.unsaveListing(5);
      },
      expect: () => [
        isA<Map>().having((m) => m['savedIds'], 'savedIds', {5}),
        isA<Map>()
            .having((m) => m['savedIds'], 'savedIds', {5})
            .having((m) => m['message'], 'message', 'you cant save your posts'),
        isA<Map>().having((m) => m['savedIds'], 'savedIds', <int>{}),
      ],
    );
  });

  group('PropertyDetailsCubit', () {
    blocTest<PropertyDetailsCubit, Map<String, dynamic>>(
      'missing listing → notFound',
      build: () {
        when(() => repo.getListingById(3)).thenAnswer((_) async => null);
        return PropertyDetailsCubit(repo);
      },
      act: (c) => c.fetchPropertyDetails(3),
      expect: () => [hasState('loading'), hasState('notFound')],
    );

    blocTest<PropertyDetailsCubit, Map<String, dynamic>>(
      'a slow response for an old id never overwrites the newer listing',
      build: () {
        final slow = Completer<PropertyListing?>();
        when(() => repo.getListingById(1)).thenAnswer((_) => slow.future);
        when(() => repo.getListingById(2))
            .thenAnswer((_) async => listing(id: 2, title: 'second'));
        addTearDown(() => slow.complete(listing(id: 1, title: 'first')));
        return PropertyDetailsCubit(repo);
      },
      act: (c) async {
        unawaited(c.fetchPropertyDetails(1));
        await c.fetchPropertyDetails(2);
      },
      verify: (c) {
        expect(c.state['id'], 2);
        expect((c.state['data'] as Map)['title'], 'second');
      },
    );

    blocTest<PropertyDetailsCubit, Map<String, dynamic>>(
      'retry refetches the listing currently shown (not #1)',
      build: () {
        var calls = 0;
        when(() => repo.getListingById(8)).thenAnswer((_) async {
          if (calls++ == 0) throw Exception('timeout');
          return listing(id: 8);
        });
        return PropertyDetailsCubit(repo);
      },
      act: (c) async {
        await c.fetchPropertyDetails(8);
        await c.retry();
      },
      expect: () => [
        hasState('loading'),
        hasState('error'),
        hasState('loading'),
        hasState('done'),
      ],
      verify: (_) => verifyNever(() => repo.getListingById(1)),
    );

    test('report errors become a failed ReturnResult', () async {
      when(() => repo.reportListing(listingId: 4, reason: 'scam'))
          .thenThrow(Exception('offline'));
      final res =
          await PropertyDetailsCubit(repo).reportListing(propertyId: 4, reason: 'scam');
      expect(res.state, isFalse);
    });
  });

  group('SavedListingsCubit', () {
    blocTest<SavedListingsCubit, Map<String, dynamic>>(
      'unsave removes the row locally',
      build: () {
        when(() => repo.getSavedListings(onUpdate: any(named: 'onUpdate')))
            .thenAnswer((_) async => [listing(id: 1), listing(id: 2)]);
        when(() => repo.unsaveListing(1)).thenAnswer((_) async => ok());
        return SavedListingsCubit(repo);
      },
      act: (c) async {
        await c.fetchSavedListings();
        await c.unsaveListing(1);
      },
      verify: (c) {
        expect((c.state['data'] as List).map((l) => l.id), [2]);
        expect(c.state['count'], 1);
        expect(c.isSaved(1), isFalse);
        expect(c.isSaved(2), isTrue);
      },
    );

    blocTest<SavedListingsCubit, Map<String, dynamic>>(
      'server down with no cache → error',
      build: () {
        when(() => repo.getSavedListings(onUpdate: any(named: 'onUpdate')))
            .thenThrow(Exception('503'));
        return SavedListingsCubit(repo);
      },
      act: (c) => c.fetchSavedListings(),
      expect: () => [hasState('loading'), hasState('error')],
    );
  });

  group('MyListingsCubit', () {
    final mine = {
      'active': [listing(id: 1)],
      'inactive': <PropertyListing>[],
    };

    blocTest<MyListingsCubit, Map<String, dynamic>>(
      'a failed delete keeps the list and reports the message',
      build: () {
        when(() => repo.getUserListings(onUpdate: any(named: 'onUpdate')))
            .thenAnswer((_) async => mine);
        when(() => repo.deleteListing(1))
            .thenAnswer((_) async => fail('dont have permission'));
        return MyListingsCubit(repo);
      },
      act: (c) async {
        await c.fetchMyListings();
        return c.deleteListing(1);
      },
      verify: (c) {
        expect(c.state['state'], 'done');
        expect(c.state['message'], 'dont have permission');
        expect(c.onlineListings.length, 1);
      },
    );

    blocTest<MyListingsCubit, Map<String, dynamic>>(
      'toggle reloads the list from the repository',
      build: () {
        var toggled = false;
        when(() => repo.getUserListings(onUpdate: any(named: 'onUpdate')))
            .thenAnswer((_) async => toggled
                ? {'active': <PropertyListing>[], 'inactive': [listing(id: 1, isOnline: false)]}
                : mine);
        when(() => repo.toggleActiveListing(1)).thenAnswer((_) async {
          toggled = true;
          return ok('Listing status updated');
        });
        return MyListingsCubit(repo);
      },
      act: (c) async {
        await c.fetchMyListings();
        await c.toggleActiveListing(1);
      },
      verify: (c) {
        expect(c.onlineListings, isEmpty);
        expect(c.offlineListings.length, 1);
      },
    );

    blocTest<MyListingsCubit, Map<String, dynamic>>(
      'reset forgets the previous user',
      build: () {
        when(() => repo.getUserListings(onUpdate: any(named: 'onUpdate')))
            .thenAnswer((_) async => mine);
        return MyListingsCubit(repo);
      },
      act: (c) async {
        await c.fetchMyListings();
        c.reset();
      },
      verify: (c) {
        expect(c.state['state'], 'initial');
        expect(c.onlineListings, isEmpty);
      },
    );
  });

  group('SearchCubit', () {
    // Regression: defaults of 2 bedrooms / 1 bathroom silently hid studios
    // and offices from every filtered search.
    test('default filters send no bedroom/bathroom minimum', () async {
      when(() => repo.getFilteredListings(
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
            onUpdate: any(named: 'onUpdate'),
          )).thenAnswer((_) async => []);
      final cubit = SearchCubit(repo);
      expect(cubit.currentFilters['numBedrooms'], 0);
      expect(cubit.currentFilters['numBathrooms'], 0);

      await cubit.getFilteredListings(numBedrooms: 0, numBathrooms: 0);
      verify(() => repo.getFilteredListings(
            numBedrooms: null,
            numBathrooms: null,
            onUpdate: any(named: 'onUpdate'),
          )).called(1);

      await cubit.getFilteredListings(numBedrooms: 3);
      verify(() => repo.getFilteredListings(
            numBedrooms: 3,
            onUpdate: any(named: 'onUpdate'),
          )).called(1);
    });
  });
}
