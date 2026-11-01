import 'package:flutter/material.dart';

/// Findar design tokens (docs/design/README.md §1) that Material's
/// [ColorScheme] has no slot for. Read them with `context.fc`.
@immutable
class FindarColors extends ThemeExtension<FindarColors> {
  const FindarColors({
    required this.bg,
    required this.surf,
    required this.line,
    required this.ink,
    required this.muted,
    required this.accent,
    required this.accentT,
    required this.btn,
    required this.btnText,
    required this.amber,
    required this.green,
    required this.greenT,
    required this.red,
    required this.redT,
    required this.scrim,
    required this.tabGlass,
    required this.isDark,
  });

  final Color bg;
  final Color surf;
  final Color line;
  final Color ink;
  final Color muted;
  final Color accent;
  final Color accentT;
  final Color btn;
  final Color btnText;
  final Color amber;
  final Color green;
  final Color greenT;
  final Color red;
  final Color redT;
  final Color scrim;
  final Color tabGlass;
  final bool isDark;

  /// Ink used on top of amber (boosted badge) in both themes.
  static const Color onAmber = Color(0xFF111317);

  /// The Findar blue used for fixed brand surfaces (waves, Post button).
  static const Color brandBlue = Color(0xFF0A5FC2);

  /// Brand gradient: hero cards, icon tile, Post button, selected plan tile.
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment(-0.77, -1),
    end: Alignment(0.77, 1),
    colors: [Color(0xFF1C74DB), Color(0xFF0A5FC2), Color(0xFF0B3A80)],
    stops: [0, 0.4, 1],
  );

  /// Lighter gradient for the floating Post button.
  static const LinearGradient postGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2F86E8), Color(0xFF0A5FC2)],
  );

  /// Dark promo cards ("List your property", "Boost a listing").
  static const LinearGradient promoGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF222938), Color(0xFF111317)],
  );

  static const light = FindarColors(
    bg: Color(0xFFFFFFFF),
    surf: Color(0xFFF3F4F6),
    line: Color(0xFFE4E6EA),
    ink: Color(0xFF111317),
    muted: Color(0xFF5B6170),
    accent: Color(0xFF0A5FC2),
    accentT: Color(0xFFE7EFFA),
    btn: Color(0xFF111317),
    btnText: Color(0xFFFFFFFF),
    amber: Color(0xFFF5B341),
    green: Color(0xFF11734A),
    greenT: Color(0xFFE3F3EA),
    red: Color(0xFFB42318),
    redT: Color(0xFFFDECEA),
    scrim: Color(0x80111317),
    tabGlass: Color(0xF0FFFFFF),
    isDark: false,
  );

  static const dark = FindarColors(
    bg: Color(0xFF0E1014),
    surf: Color(0xFF1B1E24),
    line: Color(0xFF2B2F37),
    ink: Color(0xFFF2F3F5),
    muted: Color(0xFFA3A9B5),
    accent: Color(0xFF6AA6F0),
    accentT: Color(0xFF16263B),
    btn: Color(0xFFF2F3F5),
    btnText: Color(0xFF111317),
    amber: Color(0xFFF5B341),
    green: Color(0xFF5CC78F),
    greenT: Color(0xFF14281E),
    red: Color(0xFFF28B82),
    redT: Color(0xFF3A1A18),
    scrim: Color(0x99000000),
    tabGlass: Color(0xF01B1E24),
    isDark: true,
  );

  @override
  FindarColors copyWith() => this;

  @override
  FindarColors lerp(ThemeExtension<FindarColors>? other, double t) {
    if (other is! FindarColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return FindarColors(
      bg: l(bg, other.bg),
      surf: l(surf, other.surf),
      line: l(line, other.line),
      ink: l(ink, other.ink),
      muted: l(muted, other.muted),
      accent: l(accent, other.accent),
      accentT: l(accentT, other.accentT),
      btn: l(btn, other.btn),
      btnText: l(btnText, other.btnText),
      amber: l(amber, other.amber),
      green: l(green, other.green),
      greenT: l(greenT, other.greenT),
      red: l(red, other.red),
      redT: l(redT, other.redT),
      scrim: l(scrim, other.scrim),
      tabGlass: l(tabGlass, other.tabGlass),
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}

extension FindarThemeX on BuildContext {
  FindarColors get fc =>
      Theme.of(this).extension<FindarColors>() ?? FindarColors.light;
  TextTheme get tt => Theme.of(this).textTheme;
}

/// Spacing and radius constants (4-pt grid).
abstract final class FSpace {
  static const double screen = 20;
  static const double section = 22;
  static const double rPill = 999;
  static const double rCard = 20;
  static const double rHero = 28;
  static const double rField = 16;
  static const double rThumb = 14;
  static const double rSheet = 28;
}
