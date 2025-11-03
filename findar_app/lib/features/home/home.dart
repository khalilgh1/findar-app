import 'package:flutter/material.dart';
// import '../../core/widgets/appbar.dart';
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
  final sponsored = [
    Property(
      image: "assets/find-dar-test1.jpg",
      price: "\$1,200,000",
      address: "123 Luxury Ave, Beverly Hills, CA",
      details: "4 Bed | 3 Bath | 2,500 sqft",
    ),
    Property(
      image: "assets/find-dar-test2.jpg",
      price: "\$850,000",
      address: "456 Suburb Rd, Austin, TX",
      details: "3 Bed | 2 Bath | 2,200 sqft",
    ),
    Property(
      image: "assets/find-dar-test3.jpg",
      price: "\$980,000",
      address: "101 Garden Ln, San Francisco, CA",
      details: "3 Bed | 2 Bath | 2,100 sqft",
    ),
  ];

  final recent = [
    Property(
      image: "assets/find-dar-test1.jpg",
      price: "\$1,200,000",
      address: "123 Luxury Ave, Beverly Hills, CA",
      details: "4 Bed | 3 Bath | 2,500 sqft",
    ),
    Property(
      image: "assets/find-dar-test2.jpg",
      price: "\$850,000",
      address: "456 Suburb Rd, Austin, TX",
      details: "3 Bed | 2 Bath | 2,200 sqft",
    ),
    Property(
      image: "assets/find-dar-test3.jpg",
      price: "\$980,000",
      address: "101 Garden Ln, San Francisco, CA",
      details: "3 Bed | 2 Bath | 2,100 sqft",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
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
      body: SingleChildScrollView(
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
              SizedBox(
                height: 230,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: sponsored.length,
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: () => {
                      Navigator.pushNamed(context, '/property-details'),
                    },
                    child: PropertyCard(property: sponsored[index]),
                  ),
                ),
              ),
              SizedBox(height: 25),
              Text(
                "Recent Listings",
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 15),
              Column(
                children: recent
                    .map(
                      (p) => GestureDetector(
                        onTap: () => {
                          Navigator.pushNamed(context, '/property-details'),
                        },
                        child: ListingTile(property: p),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BuildBottomNavBar(index: 0),
    );
  }
}
