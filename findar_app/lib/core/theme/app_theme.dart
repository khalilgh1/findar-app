import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:findar/core/theme/color_schemes.dart';
import 'package:findar/core/theme/findar_tokens.dart';

const String kLatinFont = 'Manrope';
const String kArabicFont = 'IBMPlexSansArabic';

/// Builds the Findar theme. Arabic uses IBM Plex Sans Arabic with Manrope as
/// a fallback for Latin digits and words; every other locale uses Manrope.
ThemeData buildFindarTheme({required bool dark, required String language}) =>
    _themeCache.putIfAbsent(
        '$dark|$language', () => _build(dark: dark, language: language));

final Map<String, ThemeData> _themeCache = {};

ThemeData _build({required bool dark, required String language}) {
  final c = dark ? FindarColors.dark : FindarColors.light;
  final scheme = dark ? darkColorScheme : lightColorScheme;
  final arabic = language == 'ar';
  final family = arabic ? kArabicFont : kLatinFont;
  final fallback = arabic ? const [kLatinFont] : const [kArabicFont];

  TextStyle s(double size, FontWeight w,
          {double em = 0, Color? color, double? h}) =>
      TextStyle(
        fontFamily: family,
        fontFamilyFallback: fallback,
        fontSize: size,
        fontWeight: w,
        letterSpacing: arabic ? 0 : em * size,
        color: color ?? c.ink,
        height: h,
      );

  final text = TextTheme(
    displaySmall: s(29, FontWeight.w800, em: -0.03, h: 1.12), // hero title
    headlineLarge: s(30, FontWeight.w800, em: -0.03, h: 1.15), // screen title
    headlineMedium: s(24, FontWeight.w800, em: -0.02, h: 1.2), // listing title
    headlineSmall: s(19, FontWeight.w800, em: -0.02), // section header
    titleLarge: s(20, FontWeight.w800, em: -0.02), // price / sheet title
    titleMedium: s(17, FontWeight.w800),
    titleSmall: s(15, FontWeight.w700),
    bodyLarge: s(15, FontWeight.w500, h: 1.5),
    bodyMedium: s(14, FontWeight.w500, h: 1.45),
    bodySmall: s(13, FontWeight.w600, color: c.muted),
    labelLarge: s(16, FontWeight.w700),
    labelMedium: s(13, FontWeight.w700),
    labelSmall: s(12, FontWeight.w800, em: 0.06, color: c.muted),
  );

  const pill = WidgetStatePropertyAll<OutlinedBorder>(StadiumBorder());
  final btnText = WidgetStatePropertyAll(s(16, FontWeight.w700));

  OutlineInputBorder border(Color color, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(FSpace.rField),
        borderSide: BorderSide(color: color, width: w),
      );

  return ThemeData(
    useMaterial3: true,
    brightness: dark ? Brightness.dark : Brightness.light,
    colorScheme: scheme,
    scaffoldBackgroundColor: c.bg,
    canvasColor: c.bg,
    fontFamily: family,
    fontFamilyFallback: fallback,
    textTheme: text,
    extensions: [c],
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    }),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      foregroundColor: c.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: s(17, FontWeight.w700, em: -0.01),
      systemOverlayStyle:
          dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: ButtonStyle(
        shape: pill,
        minimumSize: const WidgetStatePropertyAll(Size(64, 52)),
        textStyle: btnText,
        backgroundColor: WidgetStateProperty.resolveWith(
            (st) => st.contains(WidgetState.disabled) ? c.line : c.btn),
        foregroundColor: WidgetStateProperty.resolveWith(
            (st) => st.contains(WidgetState.disabled) ? c.muted : c.btnText),
        padding:
            const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 24)),
        elevation: const WidgetStatePropertyAll(0),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        shape: pill,
        minimumSize: const WidgetStatePropertyAll(Size(64, 52)),
        textStyle: btnText,
        backgroundColor: WidgetStatePropertyAll(c.btn),
        foregroundColor: WidgetStatePropertyAll(c.btnText),
        elevation: const WidgetStatePropertyAll(0),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        shape: pill,
        minimumSize: const WidgetStatePropertyAll(Size(64, 52)),
        textStyle: btnText,
        foregroundColor: WidgetStatePropertyAll(c.ink),
        backgroundColor: WidgetStatePropertyAll(c.bg),
        side: WidgetStatePropertyAll(BorderSide(color: c.line)),
        padding:
            const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 20)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(c.accent),
        textStyle: WidgetStatePropertyAll(s(14, FontWeight.w700)),
        shape: pill,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(c.ink),
        minimumSize: const WidgetStatePropertyAll(Size(44, 44)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surf,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: s(15, FontWeight.w500, color: c.muted),
      labelStyle: s(15, FontWeight.w500, color: c.muted),
      prefixIconColor: c.muted,
      suffixIconColor: c.muted,
      border: border(c.surf),
      enabledBorder: border(c.surf),
      focusedBorder: border(c.accent, 1.5),
      errorBorder: border(c.red),
      focusedErrorBorder: border(c.red, 1.5),
      errorStyle: s(12, FontWeight.w600, color: c.red),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: c.accent,
      selectionColor: c.accent.withValues(alpha: 0.25),
      selectionHandleColor: c.accent,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: c.bg,
      selectedColor: c.btn,
      side: BorderSide(color: c.line),
      shape: const StadiumBorder(),
      labelStyle: s(14, FontWeight.w600),
      secondaryLabelStyle: s(14, FontWeight.w600, color: c.btnText),
      showCheckmark: false,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.bg,
      surfaceTintColor: Colors.transparent,
      modalBackgroundColor: c.bg,
      modalBarrierColor: c.scrim,
      showDragHandle: true,
      dragHandleColor: c.line,
      dragHandleSize: const Size(40, 4),
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(FSpace.rSheet)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: c.bg,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titleTextStyle: s(19, FontWeight.w800),
      contentTextStyle: s(15, FontWeight.w500, color: c.muted, h: 1.5),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: c.bg,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shadowColor: const Color(0x2E111317),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: c.line),
      ),
      textStyle: s(15, FontWeight.w700),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF111317),
      contentTextStyle: s(14, FontWeight.w700, color: Colors.white),
      actionTextColor: const Color(0xFF8EBBF5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: const WidgetStatePropertyAll(Colors.white),
      trackColor: WidgetStateProperty.resolveWith(
          (st) => st.contains(WidgetState.selected) ? c.accent : c.line),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith(
          (st) => st.contains(WidgetState.selected) ? c.accent : c.line),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
          (st) => st.contains(WidgetState.selected) ? c.accent : null),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: c.accent,
      inactiveTrackColor: c.line,
      thumbColor: Colors.white,
      overlayColor: c.accent.withValues(alpha: 0.12),
      trackHeight: 4,
      rangeThumbShape: const RoundRangeSliderThumbShape(
          enabledThumbRadius: 13, elevation: 2),
      rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
      showValueIndicator: ShowValueIndicator.never,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: c.accent,
      linearTrackColor: c.line,
      circularTrackColor: Colors.transparent,
    ),
    dividerTheme: DividerThemeData(color: c.line, thickness: 1, space: 1),
    listTileTheme: ListTileThemeData(
      iconColor: c.ink,
      textColor: c.ink,
      titleTextStyle: s(15, FontWeight.w700),
      subtitleTextStyle: s(13, FontWeight.w500, color: c.muted),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: c.ink,
      unselectedLabelColor: c.muted,
      indicatorColor: c.accent,
      dividerColor: Colors.transparent,
      labelStyle: s(14, FontWeight.w700),
    ),
  );
}
