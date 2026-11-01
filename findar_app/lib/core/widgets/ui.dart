import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:findar/core/motion/motion.dart';
import 'package:findar/core/theme/findar_tokens.dart';
import 'package:findar/core/widgets/decor/decor.dart';
import 'package:findar/core/widgets/f_icon.dart';
import 'package:findar/l10n/app_localizations.dart';

// ---------------------------------------------------------------- buttons

/// 44 round icon button (bordered by default).
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
    this.size = 44,
    this.iconSize = 20,
    this.background,
    this.foreground,
    this.border = true,
  });

  final FIconData icon;
  final String label;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final Color? background;
  final Color? foreground;
  final bool border;

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Pressable(
        onTap: onPressed,
        scale: 0.92,
        button: false,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: background ?? c.bg,
            shape: BoxShape.circle,
            border: border ? Border.all(color: c.line) : null,
          ),
          alignment: Alignment.center,
          child: FIcon(icon, size: iconSize, color: foreground ?? c.ink),
        ),
      ),
    );
  }
}

/// Back button in the circle style; pops the route.
class FBackButton extends StatelessWidget {
  const FBackButton({super.key, this.onPhoto = false, this.close = false});
  final bool onPhoto;
  final bool close;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return CircleIconButton(
      icon: close ? FIcons.x : FIcons.back,
      label: close ? l10n.close : l10n.back,
      onPressed: () => Navigator.maybePop(context),
      background: onPhoto ? const Color(0xF0FFFFFF) : null,
      foreground: onPhoto ? const Color(0xFF111317) : null,
      border: !onPhoto,
    );
  }
}

/// Button kinds from the generator's btn().
enum FButtonKind { primary, secondary, danger }

/// Pill button (52). The primary kind morphs into a 52 circle with a spinner
/// while [loading].
class FButton extends StatelessWidget {
  const FButton({
    super.key,
    required this.label,
    this.onPressed,
    this.kind = FButtonKind.primary,
    this.icon,
    this.leading,
    this.loading = false,
    this.height = 52,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final FButtonKind kind;
  final FIconData? icon;
  final Widget? leading;
  final bool loading;
  final double height;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    final (bg, fg, side) = switch (kind) {
      FButtonKind.primary => (c.btn, c.btnText, null),
      FButtonKind.secondary => (c.bg, c.ink, BorderSide(color: c.line)),
      FButtonKind.danger => (c.bg, c.red, BorderSide(color: c.line)),
    };
    final disabled = onPressed == null && !loading;
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: 10)],
        if (icon != null) ...[
          FIcon(icon!, size: 20, color: disabled ? c.muted : fg),
          const SizedBox(width: 10),
        ],
        Flexible(
          child: Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.tt.labelLarge
                  ?.copyWith(color: disabled ? c.muted : fg)),
        ),
      ],
    );

    return LayoutBuilder(builder: (context, box) {
      final full = expand && box.hasBoundedWidth ? box.maxWidth : null;
      final width = loading ? height : full;
      return Semantics(
        button: true,
        enabled: !disabled,
        label: label,
        excludeSemantics: true,
        child: Center(
          widthFactor: expand ? null : 1,
          heightFactor: 1,
          child: Pressable(
            onTap: loading ? null : onPressed,
            scale: 0.97,
            button: false,
            child: AnimatedContainer(
              duration: Motion.reduced(context) ? Duration.zero : Motion.medium,
              curve: Motion.standard,
              width: width,
              height: height,
              padding: EdgeInsets.symmetric(horizontal: loading ? 0 : 22),
              decoration: BoxDecoration(
                color: disabled ? c.surf : bg,
                borderRadius: BorderRadius.circular(999),
                border: side == null ? null : Border.fromBorderSide(side),
              ),
              alignment: Alignment.center,
              child: AnimatedSwitcher(
                duration: Motion.fast,
                child: loading
                    ? SizedBox(
                        key: const ValueKey('spin'),
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.4, color: fg),
                      )
                    : KeyedSubtree(
                        key: const ValueKey('label'), child: content),
              ),
            ),
          ),
        ),
      );
    });
  }
}

