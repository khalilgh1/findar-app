import 'package:flutter/material.dart';

class PropertyDescription extends StatelessWidget {
  final String description;

  const PropertyDescription({
    super.key,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          description,
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
