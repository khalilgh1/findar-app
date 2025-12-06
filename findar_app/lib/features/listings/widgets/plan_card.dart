import 'package:flutter/material.dart';
import '../../../core/models/sponsorship_plan.dart';
import 'package:findar/l10n/app_localizations.dart';

class PlanCard extends StatelessWidget {
  final SponsorshipPlan plan;
  final bool isSelected;
  final VoidCallback onTap;

  const PlanCard({
    super.key,
    required this.plan,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        
        // Get localized plan name
        String getLocalizedPlanName() {
          switch (plan.id) {
            case 'basic':
              return l10n.basicSponsor;
            case 'premium':
              return l10n.premiumSponsor;
            case 'agency':
              return l10n.agencySponsorPlan;
            default:
              return plan.name;
          }
        }
        
        // Get localized features
        List<String> getLocalizedFeatures() {
          return plan.features.map((feature) {
            switch (feature) {
              case 'Featured placement for 1 month':
              case 'Featured placement for 3 months':
              case 'Featured placement for 6 months':
                return l10n.featuredPlacement;
              case 'Priority in search results':
                return l10n.priorityInSearch;
              case 'Top priority in search results':
                return l10n.topPriority;
              case 'Basic analytics':
                return l10n.basicAnalytics;
              case 'Advanced analytics':
                return l10n.advancedAnalytics;
              case 'Premium analytics dashboard':
                return l10n.premiumAnalyticsDashboard;
              case 'Featured badge':
                return l10n.featuredBadge;
              case 'Dedicated support':
                return l10n.dedicatedSupport;
              default:
                return feature;
            }
          }).toList();
        }
        
        return GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline.withValues(alpha: 0.3),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with name and selection indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          getLocalizedPlanName(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${plan.priceDZD}',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          'DZD',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Duration and Payment Method
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${plan.durationMonths} ${plan.durationMonths == 1 ? 'Month' : 'Months'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.credit_card,
                        size: 16,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'EDAHABIA',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Divider
                  Divider(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
                  const SizedBox(height: 16),
                  
                  // Features list (localized)
                  ...getLocalizedFeatures().map((feature) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 20,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                feature,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
