import 'package:flutter/material.dart';
import '../../../core/widgets/appbar_title.dart';
import '../../../core/widgets/property_card.dart';
import '../../../core/theme/theme_provider.dart';
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
      'imageUrl': 'https://images.pexels.com/photos/206172/pexels-photo-206172.jpeg',
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
      'imageUrl': 'https://images.pexels.com/photos/20708166/pexels-photo-20708166.jpeg',
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
      'imageUrl': 'https://images.pexels.com/photos/4700551/pexels-photo-4700551.jpeg',
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
      'imageUrl': 'https://images.pexels.com/photos/18610869/pexels-photo-18610869.jpeg',
      'price': '\$250,000',
      'location': '101 Forest Ln, Greenwood',
      'beds': 2,
      'baths': 1,
      'sqft': 950,
      'isSaved': true,
    },
  ];

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
    final theme = Theme.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final orientation = MediaQuery.of(context).orientation; // ADDED

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(  context).colorScheme.onSurface ,
            size: 30,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const AppbarTitle(title: 'Saved Listings'),
        actions: [
          IconButton(
            icon: Icon(
              theme.brightness == Brightness.light
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
              color: Theme.of(context).colorScheme.onSurface,
              size: 30,
            ),
            onPressed: () {
              
              
            },
          ),
        ],
      ),
      body: _savedProperties.isEmpty
          ? _buildEmptyState()
          : _buildSavedPropertiesView(orientation), // UPDATED
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // ADDED: GridView in landscape, ListView in portrait
  Widget _buildSavedPropertiesView(Orientation orientation) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    

    return ListView.builder(
      padding: EdgeInsets.only(
        top: screenHeight * 0.01,
        bottom: screenHeight * 0.02,
      ),
      itemCount: _savedProperties.length,
      itemBuilder: (context, index) {
        final property = _savedProperties[index];
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
          onTap: () {},
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
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

  Widget _buildBottomNavBar() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSecondary,
        currentIndex: 1,
        elevation: 0,
        iconSize: screenWidth * 0.06,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
            
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/saved-listings');
              break;
            case 2:
              Navigator.pushNamed(context, '/create-listing');
              break;
            case 3:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }
}
