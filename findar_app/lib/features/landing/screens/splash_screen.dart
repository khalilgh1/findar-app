import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:findar/core/motion/motion.dart';
import 'package:findar/core/services/auth_manager.dart';
import 'package:findar/core/theme/findar_tokens.dart';
import 'package:findar/core/widgets/decor/decor.dart';
import 'package:findar/core/widgets/f_icon.dart';
import 'package:findar/core/widgets/ui.dart';
import 'package:findar/features/home/home_widgets.dart';
import 'package:findar/l10n/app_localizations.dart';
import 'package:findar/logic/cubits/auth_cubit.dart';

/// '/landing': the animated splash, then Welcome (signed out) or Home.
///
/// The native splash (flutter_native_splash) shows the same gradient tile on
/// the same background, so the hand-off into this screen is seamless.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  /// Intro: tile spring, mark draw, ring ripple, tiles drift in (1.1 s).
  late final AnimationController _intro = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1100));

  /// Loops: tile bob (4 s) and the progress bar.
  late final AnimationController _loop =
      AnimationController(vsync: this, duration: const Duration(seconds: 4));

  bool _welcome = false;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final reduced = Motion.reduced(context);
    if (reduced) {
      _intro.value = 1;
    } else {
      _intro.forward();
      _loop.repeat();
    }
    _next(reduced);
  }

  Future<void> _next(bool reduced) async {
    final loggedIn = AuthManager().isAuthenticated;
    await Future.delayed(Duration(milliseconds: reduced ? 400 : 1250));
    if (!mounted) return;
    if (loggedIn) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      _loop.stop();
      setState(() => _welcome = true);
    }
  }

  @override
  void dispose() {
    _intro.dispose();
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.fc.bg,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 450),
        switchInCurve: Curves.easeOut,
        child: _welcome
            ? const _Welcome(key: ValueKey('welcome'))
            : _Splash(
                key: const ValueKey('splash'), intro: _intro, loop: _loop),
      ),
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash({super.key, required this.intro, required this.loop});
  final AnimationController intro;
  final AnimationController loop;

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.sizeOf(context);
    final cy = size.height / 2 - 30;
    final cx = size.width / 2;

    final tileIn = CurvedAnimation(
        parent: intro,
        curve: const Interval(0, 0.55, curve: Curves.elasticOut));
    final drift = CurvedAnimation(
        parent: intro, curve: const Interval(0.25, 0.8, curve: Curves.easeOut));
    final ripple = CurvedAnimation(
        parent: intro, curve: const Interval(0.1, 0.9, curve: Curves.easeOut));
    final textIn = CurvedAnimation(
        parent: intro, curve: const Interval(0.45, 1, curve: Curves.easeOut));

    Widget tile(FIconData i, double s, double dx, double dy, double rot,
            double phase) =>
        Positioned(
          left: cx + dx,
          top: cy + dy,
          child: AnimatedBuilder(
            animation: Listenable.merge([drift, loop]),
            builder: (context, child) => Opacity(
              opacity: drift.value,
              child: Transform.translate(
                offset: Offset(
                    0,
                    (1 - drift.value) * 8 +
                        math.sin((loop.value + phase) * 2 * math.pi) * 3),
                child: child,
              ),
            ),
            child: GlassTile(icon: i, size: s, rotation: rot, light: true),
          ),
        );

    return Stack(children: [
      Positioned.fill(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0, 0.45, 0.7, 1],
              colors: [c.accentT, c.bg, c.bg, c.accentT],
            ),
          ),
        ),
      ),
      Positioned(
        left: cx - 300,
        top: cy - 300,
        child: FadeTransition(
          opacity: ripple,
          child: ScaleTransition(
            scale: Tween(begin: 0.8, end: 1.0).animate(ripple),
            child: const SizedBox.square(
              dimension: 600,
              child: Rings(
                  radii: [100, 145, 190, 240],
                  opacities: [0.16, 0.11, 0.07, 0.04]),
            ),
          ),
        ),
      ),
      Positioned(
          right: -80,
          top: 60,
          child:
              DecorCircle(size: 180, color: c.accent.withValues(alpha: 0.05))),
      Positioned(
          left: -60,
          bottom: 90,
          child:
              DecorCircle(size: 150, color: c.accent.withValues(alpha: 0.05))),
      tile(FIcons.pin, 46, -143, -172, -12, 0),
      tile(FIcons.bookmark, 40, 99, -186, 10, 0.25),
      tile(FIcons.key, 42, 83, 138, -8, 0.5),
      tile(FIcons.home, 38, -121, 150, 8, 0.75),
      Positioned(
          left: cx - 75,
          top: cy - 222,
          child:
              FadeTransition(opacity: drift, child: const Sparkle(size: 14))),
      Positioned(
          left: cx + 63,
          top: cy + 198,
          child:
              FadeTransition(opacity: drift, child: const Sparkle(size: 12))),
      Positioned(
        left: 0,
        right: 0,
        top: cy - 58,
        child: Column(children: [
          ScaleTransition(
            scale: Tween(begin: 0.9, end: 1.0).animate(tileIn),
            child: Container(
              width: 116,
              height: 116,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: FindarColors.brandGradient,
                boxShadow: [
                  BoxShadow(
                    color: FindarColors.brandBlue
                        .withValues(alpha: c.isDark ? 0.5 : 0.32),
                    blurRadius: 40,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: AnimatedBuilder(
                animation: intro,
                builder: (context, _) => FindarMark(
                  width: 68,
                  color: Colors.white,
                  // Stroke reveal over the first ~80% of the intro.
                  progress: (intro.value / 0.8).clamp(0.0, 1.0),
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          FadeTransition(
            opacity: textIn,
            child: Column(children: [
              Text('findar',
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.8,
                    height: 1,
                    color: c.ink,
                  )),
              const SizedBox(height: 14),
              Text(l10n.yourPropertyMarketplace,
                  style: context.tt.bodyLarge
                      ?.copyWith(color: c.muted, fontWeight: FontWeight.w600)),
            ]),
          ),
        ]),
      ),
      Positioned(
        left: cx - 60,
        bottom: 96 + MediaQuery.paddingOf(context).bottom * 0.5,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: Container(
            width: 120,
            height: 4,
            color: c.line,
            child: AnimatedBuilder(
              animation: loop,
              builder: (context, child) {
                // Two sweeps per 4 s loop.
                final t = (loop.value * 2) % 1;
                return Transform.translate(
                  offset: Offset(-44 + t * 164, 0),
                  child: child,
                );
              },
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                      color: c.accent, borderRadius: BorderRadius.circular(9)),
                ),
              ),
            ),
          ),
        ),
      ),
    ]);
  }
}

