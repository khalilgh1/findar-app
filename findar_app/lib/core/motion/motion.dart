import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Motion tokens and helpers (docs/design/README.md §4).
///
/// Performance rules followed here:
/// * one [AnimationController] per animated group, never per frame-rebuilt
///   subtree; animated parts sit behind [RepaintBoundary];
/// * only transform/opacity are animated (no layout, no blur);
/// * reduced motion ([MediaQuery.disableAnimationsOf]) turns slides/scales
///   into short fades and stops looping animations.
abstract final class Motion {
  static const fast = Duration(milliseconds: 150);
  static const short = Duration(milliseconds: 200);
  static const medium = Duration(milliseconds: 300);

  /// Material 3 "emphasized decelerate".
  static const Curve emphasized = Cubic(0.05, 0.7, 0.1, 1.0);
  static const Curve standard = Cubic(0.2, 0, 0, 1);

  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  static void lightHaptic() => HapticFeedback.lightImpact();
  static void softHaptic() => HapticFeedback.selectionClick();
}

/// Fade + 12px rise on first build. [index] staggers by 40 ms (capped at 6
/// items so long lists don't wait). Set [play] false to show immediately
/// (e.g. items scrolled back into view after the first load).
class Entrance extends StatefulWidget {
  const Entrance({
    super.key,
    required this.child,
    this.index = 0,
    this.play = true,
    this.offset = 12,
    this.delay = Duration.zero,
  });

  final Widget child;
  final int index;
  final bool play;
  final double offset;
  final Duration delay;

  @override
  State<Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<Entrance>
    with SingleTickerProviderStateMixin {
  AnimationController? _c;
  late Animation<double> _t;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_c != null || !widget.play || widget.index >= 6) return;
    final reduced = Motion.reduced(context);
    final stagger = widget.delay + Duration(milliseconds: 40 * widget.index);
    final run = reduced ? Motion.fast : const Duration(milliseconds: 320);
    final total = stagger + run;
    _c = AnimationController(vsync: this, duration: total);
    final start = stagger.inMicroseconds / total.inMicroseconds;
    _t = CurvedAnimation(
        parent: _c!, curve: Interval(start, 1, curve: Motion.emphasized));
    _c!.forward();
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_c == null) return widget.child;
    final reduced = Motion.reduced(context);
    return AnimatedBuilder(
      animation: _t,
      child: widget.child,
      builder: (context, child) {
        final v = _t.value;
        return Opacity(
          opacity: v,
          child: reduced
              ? child
              : Transform.translate(
                  offset: Offset(0, (1 - v) * widget.offset), child: child),
        );
      },
    );
  }
}

/// Scales its child to [scale] while pressed (cards, chips, buttons).
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scale = 0.97,
    this.semanticLabel,
    this.button = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scale;
  final String? semanticLabel;
  final bool button;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v && mounted) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null || widget.onLongPress != null;
    return Semantics(
      button: widget.button && enabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => _set(true) : null,
        onTapUp: enabled ? (_) => _set(false) : null,
        onTapCancel: () => _set(false),
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: AnimatedScale(
          scale: _down && !Motion.reduced(context) ? widget.scale : 1,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Plays a 1 → [peak] → 1 spring each time [trigger] changes.
class PopOnChange extends StatefulWidget {
  const PopOnChange({
    super.key,
    required this.trigger,
    required this.child,
    this.peak = 1.25,
    this.duration = const Duration(milliseconds: 360),
  });

  final Object? trigger;
  final Widget child;
  final double peak;
  final Duration duration;

  @override
  State<PopOnChange> createState() => _PopOnChangeState();
}

class _PopOnChangeState extends State<PopOnChange>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.duration);
  late Animation<double> _scale = _build();

  Animation<double> _build() => TweenSequence<double>([
        TweenSequenceItem(
            tween: Tween(begin: 1.0, end: widget.peak)
                .chain(CurveTween(curve: Curves.easeOut)),
            weight: 35),
        TweenSequenceItem(
            tween: Tween(begin: widget.peak, end: 1.0)
                .chain(CurveTween(curve: Curves.elasticOut)),
            weight: 65),
      ]).animate(_c);

  @override
  void didUpdateWidget(PopOnChange old) {
    super.didUpdateWidget(old);
    if (old.peak != widget.peak) _scale = _build();
    if (old.trigger != widget.trigger && !Motion.reduced(context)) {
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ScaleTransition(scale: _scale, child: widget.child);
}

/// Shakes horizontally 3x over 300 ms whenever [trigger] changes (errors).
class ShakeOnChange extends StatefulWidget {
  const ShakeOnChange({super.key, required this.trigger, required this.child});
  final Object? trigger;
  final Widget child;

  @override
  State<ShakeOnChange> createState() => _ShakeOnChangeState();
}

class _ShakeOnChangeState extends State<ShakeOnChange>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 300));

  @override
  void didUpdateWidget(ShakeOnChange old) {
    super.didUpdateWidget(old);
    if (old.trigger != widget.trigger && widget.trigger != null) {
      HapticFeedback.mediumImpact();
      if (!Motion.reduced(context)) _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        final v = _c.value;
        final dx = math.sin(v * math.pi * 6) * 8 * (1 - v);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
    );
  }
}

