import 'package:flutter/material.dart';
import 'package:findar/l10n/app_localizations.dart';
import 'package:findar/l10n/app_localizations_en.dart';

/// Safe helper to get AppLocalizations from context
/// Returns null if context is invalid or l10n is not available
AppLocalizations? safeGetL10n(BuildContext context) {
  try {
    return AppLocalizations.of(context);
  } catch (e) {
    debugPrint('Warning: Could not get l10n from context: $e');
    return null;
  }
}

/// Safe helper that returns l10n or a default English instance
/// This prevents crashes when context is invalid during navigation
AppLocalizations getL10nOrDefault(BuildContext context) {
  try {
    var l10n = AppLocalizations.of(context);
    if (l10n != null) {
      return l10n;
    }
  } catch (e) {
    debugPrint('Warning: Could not get l10n from context, using defaults: $e');
  }
  
  // Return a default English instance if context is invalid
  return AppLocalizationsEn();
}