/// Google "G" mark (official colours).
class GoogleMark extends StatelessWidget {
  const GoogleMark({super.key, this.size = 20});
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
      dimension: size, child: CustomPaint(painter: _GPainter()));
}

class _GPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final c = Offset(r, r);
    final sw = size.width * 0.2;
    final rect = Rect.fromCircle(center: c, radius: r - sw / 2);
    Paint p(Color col) => Paint()
      ..color = col
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw;
    const d = 3.14159265 / 180;
    canvas.drawArc(rect, -40 * d, -95 * d, false, p(const Color(0xFFFF3D00)));
    canvas.drawArc(rect, -135 * d, -90 * d, false, p(const Color(0xFFFFC107)));
    canvas.drawArc(rect, -225 * d, -95 * d, false, p(const Color(0xFF4CAF50)));
    canvas.drawArc(rect, 40 * d, -40 * d, false, p(const Color(0xFF1976D2)));
    canvas.drawRect(Rect.fromLTWH(r, r - sw / 2, r - sw / 4, sw),
        Paint()..color = const Color(0xFF1976D2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// "—— or ——" divider.
class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    return Row(children: [
      Expanded(child: Container(height: 1, color: c.line)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(AppLocalizations.of(context)!.orLabel,
            style: context.tt.bodySmall),
      ),
      Expanded(child: Container(height: 1, color: c.line)),
    ]);
  }
}

// ---------------------------------------------------------------- layout

/// Top bar: 56 high, leading circle button, centred title, trailing slot.
class FTopBar extends StatelessWidget {
  const FTopBar({
    super.key,
    this.title,
    this.leading,
    this.trailing,
    this.close = false,
    this.showLeading = true,
  });

  final String? title;
  final Widget? leading;
  final Widget? trailing;
  final bool close;
  final bool showLeading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(children: [
          if (showLeading)
            leading ?? FBackButton(close: close)
          else
            const SizedBox(width: 44),
          Expanded(
            child: Text(
              title ?? '',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.tt.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.17),
            ),
          ),
          trailing ?? const SizedBox(width: 44),
        ]),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: Semantics(
          header: true,
          child: Text(title, style: context.tt.headlineSmall),
        ),
      ),
      if (action != null)
        GestureDetector(
          onTap: onAction,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(action!,
                style: context.tt.titleSmall
                    ?.copyWith(fontSize: 14, color: context.fc.accent)),
          ),
        ),
    ]);
  }
}

/// Screen title block: 30/800 title with an optional muted subtitle.
class ScreenTitle extends StatelessWidget {
  const ScreenTitle(this.title, {super.key, this.subtitle});
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
            header: true, child: Text(title, style: context.tt.headlineLarge)),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(subtitle!,
              style: context.tt.bodyLarge?.copyWith(color: context.fc.muted)),
        ],
      ],
    );
  }
}

/// Sticky bottom bar (bg, top hairline, safe-area aware).
class StickyBar extends StatelessWidget {
  const StickyBar({super.key, required this.child, this.border = true});
  final Widget child;
  final bool border;

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    final inset = MediaQuery.paddingOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 14, 20, 14 + (inset > 0 ? inset : 6)),
      decoration: BoxDecoration(
        color: c.bg,
        border: border ? Border(top: BorderSide(color: c.line)) : null,
      ),
      child: child,
    );
  }
}

/// Rounded bordered card.
class FCard extends StatelessWidget {
  const FCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.radius = 20,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: context.fc.line),
        ),
        child: child,
      );
}

class FDivider extends StatelessWidget {
  const FDivider({super.key});
  @override
  Widget build(BuildContext context) =>
      Container(height: 1, color: context.fc.line);
}

/// Group with an uppercase overline and a card (Settings).
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) items.add(const FDivider());
      items.add(children[i]);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 4, bottom: 8),
          child: Text(title.toUpperCase(), style: context.tt.labelSmall),
        ),
        FCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Column(children: items),
        ),
      ],
    );
  }
}

