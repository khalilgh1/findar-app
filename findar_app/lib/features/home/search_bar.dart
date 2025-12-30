import 'package:flutter/material.dart';
import 'package:findar/l10n/app_localizations.dart';
const hpaddingSearchBar = 12.0;
const vpaddingSearchBar = 3.0;

class SearchBarWidget extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();
  SearchBarWidget({super.key});

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
        // color: theme.colorScheme.onSecondaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.secondaryContainer),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Builder(
              builder: (context) {
                var l10n = AppLocalizations.of(context);
                return TextField(
                  decoration: InputDecoration(
                    hintStyle: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    
                    hintText: l10n?.searchHint ?? 'Search...',
                    border: InputBorder.none,
                  ),
                  controller: _controller,
                  onSubmitted: (value) {
                    print('😂😁Search submitted: $value');
                    Navigator.pushNamed(context, '/search-results', arguments: value);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
