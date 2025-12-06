import 'package:flutter/material.dart';
class SegmentedControl extends StatefulWidget {
  final List<String> options;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final Color activeColor;
  final Color inactiveColor;
  final Color activeTextColor;
  final Color inactiveTextColor;

  const SegmentedControl({
    Key? key,
    required this.options,
    this.initialValue,
    this.onChanged,
    this.activeColor = Colors.blue,
    this.inactiveColor = Colors.grey,
    this.activeTextColor = Colors.white,
    this.inactiveTextColor = Colors.black87,
  }) : super(key: key);

  @override
  State<SegmentedControl> createState() => _SegmentedControlState();
}

class _SegmentedControlState extends State<SegmentedControl> {
  late String _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue ?? widget.options.first;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: widget.options.map((option) {
          final isSelected = _selectedValue == option;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedValue = option;
                });
                widget.onChanged?.call(option);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? widget.activeColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  option,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Example usage
class SegmentedControlExample extends StatelessWidget {
  const SegmentedControlExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Segmented Control'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SegmentedControl(
                options: const ['Day', 'Week', 'Month'],
                initialValue: 'Day',
                onChanged: (value) {
                  print('Selected: $value');
                },
              ),
              const SizedBox(height: 30),
              SegmentedControl(
                options: const ['Grid', 'List'],
                initialValue: 'Grid',
                activeColor: Colors.blue,
                onChanged: (value) {
                  print('View mode: $value');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}