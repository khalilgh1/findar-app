import 'package:flutter/material.dart';
import 'package:findar/l10n/app_localizations.dart';

class AgentCard extends StatelessWidget {
  final String agentName;
  final String agentCompany;
  final String agentImage;
  final String? agentId;

  const AgentCard({
    super.key,
    required this.agentName,
    required this.agentCompany,
    required this.agentImage,
    this.agentId,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Builder(
          builder: (context) {
            var l10n = AppLocalizations.of(context);
            return Text(
              l10n?.listedBy ?? 'Listed By',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            );
          },
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            if (agentId != null && agentId!.isNotEmpty) {
              Navigator.pushNamed(context, '/user-profile', arguments: agentId);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.primary),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: agentImage.startsWith('http')
                      ? NetworkImage(agentImage)
                      : AssetImage(agentImage) as ImageProvider,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        agentName,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        agentCompany,
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.phone, color: colorScheme.primary),
                  onPressed: () {
                    // Handle phone call
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.message, color: colorScheme.primary),
                  onPressed: () {
                    // Handle message
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
