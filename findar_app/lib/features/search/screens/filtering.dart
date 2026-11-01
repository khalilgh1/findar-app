import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:findar/core/theme/findar_tokens.dart';
import 'package:findar/core/widgets/listing_widgets.dart';
import 'package:findar/core/widgets/ui.dart';
import 'package:findar/features/create_listing/widgets/location_autocomplete_field.dart';
import 'package:findar/features/search/screens/search_results.dart';
import 'package:findar/features/search/search_request.dart';
import 'package:findar/l10n/app_localizations.dart';
import 'package:findar/logic/cubits/search_cubit.dart';

/// Advanced search. Route argument `true` = opened from Home: applying opens
/// the results; otherwise it re-runs the search and pops with `true`.
class FilteringScreen extends StatefulWidget {
  const FilteringScreen({super.key});

  @override
  State<FilteringScreen> createState() => _FilteringScreenState();
}

class _FilteringScreenState extends State<FilteringScreen> {
  final _location = TextEditingController();
  final _minPrice = TextEditingController();
  final _maxPrice = TextEditingController();
  final _minArea = TextEditingController();

  String _listingType = 'Any'; // Any | sale | rent
  String _buildingType = 'Any';
  int _bedrooms = 0;
  int _bathrooms = 0;
  String _listedBy = 'Any'; // Any | individual | agency
  double? _lat, _lng;
  RangeValues _range = const RangeValues(0, 1);
  bool _fromHome = false;
  bool _loaded = false;

