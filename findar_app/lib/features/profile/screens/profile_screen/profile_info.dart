import 'package:flutter/material.dart';
import 'package:findar/l10n/app_localizations.dart';

class ProfileInfoCard extends StatelessWidget {
  final String phone;
  final String email;

  const ProfileInfoCard({
    super.key,
    this.phone = "0797987620",
    this.email = "yahia@gmail.com",
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Builder(
            builder: (context) {
              var l10n = AppLocalizations.of(context);
              return ListTile(
                leading: _iconBox(Icons.phone_outlined, theme),
                title: Text(l10n?.phoneNumber ?? 'Phone Number', style: TextStyle(fontSize: 13)),
                trailing: Text(phone, style: TextStyle(fontSize: 13)),
              );
            },
          ),
          const Divider(height: 1),
          Builder(
            builder: (context) {
              var l10n = AppLocalizations.of(context);
              return ListTile(
                leading: _iconBox(Icons.email_outlined, theme),
                title: Text(l10n?.email ?? 'Email', style: TextStyle(fontSize: 14)),
                trailing: Text(
                  email,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w300),
                ),
              );
            },
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
