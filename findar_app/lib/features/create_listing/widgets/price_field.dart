import 'package:flutter/material.dart';

class priceField extends StatelessWidget {
  const priceField({
    super.key,
    required TextEditingController priceController,
    required this.theme,
  }) : _priceController = priceController;

  final TextEditingController _priceController;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _priceController,
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
        hintText: '250 000',
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
