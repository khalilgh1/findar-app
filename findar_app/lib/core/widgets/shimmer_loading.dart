import 'package:flutter/material.dart';

/// Helper class to get shimmer colors based on theme
class ShimmerColors {
  /// Base color for shimmer placeholders (the main skeleton color)
  static Color baseColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.grey.shade800 : Colors.grey.shade300;
  }

  /// Highlight color for shimmer animation (the moving shine)
  static Color highlightColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.grey.shade700 : Colors.grey.shade100;
  }

  /// Container background color
  static Color containerColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return colorScheme.surface;
  }

  /// Border color for containers
  static Color borderColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Colors.grey.shade700 : Colors.grey.shade300;
  }
}

/// Shimmer effect for loading states
class ShimmerLoading extends StatefulWidget {
  final Widget child;

  const ShimmerLoading({
    super.key,
    required this.child,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;
    final highlightColor = isDark ? Colors.grey.shade600 : Colors.white;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: const [
                0.0,
                0.5,
                1.0,
              ],
              transform: _SlidingGradientTransform(_animation.value),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform(this.slidePercent);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

/// Skeleton for property card loading (Sponsored Listings)
class PropertyCardSkeleton extends StatelessWidget {
  const PropertyCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: ShimmerColors.containerColor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          ShimmerLoading(
            child: Container(
              height: 140,
              decoration: BoxDecoration(
                color: ShimmerColors.baseColor(context),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Line 1
                ShimmerLoading(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 14,
                          decoration: BoxDecoration(
                            color: ShimmerColors.baseColor(context),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Line 2
                ShimmerLoading(
                  child: Row(
                    children: [
                      Container(
                        height: 12,
                        width: 160,
                        decoration: BoxDecoration(
                          color: ShimmerColors.baseColor(context),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Line 3
                ShimmerLoading(
                  child: Row(
                    children: [
                      Container(
                        height: 12,
                        width: 100,
                        decoration: BoxDecoration(
                          color: ShimmerColors.baseColor(context),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton for listing tile loading (Recent Listings)
class ListingTileSkeleton extends StatelessWidget {
  const ListingTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ShimmerColors.containerColor(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Image placeholder
          ShimmerLoading(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: ShimmerColors.baseColor(context),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Line 1
                ShimmerLoading(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 16,
                          decoration: BoxDecoration(
                            color: ShimmerColors.baseColor(context),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Line 2
                ShimmerLoading(
                  child: Row(
                    children: [
                      Container(
                        height: 14,
                        width: 150,
                        decoration: BoxDecoration(
                          color: ShimmerColors.baseColor(context),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // Line 3
                ShimmerLoading(
                  child: Row(
                    children: [
                      Container(
                        height: 14,
                        width: 100,
                        decoration: BoxDecoration(
                          color: ShimmerColors.baseColor(context),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton for grid property card (Saved Listings / My Listings)
class PropertyGridCardSkeleton extends StatelessWidget {
  const PropertyGridCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ShimmerColors.containerColor(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          ShimmerLoading(
            child: Container(
              height: 240,
              decoration: BoxDecoration(
                color: ShimmerColors.baseColor(context),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title line
                ShimmerLoading(
                  child: Container(
                    height: 18,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: ShimmerColors.baseColor(context),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Price line
                ShimmerLoading(
                  child: Container(
                    height: 20,
                    width: 120,
                    decoration: BoxDecoration(
                      color: ShimmerColors.baseColor(context),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Location line
                ShimmerLoading(
                  child: Container(
                    height: 14,
                    width: 140,
                    decoration: BoxDecoration(
                      color: ShimmerColors.baseColor(context),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Property details row
                ShimmerLoading(
                  child: Row(
                    children: [
                      Container(
                        height: 14,
                        width: 80,
                        decoration: BoxDecoration(
                          color: ShimmerColors.baseColor(context),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        height: 14,
                        width: 90,
                        decoration: BoxDecoration(
                          color: ShimmerColors.baseColor(context),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton for property details screen loading
class PropertyDetailsSkeleton extends StatelessWidget {
  const PropertyDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main image placeholder
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: ShimmerColors.baseColor(context),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 24),
            // Title placeholder
            Container(
              height: 24,
              width: double.infinity,
              decoration: BoxDecoration(
                color: ShimmerColors.baseColor(context),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),
            // Address placeholder
            Container(
              height: 16,
              width: 200,
              decoration: BoxDecoration(
                color: ShimmerColors.baseColor(context),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            // Price placeholder
            Container(
              height: 32,
              width: 150,
              decoration: BoxDecoration(
                color: ShimmerColors.baseColor(context),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 24),
            // Features row placeholder
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                3,
                (index) => Column(
                  children: [
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: ShimmerColors.baseColor(context),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 12,
                      width: 60,
                      decoration: BoxDecoration(
                        color: ShimmerColors.baseColor(context),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Description title placeholder
            Container(
              height: 20,
              width: 120,
              decoration: BoxDecoration(
                color: ShimmerColors.baseColor(context),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),
            // Description lines placeholder
            ...List.generate(
              4,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: ShimmerColors.baseColor(context),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Agent card placeholder
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ShimmerColors.containerColor(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ShimmerColors.borderColor(context)),
              ),
              child: Row(
                children: [
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: ShimmerColors.baseColor(context),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 16,
                          width: 120,
                          decoration: BoxDecoration(
                            color: ShimmerColors.baseColor(context),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 14,
                          width: 80,
                          decoration: BoxDecoration(
                            color: ShimmerColors.baseColor(context),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton for user profile screen loading
class UserProfileSkeleton extends StatelessWidget {
  const UserProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            // Avatar placeholder
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: ShimmerColors.baseColor(context),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 10),
            // Name placeholder
            Container(
              height: 20,
              width: 150,
              decoration: BoxDecoration(
                color: ShimmerColors.baseColor(context),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            // Email placeholder
            Container(
              height: 16,
              width: 200,
              decoration: BoxDecoration(
                color: ShimmerColors.baseColor(context),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 25),
            // Profile info card placeholder
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ShimmerColors.containerColor(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ShimmerColors.borderColor(context)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        height: 16,
                        width: 80,
                        decoration: BoxDecoration(
                          color: ShimmerColors.baseColor(context),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        height: 16,
                        width: 120,
                        decoration: BoxDecoration(
                          color: ShimmerColors.baseColor(context),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        height: 16,
                        width: 80,
                        decoration: BoxDecoration(
                          color: ShimmerColors.baseColor(context),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        height: 16,
                        width: 150,
                        decoration: BoxDecoration(
                          color: ShimmerColors.baseColor(context),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Listings title placeholder
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                height: 18,
                width: 100,
                decoration: BoxDecoration(
                  color: ShimmerColors.baseColor(context),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 15),
            // Listings horizontal scroll placeholder
            SizedBox(
              height: 280,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                itemBuilder: (context, index) => Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: ShimmerColors.containerColor(context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image placeholder
                      Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: ShimmerColors.baseColor(context),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 16,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: ShimmerColors.baseColor(context),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 20,
                              width: 100,
                              decoration: BoxDecoration(
                                color: ShimmerColors.baseColor(context),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
