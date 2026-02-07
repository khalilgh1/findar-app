import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

const String kDefaultImageUrl =
    'https://res.cloudinary.com/da5xjc4dx/image/upload/v1767273156/default_cxkkda.jpg';

String imageOrDefault(String? img) {
  if (img == null) return kDefaultImageUrl;
  final s = img.trim();
  if (s.isEmpty || s.toLowerCase() == 'null') return kDefaultImageUrl;
  return s;
}

/// A reusable cached image widget that handles network, file, and asset images
/// with proper caching to prevent reloading on scroll/screen switch.
class AppCachedImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const AppCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = imageOrDefault(imageUrl);

    Widget image;
    if (resolvedUrl.startsWith('http://') ||
        resolvedUrl.startsWith('https://')) {
      image = CachedNetworkImage(
        imageUrl: resolvedUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => Container(
          width: width,
          height: height,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildPlaceholder(context),
      );
    } else if (resolvedUrl.isNotEmpty && !resolvedUrl.startsWith('assets/')) {
      // Local file
      final file = File(resolvedUrl);
      image = Image.file(
        file,
        width: width,
        height: height,
        fit: fit,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) =>
            _buildPlaceholder(context),
      );
    } else if (resolvedUrl.startsWith('assets/')) {
      image = Image.asset(
        resolvedUrl,
        width: width,
        height: height,
        fit: fit,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) =>
            _buildPlaceholder(context),
      );
    } else {
      image = _buildPlaceholder(context);
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return image;
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: Icon(Icons.image, color: Colors.grey[600]),
    );
  }
}
