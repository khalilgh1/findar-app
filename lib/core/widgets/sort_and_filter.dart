import 'package:flutter/material.dart';

class FilterButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onPressed;

  const FilterButton({
    super.key,
    required this.text,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(text),
      style: OutlinedButton.styleFrom(
        foregroundColor: theme.colorScheme.onSurface,
        side: BorderSide(color: Colors.grey[300]!),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
    );
  }
}