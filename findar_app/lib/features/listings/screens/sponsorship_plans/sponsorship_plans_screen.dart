import 'package:flutter/material.dart';

import 'package:findar/core/models/property_listing_model.dart';
import 'package:findar/core/models/sponsorship_plan.dart';
import 'package:findar/core/motion/motion.dart';
import 'package:findar/core/theme/findar_tokens.dart';
import 'package:findar/core/widgets/decor/decor.dart';
import 'package:findar/core/widgets/f_icon.dart';
import 'package:findar/core/widgets/listing_widgets.dart';
import 'package:findar/core/widgets/ui.dart';
import 'package:findar/l10n/app_localizations.dart';

/// Localized name, icon and feature list for a plan. Analytics features were
/// dropped: they don't exist.
extension PlanCopy on SponsorshipPlan {
  String label(AppLocalizations l10n) => switch (id) {
        'basic' => l10n.basicSponsor,
        'premium' => l10n.premiumSponsor,
        'agency' => l10n.agencySponsorPlan,
        _ => name,
      };

  FIconData get icon => switch (id) {
        'premium' => FIcons.star,
        'agency' => FIcons.building,
        _ => FIcons.bolt,
      };

  List<String> featureList(AppLocalizations l10n) => switch (id) {
        'basic' => [l10n.featuredOnHome],
        'premium' => [
            l10n.featuredOnHome,
            l10n.priorityInSearch,
            l10n.boostedBadgeFeature
          ],
        'agency' => [
            l10n.topPriority,
            l10n.boostedBadgeFeature,
            l10n.dedicatedSupport
          ],
        _ => const [],
      };

  int get days => durationMonths * 30;
}

class SponsorshipPlansScreen extends StatefulWidget {
  const SponsorshipPlansScreen({super.key, required this.listing});
  final PropertyListing listing;

  @override
  State<SponsorshipPlansScreen> createState() => _SponsorshipPlansScreenState();
}

class _SponsorshipPlansScreenState extends State<SponsorshipPlansScreen> {
  final _plans = SponsorshipPlan.getPlans();
  String _selected = 'premium';

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    final l10n = AppLocalizations.of(context)!;
    final l = widget.listing;

    return Scaffold(
      backgroundColor: c.bg,
      body: Stack(children: [
        const SoftTop(height: 220),
        SafeArea(
          bottom: false,
          child: Column(children: [
            FTopBar(title: l10n.boostListing),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                children: [
                  Text(l10n.boostIntro,
                      style: context.tt.bodyLarge?.copyWith(color: c.muted)),
                  const SizedBox(height: 16),
                  ListingMiniCard(listing: l),
                  const SizedBox(height: 16),
                  for (var i = 0; i < _plans.length; i++) ...[
                    Entrance(
                      index: i,
                      child: _PlanCard(
                        plan: _plans[i],
                        selected: _plans[i].id == _selected,
                        popular: _plans[i].id == 'premium',
                        onTap: () => setState(() => _selected = _plans[i].id),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
            StickyBar(
              child: FButton(
                label: l10n.continueToPayment,
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/payment-confirmation',
                  arguments: {
                    'listing': l,
                    'plan': _plans.firstWhere((p) => p.id == _selected),
                  },
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

/// Listing summary on surf (photo, title, location · price).
class ListingMiniCard extends StatelessWidget {
  const ListingMiniCard({super.key, required this.listing});
  final PropertyListing listing;

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration:
          BoxDecoration(color: c.surf, borderRadius: BorderRadius.circular(18)),
      child: Row(children: [
        ListingPhoto(url: listing.image, width: 64, height: 64, radius: 12),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(listing.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.tt.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800)),
              Text(
                  '${listing.location} · ${formatPrice(context, listing.price)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.tt.bodySmall),
            ],
          ),
        ),
      ]),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.selected,
    required this.popular,
    required this.onTap,
  });

  final SponsorshipPlan plan;
  final bool selected;
  final bool popular;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      button: true,
      child: Pressable(
        button: false,
        scale: 0.98,
        onTap: () {
          Motion.softHaptic();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: selected ? c.accentT : c.bg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: selected ? c.accent : c.line, width: selected ? 2 : 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(children: [
            Deco(
              end: -50,
              top: -60,
              child: DecorCircle(
                  size: 150,
                  color:
                      selected ? c.accent.withValues(alpha: 0.10) : c.accentT),
            ),
            const Deco(end: 26, bottom: 22, child: Sparkle(size: 12)),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: selected ? FindarColors.brandGradient : null,
                        color: selected ? null : c.accentT,
                        boxShadow: selected
                            ? const [
                                BoxShadow(
                                    color: Color(0x4D0A5FC2),
                                    blurRadius: 18,
                                    offset: Offset(0, 8))
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: FIcon(plan.icon,
                          size: 22,
                          strokeWidth: 2,
                          color: selected ? Colors.white : c.accent),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(plan.label(l10n),
                                  style: context.tt.titleMedium),
                              if (popular)
                                Container(
                                  height: 24,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  decoration: BoxDecoration(
                                      color: c.amber,
                                      borderRadius: BorderRadius.circular(99)),
                                  child: Center(
                                    widthFactor: 1,
                                    child: Text(l10n.mostChosen,
                                        style: const TextStyle(
                                            color: FindarColors.onAmber,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800)),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                              l10n.planPriceDays(
                                  formatPrice(context, plan.priceDZD),
                                  l10n.daysCount(plan.days)),
                              style: context.tt.bodySmall
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    RadioDot(selected: selected, size: 24),
                  ]),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 60),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final f in plan.featureList(l10n))
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(children: [
                              FIcon(FIcons.check,
                                  size: 16, strokeWidth: 2.4, color: c.green),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(f,
                                    style: context.tt.bodyMedium?.copyWith(
                                        color: c.muted,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ]),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
