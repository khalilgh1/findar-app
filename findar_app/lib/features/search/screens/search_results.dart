import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:findar/core/models/property_listing_model.dart';
import 'package:findar/core/motion/motion.dart';
import 'package:findar/core/theme/findar_tokens.dart';
import 'package:findar/core/utils/save_feedback.dart';
import 'package:findar/core/widgets/f_icon.dart';
import 'package:findar/core/widgets/listing_widgets.dart';
import 'package:findar/core/widgets/ui.dart';
import 'package:findar/features/home/home_widgets.dart';
import 'package:findar/features/search/search_request.dart';
import 'package:findar/l10n/app_localizations.dart';
import 'package:findar/logic/cubits/saved_listings_cubit.dart';
import 'package:findar/logic/cubits/search_cubit.dart';

const double kMaxPrice = 250000000;

/// Runs [SearchCubit.getFilteredListings] from a filters map as stored by the
/// cubit ('Any' / 0 / null mean no filter).
Future<void> runFilters(SearchCubit cubit, Map<String, dynamic> f,
    {String? sortBy}) {
  String? any(Object? v) => (v == null || v == 'Any') ? null : v as String;
  return cubit.getFilteredListings(
    latitude: (f['latitude'] as num?)?.toDouble(),
    longitude: (f['longitude'] as num?)?.toDouble(),
    minPrice: (f['minPrice'] as num?)?.toDouble() ?? 0,
    maxPrice: (f['maxPrice'] as num?)?.toDouble() ?? kMaxPrice,
    listingType: any(f['listingType']),
    buildingType: any(f['buildingType']),
    numBedrooms: f['numBedrooms'] as int? ?? 0,
    numBathrooms: f['numBathrooms'] as int? ?? 0,
    minSqft: (f['minSqft'] as num?)?.toDouble(),
    maxSqft: (f['maxSqft'] as num?)?.toDouble(),
    listedBy: any(f['listedBy']),
    sortBy: sortBy ?? f['sortBy'] as String?,
  );
}

/// Compact price for chips: 30k, 1.2M.
String shortPrice(num v) {
  if (v >= 1000000) {
    final m = v / 1000000;
    return '${m == m.roundToDouble() ? m.toInt() : m.toStringAsFixed(1)}M';
  }
  if (v >= 1000) return '${(v / 1000).round()}k';
  return v.round().toString();
}