/// Settings/contact row: 40 icon tile, title, optional subtitle, trailing.
class MenuRow extends StatelessWidget {
  const MenuRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.color,
    this.showChevron = true,
  });

  final FIconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? color;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    final fg = color ?? c.ink;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: c.surf, borderRadius: BorderRadius.circular(12)),
              alignment: Alignment.center,
              child: FIcon(icon, size: 20, color: fg),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: context.tt.titleSmall?.copyWith(color: fg)),
                  if (subtitle != null)
                    Text(subtitle!,
                        style: context.tt.bodySmall
                            ?.copyWith(fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (showChevron && onTap != null)
              FIcon(FIcons.chev, size: 18, color: c.muted),
          ]),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- inputs

/// Labelled field (label 13/700 above a surf, radius-16 input).
class AppField extends StatelessWidget {
  const AppField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.icon,
    this.trailing,
    this.keyboardType,
    this.obscure = false,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.minLines,
    this.textInputAction,
    this.inputFormatters,
    this.enabled = true,
    this.autofillHints,
    this.focusNode,
    this.fieldKey,
    this.readOnly = false,
    this.onTap,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final FIconData? icon;
  final Widget? trailing;
  final TextInputType? keyboardType;
  final bool obscure;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final int maxLines;
  final int? minLines;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final Iterable<String>? autofillHints;
  final FocusNode? focusNode;
  final Key? fieldKey;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.tt.labelMedium),
        const SizedBox(height: 8),
        TextFormField(
          key: fieldKey,
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          obscureText: obscure,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          maxLines: obscure ? 1 : maxLines,
          minLines: minLines,
          enabled: enabled,
          readOnly: readOnly,
          onTap: onTap,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          autofillHints: autofillHints,
          style: context.tt.bodyLarge?.copyWith(height: 1.3),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon == null
                ? null
                : Padding(
                    padding:
                        const EdgeInsetsDirectional.only(start: 16, end: 10),
                    child: FIcon(icon!, size: 20, color: c.muted),
                  ),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
            suffixIcon: trailing == null
                ? null
                : Padding(
                    padding:
                        const EdgeInsetsDirectional.only(end: 14, start: 8),
                    child: trailing,
                  ),
            suffixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
          ),
        ),
      ],
    );
  }
}

/// Muted unit suffix ("DA", "m²") for fields.
class UnitSuffix extends StatelessWidget {
  const UnitSuffix(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
      style: TextStyle(
          color: context.fc.muted, fontWeight: FontWeight.w800, fontSize: 14));
}

/// Pill segmented control with a sliding thumb (220 ms).
class PillSegmented<T> extends StatelessWidget {
  const PillSegmented({
    super.key,
    required this.values,
    required this.labels,
    required this.selected,
    required this.onChanged,
    this.height = 44,
  });

  final List<T> values;
  final List<String> labels;
  final T selected;
  final ValueChanged<T> onChanged;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    final idx = values.indexOf(selected).clamp(0, values.length - 1);
    final dir = Directionality.of(context);
    final n = values.length;
    final x = n == 1 ? 0.0 : (idx / (n - 1)) * 2 - 1;
    return Container(
      height: height,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: c.surf, borderRadius: BorderRadius.circular(999)),
      child: Stack(children: [
        AnimatedAlign(
          duration: Motion.reduced(context)
              ? Duration.zero
              : const Duration(milliseconds: 220),
          curve: Motion.standard,
          alignment: Alignment(dir == TextDirection.rtl ? -x : x, 0),
          child: FractionallySizedBox(
            widthFactor: 1 / n,
            child: Container(
              decoration: BoxDecoration(
                color: c.isDark ? c.line : c.bg,
                borderRadius: BorderRadius.circular(999),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x1F000000),
                      blurRadius: 3,
                      offset: Offset(0, 1))
                ],
              ),
            ),
          ),
        ),
        Row(children: [
          for (var i = 0; i < n; i++)
            Expanded(
              child: Semantics(
                selected: i == idx,
                button: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (i != idx) {
                      Motion.softHaptic();
                      onChanged(values[i]);
                    }
                  },
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: Motion.fast,
                      style: TextStyle(
                        fontFamily: context.tt.bodyMedium?.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: i == idx ? c.ink : c.muted,
                      ),
                      child: Text(labels[i],
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ),
              ),
            ),
        ]),
      ]),
    );
  }
}

