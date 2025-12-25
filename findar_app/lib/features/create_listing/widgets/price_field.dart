import 'package:flutter/material.dart';
import 'package:findar/l10n/app_localizations.dart';

class priceField extends StatelessWidget {
  const priceField({
    super.key,
    required TextEditingController priceController,
    required this.theme,
    this.validator,
  }) : _priceController = priceController;

  final TextEditingController _priceController;
  final ThemeData theme;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return TextFormField(
      controller: _priceController,
      validator: validator,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        fillColor: theme.colorScheme.secondaryContainer,
        filled: true,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.secondary),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
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
  hintText: l10n.examplePriceHint,
        hintStyle: TextStyle(
          color: theme.colorScheme.onSurface,
          fontSize: 15,
        ),
        prefixText: 'DA ',
        prefixStyle: TextStyle(
          color: theme.colorScheme.onSurface,
          fontSize: 15,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
