import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:findar/core/motion/motion.dart';
import 'package:findar/core/theme/findar_tokens.dart';
import 'package:findar/core/utils/save_feedback.dart';
import 'package:findar/core/widgets/f_icon.dart';
import 'package:findar/core/widgets/listing_widgets.dart';
import 'package:findar/core/widgets/ui.dart';
import 'package:findar/features/property_details/widgets/report_bottom_sheet.dart';
import 'package:findar/l10n/app_localizations.dart';
import 'package:findar/logic/cubits/property_details_cubit.dart';
import 'package:findar/logic/cubits/saved_listings_cubit.dart';

const double _kPhotoHeight = 380;

class PropertyDetailsScreen extends StatefulWidget {
  const PropertyDetailsScreen({super.key});

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  ListingRouteArgs? _args;

  @override
  void initState() {
    super.initState();
    // Needed for the bookmark state; no-op if already loaded.
    context.read<SavedListingsCubit>().fetchSavedListings();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final a = ModalRoute.of(context)?.settings.arguments;
    if (a is ListingRouteArgs) _args = a;
  }

  void _report(int propertyId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom),
        child: ReportBottomSheet(
          onSubmit: (reason) => context
              .read<PropertyDetailsCubit>()
              .reportListing(propertyId: propertyId, reason: reason),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    return Scaffold(
      backgroundColor: c.bg,
      bottomNavigationBar:
          BlocBuilder<PropertyDetailsCubit, Map<String, dynamic>>(
        builder: (context, state) {
          final data = state['data'];
          if (state['state'] != 'done' || data is! Map || data.isEmpty) {
            return const SizedBox.shrink();
          }
          return _PriceBar(data: Map<String, dynamic>.from(data));
        },
      ),
      body: BlocBuilder<PropertyDetailsCubit, Map<String, dynamic>>(
        builder: (context, state) {
          final status = state['state'];
          final id = state['id'] as int? ?? _args?.id;
          final data = state['data'] is Map
              ? Map<String, dynamic>.from(state['data'] as Map)
              : <String, dynamic>{};

          if (status == 'done' && data.isNotEmpty) {
            return _Loaded(
              data: data,
              heroTag: _args?.id == id ? _args?.heroTag : null,
              onReport: () => _report(data['id'] as int),
            );
          }
          if (status == 'error' || status == 'notFound') {
            return _Problem(
              status: status as String,
              message: state['message'] as String?,
              onRetry: () => context.read<PropertyDetailsCubit>().retry(),
            );
          }
          return _Loading(
            image: _args?.id == id ? _args?.image : null,
            heroTag: _args?.id == id ? _args?.heroTag : null,
          );
        },
      ),
    );
  }
}

// ------------------------------------------------------------------ states

class _Loading extends StatelessWidget {
  const _Loading({this.image, this.heroTag});
  final String? image;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    final top = MediaQuery.paddingOf(context).top;
    return Stack(children: [
      ListView(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          ListingPhoto(
              url: image,
              width: double.infinity,
              height: _kPhotoHeight,
              radius: 0,
              heroTag: heroTag),
          Transform.translate(
            offset: const Offset(0, -28),
            child: Container(
              decoration: BoxDecoration(
                color: c.bg,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
              child: const Shimmer(child: _SheetSkeleton()),
            ),
          ),
        ],
      ),
      Positioned(
          top: top + 8, left: 16, child: const FBackButton(onPhoto: true)),
    ]);
  }
}

class _SheetSkeleton extends StatelessWidget {
  const _SheetSkeleton();

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    Widget b(double w, double h, [double r = 10]) => Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
              color: c.surf, borderRadius: BorderRadius.circular(r)),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [b(84, 26, 99), const SizedBox(width: 8), b(70, 26, 99)]),
        const SizedBox(height: 20),
        b(240, 26),
        const SizedBox(height: 10),
        b(180, 14),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: b(double.infinity, 92, 16)),
          const SizedBox(width: 10),
          Expanded(child: b(double.infinity, 92, 16)),
          const SizedBox(width: 10),
          Expanded(child: b(double.infinity, 92, 16)),
        ]),
        const SizedBox(height: 20),
        b(double.infinity, 14),
        const SizedBox(height: 8),
        b(double.infinity, 14),
        const SizedBox(height: 8),
        b(200, 14),
      ],
    );
  }
}

