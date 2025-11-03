import 'package:flutter/material.dart';
import '../widgets/property_image_carousel.dart';
import '../widgets/property_header.dart';
import '../widgets/property_features.dart';
import '../widgets/property_description.dart';
import '../widgets/agent_card.dart';
import '../widgets/similar_properties_list.dart';

class PropertyDetailsScreen extends StatelessWidget {
  const PropertyDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        centerTitle: false,
        title:  Text(
          'Property Details',
          style: TextStyle(fontWeight: FontWeight.w600,color: Theme.of( context).colorScheme.onSurface  ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PropertyImageCarousel(
                    images: [
                      'assets/find-dar-test1.jpg',
                      'assets/find-dar-test2.jpg',
                      'assets/find-dar-test3.jpg',
                    ],
                  ),
                  const SizedBox(height: 16),
                  const PropertyHeader(
                    title: 'Modern Family Home',
                    address: '123 Sunshine Avenue, Meadowville',
                    price: '\$550,000',
                  ),
                  const SizedBox(height: 16),

                  const PropertyFeatures(
                    bedrooms: 4,
                    bathrooms: 3,
                    sqft: '2,200 sqft',
                  ),
                  const SizedBox(height: 24),

                  const PropertyDescription(
                    description:
                        'This beautiful and spacious modern family home is located in a quiet, friendly neighborhood. It features an open-concept living area, a gourmet kitchen with high-end appliances, and a large backyard perfect for entertaining. The master suite includes a walk-in closet and a luxurious en-suite bathroom.',
                  ),
                  const SizedBox(height: 24),

                  const AgentCard(
                    agentName: 'Ishak Dib',
                    agentCompany: 'Prestige Realty',
                    agentImage: 'assets/profile.jpg',
                  ),
                  const SizedBox(height: 24),

                  SimilarPropertiesList(
                    properties: const [
                      SimilarProperty(
                        image: 'assets/find-dar-test1.jpg',
                        price: '\$525,000',
                        address: '456 Oak St, Meadowville',
                      ),
                      SimilarProperty(
                        image: 'assets/find-dar-test2.jpg',
                        price: '\$580,000',
                        address: '789 Pine Ln',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
