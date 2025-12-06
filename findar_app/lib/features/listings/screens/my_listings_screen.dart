import 'package:findar/logic/cubits/property_details_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findar/logic/cubits/my_listings_cubit.dart';
import 'package:findar/core/models/property_listing_model.dart';
import '../../../core/widgets/property_card.dart';
import '../../../core/widgets/segment_control.dart';
import '../../../core/widgets/progress_button.dart';
import '../../../core/widgets/build_bottom_bar.dart';
import '../../../core/widgets/confirmation_dialog.dart';

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
        title: Text(
          'My Listings',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
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
                  return const Center(child: CircularProgressIndicator());
                }

                if (state['state'] == 'error') {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${state['message'] ?? 'Unknown error'}'),
                        SizedBox(height: 16),
                        ProgressButton(
                          label: 'Retry',
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          textColor: Theme.of(context).colorScheme.onPrimary,
                          onPressed: () {
                            context.read<MyListingsCubit>().fetchMyListings();
                          },
                        ),
                      ],
                    ),
                  );
                }

                // Use cubit getters for filtered listings
                final cubit = context.read<MyListingsCubit>();
                final listings = _selectedTab == 'Online'
                    ? cubit.onlineListings
                    : cubit.offlineListings;

                if (listings.isEmpty) {
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
                          'No $_selectedTab listings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Add your first property listing',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
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
                        context.read<PropertyDetailsCubit>().fetchPropertyDetails(
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
    context.read<MyListingsCubit>().editListing(
      id: listing.id,
      isOnline: !listing.isOnline,
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Setting listing to $newStatus...')));
  }

  // UPDATED: Boost handler
  void _handleBoost(PropertyListing listing) {
    Navigator.pushNamed(context, '/sponsorship-plans', arguments: listing);
  }
}
