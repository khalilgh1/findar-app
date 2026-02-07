import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

const String _kDefaultImageUrl =
    'https://res.cloudinary.com/da5xjc4dx/image/upload/v1767273156/default_cxkkda.jpg';

String _imageOrDefault(String? img) {
  if (img == null) return _kDefaultImageUrl;
  final s = img.trim();
  if (s.isEmpty || s.toLowerCase() == 'null') return _kDefaultImageUrl;
  return s;
}

class PropertyImageCarousel extends StatefulWidget {
  final String image;
  final List<String>? additionalImages;

  const PropertyImageCarousel({
    super.key,
    required this.image,
    this.additionalImages,
  });

  @override
  State<PropertyImageCarousel> createState() => _PropertyImageCarouselState();
}

class _PropertyImageCarouselState extends State<PropertyImageCarousel> {
  int _currentIndex = 0;
  late PageController _pageController;

  List<String> get _allImages {
    final List<String> images = [_imageOrDefault(widget.image)];
    if (widget.additionalImages != null) {
      for (final img in widget.additionalImages!) {
        final url = _imageOrDefault(img);
        if (url != _kDefaultImageUrl || images.isEmpty) {
          images.add(url);
        }
      }
    }
    return images;
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final images = _allImages;
    final hasMultipleImages = images.length > 1;

    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
        color: colorScheme.surfaceContainerHighest,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Image slider
          PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final imageUrl = images[index];
              return GestureDetector(
                onTap: () => _showFullScreenImage(context, images, index),
                child: _buildImage(imageUrl),
              );
            },
          ),
          // Navigation arrows (only show if multiple images)
          if (hasMultipleImages) ...[
            // Left arrow
            Positioned(
              left: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: _buildNavigationButton(
                  icon: Icons.chevron_left,
                  onTap: _currentIndex > 0
                      ? () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                ),
              ),
            ),
            // Right arrow
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: _buildNavigationButton(
                  icon: Icons.chevron_right,
                  onTap: _currentIndex < images.length - 1
                      ? () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      : null,
                ),
              ),
            ),
          ],
          // Page indicator dots
          if (hasMultipleImages)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentIndex == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _currentIndex == index
                          ? colorScheme.primary
                          : Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),
          // Image counter badge
          if (hasMultipleImages)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${_currentIndex + 1}/${images.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    VoidCallback? onTap,
  }) {
    final isEnabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isEnabled
              ? Colors.black.withOpacity(0.5)
              : Colors.black.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isEnabled ? Colors.white : Colors.white.withOpacity(0.5),
          size: 24,
        ),
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) =>
            const Center(child: CircularProgressIndicator()),
        errorWidget: (context, url, error) {
          return Container(
            color: Colors.grey[300],
            child: Icon(Icons.broken_image, size: 50, color: Colors.grey[600]),
          );
        },
      );
    } else if (imageUrl.startsWith('/') || imageUrl.contains('\\')) {
      // Local file path
      final file = File(imageUrl);
      return Image.file(
        file,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: Icon(Icons.broken_image, size: 50, color: Colors.grey[600]),
          );
        },
      );
    } else {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
  }

  void _showFullScreenImage(
      BuildContext context, List<String> images, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenImageViewer(
          images: images,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}

/// Full screen image viewer with swipe navigation
class FullScreenImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const FullScreenImageViewer({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: widget.images.length > 1
            ? Text(
                '${_currentIndex + 1} / ${widget.images.length}',
                style: const TextStyle(color: Colors.white),
              )
            : null,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final imageUrl = widget.images[index];
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: _buildFullScreenImage(imageUrl),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFullScreenImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.contain,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
        errorWidget: (context, url, error) {
          return Container(
            color: Colors.grey[900],
            child: Icon(Icons.broken_image, size: 50, color: Colors.grey[600]),
          );
        },
      );
    } else if (imageUrl.startsWith('/') || imageUrl.contains('\\')) {
      // Local file path
      final file = File(imageUrl);
      return Image.file(
        file,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[900],
            child: Icon(Icons.broken_image, size: 50, color: Colors.grey[600]),
          );
        },
      );
    } else {
      return Image.asset(
        imageUrl,
        fit: BoxFit.contain,
      );
    }
  }
}
