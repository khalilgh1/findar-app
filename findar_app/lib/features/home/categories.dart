import 'package:flutter/material.dart';
import 'package:findar/logic/cubits/home/recent_listings.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const categroiesHeight = 34.0;

class CategoryBar extends StatefulWidget {
  const CategoryBar({super.key});

  @override
  State<CategoryBar> createState() => _CategoryBarState();
}

class _CategoryBarState extends State<CategoryBar> {
  final List<String> categories = [
    "Any",
    "For Sale",
    "For Rent",
    "Commercial",
    "New Constructions",
  ];

  void newfilter() {
    String? listingtype = categories[selectedIndex];

    if (listingtype == 'Any') {
      listingtype = null;
    }
    context.read<RecentCubit>().getRecentListings(listingType: listingtype);
  }

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: categroiesHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;
          return GestureDetector(
            onTap: () => setState(() {
              selectedIndex = index;
              newfilter();
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surface,
                ),
              ),
              child: Center(
                child: Text(
                  categories[index],
                  style: TextStyle(
                    color: isSelected
                        ? theme.colorScheme.surface
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
