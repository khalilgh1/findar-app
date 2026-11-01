import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

part 'f_icons_data.dart';

/// One outline icon from the Findar set (24x24 viewBox SVG markup).
@immutable
class FIconData {
  const FIconData(this.name, this.markup);
  final String name;
  final String markup;

  /// Icons that point somewhere and must flip in RTL.
  bool get directional => name == 'back' || name == 'chev' || name == 'logout';
}

/// Renders an [FIconData] with stroke [strokeWidth] in [color].
///
/// The SVG is parsed once per (icon, stroke, fill) and cached by flutter_svg;
/// colour is applied as a filter at paint time so recolouring never reparses.
class FIcon extends StatelessWidget {
  const FIcon(
    this.icon, {
    super.key,
    this.size = 20,
    this.color,
    this.strokeWidth = 1.8,
    this.filled = false,
    this.semanticLabel,
  });

  final FIconData icon;
  final double size;
  final Color? color;
  final double strokeWidth;
  final bool filled;
  final String? semanticLabel;

  static final Map<String, String> _svgCache = {};

  static String _svg(FIconData icon, double sw, bool filled) {
    final key = '${icon.name}|$sw|$filled';
    return _svgCache.putIfAbsent(
      key,
      () => '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" '
          'fill="${filled ? '#000' : 'none'}" stroke="#000" stroke-width="$sw" '
          'stroke-linecap="round" stroke-linejoin="round">${icon.markup}</svg>',
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = color ?? IconTheme.of(context).color ?? Colors.black;
    final picture = SvgPicture.string(
      _svg(icon, strokeWidth, filled),
      width: size,
      height: size,
      matchTextDirection: icon.directional,
      colorFilter: ColorFilter.mode(c, BlendMode.srcIn),
      excludeFromSemantics: semanticLabel == null,
      semanticsLabel: semanticLabel,
    );
    return SizedBox.square(dimension: size, child: picture);
  }
}
