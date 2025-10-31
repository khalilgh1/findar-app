import 'package:flutter/material.dart';
import 'profile_avatar.dart';
import 'listings.dart';
import 'profile_info.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    var username = "null null";
    var email = "null@null.com";

    var myListings = [
      {
        "imagePath": 'lib/assets/house1.jpg',
        "title": 'house 1',
        "price": '\$127,000',
      },
      {
        "imagePath": 'lib/assets/house1.jpg',
        "title": 'house 1',
        "price": '\$127,000',
      },
    ];

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Edit',
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            ProfileAvatar(),
            const SizedBox(height: 10),
            Text(
              username,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            Text(email, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 25),
            ProfileInfoCard(),
            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Listings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
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
                        imagePath: listing['imagePath']!,
                        title: listing['title']!,
                        price: listing['price']!,
                      ),
                    )
                    .toList(),
              ),
            ),

            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                'Logout',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFEDED),
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 100,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
