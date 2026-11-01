import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:findar/core/theme/findar_tokens.dart';
import 'package:findar/core/widgets/f_icon.dart';

/// The soft "glass" decoration system (docs/design/README.md §2).
///
/// Everything here is decorative: wrapped in [IgnorePointer] and excluded
/// from semantics. Blur (backdrop-filter in the canvas) is intentionally not
/// used: it re-renders on every scroll frame and is barely visible over the
/// translucent fills, so the frosted look comes from gradients alone.

/// Concentric stroke circles.
class Rings extends StatelessWidget {
  const Rings({
    super.key,
    required this.radii,
    required this.opacities,
    this.color,
    this.strokeWidth = 1.2,
  });

  final List<double> radii;
  final List<double> opacities;
  final Color? color;
  final double strokeWidth;

  double get extent => radii.reduce(math.max) * 2 + 4;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: extent,
      child: CustomPaint(
        painter: _RingsPainter(
            radii, opacities, color ?? context.fc.accent, strokeWidth),
      ),
    );
  }
}

class _RingsPainter extends CustomPainter {
  _RingsPainter(this.radii, this.opacities, this.color, this.strokeWidth);
  final List<double> radii;
  final List<double> opacities;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    for (var i = 0; i < radii.length; i++) {
      p.color = color.withValues(alpha: opacities[i]);
      canvas.drawCircle(c, radii[i], p);
    }
  }

  @override
  bool shouldRepaint(_RingsPainter old) =>
      old.color != color || old.radii != radii || old.opacities != opacities;
}

/// Four-point star.
class Sparkle extends StatelessWidget {
  const Sparkle({super.key, this.size = 14, this.color, this.opacity = 0.4});
  final double size;
  final Color? color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _SparklePainter(
            (color ?? context.fc.accent).withValues(alpha: opacity)),
      ),
    );
  }
}

class _SparklePainter extends CustomPainter {
  _SparklePainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 24;
    final path = Path()
      ..moveTo(12 * k, 1 * k)
      ..lineTo(14.2 * k, 9.8 * k)
      ..lineTo(23 * k, 12 * k)
      ..lineTo(14.2 * k, 14.2 * k)
      ..lineTo(12 * k, 23 * k)
      ..lineTo(9.8 * k, 14.2 * k)
      ..lineTo(1 * k, 12 * k)
      ..lineTo(9.8 * k, 9.8 * k)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_SparklePainter old) => old.color != color;
}

/// Plain filled circle.
class DecorCircle extends StatelessWidget {
  const DecorCircle(
      {super.key, required this.size, this.color, this.gradient, this.border});
  final double size;
  final Color? color;
  final Gradient? gradient;
  final BoxBorder? border;

  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            gradient: gradient,
            border: border,
          ),
        ),
      );
}

/// White translucent circle with an inner ring (on blue cards).
class Bubble extends StatelessWidget {
  const Bubble({super.key, required this.size, this.opacity = 0.35});
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) => DecorCircle(
        size: size,
        color: Colors.white.withValues(alpha: opacity),
        border: Border.all(color: Colors.white.withValues(alpha: 0.55)),
      );
}

/// Rounded, slightly rotated tile holding one icon.
class GlassTile extends StatelessWidget {
  const GlassTile({
    super.key,
    required this.icon,
    required this.size,
    this.rotation = 0,
    this.light = false,
    this.iconColor,
  });

  final FIconData icon;
  final double size;

  /// Degrees.
  final double rotation;

  /// true on light backgrounds (white tile, blue icon); false on blue.
  final bool light;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    final deco = light
        ? BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.3),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [c.bg, c.surf],
            ),
            border: Border.all(color: c.line),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x1A111317),
                  blurRadius: 24,
                  offset: Offset(0, 10))
            ],
          )
        : BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.3),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.40),
                Colors.white.withValues(alpha: 0.10),
              ],
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x4D041E46),
                  blurRadius: 26,
                  offset: Offset(0, 12))
            ],
          );
    return Transform.rotate(
      angle: rotation * math.pi / 180,
      child: Container(
        width: size,
        height: size,
        decoration: deco,
        alignment: Alignment.center,
        child: FIcon(icon,
            size: size * 0.48,
            strokeWidth: 2,
            color: iconColor ?? (light ? c.accent : Colors.white)),
      ),
    );
  }
}

