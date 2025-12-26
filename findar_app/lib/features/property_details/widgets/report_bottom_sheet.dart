import 'package:flutter/material.dart';
import 'package:findar/l10n/app_localizations.dart';

class ReportReason {
  final String Function(AppLocalizations) titleBuilder;
  final IconData icon;

  const ReportReason({
    required this.titleBuilder,
    required this.icon,
  });

  static List<ReportReason> get reasons => [
    ReportReason(
      titleBuilder: (l10n) => l10n.inaccurateInformation,
      icon: Icons.info_outline,
    ),
    ReportReason(
      titleBuilder: (l10n) => l10n.fraudulentListing,
      icon: Icons.warning_amber_outlined,
    ),
    ReportReason(
      titleBuilder: (l10n) => l10n.inappropriateContent,
      icon: Icons.block_outlined,
    ),
    ReportReason(
      titleBuilder: (l10n) => l10n.propertyNotAvailable,
      icon: Icons.home_outlined,
    ),
  ];
}

class ReportBottomSheet extends StatelessWidget {
  final Function(String) onReasonSelected;

  const ReportBottomSheet({
    super.key,
    required this.onReasonSelected,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(screenWidth * 0.05),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.reportProperty,
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            l10n.selectReportReason,
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: ReportReason.reasons.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Theme.of(context).dividerColor,
            ),
            itemBuilder: (context, index) {
              final reason = ReportReason.reasons[index];
              return _ReportReasonTile(
                reason: reason,
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                onTap: () {
                  Navigator.pop(context);
                  onReasonSelected(reason.titleBuilder(l10n));
                },
              );
            },
          ),
          SizedBox(height: screenHeight * 0.02),
        ],
      ),
    );
  }
}

class _ReportReasonTile extends StatelessWidget {
  final ReportReason reason;
  final double screenWidth;
  final double screenHeight;
  final VoidCallback onTap;

  const _ReportReasonTile({
    required this.reason,
    required this.screenWidth,
    required this.screenHeight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.02,
        vertical: screenHeight * 0.005,
      ),
      leading: Icon(
        reason.icon,
        color: Theme.of(context).colorScheme.primary,
        size: screenWidth * 0.06,
      ),
      title: Text(
        reason.titleBuilder(l10n),
        style: TextStyle(
          fontSize: screenWidth * 0.04,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      onTap: onTap,
    );
  }
}
