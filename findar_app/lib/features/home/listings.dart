import 'package:flutter/material.dart';
import 'property.dart';

class ListingTile extends StatelessWidget {
  final Property property;
  final bool bookmarked;
  const ListingTile({
    super.key,
    required this.property,
    this.bookmarked = true,
  });

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    // theme.colorScheme.surface
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        // boxShadow: [
        //   BoxShadow(
        //     color: theme.colorScheme.shadow,
        //     blurRadius: 0.2,
        //     offset: Offset(0, 0),
        //   ),
        // ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.all(8),
            height: 80,
            width: 90,
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              child: Image.asset(
                property.image,
                width: 100,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    property.price,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    property.address,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Text(
                    property.details,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(8, 0, 10, 50),

            child: Column(
              children: [
                Icon(
                  Icons.bookmark_border,
                  color: bookmarked
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
