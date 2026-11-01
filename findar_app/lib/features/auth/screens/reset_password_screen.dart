import 'package:flutter/material.dart';

import 'package:findar/core/di/service_locator.dart';
import 'package:findar/core/motion/motion.dart';
import 'package:findar/core/repositories/auth_repository.dart';
import 'package:findar/core/widgets/f_icon.dart';
import 'package:findar/core/widgets/ui.dart';
import 'package:findar/features/auth/widgets/auth_scaffold.dart';
import 'package:findar/l10n/app_localizations.dart';

/// Step 3 of the password reset. Route arguments: {'email', 'code'}.
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _hidden = true;
  bool _loading = false;
  int _shake = 0;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) {
      setState(() => _shake++);
      return;
    }
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    setState(() => _loading = true);
    try {
      await getIt<AuthRepository>().resetPassword(
        args?['email'] as String? ?? '',
        args?['code'] as String? ?? '',
        _password.text,
      );
      if (!mounted) return;
      showAppSnack(context, l10n.passwordResetSuccess);
      Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _shake++;
      });
      showAppSnack(context, e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AuthScaffold(
      formKey: _formKey,
      bottom: ShakeOnChange(
        trigger: _shake == 0 ? null : _shake,
        child: FButton(
            label: l10n.updatePassword, loading: _loading, onPressed: _submit),
      ),
      children: [
        const Entrance(child: AuthArt.reset),
        const SizedBox(height: 18),
        ScreenTitle(l10n.newPasswordTitle, subtitle: l10n.newPasswordSub),
        const SizedBox(height: 18),
        AppField(
          label: l10n.newPasswordTitle,
          controller: _password,
          icon: FIcons.lock,
          obscure: _hidden,
          autofillHints: const [AutofillHints.newPassword],
          trailing: EyeToggle(
              hidden: _hidden, onTap: () => setState(() => _hidden = !_hidden)),
          validator: (v) {
            final t = v ?? '';
            if (t.length < 8) return l10n.passwordTooShort;
            if (!t.contains(RegExp(r'[A-Z]'))) {
              return l10n.passwordMissingUppercase;
            }
            if (!t.contains(RegExp(r'[a-z]'))) {
              return l10n.passwordMissingLowercase;
            }
            if (!t.contains(RegExp(r'[0-9]'))) {
              return l10n.passwordMissingNumber;
            }
            return null;
          },
        ),
        const SizedBox(height: 10),
        PasswordRules(controller: _password),
        const SizedBox(height: 18),
        AppField(
          label: l10n.confirmPassword,
          controller: _confirm,
          icon: FIcons.lock,
          obscure: _hidden,
          onSubmitted: (_) => _submit(),
          validator: (v) =>
              v != _password.text ? l10n.passwordsDontMatch : null,
        ),
      ],
    );
  }
}
