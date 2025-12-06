//flutter imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//widgets
import './widgets/property_title.dart';
import './widgets/description.dart';
import 'widgets/custom_selector.dart';
import './widgets/price_field.dart';
import './widgets/numeric_field.dart';
import './widgets/location_field.dart';
//package imports
import 'package:findar/logic/cubits/my_listings_cubit.dart';
import 'package:findar/l10n/app_localizations.dart';

//widgets
import '../../core/widgets/progress_button.dart';

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
  final List<String> _photos = ['find-dar-test1.jpg', 'find-dar-test2.jpg'];

  String? _validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a property title';
    }
    if (value.length < 5) {
      return 'Title must be at least 5 characters';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a description';
    }
    if (value.length < 20) {
      return 'Description must be at least 20 characters';
    }
    return null;
  }

  String? _validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a price';
    }
    if (double.tryParse(value) == null) {
      return 'Please enter a valid price';
    }
    if (double.parse(value) <= 0) {
      return 'Price must be greater than 0';
    }
    return null;
  }

  String? _validateLocation(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a location';
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
    final l10n = AppLocalizations.of(context)!;
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
          l10n.createNewListing,
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Property Title Section
                Text(l10n.propertyTitle, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 12),
                PropertyTitle(
                  titleController: _titleController,
                  theme: theme,
                  validator: _validateTitle,
                ),
                const SizedBox(height: 24),
                // Description Section
                Text(l10n.description, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 12),
                Description(
                  descriptionController: _descriptionController,
                  theme: theme,
                  validator: _validateDescription,
                ),
              const SizedBox(height: 24),
              // Classification Section
              Text(l10n.classification, style: theme.textTheme.headlineSmall),
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
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.price, style: theme.textTheme.headlineSmall),
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
                          l10n.propertyType,
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
                              items: ['Apartment', 'House', 'Villa', 'Condo']
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

              // Floors, Rooms, Bedrooms Row
              Row(
                children: [
                  Expanded(
                    child: NumericField(
                      label: l10n.floors,
                      hint: 'e.g. 2',
                      controller: _floorsController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: NumericField(
                      label: l10n.rooms,
                      hint: 'e.g. 5',
                      controller: _roomsController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: NumericField(
                      label: l10n.bedrooms,
                      hint: 'e.g. 3',
                      controller: _bedroomsController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: _validateBedrooms,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Location Section
              Text(l10n.location, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 12),
              LocationField(
                locationController: _locationController,
                theme: theme,
                validator: _validateLocation,
              ),
              const SizedBox(height: 24),

              // Photos Section
              Text(l10n.photos, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: AssetImage(_photos[0]),
                          fit: BoxFit.cover,
                          onError: (exception, stackTrace) {},
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () {
                                // setState(() => _photos.removeAt(0));
                              },
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.onSurface.withAlpha(
                                    150,
                                  ),
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
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: AssetImage(_photos[1]),
                          fit: BoxFit.cover,
                          onError: (exception, stackTrace) {},
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () {
                                // setState(() => _photos.removeAt(1));
                              },
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.onSurface.withAlpha(
                                    150,
                                  ),
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
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  // Handle add photo
                },
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
                        Text(
                          l10n.addPhotos,
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

              // Status Section
              Text(l10n.status, style: theme.textTheme.headlineSmall),
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
            if (state['state'] == 'done') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Listing Created Successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
              // Return to previous screen and signal that a listing was created
              Navigator.pop(context, true);
            } else if (state['state'] == 'error') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state['message'] ?? 'Failed to create listing'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: BlocBuilder<MyListingsCubit, Map<String, dynamic>>(
            builder: (context, state) {
              final isLoading = state['state'] == 'loading';
              final isError = state['state'] == 'error';
              final errorMessage = isError
                  ? (state['message'] as String?)
                  : null;

              return ProgressButton(
                label: l10n.createListing,
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
                    image: _photos.first,
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
