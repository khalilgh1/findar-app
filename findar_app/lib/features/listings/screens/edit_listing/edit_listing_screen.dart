import 'package:flutter/material.dart';

import 'package:findar/core/models/property_listing_model.dart';
import 'package:findar/features/create_listing/create_listing.dart';

/// Edit listing is the Create listing form pre-filled with [listing].
class EditListingScreen extends StatelessWidget {
  const EditListingScreen({super.key, required this.listing});
  final PropertyListing listing;

  @override
  Widget build(BuildContext context) => CreateListingScreen(listing: listing);
}
