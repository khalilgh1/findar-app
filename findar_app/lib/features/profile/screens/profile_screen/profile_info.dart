import 'package:flutter/material.dart';
import 'package:findar/l10n/app_localizations.dart';

class ProfileInfoCard extends StatelessWidget {
  final String phone;
  final String email;

  const ProfileInfoCard({
    super.key,
    this.phone = "0000000000",
    this.email = "null",
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          ListTile(
            leading: _iconBox(Icons.phone_outlined, theme),
            title: Text(l10n.phoneNumber, style: TextStyle(fontSize: 13)),
            trailing: Text(phone, style: TextStyle(fontSize: 13)),
          ),
          const Divider(height: 1),
          ListTile(
            leading: _iconBox(Icons.email_outlined, theme),
            title: Text(l10n.email, style: TextStyle(fontSize: 14)),
            trailing: Text(
              email,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBox(IconData icon, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: theme.colorScheme.onSecondary,
      ),
      child: Icon(icon),
    );
  }
}
