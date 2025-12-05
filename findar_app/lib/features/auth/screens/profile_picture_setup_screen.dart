import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../logic/cubits/profile_picture_setup_cubit.dart';

class ProfilePictureSetupScreen extends StatefulWidget {
  const ProfilePictureSetupScreen({super.key});

  @override
  State<ProfilePictureSetupScreen> createState() =>
      _ProfilePictureSetupScreenState();
}

class _ProfilePictureSetupScreenState extends State<ProfilePictureSetupScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;

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

  Future<void> _pickImage() async {
    final cubit = context.read<ProfilePictureSetupCubit>();
    final state = cubit.state;

    // Prevent multiple simultaneous uploads
    if (state.isUploading) return;

    try {
      final ImagePicker picker = ImagePicker();

      // Show dialog to choose source
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            'Choose Image Source',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        cubit.setUploading(true);

        // Reset animation controller before starting
        _progressController.reset();

        if (kIsWeb) {
          // Read bytes for web platform
          final bytes = await image.readAsBytes();
          cubit.setImage(imageBytes: bytes);
        } else {
          // Use File for mobile platforms
          cubit.setImage(imageFile: File(image.path));
        }

        // Animate progress
        _progressController.forward();

        // Simulate processing delay
        await Future.delayed(const Duration(milliseconds: 2000));

        cubit.setUploading(false);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
      context.read<ProfilePictureSetupCubit>().setUploading(false);
    }
  }

  ImageProvider _getImageProvider(ProfilePictureSetupState state) {
    if (kIsWeb && state.imageBytes != null) {
      return MemoryImage(state.imageBytes!);
    } else if (state.imageFile != null) {
      return FileImage(state.imageFile!);
    } else {
      return const AssetImage('assets/profile.jpg');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<ProfilePictureSetupCubit, ProfilePictureSetupState>(
      listener: (context, state) {
        if (state.uploadComplete) {
          // Navigate to home after upload or skip
          Navigator.pushReplacementNamed(context, '/home');
        }
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 60),
                // Title
                Text(
                  'Choose A Profile Picture',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),
                // Profile Picture Circle
                BlocBuilder<ProfilePictureSetupCubit, ProfilePictureSetupState>(
                  builder: (context, state) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // Circle Avatar
                        GestureDetector(
                          onTap: state.isUploading ? null : _pickImage,
                          child: Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.colorScheme.primary,
                                width: 3,
                              ),
                            ),
                            child: ClipOval(
                              child: state.hasImage
                                  ? Image(
                                      image: _getImageProvider(state),
                                      fit: BoxFit.cover,
                                    )
                                  : Icon(
                                      Icons.add,
                                      size: 60,
                                      color: theme.colorScheme.primary,
                                    ),
                            ),
                          ),
                        ),
                        // Progress indicator overlay
                        if (state.isUploading)
                          Positioned.fill(
                            child: AnimatedBuilder(
                              animation: _progressController,
                              builder: (context, child) {
                                return CustomPaint(
                                  painter: _CircularProgressPainter(
                                    progress: _progressController.value,
                                    color: theme.colorScheme.primary,
                                    size: 160,
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const Spacer(),
                // Buttons
                BlocBuilder<ProfilePictureSetupCubit, ProfilePictureSetupState>(
                  builder: (context, state) {
                    return Column(
                      children: [
                        // Upload Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: (state.hasImage && !state.isUploading)
                                ? () {
                                    context
                                        .read<ProfilePictureSetupCubit>()
                                        .uploadProfilePicture();
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              disabledBackgroundColor: theme.colorScheme.primary
                                  .withOpacity(0.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: state.isUploading
                                ? SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: theme.colorScheme.onPrimary,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Upload',
                                    style: TextStyle(
                                      color: theme.colorScheme.onPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Ignore Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: TextButton(
                            onPressed: state.isUploading
                                ? null
                                : () {
                                    context
                                        .read<ProfilePictureSetupCubit>()
                                        .skipProfilePicture();
                                  },
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                            ),
                            child: Text(
                              'Ignore',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom painter for circular progress indicator
class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double size;

  _CircularProgressPainter({
    required this.progress,
    required this.color,
    this.size = 100,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    final radius = size / 2;

    // Background circle (semi-transparent)
    final bgPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius - 2);
    canvas.drawArc(
      rect,
      -3.14159 / 2, // Start from top
      2 * 3.14159 * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
