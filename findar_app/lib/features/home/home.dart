import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findar/logic/cubits/home/recent_listings.dart';
import 'package:findar/logic/cubits/home/sponsored_listings.dart';
import '../../core/widgets/progress_button.dart';
import 'search_bar.dart';
import 'categories.dart';
import 'property.dart';
import 'listings.dart';
import 'sponsored.dart';
import '../../../core/widgets/build_bottom_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch listings when screen loads
    context.read<SponsoredCubit>().getSponsoredListings();
    context.read<RecentCubit>().getRecentListings();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MultiBlocListener(
      listeners: [
        BlocListener<SponsoredCubit, Map<String, dynamic>>(
          listenWhen: (previous, current) {
            return previous['message'] != current['message'];
          },
          listener: (context, state) {
            final message = state['message'] as String? ?? '';
            if (message.isNotEmpty && (message.toLowerCase().contains('saved') || 
                message.toLowerCase().contains('removed'))) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
        ),
        BlocListener<RecentCubit, Map<String, dynamic>>(
          listenWhen: (previous, current) {
            return previous['message'] != current['message'];
          },
          listener: (context, state) {
            final message = state['message'] as String? ?? '';
            if (message.isNotEmpty && (message.toLowerCase().contains('saved') || 
                message.toLowerCase().contains('removed'))) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
        ),
      ],
      child: Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        forceMaterialTransparency: false,
        primary: true,
        toolbarOpacity: 1,
        leading: IconButton(
          icon: Icon(
            Icons.settings,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pushNamed(context, '/settings'),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.person,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
        actionsPadding: EdgeInsets.only(right: 14),
        centerTitle: true,
        title: Text('FinDar'),
        elevation: 0,
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 15),
                SearchBarWidget(),
                SizedBox(height: 15),
                CategoryBar(),
                SizedBox(height: 20),
                Text(
                  "Sponsored Properties",
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 12),
                BlocBuilder<SponsoredCubit, Map<String, dynamic>>(
                  builder: (context, state) {
                    if (state['state'] == 'loading') {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state['state'] == 'error') {
                      return Center(
                        child: Column(
                          children: [
                            Text(
                              'Error: ${state['message'] ?? 'Unknown error'}',
                            ),
                            SizedBox(height: 16),
                            ProgressButton(
                              label: 'Retry',
                              backgroundColor: theme.colorScheme.primary,
                              textColor: theme.colorScheme.onPrimary,
                              onPressed: () {
                                context
                                    .read<SponsoredCubit>()
                                    .getSponsoredListings();
                              },
                            ),
                          ],
                        ),
                      );
                    }

                    final raw = state['data'];
                    final savedIds = state['savedIds'] as Set<int>? ?? <int>{};

                    final listings = raw is List
                        ? raw.map((e) => Property.convertListing(e, bookmarked: savedIds.contains(e.id))).toList()
                        : [];

                    final displayListings = listings;
                    return SizedBox(
                      height: 230,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: displayListings.length,
                        itemBuilder: (context, index) => GestureDetector(
                          onTap: () => {
                            Navigator.pushNamed(context, '/property-details'),
                          },
                          child: PropertyCard(property: displayListings[index]),
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: 25),
                Text(
                  "Recent Listings",
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 15),
                BlocBuilder<RecentCubit, Map<String, dynamic>>(
                  builder: (context, state) {
                    if (state['state'] == 'loading') {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state['state'] == 'error') {
                      return Center(
                        child: Column(
                          children: [
                            Text(
                              'Error: ${state['message'] ?? 'Unknown error'}',
                            ),
                            SizedBox(height: 16),
                            ProgressButton(
                              label: 'Retry',
                              backgroundColor: theme.colorScheme.primary,
                              textColor: theme.colorScheme.onPrimary,
                              onPressed: () {
                                context.read<RecentCubit>().getRecentListings();
                              },
                            ),
                          ],
                        ),
                      );
                    }

                    final recentraw = state['data'];
                    final savedIds = state['savedIds'] as Set<int>? ?? <int>{};

                    final recentlistings = recentraw is List
                        ? recentraw
                              .map((e) => Property.convertListing(e, bookmarked: savedIds.contains(e.id)))
                              .toList()
                        : [];

                    final displayRecentListings = recentlistings;

                    return Column(
                      children: displayRecentListings
                          .map(
                            (p) => GestureDetector(
                              onTap: () => {
                                Navigator.pushNamed(
                                  context,
                                  '/property-details',
                                ),
                              },
                              child: ListingTile(property: p),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BuildBottomNavBar(index: 0),
    ),
    );
  }
}
