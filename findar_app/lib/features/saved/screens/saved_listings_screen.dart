import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findar/core/models/property_listing_model.dart';
import 'package:findar/logic/cubits/saved_listings_cubit.dart';
import 'package:findar/logic/cubits/property_details_cubit.dart';
import 'package:findar/core/widgets/appbar_title.dart';
import 'package:findar/core/widgets/property_card.dart';
import 'package:findar/core/widgets/progress_button.dart';
import 'package:findar/core/widgets/no_internet_widget.dart';
import 'package:findar/core/theme/theme_provider.dart';
import 'package:findar/core/widgets/build_bottom_bar.dart';
import 'package:findar/core/widgets/shimmer_loading.dart';
import 'package:findar/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

/// Helper function to check if an error message indicates a network issue
bool _isNetworkError(String? message) {
  if (message == null) return false;
  final lowerMessage = message.toLowerCase();
  return lowerMessage.contains('internet') ||
      lowerMessage.contains('offline') ||
      lowerMessage.contains('network') ||
      lowerMessage.contains('connection');
}

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

    // Get localization
    var l10n = AppLocalizations.of(context);

    // Show snackbar immediately
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n?.removedFromSaved ?? 'Removed from Saved'),
        backgroundColor: colorScheme.secondary,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: l10n?.undo ?? 'Undo',
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
        title: Builder(
          builder: (context) {
            var l10n = AppLocalizations.of(context)!;
            return AppbarTitle(title: l10n.savedListings);
          },
        ),
        actions: [
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

            // Note: Saved listings should work offline, but if there's still a network error
            // (e.g., during save/unsave), show appropriate message
            if (_isNetworkError(errorMessage)) {
              return NoInternetWidget(
                title: 'Connection Issue',
                message:
                    'Your saved listings are being loaded from local storage. Some features may be limited.',
                onRetry: () {
                  context.read<SavedListingsCubit>().fetchSavedListings();
                },
              );
            }

            return Builder(
              builder: (context) {
                var l10n = AppLocalizations.of(context)!;
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: ${errorMessage ?? 'Unknown error'}'),
                      SizedBox(height: 16),
                      ProgressButton(
                        label: l10n.retry,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        textColor: Theme.of(context).colorScheme.onPrimary,
                        onPressed: () {
                          context
                              .read<SavedListingsCubit>()
                              .fetchSavedListings();
                        },
                      ),
                    ],
                  ),
                );
              },
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

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final screenHeight = MediaQuery.of(context).size.height;

    return Builder(
      builder: (context) {
        var l10n = AppLocalizations.of(context)!;
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
                l10n.noSavedProperties,
                style: textTheme.headlineMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                l10n.savePropertiesToViewHere,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSecondary,
                ),
              ),
            ],
          ),
        );
      },
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
