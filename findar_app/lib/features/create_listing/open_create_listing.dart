import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:findar/logic/cubits/home/recent_listings.dart';
import 'package:findar/logic/cubits/my_listings_cubit.dart';

/// Opens Create listing (it rises like a sheet) and, when a listing was
/// published, refreshes My listings and the Home feed.
Future<void> openCreateListing(BuildContext context) async {
  final myListings = context.read<MyListingsCubit>();
  final recent = context.read<RecentCubit>();
  final created = await Navigator.pushNamed(context, '/create-listing');
  if (created == true) {
    myListings.fetchMyListings(forceRefresh: true);
    recent.getRecentListings(forceRefresh: true);
  }
}
