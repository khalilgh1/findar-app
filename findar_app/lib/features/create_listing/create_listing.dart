import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:findar/core/models/property_listing_model.dart';
import 'package:findar/core/motion/motion.dart';
import 'package:findar/core/theme/findar_tokens.dart';
import 'package:findar/core/widgets/f_icon.dart';
import 'package:findar/core/widgets/listing_widgets.dart';
import 'package:findar/core/widgets/ui.dart';
import 'package:findar/features/create_listing/widgets/location_autocomplete_field.dart';
import 'package:findar/l10n/app_localizations.dart';
import 'package:findar/logic/cubits/my_listings_cubit.dart';
import 'package:findar/logic/cubits/property_details_cubit.dart';

/// New listing (no [listing]) or Edit listing (with [listing]). Pops `true`
/// after a successful publish/save/delete.
class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key, this.listing});
  final PropertyListing? listing;

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();
  final _area = TextEditingController();
  final _location = TextEditingController();
  final _picker = ImagePicker();

  /// Photo sources in order: http URLs (existing) or local file paths.
  final List<String> _photos = [];
  bool _rent = false;
  String _type = 'apartment';
  int _bedrooms = 2;
  int _bathrooms = 1;
  bool _visible = true;
  double? _lat, _lng;
  bool _busy = false;
  bool _deleting = false;
  int _photoShake = 0;

  bool get _editing => widget.listing != null;

  @override
  void initState() {
    super.initState();
    final l = widget.listing;
    if (l == null) return;
    _title.text = l.title;
    _description.text = l.description;
    _price.text = l.price.round().toString();
    if (l.area != null && l.area! > 0) _area.text = l.area!.round().toString();
    _location.text = l.location;
    _rent = isRent(l.classification);
    final t = l.propertyType.toLowerCase();
    _type = kPropertyTypes.contains(t) ? t : 'apartment';
    _bedrooms = l.bedrooms;
    _bathrooms = l.bathrooms;
    _visible = l.isOnline;
    _lat = l.latitude;
    _lng = l.longitude;
    if (ListingPhoto.hasImage(l.image)) _photos.add(l.image);
    for (final p in l.additionalImages ?? const <String>[]) {
      if (ListingPhoto.hasImage(p) && !_photos.contains(p)) _photos.add(p);
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _price.dispose();
    _area.dispose();
    _location.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------- photos

  Future<void> _pick({required bool camera}) async {
    try {
      if (camera) {
        final x = await _picker.pickImage(
            source: ImageSource.camera,
            maxWidth: 1920,
            maxHeight: 1080,
            imageQuality: 85);
        if (x != null) setState(() => _photos.add(x.path));
      } else {
        final xs = await _picker.pickMultiImage(
            maxWidth: 1920, maxHeight: 1080, imageQuality: 85);
        if (xs.isNotEmpty) {
          setState(() => _photos.addAll(xs.map((x) => x.path)));
        }
      }
    } catch (e) {
      if (mounted) showAppSnack(context, '$e');
    }
  }

  void _addPhoto() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            MenuRow(
              icon: FIcons.image,
              title: l10n.chooseFromGallery,
              onTap: () {
                Navigator.pop(ctx);
                _pick(camera: false);
              },
            ),
            MenuRow(
              icon: FIcons.camera,
              title: l10n.takePhoto,
              onTap: () {
                Navigator.pop(ctx);
                _pick(camera: true);
              },
            ),
          ]),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- submit

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final formOk = _formKey.currentState!.validate();
    if (_photos.isEmpty) {
      setState(() => _photoShake++);
      showAppSnack(context, l10n.addAtLeastOnePhoto);
      return;
    }
    if (!formOk) {
      HapticFeedback.mediumImpact();
      return;
    }

    final cubit = context.read<MyListingsCubit>();
    final details = context.read<PropertyDetailsCubit>();
    final price = double.parse(_price.text.trim());
    final area = double.tryParse(_area.text.trim());
    setState(() => _busy = true);

    final result = _editing
        ? await cubit.editListing(
            id: widget.listing!.id,
            title: _title.text.trim(),
            description: _description.text.trim(),
            price: price,
            location: _location.text.trim(),
            bedrooms: _bedrooms,
            bathrooms: _bathrooms,
            classification: _rent ? 'For Rent' : 'For Sale',
            propertyType: _type,
            image: _photos.first,
            // Always send the list so removed photos go server-side too.
            additionalImages: _photos.skip(1).toList(),
            isOnline: _visible,
            area: area,
            latitude: _lat,
            longitude: _lng,
          )
        : await cubit.createListing(
            title: _title.text.trim(),
            description: _description.text.trim(),
            price: price,
            location: _location.text.trim(),
            latitude: _lat,
            longitude: _lng,
            bedrooms: _bedrooms,
            bathrooms: _bathrooms,
            area: area,
            classification: _rent ? 'For Rent' : 'For Sale',
            propertyType: _type,
            image: _photos.first,
            additionalImages: _photos.skip(1).toList(),
            isOnline: _visible,
          );
    if (!mounted) return;
    setState(() => _busy = false);
    if (result.state) {
      if (_editing) details.invalidateCache(widget.listing!.id);
      showAppSnack(
          context, _editing ? result.message : l10n.listingCreatedSuccessfully);
      Navigator.pop(context, true);
    } else {
      showAppSnack(
          context,
          result.message.isNotEmpty
              ? result.message
              : l10n.listingCreateFailed);
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context)!;
    final c = context.fc;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteListingTitle),
        content: Text(l10n.deleteListingBody(widget.listing!.title)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              style: TextButton.styleFrom(foregroundColor: c.ink),
              child: Text(l10n.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: c.red),
              child: Text(l10n.delete)),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _deleting = true);
    final r =
        await context.read<MyListingsCubit>().deleteListing(widget.listing!.id);
    if (!mounted) return;
    setState(() => _deleting = false);
    showAppSnack(context, r.state ? l10n.listingRemoved : r.message);
    if (r.state) Navigator.pop(context, true);
  }

  // ---------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    final l10n = AppLocalizations.of(context)!;
    final digits = [FilteringTextInputFormatter.digitsOnly];

    Widget label(String t) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(t, style: context.tt.labelMedium),
        );

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          FTopBar(
            title: _editing ? l10n.editListingTitle : l10n.newListing,
            close: true,
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                children: [
                  Text(l10n.photos,
                      style: context.tt.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  ShakeOnChange(
                    trigger: _photoShake == 0 ? null : _photoShake,
                    child: _PhotosRow(
                      photos: _photos,
                      onAdd: _addPhoto,
                      onRemove: (i) => setState(() => _photos.removeAt(i)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(l10n.photosHint,
                      style: context.tt.bodySmall?.copyWith(fontSize: 12)),
                  const SizedBox(height: 20),
                  AppField(
                    label: l10n.titleLabel,
                    controller: _title,
                    hint: l10n.examplePropertyTitleHint,
                    textInputAction: TextInputAction.next,
                    validator: (v) {
                      final t = v?.trim() ?? '';
                      if (t.isEmpty) return l10n.validateTitleEmpty;
                      if (t.length < 5) return l10n.validateTitleMinLength;
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  AppField(
                    label: l10n.description,
                    controller: _description,
                    hint: l10n.describeHint,
                    maxLines: 6,
                    minLines: 4,
                    validator: (v) {
                      final t = v?.trim() ?? '';
                      if (t.isEmpty) return l10n.validateDescriptionEmpty;
                      if (t.length < 20) {
                        return l10n.validateDescriptionMinLength;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  label(l10n.listingType),
                  PillSegmented<bool>(
                    values: const [false, true],
                    labels: [l10n.forSale, l10n.forRent],
                    selected: _rent,
                    onChanged: (v) => setState(() => _rent = v),
                  ),
                  const SizedBox(height: 20),
                  label(l10n.propertyType),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final t in kPropertyTypes)
                      SelectChip(
                        label: propertyTypeLabel(t, l10n),
                        icon: propertyTypeIcon(t),
                        selected: _type == t,
                        onTap: () => setState(() => _type = t),
                      ),
                  ]),
                  const SizedBox(height: 20),
                  AppField(
                    label: _rent ? l10n.pricePerMonth : l10n.price,
                    controller: _price,
                    hint: '0',
                    keyboardType: TextInputType.number,
                    inputFormatters: digits,
                    trailing: UnitSuffix(l10n.currencyDa),
                    validator: (v) {
                      final t = v?.trim() ?? '';
                      if (t.isEmpty) return l10n.validatePriceEmpty;
                      final p = double.tryParse(t);
                      if (p == null) return l10n.validatePriceInvalid;
                      if (p <= 0) return l10n.validatePricePositive;
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(children: [
                    Expanded(
                      child: FStepper(
                        label: l10n.bedrooms,
                        value: _bedrooms,
                        onChanged: (v) => setState(() => _bedrooms = v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FStepper(
                        label: l10n.bathrooms,
                        value: _bathrooms,
                        onChanged: (v) => setState(() => _bathrooms = v),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  AppField(
                    label: l10n.areaSqm,
                    controller: _area,
                    hint: '0',
                    keyboardType: TextInputType.number,
                    inputFormatters: digits,
                    trailing: const UnitSuffix('m²'),
                  ),
                  const SizedBox(height: 20),
                  LocationAutocompleteField(
                    controller: _location,
                    label: l10n.location,
                    hint: l10n.searchAddress,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? l10n.validateLocationEmpty
                        : null,
                    onLocationSelected: (lat, lng) {
                      _lat = lat;
                      _lng = lng;
                    },
                    onCleared: () => _lat = _lng = null,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
                    decoration: BoxDecoration(
                        color: c.surf, borderRadius: BorderRadius.circular(16)),
                    child: Row(children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.visibleToBuyers,
                                style: context.tt.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w800)),
                            Text(l10n.visibleToBuyersSub,
                                style: context.tt.bodySmall
                                    ?.copyWith(fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      Switch(
                        value: _visible,
                        onChanged: (v) {
                          Motion.softHaptic();
                          setState(() => _visible = v);
                        },
                      ),
                    ]),
                  ),
                  if (_editing) ...[
                    const SizedBox(height: 28),
                    FButton(
                      label: l10n.deleteListing,
                      icon: FIcons.trash,
                      kind: FButtonKind.danger,
                      loading: _deleting,
                      onPressed: _busy ? null : _delete,
                    ),
                  ],
                ],
              ),
            ),
          ),
          StickyBar(
            child: FButton(
              label: _editing ? l10n.saveChanges : l10n.publishListing,
              loading: _busy,
              onPressed: _deleting ? null : _submit,
            ),
          ),
        ]),
      ),
    );
  }
}

class _PhotosRow extends StatelessWidget {
  const _PhotosRow(
      {required this.photos, required this.onAdd, required this.onRemove});
  final List<String> photos;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      height: 108,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: const EdgeInsets.only(top: 6),
        itemCount: photos.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          if (i == 0) {
            return Semantics(
              button: true,
              label: l10n.addPhotos,
              excludeSemantics: true,
              child: Pressable(
                button: false,
                onTap: onAdd,
                child: CustomPaint(
                  painter: _DashedRRect(c.muted),
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                        color: c.surf, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FIcon(FIcons.camera, size: 22, color: c.ink),
                        const SizedBox(height: 6),
                        Text(l10n.addLabel,
                            style:
                                context.tt.labelMedium?.copyWith(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
          final idx = i - 1;
          final src = photos[idx];
          return SizedBox(
            width: 96,
            height: 96,
            child: Stack(clipBehavior: Clip.none, children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: src.startsWith('http')
                    ? ListingPhoto(url: src, width: 96, height: 96, radius: 16)
                    : Image.file(File(src),
                        width: 96,
                        height: 96,
                        fit: BoxFit.cover,
                        cacheWidth:
                            (96 * MediaQuery.devicePixelRatioOf(context))
                                .round()),
              ),
              if (idx == 0)
                PositionedDirectional(
                  start: 6,
                  bottom: 6,
                  child: Container(
                    height: 22,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xBF111317),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(l10n.coverLabel,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800)),
                  ),
                ),
              PositionedDirectional(
                top: -6,
                end: -6,
                child: Semantics(
                  button: true,
                  label: l10n.removePhoto,
                  excludeSemantics: true,
                  child: GestureDetector(
                    onTap: () => onRemove(idx),
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: c.btn,
                        shape: BoxShape.circle,
                        border: Border.all(color: c.bg, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: FIcon(FIcons.x,
                          size: 14, strokeWidth: 2.4, color: c.btnText),
                    ),
                  ),
                ),
              ),
            ]),
          );
        },
      ),
    );
  }
}

class _DashedRRect extends CustomPainter {
  _DashedRRect(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Offset.zero & size, const Radius.circular(16)));
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (final m in path.computeMetrics()) {
      var d = 0.0;
      while (d < m.length) {
        canvas.drawPath(m.extractPath(d, d + 5), p);
        d += 9;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRRect old) => old.color != color;
}
