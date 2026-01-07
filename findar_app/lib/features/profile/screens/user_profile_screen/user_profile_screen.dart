import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findar/logic/cubits/profile_cubit.dart';
import 'package:findar/features/profile/screens/user_profile_screen/user_profile_avatar.dart';
import 'package:findar/features/profile/screens/profile_screen/listings.dart';
import 'package:findar/features/profile/screens/profile_screen/profile_info.dart';
import 'package:findar/core/widgets/progress_button.dart';
import 'package:findar/core/widgets/shimmer_loading.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch the specific user's profile by their ID
    context.read<ProfileCubit>().fetchUserById(int.parse(widget.userId));
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
      ),
      body: BlocBuilder<ProfileCubit, Map<String, dynamic>>(
        builder: (context, state) {
          if (state['state'] == 'loading') {
            return const UserProfileSkeleton();
          }

          if (state['state'] == 'error') {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state['message'] ?? 'Unknown error'}'),
                  const SizedBox(height: 16),
                  ProgressButton(
                    label: 'Retry',
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    textColor: Theme.of(context).colorScheme.onPrimary,
                    onPressed: () {
                      context.read<ProfileCubit>().fetchUserById(int.parse(widget.userId));
                    },
                  ),
                ],
              ),
            );
          }

          final data = state['data'];
          final user = data is Map
              ? Map<String, dynamic>.from(data)
              : <String, dynamic>{};
          final username = user['name'] ?? 'User Name';
          final email = user['email'] ?? 'user@example.com';
      final phone = user['phone'] ?? 'N/A';
          final profileImageUrl = user['profileImage'] as String?;
          final myListings =
              (user['listings'] as List?)?.cast<Map<String, dynamic>>() ??
              [
                {
                  "imagePath": 'assets/find-dar-test1.jpg',
                  "title": 'house 1',
                  "price": 127000.0,
                },
                {
                  "imagePath": 'assets/find-dar-test1.jpg',
                  "title": 'house 2',
                  "price": 150000.0,
                },
              ];

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                // Avatar without edit button
                UserProfileAvatar(imageUrl: profileImageUrl),
                const SizedBox(height: 10),
                Text(
                  username,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(email, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 25),
                // Profile info card
                ProfileInfoCard(
                  phone: phone,
                  email: email,
                ),
                const SizedBox(height: 30),
                // Listings section (without "Add New" button)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Listings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                SizedBox(
                  height: 280,
                  child: myListings.isEmpty
                      ? Center(
                          child: Text(
                            'No listings yet',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.5,
                              ),
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView(
                          scrollDirection: Axis.horizontal,
                          children: myListings
                              .map(
                                (listing) => ListingCard(
                                  imagePath:
                                      listing['imagePath'] ??
                                      'assets/find-dar-test1.jpg',
                                  title: listing['title'] ?? 'house',
                                  price: (listing['price'] is double) 
                                      ? listing['price'] 
                                      : (listing['price'] is int) 
                                          ? (listing['price'] as int).toDouble()
                                          : 0.0,
                                ),
                              )
                              .toList(),
                        ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }
}
