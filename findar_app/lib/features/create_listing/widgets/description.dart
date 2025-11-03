import 'package:flutter/material.dart';

class Description extends StatelessWidget {
  const Description({
    super.key,
    required TextEditingController descriptionController,
    required this.theme,
  }) : _descriptionController = descriptionController;

  final TextEditingController _descriptionController;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _descriptionController,
      maxLines: 5,
      style: const TextStyle(fontSize: 15, color: Colors.black87),
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
        hintText: 'Describe the property details here...',
        hintStyle: TextStyle(
          color: theme.colorScheme.onSurfaceVariant,
          fontSize: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}