import 'package:flutter/material.dart';

const hpaddingSearchBar = 12.0;
const vpaddingSearchBar = 3.0;

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: hpaddingSearchBar,
        vertical: vpaddingSearchBar,
      ),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow,
            blurRadius: 0.2,
            offset: Offset(0, 0),
          ),
        ],
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: theme.colorScheme.onSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintStyle: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 14,
                  color: theme.colorScheme.onSecondary,
                ),
                hintText: "Search for properties, agents, or locations",
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
