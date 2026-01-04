import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findar/logic/cubits/property_details_cubit.dart';
import 'package:findar/core/widgets/progress_button.dart';
import 'package:findar/features/property_details/widgets/property_image_carousel.dart';
import 'package:findar/features/property_details/widgets/property_header.dart';
import 'package:findar/features/property_details/widgets/property_features.dart';
import 'package:findar/features/property_details/widgets/property_description.dart';
import 'package:findar/features/property_details/widgets/agent_card.dart';
import 'package:findar/features/property_details/widgets/similar_properties_list.dart';
import 'package:findar/features/property_details/widgets/report_bottom_sheet.dart';
import 'package:findar/l10n/app_localizations.dart';

class PropertyDetailsScreen extends StatefulWidget {
  const PropertyDetailsScreen({super.key});

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  @override
  void initState() {
    super.initState();
  }

  void _showReportBottomSheet(BuildContext context, int propertyId) {
    final screenWidth = MediaQuery.of(context).size.width;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(screenWidth * 0.05),
        ),
      ),
      builder: (sheetContext) {
        return ReportBottomSheet(
          propertyId: propertyId.toString(),
          onReasonSelected: (reason) {
            context.read<PropertyDetailsCubit>().reportListing(
                  propertyId: propertyId,
                  reason: reason,
                );
          },
        );
      },
    );
  }

  void _handleReportStateChange(
      BuildContext context, Map<String, dynamic> state) {
    final reportState = state['reportState'];

    if (reportState == 'error') {
      final message = state['message'] as String?;
      if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PropertyDetailsCubit, Map<String, dynamic>>(
      listener: _handleReportStateChange,
      child: Scaffold(
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
                final isSaved =
                    (state['data'] as Map?)?.containsKey('isSaved') ?? false;
                return IconButton(
                  icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border),
                  onPressed: () {
                    context.read<PropertyDetailsCubit>().toggleSaveListing(1);
                  },
                );
              },
            ),
            IconButton(icon: const Icon(Icons.share), onPressed: () {}),
          ],
        ),
        body: BlocBuilder<PropertyDetailsCubit, Map<String, dynamic>>(
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
                    Builder(
                      builder: (context) {
                        var l10n = AppLocalizations.of(context);
                        return ProgressButton(
                          label: l10n?.retry ?? 'Retry',
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          textColor: Theme.of(context).colorScheme.onPrimary,
                          onPressed: () {
                            context
                                .read<PropertyDetailsCubit>()
                                .fetchPropertyDetails(
                                  1,
                                );
                          },
                        );
                      },
                    ),
                  ],
                ),
              );
            }

            final property = state['data'] as Map<dynamic, dynamic>? ?? {};
            final similarProperties =
                (state['similarProperties'] as List?) ?? [];

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
                          image: property['main_pic'] ??
                              property['image'] ??
                              'https://res.cloudinary.com/da5xjc4dx/image/upload/v1767273156/default_cxkkda.jpg',
                          additionalImages: additionalImages,
                        ),
                        const SizedBox(height: 16),
                        PropertyHeader(
                          title: property['title'] ?? 'Modern Family Home',
                          address: property['address'] ??
                              '123 Sunshine Avenue, Meadowville',
                          price: (property['price'] is double)
                              ? property['price']
                              : (property['price'] is int)
                                  ? (property['price'] as int).toDouble()
                                  : 550000.0,
                        ),
                        const SizedBox(height: 16),
                        PropertyFeatures(
                          bedrooms: property['bedrooms'] ?? 4,
                          bathrooms: property['bathrooms'] ?? 3,
                          sqft: property['sqft'] ?? '2,200 sqft',
                        ),
                        const SizedBox(height: 24),
                        PropertyDescription(
                          description: property['description'] ??
                              'This beautiful and spacious modern family home is located in a quiet, friendly neighborhood.',
                        ),
                        const SizedBox(height: 24),
                        AgentCard(
                          agentName: property['agentName'] ?? 'Ishak Dib',
                          agentCompany:
                              property['agentCompany'] ?? 'Prestige Realty',
                          agentImage:
                              property['agentImage'] ?? 'assets/profile.png',
                          agentId:
                              property['agentId'] as String? ?? 'test-user-123',
                        ),
                        const SizedBox(height: 24),
                        if (similarProperties.isNotEmpty)
                          SimilarPropertiesList(
                            properties: List.generate(
                              similarProperties.length,
                              (index) => SimilarProperty(
                                image: similarProperties[index]['image'] ??
                                    'assets/find-dar-test1.jpg',
                                price: (similarProperties[index]['price']
                                        is double)
                                    ? similarProperties[index]['price']
                                    : (similarProperties[index]['price'] is int)
                                        ? (similarProperties[index]['price']
                                                as int)
                                            .toDouble()
                                        : 525000.0,
                                address: similarProperties[index]['address'] ??
                                    '456 Oak St',
                              ),
                            ),
                          ),
                        const SizedBox(height: 24),
                        _ReportPropertyButton(
                          onPressed: () {
                            final propertyId = property['id'] as int? ?? 1;
                            _showReportBottomSheet(context, propertyId);
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
