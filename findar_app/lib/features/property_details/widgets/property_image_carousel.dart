import 'package:flutter/material.dart';

class PropertyImageCarousel extends StatelessWidget {
  final List<String> images;

  const PropertyImageCarousel({
    super.key,
    required this.images,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
        color: colorScheme.surfaceVariant,
      ),
      clipBehavior: Clip.antiAlias,
      child: PageView(
        children: images
            .map(
              (image) => Image.asset(
                image,
                fit: BoxFit.cover,
              ),
            )
            .toList(),
      ),
    );
  }
}
