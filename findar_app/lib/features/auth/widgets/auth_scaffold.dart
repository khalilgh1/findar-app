import 'package:flutter/material.dart';

import 'package:findar/core/theme/findar_tokens.dart';
import 'package:findar/core/widgets/decor/decor.dart';
import 'package:findar/core/widgets/f_icon.dart';
import 'package:findar/core/widgets/ui.dart';
import 'package:findar/l10n/app_localizations.dart';

/// Shared layout for the auth screens: SoftTop tint, a top bar, scrollable
/// content and an optional sticky bottom button.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.children,
    this.title,
    this.trailing,
    this.bottom,
    this.formKey,
    this.softTopHeight = 260,
  });

  final List<Widget> children;
  final String? title;
  final Widget? trailing;
  final Widget? bottom;
  final GlobalKey<FormState>? formKey;
  final double softTopHeight;

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    Widget body = ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
      children: children,
    );
    if (formKey != null) body = Form(key: formKey, child: body);

    return Scaffold(
      backgroundColor: context.fc.bg,
      body: Stack(children: [
        SoftTop(height: softTopHeight),
        SafeArea(
          bottom: false,
          child: Column(children: [
            FTopBar(title: title, showLeading: canPop, trailing: trailing),
            Expanded(child: body),
            if (bottom != null) StickyBar(child: bottom!),
            if (bottom == null)
              SizedBox(height: MediaQuery.paddingOf(context).bottom),
          ]),
        ),
      ]),
    );
  }
}

/// Art card presets from the canvas (login / forgot / reset).
abstract final class AuthArt {
  static const login = ArtCard(
    height: 150,
    tiles: [
      ArtTile(FIcons.home, 66, start: 34, top: 40, rotation: -8),
      ArtTile(FIcons.pin, 48, start: 132, top: 16, rotation: 10),
      ArtTile(FIcons.bookmark, 44, start: 206, top: 84, rotation: -6),
      ArtTile(FIcons.message, 52, end: 30, top: 26, rotation: 8),
      ArtTile(FIcons.phone, 38, start: 124, top: 98, rotation: -12),
    ],
    bubbles: [
      ArtBubble(14, end: 112, top: 30),
      ArtBubble(10, start: 22, top: 18),
      ArtBubble(18, end: 54, bottom: 18, opacity: 0.25),
    ],
  );

  static const forgot = ArtCard(
    height: 130,
    tiles: [
      ArtTile(FIcons.mail, 64, start: 40, top: 34, rotation: -8),
      ArtTile(FIcons.lock, 46, start: 140, top: 18, rotation: 10),
      ArtTile(FIcons.shield, 50, end: 40, top: 40, rotation: 8),
      ArtTile(FIcons.key, 38, start: 200, top: 80, rotation: -10),
    ],
    bubbles: [
      ArtBubble(12, end: 120, top: 24),
      ArtBubble(16, start: 24, bottom: 16, opacity: 0.25),
    ],
  );

  static const reset = ArtCard(
    height: 130,
    tiles: [
      ArtTile(FIcons.lock, 64, start: 40, top: 34, rotation: -8),
      ArtTile(FIcons.shield, 48, start: 146, top: 18, rotation: 10),
      ArtTile(FIcons.check, 44, end: 44, top: 44, rotation: 8),
      ArtTile(FIcons.key, 38, start: 210, top: 82, rotation: -10),
    ],
    bubbles: [
      ArtBubble(12, end: 120, top: 22),
      ArtBubble(16, start: 22, bottom: 16, opacity: 0.25),
    ],
  );
}

/// Eye toggle for password fields.
class EyeToggle extends StatelessWidget {
  const EyeToggle({super.key, required this.hidden, required this.onTap});
  final bool hidden;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: hidden
          ? AppLocalizations.of(context)!.showPassword
          : AppLocalizations.of(context)!.hidePassword,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: FIcon(hidden ? FIcons.eye : FIcons.eyeOff,
              size: 20, color: context.fc.muted),
        ),
      ),
    );
  }
}

/// "Question? Action" line with a bold blue link.
class AuthSwitchLine extends StatelessWidget {
  const AuthSwitchLine(
      {super.key,
      required this.text,
      required this.action,
      required this.onTap});
  final String text;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    return Center(
      child: Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
        Text('$text ', style: context.tt.bodyMedium?.copyWith(color: c.muted)),
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(action,
                style: context.tt.bodyMedium
                    ?.copyWith(color: c.accent, fontWeight: FontWeight.w800)),
          ),
        ),
      ]),
    );
  }
}
