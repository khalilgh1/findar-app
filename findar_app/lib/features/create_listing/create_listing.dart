//flutter imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findar/l10n/app_localizations.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

//widgets
import 'package:findar/features/create_listing/widgets/property_title.dart';
import 'package:findar/features/create_listing/widgets/description.dart';
import 'package:findar/features/create_listing/widgets/custom_selector.dart';
import 'package:findar/features/create_listing/widgets/price_field.dart';
import 'package:findar/features/create_listing/widgets/numeric_field.dart';
import 'package:findar/features/create_listing/widgets/location_field.dart';
//package imports
import 'package:findar/logic/cubits/my_listings_cubit.dart';

//widgets
import 'package:findar/core/widgets/progress_button.dart';

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _floorsController = TextEditingController();
  final _roomsController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _locationController = TextEditingController();

  String _classification = 'For Sale';
  String _propertyType = 'Apartment';
  String _status = 'Online';
  final List<File> _selectedImages = [];
  final ImagePicker _imagePicker = ImagePicker();

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
            _selectedImages.add(File(image.path));
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
            _selectedImages.addAll(images.map((xFile) => File(xFile.path)));
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

  /// Remove an image from the list
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  String? _validateTitle(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l10n.validateTitleEmpty;
    }
    if (value.length < 5) {
      return l10n.validateTitleMinLength;
    }
    return null;
  }

  String? _validateDescription(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l10n.validateDescriptionEmpty;
    }
    if (value.length < 20) {
      return l10n.validateDescriptionMinLength;
    }
    return null;
  }

  String? _validatePrice(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l10n.validatePriceEmpty;
    }
    if (double.tryParse(value) == null) {
      return l10n.validatePriceInvalid;
    }
    if (double.parse(value) <= 0) {
      return l10n.validatePricePositive;
    }
    return null;
  }

  String? _validateLocation(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l10n.validateLocationEmpty;
    }
    return null;
  }

  String? _validateBedrooms(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter number of bedrooms';
    }
    if (int.tryParse(value) == null || int.parse(value) < 0) {
      return 'Please enter a valid number';
    }
    return null;
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
        title: Builder(
          builder: (context) {
            var l10n = AppLocalizations.of(context);
            return Text(
              l10n?.createNewListing ?? 'Create New Listing',
              style: theme.textTheme.headlineLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            );
          },
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Property Title Section
                Builder(
                  builder: (context) {
                    var l10n = AppLocalizations.of(context);
                    return Text(l10n?.propertyTitle ?? 'Property Title',
                        style: theme.textTheme.headlineSmall);
                  },
                ),
                const SizedBox(height: 12),
                PropertyTitle(
                  titleController: _titleController,
                  theme: theme,
                  validator: _validateTitle,
                ),
                const SizedBox(height: 24),
                // Description Section
                Builder(
                  builder: (context) {
                    var l10n = AppLocalizations.of(context);
                    return Text(l10n?.description ?? 'Description',
                        style: theme.textTheme.headlineSmall);
                  },
                ),
                const SizedBox(height: 12),
                Description(
                  descriptionController: _descriptionController,
                  theme: theme,
                  validator: _validateDescription,
                ),
                const SizedBox(height: 24),
                // Classification Section
                Builder(
                  builder: (context) {
                    var l10n = AppLocalizations.of(context);
                    return Text(l10n?.classification ?? 'Classification',
                        style: theme.textTheme.headlineSmall);
                  },
                ),
                const SizedBox(height: 12),
                CustomSelector(
                  selectedOption: _classification,
                  theme: theme,
                  options: ['For Sale', 'For Rent'],
                  onChanged: (value) {
                    setState(() {
                      _classification = value;
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Price and Property Type Row
                Builder(
                  builder: (context) {
                    var l10n = AppLocalizations.of(context);
                    return Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l10n?.price ?? 'Price',
                                  style: theme.textTheme.headlineSmall),
                              const SizedBox(height: 12),
                              priceField(
                                priceController: _priceController,
                                theme: theme,
                                validator: _validatePrice,
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
                                l10n?.propertyType ?? 'Property Type',
                                style: theme.textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 12),
                              Container(
                                height: 52,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton(
                                    dropdownColor:
                                        theme.colorScheme.secondaryContainer,
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
                                    items: [
                                      'Apartment',
                                      'House',
                                      'Villa',
                                      'Studio',
                                      'Office'
                                    ]
                                        .map(
                                          (String value) =>
                                              DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (String? newValue) {
                                      if (newValue != null) {
                                        setState(
                                            () => _propertyType = newValue);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Floors, Rooms, Bedrooms Row
                Builder(
                  builder: (context) {
                    var l10n = AppLocalizations.of(context);
                    return Row(
                      children: [
                        Expanded(
                          child: NumericField(
                            label: l10n?.floors ?? 'Floors',
                            hint: 'e.g. 2',
                            controller: _floorsController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: NumericField(
                            label: l10n?.rooms ?? 'Rooms',
                            hint: 'e.g. 5',
                            controller: _roomsController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: NumericField(
                            label: l10n?.bedrooms ?? 'Bedrooms',
                            hint: 'e.g. 3',
                            controller: _bedroomsController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            validator: _validateBedrooms,
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Location Section
                Builder(
                  builder: (context) {
                    var l10n = AppLocalizations.of(context);
                    return Text(l10n?.location ?? 'Location',
                        style: theme.textTheme.headlineSmall);
                  },
                ),
                const SizedBox(height: 12),
                LocationField(
                  locationController: _locationController,
                  theme: theme,
                  validator: _validateLocation,
                ),
                const SizedBox(height: 24),

                // Photos Section
                Builder(
                  builder: (context) {
                    var l10n = AppLocalizations.of(context);
                    return Text(l10n?.photos ?? 'Photos',
                        style: theme.textTheme.headlineSmall);
                  },
                ),
                const SizedBox(height: 12),
                // Display selected images
                if (_selectedImages.isNotEmpty)
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _selectedImages[index],
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              // Main image badge for first image
                              if (index == 0)
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
                                  onTap: () => _removeImage(index),
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.onSurface
                                          .withAlpha(150),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      color: theme.colorScheme.surface,
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
                if (_selectedImages.isNotEmpty) const SizedBox(height: 12),
                // Add photos button
                GestureDetector(
                  onTap: _showImageSourceDialog,
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
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
                          Builder(
                            builder: (context) {
                              var l10n = AppLocalizations.of(context);
                              return Text(
                                _selectedImages.isEmpty
                                    ? (l10n?.addPhotos ?? 'Add Photos')
                                    : 'Add More Photos',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Status Section
                Builder(
                  builder: (context) {
                    var l10n = AppLocalizations.of(context);
                    return Text(l10n?.status ?? 'Status',
                        style: theme.textTheme.headlineSmall);
                  },
                ),
                const SizedBox(height: 12),
                CustomSelector(
                  selectedOption: _status,
                  theme: theme,
                  options: ['Online', 'Offline'],
                  onChanged: (value) {
                    setState(() {
                      _status = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),

      // Create Listing Button
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocListener<MyListingsCubit, Map<String, dynamic>>(
          listener: (context, state) {
            final l10n = AppLocalizations.of(context)!;
            if (state['state'] == 'done') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.listingCreatedSuccessfully),
                  backgroundColor: Colors.green,
                ),
              );
              // Return to previous screen and signal that a listing was created
              Navigator.pop(context, true);
            } else if (state['state'] == 'error') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state['message'] ?? l10n.listingCreateFailed),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: BlocBuilder<MyListingsCubit, Map<String, dynamic>>(
            builder: (context, state) {
              final isLoading = state['state'] == 'loading';
              final isError = state['state'] == 'error';
              final errorMessage =
                  isError ? (state['message'] as String?) : null;

              return Builder(
                builder: (context) {
                  var l10n = AppLocalizations.of(context);
                  return ProgressButton(
                    label: l10n?.createListing ?? 'Create Listing',
                    backgroundColor: theme.colorScheme.primary,
                    textColor: theme.colorScheme.onPrimary,
                    isLoading: isLoading,
                    isError: isError,
                    errorMessage: errorMessage,
                    onPressed: () {
                      // Validate form
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }

                      // Validate at least one image is selected
                      if (_selectedImages.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please add at least one photo'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      // Get image paths
                      final mainImage = _selectedImages.first.path;
                      final additionalImages = _selectedImages.length > 1
                          ? _selectedImages.skip(1).map((f) => f.path).toList()
                          : <String>[];

                      // Call cubit to create listing
                      context.read<MyListingsCubit>().createListing(
                            title: _titleController.text,
                            description: _descriptionController.text,
                            price: double.parse(_priceController.text),
                            location: _locationController.text,
                            bedrooms: int.parse(_bedroomsController.text),
                            bathrooms: 1,
                            classification: _classification,
                            propertyType: _propertyType,
                            image: mainImage,
                            additionalImages: additionalImages,
                          );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _floorsController.dispose();
    _roomsController.dispose();
    _bedroomsController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}