  // Slider position p (0..1) -> price = max * p^3: fine steps for rents,
  // still reaches villa prices.
  static double _toPrice(double p) => (kMaxPrice * p * p * p).roundToDouble();
  static double _toPos(double price) =>
      math.pow((price / kMaxPrice).clamp(0, 1), 1 / 3).toDouble();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    _fromHome = ModalRoute.of(context)?.settings.arguments == true;
    final f = context.read<SearchCubit>().currentFilters;
    final lt = (f['listingType'] ?? 'Any').toString().toLowerCase();
    _listingType = lt.contains('rent')
        ? 'rent'
        : lt.contains('sale')
            ? 'sale'
            : 'Any';
    final bt = (f['buildingType'] ?? 'Any').toString().toLowerCase();
    _buildingType = kPropertyTypes.contains(bt) ? bt : 'Any';
    _bedrooms = f['numBedrooms'] as int? ?? 0;
    _bathrooms = f['numBathrooms'] as int? ?? 0;
    final lb = (f['listedBy'] ?? 'Any').toString().toLowerCase();
    _listedBy = lb.contains('agen')
        ? 'agency'
        : (lb.contains('owner') || lb.contains('individual'))
            ? 'individual'
            : 'Any';
    _lat = (f['latitude'] as num?)?.toDouble();
    _lng = (f['longitude'] as num?)?.toDouble();
    final minP = (f['minPrice'] as num?)?.toDouble() ?? 0;
    final maxP = (f['maxPrice'] as num?)?.toDouble() ?? kMaxPrice;
    _setPrices(minP, maxP);
    final area = (f['minSqft'] as num?)?.toDouble();
    if (area != null && area > 0) _minArea.text = area.round().toString();
  }

  void _setPrices(double minP, double maxP, {bool fields = true}) {
    _range = RangeValues(_toPos(minP), _toPos(maxP));
    if (fields) {
      _minPrice.text = minP <= 0 ? '' : minP.round().toString();
      _maxPrice.text = maxP >= kMaxPrice ? '' : maxP.round().toString();
    }
  }

  @override
  void dispose() {
    _location.dispose();
    _minPrice.dispose();
    _maxPrice.dispose();
    _minArea.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _location.clear();
      _minArea.clear();
      _listingType = 'Any';
      _buildingType = 'Any';
      _bedrooms = 0;
      _bathrooms = 0;
      _listedBy = 'Any';
      _lat = _lng = null;
      _setPrices(0, kMaxPrice);
    });
  }

  Map<String, dynamic> _filters() {
    final minP = double.tryParse(_minPrice.text) ?? 0;
    final maxP = double.tryParse(_maxPrice.text) ?? kMaxPrice;
    final area = double.tryParse(_minArea.text.trim());
    return {
      'minPrice': math.min(minP, maxP),
      'maxPrice': math.max(minP, maxP),
      'listingType': _listingType,
      'buildingType': _buildingType,
      'numBedrooms': _bedrooms,
      'numBathrooms': _bathrooms,
      'minSqft': (area != null && area > 0) ? area : null,
      'maxSqft': null,
      'listedBy': _listedBy,
      'latitude': _lat,
      'longitude': _lng,
      'sortBy': _lat != null ? 'distance' : 'date_newest',
    };
  }

  void _apply() {
    final f = _filters();
    if (_fromHome) {
      Navigator.pushReplacementNamed(context, '/search-results',
          arguments: SearchRequest(filters: f));
    } else {
      runFilters(context.read<SearchCubit>(), f);
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    final l10n = AppLocalizations.of(context)!;
    final digits = [FilteringTextInputFormatter.digitsOnly];

    Widget label(String t, [Widget? trailing]) => Row(children: [
          Expanded(
              child: Text(t,
                  style: context.tt.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800))),
          if (trailing != null) trailing,
        ]);

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          FTopBar(
            title: l10n.advancedSearch,
            close: true,
            trailing: TextButton(
              onPressed: _reset,
              style: TextButton.styleFrom(
                  textStyle: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700)),
              child: Text(l10n.reset),
            ),
          ),
          Expanded(
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
              children: [
                PillSegmented<String>(
                  values: const ['Any', 'sale', 'rent'],
                  labels: [l10n.any, l10n.forSale, l10n.forRent],
                  selected: _listingType,
                  onChanged: (v) => setState(() => _listingType = v),
                ),
                const SizedBox(height: 20),
                LocationAutocompleteField(
                  controller: _location,
                  label: l10n.location,
                  hint: l10n.searchCityHint,
                  onLocationSelected: (lat, lng) => setState(() {
                    _lat = lat;
                    _lng = lng;
                  }),
                  onCleared: () => setState(() => _lat = _lng = null),
                ),
                const SizedBox(height: 20),
                label(l10n.propertyType),
                const SizedBox(height: 12),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  SelectChip(
                    label: l10n.any,
                    selected: _buildingType == 'Any',
                    onTap: () => setState(() => _buildingType = 'Any'),
                  ),
                  for (final t in kPropertyTypes)
                    SelectChip(
                      label: propertyTypeLabel(t, l10n),
                      icon: propertyTypeIcon(t),
                      selected: _buildingType == t,
                      onTap: () => setState(() => _buildingType = t),
                    ),
                ]),
                const SizedBox(height: 20),
                const FDivider(),
                const SizedBox(height: 20),
                label(
                    _listingType == 'rent'
                        ? l10n.pricePerMonth
                        : l10n.priceRange,
                    Text(l10n.currencyDa, style: context.tt.bodySmall)),
                const SizedBox(height: 4),
                RangeSlider(
                  values: _range,
                  onChanged: (v) => setState(() {
                    _range = v;
                    final minP = v.start <= 0.001 ? 0.0 : _toPrice(v.start);
                    final maxP = v.end >= 0.999 ? kMaxPrice : _toPrice(v.end);
                    _minPrice.text = minP <= 0 ? '' : minP.round().toString();
                    _maxPrice.text =
                        maxP >= kMaxPrice ? '' : maxP.round().toString();
                  }),
                ),
                Row(children: [
                  Expanded(
                    child: AppField(
                      label: l10n.minLabel,
                      controller: _minPrice,
                      hint: '0',
                      keyboardType: TextInputType.number,
                      inputFormatters: digits,
                      trailing: UnitSuffix(l10n.currencyDa),
                      onChanged: (_) => setState(() => _setPrices(
                          double.tryParse(_minPrice.text) ?? 0,
                          double.tryParse(_maxPrice.text) ?? kMaxPrice,
                          fields: false)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppField(
                      label: l10n.maxLabel,
                      controller: _maxPrice,
                      hint: l10n.any,
                      keyboardType: TextInputType.number,
                      inputFormatters: digits,
                      trailing: UnitSuffix(l10n.currencyDa),
                      onChanged: (_) => setState(() => _setPrices(
                          double.tryParse(_minPrice.text) ?? 0,
                          double.tryParse(_maxPrice.text) ?? kMaxPrice,
                          fields: false)),
                    ),
                  ),
                ]),
                const SizedBox(height: 20),
                const FDivider(),
                const SizedBox(height: 20),
                label(l10n.bedrooms),
                const SizedBox(height: 12),
                NumberPills(
                    value: _bedrooms,
                    onChanged: (v) => setState(() => _bedrooms = v)),
                const SizedBox(height: 20),
                label(l10n.bathrooms),
                const SizedBox(height: 12),
                NumberPills(
                    value: _bathrooms,
                    onChanged: (v) => setState(() => _bathrooms = v)),
                const SizedBox(height: 20),
                const FDivider(),
                const SizedBox(height: 20),
                AppField(
                  label: l10n.minimumArea,
                  controller: _minArea,
                  hint: '0',
                  keyboardType: TextInputType.number,
                  inputFormatters: digits,
                  trailing: const UnitSuffix('m²'),
                ),
                const SizedBox(height: 20),
                label(l10n.listedBy),
                const SizedBox(height: 12),
                PillSegmented<String>(
                  values: const ['Any', 'individual', 'agency'],
                  labels: [l10n.anyone, l10n.ownerLabel, l10n.agencyAccount],
                  selected: _listedBy,
                  onChanged: (v) => setState(() => _listedBy = v),
                ),
              ],
            ),
          ),
          StickyBar(child: FButton(label: l10n.showResults, onPressed: _apply)),
        ]),
      ),
    );
  }
}
