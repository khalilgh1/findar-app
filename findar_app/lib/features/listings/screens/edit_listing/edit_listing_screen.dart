import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:findar/core/models/property_listing_model.dart';
import 'package:findar/logic/cubits/my_listings_cubit.dart';
import 'package:findar/features/create_listing/widgets/property_title.dart';
import 'package:findar/features/create_listing/widgets/description.dart';
import 'package:findar/features/create_listing/widgets/custom_selector.dart';
import 'package:findar/features/create_listing/widgets/price_field.dart';
import 'package:findar/features/create_listing/widgets/numeric_field.dart';
import 'package:findar/features/create_listing/widgets/location_field.dart';
import 'package:findar/core/widgets/progress_button.dart';

class EditListingScreen extends StatefulWidget {
  final PropertyListing listing;

  const EditListingScreen({super.key, required this.listing});

  @override
  State<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends State<EditListingScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _bedroomsController;
  late final TextEditingController _bathroomsController;
  late final TextEditingController _locationController;

  late String _classification;
  late String _propertyType;
  
  // Image handling
  final List<File> _newImages = [];
  final List<String> _existingImageUrls = [];
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Pre-fill controllers with existing listing data
    _titleController = TextEditingController(text: widget.listing.title);
    _descriptionController = TextEditingController(text: widget.listing.description);
    _priceController = TextEditingController(text: widget.listing.price.toString());
    _bedroomsController = TextEditingController(text: widget.listing.bedrooms.toString());
    _bathroomsController = TextEditingController(text: widget.listing.bathrooms.toString());
    _locationController = TextEditingController(text: widget.listing.location);
    _classification = widget.listing.classification;
    // Capitalize first letter to match dropdown items
    _propertyType = widget.listing.propertyType.substring(0, 1).toUpperCase() + 
                    widget.listing.propertyType.substring(1).toLowerCase();
    
