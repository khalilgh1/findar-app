import 'package:flutter/material.dart';

class UserProfileAvatar extends StatelessWidget {
  final String? imageUrl;

  const UserProfileAvatar({super.key, this.imageUrl});

  ImageProvider _getImageProvider() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return NetworkImage(imageUrl!);
    } else {
      return const AssetImage('assets/profile.png');
    }
  }

  void _showFullScreenImage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            _FullScreenImageViewer(imageProvider: _getImageProvider()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFullScreenImage(context),
      child: Hero(
        tag: 'user_profile_avatar',
        child: CircleAvatar(
          radius: 50,
          backgroundImage: _getImageProvider(),
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }
}

// Full screen image viewer
class _FullScreenImageViewer extends StatelessWidget {
  final ImageProvider imageProvider;

  const _FullScreenImageViewer({required this.imageProvider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Hero(
          tag: 'user_profile_avatar',
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Image(image: imageProvider, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
