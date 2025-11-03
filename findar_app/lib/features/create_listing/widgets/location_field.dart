import 'package:flutter/material.dart';

class LocationField extends StatelessWidget {
  const LocationField({
    super.key,
    required TextEditingController locationController,
    required this.theme,
  }) : _locationController = locationController;

  final TextEditingController _locationController;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _locationController,
      style: const TextStyle(fontSize: 15, color: Colors.black87),
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

        hintText: 'e.g. 15 Rue Didouche Mourad, Algiers',
        hintStyle: TextStyle(
          color: theme.colorScheme.onSurface,
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
    );
  }
}
