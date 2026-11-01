import 'package:flutter/material.dart';

import 'package:findar/core/theme/findar_tokens.dart';

/// Material colour schemes mapped from the Findar tokens.
/// primary = ink (the primary button fill), secondary = Findar blue.
ColorScheme _scheme(FindarColors c, Brightness b) => ColorScheme(
      brightness: b,
      primary: c.btn,
      onPrimary: c.btnText,
      primaryContainer: c.accentT,
      onPrimaryContainer: c.accent,
      secondary: c.accent,
      onSecondary: c.isDark ? const Color(0xFF111317) : Colors.white,
      secondaryContainer: c.accentT,
      onSecondaryContainer: c.accent,
      tertiary: c.green,
      onTertiary: c.isDark ? const Color(0xFF111317) : Colors.white,
      tertiaryContainer: c.greenT,
      onTertiaryContainer: c.green,
      error: c.red,
      onError: c.isDark ? const Color(0xFF111317) : Colors.white,
      errorContainer: c.redT,
      onErrorContainer: c.red,
      surface: c.bg,
      onSurface: c.ink,
      surfaceContainerLowest: c.bg,
      surfaceContainerLow: c.bg,
      surfaceContainer: c.surf,
      surfaceContainerHigh: c.surf,
      surfaceContainerHighest: c.surf,
      onSurfaceVariant: c.muted,
      outline: c.line,
      outlineVariant: c.line,
      shadow: const Color(0xFF111317),
      scrim: c.scrim,
      inverseSurface: const Color(0xFF111317),
      onInverseSurface: Colors.white,
      inversePrimary: const Color(0xFF8EBBF5),
      surfaceTint: Colors.transparent,
    );

final lightColorScheme = _scheme(FindarColors.light, Brightness.light);
final darkColorScheme = _scheme(FindarColors.dark, Brightness.dark);