class _Problem extends StatelessWidget {
  const _Problem({required this.status, this.message, required this.onRetry});
  final String status;
  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final Widget body;
    if (status == 'notFound') {
      body = StateMessage(
        icon: FIcons.building,
        title: l10n.listingNotFound,
        body: '',
        bordered: false,
        actionLabel: l10n.back,
        secondaryAction: true,
        onAction: () => Navigator.maybePop(context),
      );
    } else if (isNetworkError(message)) {
      body = StateMessage(
        icon: FIcons.wifiOff,
        title: l10n.listingUnavailableOffline,
        body: l10n.listingUnavailableOfflineBody,
        bordered: false,
        actionLabel: l10n.tryAgain,
        actionIcon: FIcons.refresh,
        onAction: onRetry,
      );
    } else {
      body = ErrorState(onRetry: onRetry);
    }
    return SafeArea(
      child: Column(children: [
        const FTopBar(),
        Expanded(
          child: Center(
            child: Padding(padding: const EdgeInsets.all(24), child: body),
          ),
        ),
      ]),
    );
  }
}

// ------------------------------------------------------------------ loaded

class _Loaded extends StatelessWidget {
  const _Loaded({required this.data, this.heroTag, required this.onReport});
  final Map<String, dynamic> data;
  final Object? heroTag;
  final VoidCallback onReport;

  List<String> get _photos {
    final out = <String>[];
    final main = (data['main_pic'] as String?)?.trim() ?? '';
    if (ListingPhoto.hasImage(main)) out.add(main);
    final pics = data['pics'];
    if (pics is List) {
      for (final p in pics) {
        final s = p?.toString().trim() ?? '';
        if (ListingPhoto.hasImage(s) && !out.contains(s)) out.add(s);
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final id = data['id'] as int;

    return CustomScrollView(slivers: [
      SliverToBoxAdapter(
        child: Stack(children: [
          _PhotoCarousel(photos: _photos, heroTag: heroTag, id: id),
          Padding(
            padding: const EdgeInsets.only(top: _kPhotoHeight - 28),
            child: Entrance(
              delay: const Duration(milliseconds: 80),
              offset: 24,
              child: _Sheet(data: data, onReport: onReport),
            ),
          ),
        ]),
      ),
    ]);
  }
}

/// Sticky price + Call bar. Lives in Scaffold.bottomNavigationBar so
/// snackbars (Saved · Undo) float above it instead of covering Call.
class _PriceBar extends StatelessWidget {
  const _PriceBar({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final price = (data['price'] as num?)?.toDouble() ?? 0;
    final rent = isRent(data['listing_type']?.toString() ?? '');
    final phone = (data['owner_phone'] as String?)?.trim() ?? '';
    return StickyBar(
      child: Row(children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.price,
                  style: context.tt.bodySmall
                      ?.copyWith(fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              PriceText(price: price, rent: rent, size: 21),
            ],
          ),
        ),
        const SizedBox(width: 12),
        FButton(
          label: l10n.call,
          icon: FIcons.phone,
          expand: false,
          onPressed: phone.isEmpty
              ? () => showAppSnack(context, l10n.noPhoneNumber)
              : () => _launch(context, Uri(scheme: 'tel', path: phone)),
        ),
      ]),
    );
  }
}

Future<void> _launch(BuildContext context, Uri uri) async {
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok && context.mounted) showAppSnack(context, uri.path);
}

