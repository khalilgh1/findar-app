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
import 'package:findar/core/widgets/f_icon.dart';
import 'package:findar/core/widgets/floating_tab_bar.dart';
import 'package:findar/core/widgets/listing_widgets.dart';
import 'package:findar/core/widgets/ui.dart';
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
  fail(
      'Timed out waiting for ${reason ?? finder.describeMatch(Plurality.one)}');
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
      of: find.byType(FloatingTabBar),
      matching: find.text(label),
    );

Finder circleButton(String label) =>
    find.byWidgetPredicate((w) => w is CircleIconButton && w.label == label);

/// The "⋯" menus on My listings cards (PopupMenuButton tooltips).
Finder listingMenus() => find.byWidgetPredicate(
    (w) => w is Tooltip && (w.message ?? '').startsWith('Actions for'));

Future<void> login(WidgetTester tester, String email) async {
  // Signed-out launches show the splash, then Welcome.
  await pumpUntil(
    tester,
    find.byWidgetPredicate((w) =>
        w.key == const Key('welcome-login') ||
        w.key == const Key('login-submit')),
    reason: 'welcome or login screen',
  );
  // Let the splash -> welcome cross-fade and the sheet entrance finish.
  await pumpFor(tester, const Duration(milliseconds: 900));
  if (find.byKey(const Key('welcome-login')).evaluate().isNotEmpty) {
    await tapAndWait(tester, find.byKey(const Key('welcome-login')));
  }
  await pumpUntil(tester, find.byKey(const Key('login-submit')),
      reason: 'login screen');
  await tester.enterText(
      find.descendant(
          of: find.byKey(const Key('login-email')),
          matching: find.byType(EditableText)),
      email);
  await tester.enterText(
      find.descendant(
          of: find.byKey(const Key('login-password')),
          matching: find.byType(EditableText)),
      E2E.password);
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await pumpUntil(tester, find.text('Find your next place'),
      timeout: const Duration(seconds: 45), reason: 'home after login');
}

Future<void> logout(WidgetTester tester) async {
  await tapAndWait(tester, bottomTab('Profile'));
  await pumpUntil(tester, circleButton('Settings'), reason: 'profile screen');
  await tapAndWait(tester, circleButton('Settings'));
  await pumpUntil(tester, find.text('Log out'), reason: 'settings');
  await tapAndWait(tester, find.text('Log out'));
  // Confirm dialog: the second "Log out" is its action.
  await tapAndWait(tester, find.text('Log out').last);
  await pumpUntil(tester, find.byKey(const Key('login-submit')),
      reason: 'login after logout');
}

Future<void> openFromHome(WidgetTester tester, String title) async {
  final card = find.text(title);
  // Home builds its rows lazily: scroll until the card exists.
  await tester.scrollUntilVisible(card, 300,
      scrollable: find.byType(Scrollable).first, maxScrolls: 80);
  // Lift it clear of the floating tab bar.
  await tester.drag(find.byType(Scrollable).first, const Offset(0, -250));
  await pumpFor(tester, const Duration(milliseconds: 500));
  await tapAndWait(tester, card.last);
  await pumpUntil(tester, find.byType(StatTile), reason: 'details loaded');
}

bool detailsSaved(WidgetTester tester) => tester
    .widget<FIcon>(find.descendant(
        of: find.byType(SaveButton).first, matching: find.byType(FIcon)))
    .filled;

