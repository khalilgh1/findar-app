import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findar/logic/cubits/home/recent_listings.dart';
import 'package:findar/logic/cubits/home/sponsored_listings.dart';
import 'package:findar/logic/cubits/property_details_cubit.dart';
import 'package:findar/core/widgets/progress_button.dart';
import 'package:findar/core/widgets/shimmer_loading.dart';
import 'package:findar/core/widgets/no_internet_widget.dart';
import 'package:findar/features/home/search_bar.dart';
import 'package:findar/features/home/categories.dart';
import 'package:findar/features/home/property.dart';
import 'package:findar/features/home/listings.dart';
import 'package:findar/features/home/sponsored.dart';
import '../../../core/widgets/build_bottom_bar.dart';
import 'package:findar/l10n/app_localizations.dart';
import 'package:findar/core/di/service_locator.dart';
import 'package:findar/core/repositories/abstract_listing_repo.dart';
import 'package:findar/core/repositories/composite_listing_repo.dart';

/// Helper function to check if an error message indicates a network issue
bool _isNetworkError(String? message) {
  if (message == null) return false;
  final lowerMessage = message.toLowerCase();
  return lowerMessage.contains('internet') ||
      lowerMessage.contains('offline') ||
      lowerMessage.contains('network') ||
      lowerMessage.contains('connection');
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Sync local database with remote data once per session
    _syncOncePerSession();
    // Fetch listings when screen loads
    context.read<SponsoredCubit>().getSponsoredListings();
    context.read<RecentCubit>().getRecentListings();
  }

  Future<void> _syncOncePerSession() async {
    final repo = getIt<ListingRepository>();
    if (repo is CompositeListingRepository) {
      await repo.syncOncePerSession();
    }
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
          child: RefreshIndicator(
            onRefresh: () async {
              // Refresh both sponsored and recent listings with forceRefresh
              await Future.wait([
                context.read<SponsoredCubit>().getSponsoredListings(forceRefresh: true),
                context.read<RecentCubit>().getRecentListings(forceRefresh: true),
              ]);
            },
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
                          return SizedBox(
                            height: 250,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: 3,
                              itemBuilder: (context, index) =>
                                  const PropertyCardSkeleton(),
                            ),
                          );
                        }
                        if (state['state'] == 'error') {
                          final errorMessage = state['message'] as String?;

                          // Check if it's a network error
                          if (_isNetworkError(errorMessage)) {
                            return NoInternetBanner(
                              message: 'Sponsored listings unavailable offline',
                              onRetry: () {
                                context
                                    .read<SponsoredCubit>()
                                    .getSponsoredListings(forceRefresh: true);
                              },
                            );
                          }

                          return Center(
                            child: Column(
                              children: [
                                Text(
                                  'Error: ${errorMessage ?? 'Unknown error'}',
                                ),
                                SizedBox(height: 16),
                                Builder(
                                  builder: (context) {
                                    var l10n = AppLocalizations.of(context);
                                    return ProgressButton(
                                      label: l10n?.retry ?? 'Retry',
                                      backgroundColor:
                                          theme.colorScheme.primary,
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
                                Navigator.pushNamed(
                                    context, '/property-details'),
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
                          return Column(
                            children: List.generate(
                              5,
                              (index) => const ListingTileSkeleton(),
                            ),
                          );
                        }
                        if (state['state'] == 'error') {
                          final errorMessage = state['message'] as String?;

                          // Check if it's a network error
                          if (_isNetworkError(errorMessage)) {
                            return NoInternetWidget(
                              title: 'No Internet Connection',
                              message:
                                  'Recent listings are not available offline. Please connect to the internet to browse listings.',
                              onRetry: () {
                                context.read<RecentCubit>().getRecentListings();
                              },
                            );
                          }

                          return Center(
                            child: Column(
                              children: [
                                Text(
                                  'Error: ${errorMessage ?? 'Unknown error'}',
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

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: displayRecentListings.length,
                          itemBuilder: (context, index) {
                            print('building recent listing index $index');
                            final p = displayRecentListings[index];
                            return GestureDetector(
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
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: BuildBottomNavBar(index: 0),
      ),
    );
  }
}
