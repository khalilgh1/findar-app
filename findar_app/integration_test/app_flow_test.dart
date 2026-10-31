// End-to-end flows on a real device/emulator against a local, seeded backend.
//
//   cd findar_backend
//   $env:SQLITE_PATH='e2e.sqlite3'; python manage.py migrate; python manage.py seed_e2e
//   $env:SQLITE_PATH='e2e.sqlite3'; python manage.py runserver 0.0.0.0:8000
//
//   cd findar_app
//   flutter test integration_test -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:8000
//
// Re-run seed_e2e before each run: the flows change server state.
import 'package:findar/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'e2e_config.dart';

/// Pumps frames until [finder] matches. pumpAndSettle can't be used: the
/// shimmer skeletons animate forever while data loads.
Future<void> pumpUntil(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 30),
  String? reason,
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 200));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('Timed out waiting for ${reason ?? finder.describeMatch(Plurality.one)}');
}

Future<void> pumpFor(WidgetTester tester, Duration d) async {
  final end = DateTime.now().add(d);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> tapAndWait(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder.first);
  await tester.pump();
  await tester.tap(finder.first);
  await pumpFor(tester, const Duration(milliseconds: 600));
}

Finder bottomTab(String label) => find.descendant(
      of: find.byType(BottomNavigationBar),
      matching: find.text(label),
    );

Future<void> login(WidgetTester tester, String email) async {
  // Signed-out launches land on the welcome screen first.
  final loginButton = find.widgetWithText(ElevatedButton, 'Login');
  await pumpUntil(
    tester,
    find.byWidgetPredicate((w) =>
        w is Text && (w.data == 'Get Started' || w.data == 'Login')),
    reason: 'welcome or login screen',
  );
  if (find.text('Get Started').evaluate().isNotEmpty) {
    await tapAndWait(tester, find.text('Get Started'));
  }
  await pumpUntil(tester, loginButton, reason: 'login screen');
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), email);
  await tester.enterText(fields.at(1), E2E.password);
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pump();
  await tapAndWait(tester, find.widgetWithText(ElevatedButton, 'Login'));
  await pumpUntil(tester, find.text('Recent Listings'),
      timeout: const Duration(seconds: 45), reason: 'home after login');
}

Future<void> logout(WidgetTester tester) async {
  await tapAndWait(tester, bottomTab('Profile'));
  await pumpUntil(tester, find.text('Logout'), reason: 'profile screen');
  await tapAndWait(tester, find.text('Logout'));
  await pumpUntil(tester, find.widgetWithText(ElevatedButton, 'Login'),
      reason: 'login after logout');
}

Future<void> openFromHome(WidgetTester tester, String title) async {
  final card = find.text(title);
  await pumpUntil(tester, card, reason: '"$title" on home');
  await tester.scrollUntilVisible(card.last, 300,
      scrollable: find.byType(Scrollable).first);
  await tapAndWait(tester, card.last);
  await pumpUntil(tester, find.text('Property Details'));
  await pumpUntil(tester, find.byIcon(Icons.flag_outlined),
      reason: 'details loaded');
}

Future<void> back(WidgetTester tester) async {
  // Some screens use a custom arrow IconButton instead of BackButton.
  if (find.byType(BackButton).evaluate().isNotEmpty) {
    await tester.pageBack();
  } else {
    await tester.tap(find.byIcon(Icons.arrow_back).first);
  }
  await pumpFor(tester, const Duration(milliseconds: 800));
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  setUpAll(() async {
    // Start signed out with an empty cache, whatever the last run left.
    await const FlutterSecureStorage().deleteAll();
    (await SharedPreferences.getInstance()).clear();
    await deleteDatabase(await getDatabasesPath().then((p) => '$p/listings.db'));
  });

  testWidgets('buyer: browse, details, save, saved tab, unsave, logout',
      (tester) async {
    app.main();
    await login(tester, E2E.buyerEmail);

    // Home: sponsored carousel + recent feed from the seeded server.
    for (final t in E2E.boostedTitles) {
      await pumpUntil(tester, find.text(t), reason: 'sponsored "$t"');
    }
    await pumpUntil(tester, find.text(E2E.koubaTitle));

    // Search bar → Search Results (regression: the list used to crash on
    // context.select inside its itemBuilder).
    await tester.enterText(find.byType(TextField).first, 'Oran');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await pumpUntil(tester, find.text('Search Results'));
    await pumpUntil(tester, find.text(E2E.studioTitle),
        reason: 'search result card');
    expect(tester.takeException(), isNull);
    expect(find.text(E2E.koubaTitle), findsNothing);
    await back(tester);
    await tester.enterText(find.byType(TextField).first, '');
    await pumpFor(tester, const Duration(milliseconds: 500));

    // Details of a seeded listing show real data and the owner.
    await openFromHome(tester, E2E.studioTitle);
    expect(find.text(E2E.studioTitle), findsWidgets);
    await pumpUntil(tester, find.textContaining(E2E.sellerName),
        reason: 'owner card');
    expect(find.text('Modern Family Home'), findsNothing,
        reason: 'no fake fallback data');

    // Save from the details app bar.
    await pumpUntil(tester, find.byIcon(Icons.bookmark_border));
    await tapAndWait(tester, find.byIcon(Icons.bookmark_border));
    await pumpUntil(tester, find.byIcon(Icons.bookmark), reason: 'saved icon');
    await back(tester);

    // Saved tab lists it.
    await tapAndWait(tester, bottomTab('Saved'));
    await pumpUntil(tester, find.text(E2E.studioTitle),
        reason: 'listing on saved screen');

    // Unsave from details → saved list is empty.
    await tapAndWait(tester, find.text(E2E.studioTitle));
    await pumpUntil(tester, find.byIcon(Icons.bookmark));
    await tapAndWait(tester, find.byIcon(Icons.bookmark));
    await pumpUntil(tester, find.byIcon(Icons.bookmark_border));
    await back(tester);
    await tapAndWait(tester, bottomTab('Home'));
    await tapAndWait(tester, bottomTab('Saved'));
    await pumpUntil(tester, find.text('No saved properties'),
        reason: 'empty saved list');

    await logout(tester);

    // Seller: my listings, toggle one offline and back online.
    await login(tester, E2E.sellerEmail);
    await tapAndWait(tester, bottomTab('Listings'));
    await pumpUntil(tester, find.text('My Listings'));
    // First card (my_listings is in id order); later cards aren't built
    // until scrolled into view.
    await pumpUntil(tester, find.text(E2E.boostedTitles.first),
        reason: 'seller sees own listing');

    // Make the first listing offline: it moves to the Offline tab.
    await pumpUntil(tester, find.byIcon(Icons.more_vert));
    await tapAndWait(tester, find.byIcon(Icons.more_vert));
    await tapAndWait(tester, find.text('Make Offline'));
    await pumpUntil(tester, find.text('Listing status updated'),
        reason: 'toggle snackbar');
    await tapAndWait(tester, find.text('Offline'));
    await pumpUntil(tester, find.byIcon(Icons.more_vert));
    expect(find.byIcon(Icons.more_vert), findsOneWidget);

    // ...and back online.
    await tapAndWait(tester, find.byIcon(Icons.more_vert));
    await tapAndWait(tester, find.text('Make Online'));
    await pumpFor(tester, const Duration(seconds: 2));
    expect(find.byIcon(Icons.more_vert), findsNothing,
        reason: 'offline tab empty again');

    // The seller didn't inherit the buyer's saved/session state.
    await tapAndWait(tester, bottomTab('Saved'));
    await pumpUntil(tester, find.text('No saved properties'));

    await logout(tester);
  });
}
