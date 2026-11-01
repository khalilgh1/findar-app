import 'dart:collection';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:findar/core/models/property_listing_model.dart';
import 'package:findar/core/motion/motion.dart';
import 'package:findar/core/theme/findar_tokens.dart';
import 'package:findar/core/widgets/f_icon.dart';
import 'package:findar/l10n/app_localizations.dart';
import 'package:findar/logic/cubits/property_details_cubit.dart';
import 'package:findar/logic/cubits/saved_listings_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ---------------------------------------------------------------- prices

/// Groups digits with a narrow no-break space: 52000000 -> "52 000 000".
String groupDigits(num value) {
  final s = value.round().abs().toString();
  final b = StringBuffer(value < 0 ? '-' : '');
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(' ');
    b.write(s[i]);
  }
  return b.toString();
}

/// "52 000 000 DA" (Arabic: "52 000 000 دج"). The single price format.
String formatPrice(BuildContext context, num value) =>
    '${groupDigits(value)} ${AppLocalizations.of(context)!.currencyDa}';

/// Price in the listing scale; rent appends a muted "/ month".
class PriceText extends StatelessWidget {
  const PriceText({
    super.key,
    required this.price,
    this.rent = false,
    this.size = 20,
    this.color,
  });

  final num price;
  final bool rent;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    final l10n = AppLocalizations.of(context)!;
    final base = context.tt.titleLarge!;
    return Text.rich(
      TextSpan(children: [
        TextSpan(
          text: formatPrice(context, price),
          style: base.copyWith(
              fontSize: size,
              color: color ?? c.ink,
              letterSpacing: -0.02 * size),
        ),
        if (rent)
          TextSpan(
            text: ' ${l10n.perMonth}',
            style: base.copyWith(
                fontSize: size - 7 < 12 ? 12 : size - 7,
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
                color: c.muted),
          ),
      ]),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

// ---------------------------------------------------------------- types

String propertyTypeLabel(String type, AppLocalizations l10n) {
  switch (type.toLowerCase()) {
    case 'house':
      return l10n.house;
    case 'apartment':
      return l10n.apartment;
    case 'villa':
      return l10n.villa;
    case 'studio':
      return l10n.studio;
    case 'office':
      return l10n.office;
    default:
      return type;
  }
}

FIconData propertyTypeIcon(String type) {
  switch (type.toLowerCase()) {
    case 'apartment':
      return FIcons.apartment;
    case 'villa':
      return FIcons.villa;
    case 'studio':
      return FIcons.studio;
    case 'office':
      return FIcons.building;
    default:
      return FIcons.home;
  }
}

const kPropertyTypes = ['house', 'apartment', 'villa', 'studio', 'office'];

bool isRent(String classification) =>
    classification.toLowerCase().contains('rent');

// ---------------------------------------------------------------- photo

/// Listing photo: network (cached, decoded at display size), local file or
/// asset. Missing or broken images show a calm "No photo" block instead of
/// an endless spinner.
class ListingPhoto extends StatelessWidget {
  const ListingPhoto({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.radius = 20,
    this.heroTag,
    this.semanticLabel,
  });

  final String? url;
  final double? width;
  final double? height;
  final double radius;
  final Object? heroTag;
  final String? semanticLabel;

  /// Last decode width per URL (bounded), to reuse as a placeholder.
  static final Map<String, int> _decodedWidth = _BoundedMap();

  static bool hasImage(String? url) {
    final s = url?.trim() ?? '';
    return s.isNotEmpty && s.toLowerCase() != 'null';
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final logicalW =
        (width == null || width == double.infinity) ? mq.size.width : width!;
    final cacheW = (logicalW * mq.devicePixelRatio).round();
    final u = url?.trim() ?? '';

    Widget img;
    if (!hasImage(u)) {
      img = _NoPhoto(width: width, height: height);
    } else if (u.startsWith('http')) {
      img = CachedNetworkImage(
        imageUrl: u,
        width: width,
        height: height,
        fit: BoxFit.cover,
        memCacheWidth: cacheW,
        fadeInDuration: const Duration(milliseconds: 180),
        imageBuilder: (context, provider) {
          _decodedWidth[u] = cacheW;
          return Image(
              image: provider,
              width: width,
              height: height,
              fit: BoxFit.cover,
              gaplessPlayback: true);
        },
        placeholder: (context, _) {
          // Show the size already decoded elsewhere (e.g. the card the
          // Hero flew from) while this size decodes: no grey flash.
          final w = _decodedWidth[u];
          if (w != null && w != cacheW) {
            return Image(
              image: ResizeImage(CachedNetworkImageProvider(u), width: w),
              width: width,
              height: height,
              fit: BoxFit.cover,
              gaplessPlayback: true,
            );
          }
          return ColoredBox(
              color: context.fc.surf,
              child: SizedBox(width: width, height: height));
        },
        errorWidget: (context, _, __) => _NoPhoto(width: width, height: height),
      );
    } else if (u.startsWith('assets/')) {
      img = Image.asset(u,
          width: width, height: height, fit: BoxFit.cover, cacheWidth: cacheW);
    } else {
      img = Image.file(
        File(u),
        width: width,
        height: height,
        fit: BoxFit.cover,
        cacheWidth: cacheW,
        errorBuilder: (context, _, __) =>
            _NoPhoto(width: width, height: height),
      );
    }

    Widget child = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Semantics(
        image: true,
        label: semanticLabel,
        excludeSemantics: true,
        child: img,
      ),
    );
    if (heroTag != null) {
      child = Hero(
        tag: heroTag!,
        // Animate the corner radius smoothly during the flight.
        flightShuttleBuilder: (ctx, anim, dir, from, to) => AnimatedBuilder(
          animation: anim,
          builder: (ctx, _) => ClipRRect(
            borderRadius: BorderRadius.circular(radius *
                (dir == HeroFlightDirection.push
                    ? 1 - anim.value
                    : anim.value)),
            child: img,
          ),
        ),
        child: child,
      );
    }
    return child;
  }
}

/// Small insertion-ordered map that forgets its oldest entries.
class _BoundedMap extends MapBase<String, int> {
  final _m = <String, int>{};
  @override
  int? operator [](Object? key) => _m[key];
  @override
  void operator []=(String key, int value) {
    _m.remove(key);
    _m[key] = value;
    if (_m.length > 300) _m.remove(_m.keys.first);
  }

