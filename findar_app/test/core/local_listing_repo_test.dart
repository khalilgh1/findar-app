import 'package:findar/core/repositories/auth_repository.dart' show User;
import 'package:findar/core/repositories/database_listing_repo.dart';
import 'package:findar/core/repositories/local_user_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../helpers/fixtures.dart';

const me = User(
  id: 3, username: 'me', email: 'me@x.com', phone: '0555000000',
  accountType: 'individual', credits: 0,
);

void main() {
  late LocalListingRepository repo;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfiNoIsolate;
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalUserStore().saveUser(me);
    repo = LocalListingRepository();
    await repo.clearAll();
  });

  test('cached listings keep their server id and owner', () async {
    await repo.cacheListings([listing(id: 42, title: 'server row', ownerId: 8)]);

    final l = await repo.getListingById(42);
    expect(l, isNotNull);
    expect(l!.title, 'server row');
    expect(l.ownerId, 8);
    expect(l.ownerName, 'owner_8');
  });

  test('my listings only contain my rows, split by active', () async {
    await repo.cacheListings([listing(id: 1, ownerId: 99)]);
    await repo.cacheUserListings({
      'active': [listing(id: 2, ownerId: 3)],
      'inactive': [listing(id: 3, ownerId: 3, isOnline: false)],
    });

    final mine = await repo.getUserListings();
    expect(mine['active']!.map((l) => l.id), [2]);
    expect(mine['inactive']!.map((l) => l.id), [3]);
  });

  test('re-caching my listings drops ones deleted on the server', () async {
    await repo.cacheUserListings({
      'active': [listing(id: 2), listing(id: 4)],
      'inactive': [],
    });
    await repo.cacheUserListings({'active': [listing(id: 2)], 'inactive': []});

    final mine = await repo.getUserListings();
    expect(mine['active']!.map((l) => l.id), [2]);
    expect(await repo.getListingById(4), isNull);
  });

  test('recent listings hide inactive rows', () async {
    await repo.cacheListings([
      listing(id: 1, ownerId: 9),
      listing(id: 2, ownerId: 9, isOnline: false),
    ]);
    final recent = await repo.getRecentListings();
    expect(recent.map((l) => l.id), [1]);
  });

  test('sponsored = boosted and active', () async {
    await repo.cacheListings([
      listing(id: 1, ownerId: 9, isBoosted: true),
      listing(id: 2, ownerId: 9),
      listing(id: 3, ownerId: 9, isBoosted: true, isOnline: false),
    ]);
    final sponsored = await repo.getSponsoredListings();
    expect(sponsored.map((l) => l.id), [1]);
  });

  test('saved listings come from the saved id set', () async {
    await repo.cacheSavedListings([listing(id: 5, ownerId: 9), listing(id: 6, ownerId: 9)]);
    expect(await repo.getSavedListingIds(), {5, 6});

    await repo.unsaveListing(5);
    final saved = await repo.getSavedListings();
    expect(saved.map((l) => l.id), [6]);
  });

  test('cannot save your own listing offline', () async {
    await repo.cacheListings([listing(id: 7, ownerId: me.id)]);
    final res = await repo.saveListing(7);
    expect(res.state, isFalse);
  });

  test('clearAll forgets listings and saved ids (logout)', () async {
    await repo.cacheSavedListings([listing(id: 5, ownerId: 9)]);
    await repo.clearAll();
    expect(await repo.getSavedListingIds(), isEmpty);
    expect(await repo.getListingById(5), isNull);
    expect(await repo.getRecentListings(), isEmpty);
  });

  test('signed out: no "my listings"', () async {
    await repo.cacheUserListings({'active': [listing(id: 2)], 'inactive': []});
    await LocalUserStore().clearUser();
    final mine = await repo.getUserListings();
    expect(mine['active'], isEmpty);
  });
}
