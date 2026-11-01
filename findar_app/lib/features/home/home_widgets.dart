import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:findar/core/motion/motion.dart';
import 'package:findar/core/theme/findar_tokens.dart';
import 'package:findar/core/widgets/decor/decor.dart';
import 'package:findar/core/widgets/f_icon.dart';
import 'package:findar/core/widgets/listing_widgets.dart';
import 'package:findar/features/create_listing/open_create_listing.dart';
import 'package:findar/features/search/search_request.dart';
import 'package:findar/l10n/app_localizations.dart';

/// Shared-element tag between the Home search pill and the results field.
const kSearchPillHero = 'search-pill';

/// A hashtag on the hero card: label, position, tilt, and the search it runs.
class _Tag {
  const _Tag(this.label, this.request,
      {this.start,
      this.end,
      required this.top,
      required this.rot,
      required this.phase});
  final String label;
  final SearchRequest request;
  final double? start, end;
  final double top, rot, phase;
}

/// Blue hero card: title, glass search pill with a filter button, and
/// floating hashtag chips (±4px over 6 s, offset phases, paused while the
/// page scrolls or under reduced motion; one ticker drives all five).
class HeroSearchCard extends StatelessWidget {
  const HeroSearchCard({super.key, required this.floatPaused});
  final ValueListenable<bool> floatPaused;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tags = [
      _Tag(l10n.tagHydra, const SearchRequest(query: 'Hydra'),
          start: 22, top: 24, rot: -6, phase: 0),
      _Tag(l10n.tagForRent, const SearchRequest(listingType: 'rent'),
          end: 24, top: 30, rot: 5, phase: 0.22),
      _Tag(l10n.tagVilla, const SearchRequest(buildingType: 'villa'),
          start: 26, top: 234, rot: 4, phase: 0.48),
      _Tag(l10n.tagOran, const SearchRequest(query: 'Oran'),
          start: 124, top: 240, rot: -4, phase: 0.66),
      _Tag(l10n.tagF3, const SearchRequest(query: 'F3'),
          end: 30, top: 232, rot: -6, phase: 0.86),
    ];

    return RepaintBoundary(
      child: BlueCard(
        height: 290,
        shadowOpacity: 0.28,
        children: [
          const Deco(
            start: 0,
            end: 0,
            top: 22,
            child: Center(
                child: Sparkle(size: 14, color: Colors.white, opacity: 0.6)),
          ),
          Positioned.fill(
              child: _FloatingTags(tags: tags, paused: floatPaused)),
          Positioned(
            left: 24,
            right: 24,
            top: 78,
            child: Semantics(
              header: true,
              child: Text(
                l10n.heroTitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: context.tt.displaySmall?.copyWith(color: Colors.white),
              ),
            ),
          ),
          Positioned(
            left: 18,
            right: 18,
            top: 164,
            height: 56,
            child: _GlassSearchPill(
              hint: l10n.searchCityHint,
              filtersLabel: AppLocalizations.of(context)!.filters,
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingTags extends StatelessWidget {
  const _FloatingTags({required this.tags, required this.paused});
  final List<_Tag> tags;
  final ValueListenable<bool> paused;

  // Cycles per 30 s loop -> periods of 6, 5, 7.5, 6 and 5 s.
  static const _cycles = [5, 6, 4, 5, 6];

  @override
  Widget build(BuildContext context) {
    final chips = [
      for (final t in tags)
        Transform.rotate(
          angle: t.rot * math.pi / 180,
          child: GlassTag(
            label: t.label,
            onTap: () => Navigator.pushNamed(context, '/search-results',
                arguments: t.request),
          ),
        ),
    ];
    return FloatClock(
      paused: paused,
      period: const Duration(seconds: 30),
      builder: (context, v, _) => Stack(children: [
        for (var i = 0; i < tags.length; i++)
          Deco(
            start: tags[i].start,
            end: tags[i].end,
            top: tags[i].top,
            child: Transform.translate(
              offset: Offset(0,
                  math.sin((v * _cycles[i] + tags[i].phase) * 2 * math.pi) * 4),
              child: chips[i],
            ),
          ),
      ]),
    );
  }
}

class _GlassSearchPill extends StatelessWidget {
  const _GlassSearchPill({required this.hint, required this.filtersLabel});
  final String hint;
  final String filtersLabel;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned.fill(
        child: Semantics(
          button: true,
          label: hint,
          excludeSemantics: true,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.pushNamed(context, '/search-results',
                arguments: const SearchRequest(focus: true)),
            child: Hero(
              tag: kSearchPillHero,
              flightShuttleBuilder: searchPillShuttle,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.38)),
                ),
              ),
            ),
          ),
        ),
      ),
      IgnorePointer(
        child: Padding(
          padding: const EdgeInsetsDirectional.only(start: 18, end: 6),
          child: Row(children: [
            const FIcon(FIcons.search, size: 20, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(hint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 44),
          ]),
        ),
      ),
      PositionedDirectional(
        end: 6,
        top: 6,
        child: Semantics(
          button: true,
          label: filtersLabel,
          excludeSemantics: true,
          child: Pressable(
            button: false,
            scale: 0.92,
            onTap: () => Navigator.pushNamed(context, '/filtering',
                arguments: true /* opened from Home */),
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: const FIcon(FIcons.sliders,
                  size: 20, color: FindarColors.brandBlue),
            ),
          ),
        ),
      ),
    ]);
  }
}

