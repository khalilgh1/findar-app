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
import 'package:findar/features/profile/profile_photo.dart';
import 'package:findar/l10n/app_localizations.dart';
import 'package:findar/logic/cubits/my_listings_cubit.dart';
import 'package:findar/logic/cubits/profile_cubit.dart';
import 'package:findar/logic/cubits/saved_listings_cubit.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _uploading = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    context.read<ProfileCubit>().fetchProfile();
    context.read<MyListingsCubit>().fetchMyListings();
    context.read<SavedListingsCubit>().fetchSavedListings();
  }

  @override
  void dispose() {
    _uploading.dispose();
    super.dispose();
  }

  /// "Boost a listing": pick one of your non-boosted listings, then plans.
  void _boost(List<PropertyListing> mine) {
    final l10n = AppLocalizations.of(context)!;
    final candidates = mine.where((l) => !l.isBoosted).toList();
    if (candidates.isEmpty) {
      showAppSnack(context, l10n.noListingsToBoost);
      return;
    }
    if (candidates.length == 1) {
      Navigator.pushNamed(context, '/sponsorship-plans',
          arguments: candidates.first);
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (ctx, scroll) => ListView(
          controller: scroll,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            Text(l10n.pickListingToBoost, style: ctx.tt.titleLarge),
            const SizedBox(height: 16),
            for (final l in candidates)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.pushNamed(context, '/sponsorship-plans',
                        arguments: l);
                  },
                  child: _MiniListing(listing: l),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    final l10n = AppLocalizations.of(context)!;

    return TabScaffold(
      index: 3,
      body: BlocBuilder<ProfileCubit, Map<String, dynamic>>(
        builder: (context, state) {
          final d = state['data'] is Map
              ? Map<String, dynamic>.from(state['data'] as Map)
              : <String, dynamic>{};
          if (d.isEmpty && state['state'] == 'error') {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: ErrorState(
                    title: l10n.errorOccurred,
                    body: '${state['message'] ?? ''}',
                    onRetry: () => context.read<ProfileCubit>().fetchProfile(),
                  ),
                ),
              ),
            );
          }

          final name = (d['username'] ?? d['name'] ?? '') as String;
          final email = (d['email'] ?? '') as String;
          final phone = (d['phone'] ?? '') as String;
          final pic = d['profile_pic'] as String? ?? d['profilePic'] as String?;
          final agency = (d['account_type'] ?? d['accountType'] ?? '')
                  .toString()
                  .toLowerCase() ==
              'agency';

          final my = context.watch<MyListingsCubit>();
          final online = my.onlineListings.cast<PropertyListing>();
          final offline = my.offlineListings.cast<PropertyListing>();
          final all = [...online, ...offline];
          final savedCount = context.select<SavedListingsCubit, int>(
              (s) => (s.state['data'] as List?)?.length ?? 0);

          return CustomScrollView(slivers: [
            SliverToBoxAdapter(
              child: _Header(
                name: name,
                email: email,
                pic: pic,
                agency: agency,
                uploading: _uploading,
                onPhoto: () =>
                    changeProfilePhoto(context, uploading: _uploading),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, kTabBarClearance),
              sliver: SliverList.list(children: [
                Transform.translate(
                  offset: const Offset(0, -10),
                  child: _StatsCard(
                    listings: all.length,
                    online: online.length,
                    saved: savedCount,
                  ),
                ),
                const SizedBox(height: 8),
                _BoostCard(onTap: () => _boost(all)),
                const SizedBox(height: 18),
                FCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Column(children: [
                    MenuRow(
                        icon: FIcons.phone,
                        title: phone.isEmpty ? '—' : phone,
                        subtitle: l10n.phoneLabel),
                    const FDivider(),
                    MenuRow(
                        icon: FIcons.mail,
                        title: email.isEmpty ? '—' : email,
                        subtitle: l10n.email),
                  ]),
                ),
                const SizedBox(height: 18),
                SectionHeader(
                  l10n.myListings,
                  action: all.isEmpty ? null : l10n.seeAll,
                  onAction: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/my-listings',
                      (r) => r.settings.name == '/home' || r.isFirst),
                ),
                const SizedBox(height: 12),
                if (all.isEmpty)
                  Text(l10n.noListingsYet,
                      style: context.tt.bodyMedium?.copyWith(color: c.muted))
                else
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    for (var i = 0; i < 2; i++) ...[
                      if (i > 0) const SizedBox(width: 14),
                      Expanded(
                        child: i < all.length
                            ? ListingGridTile(
                                listing: all[i],
                                photoHeight: 110,
                                heroPrefix: 'pf',
                                showLocation: false,
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ]),
              ]),
            ),
          ]);
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.name,
    required this.email,
    required this.pic,
    required this.agency,
    required this.uploading,
    required this.onPhoto,
  });

  final String name;
  final String email;
  final String? pic;
  final bool agency;
  final ValueNotifier<bool> uploading;
  final VoidCallback onPhoto;

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    final l10n = AppLocalizations.of(context)!;
    final top = MediaQuery.paddingOf(context).top;
    return WaveHeader(
      height: 400 + top - 44,
      child: Padding(
        padding: EdgeInsets.only(top: top + 8),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Expanded(child: ScreenTitle(l10n.profile)),
              CircleIconButton(
                icon: FIcons.settings,
                label: l10n.settings,
                onPressed: () => Navigator.pushNamed(context, '/settings'),
              ),
            ]),
          ),
          const SizedBox(height: 8),
          Stack(clipBehavior: Clip.none, children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: c.bg,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x330A5FC2),
                      blurRadius: 26,
                      offset: Offset(0, 10)),
                ],
              ),
              child: ValueListenableBuilder<bool>(
                valueListenable: uploading,
                builder: (context, busy, child) => Stack(children: [
                  child!,
                  if (busy)
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                            color: Color(0x66111317), shape: BoxShape.circle),
                        alignment: Alignment.center,
                        child: const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.6, color: Colors.white),
                        ),
                      ),
                    ),
                ]),
                child: InitialsAvatar(name: name, imageUrl: pic, size: 100),
              ),
            ),
            PositionedDirectional(
              end: 0,
              bottom: 0,
              child: CircleIconButton(
                icon: FIcons.camera,
                label: l10n.changePhoto,
                size: 34,
                iconSize: 16,
                border: false,
                background: c.btn,
                foreground: c.btnText,
                onPressed: onPhoto,
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(name.isEmpty ? ' ' : name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.tt.headlineMedium),
          ),
          Text(email,
              style: context.tt.bodyMedium
                  ?.copyWith(color: c.muted, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: c.line),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              FIcon(agency ? FIcons.building : FIcons.user,
                  size: 15, color: const Color(0xFF111317)),
              const SizedBox(width: 6),
              Text(agency ? l10n.agencyAccount : l10n.individualAccount,
                  style: const TextStyle(
                      color: Color(0xFF111317),
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
            ]),
          ),
          const SizedBox(height: 10),
          Pressable(
            semanticLabel: l10n.editProfile,
            onTap: () => Navigator.pushNamed(context, '/edit-profile'),
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x2E041E46),
                      blurRadius: 20,
                      offset: Offset(0, 8)),
                ],
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const FIcon(FIcons.edit,
                    size: 17, color: FindarColors.brandBlue),
                const SizedBox(width: 8),
                Text(l10n.editProfile,
                    style: const TextStyle(
                        color: FindarColors.brandBlue,
                        fontSize: 15,
                        fontWeight: FontWeight.w800)),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard(
      {required this.listings, required this.online, required this.saved});
  final int listings, online, saved;

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    final l10n = AppLocalizations.of(context)!;
    Widget stat(FIconData i, int v, String t) => Expanded(
          child: Semantics(
            label: '$v $t',
            excludeSemantics: true,
            child: Column(children: [
              FIcon(i, size: 22, color: c.accent),
              const SizedBox(height: 4),
              AnimatedSwitcher(
                duration: Motion.short,
                child: Text('$v',
                    key: ValueKey(v),
                    style: context.tt.headlineSmall?.copyWith(fontSize: 22)),
              ),
              const SizedBox(height: 2),
              Text(t.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.tt.labelSmall
                      ?.copyWith(fontSize: 11, letterSpacing: 0.9)),
            ]),
          ),
        );
    Widget vline() => Container(
        width: 1,
        height: 52,
        color: c.line,
        margin: const EdgeInsets.symmetric(vertical: 8));
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: c.line),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0D111317), blurRadius: 24, offset: Offset(0, 8)),
        ],
      ),
      child: Row(children: [
        stat(FIcons.listings, listings, l10n.listings),
        vline(),
        stat(FIcons.eye, online, l10n.online),
        vline(),
        stat(FIcons.bookmark, saved, l10n.saved),
      ]),
    );
  }
}

