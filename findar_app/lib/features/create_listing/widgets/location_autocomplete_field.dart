import 'dart:async';

import 'package:flutter/material.dart';

import 'package:findar/core/services/tomtom_service.dart';
import 'package:findar/core/theme/findar_tokens.dart';
import 'package:findar/core/widgets/f_icon.dart';
import 'package:findar/core/widgets/ui.dart';

/// Address field with TomTom suggestions in a dropdown card.
/// Requests are debounced (300 ms) and late responses for an older query
/// are dropped.
class LocationAutocompleteField extends StatefulWidget {
  const LocationAutocompleteField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.validator,
    this.onLocationSelected,
    this.onCleared,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? Function(String?)? validator;
  final void Function(double latitude, double longitude)? onLocationSelected;

  /// Called when the user edits the text after picking a suggestion.
  final VoidCallback? onCleared;

  @override
  State<LocationAutocompleteField> createState() =>
      _LocationAutocompleteFieldState();
}

class _LocationAutocompleteFieldState extends State<LocationAutocompleteField> {
  List<LocationResult> _suggestions = const [];
  bool _loading = false;
  Timer? _debounce;
  int _seq = 0;
  bool _picked = false;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    if (_picked) {
      _picked = false;
      widget.onCleared?.call();
    }
    _debounce?.cancel();
    final q = value.trim();
    if (q.length < 2) {
      setState(() {
        _suggestions = const [];
        _loading = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      final seq = ++_seq;
      setState(() => _loading = true);
      List<LocationResult> results;
      try {
        results = await TomTomService.autocomplete(q);
      } catch (_) {
        results = const [];
      }
      if (!mounted || seq != _seq) return;
      setState(() {
        _suggestions = results.take(5).toList();
        _loading = false;
      });
    });
  }

  void _pick(LocationResult r) {
    _picked = true;
    widget.controller.text = r.address;
    widget.onLocationSelected?.call(r.latitude, r.longitude);
    FocusScope.of(context).unfocus();
    setState(() => _suggestions = const []);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppField(
          label: widget.label,
          controller: widget.controller,
          hint: widget.hint,
          icon: FIcons.pin,
          validator: widget.validator,
          onChanged: _onChanged,
          textInputAction: TextInputAction.search,
          trailing: _loading
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: c.accent))
              : null,
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.topCenter,
          child: _suggestions.isEmpty
              ? const SizedBox(width: double.infinity)
              : Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: c.bg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: c.line),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0x14111317),
                          blurRadius: 24,
                          offset: Offset(0, 8)),
                    ],
                  ),
                  child: Column(children: [
                    for (final r in _suggestions)
                      _Suggestion(r, () => _pick(r)),
                  ]),
                ),
        ),
      ],
    );
  }
}

class _Suggestion extends StatelessWidget {
  const _Suggestion(this.r, this.onTap);
  final LocationResult r;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    final i = r.address.indexOf(',');
    final main = i < 0 ? r.address : r.address.substring(0, i);
    final sub = i < 0 ? '' : r.address.substring(i + 1).trim();
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(children: [
            FIcon(FIcons.pin, size: 18, color: c.muted),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(main,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.tt.titleSmall?.copyWith(fontSize: 14)),
                  if (sub.isNotEmpty)
                    Text(sub,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.tt.bodySmall?.copyWith(
                            fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