/// Morphs the translucent hero pill into the solid surface field.
Widget searchPillShuttle(BuildContext flightContext, Animation<double> anim,
    HeroFlightDirection dir, BuildContext from, BuildContext to) {
  final surf = Theme.of(to).extension<FindarColors>()?.surf ?? Colors.white;
  final start = Colors.white.withValues(alpha: 0.16);
  return AnimatedBuilder(
    animation: anim,
    builder: (context, _) {
      final t = Motion.emphasized.transform(anim.value);
      final col = dir == HeroFlightDirection.push
          ? Color.lerp(start, surf, t)
          : Color.lerp(start, surf, 1 - t);
      return DecoratedBox(
        decoration:
            BoxDecoration(color: col, borderRadius: BorderRadius.circular(999)),
      );
    },
  );
}

/// Dark "List your property" promo → Create listing.
class PostBanner extends StatelessWidget {
  const PostBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Pressable(
      semanticLabel: l10n.listYourProperty,
      onTap: () => openCreateListing(context),
      child: Container(
        decoration: BoxDecoration(
          gradient: FindarColors.promoGradient,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(children: [
          const Deco(
            end: -40,
            top: -60,
            child: DecorCircle(
              size: 170,
              gradient: RadialGradient(colors: [
                Color(0x8C2F86E8),
                Color(0x002F86E8),
              ]),
            ),
          ),
          const Deco(
              end: 70,
              bottom: 16,
              child: Sparkle(size: 12, color: Colors.white, opacity: 0.5)),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(children: [
              SizedBox(
                width: 58,
                height: 58,
                child: Stack(clipBehavior: Clip.none, children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: const FIcon(FIcons.home,
                        size: 26,
                        strokeWidth: 2,
                        color: FindarColors.brandBlue),
                  ),
                  PositionedDirectional(
                    end: -2,
                    bottom: -2,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: context.fc.amber,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: const FIcon(FIcons.plus,
                          size: 12,
                          strokeWidth: 3,
                          color: FindarColors.onAmber),
                    ),
                  ),
                ]),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.listYourProperty,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text(l10n.listYourPropertySub,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const FIcon(FIcons.chev,
                  size: 22, strokeWidth: 2.2, color: Colors.white),
            ]),
          ),
        ]),
      ),
    );
  }
}

/// 136x148 "Browse by type" card. Presses to 0.97; the chevron nudges 2px.
class TypeCard extends StatefulWidget {
  const TypeCard({super.key, required this.type});
  final String type;

  @override
  State<TypeCard> createState() => _TypeCardState();
}