/// Selectable chip (ink when selected), optional icon. Cross-fades 150 ms.
class SelectChip extends StatelessWidget {
  const SelectChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.height = 38,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final FIconData? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    final fg = selected ? c.btnText : c.ink;
    return Semantics(
      selected: selected,
      button: true,
      label: label,
      excludeSemantics: true,
      child: Pressable(
        onTap: onTap,
        button: false,
        scale: 0.95,
        child: SizedBox(
          height: height < 44 ? 44 : height,
          child: Center(
            widthFactor: 1,
            child: AnimatedContainer(
              duration: Motion.fast,
              height: height,
              constraints: const BoxConstraints(minWidth: 48),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: selected ? c.btn : c.bg,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: selected ? c.btn : c.line),
              ),
              child: Center(
                widthFactor: 1,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  if (icon != null) ...[
                    FIcon(icon!, size: 16, color: fg),
                    const SizedBox(width: 6),
                  ],
                  Text(label,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: fg)),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Any / 1 / 2 / 3 / 4+ pills (0 = Any).
class NumberPills extends StatelessWidget {
  const NumberPills({super.key, required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final opts = [(0, l10n.any), (1, '1'), (2, '2'), (3, '3'), (4, '4+')];
    return Wrap(spacing: 8, runSpacing: 8, children: [
      for (final (v, t) in opts)
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 48),
          child: SelectChip(
              label: t,
              selected: v == value,
              onTap: () => onChanged(v),
              height: 44),
        ),
    ]);
  }
}

/// − value + stepper in a surf box.
class FStepper extends StatelessWidget {
  const FStepper({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 20,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    final l10n = AppLocalizations.of(context)!;
    Widget b(FIconData i, String lab, bool enabled, int next) =>
        CircleIconButton(
          icon: i,
          label: '$lab $label',
          size: 40,
          iconSize: 18,
          foreground: enabled ? c.ink : c.line,
          onPressed: enabled
              ? () {
                  Motion.softHaptic();
                  onChanged(next);
                }
              : null,
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.tt.labelMedium),
        const SizedBox(height: 8),
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
              color: c.surf, borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            b(FIcons.minus, l10n.decrease, value > min, value - 1),
            Expanded(
              child: Center(
                child: AnimatedSwitcher(
                  duration: Motion.fast,
                  transitionBuilder: (child, a) =>
                      FadeTransition(opacity: a, child: child),
                  child: Text('$value',
                      key: ValueKey(value), style: context.tt.titleMedium),
                ),
              ),
            ),
            b(FIcons.plus, l10n.increase, value < max, value + 1),
          ]),
        ),
      ],
    );
  }
}

/// Selectable card with a radio (report reasons, payment methods, accounts).
class RadioCard extends StatelessWidget {
  const RadioCard({
    super.key,
    required this.selected,
    required this.onTap,
    required this.child,
    this.showRadio = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    this.radius = 14,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;
  final bool showRadio;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      button: true,
      child: GestureDetector(
        onTap: () {
          Motion.softHaptic();
          onTap();
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: const BoxConstraints(minHeight: 52),
          padding: padding,
          decoration: BoxDecoration(
            color: selected ? c.accentT : c.bg,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
                color: selected ? c.accent : c.line, width: selected ? 2 : 1),
          ),
          child: Row(children: [
            if (showRadio) ...[
              RadioDot(selected: selected),
              const SizedBox(width: 12),
            ],
            Expanded(child: child),
          ]),
        ),
      ),
    );
  }
}

/// Animated radio dot (ring grows when selected).
class RadioDot extends StatelessWidget {
  const RadioDot({super.key, required this.selected, this.size = 22});
  final bool selected;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? c.accent : c.bg,
        border: Border.all(color: selected ? c.accent : c.line, width: 2),
      ),
      alignment: Alignment.center,
      child: AnimatedScale(
        scale: selected ? 1 : 0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutBack,
        child: FIcon(FIcons.check,
            size: size * 0.6, strokeWidth: 3, color: Colors.white),
      ),
    );
  }
}