    // Load existing images
    if (widget.listing.image.isNotEmpty) {
      _existingImageUrls.add(widget.listing.image);
    }
    if (widget.listing.additionalImages != null && widget.listing.additionalImages!.isNotEmpty) {
      _existingImageUrls.addAll(widget.listing.additionalImages!);
    }
  }
  
  /// Pick images from gallery or camera
  Future<void> _pickImages({bool fromCamera = false}) async {
    try {
      if (fromCamera) {
        final XFile? image = await _imagePicker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );
        if (image != null) {
          setState(() {
            _newImages.add(File(image.path));
          });
        }
      } else {
        final List<XFile> images = await _imagePicker.pickMultiImage(
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );
        if (images.isNotEmpty) {
          setState(() {
            _newImages.addAll(images.map((xFile) => File(xFile.path)));
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
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
                _pickImages(fromCamera: false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImages(fromCamera: true);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Remove an existing image
  void _removeExistingImage(int index) {
    setState(() {
      _existingImageUrls.removeAt(index);
    });
  }

  /// Remove a new image
  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _handleUpdate() {
    // Simple validation - check required fields
    if (_titleController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty ||
        _priceController.text.trim().isEmpty ||
        _locationController.text.trim().isEmpty ||
        _bedroomsController.text.trim().isEmpty ||
        _bathroomsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final price = double.tryParse(_priceController.text);
    final bedrooms = int.tryParse(_bedroomsController.text);
    final bathrooms = int.tryParse(_bathroomsController.text);

    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid price'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (bedrooms == null || bedrooms < 0 || bathrooms == null || bathrooms < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid numbers for bedrooms and bathrooms'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Prepare image data
    // Combine existing URLs with new file paths
    final allImages = <String>[
      ..._existingImageUrls,
      ..._newImages.map((file) => file.path),
    ];

    // The first image is the main image, rest are additional
    final mainImage = allImages.isNotEmpty ? allImages.first : null;
    final additionalImages = allImages.length > 1 ? allImages.sublist(1) : null;

    context.read<MyListingsCubit>().editListing(
      id: widget.listing.id,
      title: _titleController.text,
      description: _descriptionController.text,
      price: price,
      location: _locationController.text,
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      classification: _classification,
      propertyType: _propertyType.toLowerCase(), // Convert back to lowercase for backend
      image: mainImage,
      additionalImages: additionalImages,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Updating listing...')),
    );

    // Navigate back after update
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        forceMaterialTransparency: false,
        primary: true,
        toolbarOpacity: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Listing',
          style: theme.textTheme.headlineLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                // Property Title Section
                Text('Property Title', style: theme.textTheme.headlineSmall),
                const SizedBox(height: 12),
                PropertyTitle(titleController: _titleController, theme: theme),
                const SizedBox(height: 24),

                // Description Section
                Text('Description', style: theme.textTheme.headlineSmall),
                const SizedBox(height: 12),
                Description(
                  descriptionController: _descriptionController,
                  theme: theme,
                ),
                const SizedBox(height: 24),

                // Classification Section
                Text('Classification', style: theme.textTheme.headlineSmall),
                const SizedBox(height: 12),
                CustomSelector(
                  selectedOption: _classification,
                  theme: theme,
                  options: const ['For Sale', 'For Rent'],
                  onChanged: (value) {
                    setState(() {
                      _classification = value;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Price and Property Type Row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Price', style: theme.textTheme.headlineSmall),
                          const SizedBox(height: 12),
                          priceField(
                            priceController: _priceController,
                            theme: theme,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Property Type',
                            style: theme.textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 12),
                          Container(
                            height: 52,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton(
                                dropdownColor: theme.colorScheme.secondaryContainer,
                                value: _propertyType,
                                isExpanded: true,
                                icon: Icon(
                                  Icons.keyboard_arrow_down,
                                  color: theme.colorScheme.onSurface,
                                ),
                                style: TextStyle(
                                  fontSize: 15,
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w500,
                                ),
                                items: ['Apartment', 'House', 'Villa', 'Studio', 'Office']
                                    .map(
                                      (String value) => DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() => _propertyType = newValue);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Bedrooms and Bathrooms Row
                Row(
                  children: [
                    Expanded(
                      child: NumericField(
                        label: 'Bedrooms',
                        hint: 'e.g. 3',
                        controller: _bedroomsController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: NumericField(
                        label: 'Bathrooms',
                        hint: 'e.g. 2',
                        controller: _bathroomsController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Photos Section
                Text('Photos', style: theme.textTheme.headlineSmall),
                const SizedBox(height: 12),
                
                // Display existing images from URLs
                if (_existingImageUrls.isNotEmpty)
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _existingImageUrls.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 12),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  _existingImageUrls[index],
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey.shade300,
                                      child: const Center(
                                        child: Icon(Icons.broken_image, color: Colors.grey),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              // Main image badge for first existing image
                              if (index == 0 && _newImages.isEmpty)
                                Positioned(
                                  bottom: 8,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Main',
                                      style: TextStyle(
                                        color: theme.colorScheme.onPrimary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              // Delete button
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () => _removeExistingImage(index),
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                if (_existingImageUrls.isNotEmpty) const SizedBox(height: 12),
                
                // Display new images from files
                if (_newImages.isNotEmpty)
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _newImages.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 12),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _newImages[index],
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              // Main image badge for first new image if no existing images
                              if (index == 0 && _existingImageUrls.isEmpty)
                                Positioned(
                                  bottom: 8,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Main',
                                      style: TextStyle(
                                        color: theme.colorScheme.onPrimary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              // Delete button
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () => _removeNewImage(index),
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                if (_newImages.isNotEmpty) const SizedBox(height: 12),
                
                // Add photos button
                GestureDetector(
                  onTap: _showImageSourceDialog,
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        style: BorderStyle.solid,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            color: Colors.grey[400],
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            (_existingImageUrls.isEmpty && _newImages.isEmpty)
                                ? 'Add Photos'
                                : 'Add More Photos',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Location Section
                Text('Location', style: theme.textTheme.headlineSmall),
                const SizedBox(height: 12),
                LocationField(
                  locationController: _locationController,
                  theme: theme,
                ),
                const SizedBox(height: 40),

                // Update Button
                BlocBuilder<MyListingsCubit, Map<String, dynamic>>(
                  builder: (context, state) {
                    final isLoading = state['state'] == 'loading';
                    return ProgressButton(
                      label: 'Update Listing',
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      textColor: Colors.white,
                      onPressed: isLoading ? null : _handleUpdate,
                      isLoading: isLoading,
                    );
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      );
  }
}
