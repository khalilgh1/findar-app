import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findar/core/models/property_listing_model.dart';
import 'package:findar/logic/cubits/saved_listings_cubit.dart';
import '../../../core/widgets/appbar_title.dart';
import '../../../core/widgets/property_card.dart';
import '../../../core/widgets/progress_button.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/build_bottom_bar.dart';
import 'package:provider/provider.dart';

class SavedListingsScreen extends StatefulWidget {
  const SavedListingsScreen({super.key});

  @override
  State<SavedListingsScreen> createState() => _SavedListingsScreenState();
}

class _SavedListingsScreenState extends State<SavedListingsScreen> {
  final List<Map<String, dynamic>> _savedProperties = [
    {
      'title': 'Luxury Villa',
      'id': 1,
      'description': 'Ocean-view villa with private pool',
      'imageUrl':
          'https://images.pexels.com/photos/206172/pexels-photo-206172.jpeg',
      'price': 550000.0,
      'location': '123 Ocean View Dr, Malibu',
      'beds': 3,
      'baths': 2,
      'propertyType': 'Villa',
      'classification': 'For Sale',
      'isSaved': true,
    },
    {
      'title': 'Charming Bungalow',
      'id': 2,
      'description': 'Family-friendly bungalow with garden',
      'imageUrl':
          'https://images.pexels.com/photos/20708166/pexels-photo-20708166.jpeg',
      'price': 320000.0,
      'location': '456 Maple St, Springfield',
      'beds': 4,
      'baths': 3,
      'propertyType': 'Bungalow',
      'classification': 'For Sale',
      'isSaved': true,
    },
    {
      'title': 'Modern Apartment',
      'id': 3,
      'description': 'City-center apartment with skyline views',
      'imageUrl':
          'https://images.pexels.com/photos/4700551/pexels-photo-4700551.jpeg',
      'price': 780000.0,
      'location': '789 City Center, Apt 12B',
      'beds': 2,
      'baths': 2,
      'propertyType': 'Apartment',
      'classification': 'For Sale',
      'isSaved': true,
    },
    {
      'title': 'Cozy Cottage',
      'id': 4,
      'description': 'Woodland cottage perfect for getaways',
      'imageUrl':
          'https://images.pexels.com/photos/18610869/pexels-photo-18610869.jpeg',
      'price': 250000.0,
      'location': '101 Forest Ln, Greenwood',
      'beds': 2,
      'baths': 1,
      'propertyType': 'Cottage',
      'classification': 'For Sale',
      'isSaved': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Fetch saved listings when screen loads
    context.read<SavedListingsCubit>().fetchSavedListings();
  }

  void _toggleSave(int index) {
    final colorScheme = Theme.of(context).colorScheme;

    setState(() {
      _savedProperties[index]['isSaved'] = !_savedProperties[index]['isSaved'];
      if (!_savedProperties[index]['isSaved']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Removed from saved'),
            backgroundColor: colorScheme.secondary,
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'Undo',
              textColor: colorScheme.primary,
              onPressed: () {
                setState(() {
                  _savedProperties[index]['isSaved'] = true;
                });
              },
            ),
          ),
        );
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && !_savedProperties[index]['isSaved']) {
            setState(() {
              _savedProperties.removeAt(index);
            });
          }
        });
      }
    });
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

          final remoteData = state['data'] as List<dynamic>?;
          final useFallback = remoteData == null || remoteData.isEmpty;
          final listingsToDisplay = useFallback ? _savedProperties : remoteData;

          return listingsToDisplay.isEmpty
              ? _buildEmptyState()
              : _buildSavedPropertiesView(
                  MediaQuery.of(context).orientation,
                  listingsToDisplay,
                  useFallback,
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
    bool isFallbackData,
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
        final bool isSaved = isFallbackData
            ? (property as Map<String, dynamic>)['isSaved'] as bool? ?? true
            : true;
        final VoidCallback? onSaveToggle = isFallbackData
            ? () => _toggleSave(index)
            : null;

        return PropertyListingCard(
          listing: listing,
          isSaved: isSaved,
          onSaveToggle: onSaveToggle,
          onTap: () {},
        );
      },
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
