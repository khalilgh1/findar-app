import 'package:flutter/material.dart';
import 'package:findar_app/core/widgets/appbar_title.dart';
import 'package:findar_app/core/widgets/label.dart';
import 'package:findar_app/core/widgets/range_slider.dart';
import 'package:findar_app/core/widgets/segment_control.dart';

class FilteringScreen extends StatefulWidget {
  const FilteringScreen({super.key});

  @override
  State<FilteringScreen> createState() => _FilteringScreenState();
}

class _FilteringScreenState extends State<FilteringScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const AppbarTitle(title: 'Advanced Search'),
        leading: Icon(Icons.adaptive.arrow_back),
        actions: const [
          Icon(Icons.bookmark_outline),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FormLabel(text: "Location"),
              const TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                  labelText: 'Enter location',
                ),
              ),
              const FormLabel(text: "Price Range"),
              const RangeSliderExample(),
              const FormLabel(text: "Property Type"),
              SegmentedControl(
                options: const ['Any', 'For Sale', 'For Rent'],
                initialValue: 'Any',
                onChanged: (value) {
                  // print('Property Type: $value');
                },
              ),
              const FormLabel(text: "Building Type"),

              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Back to Home Screen'),
              ),
            ]),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 50,
          color: Colors.blueGrey,
          child: const Center(
            child: Text(
              'Bottom Navigation Bar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
