import 'package:flutter/material.dart';
import 'primary_button.dart';

class PropertyListingCard extends StatelessWidget {
  final String imageUrl;
  final String price;
  final String location;
  final int beds;
  final int baths;
  final int sqft;
  final String? title;
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
    required this.imageUrl,
    required this.price,
    required this.location,
    required this.beds,
    required this.baths,
    required this.sqft,
    this.title,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme; // UPDATED: Get color scheme from theme
    final textTheme = theme.textTheme; // UPDATED: Get text theme
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
      onTap: onTap,
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
        color: Theme.of(context).colorScheme.surface, // UPDATED: Use theme surface color
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Image
            Stack(
              children: [
                SizedBox(
                  height: imageHeight,
                  width: double.infinity,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.fill,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: colorScheme.secondary.withOpacity(0.3), // UPDATED: Use theme secondary color
                        child: Center(
                          child: Icon(
                            Icons.home,
                            size: screenWidth * 0.12,
                            color: colorScheme.onSecondary, // UPDATED: Use theme onSecondary color
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Save/Bookmark Button
                Positioned(
                  top: screenHeight * 0.015,
                  right: screenWidth * 0.03,

                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: onSaveToggle,
                        child: Container(
                          padding: EdgeInsets.all(4),

                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                             // reduce the size of the button

                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.onSurface.withOpacity(0.1), // UPDATED: Use theme onSurface color
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: colorScheme.primary, // UPDATED: Use theme primary color
                        size: iconSize,
                      ),
                    ),
                  ),
                  if (showMenu)
                  Positioned(
                    top: screenHeight * 0.015,
                    right: screenWidth * 0.15,
                    child: _buildMenuButton(context, screenWidth, colorScheme), // UPDATED: Pass colorScheme
                  ),
              ]),
                // 3-dot menu button
                
                ),
          ]),
            // Property Details
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  if (title != null) ...[
                    Text(
                      title!,
                      style: textTheme.headlineMedium?.copyWith( // UPDATED: Use theme headlineMedium
                        fontWeight: FontWeight.bold,
                        fontSize: titleFontSize,
                        color: colorScheme.onSurface, // UPDATED: Use theme onSurface color
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 15),
                  ],
                  // Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        price,
                        style: textTheme.headlineMedium?.copyWith( // UPDATED: Use theme headlineMedium
                          color: colorScheme.primary, // UPDATED: Use theme primary color
                          fontWeight: FontWeight.bold,
                          fontSize: priceFontSize,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  // Location
                  Text(
                    location,
                    style: textTheme.bodyMedium?.copyWith( // UPDATED: Use theme bodyMedium
                      color: colorScheme.onSecondary, // UPDATED: Use theme onSecondary color
                      fontSize: fontSize * 0.95,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 15),
                  // Property Features
                  Row(
                    children: [
                      _buildFeature(context, '$beds Beds', fontSize, colorScheme, textTheme), // UPDATED: Pass theme
                      SizedBox(width: 10),
                      Text('•', style: TextStyle(color: colorScheme.onSecondary, fontSize: fontSize)), // UPDATED: Use theme color
                      SizedBox(width: 10),
                      _buildFeature(context, '$baths Baths', fontSize, colorScheme, textTheme), // UPDATED: Pass theme
                      SizedBox(width: 10),
                      Text('•', style: TextStyle(color: colorScheme.onSecondary, fontSize: fontSize)), // UPDATED: Use theme color
                      SizedBox(width: 10),
                      _buildFeature(context, '$sqft sqft', fontSize, colorScheme, textTheme), // UPDATED: Pass theme
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
  Widget _buildMenuButton(BuildContext context, double screenWidth, ColorScheme colorScheme) {
    return PopupMenuButton<String>(
      icon: Container(
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: colorScheme.surface, // UPDATED: Use theme surface color
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface.withOpacity(0.1), // UPDATED: Use theme onSurface color
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
              SizedBox(width: 15),

              Text('Edit', style: TextStyle(fontSize: 10, color: colorScheme.onSurface)), // UPDATED: Use theme color

            ],
          ),
        ),
        PopupMenuItem(
          value: 'remove',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 20, color: colorScheme.error), // UPDATED: Use theme error color
              SizedBox(width: 15),
              Text('Remove', style: TextStyle(fontSize: 10, color: colorScheme.onSurface)), // UPDATED: Use theme color
            ],
          ),
        ),
        PopupMenuItem(
          value: 'toggle',
          child: Row(
            children: [
              Icon(Icons.cloud_off_outlined, size: 20, color: colorScheme.onSurface), // UPDATED: Use theme color
              SizedBox(width: 15),
              Text(
                menuToggleText ?? 'Toggle Status',
                style: TextStyle(fontSize: 10, color: colorScheme.onSurface), // UPDATED: Use theme color
              ),
            ],
          ),
        ),
      ],
    );
  }

  // UPDATED: Method signature with colorScheme and textTheme parameters
  Widget _buildFeature(BuildContext context, String text, double fontSize, ColorScheme colorScheme, TextTheme textTheme) {
    return Text(
      text,
      style: textTheme.bodyMedium?.copyWith( // UPDATED: Use theme bodyMedium
            color: colorScheme.onSecondary, // UPDATED: Use theme onSecondary color
            fontSize: fontSize * 0.9,
          ),
    );
  }
}
