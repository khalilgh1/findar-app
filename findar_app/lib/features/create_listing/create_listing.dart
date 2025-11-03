//flutter imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//widgets
import './widgets/property_title.dart';
import './widgets/description.dart';
import 'widgets/custom_selector.dart';
import './widgets/price_field.dart';
import './widgets/numeric_field.dart';
import './widgets/location_field.dart';
//package imports
import 'package:main_button/main_button.dart';

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
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
        title: Text('Create New Listing', style: theme.textTheme.headlineLarge?.copyWith(color: theme.colorScheme.onSurface),),
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
                      label: 'Floors',
                      hint: 'e.g. 2',
                      controller: _floorsController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: NumericField(
                      label: 'Rooms',
                      hint: 'e.g. 5',
                      controller: _roomsController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: NumericField(
                      label: 'Bedrooms',
                      hint: 'e.g. 3',
                      controller: _bedroomsController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Location Section
              Text('Location', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 12),
              LocationField(
                locationController: _locationController,
                theme: theme,
              ),
              const SizedBox(height: 24),

              // Photos Section
              Text('Photos', style: theme.textTheme.headlineSmall),
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
                                  color: theme.colorScheme.onSurface.withAlpha(150),
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
                                  color: theme.colorScheme.onSurface.withAlpha(150),
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
                    color: Theme.of(  context).colorScheme.secondary ,
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
                          'Add Photos',
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
              Text('Status', style: theme.textTheme.headlineSmall),
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

      // Create Listing Button
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: MainButton(
          label: 'Create Listing',
          backgroundColor: theme.colorScheme.primary,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Listing Created Successfully!')),
            );
              Navigator.pushNamed(context, '/my-listings');

          },
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
