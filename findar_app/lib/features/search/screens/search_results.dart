import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findar/logic/cubits/search_cubit.dart';
import 'package:findar/core/models/property_listing_model.dart';
import '../../../../core/widgets/appbar_title.dart';
import '../../../../core/widgets/property_card.dart';
import '../../../../core/widgets/sort_and_filter.dart';
import '../../../../core/widgets/progress_button.dart';

class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({super.key});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  @override
  void initState() {
    super.initState();
    // Perform search when screen loads
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

                //use cubit getters for listings
                final listings =
                    (state['data'] as List<PropertyListing>?) ?? const [];
                if (listings.isEmpty) {
                  return _buildEmptyState();
                }
                return ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenHeight * 0.02,
                  ),
                  itemCount: listings.length,
                  separatorBuilder: (context, index) =>
                      SizedBox(height: screenHeight * 0.02),
                  itemBuilder: (context, index) {
                    final listing = listings[index];
                    final isSaved = _savedIds.contains(listing.id);

                    return PropertyListingCard(
                      listing: listing,
                      isSaved: isSaved,
                      onSaveToggle: () => _toggleSave(listing.id),
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

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(screenWidth * 0.05),
        ),
      ),
      builder: (context) {
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
              _buildSortOption('Price: Low to High', screenWidth),
              _buildSortOption('Price: High to Low', screenWidth),
              _buildSortOption('Newest', screenWidth),
              _buildSortOption('Most Popular', screenWidth),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String title, double screenWidth) {
    return ListTile(
      title: Text(title, style: TextStyle(fontSize: screenWidth * 0.04)),
      onTap: () {
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
