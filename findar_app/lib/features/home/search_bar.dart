import 'package:findar/logic/cubits/search_cubit.dart';
import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:provider/provider.dart';
=======
import 'package:findar/l10n/app_localizations.dart';
>>>>>>> origin/localizations

const hpaddingSearchBar = 12.0;
const vpaddingSearchBar = 3.0;

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
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
            child: TextField(
              decoration: InputDecoration(
                hintStyle: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
          
                hintText: l10n.searchHint,
                border: InputBorder.none,
              ),
                onSubmitted: (value) {
                  context.read<SearchCubit>().getrecentListings(value);
                  Navigator.pushNamed(context, '/search-results');
                },

            ),
          ),
        ],
      ),
    );
  }
}
