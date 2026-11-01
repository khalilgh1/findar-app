import 'package:flutter/material.dart';

import 'package:findar/core/models/return_result.dart';
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
  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();
  messenger.showSnackBar(SnackBar(
    content: Text(
        offline ? AppLocalizations.of(context)!.actionNeedsInternet : message),
  ));
}

/// Saves or unsaves through [save]/[unsave] and reports the outcome:
/// success shows "Saved to your list" / "Removed from saved" with Undo,
/// failure shows the reason. Returns whether the change succeeded.
Future<bool> toggleSaveWithUndo(
  BuildContext context, {
  required bool save,
  required Future<ReturnResult> Function() doSave,
  required Future<ReturnResult> Function() doUnsave,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final messenger = ScaffoldMessenger.of(context);
  final result = save ? await doSave() : await doUnsave();
  if (!context.mounted) return result.state;
  if (!result.state) {
    showSaveFailure(context, result.message);
    return false;
  }
  messenger.clearSnackBars();
  messenger.showSnackBar(SnackBar(
    content: Text(save ? l10n.savedToList : l10n.removedFromSaved),
    duration: const Duration(seconds: 3),
    // An action would otherwise keep it up until dismissed.
    persist: false,
    action: SnackBarAction(
      label: l10n.undo,
      onPressed: () => save ? doUnsave() : doSave(),
    ),
  ));
  return true;
}
