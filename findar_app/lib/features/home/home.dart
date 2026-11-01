import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:findar/core/di/service_locator.dart';
import 'package:findar/core/models/property_listing_model.dart';
import 'package:findar/core/motion/motion.dart';
import 'package:findar/core/repositories/auth_repository.dart';
import 'package:findar/core/theme/findar_tokens.dart';
import 'package:findar/core/utils/save_feedback.dart';
import 'package:findar/core/widgets/decor/decor.dart';
import 'package:findar/core/widgets/f_icon.dart';
import 'package:findar/core/widgets/floating_tab_bar.dart';
import 'package:findar/core/widgets/listing_widgets.dart';
import 'package:findar/core/widgets/ui.dart';
import 'package:findar/features/home/home_widgets.dart';
import 'package:findar/l10n/app_localizations.dart';
import 'package:findar/logic/cubits/home/recent_listings.dart';
import 'package:findar/logic/cubits/home/sponsored_listings.dart';
import 'package:findar/logic/cubits/profile_cubit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Hashtags stop floating while the page scrolls.
  final _floatPaused = ValueNotifier(false);

  /// Entrance animations play only for the first load of this screen.
  bool _entered = false;

  @override
  void initState() {
    super.initState();
    context.read<SponsoredCubit>().getSponsoredListings();
    context.read<RecentCubit>().getRecentListings();
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) _entered = true;
    });
  }

  @override
  void dispose() {
    _floatPaused.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await Future.wait([
      context.read<SponsoredCubit>().getSponsoredListings(forceRefresh: true),
      context.read<RecentCubit>().getRecentListings(forceRefresh: true),
    ]);
  }

  bool _onScroll(ScrollNotification n) {
    if (n is ScrollStartNotification) _floatPaused.value = true;
    if (n is ScrollEndNotification) _floatPaused.value = false;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    final l10n = AppLocalizations.of(context)!;
    final top = MediaQuery.paddingOf(context).top;

    return TabScaffold(
      index: 0,
      body: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: RefreshIndicator(
          color: c.accent,
          edgeOffset: top,
          onRefresh: _refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Stack(children: [
                  const SoftTop(height: 300),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, top + 12, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Header(),
                        const SizedBox(height: 22),
                        HeroSearchCard(floatPaused: _floatPaused),
                        const SizedBox(height: 22),
                        const PostBanner(),
                        const SizedBox(height: 22),
                        SectionHeader(l10n.browseByType),
                        const SizedBox(height: 14),
                      ],
                    ),
                  ),
                ]),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 152,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: kPropertyTypes.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (_, i) =>
                        Center(child: TypeCard(type: kPropertyTypes[i])),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 22)),
              _SponsoredSection(play: !_entered),
              _RecentSection(play: !_entered),
              const SliverToBoxAdapter(
                  child: SizedBox(height: kTabBarClearance)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.fc;
    final name = context.select<ProfileCubit, String?>((p) {
          final d = p.state['data'];
          return d is Map ? d['username'] as String? : null;
        }) ??
        getIt<AuthRepository>().getCurrentUser()?.username;
    final first = (name ?? '').trim().split(RegExp(r'\s+')).first;
    return Row(children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(first.isEmpty ? l10n.hello : l10n.helloName(first),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.tt.bodySmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            FindarLockup(size: 22, markColor: c.accent),
          ],
        ),
      ),
      CircleIconButton(
        icon: FIcons.settings,
        label: l10n.settings,
        onPressed: () => Navigator.pushNamed(context, '/settings'),
      ),
    ]);
  }
}

class _SponsoredSection extends StatelessWidget {
  const _SponsoredSection({required this.play});
  final bool play;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<SponsoredCubit, Map<String, dynamic>>(
      buildWhen: (a, b) =>
          a['state'] != b['state'] ||
          a['data'] != b['data'] ||
          a['savedIds'] != b['savedIds'],
      builder: (context, state) {
        final status = state['state'];
        final data = (state['data'] as List?)?.cast<PropertyListing>() ??
            const <PropertyListing>[];
        final savedIds = state['savedIds'] as Set<int>? ?? const <int>{};

        Widget body;
        if (status == 'loading' || status == 'initial') {
          body = SizedBox(
            height: 316,
            child: Shimmer(
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: 2,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (_, __) => const SkeletonCard(width: 296),
              ),
            ),
          );
        } else if (status == 'error') {
          final msg = state['message'] as String?;
          void retry() => context
              .read<SponsoredCubit>()
              .getSponsoredListings(forceRefresh: true);
          body = Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: isNetworkError(msg)
                ? OfflineBanner(onRetry: retry)
                : ErrorState(onRetry: retry),
          );
        } else if (data.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        } else {
          final cubit = context.read<SponsoredCubit>();
          body = SizedBox(
            height: 316,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: data.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, i) {
                final l = data[i];
                return Entrance(
                  index: i,
                  play: play,
                  child: ListingFeatureCard(
                    listing: l,
                    heroPrefix: 'sp',
                    saved: savedIds.contains(l.id),
                    onToggleSave: (save) => toggleSaveWithUndo(
                      context,
                      save: save,
                      doSave: () => cubit.saveListing(l.id),
                      doUnsave: () => cubit.unsaveListing(l.id),
                    ),
                  ),
                );
              },
            ),
          );
        }

        return SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SectionHeader(l10n.sponsored),
              ),
              const SizedBox(height: 14),
              body,
              const SizedBox(height: 22),
            ],
          ),
        );
      },
    );
  }
}

class _RecentSection extends StatelessWidget {
  const _RecentSection({required this.play});
  final bool play;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: BlocBuilder<RecentCubit, Map<String, dynamic>>(
        buildWhen: (a, b) =>
            a['state'] != b['state'] ||
            a['data'] != b['data'] ||
            a['savedIds'] != b['savedIds'],
        builder: (context, state) {
          final status = state['state'];
          final data = (state['data'] as List?)?.cast<PropertyListing>() ??
              const <PropertyListing>[];
          final savedIds = state['savedIds'] as Set<int>? ?? const <int>{};
          final header = Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: SectionHeader(l10n.recentListings),
          );

          if (status == 'loading' || status == 'initial') {
            return SliverToBoxAdapter(
              child: Column(children: [header, const SkeletonList(count: 3)]),
            );
          }
          if (status == 'error') {
            final msg = state['message'] as String?;
            void retry() => context
                .read<RecentCubit>()
                .getRecentListings(forceRefresh: true);
            return SliverToBoxAdapter(
              child: Column(children: [
                header,
                isNetworkError(msg)
                    ? OfflineBanner(onRetry: retry)
                    : ErrorState(onRetry: retry),
              ]),
            );
          }
          if (data.isEmpty) {
            return SliverToBoxAdapter(
              child: Column(children: [
                header,
                StateMessage(
                  icon: FIcons.home,
                  title: l10n.noRecentListings,
                  body: l10n.noRecentListingsBody,
                ),
              ]),
            );
          }
          final cubit = context.read<RecentCubit>();
          return SliverList.builder(
            itemCount: data.length + 1,
            itemBuilder: (context, i) {
              if (i == 0) return header;
              final l = data[i - 1];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Entrance(
                  index: i - 1,
                  play: play,
                  child: ListingRowCard(
                    listing: l,
                    heroPrefix: 'rc',
                    saved: savedIds.contains(l.id),
                    onToggleSave: (save) => toggleSaveWithUndo(
                      context,
                      save: save,
                      doSave: () => cubit.saveListing(l.id),
                      doUnsave: () => cubit.unsaveListing(l.id),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
