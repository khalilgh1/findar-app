import 'package:flutter/material.dart';

class PropertyHeader extends StatelessWidget {
  final String title;
  final String address;
  final double price;

  const PropertyHeader({
    super.key,
    required this.title,
    required this.address,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          address,
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _formatPrice(price),
          style: textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
      ],
    );
  }

  String _formatPrice(double price) {
    if (price <= 0) {
      return 'Price on request';
    }

    final hasDecimals = price % 1 != 0;
    final value = hasDecimals
        ? price.toStringAsFixed(2)
        : price.toStringAsFixed(0);
    final parts = value.split('.');
    final whole = parts.first.replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), ',');

    if (parts.length > 1 && parts[1].isNotEmpty) {
      return '$whole.${parts[1]} DZD';
    }

    return '$whole DZD';
  }
}
