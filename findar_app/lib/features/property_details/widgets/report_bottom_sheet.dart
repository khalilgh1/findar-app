import 'package:flutter/material.dart';

import 'package:findar/core/models/return_result.dart';
import 'package:findar/core/motion/motion.dart';
import 'package:findar/core/theme/findar_tokens.dart';
import 'package:findar/core/widgets/f_icon.dart';
import 'package:findar/core/widgets/ui.dart';
import 'package:findar/l10n/app_localizations.dart';

/// Report reasons. [apiLabel] is what moderators read (English, stable).
enum ReportReason {
  fraud('Fraudulent listing'),
  inaccurate('Inaccurate information'),
  inappropriate('Inappropriate content'),
  unavailable('No longer available');

  const ReportReason(this.apiLabel);
  final String apiLabel;

  String label(AppLocalizations l10n) => switch (this) {
        ReportReason.fraud => l10n.fraudulentListing,
        ReportReason.inaccurate => l10n.inaccurateInformation,
        ReportReason.inappropriate => l10n.inappropriateContent,
        ReportReason.unavailable => l10n.propertyNotAvailable,
      };
}

class ReportBottomSheet extends StatefulWidget {
  const ReportBottomSheet({super.key, required this.onSubmit});

  /// Receives "Reason" or "Reason: details".
  final Future<ReturnResult> Function(String reason) onSubmit;

  @override
  State<ReportBottomSheet> createState() => _ReportBottomSheetState();
}

class _ReportBottomSheetState extends State<ReportBottomSheet> {
  final _details = TextEditingController();
  ReportReason? _reason;
  bool _sending = false;
  int _shake = 0;
  String? _error;

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final details = _details.text.trim();
    if (_reason == null && details.isEmpty) {
      setState(() {
        _error = l10n.pleaseSelectOrDescribe;
        _shake++;
      });
      return;
    }
    final text = [
      if (_reason != null) _reason!.apiLabel,
      if (details.isNotEmpty) details,
    ].join(': ');

    setState(() {
      _sending = true;
      _error = null;
    });
    final result = await widget.onSubmit(text);
    if (!mounted) return;
    if (result.state) {
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger
          .showSnackBar(SnackBar(content: Text(l10n.propertyReportedThankYou)));
    } else {
      setState(() {
        _sending = false;
        _error = result.message;
        _shake++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Expanded(
              child: Text(l10n.reportThisListing, style: context.tt.titleLarge),
            ),
            CircleIconButton(
              icon: FIcons.x,
              label: l10n.close,
              size: 40,
              border: false,
              background: c.surf,
              onPressed: () => Navigator.pop(context),
            ),
          ]),
          const SizedBox(height: 4),
          Text(l10n.reportPrivate,
              style: context.tt.bodyMedium?.copyWith(color: c.muted)),
          const SizedBox(height: 14),
          for (final r in ReportReason.values) ...[
            RadioCard(
              selected: _reason == r,
              onTap: () => setState(() {
                _reason = r;
                _error = null;
              }),
              child: Text(r.label(l10n), style: context.tt.titleSmall),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 4),
          AppField(
            label: l10n.detailsOptional,
            controller: _details,
            hint: l10n.tellUsWhatsWrong,
            maxLines: 4,
            minLines: 3,
          ),
          AnimatedSize(
            duration: Motion.fast,
            child: _error == null
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(_error!,
                        style: context.tt.bodySmall?.copyWith(color: c.red)),
                  ),
          ),
          const SizedBox(height: 14),
          ShakeOnChange(
            trigger: _shake == 0 ? null : _shake,
            child: FButton(
              label: l10n.sendReport,
              loading: _sending,
              onPressed: _submit,
            ),
          ),
        ],
      ),
    );
  }
}