/// Password rule chip ("8+ characters") that ticks green when met.
class RuleChip extends StatelessWidget {
  const RuleChip({super.key, required this.label, required this.ok});
  final String label;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    final col = ok ? c.green : c.muted;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        transitionBuilder: (child, a) => ScaleTransition(
            scale: Tween(begin: 0.6, end: 1.0).animate(a), child: child),
        child: FIcon(ok ? FIcons.check : FIcons.minus,
            key: ValueKey(ok), size: 14, color: col, strokeWidth: 2.2),
      ),
      const SizedBox(width: 6),
      AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 180),
        style: TextStyle(
            fontFamily: context.tt.bodyMedium?.fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: col),
        child: Text(label),
      ),
    ]);
  }
}

/// Live password rules (8+, upper, lower, number).
class PasswordRules extends StatelessWidget {
  const PasswordRules({super.key, required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, v, _) {
        final t = v.text;
        return Wrap(spacing: 14, runSpacing: 8, children: [
          RuleChip(label: l10n.rule8Chars, ok: t.length >= 8),
          RuleChip(label: l10n.ruleUppercase, ok: t.contains(RegExp(r'[A-Z]'))),
          RuleChip(label: l10n.ruleLowercase, ok: t.contains(RegExp(r'[a-z]'))),
          RuleChip(label: l10n.ruleNumber, ok: t.contains(RegExp(r'[0-9]'))),
        ]);
      },
    );
  }
}

// ---------------------------------------------------------------- people

String initialsOf(String? name) {
  final parts = (name ?? '')
      .trim()
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.characters.first.toUpperCase();
  return (parts[0].characters.first + parts[1].characters.first).toUpperCase();
}

/// Avatar: network photo when there is one, otherwise initials on accentT.
/// Never a stock person photo.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 48,
  });

  final String? name;
  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    final url = imageUrl?.trim() ?? '';
    final initials = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: c.accentT, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(initialsOf(name),
          style: TextStyle(
              color: c.accent,
              fontSize: size * 0.36,
              fontWeight: FontWeight.w800)),
    );
    if (!url.startsWith('http')) return ExcludeSemantics(child: initials);
    final px = (size * MediaQuery.devicePixelRatioOf(context)).round();
    return ExcludeSemantics(
      child: ClipOval(
        child: Image.network(
          url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          cacheWidth: px,
          errorBuilder: (_, __, ___) => initials,
          frameBuilder: (context, child, frame, sync) =>
              frame == null && !sync ? initials : child,
        ),
      ),
    );
  }
}

/// Stat tile (icon, value, label) for listing details.
class StatTile extends StatelessWidget {
  const StatTile(
      {super.key,
      required this.icon,
      required this.value,
      required this.label});
  final FIconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: c.line),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FIcon(icon, size: 22, color: c.accent),
          const SizedBox(height: 6),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.tt.titleMedium),
          const SizedBox(height: 2),
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.tt.bodySmall?.copyWith(fontSize: 12)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- states

class _Block extends StatelessWidget {
  const _Block({this.width, required this.height, this.radius = 10});
  final double? width;
  final double height;
  final double radius;
  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
            color: context.fc.surf,
            borderRadius: BorderRadius.circular(radius)),
      );
}

/// Skeleton row (104 photo + three text bars).
class SkeletonRow extends StatelessWidget {
  const SkeletonRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const _Block(width: 104, height: 104, radius: 16),
      const SizedBox(width: 14),
      Expanded(
        child: LayoutBuilder(
          builder: (context, b) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Block(width: b.maxWidth * 0.7, height: 14),
              const SizedBox(height: 10),
              _Block(width: b.maxWidth * 0.5, height: 12),
              const SizedBox(height: 10),
              _Block(width: b.maxWidth * 0.4, height: 16),
            ],
          ),
        ),
      ),
    ]);
  }
}