  @override
  void clear() => _m.clear();
  @override
  Iterable<String> get keys => _m.keys;
  @override
  int? remove(Object? key) => _m.remove(key);
}

class _NoPhoto extends StatelessWidget {
  const _NoPhoto({this.width, this.height});
  final double? width, height;

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    return Container(
      width: width,
      height: height,
      color: c.surf,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FIcon(FIcons.building, size: 28, color: c.muted),
          const SizedBox(height: 6),
          Text(AppLocalizations.of(context)!.noPhoto,
              style: context.tt.bodySmall?.copyWith(fontSize: 12)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- badges

class BoostedBadge extends StatelessWidget {
  const BoostedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: context.fc.amber,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const FIcon(FIcons.bolt,
            size: 14,
            filled: true,
            strokeWidth: 1.2,
            color: FindarColors.onAmber),
        const SizedBox(width: 4),
        Text(AppLocalizations.of(context)!.boostedBadge,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: FindarColors.onAmber)),
      ]),
    );
  }
}

/// Online / Offline status pill (green dot when online).
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.online});
  final bool online;

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    final fg = online ? c.green : c.muted;
    final l10n = AppLocalizations.of(context)!;
    return AnimatedContainer(
      duration: Motion.short,
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: online ? c.greenT : c.surf,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(online ? l10n.online : l10n.offline,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w800, color: fg)),
      ]),
    );
  }
}

/// Small grey pill ("For sale", "Villa").
class TagPill extends StatelessWidget {
  const TagPill(this.label, {super.key});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: context.fc.surf,
          borderRadius: BorderRadius.circular(999),
        ),
        // widthFactor 1: hug the label (alignment alone would fill a Wrap).
        child: Center(
          widthFactor: 1,
          child: Text(label,
              style: context.tt.labelMedium
                  ?.copyWith(fontSize: 12, fontWeight: FontWeight.w800)),
        ),
      );
}

// ---------------------------------------------------------------- save

/// Round bookmark button. Flips optimistically, springs 1 → 1.25 → 1 with a
/// light haptic, and reverts if [onToggle] reports failure.
class SaveButton extends StatefulWidget {
  const SaveButton({
    super.key,
    required this.saved,
    required this.onToggle,
    this.size = 40,
    this.onPhoto = true,
  });

  final bool saved;

  /// Called with the new value; return true on success.
  final Future<bool> Function(bool save) onToggle;
  final double size;

  /// true on top of photos (white chip); false on plain surfaces (surf chip).
  final bool onPhoto;

