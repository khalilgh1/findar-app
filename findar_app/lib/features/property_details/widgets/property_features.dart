import 'package:flutter/material.dart';

class PropertyFeatures extends StatelessWidget {
  final int bedrooms;
  final int bathrooms;
  final String sqft;

  const PropertyFeatures({
    super.key,
    required this.bedrooms,
    required this.bathrooms,
    required this.sqft,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _FeatureItem(
              icon: Icons.bed_outlined,
              text: '$bedrooms Bedrooms',
            ),
            const SizedBox(width: 24),
            _FeatureItem(
              icon: Icons.bathtub_outlined,
              text: '$bathrooms Bathrooms',
            ),
          ],
        ),
        const SizedBox(height: 12),
        _FeatureItem(
          icon: Icons.square_foot,
          text: sqft,
        ),
      ],
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.onSurface.withOpacity(0.8)),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
