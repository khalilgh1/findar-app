import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:findar/logic/cubits/home/sponsored_listings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'property.dart';

class PropertyCard extends StatefulWidget {
  final Property property;
  const PropertyCard({super.key, required this.property});

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  late bool _bookmarked;

  @override
  void initState() {
    super.initState();
    _bookmarked = widget.property.bookmarked; // initial value
  }

  void _toggleSave() {
    final cubit = context.read<SponsoredCubit>();
    print('Before toggle: _bookmarked=$_bookmarked, id=${widget.property.id}');
    
    if (_bookmarked) {
      // Currently saved, so unsave it
      print('Unsaving listing ${widget.property.id}');
      setState(() {
        _bookmarked = false;
      });
      cubit.unsaveListing(widget.property.id);
    } else {
      // Currently not saved, so save it
      print('Saving listing ${widget.property.id}');
      setState(() {
        _bookmarked = true;
      });
      cubit.saveListing(widget.property.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 250,
      margin: const EdgeInsets.fromLTRB(4, 0, 16, 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.shadow, width: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
            height: 125,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Dynamic image loading based on URL
                widget.property.image.startsWith('http')
                    ? Image.network(
                        widget.property.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Colors.grey,
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      )
                    : Image.asset(
                        widget.property.image,
                        fit: BoxFit.cover,
                      ),
                // Bookmark button overlay
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: GestureDetector(
                    onTap: _toggleSave,
                    child: ClipRect(
                      child: Container(
                        clipBehavior: Clip.hardEdge,
                        padding: _bookmarked
                            ? EdgeInsets.fromLTRB(2, 10, 2, 6)
                            : EdgeInsets.fromLTRB(2, 6, 2, 20),
                        width: 35,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
                          child: Icon(
                            _bookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border_outlined,
                            size: 22,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.property.price.toString()+' DZD',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.property.address,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                  softWrap: false,
                ),
                const SizedBox(height: 2),
                Text(
                  widget.property.details,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