class _PhotoCarousel extends StatefulWidget {
  const _PhotoCarousel({required this.photos, this.heroTag, required this.id});
  final List<String> photos;
  final Object? heroTag;
  final int id;

  @override
  State<_PhotoCarousel> createState() => _PhotoCarouselState();
}

class _PhotoCarouselState extends State<_PhotoCarousel> {
  final _index = ValueNotifier(0);

  @override
  void dispose() {
    _index.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final top = MediaQuery.paddingOf(context).top;
    final photos = widget.photos.isEmpty ? <String?>[null] : widget.photos;
    final saved =
        context.select<SavedListingsCubit, bool>((s) => s.isSaved(widget.id));
    final savedCubit = context.read<SavedListingsCubit>();

    return SizedBox(
      height: _kPhotoHeight,
      child: Stack(children: [
        PageView.builder(
          itemCount: photos.length,
          onPageChanged: (i) => _index.value = i,
          itemBuilder: (context, i) => ListingPhoto(
            url: photos[i],
            width: double.infinity,
            height: _kPhotoHeight,
            radius: 0,
            heroTag: i == 0 ? widget.heroTag : null,
            semanticLabel: l10n.photoOf(i + 1, photos.length),
          ),
        ),
        // Soft top shade so the round buttons read on bright photos.
        const Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: 120,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x40000000), Color(0x00000000)],
                ),
              ),
            ),
          ),
        ),
        PositionedDirectional(
          top: top + 8,
          start: 16,
          end: 16,
          child: Row(children: [
            const FBackButton(onPhoto: true),
            const Spacer(),
            SaveButton(
              saved: saved,
              size: 44,
              onToggle: (save) => toggleSaveWithUndo(
                context,
                save: save,
                doSave: () => savedCubit.saveListing(widget.id),
                doUnsave: () => savedCubit.unsaveListing(widget.id),
              ),
            ),
          ]),
        ),
        if (photos.length > 1)
          PositionedDirectional(
            end: 16,
            bottom: 44,
            child: ValueListenableBuilder<int>(
              valueListenable: _index,
              builder: (context, i, _) => Container(
                height: 28,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xB8111317),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text('${i + 1} / ${photos.length}',
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ),
      ]),
    );
  }
}

class _Sheet extends StatelessWidget {
  const _Sheet({required this.data, required this.onReport});
  final Map<String, dynamic> data;
  final VoidCallback onReport;

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    final l10n = AppLocalizations.of(context)!;
    final rent = isRent(data['listing_type']?.toString() ?? '');
    final type = data['building_type']?.toString() ?? '';
    final boosted = data['is_boosted'] == true || data['is_boosted'] == 1;
    final area = (data['area'] as num?)?.toDouble();
    final created = DateTime.tryParse(data['created_at']?.toString() ?? '');
    final days = created == null
        ? null
        : DateTime.now().difference(created.toLocal()).inDays.clamp(0, 9999);

