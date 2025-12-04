import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findar/logic/cubits/auth_cubit.dart';
import 'package:findar/logic/cubits/create_listing_cubit.dart';
import 'package:findar/logic/cubits/listings_cubit.dart';
import 'package:findar/logic/cubits/search_cubit.dart';
import 'package:findar/logic/cubits/saved_listings_cubit.dart';
import 'package:findar/logic/cubits/property_details_cubit.dart';
import 'package:findar/logic/cubits/my_listings_cubit.dart';
import 'package:findar/logic/cubits/profile_cubit.dart';
import 'package:findar/logic/cubits/settings_cubit.dart';

/// Demo Test Screen to verify all 9 Cubits work correctly
/// 
/// This screen provides interactive buttons to test each cubit
/// and displays the state changes in real-time.
class DemoTestScreen extends StatefulWidget {
  const DemoTestScreen({Key? key}) : super(key: key);

  @override
  State<DemoTestScreen> createState() => _DemoTestScreenState();
}

class _DemoTestScreenState extends State<DemoTestScreen> {
  int _selectedCubitIndex = 0;
  
  final List<String> _cubitNames = [
    'AuthCubit',
    'CreateListingCubit',
    'ListingsCubit',
    'SearchCubit',
    'SavedListingsCubit',
    'PropertyDetailsCubit',
    'MyListingsCubit',
    'ProfileCubit',
    'SettingsCubit',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧪 Cubit Test Dashboard'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tab Navigation
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  _cubitNames.length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(_cubitNames[index]),
                      selected: _selectedCubitIndex == index,
                      onSelected: (_) => setState(() => _selectedCubitIndex = index),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Content based on selected cubit
            _buildCubitTester(_selectedCubitIndex),
          ],
        ),
      ),
    );
  }

  Widget _buildCubitTester(int index) {
    switch (index) {
      case 0:
        return _buildAuthCubitTester();
      case 1:
        return _buildCreateListingCubitTester();
      case 2:
        return _buildListingsCubitTester();
      case 3:
        return _buildSearchCubitTester();
      case 4:
        return _buildSavedListingsCubitTester();
      case 5:
        return _buildPropertyDetailsCubitTester();
      case 6:
        return _buildMyListingsCubitTester();
      case 7:
        return _buildProfileCubitTester();
      case 8:
        return _buildSettingsCubitTester();
      default:
        return const SizedBox.shrink();
    }
  }

  // ============ AuthCubit Tests ============
  Widget _buildAuthCubitTester() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('AuthCubit - Authentication Operations'),
        _buildCubitDisplay<AuthCubit>(),
        _buildTestButton(
          label: 'Register User',
          onPressed: (context) => context.read<AuthCubit>().register(
            name: 'John Doe',
            email: 'john@example.com',
            phone: '+1234567890',
            password: 'password123',
            accountType: 'individual',
          ),
        ),
        _buildTestButton(
          label: 'Login',
          onPressed: (context) => context.read<AuthCubit>().login(
            email: 'test@example.com',
            password: 'password123',
          ),
        ),
        _buildTestButton(
          label: 'Get Profile',
          onPressed: (context) => context.read<AuthCubit>().getProfile(),
        ),
        _buildTestButton(
          label: 'Update Profile',
          onPressed: (context) => context.read<AuthCubit>().updateProfile(
            name: 'Updated Name',
            phone: '+9876543210',
          ),
        ),
        _buildTestButton(
          label: 'Logout',
          onPressed: (context) => context.read<AuthCubit>().logout(),
        ),
      ],
    );
  }

  // ============ CreateListingCubit Tests ============
  Widget _buildCreateListingCubitTester() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('CreateListingCubit - Create/Update/Delete Listings'),
        _buildCubitDisplay<CreateListingCubit>(),
        _buildTestButton(
          label: 'Create Listing',
          onPressed: (context) => context.read<CreateListingCubit>().createListing(
            title: 'Beautiful Apartment',
            description: 'Modern 2-bedroom apartment',
            price: 500.0,
            location: 'Downtown',
            bedrooms: 2,
            bathrooms: 1,
            classification: 'apartment',
            propertyType: 'rent',
          ),
        ),
        _buildTestButton(
          label: 'Update Listing',
          onPressed: (context) => context.read<CreateListingCubit>().updateListing(
            1,
            title: 'Updated Title',
            price: 550.0,
            location: 'Uptown',
          ),
        ),
        _buildTestButton(
          label: 'Delete Listing',
          onPressed: (context) => context.read<CreateListingCubit>().deleteListing(1),
        ),
      ],
    );
  }

  // ============ ListingsCubit Tests ============
  Widget _buildListingsCubitTester() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('ListingsCubit - Fetch Listings with Filters'),
        _buildCubitDisplay<ListingsCubit>(),
        _buildTestButton(
          label: 'Fetch All Listings',
          onPressed: (context) => context.read<ListingsCubit>().fetchListings(),
        ),
        _buildTestButton(
          label: 'Filter by Location (Downtown)',
          onPressed: (context) => context.read<ListingsCubit>().fetchListings(
            location: 'Downtown',
          ),
        ),
        _buildTestButton(
          label: 'Filter by Price (400-600)',
          onPressed: (context) => context.read<ListingsCubit>().fetchListings(
            minPrice: 400,
            maxPrice: 600,
          ),
        ),
      ],
    );
  }

  // ============ SearchCubit Tests ============
  Widget _buildSearchCubitTester() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('SearchCubit - Advanced Search'),
        _buildCubitDisplay<SearchCubit>(),
        _buildTestButton(
          label: 'Search "apartment"',
          onPressed: (context) => context.read<SearchCubit>().search(query: 'apartment'),
        ),
        _buildTestButton(
          label: 'Get Search Suggestions',
          onPressed: (context) => context.read<SearchCubit>().getSearchSuggestions(),
        ),
        _buildTestButton(
          label: 'Get Filter Options',
          onPressed: (context) => context.read<SearchCubit>().getFilterOptions(),
        ),
        _buildTestButton(
          label: 'Save Filter',
          onPressed: (context) => context.read<SearchCubit>().saveFilter(
            name: 'Budget Apartments',
            filters: {'maxPrice': 500},
          ),
        ),
      ],
    );
  }

  // ============ SavedListingsCubit Tests ============
  Widget _buildSavedListingsCubitTester() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('SavedListingsCubit - Manage Saved Listings'),
        _buildCubitDisplay<SavedListingsCubit>(),
        _buildTestButton(
          label: 'Fetch Saved Listings',
          onPressed: (context) => context.read<SavedListingsCubit>().fetchSavedListings(),
        ),
        _buildTestButton(
          label: 'Save Listing (ID: 1)',
          onPressed: (context) => context.read<SavedListingsCubit>().saveListing(1),
        ),
        _buildTestButton(
          label: 'Unsave Listing (ID: 1)',
          onPressed: (context) => context.read<SavedListingsCubit>().unsaveListing(1),
        ),
        _buildTestButton(
          label: 'Get Saved Count',
          onPressed: (context) => context.read<SavedListingsCubit>().getSavedCount(),
        ),
        _buildTestButton(
          label: 'Clear All Saved',
          onPressed: (context) => context.read<SavedListingsCubit>().clearAllSavedListings(),
        ),
      ],
    );
  }

  // ============ PropertyDetailsCubit Tests ============
  Widget _buildPropertyDetailsCubitTester() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('PropertyDetailsCubit - Property Details & Actions'),
        _buildCubitDisplay<PropertyDetailsCubit>(),
        _buildTestButton(
          label: 'Fetch Property Details',
          onPressed: (context) => context.read<PropertyDetailsCubit>().fetchPropertyDetails(1),
        ),
        _buildTestButton(
          label: 'Toggle Save Property',
          onPressed: (context) => context.read<PropertyDetailsCubit>().toggleSaveListing(1),
        ),
        _buildTestButton(
          label: 'Report Property',
          onPressed: (context) => context.read<PropertyDetailsCubit>().reportListing(
            propertyId: 1,
            reason: 'Inappropriate content',
          ),
        ),
        _buildTestButton(
          label: 'Get Similar Properties',
          onPressed: (context) => context.read<PropertyDetailsCubit>().getSimilarProperties(1),
        ),
      ],
    );
  }

  // ============ MyListingsCubit Tests ============
  Widget _buildMyListingsCubitTester() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('MyListingsCubit - User\'s Listings Management'),
        _buildCubitDisplay<MyListingsCubit>(),
        _buildTestButton(
          label: 'Fetch My Listings',
          onPressed: (context) => context.read<MyListingsCubit>().fetchMyListings(),
        ),
        _buildTestButton(
          label: 'Update My Listing',
          onPressed: (context) => context.read<MyListingsCubit>().updateListing(
            1,
            title: 'Updated Listing',
            price: 600.0,
          ),
        ),
        _buildTestButton(
          label: 'Delete My Listing',
          onPressed: (context) => context.read<MyListingsCubit>().deleteListing(1),
        ),
        _buildTestButton(
          label: 'Toggle Listing Status',
          onPressed: (context) => context.read<MyListingsCubit>().toggleListingStatus(1),
        ),
      ],
    );
  }

  // ============ ProfileCubit Tests ============
  Widget _buildProfileCubitTester() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('ProfileCubit - User Profile Management'),
        _buildCubitDisplay<ProfileCubit>(),
        _buildTestButton(
          label: 'Fetch Profile',
          onPressed: (context) => context.read<ProfileCubit>().fetchProfile(),
        ),
        _buildTestButton(
          label: 'Update Profile',
          onPressed: (context) => context.read<ProfileCubit>().updateProfile(
            name: 'New Name',
            phone: '+1234567890',
          ),
        ),
        _buildTestButton(
          label: 'Get User Stats',
          onPressed: (context) => context.read<ProfileCubit>().getUserStats(),
        ),
        _buildTestButton(
          label: 'Verify Email',
          onPressed: (context) => context.read<ProfileCubit>().verifyEmail(
            'user@example.com',
          ),
        ),
        _buildTestButton(
          label: 'Change Password',
          onPressed: (context) => context.read<ProfileCubit>().changePassword(
            currentPassword: 'old123',
            newPassword: 'new456',
            confirmPassword: 'new456',
          ),
        ),
        _buildTestButton(
          label: 'Logout',
          onPressed: (context) => context.read<ProfileCubit>().logout(),
        ),
      ],
    );
  }

  // ============ SettingsCubit Tests ============
  Widget _buildSettingsCubitTester() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('SettingsCubit - App Settings'),
        _buildCubitDisplay<SettingsCubit>(),
        _buildTestButton(
          label: 'Toggle Dark Mode',
          onPressed: (context) => context.read<SettingsCubit>().toggleDarkMode(),
        ),
        _buildTestButton(
          label: 'Change Language (FR)',
          onPressed: (context) => context.read<SettingsCubit>().changeLanguage('fr'),
        ),
        _buildTestButton(
          label: 'Toggle Notifications',
          onPressed: (context) => context.read<SettingsCubit>().toggleNotifications(),
        ),
        _buildTestButton(
          label: 'Toggle Email Notifications',
          onPressed: (context) => context.read<SettingsCubit>().toggleEmailNotifications(),
        ),
        _buildTestButton(
          label: 'Toggle Push Notifications',
          onPressed: (context) => context.read<SettingsCubit>().togglePushNotifications(),
        ),
        _buildTestButton(
          label: 'Toggle Location Services',
          onPressed: (context) => context.read<SettingsCubit>().toggleLocationServices(),
        ),
        _buildTestButton(
          label: 'Toggle Auto Play',
          onPressed: (context) => context.read<SettingsCubit>().toggleAutoPlay(),
        ),
      ],
    );
  }

  // ============ Helper Widgets ============
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCubitDisplay<T extends Cubit<Map<String, dynamic>>>() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: BlocBuilder<T, Map<String, dynamic>>(
        builder: (context, state) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'State:',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 8),
                _buildStateChip(state['state'] ?? 'unknown'),
                const SizedBox(height: 8),
                if (state['message'] != null && state['message'].isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Message: ${state['message']}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                if (state['data'] != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Data: ${_truncateString(state['data'].toString())}',
                        style: const TextStyle(fontSize: 12),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStateChip(String state) {
    Color bgColor;
    switch (state) {
      case 'loading':
        bgColor = Colors.blue.shade100;
        break;
      case 'done':
        bgColor = Colors.green.shade100;
        break;
      case 'error':
        bgColor = Colors.red.shade100;
        break;
      default:
        bgColor = Colors.grey.shade100;
    }
    
    return Chip(
      label: Text(state.toUpperCase()),
      backgroundColor: bgColor,
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildTestButton({
    required String label,
    required Function(BuildContext context) onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => onPressed(context),
          child: Text(label),
        ),
      ),
    );
  }

  String _truncateString(String str) {
    if (str.length > 100) {
      return '${str.substring(0, 100)}...';
    }
    return str;
  }
}
