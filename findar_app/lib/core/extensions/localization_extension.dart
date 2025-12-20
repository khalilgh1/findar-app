import 'package:flutter/material.dart';
import 'package:findar/l10n/app_localizations.dart';
import 'package:findar/l10n/app_localizations_en.dart';

/// Extension on BuildContext to safely access localization strings
extension LocalizationExtension on BuildContext {
  /// Get AppLocalizations from context without caching
  /// Returns a default English instance if not available
  /// This avoids late initialization errors during widget tree transitions
  AppLocalizations get l10n {
    try {
      var l10nInstance = AppLocalizations.of(this);
      if (l10nInstance != null) {
        return l10nInstance;
      }
    } catch (e) {
      debugPrint('Warning: Could not get l10n from context: $e');
    }
    
    // Return a new English instance each time if context access fails
    // This avoids late initialization errors
    return AppLocalizationsEn();
  }

  /// Safely get localization, checking if context is still valid
  /// Returns null if unable to access
  AppLocalizations? get l10nSafe {
    try {
      return AppLocalizations.of(this);
    } catch (e) {
      debugPrint('Warning: Could not safely get l10n: $e');
      return null;
    }
  }
}
