import 'package:flutter/material.dart';
import 'package:findar_app/core/widgets/appbar_title.dart';
import 'package:findar_app/core/widgets/label.dart';
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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const AppbarTitle(title: 'Advanced Search'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: Colors.white,
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
                  borderSide: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: 'Enter a city, zip code, or neighborhood',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Price Range
            const FormLabel(text: 'Price Range'),

            RangeSlider(
              values: priceRange,
              min: 20000,
              max: 250000000,
              divisions: 20,
              labels: RangeLabels(
                _formatPrice(priceRange.start),
                _formatPrice(priceRange.end),
              ),
              activeColor: Colors.blue,
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
            const FormLabel(text: 'Location'),

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
                    selectedColor: Colors.blue,
                    iconTheme: IconThemeData(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Building Type
            const Text('Building Type'),
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
            const Text('Beds & Baths'),
            const SizedBox(height: 8),
            _buildCounterRow(
                'Bedrooms', bedrooms, (v) => setState(() => bedrooms = v)),
            const SizedBox(height: 8),
            _buildCounterRow(
                'Bathrooms', bathrooms, (v) => setState(() => bathrooms = v)),

            const SizedBox(height: 24),

            // Square Footage
            const Text('Square Footage'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Min',
                      labelStyle: const TextStyle(
                          color: Colors.grey), // default (unfocused)
                      floatingLabelStyle: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600), // on focus
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.blue, width: 2),
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
                      labelStyle: const TextStyle(color: Colors.grey),
                      floatingLabelStyle: const TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.w600),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.blue, width: 2),
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
            const Text('Listed by'),
            Column(
              children: [
                RadioListTile<String>(
                  title: const Text('Any'),
                  value: 'Any',
                  activeColor: Colors.blue,
                  groupValue: listedBy,
                  onChanged: (v) => setState(() => listedBy = v),
                ),
                RadioListTile<String>(
                  title: const Text('Private Owner'),
                  value: 'Private Owner',
                  activeColor: Colors.blue,
                  groupValue: listedBy,
                  onChanged: (v) => setState(() => listedBy = v),
                ),
                RadioListTile<String>(
                  title: const Text('Real Estate Agent'),
                  value: 'Real Estate Agent',
                  activeColor: Colors.blue,
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
                backgroundColor: Colors.grey,
                onPressed: resetFilters,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MainButton(
                label: 'Show results',
                backgroundColor: Colors.blue,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Showing 42 results')),
                  );
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
      activeColor: Colors.blue,
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
      String label, int value, ValueChanged<int> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Row(
          children: [
            IconButton(
              onPressed: value > 0 ? () => onChanged(value - 1) : null,
              icon: const Icon(
                Icons.remove_circle,
                color: Colors.blue,
              ),
            ),
            Text('$value', style: const TextStyle(fontSize: 16)),
            IconButton(
              onPressed: () => onChanged(value + 1),
              icon: const Icon(
                Icons.add_circle,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