/// A looping 0..1 clock shared by several floating decorations. Stops when
/// [paused] is true, under reduced motion, and when the route is hidden
/// (TickerMode), so it never burns frames off-screen.
class FloatClock extends StatefulWidget {
  const FloatClock({
    super.key,
    required this.builder,
    this.period = const Duration(seconds: 6),
    this.paused,
    this.child,
  });

  final Duration period;
  final ValueListenable<bool>? paused;
  final Widget? child;
  final Widget Function(BuildContext context, double t, Widget? child) builder;

  @override
  State<FloatClock> createState() => _FloatClockState();
}

class _FloatClockState extends State<FloatClock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.period);

  @override
  void initState() {
    super.initState();
    widget.paused?.addListener(_sync);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  void _sync() {
    if (!mounted) return;
    final stop = Motion.reduced(context) || (widget.paused?.value ?? false);
    if (stop) {
      if (_c.isAnimating) _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    widget.paused?.removeListener(_sync);
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) => widget.builder(context, _c.value, child),
    );
  }
}

/// Sliding shimmer for skeletons (1.2 s). Static under reduced motion.
class Shimmer extends StatefulWidget {
  const Shimmer({super.key, required this.child});
  final Widget child;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (Motion.reduced(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final hi = dark ? const Color(0x14FFFFFF) : const Color(0x99FFFFFF);
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _c,
        child: widget.child,
        builder: (context, child) {
          final x = _c.value * 3 - 1.5;
          return ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (rect) => LinearGradient(
              begin: Alignment(x - 0.6, 0),
              end: Alignment(x + 0.6, 0),
              colors: [Colors.transparent, hi, Colors.transparent],
            ).createShader(rect),
            child: child,
          );
        },
      ),
    );
  }
}

/// Fade-through page transition for switching tabs (200 ms).
class FadeThroughRoute<T> extends PageRouteBuilder<T> {
  FadeThroughRoute({required WidgetBuilder builder, super.settings})
      : super(
          transitionDuration: Motion.short,
          reverseTransitionDuration: Motion.short,
          pageBuilder: (context, _, __) => builder(context),
          transitionsBuilder: (context, anim, secondary, child) {
            final fadeIn = CurvedAnimation(
                parent: anim,
                curve: const Interval(0.3, 1, curve: Curves.easeOut));
            return FadeTransition(opacity: fadeIn, child: child);
          },
        );
}

/// Full-screen route that springs up from the bottom like a sheet
/// (Create listing from the Post button). Cross-fades under reduced motion.
class SheetRoute<T> extends PageRouteBuilder<T> {
  SheetRoute({required WidgetBuilder builder, super.settings})
      : super(
          transitionDuration: const Duration(milliseconds: 380),
          reverseTransitionDuration: const Duration(milliseconds: 260),
          pageBuilder: (context, _, __) => builder(context),
          transitionsBuilder: (context, anim, secondary, child) {
            if (Motion.reduced(context)) {
              return FadeTransition(opacity: anim, child: child);
            }
            final curved = CurvedAnimation(
                parent: anim,
                curve: Motion.emphasized,
                reverseCurve: Curves.easeInCubic);
            return SlideTransition(
              position: Tween(begin: const Offset(0, 1), end: Offset.zero)
                  .animate(curved),
              child: child,
            );
          },
        );
}
