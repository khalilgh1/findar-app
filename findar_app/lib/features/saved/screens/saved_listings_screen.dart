import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:findar/core/models/property_listing_model.dart';
import 'package:findar/core/motion/motion.dart';
import 'package:findar/core/theme/findar_tokens.dart';
import 'package:findar/core/utils/save_feedback.dart';
import 'package:findar/core/widgets/decor/decor.dart';
import 'package:findar/core/widgets/f_icon.dart';
import 'package:findar/core/widgets/floating_tab_bar.dart';
import 'package:findar/core/widgets/listing_widgets.dart';
import 'package:findar/core/widgets/ui.dart';
import 'package:findar/l10n/app_localizations.dart';
import 'package:findar/logic/cubits/saved_listings_cubit.dart';

class SavedListingsScreen extends StatefulWidget {
  const SavedListingsScreen({super.key});

  @override
  State<SavedListingsScreen> createState() => _SavedListingsScreenState();
}

class _SavedListingsScreenState extends State<SavedListingsScreen> {
  bool _entered = false;

  @override
  void initState() {
    super.initState();
    // Saves made from Home go through other cubits: always refresh here.
    context.read<SavedListingsCubit>().fetchSavedListings(forceRefresh: true);
    Future.delayed(const Duration(milliseconds: 900), () => _entered = true);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    final l10n = AppLocalizations.of(context)!;
    final top = MediaQuery.paddingOf(context).top;
    final cubit = context.read<SavedListingsCubit>();

    return TabScaffold(
      index: 1,
      body: BlocBuilder<SavedListingsCubit, Map<String, dynamic>>(
        builder: (context, state) {
          final status = state['state'];
          final data = (state['data'] as List?)?.cast<PropertyListing>() ??
              const <PropertyListing>[];

          Widget content;
          if ((status == 'loading' || status == 'initial') && data.isEmpty) {
            content = SliverToBoxAdapter(
              child: Shimmer(
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.72,
                  children: List.generate(
                      4, (_) => const SkeletonCard(photoHeight: 150)),
                ),
              ),
            );
          } else if (status == 'error' && data.isEmpty) {
            final msg = state['message'] as String?;
            void retry() => cubit.fetchSavedListings(forceRefresh: true);
            content = SliverToBoxAdapter(
              child: isNetworkError(msg)
                  ? OfflineBanner(onRetry: retry)
                  : ErrorState(onRetry: retry),
            );
          } else if (data.isEmpty) {
            content = SliverToBoxAdapter(
              child: StateMessage(
                icon: FIcons.bookmark,
                title: l10n.noSavedYet,
                body: l10n.noSavedBody,
                actionLabel: l10n.browseListings,
                secondaryAction: true,
                onAction: () => Navigator.pushNamedAndRemoveUntil(
                    context, '/home', (r) => false),
              ),
            );
          } else {
            content = SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 14,
                mainAxisExtent: 232,
              ),
              itemCount: data.length,
              itemBuilder: (context, i) {
                final l = data[i];
                return Entrance(
                  index: i,
                  play: !_entered,
                  child: ListingGridTile(
                    key: ValueKey(l.id),
                    listing: l,
                    heroPrefix: 'sv',
                    saved: true,
                    onToggleSave: (save) => toggleSaveWithUndo(
                      context,
                      save: save,
                      doSave: () => cubit.saveListing(l.id),
                      doUnsave: () => cubit.unsaveListing(l.id),
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
              onRefresh: () => cubit.fetchSavedListings(forceRefresh: true),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Stack(children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, top + 24, 20, 20),
                        child: ScreenTitle(
                          l10n.saved,
                          subtitle: status == 'done' || data.isNotEmpty
                              ? l10n.propertiesCount(data.length)
                              : null,
                        ),
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
