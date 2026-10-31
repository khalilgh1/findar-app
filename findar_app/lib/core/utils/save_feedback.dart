import 'package:flutter/material.dart';

import 'package:findar/l10n/app_localizations.dart';

/// Shows why a save/unsave failed (offline, own listing, server error).
/// These failures used to be printed only, so the bookmark silently did
/// nothing.
void showSaveFailure(BuildContext context, String message) {
  if (!context.mounted) return;
  final lower = message.toLowerCase();
  final offline = lower.contains('offline') ||
      lower.contains('internet') ||
      lower.contains('cannot reach server');
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content:
        Text(offline ? AppLocalizations.of(context)!.actionNeedsInternet : message),
  ));
}
