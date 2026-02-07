import 'package:flutter/material.dart';
import 'package:findar/l10n/app_localizations.dart';

class BottomBar extends StatelessWidget {
  const BottomBar({
    super.key,
    required this.theme,
    required this.screenWidth,
    required this.context,
    required this.index,
  });

  final ThemeData theme;
  final double screenWidth;
  final BuildContext context;
  final int index;

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: theme.colorScheme.surface,
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: theme.colorScheme.onSurfaceVariant,
      currentIndex: index,
      elevation: 0,
      iconSize: screenWidth.clamp(10, 25),
      items: [
        BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined), label: l10n.home),
        BottomNavigationBarItem(
          icon: Icon(Icons.bookmark_outline),
          label: l10n.saved,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.article_outlined),
          label: l10n.listings,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: l10n.profile,
        ),
      ],
      onTap: (tappedIndex) {
        // Don't navigate if already on the same tab
        if (tappedIndex == index) return;

        String routeName;
        switch (tappedIndex) {
          case 0:
            routeName = '/home';
            break;
          case 1:
            routeName = '/saved-listings';
            break;
          case 2:
            routeName = '/my-listings';
            break;
          case 3:
            routeName = '/profile';
            break;
          default:
            return;
        }

        // Use pushNamedAndRemoveUntil to avoid stacking multiple routes
        // Keep only the home route at the bottom of the stack
        Navigator.pushNamedAndRemoveUntil(
          context,
          routeName,
          (route) => route.settings.name == '/home' || route.isFirst,
        );
      },
    );
  }
}
