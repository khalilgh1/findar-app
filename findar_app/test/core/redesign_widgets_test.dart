import 'dart:async';

import 'package:findar/core/theme/app_theme.dart';
import 'package:findar/core/widgets/f_icon.dart';
import 'package:findar/core/widgets/listing_widgets.dart';
import 'package:findar/core/widgets/ui.dart';
import 'package:findar/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child, {String lang = 'en'}) => MaterialApp(
      locale: Locale(lang),
      theme: buildFindarTheme(dark: false, language: lang),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: Center(child: child)),
    );

String _plain(WidgetTester t) => t
    .widgetList<RichText>(find.byType(RichText))
    .map((r) => r.text.toPlainText())
    .join('|');

void main() {
  group('groupDigits', () {
    test('groups thousands with a narrow no-break space', () {
      expect(groupDigits(52000000), '52 000 000');
      expect(groupDigits(30000.0), '30 000');
      expect(groupDigits(999), '999');
      expect(groupDigits(1000), '1 000');
    });
  });

  testWidgets('PriceText: one format, rent adds "/ month"', (t) async {
    await t.pumpWidget(_app(const Column(children: [
      PriceText(price: 52000000),
      PriceText(price: 65000, rent: true),
    ])));
    final text = _plain(t);
    expect(text, contains('52 000 000 DA'));
    expect(text, contains('65 000 DA / month'));
    expect(text, isNot(contains('DZD')));
  });

  testWidgets('PriceText in Arabic uses دج and / شهر', (t) async {
    await t.pumpWidget(
        _app(const PriceText(price: 30000, rent: true), lang: 'ar'));
    final text = _plain(t);
    expect(text, contains('دج'));
    expect(text, contains('/ شهر'));
  });

  testWidgets('SaveButton flips at once and reverts when the save fails',
      (t) async {
    var calls = 0;
    final result = Completer<bool>();
    await t.pumpWidget(_app(SaveButton(
      saved: false,
      onToggle: (save) {
        calls++;
        return result.future;
      },
    )));
    final button = find.byType(SaveButton);
    bool filled() => t
        .widget<FIcon>(
            find.descendant(of: button, matching: find.byType(FIcon)))
        .filled;
    expect(filled(), isFalse);

    await t.tap(button);
    await t.pump(); // optimistic flip, before the save resolves
    expect(filled(), isTrue);
    result.complete(false); // e.g. offline
    await t.pumpAndSettle(); // failure -> revert
    expect(calls, 1);
    expect(filled(), isFalse);
  });

  testWidgets('PasswordRules tick as the password meets each rule', (t) async {
    final c = TextEditingController();
    await t.pumpWidget(_app(PasswordRules(controller: c)));
    RuleChip chip(String label) => t.widget<RuleChip>(
        find.ancestor(of: find.text(label), matching: find.byType(RuleChip)));

    expect(chip('8+ characters').ok, isFalse);
    c.text = 'Abcdefg1';
    await t.pumpAndSettle();
    expect(chip('8+ characters').ok, isTrue);
    expect(chip('Uppercase').ok, isTrue);
    expect(chip('Lowercase').ok, isTrue);
    expect(chip('Number').ok, isTrue);
  });

  testWidgets('PillSegmented reports the tapped value', (t) async {
    String? picked;
    await t.pumpWidget(_app(SizedBox(
      width: 300,
      child: PillSegmented<String>(
        values: const ['a', 'b'],
        labels: const ['Alpha', 'Beta'],
        selected: 'a',
        onChanged: (v) => picked = v,
      ),
    )));
    await t.tap(find.text('Beta'));
    expect(picked, 'b');
  });
}