class _Welcome extends StatefulWidget {
  const _Welcome({super.key});

  @override
  State<_Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<_Welcome> {
  bool _google = false;

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.sizeOf(context);
    final photoH = size.height * 520 / 844;
    final sheetTop = size.height * 488 / 844;
    final top = MediaQuery.paddingOf(context).top;

    return BlocListener<AuthCubit, Map<String, dynamic>>(
      listener: (context, state) {
        if (!_google) return;
        if (state['state'] == 'done') {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
        } else if (state['state'] == 'error') {
          setState(() => _google = false);
          showAppSnack(context, '${state['message'] ?? l10n.errorOccurred}');
          context.read<AuthCubit>().clearError();
        }
      },
      child: SizedBox.expand(
        child: Stack(children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: photoH,
            child: Stack(fit: StackFit.expand, children: [
              Image.asset(
                'assets/find-dar-test1.jpg',
                fit: BoxFit.cover,
                cacheWidth:
                    (size.width * MediaQuery.devicePixelRatioOf(context))
                        .round(),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0, 0.3, 0.55, 1],
                    colors: [
                      Color(0x59000000),
                      Color(0x00000000),
                      Color(0x00000000),
                      Color(0x8C000000),
                    ],
                  ),
                ),
              ),
              PositionedDirectional(
                top: top + 16,
                start: 24,
                child: const FindarLockup(size: 24, color: Colors.white),
              ),
              PositionedDirectional(
                start: 24,
                end: 24,
                bottom: photoH - sheetTop + 26,
                child: Entrance(
                  offset: 16,
                  child: Text(
                    l10n.welcomeHeadline,
                    style: context.tt.displaySmall?.copyWith(
                        color: Colors.white, fontSize: 36, height: 1.08),
                  ),
                ),
              ),
            ]),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: sheetTop,
            bottom: 0,
            child: Entrance(
              offset: 40,
              delay: const Duration(milliseconds: 80),
              child: Container(
                decoration: BoxDecoration(
                  color: c.bg,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: EdgeInsets.fromLTRB(
                    24, 14, 24, 20 + MediaQuery.paddingOf(context).bottom),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                              color: c.line,
                              borderRadius: BorderRadius.circular(9)),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(l10n.welcomeBody,
                          style:
                              context.tt.bodyLarge?.copyWith(color: c.muted)),
                      const SizedBox(height: 20),
                      Row(children: [
                        Expanded(
                          child: FButton(
                            key: const Key('welcome-login'),
                            label: l10n.login,
                            onPressed: () =>
                                Navigator.pushNamed(context, '/login'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FButton(
                            label: l10n.createAccount,
                            kind: FButtonKind.secondary,
                            onPressed: () =>
                                Navigator.pushNamed(context, '/register'),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 14),
                      const OrDivider(),
                      const SizedBox(height: 14),
                      FButton(
                        label: l10n.continueWithGoogle,
                        kind: FButtonKind.secondary,
                        leading: const GoogleMark(),
                        loading: _google,
                        onPressed: () {
                          setState(() => _google = true);
                          context.read<AuthCubit>().loginWithGoogle();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
