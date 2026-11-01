import 'package:flutter/material.dart';

import 'package:findar/core/models/property_listing_model.dart';
import 'package:findar/core/motion/motion.dart';
import 'package:findar/core/theme/findar_tokens.dart';
import 'package:findar/core/widgets/decor/decor.dart';
import 'package:findar/core/widgets/f_icon.dart';
import 'package:findar/core/widgets/listing_widgets.dart';
import 'package:findar/core/widgets/ui.dart';
import 'package:findar/l10n/app_localizations.dart';

/// Success after a boost: the spot springs in and the bolt pops.
class BoostConfirmedScreen extends StatefulWidget {
  const BoostConfirmedScreen({super.key, required this.listing});
  final PropertyListing listing;

  @override
  State<BoostConfirmedScreen> createState() => _BoostConfirmedScreenState();
}

class _BoostConfirmedScreenState extends State<BoostConfirmedScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900));
  late final Animation<double> _spot = CurvedAnimation(
      parent: _c, curve: const Interval(0, 0.6, curve: Curves.elasticOut));
  late final Animation<double> _bolt = CurvedAnimation(
      parent: _c, curve: const Interval(0.35, 1, curve: Curves.elasticOut));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_c.status == AnimationStatus.dismissed) {
      Motion.reduced(context) ? _c.value = 1 : _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    final l10n = AppLocalizations.of(context)!;
    final title = widget.listing.title;

    return Scaffold(
      backgroundColor: c.bg,
      body: Stack(children: [
        const SoftTop(height: 420),
        SafeArea(
          child: Column(children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: Tween(begin: 0.6, end: 1.0).animate(_spot),
                      child: SpotIllustration(
                        size: 150,
                        child: ScaleTransition(
                          scale: _bolt,
                          child: FIcon(FIcons.bolt,
                              size: 46,
                              filled: true,
                              strokeWidth: 1.4,
                              color: c.amber),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(l10n.boostedTitle,
                        textAlign: TextAlign.center,
                        style:
                            context.tt.headlineLarge?.copyWith(fontSize: 28)),
                    const SizedBox(height: 10),
                    Text(l10n.boostedBody(title),
                        textAlign: TextAlign.center,
                        style: context.tt.bodyLarge?.copyWith(color: c.muted)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(children: [
                Expanded(
                  child: FButton(
                    label: l10n.viewListing,
                    kind: FButtonKind.secondary,
                    onPressed: () {
                      Navigator.pop(context);
                      openListing(context, widget.listing);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FButton(
                    label: l10n.done,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ]),
    );
  }
}
