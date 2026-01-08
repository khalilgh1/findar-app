import 'package:findar/logic/cubits/property_details_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findar/logic/cubits/my_listings_cubit.dart';
import 'package:findar/core/models/property_listing_model.dart';
import 'package:findar/l10n/app_localizations.dart';
import 'package:findar/core/widgets/property_card.dart';
import 'package:findar/core/widgets/segment_control.dart';
import 'package:findar/core/widgets/progress_button.dart';
import 'package:findar/core/widgets/build_bottom_bar.dart';
import 'package:findar/core/widgets/confirmation_dialog.dart';
import 'package:findar/core/widgets/no_internet_widget.dart';
import 'package:findar/core/widgets/shimmer_loading.dart';

/// Helper function to check if an error message indicates a network issue
bool _isNetworkError(String? message) {
  if (message == null) return false;
  final lowerMessage = message.toLowerCase();
  return lowerMessage.contains('internet') ||
      lowerMessage.contains('offline') ||
      lowerMessage.contains('network') ||
      lowerMessage.contains('connection');
}
class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  String _selectedTab = 'Online';

  @override
  void initState() {
    super.initState();
    // Fetch listings when screen loads
    context.read<MyListingsCubit>().fetchMyListings();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Builder(
          builder: (context) {
            var l10n = AppLocalizations.of(context)!;
            return Text(
              l10n.myListings,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: Theme.of(context).colorScheme.onSurface,
              size: 25,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
              // Handle settings
            },
          ),
        ],
      ),
      body: Column(
        // Color this column
        children: [
          // Segmented Control
          Container(
            color: Theme.of(context).colorScheme.surface,
            padding: EdgeInsets.all(15),
            child: SegmentedControl(
              inactiveColor: const Color.fromARGB(255, 87, 71, 71),
              options: const ['Online', 'Offline'],
              initialValue: _selectedTab,
              activeColor: Theme.of(context).colorScheme.primary,
              onChanged: (value) {
                setState(() {
                  _selectedTab = value;
                });
              },
            ),
          ),
          Divider(
            height: 1,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
          ),
          // Listings
          Expanded(
            child: BlocBuilder<MyListingsCubit, Map<String, dynamic>>(
              builder: (context, state) {
                if (state['state'] == 'loading') {
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: 4,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: const PropertyGridCardSkeleton(),
                    ),
                  );
                }

                if (state['state'] == 'error') {
                  final errorMessage = state['message'] as String?;

                  // My listings should work offline from local cache
                  // But if there's a network error, show appropriate message
                  if (_isNetworkError(errorMessage)) {
                    return NoInternetWidget(
                      title: 'Your Listings Available Offline',
                      message:
                          'Viewing your listings from local storage. Some actions may be unavailable until you reconnect.',
                      onRetry: () {
                        context.read<MyListingsCubit>().fetchMyListings();
                      },
                    );
                  }

                  return Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Error: ${errorMessage ?? 'Unknown error'}'),
                            SizedBox(height: 16),
                            ProgressButton(
                              label: l10n.retry,
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              textColor:
                                  Theme.of(context).colorScheme.onPrimary,
                              onPressed: () {
                                context
                                    .read<MyListingsCubit>()
                                    .fetchMyListings();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }

                // Use cubit getters for filtered listings
                final cubit = context.read<MyListingsCubit>();
                final listings = _selectedTab == 'Online'
                    ? cubit.onlineListings
                    : cubit.offlineListings;

                if (listings.isEmpty) {
                  return Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.home_outlined,
                              size: 60,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 30),
                            Text(
                              l10n.noListingsMessage(_selectedTab),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              l10n.addFirstPropertyListing,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.only(top: 8.0, bottom: 80.0),
                  itemCount: listings.length,
                  itemBuilder: (context, index) {
                    final listing = listings[index];
                    return PropertyListingCard(
                      listing: listing,
                      isSaved: false,
                      showMenu: true,
                      onEdit: () => _handleEdit(listing),
                      onRemove: () => _handleRemove(listing),
                      onToggleStatus: () => _handleToggleStatus(listing),
                      menuToggleText: _selectedTab == 'Online'
                          ? 'Make Offline'
                          : 'Make Online',
                      showBoostButton: true,
                      onBoost: () => _handleBoost(listing),
                      onTap: () {
                        context
                            .read<PropertyDetailsCubit>()
                            .fetchPropertyDetails(
                              listing.id,
                            );
                        Navigator.pushNamed(context, '/property-details');
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      // Floating Action Button to add new listing
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Open create listing and refresh when a new listing was created
          final created = await Navigator.pushNamed(context, '/create-listing');
          if (created == true) {
            // refresh listings
            context.read<MyListingsCubit>().fetchMyListings();
          }
        },
        backgroundColor: theme.colorScheme.primary,
        child: Icon(Icons.add, size: 40, color: Colors.white),
      ),
      bottomNavigationBar: BuildBottomNavBar(index: 2),
    );
  }

  // UPDATED: Edit handler
  void _handleEdit(PropertyListing listing) {
    // Navigate to edit screen
    Navigator.pushNamed(context, '/edit-listing', arguments: listing);
  }

  // UPDATED: Remove handler
  void _handleRemove(PropertyListing listing) {
    ConfirmationDialog.show(
      context: context,
      title: 'Remove Listing',
      message: 'Are you sure you want to remove "${listing.title}"?',
      onConfirm: () {
        context.read<MyListingsCubit>().deleteListing(listing.id);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Removing listing...')));
      },
    );
  }

  // UPDATED: Toggle online/offline handler
  void _handleToggleStatus(PropertyListing listing) {
    final newStatus = listing.isOnline ? 'Offline' : 'Online';
    context.read<MyListingsCubit>().toggleActiveListing(listing.id);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Setting listing to $newStatus...')));
  }

  // UPDATED: Boost handler
  void _handleBoost(PropertyListing listing) {
    Navigator.pushNamed(context, '/sponsorship-plans', arguments: listing);
  }
}
