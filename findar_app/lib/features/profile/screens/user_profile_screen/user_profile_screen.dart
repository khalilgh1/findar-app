import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:findar/core/models/property_listing_model.dart';
import 'package:findar/core/motion/motion.dart';
import 'package:findar/core/theme/findar_tokens.dart';
import 'package:findar/core/utils/save_feedback.dart';
import 'package:findar/core/widgets/decor/decor.dart';
import 'package:findar/core/widgets/f_icon.dart';
import 'package:findar/core/widgets/listing_widgets.dart';
import 'package:findar/core/widgets/ui.dart';
import 'package:findar/l10n/app_localizations.dart';
import 'package:findar/logic/cubits/profile_cubit.dart';
import 'package:findar/logic/cubits/saved_listings_cubit.dart';

/// Another user's public profile (owner / agency).
class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key, required this.userId});
  final String userId;

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  void initState() {
    super.initState();
    _load();
    context.read<SavedListingsCubit>().fetchSavedListings();
  }

  void _load() {
    final id = int.tryParse(widget.userId);
    if (id != null) context.read<ProfileCubit>().fetchUserById(id);
  }

  Future<void> _launch(Uri uri) async {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) showAppSnack(context, uri.path);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    final l10n = AppLocalizations.of(context)!;
    final top = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: c.bg,
      body: BlocBuilder<ProfileCubit, Map<String, dynamic>>(
        builder: (context, state) {
          final status = state['state'];
          final d = state['data'] is Map
              ? Map<String, dynamic>.from(state['data'] as Map)
              : <String, dynamic>{};
          final loaded = status == 'done' && d['listingModels'] != null;

          if (status == 'error') {
            return SafeArea(
              child: Column(children: [
                const FTopBar(),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: ErrorState(
                        title: l10n.errorOccurred,
                        body: '${state['message'] ?? ''}',
                        onRetry: _load,
                      ),
                    ),
                  ),
                ),
              ]),
            );
          }

          final name = (d['name'] ?? '') as String;
          final phone = ((d['phone'] ?? '') as String).trim();
          final agency =
              (d['accountType'] ?? '').toString().toLowerCase() == 'agency';
          final listings = loaded
              ? (d['listingModels'] as List).cast<PropertyListing>()
              : const <PropertyListing>[];
          final saved = context.read<SavedListingsCubit>();

          return CustomScrollView(slivers: [
            SliverToBoxAdapter(
              child: WaveHeader(
                height: 300 + top - 44,
                child: Stack(children: [
                  PositionedDirectional(
                      top: top + 6, start: 16, child: const FBackButton()),
                  Positioned(
                    left: 20,
                    right: 20,
                    top: top + 26,
                    child: Column(children: [
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
                        child: InitialsAvatar(
                            name: loaded ? name : null,
                            imageUrl: d['profileImage'] as String?,
                            size: 88),
                      ),
                      const SizedBox(height: 8),
                      Text(loaded ? name : ' ',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.tt.headlineMedium
                              ?.copyWith(fontSize: 22)),
                      const SizedBox(height: 8),
                      if (loaded)
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
                                size: 15, color: FindarColors.brandBlue),
                            const SizedBox(width: 6),
                            Text(
                                agency
                                    ? l10n.agencyAccount
                                    : l10n.individualLabel,
                                style: const TextStyle(
                                    color: FindarColors.brandBlue,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800)),
                          ]),
                        ),
                    ]),
                  ),
                ]),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Row(children: [
                  Expanded(
                    child: FButton(
                      label: l10n.message,
                      icon: FIcons.message,
                      kind: FButtonKind.secondary,
                      height: 48,
                      onPressed: phone.isEmpty
                          ? null
                          : () => _launch(Uri(scheme: 'sms', path: phone)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FButton(
                      label: l10n.call,
                      icon: FIcons.phone,
                      height: 48,
                      onPressed: phone.isEmpty
                          ? null
                          : () => _launch(Uri(scheme: 'tel', path: phone)),
                    ),
                  ),
                ]),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
              sliver: SliverToBoxAdapter(
                child: SectionHeader(loaded
                    ? l10n.listingsCount(listings.length)
                    : l10n.listings),
              ),
            ),
            if (!loaded)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: Shimmer(
                    child: Row(children: const [
                      Expanded(child: SkeletonCard(photoHeight: 130)),
                      SizedBox(width: 14),
                      Expanded(child: SkeletonCard(photoHeight: 130)),
                    ]),
                  ),
                ),
              )
            else if (listings.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: Text(l10n.noListingsYet,
                      style: context.tt.bodyMedium?.copyWith(color: c.muted)),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 18,
                    crossAxisSpacing: 14,
                    mainAxisExtent: 212,
                  ),
                  itemCount: listings.length,
                  itemBuilder: (context, i) {
                    final l = listings[i];
                    return Entrance(
                      index: i,
                      child: SavedSelector(
                        id: l.id,
                        builder: (context, isSaved) => ListingGridTile(
                          listing: l,
                          photoHeight: 130,
                          heroPrefix: 'up',
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
            SliverToBoxAdapter(
                child: SizedBox(
                    height: 32 + MediaQuery.paddingOf(context).bottom)),
          ]);
        },
      ),
    );
  }
}
