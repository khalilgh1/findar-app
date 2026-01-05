import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findar/logic/cubits/auth_cubit.dart';
import 'package:findar/core/services/cloudinary_service.dart';

class ProfileAvatar extends StatefulWidget {
  const ProfileAvatar({super.key});

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar>
    with SingleTickerProviderStateMixin {
  File? _selectedImage;
  Uint8List? _webImageBytes; // For web platform
  bool _isUploading = false;
  late AnimationController _progressController;
  final CloudinaryService _cloudinaryService = CloudinaryService();

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  ImageProvider _getImageProvider(dynamic authState) {
    // First check if user just uploaded/selected an image in this session
    if (kIsWeb && _webImageBytes != null) {
      return MemoryImage(_webImageBytes!);
    } else if (_selectedImage != null) {
      return FileImage(_selectedImage!);
    }

    // Then check if user has a saved profile picture from backend
    final userData = authState['data'];
    if (userData != null && userData.profilePic != null) {
      final profilePic = userData.profilePic as String;

      // If it's a URL from Cloudinary, use NetworkImage
      if (profilePic.startsWith('http')) {
        return NetworkImage(profilePic);
      }
    }

    // Finally, fall back to default avatar
    return const AssetImage('assets/profile.png');
  }

  void _showFullScreenImage(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            _FullScreenImageViewer(imageProvider: _getImageProvider(authState)),
      ),
    );
  }

  void _showImageSourceDialog() {
    // Don't show dialog if currently uploading
    if (_isUploading) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(fromCamera: false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(fromCamera: true);
                },
              ),
              if (_selectedImage != null || _webImageBytes != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Remove Photo',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedImage = null;
                      _webImageBytes = null;
                      _selectedImage = null;
                    });
                  },
                ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage({required bool fromCamera}) async {
    try {
      // Prevent multiple simultaneous uploads
      if (_isUploading) return;

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        // Reset animation controller before starting new upload
        _progressController.reset();

        setState(() {
          _isUploading = true;
        });

        if (kIsWeb) {
          // Read bytes for web platform
          final bytes = await image.readAsBytes();
          setState(() {
            _webImageBytes = bytes;
          });
        } else {
          // Use File for mobile platforms
          setState(() {
            _selectedImage = File(image.path);
          });
        }

        // Animate upload progress
        _progressController.forward();

        // Upload to Cloudinary
        if (_selectedImage != null) {
          final result = await _cloudinaryService.uploadProfilePicture(
            _selectedImage!.path,
          );

          if (result.success && result.url != null && mounted) {
            // Update profile with Cloudinary URL
            await context.read<AuthCubit>().updateProfile(
                  profilePic: result.url,
                );

            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile picture updated successfully'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          } else {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('Upload failed: ${result.error ?? "Unknown error"}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }

        setState(() {
          _isUploading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<AuthCubit, Map<String, dynamic>>(
      builder: (context, authState) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Main avatar with tap to view fullscreen
            GestureDetector(
              onTap: () => _showFullScreenImage(context),
              child: Hero(
                tag: 'profile_avatar',
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _getImageProvider(authState),
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),

            // Circular progress indicator (Facebook-style)
            if (_isUploading)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _CircularProgressPainter(
                        progress: _progressController.value,
                        color: theme.colorScheme.primary,
                      ),
                    );
                  },
                ),
              ),

            // Edit button
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _isUploading ? null : _showImageSourceDialog,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _isUploading
                        ? theme.colorScheme.primary.withOpacity(0.5)
                        : theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.edit,
                    color: theme.colorScheme.onPrimary,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Custom painter for Facebook-style circular progress
class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  _CircularProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle (semi-transparent)
    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 2),
      -3.14159 / 2, // Start from top
      2 * 3.14159 * progress, // Progress angle
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// Fullscreen image viewer
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
          tag: 'profile_avatar',
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
