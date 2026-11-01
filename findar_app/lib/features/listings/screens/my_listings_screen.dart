import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:findar/core/models/property_listing_model.dart';
import 'package:findar/core/motion/motion.dart';
import 'package:findar/core/theme/findar_tokens.dart';
import 'package:findar/core/widgets/decor/decor.dart';
import 'package:findar/core/widgets/f_icon.dart';
import 'package:findar/core/widgets/floating_tab_bar.dart';
import 'package:findar/core/widgets/listing_widgets.dart';
import 'package:findar/core/widgets/ui.dart';
import 'package:findar/features/create_listing/open_create_listing.dart';
import 'package:findar/l10n/app_localizations.dart';
import 'package:findar/logic/cubits/my_listings_cubit.dart';
import 'package:findar/logic/cubits/property_details_cubit.dart';

enum _Action { edit, boost, toggle, delete }

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  bool _online = true;
  bool _entered = false;

  /// Listings being toggled (dimmed) or deleted (collapsing).
  final Set<int> _dimmed = {};
  final Set<int> _removing = {};

  @override
  void initState() {
    super.initState();
    context.read<MyListingsCubit>().fetchMyListings(forceRefresh: true);
    Future.delayed(const Duration(milliseconds: 900), () => _entered = true);
  }

  Future<void> _onAction(_Action a, PropertyListing l) async {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<MyListingsCubit>();
    switch (a) {
      case _Action.edit:
        Navigator.pushNamed(context, '/edit-listing', arguments: l);
      case _Action.boost:
        Navigator.pushNamed(context, '/sponsorship-plans', arguments: l);
      case _Action.toggle:
        setState(() => _dimmed.add(l.id));
        final r = await cubit.toggleActiveListing(l.id);
        if (!mounted) return;
        context.read<PropertyDetailsCubit>().invalidateCache(l.id);
        setState(() => _dimmed.remove(l.id));
        showAppSnack(context, r.state ? l10n.listingStatusUpdated : r.message);
      case _Action.delete:
        final ok = await _confirmDelete(l);
        if (ok != true || !mounted) return;
        setState(() => _removing.add(l.id));
        await Future.delayed(const Duration(milliseconds: 220));
        final r = await cubit.deleteListing(l.id);
        if (!mounted) return;
        setState(() => _removing.remove(l.id));
        showAppSnack(context, r.state ? l10n.listingRemoved : r.message);
    }
  }

  Future<bool?> _confirmDelete(PropertyListing l) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.fc;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteListingTitle),
        content: Text(l10n.deleteListingBody(l.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(foregroundColor: c.ink),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: c.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    final l10n = AppLocalizations.of(context)!;
    final top = MediaQuery.paddingOf(context).top;

    return TabScaffold(
      index: 2,
      body: BlocBuilder<MyListingsCubit, Map<String, dynamic>>(
        builder: (context, state) {
          final cubit = context.read<MyListingsCubit>();
          final status = state['state'];
          final online = cubit.onlineListings;
          final offline = cubit.offlineListings;
          final list = _online ? online : offline;
          final nothingYet = online.isEmpty && offline.isEmpty;

          Widget content;
          if ((status == 'loading' || status == 'initial') && nothingYet) {
            content = const SliverToBoxAdapter(child: SkeletonList(count: 3));
          } else if (status == 'error' && nothingYet) {
            final msg = state['message'] as String?;
            void retry() => cubit.fetchMyListings(forceRefresh: true);
            content = SliverToBoxAdapter(
              child: isNetworkError(msg)
                  ? OfflineBanner(onRetry: retry)
                  : ErrorState(onRetry: retry),
            );
          } else if (list.isEmpty) {
            content = SliverToBoxAdapter(
              child: StateMessage(
                icon: FIcons.listings,
                title: _online ? l10n.noOnlineListings : l10n.noOfflineListings,
                body: l10n.addFirstPropertyListing,
                actionLabel: l10n.newListing,
                actionIcon: FIcons.plus,
                onAction: () => openCreateListing(context),
              ),
            );
          } else {
            content = SliverList.separated(
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, i) {
                final l = list[i];
                return Entrance(
                  key: ValueKey(l.id),
                  index: i,
                  play: !_entered,
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeInOut,
                    child: _removing.contains(l.id)
                        ? const SizedBox(width: double.infinity)
                        : AnimatedOpacity(
                            duration: Motion.short,
                            opacity: _dimmed.contains(l.id) ? 0.4 : 1,
                            child: _MyListingCard(
                                listing: l, onAction: (a) => _onAction(a, l)),
                          ),
                  ),
                );
              },
            );
          }

          return Stack(children: [
            const SoftTop(height: 200),
            RefreshIndicator(
              color: c.accent,
              edgeOffset: top,
              onRefresh: () => cubit.fetchMyListings(forceRefresh: true),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Stack(children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, top + 24, 20, 16),
                        child: Column(children: [
                          Row(children: [
                            Expanded(child: ScreenTitle(l10n.myListings)),
                            CircleIconButton(
                              icon: FIcons.plus,
                              label: l10n.newListing,
                              size: 48,
                              iconSize: 22,
                              border: false,
                              background: c.btn,
                              foreground: c.btnText,
                              onPressed: () => openCreateListing(context),
                            ),
                          ]),
                          const SizedBox(height: 16),
                          PillSegmented<bool>(
                            values: const [true, false],
                            labels: [
                              l10n.onlineCount(online.length),
                              l10n.offlineCount(offline.length),
                            ],
                            selected: _online,
                            onChanged: (v) => setState(() => _online = v),
                          ),
                        ]),
                      ),
                    ]),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: content,
                  ),
                  const SliverToBoxAdapter(
                      child: SizedBox(height: kTabBarClearance)),
                ],
              ),
            ),
          ]);
        },
      ),
    );
  }
}

