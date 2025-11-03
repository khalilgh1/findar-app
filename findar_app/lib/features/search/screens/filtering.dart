import 'package:flutter/material.dart';
import 'package:main_button/main_button.dart';

class FilteringScreen extends StatefulWidget {
  const FilteringScreen({super.key});

  @override
  State<FilteringScreen> createState() => _FilteringScreenState();
}

class _FilteringScreenState extends State<FilteringScreen> {
  final TextEditingController locationController = TextEditingController();

  RangeValues priceRange = const RangeValues(20000, 250000000);
  String propertyType = 'Any';
  String buildingType = 'House'; // Only one can be selected now

  int bedrooms = 2;
  int bathrooms = 1;
  String? listedBy = 'Any';
  String? minSqFt;
  String? maxSqFt;

  void resetFilters() {
    setState(() {
      locationController.clear();
      priceRange = const RangeValues(100000, 5000000);
      propertyType = 'Any';
      buildingType = 'House';
      bedrooms = 2;
      bathrooms = 1;
      listedBy = 'Any';
      minSqFt = null;
      maxSqFt = null;
    });
  }

  String _formatPrice(double value) {
    if (value >= 1000000) {
      return "${(value / 1000000).toStringAsFixed(1)}M DA";
    } else if (value >= 1000) {
      return "${(value / 1000).toStringAsFixed(0)}k DA";
    }
    return "${value.toStringAsFixed(0)} DA";
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
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
        title: const Text('Advanced Search'),
        centerTitle: true,
    
        elevation: 0,
      ),
      body: Container(
        color: theme.colorScheme.surface,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Location
            Text('Location', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            TextField(
              controller: locationController,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: theme.colorScheme.secondary),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: 'Enter a city, zip code, or neighborhood',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Price Range
            Text('Price range', style: theme.textTheme.headlineSmall),

            RangeSlider(
              values: priceRange,
              min: 20000,
              max: 250000000,
              divisions: 20,
              labels: RangeLabels(
                _formatPrice(priceRange.start),
                _formatPrice(priceRange.end),
              ),
              activeColor: theme.colorScheme.primary,
              onChanged: (values) => setState(() => priceRange = values),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatPrice(priceRange.start)),
                Text(_formatPrice(priceRange.end)),
              ],
            ),

            const SizedBox(height: 24),

            // Property Type
            Text('Propoerty type', style: theme.textTheme.headlineSmall),

            const SizedBox(height: 8),
            Row(
              children: ['Any', 'For Sale', 'For Rent'].map((type) {
                final isSelected = propertyType == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (_) => setState(() => propertyType = type),
                    selectedColor: theme.colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                    ),
                    side: BorderSide.none,
                    showCheckmark: false,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Building Type
            Text('Building Type', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildBuildingRadio('House')),
                    Expanded(child: _buildBuildingRadio('Apartment')),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: _buildBuildingRadio('Condo')),
                    Expanded(child: _buildBuildingRadio('Townhouse')),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Beds & Baths
            Text('Beds & Baths', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            _buildCounterRow(
              'Bedrooms',
              bedrooms,
              (v) => setState(() => bedrooms = v),
            ),
            const SizedBox(height: 8),
            _buildCounterRow(
              'Bathrooms',
              bathrooms,
              (v) => setState(() => bathrooms = v),
            ),

            const SizedBox(height: 24),

            // Square Footage
            Text('Square Footage', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Min',
                      labelStyle: const TextStyle(
                        color: Colors.grey,
                      ), // default (unfocused)
                      floatingLabelStyle: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ), // on focus
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: theme.colorScheme.secondary,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Max',
                      labelStyle: TextStyle(color: theme.colorScheme.secondary),
                      floatingLabelStyle: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: theme.colorScheme.secondary,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Listed By
            Text('Listed by', style: theme.textTheme.headlineSmall),
            Column(
              children: [
                RadioListTile<String>(
                  title: Text('Any'),
                  value: 'Any',
                  activeColor: theme.colorScheme.primary,
                  groupValue: listedBy,
                  onChanged: (v) => setState(() => listedBy = v),
                ),
                RadioListTile<String>(
                  title: Text('Private Owner'),
                  value: 'Private Owner',
                  activeColor: theme.colorScheme.primary,
                  groupValue: listedBy,
                  onChanged: (v) => setState(() => listedBy = v),
                ),
                RadioListTile<String>(
                  title: const Text('Real Estate Agent'),
                  value: 'Real Estate Agent',
                  activeColor: theme.colorScheme.primary,
                  groupValue: listedBy,
                  onChanged: (v) => setState(() => listedBy = v),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: MainButton(
                label: 'Reset',
                backgroundColor: theme.colorScheme.secondary,
                onPressed: resetFilters,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MainButton(
                label: 'Show results',
                backgroundColor: theme.colorScheme.primary,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Showing 42 results')),
                    
                  );
                  Navigator.pushNamed(context,'/search-results');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuildingRadio(String type) {
    return RadioListTile<String>(
      title: Text(type),
      value: type,
      groupValue: buildingType,
      activeColor: Theme.of(context).colorScheme.primary,
      onChanged: (value) {
        setState(() {
          buildingType = value!;
        });
      },
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  Widget _buildCounterRow(
    String label,
    int value,
    ValueChanged<int> onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Row(
          children: [
            IconButton(
              onPressed: value > 0 ? () => onChanged(value - 1) : null,
              icon: Icon(
                Icons.remove_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Text('$value', style: const TextStyle(fontSize: 16)),
            IconButton(
              onPressed: () => onChanged(value + 1),
              icon: Icon(
                Icons.add_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
