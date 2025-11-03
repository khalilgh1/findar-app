import 'package:flutter/material.dart';
import '../../../../core/widgets/appbar_title.dart';
import '../../../../core/widgets/property_card.dart';
import '../../../../core/widgets/sort_and_filter.dart';
import '../../../../core/theme/color_schemes.dart';

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

  void _toggleSave(int index) {
    setState(() {
      _properties[index]['isSaved'] = !_properties[index]['isSaved'];
    });
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
            child: _properties.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: EdgeInsets.only(
                      top: screenHeight * 0.01,
                      bottom: screenHeight * 0.02,
                    ),
                    itemCount: _properties.length,
                    itemBuilder: (context, index) {
                      final property = _properties[index];
                      // NO CHANGES: Search results don't show boost button or menu
                      return PropertyListingCard(
                        title: property['title'],
                        imageUrl: property['imageUrl'],
                        price: property['price'],
                        location: property['location'],
                        beds: property['beds'],
                        baths: property['baths'],
                        sqft: property['sqft'],
                        isSaved: property['isSaved'],
                        onSaveToggle: () => _toggleSave(index),
                        onTap: () {
                          // Navigate to property details
                        },
                        // showBoostButton defaults to false
                        // showMenu defaults to false
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
            color: Theme.of(context).colorScheme.onBackground,
          ),
          SizedBox(height: screenHeight * 0.02),
          Text(
            'No properties found',
            style: TextStyle(
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onBackground,
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
