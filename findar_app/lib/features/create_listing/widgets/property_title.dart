import 'package:flutter/material.dart';
class PropertyTitle extends StatelessWidget {
  const PropertyTitle({
    super.key,
    required TextEditingController titleController,
    required this.theme,
  }) : _titleController = titleController;

  final TextEditingController _titleController;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _titleController,
      decoration: InputDecoration(
        fillColor: theme.colorScheme.secondaryContainer,
        filled: true,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: theme.colorScheme.secondary),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        hintText: 'e.g. Spacious 3 Bedroom Apartment',
        hintStyle: TextStyle(
          color: theme.colorScheme.onSecondary,
          fontSize: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}