class _MyListingCard extends StatelessWidget {
  const _MyListingCard({required this.listing, required this.onAction});
  final PropertyListing listing;
  final ValueChanged<_Action> onAction;

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    final l10n = AppLocalizations.of(context)!;
    final l = listing;
    final tag = 'ml-${l.id}';

    PopupMenuItem<_Action> item(_Action a, FIconData i, String t,
            [Color? color]) =>
        PopupMenuItem(
          value: a,
          height: 48,
          child: Row(children: [
            FIcon(i, size: 20, color: color ?? c.ink),
            const SizedBox(width: 12),
            Text(t, style: TextStyle(color: color ?? c.ink)),
          ]),
        );

    return Pressable(
      scale: 0.98,
      semanticLabel: l.title,
      onTap: () => openListing(context, l, heroTag: tag),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: c.bg,
          border: Border.all(color: c.line),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ListingPhoto(
              url: l.image, width: 92, height: 92, radius: 14, heroTag: tag),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(spacing: 6, runSpacing: 6, children: [
                  StatusPill(online: l.isOnline),
                  if (l.isBoosted) const BoostedBadge(),
                ]),
                const SizedBox(height: 6),
                Text(l.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.tt.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                PriceText(
                    price: l.price, rent: isRent(l.classification), size: 15),
              ],
            ),
          ),
          PopupMenuButton<_Action>(
            tooltip: l10n.actionsFor(l.title),
            onSelected: onAction,
            position: PopupMenuPosition.under,
            icon: FIcon(FIcons.more, size: 20, color: c.ink),
            itemBuilder: (_) => [
              item(_Action.edit, FIcons.edit, l10n.edit),
              if (!l.isBoosted)
                item(_Action.boost, FIcons.bolt, l10n.boostAction),
              item(_Action.toggle, l.isOnline ? FIcons.eyeOff : FIcons.eye,
                  l.isOnline ? l10n.makeOffline : l10n.makeOnline),
              item(_Action.delete, FIcons.trash, l10n.delete, c.red),
            ],
          ),
        ]),
      ),
    );
  }
}
