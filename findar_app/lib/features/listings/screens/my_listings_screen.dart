import 'package:flutter/material.dart';
import '../../../core/widgets/property_card.dart';
import '../../../core/widgets/segment_control.dart';
import '../../../core/theme/color_schemes.dart';
import '../../../core/widgets/build_bottom_bar.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  String _selectedTab = 'Online';

  // Sample data
  final List<Map<String, dynamic>> _onlineListings = [
    {
      'id': '1',
      'imageUrl': 'https://picsum.photos/seed/luxury1/800/600',
      'title': 'Luxury Villa with Ocean View',
      'location': '123 Ocean Drive, Miami FL',
      'price': '\$1,200,000',
      'beds': 3,
      'baths': 2,
      'sqft': 1800,
      'isSaved': false,
    },
    {
      'id': '2',
      'imageUrl': 'https://images.pexels.com/photos/259588/pexels-photo-259588.jpeg',
      'title': 'Spacious Family Home',
      'location': '456 Maple Avenue, Suburbia USA',
      'price': '\$750,000',
      'beds': 4,
      'baths': 3,
      'sqft': 2200,
      'isSaved': false,
    },
  ];

  final List<Map<String, dynamic>> _offlineListings = [];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: Theme.of(  context).colorScheme.surface,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(  context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon:  Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
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
              size: 40,
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
            color: Theme.of(  context).colorScheme.surface,
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
          Divider(height: 1, color: Theme.of( context).colorScheme.onSurface.withOpacity(0.2)),
          // Listings
          Expanded(
            child: _buildListingsView(),
          ),
        ],
      ),
      // Floating Action Button to add new listing
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle add new listing
          Navigator.pushNamed(context, '/create-listing');
        },
        backgroundColor: theme.colorScheme.primary,
        child: Icon(
          Icons.add,
          size: 40,
        ),
      ),
      bottomNavigationBar: BuildBottomNavBar(index: 2),
    );
  }

  Widget _buildListingsView() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final listings = _selectedTab == 'Online' ? _onlineListings : _offlineListings;

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
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            Text(
              'Add your first property listing',
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(
        top: screenHeight * 0.01,
        bottom: screenHeight * 0.1,
      ),
      itemCount: listings.length,
      itemBuilder: (context, index) {
        final listing = listings[index];
        // UPDATED: Using new PropertyListingCard parameters
        return PropertyListingCard(
          imageUrl: listing['imageUrl'],
          title: listing['title'],
          price: listing['price'],
          location: listing['location'],
          beds: listing['beds'],
          baths: listing['baths'],
          sqft: listing['sqft'],
          isSaved: listing['isSaved'],
          // UPDATED: Show 3-dot menu instead of trailing widget
          showMenu: true,
          onEdit: () => _handleEdit(index),
          onRemove: () => _handleRemove(index),
          onToggleStatus: () => _handleToggleStatus(index),
          menuToggleText: _selectedTab == 'Online' ? 'Make Offline' : 'Make Online',
          // UPDATED: Show boost button in card
          showBoostButton: true,
          onBoost: () => _handleBoost(index),
          onTap: () {
            // Navigate to property details
          },
        );
      },
    );
  }

  // UPDATED: Edit handler
  void _handleEdit(int index) {
    final listing = _selectedTab == 'Online' ? _onlineListings[index] : _offlineListings[index];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit "${listing['title']}"'),
        duration: const Duration(seconds: 2),
      ),
    );
    // Add edit logic here
  }

  // UPDATED: Remove handler
  void _handleRemove(int index) {
    final listing = _selectedTab == 'Online' ? _onlineListings[index] : _offlineListings[index];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Listing'),
        content: Text('Are you sure you want to remove "${listing['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                if (_selectedTab == 'Online') {
                  _onlineListings.removeAt(index);
                } else {
                  _offlineListings.removeAt(index);
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Listing removed')),
              );
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // UPDATED: Toggle online/offline handler
  void _handleToggleStatus(int index) {
    final listing = _selectedTab == 'Online' ? _onlineListings[index] : _offlineListings[index];
    
    setState(() {
      if (_selectedTab == 'Online') {
        _onlineListings.removeAt(index);
        _offlineListings.add(listing);
      } else {
        _offlineListings.removeAt(index);
        _onlineListings.add(listing);
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Moved to ${_selectedTab == 'Online' ? 'Offline' : 'Online'}',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // UPDATED: Boost handler
  void _handleBoost(int index) {
    final listing = _selectedTab == 'Online' ? _onlineListings[index] : _offlineListings[index];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Boost Listing'),
        content: Text('Boost "${listing['title']}" to get more visibility?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${listing['title']} has been boosted!'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Boost'),
          ),
        ],
      ),
    );
  }
}
