import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findar/logic/cubits/search_cubit.dart';
import 'package:findar/core/models/property_listing_model.dart';
import '../../../../core/widgets/appbar_title.dart';
import '../../../../core/widgets/property_card.dart';
import '../../../../core/widgets/sort_and_filter.dart';
import '../../../../core/widgets/progress_button.dart';
import '../../../core/cubits/base_state.dart';

class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({super.key});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  // Sample data - in a real app, this would come from a service/provider
  final List<Map<String, dynamic>> _properties = [
    {
      'id': '1',
      'imageUrl':
          'https://images.pexels.com/photos/206172/pexels-photo-206172.jpeg',
      'title': 'Luxury Villa with Ocean View',
      'price': '\$500,000',
      'location': 'New York, NY',
      'beds': 3,
      'baths': 2,
      'sqft': 1500,
      'isSaved': false,
    },
    {
      'id': '2',
      'imageUrl':
          'https://images.pexels.com/photos/20708166/pexels-photo-20708166.jpeg',
      'title': 'Modern Apartment in the City',
      'price': '\$750,000',
      'location': 'San Francisco, CA',
      'beds': 2,
      'baths': 2,
      'sqft': 1200,
      'isSaved': true,
    },
    {
      'id': '3',
      'imageUrl':
          'https://images.pexels.com/photos/1396132/pexels-photo-1396132.jpeg',
      'title': 'Cozy Cottage in the Suburbs',
      'price': '\$320,000',
      'location': 'Austin, TX',
      'beds': 4,
      'baths': 3,
      'sqft': 2000,
      'isSaved': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Perform search when screen loads
    context.read<SearchCubit>().getFilteredListings(
      minPrice: 0,
      maxPrice: double.infinity,
    );
  }

  // Keep track of locally saved listing ids for optimistic UI updates
  final Set<int> _savedIds = {};

  void _toggleSave(int listingId) async {
    final result = await context.read<SearchCubit>().saveListing(listingId);
    if (result.state) {
      setState(() {
        if (_savedIds.contains(listingId)) {
          _savedIds.remove(listingId);
        } else {
          _savedIds.add(listingId);
        }
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
            size: 30,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const AppbarTitle(title: 'Search Results'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_alt_rounded,
              color: Theme.of(context).colorScheme.onSurface,
              size: 30,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/filtering');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter buttons
          Container(
            color: Theme.of(context).colorScheme.surface,
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenHeight * 0.015,
            ),
            child: Row(
              children: [
                FilterButton(
                  text: 'Sort',
                  icon: Icons.swap_vert,
                  onPressed: () {
                    _showSortBottomSheet(context);
                  },
                ),
                SizedBox(width: screenWidth * 0.03),
                FilterButton(
                  text: 'Filter',
                  icon: Icons.tune,
                  onPressed: () {
                    _showFilterBottomSheet(context);
                  },
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          // Properties list
          Expanded(
            child: BlocBuilder<SearchCubit, Map<String, dynamic>>(
              builder: (context, searchState) {
                if (searchState['state'] == 'loading') {
                  return const Center(child: CircularProgressIndicator());
                }

                if (searchState['state'] == 'error') {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error: ${searchState['message'] ?? 'Unknown error'}',
                        ),
                        SizedBox(height: 16),
                        ProgressButton(
                          label: 'Retry',
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          textColor: Theme.of(context).colorScheme.onPrimary,
                          onPressed: () {
                            context.read<SearchCubit>().getFilteredListings(
                              minPrice: 0,
                              maxPrice: double.infinity,
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }

                final dynamic listData = state['data'];
                final bool useFallback =
                    listData == null || (listData is List && listData.isEmpty);

                if (useFallback) {
                  return _properties.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: EdgeInsets.only(
                            top: screenHeight * 0.01,
                            bottom: screenHeight * 0.02,
                          ),
                          itemCount: _properties.length,
                          itemBuilder: (context, index) {
                            final property = _properties[index];
                            return PropertyListingCard(
                              title: property['title'],
                              imageUrl: property['imageUrl'],
                              price: property['price'],
                              location: property['location'],
                              beds: property['beds'],
                              baths: property['baths'],
                              sqft: property['sqft'],
                              isSaved: property['isSaved'],
                              onSaveToggle: () => _toggleSave(
                                int.tryParse(property['id'].toString()) ?? 0,
                              ),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/property-details',
                                );
                              },
                            );
                          },
                        );
                }

                final listings = (listData as List).cast();
                if (listings.isEmpty) return _buildEmptyState();

                return ListView.builder(
                  padding: EdgeInsets.only(
                    top: screenHeight * 0.01,
                    bottom: screenHeight * 0.02,
                  ),
                  itemCount: listings.length,
                  itemBuilder: (context, index) {
                    final item = listings[index];

                    // item may be PropertyListing
                    String imageUrl = '';
                    if (item is PropertyListing) {
                      imageUrl =
                          (item.image.isNotEmpty &&
                              item.image.startsWith('http'))
                          ? item.image
                          : 'https://via.placeholder.com/600x400';
                    }

                    final title = item is PropertyListing ? item.title : '';
                    final price = item is PropertyListing
                        ? '\$${item.price.toStringAsFixed(0)}'
                        : '';
                    final location = item is PropertyListing
                        ? item.location
                        : '';
                    final beds = item is PropertyListing ? item.bedrooms : 0;
                    final baths = item is PropertyListing ? item.bathrooms : 0;
                    final sqft = 0;
                    final id = item is PropertyListing ? item.id : 0;
                    final isSaved = _savedIds.contains(id);

                    return PropertyListingCard(
                      title: title,
                      imageUrl: imageUrl,
                      price: price,
                      location: location,
                      beds: beds,
                      baths: baths,
                      sqft: sqft,
                      isSaved: isSaved,
                      onSaveToggle: () => _toggleSave(id),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/property-details',
                          arguments: item,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: screenWidth * 0.2,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          SizedBox(height: screenHeight * 0.02),
          Text(
            'No properties found',
            style: TextStyle(
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            'Please try adjusting your search filters.',
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
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
      onTap:
          onTap ??
          () {
            Navigator.pop(context);
            // Apply sort
          },
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(screenWidth * 0.05),
        ),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: EdgeInsets.all(screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filters',
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.04),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        Text(
                          'Filter options would go here',
                          style: TextStyle(fontSize: screenWidth * 0.04),
                        ),
                        // Add filter options
                      ],
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
}