/// Positions a decoration child with directional offsets inside a [Stack].
class Deco extends StatelessWidget {
  const Deco({
    super.key,
    this.start,
    this.end,
    this.top,
    this.bottom,
    required this.child,
  });
  final double? start, end, top, bottom;
  final Widget child;

  @override
  Widget build(BuildContext context) => PositionedDirectional(
        start: start,
        end: end,
        top: top,
        bottom: bottom,
        child: child,
      );
}

/// Brand gradient card with two big white circles and rings at the top end.
/// Base for the hero search, auth art cards and the icon tile.
class BlueCard extends StatelessWidget {
  const BlueCard({
    super.key,
    this.height,
    this.radius = 28,
    this.children = const [],
    this.shadowOpacity = 0.25,
  });

  final double? height;
  final double radius;
  final List<Widget> children;
  final double shadowOpacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: FindarColors.brandGradient,
        boxShadow: [
          BoxShadow(
            color: FindarColors.brandBlue.withValues(alpha: shadowOpacity),
            blurRadius: 36,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            IgnorePointer(
              child: Stack(children: [
                Deco(
                  start: -90,
                  top: -110,
                  child: DecorCircle(
                      size: 260, color: Colors.white.withValues(alpha: 0.08)),
                ),
                Deco(
                  end: -70,
                  bottom: -100,
                  child: DecorCircle(
                      size: 240, color: Colors.white.withValues(alpha: 0.07)),
                ),
                const Deco(
                  end: -60,
                  top: -60,
                  child: Rings(
                      radii: [60, 90],
                      opacities: [0.18, 0.10],
                      color: Colors.white),
                ),
              ]),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// A decorative tile placement for [ArtCard].
class ArtTile {
  const ArtTile(this.icon, this.size,
      {this.start, this.end, this.top, this.bottom, this.rotation = 0});
  final FIconData icon;
  final double size;
  final double? start, end, top, bottom;
  final double rotation;
}

class ArtBubble {
  const ArtBubble(this.size,
      {this.start, this.end, this.top, this.bottom, this.opacity = 0.35});
  final double size;
  final double? start, end, top, bottom;
  final double opacity;
}

/// Blue art card used at the top of the auth screens.
class ArtCard extends StatelessWidget {
  const ArtCard({
    super.key,
    required this.height,
    required this.tiles,
    this.bubbles = const [],
  });
  final double height;
  final List<ArtTile> tiles;
  final List<ArtBubble> bubbles;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: RepaintBoundary(
        child: BlueCard(
          height: height,
          children: [
            for (final b in bubbles)
              Deco(
                  start: b.start,
                  end: b.end,
                  top: b.top,
                  bottom: b.bottom,
                  child: Bubble(size: b.size, opacity: b.opacity)),
            for (final t in tiles)
              Deco(
                  start: t.start,
                  end: t.end,
                  top: t.top,
                  bottom: t.bottom,
                  child: GlassTile(
                      icon: t.icon, size: t.size, rotation: t.rotation)),
          ],
        ),
      ),
    );
  }
}

/// Top tint + rings off the top-end corner + a faint circle on the start
/// side. Place as the first child of a screen-level [Stack].
class SoftTop extends StatelessWidget {
  const SoftTop({super.key, this.height = 280});
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: height,
      child: IgnorePointer(
        child: ExcludeSemantics(
          child: RepaintBoundary(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [c.accentT, c.bg],
                      ),
                    ),
                  ),
                ),
                const Deco(
                  end: -110,
                  top: -120,
                  child: Rings(
                      radii: [80, 120, 160], opacities: [0.14, 0.10, 0.06]),
                ),
                Deco(
                  start: -70,
                  top: height * 0.45,
                  child: DecorCircle(
                      size: 150, color: c.accent.withValues(alpha: 0.05)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Light tint + rings + three layered waves at the bottom (profile headers).
class WaveHeader extends StatelessWidget {
  const WaveHeader({super.key, required this.height, required this.child});
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    return SizedBox(
      height: height,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: ExcludeSemantics(
                child: RepaintBoundary(
                  child: Stack(clipBehavior: Clip.hardEdge, children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [c.accentT, c.bg],
                          ),
                        ),
                      ),
                    ),
                    const Deco(
                      end: -150,
                      top: -150,
                      child: Rings(
                          radii: [90, 130, 170, 210],
                          opacities: [0.14, 0.10, 0.07, 0.04]),
                    ),
                    const Deco(
                      start: -120,
                      top: 40,
                      child: Rings(radii: [70, 100], opacities: [0.10, 0.06]),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 150,
                      child: CustomPaint(painter: _WavePainter(c.accent)),
                    ),
                  ]),
                ),
              ),
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  _WavePainter(this.accent);
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / 390;
    final sy = size.height / 150;
    // p: y0 | c1 c2 end | c1 c2 endY  (viewBox 390x150, from wave_header()).
    Path wave(List<double> p) => Path()
      ..moveTo(0, p[0] * sy)
      ..cubicTo(
          p[1] * sx, p[2] * sy, p[3] * sx, p[4] * sy, p[5] * sx, p[6] * sy)
      ..cubicTo(
          p[7] * sx, p[8] * sy, p[9] * sx, p[10] * sy, 390 * sx, p[11] * sy)
      ..lineTo(390 * sx, 150 * sy)
      ..lineTo(0, 150 * sy)
      ..close();

