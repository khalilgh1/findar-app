import 'package:flutter/material.dart';

import 'package:findar/core/di/service_locator.dart';
import 'package:findar/core/motion/motion.dart';
import 'package:findar/core/repositories/auth_repository.dart';
import 'package:findar/core/theme/findar_tokens.dart';
import 'package:findar/core/widgets/f_icon.dart';
import 'package:findar/core/widgets/ui.dart';
import 'package:findar/features/auth/widgets/auth_scaffold.dart';
import 'package:findar/l10n/app_localizations.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _code = TextEditingController();
  final _codeFocus = FocusNode();
  final _auth = getIt<AuthRepository>();
  bool _sent = false;
  bool _loading = false;
  int _shake = 0;

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  String _clean(Object e) => e.toString().replaceFirst('Exception: ', '');

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _shake++);
      return;
    }
    setState(() => _loading = true);
    try {
      await _auth.sendResetCode(_email.text);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _sent = true;
      });
      Future.delayed(Motion.medium, () {
        if (mounted) _codeFocus.requestFocus();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _shake++;
      });
      showAppSnack(context, _clean(e));
    }
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _shake++);
      return;
    }
    setState(() => _loading = true);
    try {
      await _auth.checkResetCode(_email.text, _code.text);
      if (!mounted) return;
      setState(() => _loading = false);
      Navigator.pushNamed(context, '/reset-password', arguments: {
        'email': _email.text.trim(),
        'code': _code.text.trim(),
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _shake++;
      });
      showAppSnack(context, _clean(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    final l10n = AppLocalizations.of(context)!;

    return AuthScaffold(
      formKey: _formKey,
      children: [
        const Entrance(child: AuthArt.forgot),
        const SizedBox(height: 18),
        ScreenTitle(l10n.resetPassword, subtitle: l10n.resetPasswordSub),
        const SizedBox(height: 18),
        AppField(
          label: l10n.emailAddress,
          controller: _email,
          icon: FIcons.mail,
          enabled: !_sent,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          onSubmitted: (_) => _sent ? null : _send(),
          validator: (v) {
            final t = v?.trim() ?? '';
            if (t.isEmpty) return l10n.emailRequired;
            if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$').hasMatch(t)) {
              return l10n.invalidEmail;
            }
            return null;
          },
        ),
        AnimatedSize(
          duration: Motion.reduced(context) ? Duration.zero : Motion.medium,
          curve: Motion.standard,
          alignment: Alignment.topCenter,
          child: !_sent
              ? const SizedBox(width: double.infinity)
              : Column(children: [
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                        color: c.greenT,
                        borderRadius: BorderRadius.circular(14)),
                    child: Row(children: [
                      FIcon(FIcons.check, size: 18, color: c.green),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(l10n.codeSent,
                            style: context.tt.titleSmall
                                ?.copyWith(fontSize: 14, color: c.green)),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 18),
                  AppField(
                    label: l10n.verificationCode,
                    controller: _code,
                    focusNode: _codeFocus,
                    hint: l10n.enterCode,
                    icon: FIcons.shield,
                    keyboardType: TextInputType.number,
                    autofillHints: const [AutofillHints.oneTimeCode],
                    onSubmitted: (_) => _verify(),
                    validator: (v) => (_sent && (v ?? '').trim().isEmpty)
                        ? l10n.fieldRequired
                        : null,
                  ),
                ]),
        ),
        const SizedBox(height: 20),
        ShakeOnChange(
          trigger: _shake == 0 ? null : _shake,
          child: FButton(
            label: _sent ? l10n.verifyCode : l10n.sendCode,
            loading: _loading,
            onPressed: _sent ? _verify : _send,
          ),
        ),
        if (_sent) ...[
          const SizedBox(height: 6),
          AuthSwitchLine(
            text: l10n.didntGetIt,
            action: l10n.resendCode,
            onTap: _loading ? () {} : _send,
          ),
        ],
      ],
    );
  }
}
