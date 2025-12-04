import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findar/logic/cubits/profile_cubit.dart';
import 'profile_avatar.dart';
import 'listings.dart';
import 'profile_info.dart';
import '../../../../core/widgets/progress_button.dart';
import '../../../../core/widgets/build_bottom_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch profile when screen loads
    context.read<ProfileCubit>().fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
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
        title: Text(
          'Profile',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/edit-profile');
            },
            child: const Text(
              'Edit',
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ),
        ],
      ),
      body: BlocListener<ProfileCubit, Map<String, dynamic>>(
        listener: (context, state) {
          // Navigate to login when logout is successful (state becomes 'initial' with empty data)
          if (state['state'] == 'initial' && (state['data'] as Map?)?.isEmpty == true && state['message'] != null) {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
          }
        },
        child: BlocBuilder<ProfileCubit, Map<String, dynamic>>(
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
                      context.read<ProfileCubit>().fetchProfile();
                    },
                  ),
                ],
              ),
            );
          }

          final data = state['data'];
          final user = data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
          final username = user['name'] ?? 'null null';
          final email = user['email'] ?? 'null@null.com';
          final myListings = (user['listings'] as List?)?.cast<Map<String, dynamic>>() ??
              [
                {
                  "imagePath": 'assets/find-dar-test1.jpg',
                  "title": 'house 1',
                  "price": '\$127,000',
                },
                {
                  "imagePath": 'assets/find-dar-test1.jpg',
                  "title": 'house 1',
                  "price": '\$127,000',
                },
              ];

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                ProfileAvatar(),
                const SizedBox(height: 10),
                Text(
                  username,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                Text(email, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 25),
                ProfileInfoCard(),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => {
                        Navigator.pushNamed(context, '/my-listings'),
                      },
                      child: Text(
                        'Listings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/create-listing');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Icon(
                        Icons.add,
                        size: 18,
                        color: theme.colorScheme.onPrimary,
                      ),
                      label: Text(
                        'Add New',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                SizedBox(
                  height: 280,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: myListings
                        .map(
                          (listing) => ListingCard(
                            imagePath: listing['imagePath'] ?? 'assets/find-dar-test1.jpg',
                            title: listing['title'] ?? 'house',
                            price: listing['price'] ?? '\$0',
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 30),
                ProgressButton(
                  label: 'Logout',
                  backgroundColor: const Color(0xFFFFEDED),
                  textColor: Colors.red,
                  onPressed: () {
                    context.read<ProfileCubit>().logout();
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
          },
        ),
      ),
      bottomNavigationBar: BuildBottomNavBar(index: 3),
    );
  }
}