import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  ProfileAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage('assets/house1.jpg'),
          backgroundColor: Colors.transparent,
        ),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.edit, color: theme.colorScheme.onPrimary, size: 18),
        ),
      ],
    );
  }
}
