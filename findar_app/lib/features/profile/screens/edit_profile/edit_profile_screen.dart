import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findar/logic/cubits/profile_cubit.dart';
import 'package:findar/logic/cubits/auth_cubit.dart';
import 'package:findar/core/widgets/progress_button.dart';
import 'package:findar/features/profile/screens/edit_profile/widgets/profile_text_field.dart';
import 'package:findar/features/profile/screens/edit_profile/utils/validators.dart';
import 'package:findar/features/profile/screens/edit_profile/utils/edit_profile_handler.dart';
import 'package:findar/l10n/app_localizations.dart';
import 'package:findar/core/services/cloudinary_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = false;
  File? _selectedImage;
  String? _uploadedImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Load current user data into form fields
  void _loadUserData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileState = context.read<ProfileCubit>().state;
      final userData = profileState['data'] as Map<String, dynamic>?;

      if (userData != null) {
        _nameController.text = userData['name'] ?? '';
        _emailController.text = userData['email'] ?? '';
        _phoneController.text = userData['phone'] ?? '';
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _setLoading(bool loading) {
    if (mounted) {
      setState(() => _isLoading = loading);
    }
  }

  /// Pick an image from gallery or camera
  Future<void> _pickImage({bool fromCamera = false}) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Show image source selection dialog
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
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
          ],
        ),
      ),
    );
  }

  /// Get current profile picture
  ImageProvider _getImageProvider() {
    // First check if user just selected a new image
    if (_selectedImage != null) {
      return FileImage(_selectedImage!);
    }

    // Then check if user has a saved profile picture
    final authState = context.read<AuthCubit>().state;
    final userData = authState['data'];

    if (userData != null && userData.profilePic != null) {
      final profilePic = userData.profilePic as String;
      if (profilePic.startsWith('http')) {
        return NetworkImage(profilePic);
      }
    }

    // Fall back to default avatar
    return const AssetImage('assets/profile.png');
  }

  /// Upload image to Cloudinary and save
  Future<void> _uploadAndSaveImage() async {
    if (_selectedImage == null) return;

    _setLoading(true);

    try {
      // Upload to Cloudinary
      final result = await _cloudinaryService.uploadProfilePicture(
        _selectedImage!.path,
      );

      if (result.success && result.url != null) {
        _uploadedImageUrl = result.url;

        // Update profile with new image URL
        await context.read<AuthCubit>().updateProfile(
              profilePic: _uploadedImageUrl,
            );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload image: ${result.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      _setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.colorScheme.onSurface,
            size: 30,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return Text(
              l10n.editProfile,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            );
          },
        ),
        centerTitle: true,
      ),
      body: BlocListener<ProfileCubit, Map<String, dynamic>>(
        listener: (context, state) {
          // Handle state changes if needed
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // Profile Picture Section
                Center(
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: _showImageSourceDialog,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.primary,
                              width: 3,
                            ),
                          ),
                          child: ClipOval(
                            child: Image(
                              image: _getImageProvider(),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _showImageSourceDialog,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.colorScheme.surface,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              color: theme.colorScheme.onPrimary,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Upload button (only show when image is selected)
                if (_selectedImage != null)
                  Center(
                    child: TextButton.icon(
                      onPressed: _isLoading ? null : _uploadAndSaveImage,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.upload),
                      label: Text(_isLoading ? 'Uploading...' : 'Upload Photo'),
                    ),
                  ),

                const SizedBox(height: 24),

                // Full Name Field
                ProfileTextField(
                  label: l10n.fullName,
                  controller: _nameController,
                  validator: ProfileValidators.validateName,
                  hintText: l10n.enterFullName,
                ),

                const SizedBox(height: 24),

                // Email Field
                ProfileTextField(
                  label: l10n.emailAddress,
                  controller: _emailController,
                  validator: ProfileValidators.validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  hintText: l10n.enterEmail,
                ),

                const SizedBox(height: 24),

                // Phone Number Field
                ProfileTextField(
                  label: l10n.phoneNumber,
                  controller: _phoneController,
                  validator: ProfileValidators.validatePhone,
                  keyboardType: TextInputType.phone,
                  hintText: l10n.enterPhone,
                ),

                const SizedBox(height: 40),

                // Save Changes Button
                SizedBox(
                  width: double.infinity,
                  child: ProgressButton(
                    label: l10n.saveChanges,
                    backgroundColor: theme.colorScheme.primary,
                    textColor: Colors.white,
                    isLoading: _isLoading,
                    onPressed: _isLoading
                        ? null
                        : () => EditProfileHandler.saveChanges(
                              context: context,
                              formKey: _formKey,
                              nameController: _nameController,
                              emailController: _emailController,
                              phoneController: _phoneController,
                              setLoading: _setLoading,
                            ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
