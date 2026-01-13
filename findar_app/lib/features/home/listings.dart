import 'dart:io';

import 'package:flutter/material.dart';
import 'package:findar/logic/cubits/home/recent_listings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findar/features/home/property.dart';

const String _kDefaultImageUrl =
    'https://res.cloudinary.com/da5xjc4dx/image/upload/v1767273156/default_cxkkda.jpg';

String _imageOrDefault(String? img) {
  if (img == null) return _kDefaultImageUrl;
  final s = img.trim();
  if (s.isEmpty || s.toLowerCase() == 'null') return _kDefaultImageUrl;
  return s;
}

/// Build the appropriate image widget based on the image path
Widget _buildListingImage(String imagePath,
    {double? width, double? height, BoxFit fit = BoxFit.cover}) {
  // Check if it's a network URL
  if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
    return Image.network(
      imagePath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: Icon(Icons.broken_image, color: Colors.grey[600]),
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
    );
  }

  // Check if it's a local file path
  if (imagePath.isNotEmpty && !imagePath.startsWith('assets/')) {
    final file = File(imagePath);
    return FutureBuilder<bool>(
      future: file.exists(),
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          return Image.file(
            file,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: width,
                height: height,
                color: Colors.grey[300],
                child: Icon(Icons.broken_image, color: Colors.grey[600]),
              );
            },
          );
        }
        return Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: Icon(Icons.image, color: Colors.grey[600]),
        );
      },
    );
  }

  // Asset image
  if (imagePath.startsWith('assets/')) {
    return Image.asset(
      imagePath,
      width: width,
      height: height,
      fit: fit,
    );
  }

  return Container(
    width: width,
    height: height,
    color: Colors.grey[300],
    child: Icon(Icons.image, color: Colors.grey[600]),
  );
}

class ListingTile extends StatefulWidget {
  final Property property;
  const ListingTile({super.key, required this.property});

  @override
  State<ListingTile> createState() => _ListingTileState();
}

class _ListingTileState extends State<ListingTile> {
  late bool _bookmarked;
  @override
  void initState() {
    super.initState();
    _bookmarked = widget.property.bookmarked; // initial value
    print("property: ");
    print(widget.property.image);
  }

  void _toggleSave() async {
    final cubit = context.read<RecentCubit>();
    print('Before toggle: _bookmarked=$_bookmarked, id=${widget.property.id}');

    if (_bookmarked) {
      // Currently saved, so unsave it
      print('Unsaving listing ${widget.property.id}');
      final result = await cubit.unsaveListing(widget.property.id);

      // Only update UI if successful
      if (result.state) {
        setState(() {
          _bookmarked = false;
        });
      } else {
        print('Failed to unsave: ${result.message}');
      }
    } else {
      // Currently not saved, so save it
      print('Saving listing ${widget.property.id}');
      final result = await cubit.saveListing(widget.property.id);

      // Only update UI if successful
      if (result.state) {
        setState(() {
          _bookmarked = true;
        });
      } else {
        print('Failed to save: ${result.message}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    final imageUrl = _imageOrDefault(widget.property.image);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
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
              child: _buildListingImage(imageUrl, width: 100, height: 90),
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
                    widget.property.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${widget.property.price} DZD',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    widget.property.address,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Text(
                    widget.property.details,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(8, 0, 10, 50),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _toggleSave,
                  child: Icon(
                    _bookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: Colors.blue,
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
