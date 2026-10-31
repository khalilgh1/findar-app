import 'package:findar/core/utils/save_feedback.dart';
import 'package:findar/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> show(WidgetTester tester, String message, {Locale? locale}) async {
  await tester.pumpWidget(MaterialApp(
    locale: locale ?? const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Builder(
        builder: (context) => TextButton(
          onPressed: () => showSaveFailure(context, message),
          child: const Text('go'),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('go'));
  await tester.pump();
}

void main() {
  testWidgets('offline failures show the localized offline message',
      (tester) async {
    await show(tester,
        'Failed to save listing: NetworkException: Save listing is not available in offline mode');
    expect(find.text("You're offline. Connect to the internet and try again."),
        findsOneWidget);
  });

  testWidgets('other failures show the server message', (tester) async {
    await show(tester, 'you cant save your posts');
    expect(find.text('you cant save your posts'), findsOneWidget);
  });

  testWidgets('Arabic', (tester) async {
    await show(tester, 'Cannot reach server (x)', locale: const Locale('ar'));
    expect(find.textContaining('غير متصل'), findsOneWidget);
  });
}