  @override
  State<SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<SaveButton> {
  late bool _saved = widget.saved;
  bool _busy = false;
  int _pops = 0;

  @override
  void didUpdateWidget(SaveButton old) {
    super.didUpdateWidget(old);
    if (!_busy && old.saved != widget.saved) _saved = widget.saved;
  }

  Future<void> _tap() async {
    if (_busy) return;
    final next = !_saved;
    Motion.lightHaptic();
    setState(() {
      _busy = true;
      _saved = next;
      if (next) _pops++;
    });
    final ok = await widget.onToggle(next);
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (!ok) _saved = !next;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    final l10n = AppLocalizations.of(context)!;
    final bg = widget.onPhoto ? const Color(0xF0FFFFFF) : c.surf;
    final fg = widget.onPhoto ? const Color(0xFF111317) : c.ink;
    return Semantics(
      button: true,
      toggled: _saved,
      label: _saved ? l10n.removeFromSaved : l10n.save,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: _tap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox.square(
          dimension: widget.size < 44 ? 44 : widget.size,
          child: Center(
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: PopOnChange(
                trigger: _pops,
                child: FIcon(
                  FIcons.bookmark,
                  key: ValueKey(_saved),
                  size: widget.size * 0.5,
                  filled: _saved,
                  color: fg,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Rebuilds [builder] when listing [id]'s saved state changes in
/// [SavedListingsCubit]. Safe inside lazy list item builders (unlike
/// `context.select`, which crashed there).
class SavedSelector extends StatelessWidget {
  const SavedSelector({super.key, required this.id, required this.builder});
  final int id;
  final Widget Function(BuildContext context, bool saved) builder;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SavedListingsCubit, Map<String, dynamic>, bool>(
      selector: (s) => (s['data'] as List? ?? const []).any((l) => l.id == id),
      builder: builder,
    );
  }
}

// ---------------------------------------------------------------- stats

class ListingStats extends StatelessWidget {
  const ListingStats({super.key, required this.listing, this.size = 13});
  final PropertyListing listing;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    final l10n = AppLocalizations.of(context)!;
    final style =
        TextStyle(fontSize: size, fontWeight: FontWeight.w600, color: c.muted);
    Widget item(FIconData i, String t) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FIcon(i, size: 16, color: c.muted),
            const SizedBox(width: 5),
            Text(t, style: style),
          ],
        );
    final area = listing.area;
    return Wrap(
      spacing: 14,
      runSpacing: 4,
      children: [
        if (listing.bedrooms > 0)
          item(FIcons.bed, l10n.bdShort(listing.bedrooms)),
        item(FIcons.bath, l10n.baShort(listing.bathrooms)),
        if (area != null && area > 0) item(FIcons.area, '\u2066${area.round()} m²\u2069'),
      ],
    );
  }
}

Widget _location(BuildContext context, String text, {double size = 13}) {
  final c = context.fc;
  return Row(children: [
    FIcon(FIcons.pin, size: size + 2, color: c.muted),
    const SizedBox(width: 4),
    Expanded(
      child: Text(text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontSize: size, fontWeight: FontWeight.w500, color: c.muted)),
    ),
  ]);
}

// ---------------------------------------------------------------- navigation

/// Arguments for '/property-details' so the photo can fly in as a Hero and
/// show while the details load.
class ListingRouteArgs {
  const ListingRouteArgs({required this.id, this.heroTag, this.image});
  final int id;
  final Object? heroTag;
  final String? image;
}

void openListing(BuildContext context, PropertyListing l, {Object? heroTag}) {
  context.read<PropertyDetailsCubit>().fetchPropertyDetails(l.id);
  Navigator.pushNamed(context, '/property-details',
      arguments: ListingRouteArgs(id: l.id, heroTag: heroTag, image: l.image));
}

// ---------------------------------------------------------------- cards

/// 296-wide card for the Sponsored carousel.
class ListingFeatureCard extends StatelessWidget {
  const ListingFeatureCard({
    super.key,
    required this.listing,
    required this.saved,
    required this.onToggleSave,
    this.heroPrefix = 'feat',
    this.width = 296,
  });

  final PropertyListing listing;
  final bool saved;
  final Future<bool> Function(bool) onToggleSave;
  final String heroPrefix;
  final double width;

  @override
  Widget build(BuildContext context) {
    final l = listing;
    final tag = '$heroPrefix-${l.id}';
    return Pressable(
      scale: 0.98,
      onTap: () => openListing(context, l, heroTag: tag),
      semanticLabel: l.title,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(children: [
              ListingPhoto(
                  url: l.image,
                  width: width,
                  height: 196,
                  heroTag: tag,
                  semanticLabel: '${l.title}, ${l.location}'),
              if (l.isBoosted)
                const PositionedDirectional(
                    top: 12, start: 12, child: BoostedBadge()),
              PositionedDirectional(
                top: 4,
                end: 4,
                child: SaveButton(saved: saved, onToggle: onToggleSave),
              ),
            ]),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PriceText(price: l.price, rent: isRent(l.classification)),
                  const SizedBox(height: 4),
                  Text(l.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.tt.titleSmall),
                  const SizedBox(height: 4),
                  _location(context, l.location),
                  const SizedBox(height: 8),
                  ListingStats(listing: l),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Row card (104 photo) for recent listings.
class ListingRowCard extends StatelessWidget {
  const ListingRowCard({
    super.key,
    required this.listing,
    this.saved = false,
    this.onToggleSave,
    this.heroPrefix = 'row',
    this.trailing,
  });

  final PropertyListing listing;
  final bool saved;
  final Future<bool> Function(bool)? onToggleSave;
  final String heroPrefix;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final l = listing;
    final tag = '$heroPrefix-${l.id}';
    return Pressable(
      scale: 0.98,
      onTap: () => openListing(context, l, heroTag: tag),
      semanticLabel: l.title,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListingPhoto(
              url: l.image, width: 104, height: 104, radius: 16, heroTag: tag),
          const SizedBox(width: 14),
          Expanded(
            child: SizedBox(
              height: 104,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.tt.titleSmall),
                  const SizedBox(height: 4),
                  _location(context, l.location),
                  const SizedBox(height: 4),
                  PriceText(
                      price: l.price, rent: isRent(l.classification), size: 16),
                  const SizedBox(height: 4),
                  ListingStats(listing: l, size: 12),
                ],
              ),
            ),
          ),
          if (trailing != null)
            trailing!
          else if (onToggleSave != null)
            SaveButton(
                saved: saved,
                onToggle: onToggleSave!,
                size: 36,
                onPhoto: false),
        ],
      ),
    );
  }
}

