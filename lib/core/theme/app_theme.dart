import 'package:flutter/material.dart';
import 'color_schemes.dart';
import 'text_styles.dart';

ThemeData lightTheme = ThemeData(
  colorScheme: lightColorScheme,
  textTheme: const TextTheme(
    headlineLarge: AppTextStyles.heading1,
    headlineMedium: AppTextStyles.heading2,
    headlineSmall: AppTextStyles.heading3,
    bodyMedium: AppTextStyles.body,
  ),
);

ThemeData darkTheme = ThemeData(
  colorScheme: darkColorScheme,
  textTheme: TextTheme(
    headlineLarge:
        AppTextStyles.heading1.copyWith(color: darkColorScheme.onSurface),
    headlineMedium:
        AppTextStyles.heading2.copyWith(color: darkColorScheme.onSurface),
    headlineSmall:
        AppTextStyles.heading3.copyWith(color: darkColorScheme.onSurface),
    bodyMedium: AppTextStyles.body.copyWith(color: darkColorScheme.onSurface),
  ),
);
