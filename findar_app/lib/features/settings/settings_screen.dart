import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:findar/core/config/support_config.dart';
import 'package:findar/core/motion/motion.dart';
import 'package:findar/core/theme/findar_tokens.dart';
import 'package:findar/core/theme/theme_provider.dart';
import 'package:findar/core/widgets/decor/decor.dart';
import 'package:findar/core/widgets/f_icon.dart';
import 'package:findar/core/widgets/ui.dart';
import 'package:findar/l10n/app_localizations.dart';
import 'package:findar/logic/cubits/language_cubit.dart';
import 'package:findar/logic/cubits/profile_cubit.dart';
import 'package:findar/logic/cubits/settings_cubit.dart';
import 'package:findar/logic/session_reset.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _loggingOut = false;

  Future<void> _logout() async {
    final l10n = AppLocalizations.of(context)!;
    final c = context.fc;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.logoutConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              style: TextButton.styleFrom(foregroundColor: c.ink),
              child: Text(l10n.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: c.red),
              child: Text(l10n.logout)),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _loggingOut = true);
    final profile = context.read<ProfileCubit>();
    await profile.logout();
    if (!mounted) return;
    setState(() => _loggingOut = false);
    final st = profile.state;
    if (st['state'] == 'initial') {
      resetUserSession(context);
      Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
    } else {
      showAppSnack(context, '${st['message'] ?? l10n.errorOccurred}');
    }
  }

  Future<void> _launch(Uri uri) async {
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) showAppSnack(context, uri.path);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    final l10n = AppLocalizations.of(context)!;
    final theme = context.watch<ThemeProvider>();
    final lang = context.watch<LanguageCubit>().state;

    Widget langRow(String code, String title, String sub) => Semantics(
          selected: code == lang,
          inMutuallyExclusiveGroup: true,
          button: true,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              if (code == lang) return;
              Motion.softHaptic();
              context.read<SettingsCubit>().changeLanguage(code);
              context.read<LanguageCubit>().changeLanguage(code);
            },
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 56),
              child: Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title, style: context.tt.titleSmall),
                      Text(sub,
                          style: context.tt.bodySmall
                              ?.copyWith(fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                RadioDot(selected: code == lang),
                const SizedBox(width: 4),
              ]),
            ),
          ),
        );

    final hasSupport =
        SupportConfig.phone != null || SupportConfig.email != null;

    return Scaffold(
      backgroundColor: c.bg,
      body: Stack(children: [
        Positioned(
          left: -120,
          bottom: -40,
          child: IgnorePointer(
            child: Rings(radii: const [90, 130], opacities: const [0.10, 0.06]),
          ),
        ),
        SafeArea(
          child: Column(children: [
            FTopBar(title: l10n.settings),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  SettingsGroup(title: l10n.appearance, children: [
                    MenuRow(
                      icon: theme.isDarkMode ? FIcons.moon : FIcons.sun,
                      title: l10n.darkMode,
                      subtitle: l10n.darkModeSub,
                      trailing: Switch(
                        value: theme.isDarkMode,
                        onChanged: (v) {
                          Motion.softHaptic();
                          context.read<SettingsCubit>().toggleDarkMode();
                          theme.toggleTheme(v);
                        },
                      ),
                    ),
                  ]),
                  const SizedBox(height: 22),
                  SettingsGroup(title: l10n.language, children: [
                    langRow('en', 'English', l10n.english),
                    langRow('ar', 'العربية', l10n.arabic),
                    langRow('fr', 'Français', l10n.french),
                  ]),
                  if (hasSupport) ...[
                    const SizedBox(height: 22),
                    SettingsGroup(title: l10n.contactUs, children: [
                      if (SupportConfig.phone != null)
                        MenuRow(
                          icon: FIcons.phone,
                          title: l10n.callSupport,
                          subtitle: SupportConfig.phone,
                          onTap: () => _launch(
                              Uri(scheme: 'tel', path: SupportConfig.phone)),
                        ),
                      if (SupportConfig.email != null)
                        MenuRow(
                          icon: FIcons.mail,
                          title: l10n.emailSupport,
                          subtitle: SupportConfig.email,
                          onTap: () => _launch(
                              Uri(scheme: 'mailto', path: SupportConfig.email)),
                        ),
                    ]),
                  ],
                  const SizedBox(height: 22),
                  SettingsGroup(title: l10n.account, children: [
                    MenuRow(
                      icon: FIcons.logout,
                      title: l10n.logout,
                      color: c.red,
                      showChevron: false,
                      trailing: _loggingOut
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: c.red))
                          : null,
                      onTap: _loggingOut ? null : _logout,
                    ),
                  ]),
                ],
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}
