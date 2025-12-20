import 'package:flutter/material.dart';

class PropertyImageCarousel extends StatelessWidget {
  final String image;

  const PropertyImageCarousel({
    super.key,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
        color: colorScheme.surfaceVariant,
      ),
      clipBehavior: Clip.antiAlias,
      child: image.startsWith('http')
          ? Image.network(
              image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: Icon(Icons.broken_image, size: 50, color: Colors.grey[600]),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(child: CircularProgressIndicator());
              },
            )
          : Image.asset(
              image,
              fit: BoxFit.cover,
            ),
    );
  }
}
