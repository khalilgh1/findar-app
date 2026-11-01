import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:findar/core/motion/motion.dart';
import 'package:findar/core/widgets/f_icon.dart';
import 'package:findar/core/widgets/ui.dart';
import 'package:findar/features/auth/widgets/auth_scaffold.dart';
import 'package:findar/l10n/app_localizations.dart';
import 'package:findar/logic/cubits/auth_cubit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hidden = true;
  bool _google = false;
  int _shake = 0;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      setState(() => _shake++);
      return;
    }
    _google = false;
    context
        .read<AuthCubit>()
        .login(email: _email.text.trim(), password: _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<AuthCubit, Map<String, dynamic>>(
      listener: (context, state) {
        if (state['state'] == 'done') {
          // No success snackbar: it used to sit over the tab bar and
          // swallow the first tap.
          Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
        }
        if (state['state'] == 'error' && state['message'] != null) {
          setState(() => _shake++);
          showAppSnack(context, state['message'] as String);
          Future.delayed(const Duration(milliseconds: 100), () {
            if (context.mounted) context.read<AuthCubit>().clearError();
          });
        }
      },
      builder: (context, state) {
        final loading = state['state'] == 'loading';
        return AuthScaffold(
          formKey: _formKey,
          children: [
            const Entrance(child: AuthArt.login),
            const SizedBox(height: 18),
            ScreenTitle(l10n.welcomeBack, subtitle: l10n.loginSubtitle),
            const SizedBox(height: 18),
            AppField(
              fieldKey: const Key('login-email'),
              label: l10n.emailAddress,
              controller: _email,
              icon: FIcons.mail,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: (v) {
                final t = v?.trim() ?? '';
                if (t.isEmpty) return l10n.emailRequired;
                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$').hasMatch(t)) {
                  return l10n.invalidEmail;
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            AppField(
              fieldKey: const Key('login-password'),
              label: l10n.password,
              controller: _password,
              icon: FIcons.lock,
              obscure: _hidden,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              onSubmitted: (_) => _submit(),
              trailing: EyeToggle(
                  hidden: _hidden,
                  onTap: () => setState(() => _hidden = !_hidden)),
              validator: (v) =>
                  (v == null || v.isEmpty) ? l10n.passwordRequired : null,
            ),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/forgot-password'),
                child: Text(l10n.forgotPassword),
              ),
            ),
            const SizedBox(height: 4),
            ShakeOnChange(
              trigger: _shake == 0 ? null : _shake,
              child: FButton(
                key: const Key('login-submit'),
                label: l10n.login,
                loading: loading && !_google,
                onPressed: loading ? null : _submit,
              ),
            ),
            const SizedBox(height: 18),
            const OrDivider(),
            const SizedBox(height: 18),
            FButton(
              label: l10n.continueWithGoogle,
              kind: FButtonKind.secondary,
              leading: const GoogleMark(),
              loading: loading && _google,
              onPressed: loading
                  ? null
                  : () {
                      _google = true;
                      context.read<AuthCubit>().loginWithGoogle();
                    },
            ),
            const SizedBox(height: 12),
            AuthSwitchLine(
              text: l10n.dontHaveAccount,
              action: l10n.register,
              onTap: () => Navigator.pushNamed(context, '/register'),
            ),
          ],
        );
      },
    );
  }
}
