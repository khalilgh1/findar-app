import 'package:flutter/material.dart';
class CustomSelector extends StatelessWidget {
  final String selectedOption;
  final ValueChanged<String> onChanged;
  final ThemeData theme;
  final List<String> options;

  const CustomSelector({
    required this.selectedOption,
    required this.onChanged,
    required this.theme,
    required this.options,
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    return Row(
      children: options.map((type) {
        final isSelected = selectedOption == type;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: SizedBox(
                width: double.infinity,
                child: Text(type, textAlign: TextAlign.center),
              ),
              selected: isSelected,
              onSelected: (_) => onChanged(type),
              selectedColor: theme.colorScheme.primary,
              backgroundColor: theme.colorScheme.secondaryContainer,
              labelStyle: TextStyle(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
              ),
              side: BorderSide.none,
              showCheckmark: false,
            ),
          ),
        );
      }).toList(),
    );
  }
}