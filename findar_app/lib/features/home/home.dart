import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findar/logic/cubits/home/recent_listings.dart';
import 'package:findar/logic/cubits/home/sponsored_listings.dart';
import 'package:findar/logic/cubits/property_details_cubit.dart';
import 'package:findar/core/widgets/progress_button.dart';
import 'package:findar/features/home/search_bar.dart';
import 'package:findar/features/home/categories.dart';
import 'package:findar/features/home/property.dart';
import 'package:findar/features/home/listings.dart';
import 'package:findar/features/home/sponsored.dart';
import '../../../core/widgets/build_bottom_bar.dart';
import 'package:findar/l10n/app_localizations.dart';

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
            // Only listen if message actually changed and is non-empty
            return previous['message'] != current['message'] && 
                   (current['message'] as String? ?? '').isNotEmpty;
          },
          listener: (context, state) {
            final message = state['message'] as String? ?? '';
            if (message.isEmpty) return;
            
            // Clear any existing snackbars first
            ScaffoldMessenger.of(context).clearSnackBars();
            
            // Check if it's a success or error message
            final isSuccess = message.toLowerCase().contains('successfully');
            final isError = message.toLowerCase().contains('error') ||
                            message.toLowerCase().contains('failed') ||
                            message.toLowerCase().contains('cannot') ||
                            message.toLowerCase().contains('can\'t') ||
                            message.toLowerCase().contains('not saved');
            
            if (isSuccess || isError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  duration: const Duration(seconds: 2),
                  backgroundColor: isSuccess ? Colors.green : Colors.red,
                ),
              );
            }
          },
        ),
        BlocListener<RecentCubit, Map<String, dynamic>>(
          listenWhen: (previous, current) {
            // Only listen if message actually changed and is non-empty
            return previous['message'] != current['message'] && 
                   (current['message'] as String? ?? '').isNotEmpty;
          },
          listener: (context, state) {
            final message = state['message'] as String? ?? '';
            if (message.isEmpty) return;
            
            // Clear any existing snackbars first
            ScaffoldMessenger.of(context).clearSnackBars();
            
            // Check if it's a success or error message
            final isSuccess = message.toLowerCase().contains('successfully');
            final isError = message.toLowerCase().contains('error') ||
                            message.toLowerCase().contains('failed') ||
                            message.toLowerCase().contains('cannot') ||
                            message.toLowerCase().contains('can\'t') ||
                            message.toLowerCase().contains('not saved');
            
            if (isSuccess || isError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  duration: const Duration(seconds: 2),
                  backgroundColor: isSuccess ? Colors.green : Colors.red,
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
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
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
                  Builder(
                    builder: (context) {
                      var l10n = AppLocalizations.of(context);
                      return Text(
                        l10n?.sponsoredProperties ?? 'Sponsored Properties',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      );
                    },
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
                              Builder(
                                builder: (context) {
                                  var l10n = AppLocalizations.of(context);
                                  return ProgressButton(
                                    label: l10n?.retry ?? 'Retry',
                                    backgroundColor: theme.colorScheme.primary,
                                    textColor: theme.colorScheme.onPrimary,
                                    onPressed: () {
                                      context
                                          .read<SponsoredCubit>()
                                          .getSponsoredListings();
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      }

                      final raw = state['data'];
                      final savedIds =
                          state['savedIds'] as Set<int>? ?? <int>{};
                      final l10n = AppLocalizations.of(context)!;

                      final listings = raw is List
                          ? raw
                              .map(
                                (e) => Property.convertListing(
                                  e,
                                  l10n,
                                  bookmarked: savedIds.contains(e.id),
                                ),
                              )
                              .toList()
                          : [];

                      final displayListings = listings;
                      return SizedBox(
                        height: 230,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: displayListings.length,
                          itemBuilder: (context, index) => GestureDetector(
                            onTap: () => {
                              context
                                  .read<PropertyDetailsCubit>()
                                  .fetchPropertyDetails(
                                    displayListings[index].id,
                                  ),
                              Navigator.pushNamed(context, '/property-details'),
                            },
                            child: PropertyCard(
                              property: displayListings[index],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 25),
                  Builder(
                    builder: (context) {
                      var l10n = AppLocalizations.of(context);
                      return Text(
                        l10n?.recentListings ?? 'Recent Listings',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      );
                    },
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
                                  context
                                      .read<RecentCubit>()
                                      .getRecentListings();
                                },
                              ),
                            ],
                          ),
                        );
                      }

                      final recentraw = state['data'];
                      final savedIds =
                          state['savedIds'] as Set<int>? ?? <int>{};
                      final l10n = AppLocalizations.of(context)!;

                      final recentlistings = recentraw is List
                          ? recentraw
                              .map(
                                (e) => Property.convertListing(
                                  e,
                                  l10n,
                                  bookmarked: savedIds.contains(e.id),
                                ),
                              )
                              .toList()
                          : [];

                      final displayRecentListings = recentlistings;

                      return Column(
                        children: displayRecentListings
                            .map(
                              (p) => GestureDetector(
                                onTap: () => {
                                  context
                                      .read<PropertyDetailsCubit>()
                                      .fetchPropertyDetails(p.id),
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
