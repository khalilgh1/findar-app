import 'package:flutter/material.dart';

const String _kDefaultImageUrl =
    'https://res.cloudinary.com/da5xjc4dx/image/upload/v1767273156/default_cxkkda.jpg';

String _imageOrDefault(String? img) {
  if (img == null) return _kDefaultImageUrl;
  final s = img.trim();
  if (s.isEmpty || s.toLowerCase() == 'null') return _kDefaultImageUrl;
  return s;
}

class PropertyImageCarousel extends StatelessWidget {
  final String image;

  const PropertyImageCarousel({
    super.key,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final imageUrl = _imageOrDefault(image);

    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
        color: colorScheme.surfaceContainerHighest,
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl.startsWith('http')
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: Icon(Icons.broken_image,
                      size: 50, color: Colors.grey[600]),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(child: CircularProgressIndicator());
              },
            )
          : Image.asset(
              imageUrl,
              fit: BoxFit.cover,
            ),
    );
  }
}