/// Skeleton for a photo card (feature / wide / grid).
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key, this.width, this.photoHeight = 196});
  final double? width;
  final double photoHeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Block(height: photoHeight, radius: 20),
          const SizedBox(height: 12),
          const _Block(width: 140, height: 18),
          const SizedBox(height: 8),
          const _Block(width: 190, height: 14),
          const SizedBox(height: 8),
          const _Block(width: 110, height: 12),
        ],
      ),
    );
  }
}

/// A shimmering column of [count] skeleton rows.
class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.count = 3, this.card = false});
  final int count;
  final bool card;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Column(children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) SizedBox(height: card ? 24 : 16),
          card ? const SkeletonCard(photoHeight: 200) : const SkeletonRow(),
        ],
      ]),
    );
  }
}

/// "You're offline" banner with Retry.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, this.onRetry, this.body});
  final VoidCallback? onRetry;
  final String? body;

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration:
          BoxDecoration(color: c.surf, borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        FIcon(FIcons.wifiOff, size: 22, color: c.ink),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.youreOffline,
                  style: context.tt.titleSmall
                      ?.copyWith(fontSize: 14, fontWeight: FontWeight.w800)),
              Text(body ?? l10n.offlineBannerBody,
                  style: context.tt.bodySmall
                      ?.copyWith(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        if (onRetry != null) ...[
          const SizedBox(width: 8),
          FButton(
              label: l10n.retry, onPressed: onRetry, height: 36, expand: false),
        ],
      ]),
    );
  }
}

/// Spot illustration + title + body + optional action (empty and error).
class StateMessage extends StatelessWidget {
  const StateMessage({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
    this.secondaryAction = false,
    this.dashed = false,
    this.bordered = true,
  });

  final FIconData icon;
  final String title;
  final String body;
  final String? actionLabel;
  final FIconData? actionIcon;
  final VoidCallback? onAction;
  final bool secondaryAction;
  final bool dashed;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        SpotIllustration(
          size: 110,
          child: FIcon(icon, size: 34, color: c.accent),
        ),
        const SizedBox(height: 18),
        Text(title,
            textAlign: TextAlign.center,
            style: context.tt.titleMedium?.copyWith(fontSize: 16)),
        const SizedBox(height: 6),
        Text(body,
            textAlign: TextAlign.center,
            style: context.tt.bodyMedium?.copyWith(color: c.muted)),
        if (actionLabel != null) ...[
          const SizedBox(height: 14),
          FButton(
            label: actionLabel!,
            icon: actionIcon,
            onPressed: onAction,
            kind: secondaryAction ? FButtonKind.secondary : FButtonKind.primary,
            height: 44,
            expand: false,
          ),
        ],
      ],
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: bordered
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: c.line),
            )
          : null,
      child: content,
    );
  }
}

/// Error state with "Try again".
class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.onRetry, this.title, this.body});
  final VoidCallback onRetry;
  final String? title;
  final String? body;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return StateMessage(
      icon: FIcons.wifiOff,
      title: title ?? l10n.couldntLoadListings,
      body: body ?? l10n.couldntLoadBody,
      actionLabel: l10n.tryAgain,
      actionIcon: FIcons.refresh,
      onAction: onRetry,
    );
  }
}

/// Heuristic used by the cubits' string errors.
bool isNetworkError(String? message) {
  final m = (message ?? '').toLowerCase();
  return m.contains('internet') ||
      m.contains('offline') ||
      m.contains('network') ||
      m.contains('connection') ||
      m.contains('socket') ||
      m.contains('cannot reach server');
}

/// Dark floating snackbar, optional action (Undo).
void showAppSnack(
  BuildContext context,
  String message, {
  String? actionLabel,
  VoidCallback? onAction,
  Duration duration = const Duration(seconds: 3),
}) {
  final m = ScaffoldMessenger.maybeOf(context);
  if (m == null) return;
  m.clearSnackBars();
  m.showSnackBar(SnackBar(
    content: Text(message),
    duration: duration,
    persist: false,
    action: actionLabel == null
        ? null
        : SnackBarAction(label: actionLabel, onPressed: onAction ?? () {}),
  ));
}