/// Full-width card (200 photo) for search results.
class ListingWideCard extends StatelessWidget {
  const ListingWideCard({
    super.key,
    required this.listing,
    required this.saved,
    required this.onToggleSave,
    this.heroPrefix = 'wide',
  });

  final PropertyListing listing;
  final bool saved;
  final Future<bool> Function(bool) onToggleSave;
  final String heroPrefix;

  @override
  Widget build(BuildContext context) {
    final l = listing;
    final tag = '$heroPrefix-${l.id}';
    return Pressable(
      scale: 0.98,
      onTap: () => openListing(context, l, heroTag: tag),
      semanticLabel: l.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(children: [
            ListingPhoto(
                url: l.image,
                width: double.infinity,
                height: 200,
                heroTag: tag,
                semanticLabel: '${l.title}, ${l.location}'),
            if (l.isBoosted)
              const PositionedDirectional(
                  top: 12, start: 12, child: BoostedBadge()),
            PositionedDirectional(
              top: 4,
              end: 4,
              child: SaveButton(saved: saved, onToggle: onToggleSave),
            ),
          ]),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.tt.titleSmall?.copyWith(
                            fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    _location(context, l.location),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: PriceText(
                    price: l.price, rent: isRent(l.classification), size: 17),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ListingStats(listing: l),
        ],
      ),
    );
  }
}

/// Two-column grid tile (Saved, Owner profile, Profile preview).
class ListingGridTile extends StatelessWidget {
  const ListingGridTile({
    super.key,
    required this.listing,
    this.saved,
    this.onToggleSave,
    this.photoHeight = 150,
    this.heroPrefix = 'grid',
    this.showLocation = true,
  });

  final PropertyListing listing;
  final bool? saved;
  final Future<bool> Function(bool)? onToggleSave;
  final double photoHeight;
  final String heroPrefix;
  final bool showLocation;

  @override
  Widget build(BuildContext context) {
    final l = listing;
    final tag = '$heroPrefix-${l.id}';
    return Pressable(
      scale: 0.97,
      onTap: () => openListing(context, l, heroTag: tag),
      semanticLabel: l.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(children: [
            ListingPhoto(
                url: l.image,
                width: double.infinity,
                height: photoHeight,
                radius: 18,
                heroTag: tag),
            if (onToggleSave != null)
              PositionedDirectional(
                top: 0,
                end: 0,
                child: SaveButton(
                    saved: saved ?? false, onToggle: onToggleSave!, size: 36),
              ),
          ]),
          const SizedBox(height: 8),
          PriceText(price: l.price, rent: isRent(l.classification), size: 15),
          const SizedBox(height: 2),
          Text(l.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.tt.titleSmall?.copyWith(fontSize: 14)),
          if (showLocation) ...[
            const SizedBox(height: 2),
            Text(l.location,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.tt.bodySmall?.copyWith(fontSize: 12)),
          ],
        ],
      ),
    );
  }
}
