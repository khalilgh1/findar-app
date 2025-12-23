import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:findar/core/models/property_listing_model.dart';
import 'package:findar/logic/cubits/property_details_cubit.dart';
import 'package:findar/core/widgets/primary_button.dart';

class PropertyListingCard extends StatelessWidget {
  final PropertyListing listing;
  final bool isSaved;
  final VoidCallback? onTap;
  final VoidCallback? onSaveToggle;
  final bool showMenu;
  final VoidCallback? onEdit;
  final VoidCallback? onRemove;
  final VoidCallback? onToggleStatus;
  final String? menuToggleText;
  final bool showBoostButton;
  final VoidCallback? onBoost;

  const PropertyListingCard({
    super.key,
    required this.listing,
    this.isSaved = false,
    this.onTap,
    this.onSaveToggle,
    this.showMenu = false,
    this.onEdit,
    this.onRemove,
    this.onToggleStatus,
    this.menuToggleText,
    this.showBoostButton = false,
    this.onBoost,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(
      context,
    ).colorScheme; // UPDATED: Get color scheme from theme
    final textTheme = Theme.of(context).textTheme; // UPDATED: Get text theme
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive sizing
    final cardMargin = screenWidth * 0.04;
    final imageHeight = 250.0;
    final iconSize = 25.0;
    final fontSize = screenWidth * 0.04;
    final titleFontSize = screenWidth * 0.045;
    final priceFontSize = 25.0;

    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!();
        } else {
          context.read<PropertyDetailsCubit>().fetchPropertyDetails(listing.id);
          Navigator.pushNamed(context, '/property-details', arguments: listing);
        }
      },
      child: Card(
        margin: EdgeInsets.symmetric(
          horizontal: cardMargin,
          vertical: screenHeight * 0.01,
        ),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
        ),
        elevation: 2,
        color: Theme.of(
          context,
        ).colorScheme.onPrimary, // UPDATED: Use theme surface color
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Image
            Stack(
              children: [
                _buildListingImage(
                  height: imageHeight,
                  width: double.infinity,
                  colorScheme: colorScheme,
                  screenWidth: screenWidth,
                ),
                // Boosted badge
                if (listing.isBoosted)
                  Positioned(
                    top: screenHeight * 0.015,
                    left: screenWidth * 0.03,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.onSurface.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.rocket_launch,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Boosted',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // 3-dot menu button (replaces save icon when showMenu is true)
                if (showMenu)
                  Positioned(
                    top: screenHeight * 0.015,
                    right: screenWidth * 0.03,
                    child: _buildMenuButton(context, screenWidth, colorScheme),
                  )
                else
                  // Save/Bookmark Button (only show when menu is not shown)
                  Positioned(
                    top: screenHeight * 0.015,
                    right: screenWidth * 0.03,
                    child: GestureDetector(
                      onTap: onSaveToggle,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.onSurface.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          isSaved ? Icons.bookmark : Icons.bookmark_border,
                          color: colorScheme.primary,
                          size: iconSize,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Property Details
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    listing.title,
                    style: textTheme.headlineMedium?.copyWith(
                      // UPDATED: Use theme headlineMedium
                      fontWeight: FontWeight.bold,
                      fontSize: titleFontSize,
                      color: colorScheme
                          .onSurface, // UPDATED: Use theme onSurface color
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 15),
                  // Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatPrice(listing.price),
                        style: textTheme.headlineMedium?.copyWith(
                          // UPDATED: Use theme headlineMedium
                          color: colorScheme
                              .primary, // UPDATED: Use theme primary color
                          fontWeight: FontWeight.bold,
                          fontSize: priceFontSize,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  // Location
                  Text(
                    listing.location,
                    style: textTheme.bodyMedium?.copyWith(
                      // UPDATED: Use theme bodyMedium
                      color: colorScheme
                          .onSecondaryContainer, // UPDATED: Use theme onSecondary color
                      fontSize: fontSize * 0.95,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 15),
                  // Property Features
                  Row(
                    children: [
                      _buildFeature(
                        context,
                        '${listing.bedrooms} Beds',
                        fontSize,
                        colorScheme,
                        textTheme,
                      ), // UPDATED: Pass theme
                      SizedBox(width: 10),
                      Text(
                        '•',
                        style: TextStyle(
                          color: colorScheme.onSecondary,
                          fontSize: fontSize,
                        ),
                      ), // UPDATED: Use theme color
                      SizedBox(width: 10),
                      _buildFeature(
                        context,
                        '${listing.bathrooms} Baths',
                        fontSize,
                        colorScheme,
                        textTheme,
                      ), // UPDATED: Pass theme
                      SizedBox(width: 10),
                      Text(
                        '•',
                        style: TextStyle(
                          color: colorScheme.onSecondary,
                          fontSize: fontSize,
                        ),
                      ), // UPDATED: Use theme color
                      SizedBox(width: 10),
                      _buildFeature(
                        context,
                        listing.propertyType,
                        fontSize,
                        colorScheme,
                        textTheme,
                      ), // UPDATED: Pass theme
                    ],
                  ),
                  // Boost Button
                  if (showBoostButton) ...[
                    SizedBox(height: 15),
                    PrimaryButton(
                      text: 'Boost',
                      onPressed: onBoost,
                      icon: Icons.rocket_launch_outlined,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // UPDATED: Method signature with colorScheme parameter
  Widget _buildMenuButton(
    BuildContext context,
    double screenWidth,
    ColorScheme colorScheme,
  ) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: colorScheme.surface, // UPDATED: Use theme surface color
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface.withOpacity(
                0.1,
              ), // UPDATED: Use theme onSurface color
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.more_vert,
          color: colorScheme.onSurface, // UPDATED: Use theme onSurface color
          size: 20,
        ),
      ),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit?.call();
            break;
          case 'remove':
            onRemove?.call();
            break;
          case 'toggle':
            onToggleStatus?.call();
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 20, color: colorScheme.onSurface),
              SizedBox(width: 12),
              Text(
                'Edit',
                style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'remove',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 20, color: colorScheme.error),
              SizedBox(width: 12),
              Text(
                'Remove',
                style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'toggle',
          child: Row(
            children: [
              Icon(
                Icons.cloud_off_outlined,
                size: 20,
                color: colorScheme.onSurface,
              ),
              SizedBox(width: 12),
              Text(
                menuToggleText ?? 'Toggle Status',
                style: TextStyle(fontSize: 14, color: colorScheme.onSurface),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // UPDATED: Method signature with colorScheme and textTheme parameters
  Widget _buildFeature(
    BuildContext context,
    String text,
    double fontSize,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Text(
      text,
      style: textTheme.bodyMedium?.copyWith(
        // UPDATED: Use theme bodyMedium
        color: colorScheme
            .onSecondaryContainer, // UPDATED: Use theme onSecondary color
        fontSize: fontSize * 0.9,
      ),
    );
  }

  Widget _buildListingImage({
    required double height,
    required double width,
    required ColorScheme colorScheme,
    required double screenWidth,
  }) {
    if (listing.image.isEmpty) {
      return Container(
        height: height,
        width: width,
        color: colorScheme.secondary.withOpacity(0.3),
        child: Center(
          child: Icon(
            Icons.home,
            size: screenWidth * 0.12,
            color: colorScheme.onSecondary,
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      width: width,
      child: Image.network(
        listing.image,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: colorScheme.secondary.withOpacity(0.3),
            child: Center(
              child: Icon(
                Icons.home,
                size: screenWidth * 0.12,
                color: colorScheme.onSecondary,
              ),
            ),
          );
        },
      ),
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
