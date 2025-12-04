import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:findar/core/models/property_listing_model.dart';
import 'package:findar/logic/cubits/listing_cubit.dart';
import '../../../create_listing/widgets/property_title.dart';
import '../../../create_listing/widgets/description.dart';
import '../../../create_listing/widgets/custom_selector.dart';
import '../../../create_listing/widgets/price_field.dart';
import '../../../create_listing/widgets/numeric_field.dart';
import '../../../create_listing/widgets/location_field.dart';
import '../../../../core/widgets/progress_button.dart';

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
    _propertyType = widget.listing.propertyType;
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

    context.read<ListingCubit>().updateListing(
      id: widget.listing.id,
      title: _titleController.text,
      description: _descriptionController.text,
      price: price,
      location: _locationController.text,
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      classification: _classification,
      propertyType: _propertyType,
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

                // Location Section
                Text('Location', style: theme.textTheme.headlineSmall),
                const SizedBox(height: 12),
                LocationField(
                  locationController: _locationController,
                  theme: theme,
                ),
                const SizedBox(height: 40),

                // Update Button
                BlocBuilder<ListingCubit, Map<String, dynamic>>(
                  builder: (context, state) {
                    final isLoading = state['state'] == 'loading';
                    return ProgressButton(
                      label: 'Update Listing',
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
