import 'package:flutter/material.dart';

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
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: theme.colorScheme.surface,
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: theme.colorScheme.onSurfaceVariant,
      currentIndex: index,
      elevation: 0,
      iconSize: screenWidth * 0.06,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.bookmark_outline),
          label: 'Saved',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          label: 'Post',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushNamed(context, '/home');
            break;
          case 1:
            Navigator.pushNamed(context, '/saved-listings');
            break;
          case 2:
            Navigator.pushNamed(context, '/create-listing');
            break;
          case 3:
            Navigator.pushNamed(context, '/profile');
            break;
        }
      },
    );
  }
}
