import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findar/logic/cubits/property_details_cubit.dart';
import '../../../core/widgets/progress_button.dart';
import '../widgets/property_image_carousel.dart';
import '../widgets/property_header.dart';
import '../widgets/property_features.dart';
import '../widgets/property_description.dart';
import '../widgets/agent_card.dart';
import '../widgets/similar_properties_list.dart';
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
    // Fetch property details when screen loads
    
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        centerTitle: false,
        title: Text(
          l10n.propertyDetails,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
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
                  ProgressButton(
                    label: l10n.retry,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    textColor: Theme.of(context).colorScheme.onPrimary,
                    onPressed: () {
                      context.read<PropertyDetailsCubit>().fetchPropertyDetails(
                        1,
                      );
                    },
                  ),
                ],
              ),
            );
          }

          final property = state['data'] as Map<dynamic, dynamic>? ?? {};
          final similarProperties = (state['similarProperties'] as List?) ?? [];

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PropertyImageCarousel(
                        images:
                            (property['images'] as List?)?.cast<String>() ??
                            [
                              'assets/find-dar-test1.jpg',
                              'assets/find-dar-test2.jpg',
                              'assets/find-dar-test3.jpg',
                            ],
                      ),
                      const SizedBox(height: 16),
                      PropertyHeader(
                        title: property['title'] ?? 'Modern Family Home',
                        address:
                            property['address'] ??
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
                        description:
                            property['description'] ??
                            'This beautiful and spacious modern family home is located in a quiet, friendly neighborhood.',
                      ),
                      const SizedBox(height: 24),
                      AgentCard(
                        agentName: property['agentName'] ?? 'Ishak Dib',
                        agentCompany:
                            property['agentCompany'] ?? 'Prestige Realty',
                        agentImage:
                            property['agentImage'] ?? 'assets/profile.jpg',
                        agentId:
                            property['agentId'] as String? ?? 'test-user-123',
                      ),
                      const SizedBox(height: 24),
                      if (similarProperties.isNotEmpty)
                        SimilarPropertiesList(
                          properties: List.generate(
                            similarProperties.length,
                            (index) => SimilarProperty(
                              image:
                                  similarProperties[index]['image'] ??
                                  'assets/find-dar-test1.jpg',
                              price: (similarProperties[index]['price'] is double)
                                  ? similarProperties[index]['price']
                                  : (similarProperties[index]['price'] is int)
                                      ? (similarProperties[index]['price'] as int).toDouble()
                                      : 525000.0,
                              address:
                                  similarProperties[index]['address'] ??
                                  '456 Oak St',
                            ),
                          ),
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
