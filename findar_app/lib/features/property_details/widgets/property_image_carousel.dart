import 'package:flutter/material.dart';


class PropertyImageCarousel extends StatelessWidget {
  final List<String> images;

  const PropertyImageCarousel({
    super.key,
    required this.images,
  });

  @override
  Widget build(BuildContext context) {
    return Container
        (
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.grey.shade100,
      ),
      clipBehavior: Clip.antiAlias,
      child: PageView(
        children: images
            .map(
              (image) => Image.asset(
                image,
                fit: BoxFit.cover,
              ),
            )
            .toList(),
      ),
    );
  }
}
