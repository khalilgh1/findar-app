import 'package:flutter/material.dart';
import 'package:findar/logic/cubits/home/recent_listings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findar/features/home/property.dart';

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
              child: widget.property.image.startsWith('http')
                  ? Image.network(
                      widget.property.image,
                      width: 100,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
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
                    )
                  : Image.asset(
                      widget.property.image,
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
                    widget.property.price.toString() + ' DZD',
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
