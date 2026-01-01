import 'package:flutter/material.dart';
import 'package:findar/l10n/app_localizations.dart';

const String _kDefaultImageUrl =
    'https://res.cloudinary.com/da5xjc4dx/image/upload/v1767273156/default_cxkkda.jpg';

String _imageOrDefault(String? img) {
  if (img == null) return _kDefaultImageUrl;
  final s = img.trim();
  if (s.isEmpty || s.toLowerCase() == 'null') return _kDefaultImageUrl;
  return s;
}

class SimilarPropertiesList extends StatelessWidget {
  final List<SimilarProperty> properties;

  const SimilarPropertiesList({
    super.key,
    required this.properties,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Builder(
          builder: (context) {
            var l10n = AppLocalizations.of(context);
            return Text(
              l10n?.similarProperties ?? 'Similar Properties',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: properties.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return SimilarPropertyCard(property: properties[index]);
            },
          ),
        ),
      ],
    );
  }
}

class SimilarPropertyCard extends StatelessWidget {
  final SimilarProperty property;

  const SimilarPropertyCard({
    super.key,
    required this.property,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final imageUrl = _imageOrDefault(property.image);

    return Container(
      width: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: imageUrl.startsWith('http')
                ? Image.network(
                    imageUrl,
                    height: 100,
                    width: 160,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 100,
                        width: 160,
                        color: Colors.grey[300],
                        child:
                            Icon(Icons.broken_image, color: Colors.grey[600]),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return SizedBox(
                        height: 100,
                        width: 160,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    },
                  )
                : Image.asset(
                    imageUrl,
                    height: 100,
                    width: 160,
                    fit: BoxFit.cover,
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatPrice(property.price),
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  property.address,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    if (price <= 0) {
      return 'Price on request';
    }

    final hasDecimals = price % 1 != 0;
    final value =
        hasDecimals ? price.toStringAsFixed(2) : price.toStringAsFixed(0);
    final parts = value.split('.');
    final whole = parts.first.replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), ',');

    if (parts.length > 1 && parts[1].isNotEmpty) {
      return '$whole.${parts[1]} DZD';
    }

    return '$whole DZD';
  }
}

class SimilarProperty {
  final String image;
  final double price;
  final String address;

  const SimilarProperty({
    required this.image,
    required this.price,
    required this.address,
  });
}
