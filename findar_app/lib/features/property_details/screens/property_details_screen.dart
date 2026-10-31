import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findar/logic/cubits/property_details_cubit.dart';
import 'package:findar/logic/cubits/saved_listings_cubit.dart';
import 'package:findar/core/widgets/progress_button.dart';
import 'package:findar/core/widgets/no_internet_widget.dart';
import 'package:findar/core/widgets/shimmer_loading.dart';
import 'package:findar/features/property_details/widgets/property_image_carousel.dart';
import 'package:findar/features/property_details/widgets/property_header.dart';
import 'package:findar/features/property_details/widgets/property_features.dart';
import 'package:findar/features/property_details/widgets/property_description.dart';
import 'package:findar/features/property_details/widgets/agent_card.dart';
import 'package:findar/features/property_details/widgets/report_bottom_sheet.dart';
import 'package:findar/l10n/app_localizations.dart';

/// Helper function to check if an error message indicates a network issue
bool _isNetworkError(String? message) {
  if (message == null) return false;
  final lowerMessage = message.toLowerCase();
  return lowerMessage.contains('internet') ||
      lowerMessage.contains('offline') ||
      lowerMessage.contains('network') ||
      lowerMessage.contains('connection');
}

class PropertyDetailsScreen extends StatefulWidget {
  const PropertyDetailsScreen({super.key});

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Needed for the bookmark state; no-op if already loaded.
    context.read<SavedListingsCubit>().fetchSavedListings();
  }

  void _showReportBottomSheet(BuildContext context, int propertyId) {
    final screenWidth = MediaQuery.of(context).size.width;

    showModalBottomSheet(
      context: context,
      // Lets the sheet move above the keyboard.
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(screenWidth * 0.05),
        ),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: ReportBottomSheet(
            onSubmit: (reason) =>
                context.read<PropertyDetailsCubit>().reportListing(
                      propertyId: propertyId,
                      reason: reason,
                    ),
          ),
        );
      },
    );
  }

  Future<void> _toggleSave(int propertyId) async {
    final saved = context.read<SavedListingsCubit>();
    final result = saved.isSaved(propertyId)
        ? await saved.unsaveListing(propertyId)
        : await saved.saveListing(propertyId);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(result.message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          elevation: 0.5,
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          centerTitle: false,
          title: Builder(
            builder: (context) {
              var l10n = AppLocalizations.of(context);
              return Text(
                l10n?.propertyDetails ?? 'Property Details',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              );
            },
          ),
          actions: [
            BlocBuilder<PropertyDetailsCubit, Map<String, dynamic>>(
              builder: (context, state) {
                final id = state['id'] as int?;
                if (id == null || state['state'] != 'done') {
                  return const SizedBox.shrink();
                }
                final isSaved = context.select<SavedListingsCubit, bool>(
                    (c) => c.isSaved(id));
                return IconButton(
                  icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border),
                  onPressed: () => _toggleSave(id),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<PropertyDetailsCubit, Map<String, dynamic>>(
          builder: (context, state) {
            if (state['state'] == 'loading') {
              return const PropertyDetailsSkeleton();
            }

            if (state['state'] == 'error') {
              final errorMessage = state['message'] as String?;

              // Check if it's a network error
              if (_isNetworkError(errorMessage)) {
                return NoInternetWidget(
                  title: 'Property Unavailable Offline',
                  message:
                      'This property is not available offline. You can only view your own listings and saved properties when offline.',
                  onRetry: () {
                    context.read<PropertyDetailsCubit>().retry();
                  },
                  showRetryButton: true,
                );
              }

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        errorMessage ?? '',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 16),
                    Builder(
                      builder: (context) {
                        var l10n = AppLocalizations.of(context);
                        return ProgressButton(
                          label: l10n?.retry ?? 'Retry',
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          textColor: Theme.of(context).colorScheme.onPrimary,
                          onPressed: () {
                            context.read<PropertyDetailsCubit>().retry();
                          },
                        );
                      },
                    ),
                  ],
                ),
              );
            }

            if (state['state'] == 'notFound') {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    AppLocalizations.of(context)!.listingNotFound,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            if (state['state'] != 'done') {
              return const PropertyDetailsSkeleton();
            }

            final property = state['data'] as Map<dynamic, dynamic>? ?? {};
            final area = (property['area'] as num?)?.toDouble();

            // Extract additional images from pics field
            List<String>? additionalImages;
            if (property['pics'] != null) {
              final pics = property['pics'];
              if (pics is List) {
                additionalImages = pics.map((e) => e.toString()).toList();
              }
            }

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PropertyImageCarousel(
                          image: (property['main_pic'] as String?)
                                      ?.isNotEmpty ==
                                  true
                              ? property['main_pic']
                              : 'https://res.cloudinary.com/da5xjc4dx/image/upload/v1767273156/default_cxkkda.jpg',
                          additionalImages: additionalImages,
                        ),
                        const SizedBox(height: 16),
                        PropertyHeader(
                          title: property['title'] ?? '',
                          address: property['address'] ?? '',
                          price: (property['price'] as num?)?.toDouble() ?? 0,
                        ),
                        const SizedBox(height: 16),
                        PropertyFeatures(
                          bedrooms: property['bedrooms'] ?? 0,
                          bathrooms: property['bathrooms'] ?? 0,
                          sqft: (area != null && area > 0)
                              ? '${area.round()} m²'
                              : '—',
                        ),
                        const SizedBox(height: 24),
                        PropertyDescription(
                          description: property['description'] ?? '',
                        ),
                        const SizedBox(height: 24),
                        AgentCard(
                          agentName: property['owner_name'] ?? 'Owner',
                          agentCompany: property['owner_account_type'] ?? 'Individual',
                          agentImage: property['owner_image'] ?? 'assets/profile.png',
                          agentId: property['owner_id']?.toString() ?? '',
                          agentPhone: property['owner_phone'] as String?,
                        ),
                        const SizedBox(height: 24),
                        _ReportPropertyButton(
                          onPressed: () {
                            _showReportBottomSheet(
                                context, property['id'] as int);
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
    );
  }
}

class _ReportPropertyButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _ReportPropertyButton({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.flag_outlined),
        label: Text(l10n?.reportProperty ?? 'Report Property'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red[700],
          side: BorderSide(color: Colors.red[300]!),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