    return Container(
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(spacing: 8, runSpacing: 8, children: [
            if (boosted) const BoostedBadge(),
            TagPill(rent ? l10n.forRent : l10n.forSale),
            if (type.isNotEmpty) TagPill(propertyTypeLabel(type, l10n)),
          ]),
          const SizedBox(height: 20),
          Semantics(
            header: true,
            child: Text(data['title']?.toString() ?? '',
                style: context.tt.headlineMedium),
          ),
          const SizedBox(height: 6),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: FIcon(FIcons.pin, size: 16, color: c.muted),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                [
                  data['address']?.toString() ?? '',
                  if (days != null) l10n.listedDaysAgo(days),
                ].where((s) => s.isNotEmpty).join(' · '),
                style: context.tt.bodyMedium
                    ?.copyWith(color: c.muted, fontWeight: FontWeight.w600),
              ),
            ),
          ]),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
                child: StatTile(
                    icon: FIcons.bed,
                    value: '${data['bedrooms'] ?? 0}',
                    label: l10n.bedrooms)),
            const SizedBox(width: 10),
            Expanded(
                child: StatTile(
                    icon: FIcons.bath,
                    value: '${data['bathrooms'] ?? 0}',
                    label: l10n.bathrooms)),
            const SizedBox(width: 10),
            Expanded(
                child: StatTile(
                    icon: FIcons.area,
                    value:
                        area != null && area > 0 ? '\u2066${area.round()} m²\u2069' : '—',
                    label: l10n.areaLabel)),
          ]),
          const SizedBox(height: 20),
          Text(l10n.aboutProperty, style: context.tt.titleMedium),
          const SizedBox(height: 8),
          _Description(text: data['description']?.toString() ?? ''),
          const SizedBox(height: 20),
          Text(l10n.listedBy, style: context.tt.titleMedium),
          const SizedBox(height: 10),
          _OwnerCard(data: data),
          const SizedBox(height: 20),
          InkWell(
            onTap: onReport,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                FIcon(FIcons.flag, size: 18, color: c.muted),
                const SizedBox(width: 8),
                Text(l10n.reportThisListing,
                    style: context.tt.bodyMedium?.copyWith(
                        color: c.muted, fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _Description extends StatefulWidget {
  const _Description({required this.text});
  final String text;

  @override
  State<_Description> createState() => _DescriptionState();
}

class _DescriptionState extends State<_Description> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    final l10n = AppLocalizations.of(context)!;
    final style = context.tt.bodyLarge?.copyWith(color: c.muted, height: 1.6);
    return LayoutBuilder(builder: (context, box) {
      final tp = TextPainter(
        text: TextSpan(text: widget.text, style: style),
        maxLines: 4,
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      )..layout(maxWidth: box.maxWidth);
      final overflows = tp.didExceedMaxLines;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSize(
            duration: Motion.reduced(context) ? Duration.zero : Motion.medium,
            curve: Motion.standard,
            alignment: AlignmentDirectional.topStart,
            child: Text(widget.text,
                style: style,
                maxLines: _open ? null : 4,
                overflow: _open ? TextOverflow.visible : TextOverflow.ellipsis),
          ),
          if (overflows)
            GestureDetector(
              onTap: () => setState(() => _open = !_open),
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_open ? l10n.showLess : l10n.readMore,
                    style: context.tt.bodyMedium?.copyWith(
                        color: c.accent, fontWeight: FontWeight.w800)),
              ),
            ),
        ],
      );
    });
  }
}

class _OwnerCard extends StatelessWidget {
  const _OwnerCard({required this.data});
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    final l10n = AppLocalizations.of(context)!;
    final name = data['owner_name']?.toString() ?? '';
    final ownerId = data['owner_id']?.toString() ?? '';
    final phone = (data['owner_phone'] as String?)?.trim() ?? '';
    final agency =
        (data['owner_account_type']?.toString() ?? '').toLowerCase() ==
            'agency';

    return Pressable(
      scale: 0.98,
      semanticLabel: '$name, ${l10n.viewProfile}',
      onTap: ownerId.isEmpty
          ? null
          : () =>
              Navigator.pushNamed(context, '/user-profile', arguments: ownerId),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: c.surf, borderRadius: BorderRadius.circular(20)),
        child: Row(children: [
          InitialsAvatar(
              name: name, imageUrl: data['owner_image'] as String?, size: 48),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name.isEmpty ? '—' : name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.tt.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w800)),
                Text(
                    '${agency ? l10n.agencyAccount : l10n.individualLabel} · ${l10n.viewProfile}',
                    style: context.tt.bodySmall),
              ],
            ),
          ),
          if (phone.isNotEmpty)
            CircleIconButton(
              icon: FIcons.message,
              label: l10n.sendSms,
              border: false,
              onPressed: () =>
                  _launch(context, Uri(scheme: 'sms', path: phone)),
            ),
        ]),
      ),
    );
  }
}