class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({super.key});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final _query = TextEditingController();
  final _focus = FocusNode();
  bool _started = false;
  bool _filtered = false;
  bool _entered = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    context.read<SavedListingsCubit>().fetchSavedListings();

    final raw = ModalRoute.of(context)?.settings.arguments;
    final req = raw is SearchRequest
        ? raw
        : SearchRequest(
            query: (raw == null || raw.toString() == 'null') ? '' : '$raw');
    final cubit = context.read<SearchCubit>();

    if (req.isFiltered) {
      _filtered = true;
      if (req.filters != null) {
        runFilters(cubit, req.filters!);
      } else if (req.useCurrentFilters) {
        runFilters(cubit, cubit.currentFilters);
      } else {
        runFilters(cubit, {
          'listingType': req.listingType ?? 'Any',
          'buildingType': req.buildingType ?? 'Any',
        });
      }
    } else {
      _query.text = req.query;
      cubit.getrecentListings(req.query);
      if (req.focus) {
        // After the shared-element flight lands.
        Future.delayed(const Duration(milliseconds: 320), () {
          if (mounted) _focus.requestFocus();
        });
      }
    }
    Future.delayed(const Duration(milliseconds: 900), () => _entered = true);
  }

  @override
  void dispose() {
    _query.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _search(String q) {
    setState(() => _filtered = false);
    context.read<SearchCubit>().getrecentListings(q.trim());
  }

  Future<void> _openFilters() async {
    final applied = await Navigator.pushNamed(context, '/filtering');
    if (applied == true && mounted) {
      setState(() => _filtered = true);
      _query.clear();
    }
  }

  void _sort(String sortBy) {
    setState(() => _filtered = true);
    final cubit = context.read<SearchCubit>();
    runFilters(cubit, cubit.currentFilters, sortBy: sortBy);
  }

  void _removeFilter(String key) {
    final cubit = context.read<SearchCubit>();
    final f = Map<String, dynamic>.from(cubit.currentFilters);
    switch (key) {
      case 'price':
        f['minPrice'] = 0.0;
        f['maxPrice'] = kMaxPrice;
      case 'location':
        f['latitude'] = null;
        f['longitude'] = null;
        if (f['sortBy'] == 'distance') f['sortBy'] = 'date_newest';
      case 'numBedrooms' || 'numBathrooms':
        f[key] = 0;
      case 'minSqft':
        f['minSqft'] = null;
      default:
        f[key] = 'Any';
    }
    runFilters(cubit, f);
  }

  /// Active filters as (key, label) pairs.
  List<(String, String)> _chips(Map<String, dynamic> f, AppLocalizations l10n) {
    final out = <(String, String)>[];
    final lt = f['listingType'];
    if (lt != null && lt != 'Any') {
      out.add((
        'listingType',
        lt.toString().contains('rent') ? l10n.forRent : l10n.forSale
      ));
    }
    final bt = f['buildingType'];
    if (bt != null && bt != 'Any') {
      out.add(('buildingType', propertyTypeLabel(bt.toString(), l10n)));
    }
    final bd = f['numBedrooms'] as int? ?? 0;
    if (bd > 0) out.add(('numBedrooms', l10n.bedsMin(bd)));
    final ba = f['numBathrooms'] as int? ?? 0;
    if (ba > 0) out.add(('numBathrooms', l10n.bathsMin(ba)));
    final minP = (f['minPrice'] as num?)?.toDouble() ?? 0;
    final maxP = (f['maxPrice'] as num?)?.toDouble() ?? kMaxPrice;
    if (minP > 0 || maxP < kMaxPrice) {
      out.add((
        'price',
        '${shortPrice(minP)}–${shortPrice(maxP)} ${l10n.currencyDa}'
      ));
    }
    final area = (f['minSqft'] as num?)?.toDouble();
    if (area != null && area > 0) {
      out.add(('minSqft', l10n.areaMin(area.round())));
    }
    final lb = f['listedBy'];
    if (lb != null && lb != 'Any') {
      out.add((
        'listedBy',
        lb.toString().contains('agen') ? l10n.agencyAccount : l10n.ownerLabel
      ));
    }
    if (f['latitude'] != null) out.add(('location', l10n.location));
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    final l10n = AppLocalizations.of(context)!;
    final top = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: c.bg,
      body: BlocBuilder<SearchCubit, Map<String, dynamic>>(
        builder: (context, state) {
          final filters = (state['filters'] as Map<String, dynamic>?) ?? {};
          final chips =
              _filtered ? _chips(filters, l10n) : const <(String, String)>[];
          final status = state['state'];
          final listings =
              (state['data'] as List?)?.cast<PropertyListing>() ?? const [];
          final hasLocation = filters['latitude'] != null;

          return CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20, top + 8, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: Row(children: [
                    const FBackButton(),
                    const SizedBox(width: 10),
                    Expanded(
                        child: _QueryField(
                            controller: _query,
                            focus: _focus,
                            onSubmit: _search)),
                    const SizedBox(width: 10),
                    _FilterButton(count: chips.length, onTap: _openFilters),
                  ]),
                ),
              ),
              if (chips.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: Wrap(spacing: 8, runSpacing: 8, children: [
                      for (final (key, label) in chips)
                        _ActiveChip(
                            label: label, onRemove: () => _removeFilter(key)),
                    ]),
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                sliver: SliverToBoxAdapter(
                  child: Row(children: [
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: Motion.short,
                        layoutBuilder: (current, previous) => Stack(
                          alignment: AlignmentDirectional.centerStart,
                          children: [...previous, if (current != null) current],
                        ),
                        transitionBuilder: (child, a) => FadeTransition(
                          opacity: a,
                          child: SlideTransition(
                            position: Tween(
                                    begin: const Offset(0, 0.4),
                                    end: Offset.zero)
                                .animate(a),
                            child: child,
                          ),
                        ),
                        child: Text(
                          status == 'done'
                              ? l10n.resultsCount(listings.length)
                              : ' ',
                          key: ValueKey('$status${listings.length}'),
                          style: context.tt.bodyMedium?.copyWith(
                              color: c.muted, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    _SortMenu(
                      current: _filtered
                          ? filters['sortBy'] as String? ?? 'date_newest'
                          : 'date_newest',
                      allowDistance: hasLocation,
                      onSelected: _sort,
                    ),
                  ]),
                ),
              ),
              ..._results(
                  context, status, state['message'] as String?, listings),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _results(BuildContext context, Object? status, String? message,
      List<PropertyListing> listings) {
    final l10n = AppLocalizations.of(context)!;
    Widget pad(Widget w) => SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverToBoxAdapter(child: w));

    if (status == 'loading' || status == 'initial') {
      return [pad(const SkeletonList(count: 2, card: true))];
    }
    if (status == 'error') {
      void retry() => _filtered
          ? runFilters(context.read<SearchCubit>(),
              context.read<SearchCubit>().currentFilters)
          : _search(_query.text);
      return [
        pad(isNetworkError(message)
            ? OfflineBanner(onRetry: retry, body: l10n.actionNeedsInternet)
            : ErrorState(onRetry: retry)),
      ];
    }
    if (listings.isEmpty) {
      return [
        pad(StateMessage(
          icon: FIcons.search,
          title: l10n.noPropertiesFound,
          body: l10n.pleaseTryAdjustingFilters,
          actionLabel: l10n.filters,
          actionIcon: FIcons.sliders,
          secondaryAction: true,
          onAction: _openFilters,
        )),
      ];
    }
    final saved = context.read<SavedListingsCubit>();
    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList.separated(
          itemCount: listings.length,
          separatorBuilder: (_, __) => const SizedBox(height: 24),
          itemBuilder: (context, i) {
            final l = listings[i];
            return Entrance(
              index: i,
              play: !_entered,
              child: SavedSelector(
                id: l.id,
                builder: (context, isSaved) => ListingWideCard(
                  listing: l,
                  heroPrefix: 'sr',
                  saved: isSaved,
                  onToggleSave: (save) => toggleSaveWithUndo(
                    context,
                    save: save,
                    doSave: () => saved.saveListing(l.id),
                    doUnsave: () => saved.unsaveListing(l.id),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ];
  }
}

class _QueryField extends StatelessWidget {
  const _QueryField(
      {required this.controller, required this.focus, required this.onSubmit});
  final TextEditingController controller;
  final FocusNode focus;
  final ValueChanged<String> onSubmit;

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      height: 48,
      child: Stack(children: [
        Positioned.fill(
          child: Hero(
            tag: kSearchPillHero,
            flightShuttleBuilder: searchPillShuttle,
            child: DecoratedBox(
              decoration: BoxDecoration(
                  color: c.surf, borderRadius: BorderRadius.circular(999)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 16, end: 8),
          child: Row(children: [
            FIcon(FIcons.search, size: 20, color: c.muted),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focus,
                textInputAction: TextInputAction.search,
                onSubmitted: onSubmit,
                style:
                    context.tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: l10n.searchCityHint,
                  filled: false,
                  isCollapsed: true,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.count, required this.onTap});
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      button: true,
      label: count > 0 ? l10n.filtersActive(count) : l10n.filters,
      excludeSemantics: true,
      child: Stack(clipBehavior: Clip.none, children: [
        CircleIconButton(
          icon: FIcons.sliders,
          label: l10n.filters,
          size: 48,
          border: false,
          background: c.btn,
          foreground: c.btnText,
          onPressed: onTap,
        ),
        if (count > 0)
          PositionedDirectional(
            top: -2,
            end: -2,
            child: PopOnChange(
              trigger: count,
              peak: 1.2,
              child: Container(
                constraints: const BoxConstraints(minWidth: 20),
                height: 20,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: c.accent,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: c.bg, width: 2),
                ),
                child: Text('$count',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800)),
              ),
            ),
          ),
      ]),
    );
  }
}

class _ActiveChip extends StatelessWidget {
  const _ActiveChip({required this.label, required this.onRemove});
  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      height: 34,
      padding: const EdgeInsetsDirectional.only(start: 14, end: 4),
      decoration: BoxDecoration(
          color: c.accentT, borderRadius: BorderRadius.circular(999)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(label,
            style: TextStyle(
                color: c.accent, fontSize: 13, fontWeight: FontWeight.w700)),
        Semantics(
          button: true,
          label: l10n.removeFilter(label),
          excludeSemantics: true,
          child: GestureDetector(
            onTap: onRemove,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(6),
              child:
                  FIcon(FIcons.x, size: 14, strokeWidth: 2.2, color: c.accent),
            ),
          ),
        ),
      ]),
    );
  }
}

class _SortMenu extends StatelessWidget {
  const _SortMenu(
      {required this.current,
      required this.allowDistance,
      required this.onSelected});
  final String current;
  final bool allowDistance;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    final l10n = AppLocalizations.of(context)!;
    final options = <(String, String)>[
      ('date_newest', l10n.newest),
      ('price_asc', l10n.priceLowToHigh),
      ('price_desc', l10n.priceHighToLow),
      if (allowDistance) ('distance', l10n.nearest),
    ];
    final label = options
        .firstWhere((o) => o.$1 == current, orElse: () => options.first)
        .$2;
    return PopupMenuButton<String>(
      tooltip: l10n.sortBy,
      onSelected: onSelected,
      position: PopupMenuPosition.under,
      itemBuilder: (_) => [
        for (final (v, t) in options)
          PopupMenuItem(
            value: v,
            height: 48,
            child: Row(children: [
              Expanded(child: Text(t)),
              if (v == current) FIcon(FIcons.check, size: 18, color: c.accent),
            ]),
          ),
      ],
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: c.bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: c.line),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          FIcon(FIcons.sort, size: 16, color: c.ink),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: c.ink, fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(width: 4),
          FIcon(FIcons.chevDown, size: 16, color: c.ink),
        ]),
      ),
    );
  }
}