class _TypeCardState extends State<TypeCard> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    final l10n = AppLocalizations.of(context)!;
    final label = propertyTypeLabel(widget.type, l10n);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Listener(
        onPointerDown: (_) => setState(() => _down = true),
        onPointerUp: (_) => setState(() => _down = false),
        onPointerCancel: (_) => setState(() => _down = false),
        child: Pressable(
          button: false,
          onTap: () => Navigator.pushNamed(context, '/search-results',
              arguments: SearchRequest(buildingType: widget.type)),
          child: Container(
            width: 136,
            height: 148,
            decoration: BoxDecoration(
              color: c.bg,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: c.line),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(children: [
              Deco(
                  end: -46,
                  top: -46,
                  child: DecorCircle(size: 116, color: c.accentT)),
              Deco(
                  start: -14,
                  bottom: 34,
                  child: DecorCircle(
                      size: 34, color: c.accentT.withValues(alpha: 0.8))),
              const Deco(end: 22, bottom: 46, child: Sparkle(size: 12)),
              Deco(
                start: 14,
                top: 14,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: c.accentT,
                    shape: BoxShape.circle,
                    border: Border.all(color: c.line),
                  ),
                  alignment: Alignment.center,
                  child: FIcon(propertyTypeIcon(widget.type),
                      size: 24, strokeWidth: 2, color: c.accent),
                ),
              ),
              Deco(
                end: 12,
                top: 12,
                child: AnimatedSlide(
                  offset: Offset(_down ? (rtl ? -0.07 : 0.07) : 0, 0),
                  duration: const Duration(milliseconds: 140),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: c.bg,
                      shape: BoxShape.circle,
                      border: Border.all(color: c.line),
                    ),
                    alignment: Alignment.center,
                    child: FIcon(FIcons.chev,
                        size: 15, strokeWidth: 2.2, color: c.accent),
                  ),
                ),
              ),
              Deco(
                start: 14,
                bottom: 14,
                end: 8,
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.tt.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w800)),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Small Findar lockup: house mark + lowercase wordmark.
class FindarLockup extends StatelessWidget {
  const FindarLockup({super.key, this.size = 22, this.color, this.markColor});
  final double size;
  final Color? color;
  final Color? markColor;

  @override
  Widget build(BuildContext context) {
    final ink = color ?? context.fc.ink;
    return Semantics(
      label: 'Findar',
      excludeSemantics: true,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        FindarMark(width: size * 1.25, color: markColor ?? ink),
        SizedBox(width: size * 0.32),
        Text('findar',
            textDirection: TextDirection.ltr,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: size,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.045 * size,
              height: 1,
              color: ink,
            )),
      ]),
    );
  }
}

/// The house-with-nested-f mark, drawn as a vector. [progress] 0..1 reveals
/// the house outline then the f (used by the splash animation).
class FindarMark extends StatelessWidget {
  const FindarMark({
    super.key,
    required this.width,
    this.color = Colors.white,
    this.progress = 1,
  });
  final double width;
  final Color color;
  final double progress;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        height: width * 80 / 104,
        child: CustomPaint(painter: FindarMarkPainter(color, progress)),
      );
}

class FindarMarkPainter extends CustomPainter {
  FindarMarkPainter(this.color, this.progress);
  final Color color;
  final double progress;

  static final Path _house = Path()
    ..moveTo(11, 80)
    ..lineTo(11, 34)
    ..lineTo(52, 10)
    ..lineTo(93, 34);
  static final Path _f = Path()
    ..moveTo(43, 80)
    ..lineTo(43, 53)
    ..lineTo(55, 45.5)
    ..lineTo(74, 56.5);

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 104;
    canvas.scale(k);
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 17
      ..strokeJoin = StrokeJoin.round;
    if (progress >= 1) {
      canvas.drawPath(_house, p);
      canvas.drawPath(_f, p);
      return;
    }
    // House draws over 0..0.6, f over 0.45..1 (450 ms each, 120 ms overlap).
    final a = (progress / 0.6).clamp(0.0, 1.0);
    final b = ((progress - 0.45) / 0.55).clamp(0.0, 1.0);
    void partial(Path path, double t) {
      if (t <= 0) return;
      for (final m in path.computeMetrics()) {
        canvas.drawPath(m.extractPath(0, m.length * t), p);
      }
    }

    partial(_house, Curves.easeInOut.transform(a));
    partial(_f, Curves.easeInOut.transform(b));
  }

  @override
  bool shouldRepaint(FindarMarkPainter old) =>
      old.color != color || old.progress != progress;
}
