import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findar/logic/cubits/search_cubit.dart';
import 'package:findar/logic/cubits/sort_cubit.dart';
import 'package:findar/core/models/property_listing_model.dart';
import '../../../../core/widgets/appbar_title.dart';
import '../../../../core/widgets/property_card.dart';
import '../../../../core/widgets/sort_and_filter.dart';
import '../../../../core/widgets/progress_button.dart';
import 'package:findar/l10n/app_localizations.dart';

class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({super.key});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  @override
  void initState() {
    super.initState();
  }

  // Keep track of locally saved listing ids for optimistic UI updates
  final Set<int> _savedIds = {};

  void _toggleSave(int listingId) async {
    final result = await context.read<SearchCubit>().saveListing(listingId);
    if (result.state) {
      setState(() {
        if (_savedIds.contains(listingId)) {
          _savedIds.remove(listingId);
        } else {
          _savedIds.add(listingId);
        }
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    var l10n = AppLocalizations.of(context)!;

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
        title: AppbarTitle(title: l10n.searchResults),
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
                  text: l10n.sort,
                  icon: Icons.swap_vert,
                  onPressed: () {
                    _showSortBottomSheet(context);
                  },
                ),
                SizedBox(width: screenWidth * 0.03),
                FilterButton(
                  text: l10n.filter,
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
            child: BlocBuilder<SearchCubit, Map<String, dynamic>>(
              builder: (context, searchState) {
                if (searchState['state'] == 'loading') {
                  return const Center(child: CircularProgressIndicator());
                }

                if (searchState['state'] == 'error') {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error: ${searchState['message'] ?? 'Unknown error'}',
                        ),
                        SizedBox(height: 16),
                        ProgressButton(
                          label: l10n.retry,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          textColor: Theme.of(context).colorScheme.onPrimary,
                          onPressed: () {
                            context.read<SearchCubit>().getFilteredListings(
                              minPrice: 0,
                              maxPrice: double.infinity,
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }

                //use cubit getters for listings
                final listings =
                    (searchState['data'] as List<PropertyListing>?) ?? const [];
                if (listings.isEmpty) {
                  return _buildEmptyState();
                }
                return ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenHeight * 0.02,
                  ),
                  itemCount: listings.length,
                  separatorBuilder: (context, index) =>
                      SizedBox(height: screenHeight * 0.02),
                  itemBuilder: (context, index) {
                    final listing = listings[index];
                    final isSaved = _savedIds.contains(listing.id);

                    return PropertyListingCard(
                      listing: listing,
                      isSaved: isSaved,
                      onSaveToggle: () => _toggleSave(listing.id),
                    );
                  },
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
    var l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: screenWidth * 0.2,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          SizedBox(height: screenHeight * 0.02),
          Text(
            l10n.noPropertiesFound,
            style: TextStyle(
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            l10n.pleaseTryAdjustingFilters,
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
    final sortCubit = context.read<SortCubit>();

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(screenWidth * 0.05),
        ),
      ),
      builder: (context) {
        return BlocBuilder<SortCubit, SortOption>(
          builder: (context, state) {
            final currentSort = sortCubit.currentSort;

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
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: SortOption.values.map((option) {
                        return _buildSortOption(
                          option.displayName,
                          screenWidth,
                          isSelected: currentSort == option,
                          onTap: () {
                            sortCubit.updateSort(option);
                            Navigator.pop(context);
                          },
                        );
                      }).toList(),
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

  Widget _buildSortOption(
    String title,
    double screenWidth, {
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: screenWidth * 0.04,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Theme.of(context).colorScheme.primary : null,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
          : null,
      onTap:
          onTap ??
          () {
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
