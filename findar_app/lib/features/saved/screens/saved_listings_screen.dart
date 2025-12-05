import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findar/logic/cubits/saved_listings_cubit.dart';
import 'package:findar/logic/cubits/sort_cubit.dart';
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
  final List<Map<String, dynamic>> _savedProperties = [
    {
      'title': 'Luxury Villa',
      'id': '1',
      'imageUrl':
          'https://images.pexels.com/photos/206172/pexels-photo-206172.jpeg',
      'price': '\$550,000',
      'location': '123 Ocean View Dr, Malibu',
      'beds': 3,
      'baths': 2,
      'sqft': 1800,
      'isSaved': true,
    },
    {
      'title': 'Charming Bungalow',
      'id': '2',
      'imageUrl':
          'https://images.pexels.com/photos/20708166/pexels-photo-20708166.jpeg',
      'price': '\$320,000',
      'location': '456 Maple St, Springfield',
      'beds': 4,
      'baths': 3,
      'sqft': 2200,
      'isSaved': true,
    },
    {
      'title': 'Modern Apartment',
      'id': '3',
      'imageUrl':
          'https://images.pexels.com/photos/4700551/pexels-photo-4700551.jpeg',
      'price': '\$780,000',
      'location': '789 City Center, Apt 12B',
      'beds': 2,
      'baths': 2,
      'sqft': 1100,
      'isSaved': true,
    },
    {
      'title': 'Cozy Cottage',
      'id': '4',
      'imageUrl':
          'https://images.pexels.com/photos/18610869/pexels-photo-18610869.jpeg',
      'price': '\$250,000',
      'location': '101 Forest Ln, Greenwood',
      'beds': 2,
      'baths': 1,
      'sqft': 950,
      'isSaved': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Fetch saved listings when screen loads
    context.read<SavedListingsCubit>().fetchSavedListings();
  }

  void _toggleSave(String propertyId) {
    final colorScheme = Theme.of(context).colorScheme;
    final propertyIndex = _savedProperties.indexWhere(
      (p) => p['id'] == propertyId,
    );

    if (propertyIndex == -1) return; // Property not found

    setState(() {
      _savedProperties[propertyIndex]['isSaved'] =
          !_savedProperties[propertyIndex]['isSaved'];
      if (!_savedProperties[propertyIndex]['isSaved']) {
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
                  _savedProperties[propertyIndex]['isSaved'] = true;
                });
              },
            ),
          ),
        );
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && !_savedProperties[propertyIndex]['isSaved']) {
            setState(() {
              _savedProperties.removeAt(propertyIndex);
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

          final savedListings = (state['data'] as List?)?.isEmpty ?? true
              ? _savedProperties
              : (state['data'] as List?);

          // Apply sorting using SortCubit
          return BlocBuilder<SortCubit, BaseState>(
            builder: (context, sortState) {
              final sortCubit = context.read<SortCubit>();
              final sortedProperties = sortCubit.sortProperties(
                List<Map<String, dynamic>>.from(savedListings!),
              );

              return sortedProperties.isEmpty
                  ? _buildEmptyState()
                  : _buildSavedPropertiesView(
                      MediaQuery.of(context).orientation,
                      sortedProperties,
                    );
            },
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
        return PropertyListingCard(
          title: property['title'],
          imageUrl: property['imageUrl'],
          price: property['price'],
          location: property['location'],
          beds: property['beds'],
          baths: property['baths'],
          sqft: property['sqft'],
          isSaved: property['isSaved'],
          onSaveToggle: () => _toggleSave(property['id']),
          onTap: () {},
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
}
