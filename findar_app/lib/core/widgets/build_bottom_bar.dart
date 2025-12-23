import 'package:flutter/material.dart';
import 'package:findar/core/layout/bottom_bar.dart';

class BuildBottomNavBar extends StatelessWidget {
  final int index;

  const BuildBottomNavBar({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomBar(
        theme: theme,
        screenWidth: screenWidth,
        context: context,
        index: index,
      ),
    );
  }
}