    canvas.drawPath(wave([46, 80, 14, 150, 76, 232, 50, 302, 28, 350, 56, 38]),
        Paint()..color = accent.withValues(alpha: 0.14));
    canvas.drawPath(wave([82, 70, 60, 142, 108, 222, 86, 292, 66, 340, 96, 78]),
        Paint()..color = accent.withValues(alpha: 0.28));
    canvas.drawPath(
        wave([116, 90, 96, 162, 134, 252, 114, 312, 101, 352, 118, 108]),
        Paint()..color = FindarColors.brandBlue);
  }

  @override
  bool shouldRepaint(_WavePainter old) => old.accent != accent;
}

/// Empty/error/success illustration: tinted disc, rings, two small light
/// glass tiles and a sparkle around a centre icon.
class SpotIllustration extends StatelessWidget {
  const SpotIllustration({
    super.key,
    required this.child,
    this.size = 120,
    this.minis = const [FIcons.home, FIcons.pin],
  });

  final Widget child;
  final double size;
  final List<FIconData> minis;

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    final s = size;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: s,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: -s * 0.25,
              top: -s * 0.25,
              child: SizedBox.square(
                dimension: s * 1.5,
                child: CustomPaint(
                  painter: _RingsPainter(
                      [s * 0.62, s * 0.75], const [0.16, 0.08], c.accent, 1.2),
                ),
              ),
            ),
            Positioned(
              left: s * 0.1,
              top: s * 0.1,
              child: DecorCircle(
                size: s * 0.8,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [c.accentT, c.bg],
                ),
                border: Border.all(color: c.line),
              ),
            ),
            Deco(
              end: -s * 0.12,
              top: s * 0.02,
              child: GlassTile(
                  icon: minis[0], size: s * 0.3, rotation: 10, light: true),
            ),
            Deco(
              start: -s * 0.08,
              bottom: s * 0.06,
              child: GlassTile(
                  icon: minis[1], size: s * 0.25, rotation: -12, light: true),
            ),
            Deco(
                start: s * 0.12,
                top: -s * 0.02,
                child: const Sparkle(size: 12)),
            Positioned.fill(
              child: Center(
                child: IconTheme(
                    data: IconThemeData(color: c.accent), child: child),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Translucent pill used on the hero card (hashtags).
class GlassTag extends StatelessWidget {
  const GlassTag({super.key, required this.label, this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x2E041E46),
                  blurRadius: 16,
                  offset: Offset(0, 6))
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(
                color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
