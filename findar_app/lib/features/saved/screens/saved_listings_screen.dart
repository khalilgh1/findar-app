import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findar/core/models/property_listing_model.dart';
import 'package:findar/logic/cubits/saved_listings_cubit.dart';
import 'package:findar/logic/cubits/sort_cubit.dart';
import 'package:findar/logic/cubits/property_details_cubit.dart';
import '../../../core/widgets/appbar_title.dart';
import '../../../core/widgets/property_card.dart';
import '../../../core/widgets/progress_button.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/build_bottom_bar.dart';
import '../../../core/cubits/base_state.dart';
import 'package:provider/provider.dart';

class SavedListingsScreen extends StatefulWidget {
  const SavedListingsScreen({super.key});

  @override
  State<SavedListingsScreen> createState() => _SavedListingsScreenState();
}

class _SavedListingsScreenState extends State<SavedListingsScreen> {
  // Track listings that are being removed
  final Set<int> _removingListingIds = {};

  @override
  void initState() {
    super.initState();
    // Fetch saved listings when screen loads
    context.read<SavedListingsCubit>().fetchSavedListings();
  }

  void _toggleSave(int listingId) async {
    final colorScheme = Theme.of(context).colorScheme;

    // Mark as removing to change icon color
    setState(() {
      _removingListingIds.add(listingId);
    });

    // Show snackbar immediately
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Removed from saved'),
        backgroundColor: colorScheme.secondary,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Undo',
          textColor: colorScheme.primary,
          onPressed: () {
            // Cancel removal
            setState(() {
              _removingListingIds.remove(listingId);
            });
            // Re-save the listing
            context.read<SavedListingsCubit>().saveListing(listingId);
          },
        ),
      ),
    );

    // Wait for 2 seconds before actually removing
    await Future.delayed(const Duration(seconds: 2));

    // Check if still in removing state (not undone)
    if (mounted && _removingListingIds.contains(listingId)) {
      // Call cubit to unsave the listing
      context.read<SavedListingsCubit>().unsaveListing(listingId);

      setState(() {
        _removingListingIds.remove(listingId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
            size: 30,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const AppbarTitle(title: 'Saved Listings'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.sort,
              color: Theme.of(context).colorScheme.onSurface,
              size: 30,
            ),
            onPressed: () => _showSortBottomSheet(context),
          ),
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
              color: Theme.of(context).colorScheme.onSurface,
              size: 30,
            ),
            onPressed: () {
              themeProvider.toggleTheme(!themeProvider.isDarkMode);
            },
          ),
        ],
      ),
      body: BlocBuilder<SavedListingsCubit, Map<String, dynamic>>(
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
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    textColor: Theme.of(context).colorScheme.onPrimary,
                    onPressed: () {
                      context.read<SavedListingsCubit>().fetchSavedListings();
                    },
                  ),
                ],
              ),
            );
          }

          final listings = state['data'] as List<dynamic>? ?? [];

          return listings.isEmpty
              ? _buildEmptyState()
              : _buildSavedPropertiesView(
                  MediaQuery.of(context).orientation,
                  listings,
                );
        },
      ),
      bottomNavigationBar: BuildBottomNavBar(index: 1),
    );
  }

  // ADDED: GridView in landscape, ListView in portrait
  Widget _buildSavedPropertiesView(
    Orientation orientation,
    List<dynamic> properties,
  ) {
    final screenHeight = MediaQuery.of(context).size.height;

    return ListView.builder(
      padding: EdgeInsets.only(
        top: screenHeight * 0.01,
        bottom: screenHeight * 0.02,
      ),
      itemCount: properties.length,
      itemBuilder: (context, index) {
        final property = properties[index];
        final listing = property is PropertyListing
            ? property
            : _mapToListing(property as Map<String, dynamic>);

        // Check if this listing is being removed
        final isBeingRemoved = _removingListingIds.contains(listing.id);

        return PropertyListingCard(
          listing: listing,
          isSaved: !isBeingRemoved, // Unselect if being removed
          onSaveToggle: () => _toggleSave(listing.id),
          onTap: () {
            context.read<PropertyDetailsCubit>().fetchPropertyDetails(
              listing.id,
            );
            Navigator.pushNamed(context, '/property-details');
          },
        );
      },
    );
  }

  void _showSortBottomSheet(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final sortCubit = context.read<SortCubit>();

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(screenWidth * 0.05),
        ),
      ),
      builder: (context) {
        return BlocBuilder<SortCubit, BaseState>(
          builder: (context, state) {
            final currentSort = sortCubit.currentSort;

            return Container(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sort by',
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: SortOption.values.map((option) {
                        return _buildSortOption(
                          option.displayName,
                          screenWidth,
                          isSelected: currentSort == option,
                          onTap: () {
                            sortCubit.updateSort(option);
                            Navigator.pop(context);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSortOption(
    String title,
    double screenWidth, {
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: screenWidth * 0.04,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Theme.of(context).colorScheme.primary : null,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final screenHeight = MediaQuery.of(context).size.height;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 35,
            color: Theme.of(context).colorScheme.onSecondary,
          ),
          SizedBox(height: screenHeight * 0.02),
          Text(
            'No saved properties',
            style: textTheme.headlineMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            'Save properties to view them here',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSecondary,
            ),
          ),
        ],
      ),
    );
  }

  PropertyListing _mapToListing(Map<String, dynamic> data) {
    return PropertyListing(
      id: _toInt(data['id']),
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      price: _parsePrice(data['price']),
      location: data['location'] as String? ?? '',
      bedrooms: _toInt(data['beds'] ?? data['bedrooms']),
      bathrooms: _toInt(data['baths'] ?? data['bathrooms']),
      classification: data['classification'] as String? ?? 'For Sale',
      propertyType: data['propertyType'] as String? ?? 'Apartment',
      image: (data['image'] ?? data['imageUrl']) as String? ?? '',
      isBoosted: data['isBoosted'] as bool? ?? false,
    );
  }

  double _parsePrice(dynamic price) {
    if (price is num) {
      return price.toDouble();
    }

    if (price is String) {
      final cleaned = price.replaceAll(RegExp(r'[^0-9.]'), '');
      return double.tryParse(cleaned) ?? 0;
    }

    return 0;
  }

  int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is double) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }
}