Future<void> back(WidgetTester tester) async {
  await tester.tap(circleButton('Back').first);
  await pumpFor(tester, const Duration(milliseconds: 800));
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  setUpAll(() async {
    // Start signed out with an empty cache, whatever the last run left.
    await const FlutterSecureStorage().deleteAll();
    (await SharedPreferences.getInstance()).clear();
    await deleteDatabase(
        await getDatabasesPath().then((p) => '$p/listings.db'));
  });

  testWidgets('buyer: browse, details, save, saved tab, unsave, logout',
      (tester) async {
    app.main();
    await login(tester, E2E.buyerEmail);

    // Home: sponsored carousel + recent feed from the seeded server.
    // Both sections sit below the hero, so scroll them into view (the
    // slivers build lazily).
    final page = find.byType(Scrollable).first;
    await pumpFor(tester, const Duration(seconds: 3)); // feeds load
    await tester.scrollUntilVisible(find.text('Sponsored'), 300,
        scrollable: page);
    for (final t in E2E.boostedTitles) {
      await pumpUntil(tester, find.text(t), reason: 'sponsored "$t"');
    }
    await tester.scrollUntilVisible(find.text(E2E.koubaTitle), 300,
        scrollable: page);
    await tester.fling(page, const Offset(0, 4000), 3000);
    await pumpFor(tester, const Duration(milliseconds: 400));

    // Search pill → search screen (regression: the results list used to
    // crash on context.select inside its itemBuilder).
    await tapAndWait(tester, find.text('Search city or district'));
    await pumpUntil(tester, find.byType(TextField));
    await tester.enterText(find.byType(TextField).first, 'Oran');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await pumpUntil(tester, find.text(E2E.studioTitle),
        reason: 'search result card');
    expect(tester.takeException(), isNull);
    expect(find.text(E2E.koubaTitle), findsNothing);
    await back(tester);

    // Details of a seeded listing show real data and the owner.
    await openFromHome(tester, E2E.studioTitle);
    expect(find.text(E2E.studioTitle), findsWidgets);
    await pumpUntil(tester, find.textContaining(E2E.sellerName),
        reason: 'owner card');
    expect(find.text('Modern Family Home'), findsNothing,
        reason: 'no fake fallback data');

    // Save from the details photo header.
    expect(detailsSaved(tester), isFalse);
    await tapAndWait(tester, find.byType(SaveButton).first);
    await pumpUntil(tester, find.text('Saved to your list'),
        reason: 'saved snackbar');
    expect(detailsSaved(tester), isTrue);
    await back(tester);

    // Saved tab lists it.
    await tapAndWait(tester, bottomTab('Saved'));
    await pumpUntil(tester, find.text(E2E.studioTitle),
        reason: 'listing on saved screen');

    // Unsave from details → saved list is empty.
    await tapAndWait(tester, find.text(E2E.studioTitle));
    await pumpUntil(tester, find.byType(StatTile));
    await tapAndWait(tester, find.byType(SaveButton).first);
    await pumpUntil(tester, find.text('Removed from saved'));
    await back(tester);
    await tapAndWait(tester, bottomTab('Home'));
    await tapAndWait(tester, bottomTab('Saved'));
    await pumpUntil(tester, find.text('No saved properties yet'),
        reason: 'empty saved list');

    await logout(tester);

    // Seller: my listings, toggle one offline and back online.
    await login(tester, E2E.sellerEmail);
    await tapAndWait(tester, bottomTab('My listings'));
    // First card (my_listings is in id order); later cards aren't built
    // until scrolled into view.
    await pumpUntil(tester, find.text(E2E.boostedTitles.first),
        reason: 'seller sees own listing');

    // Make the first listing offline: it moves to the Offline tab.
    await pumpUntil(tester, listingMenus());
    await tapAndWait(tester, listingMenus());
    await tapAndWait(tester, find.text('Make offline'));
    await pumpUntil(tester, find.text('Listing status updated'),
        reason: 'toggle snackbar');
    await tapAndWait(tester, find.textContaining('Offline ·'));
    await pumpUntil(tester, listingMenus());
    expect(listingMenus(), findsOneWidget);

    // ...and back online.
    await tapAndWait(tester, listingMenus());
    await tapAndWait(tester, find.text('Make online'));
    await pumpFor(tester, const Duration(seconds: 2));
    expect(listingMenus(), findsNothing, reason: 'offline tab empty again');

    // The seller didn't inherit the buyer's saved/session state.
    await tapAndWait(tester, bottomTab('Saved'));
    await pumpUntil(tester, find.text('No saved properties yet'));

    await logout(tester);
  });
}
