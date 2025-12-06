import 'package:flutter/material.dart';
import '../../../../core/models/sponsorship_plan.dart';
import '../../../../core/models/property_listing_model.dart';
import '../../widgets/plan_card.dart';

class SponsorshipPlansScreen extends StatefulWidget {
  final PropertyListing listing;

  const SponsorshipPlansScreen({
    super.key,
    required this.listing,
  });

  @override
  State<SponsorshipPlansScreen> createState() => _SponsorshipPlansScreenState();
}

class _SponsorshipPlansScreenState extends State<SponsorshipPlansScreen> {
  SponsorshipPlan? _selectedPlan;
  final List<SponsorshipPlan> _plans = SponsorshipPlan.getPlans();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        centerTitle: false,
        title: Text(
          'Choose Sponsorship Plan',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
      body: Column(
        children: [
          // Property preview
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    widget.listing.image,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 80,
                        height: 80,
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.image,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.listing.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.listing.location,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Plans list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Select a plan to boost your property',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                ..._plans.map((plan) => PlanCard(
                      plan: plan,
                      isSelected: _selectedPlan?.id == plan.id,
                      onTap: () {
                        setState(() {
                          _selectedPlan = plan;
                        });
                      },
                    )),
              ],
            ),
          ),

          // Continue button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _selectedPlan == null
                    ? null
                    : () {
                        Navigator.pushNamed(
                          context,
                          '/payment-confirmation',
                          arguments: {
                            'listing': widget.listing,
                            'plan': _selectedPlan,
                          },
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  disabledBackgroundColor:
                      theme.colorScheme.onSurface.withValues(alpha: 0.12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Continue to Payment',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _selectedPlan == null
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.38)
                        : Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
