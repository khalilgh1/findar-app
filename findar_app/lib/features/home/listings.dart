import 'package:flutter/material.dart';
import 'package:findar/logic/cubits/home/recent_listings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'property.dart';

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

  void _toggleSave() {
    final cubit = context.read<RecentCubit>();
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
              child: Image.asset(
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
                    widget.property.price.toString(),
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