class _BoostCard extends StatelessWidget {
  const _BoostCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        gradient: FindarColors.promoGradient,
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(children: [
        const Deco(
          end: -50,
          top: -70,
          child: DecorCircle(
            size: 190,
            gradient:
                RadialGradient(colors: [Color(0x59F5B341), Color(0x00F5B341)]),
          ),
        ),
        const Deco(
            end: 40,
            bottom: 26,
            child: Sparkle(size: 12, color: Colors.white, opacity: 0.5)),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(14),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.18)),
                  ),
                  alignment: Alignment.center,
                  child: const FIcon(FIcons.bolt,
                      size: 22,
                      filled: true,
                      strokeWidth: 1.2,
                      color: Color(0xFFF5B341)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.boostAListing,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800)),
                      Text(l10n.boostAListingSub,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 14),
              Pressable(
                semanticLabel: l10n.seePlans,
                onTap: onTap,
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(l10n.seePlans,
                        style: const TextStyle(
                            color: Color(0xFF111317),
                            fontSize: 14,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(width: 6),
                    const FIcon(FIcons.chev,
                        size: 16, strokeWidth: 2.2, color: Color(0xFF111317)),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

/// Small listing row on surf (boost picker, plan screen).
class _MiniListing extends StatelessWidget {
  const _MiniListing({required this.listing});
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
