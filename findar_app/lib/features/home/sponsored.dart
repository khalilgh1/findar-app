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
    setState(() {
      _bookmarked = !_bookmarked;
    });
    context.read<SponsoredCubit>().saveListing(widget.property.id);
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
              image: DecorationImage(
                image: AssetImage(widget.property.image),
                fit: BoxFit.fill,
              ),
            ),
            clipBehavior: Clip.hardEdge,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Spacer(),
                GestureDetector(
                  onTap: _toggleSave,
                  child: ClipRect(
                    child: Container(
                      clipBehavior: Clip.hardEdge,
                      margin: const EdgeInsets.fromLTRB(0, 0, 8, 8),
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
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.property.price,
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
