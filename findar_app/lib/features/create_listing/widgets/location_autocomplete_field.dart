import 'package:flutter/material.dart';
import 'package:findar/core/services/tomtom_service.dart';
import 'package:findar/l10n/app_localizations.dart';

class LocationAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final ThemeData theme;
  final String? Function(String?)? validator;
  final Function(double latitude, double longitude)? onLocationSelected;

  const LocationAutocompleteField({
    super.key,
    required this.controller,
    required this.theme,
    this.validator,
    this.onLocationSelected,
  });

  @override
  State<LocationAutocompleteField> createState() => _LocationAutocompleteFieldState();
}

class _LocationAutocompleteFieldState extends State<LocationAutocompleteField> {
  List<LocationResult> _suggestions = [];
  bool _isLoading = false;

  void _onChanged(String value) async {
    if (value.length < 1) {
      setState(() => _suggestions = []);
      return;
    }
    setState(() => _isLoading = true);
    final results = await TomTomService.autocomplete(value);
    setState(() {
      _suggestions = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          style: const TextStyle(fontSize: 15, color: Colors.black87),
          decoration: InputDecoration(
            fillColor: widget.theme.colorScheme.secondaryContainer,
            filled: true,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: widget.theme.colorScheme.secondary),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: widget.theme.colorScheme.primary, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            hintText: l10n?.exampleLocationHint ?? 'e.g. 15 Rue Didouche Mourad, Algiers',
            hintStyle: TextStyle(
              color: widget.theme.colorScheme.onSurfaceVariant,
              fontSize: 15,
            ),
            prefixIcon: Icon(
              Icons.location_on_outlined,
              color: Colors.grey[400],
              size: 22,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          onChanged: _onChanged,
        ),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: LinearProgressIndicator(),
          ),
        if (_suggestions.isNotEmpty)
          Card(
            margin: const EdgeInsets.only(top: 4),
            child: ListView(
              shrinkWrap: true,
              children: _suggestions.map((location) => ListTile(
                title: Text(location.address),
                onTap: () {
                  widget.controller.text = location.address;
                  widget.onLocationSelected?.call(location.latitude, location.longitude);
                  setState(() => _suggestions = []);
                },
              )).toList(),
            ),
          ),
      ],
    );
  }
}
