import 'package:flutter/material.dart';

import 'package:findar/core/motion/motion.dart';
import 'package:findar/core/theme/findar_tokens.dart';
import 'package:findar/core/widgets/f_icon.dart';
import 'package:findar/features/create_listing/open_create_listing.dart';
import 'package:findar/l10n/app_localizations.dart';

/// Tab routes in bar order (Post sits between Saved and My listings).
const kTabRoutes = ['/home', '/saved-listings', '/my-listings', '/profile'];

/// Space the floating bar needs below scrollable content.
const double kTabBarClearance = 120;

/// Scaffold for the four tab screens: body, a fade behind the bar, and the
/// floating bar itself.
class TabScaffold extends StatefulWidget {
  const TabScaffold({super.key, required this.index, required this.body});

  final int index;
  final Widget body;

  @override
  State<TabScaffold> createState() => _TabScaffoldState();
}

class _TabScaffoldState extends State<TabScaffold> {
  /// Whether content is scrolled under the status bar.
  final _scrolled = ValueNotifier(false);

  @override
  void dispose() {
    _scrolled.dispose();
    super.dispose();
  }

  bool _onScroll(ScrollNotification n) {
    if (n.depth == 0 && n.metrics.axis == Axis.vertical) {
      _scrolled.value = n.metrics.pixels > 8;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    final inset = MediaQuery.paddingOf(context).bottom * 0.5;
    return Scaffold(
      backgroundColor: c.bg,
      // The bar lives in bottomNavigationBar so floating snackbars (Undo)
      // sit above it instead of covering it; extendBody keeps content
      // scrolling underneath.
      extendBody: true,
      bottomNavigationBar: SizedBox(
        height: 34 + 70 + 18 + inset,
        child: Stack(clipBehavior: Clip.none, children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 130,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0, 0.7],
                    colors: [c.bg.withValues(alpha: 0), c.bg],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 14,
            right: 14,
            bottom: 18 + inset,
            child: FloatingTabBar(index: widget.index),
          ),
        ]),
      ),
      body: Stack(children: [
        Positioned.fill(
          child: NotificationListener<ScrollNotification>(
            onNotification: _onScroll,
            child: widget.body,
          ),
        ),
        // Keeps scrolled content from running under the status bar icons.
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: MediaQuery.paddingOf(context).top,
          child: IgnorePointer(
            child: ValueListenableBuilder<bool>(
              valueListenable: _scrolled,
              builder: (context, on, _) => AnimatedOpacity(
                opacity: on ? 1 : 0,
                duration: const Duration(milliseconds: 150),
                child: ColoredBox(color: c.bg.withValues(alpha: 0.96)),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class FloatingTabBar extends StatelessWidget {
  const FloatingTabBar({super.key, required this.index});
  final int index;

  void _go(BuildContext context, int i) {
    if (i == index) return;
    Motion.softHaptic();
    Navigator.pushNamedAndRemoveUntil(
      context,
      kTabRoutes[i],
      (route) => route.settings.name == '/home' || route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: SizedBox(
        height: 70,
        child: Stack(clipBehavior: Clip.none, children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: c.tabGlass,
                borderRadius: BorderRadius.circular(35),
                border: Border.all(color: c.line),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x24111317),
                      blurRadius: 34,
                      offset: Offset(0, 14)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(children: [
              _TabItem(
                  icon: FIcons.home,
                  label: l10n.home,
                  active: index == 0,
                  onTap: () => _go(context, 0)),
              _TabItem(
                  icon: FIcons.bookmark,
                  label: l10n.saved,
                  active: index == 1,
                  fillWhenActive: true,
                  onTap: () => _go(context, 1)),
              const SizedBox(width: 74),
              _TabItem(
                  icon: FIcons.listings,
                  label: l10n.myListings,
                  active: index == 2,
                  onTap: () => _go(context, 2)),
              _TabItem(
                  icon: FIcons.user,
                  label: l10n.profile,
                  active: index == 3,
                  onTap: () => _go(context, 3)),
            ]),
          ),
          Positioned(
            top: -34,
            left: 0,
            right: 0,
            child: Center(child: _PostButton(label: l10n.postTab)),
          ),
        ]),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    this.fillWhenActive = false,
  });

  final FIconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final bool fillWhenActive;

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    final col = active ? c.accent : c.muted;
    return Expanded(
      child: Semantics(
        button: true,
        selected: active,
        label: label,
        excludeSemantics: true,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: SizedBox.expand(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FIcon(icon,
                    size: 23,
                    color: col,
                    strokeWidth: active ? 2 : 1.8,
                    filled: active && fillWhenActive),
                const SizedBox(height: 3),
                Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: TextStyle(
                      fontFamily: context.tt.bodyMedium?.fontFamily,
                      fontSize: 11,
                      fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                      color: col,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Raised gradient "+" that opens Create listing. Springs 0.94 → 1.04 → 1.
class _PostButton extends StatefulWidget {
  const _PostButton({required this.label});
  final String label;

  @override
  State<_PostButton> createState() => _PostButtonState();
}

class _PostButtonState extends State<_PostButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 320));
  late final Animation<double> _s = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.94), weight: 25),
    TweenSequenceItem(
        tween: Tween(begin: 0.94, end: 1.04)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 35),
    TweenSequenceItem(
        tween: Tween(begin: 1.04, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40),
  ]).animate(_c);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _tap() {
    Motion.lightHaptic();
    if (!Motion.reduced(context)) _c.forward(from: 0);
    openCreateListing(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    return Semantics(
      button: true,
      label: widget.label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: _tap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 74,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            ScaleTransition(
              scale: _s,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: c.bg,
                ),
                alignment: Alignment.center,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: FindarColors.postGradient,
                    boxShadow: [
                      BoxShadow(
                          color: Color(0x730A5FC2),
                          blurRadius: 22,
                          offset: Offset(0, 10)),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const FIcon(FIcons.plus,
                      size: 28, strokeWidth: 2.4, color: Colors.white),
                ),
              ),
            ),
            Text(widget.label,
                style: TextStyle(
                  fontFamily: context.tt.bodyMedium?.fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: c.muted,
                )),
          ]),
        ),
      ),
    );
  }
}
