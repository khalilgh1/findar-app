import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:findar/core/motion/motion.dart';
import 'package:findar/core/theme/findar_tokens.dart';
import 'package:findar/core/widgets/f_icon.dart';
import 'package:findar/core/widgets/ui.dart';
import 'package:findar/features/auth/widgets/auth_scaffold.dart';
import 'package:findar/l10n/app_localizations.dart';
import 'package:findar/logic/cubits/auth_cubit.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  String _accountType = 'individual';
  bool _hidden = true;
  int _shake = 0;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      setState(() => _shake++);
      return;
    }
    context.read<AuthCubit>().register(
          name: _name.text.trim(),
          email: _email.text.trim(),
          phone: _phone.text.trim(),
          password: _password.text,
          accountType: _accountType,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    Widget account(String value, String title, String sub) => Expanded(
          child: RadioCard(
            selected: _accountType == value,
            showRadio: false,
            radius: 16,
            padding: const EdgeInsets.all(14),
            onTap: () => setState(() => _accountType = value),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: context.tt.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(sub,
                    style: context.tt.bodySmall
                        ?.copyWith(fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        );

    return BlocConsumer<AuthCubit, Map<String, dynamic>>(
      listener: (context, state) {
        if (state['state'] == 'done') {
          Navigator.pushNamedAndRemoveUntil(
              context, '/profile-picture-setup', (r) => false);
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
          title: l10n.createAccount,
          softTopHeight: 200,
          formKey: _formKey,
          bottom: ShakeOnChange(
            trigger: _shake == 0 ? null : _shake,
            child: FButton(
              label: l10n.completeRegistration,
              loading: loading,
              onPressed: loading ? null : _submit,
            ),
          ),
          children: [
            Text(l10n.accountType, style: context.tt.labelMedium),
            const SizedBox(height: 8),
            IntrinsicHeight(
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    account('individual', l10n.accountIndividual,
                        l10n.individualSub),
                    const SizedBox(width: 10),
                    account('agency', l10n.accountAgency, l10n.agencySub),
                  ]),
            ),
            const SizedBox(height: 16),
            AppField(
              label: l10n.fullName,
              controller: _name,
              icon: FIcons.user,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              validator: (v) {
                final t = v?.trim() ?? '';
                if (t.isEmpty) return l10n.nameRequired;
                if (t.length < 4) return l10n.nameTooShort;
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppField(
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
            const SizedBox(height: 16),
            AppField(
              label: l10n.phoneNumber,
              controller: _phone,
              icon: FIcons.phone,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.telephoneNumber],
              validator: (v) {
                final t = v?.trim() ?? '';
                if (t.isEmpty) return l10n.phoneRequired;
                if (t.replaceAll(RegExp(r'\D'), '').length < 10) {
                  return l10n.phoneTooShort;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            AppField(
              label: l10n.password,
              controller: _password,
              icon: FIcons.lock,
              obscure: _hidden,
              autofillHints: const [AutofillHints.newPassword],
              onSubmitted: (_) => _submit(),
              trailing: EyeToggle(
                  hidden: _hidden,
                  onTap: () => setState(() => _hidden = !_hidden)),
              validator: (v) {
                final t = v ?? '';
                if (t.isEmpty) return l10n.passwordRequired;
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
            const SizedBox(height: 16),
            AuthSwitchLine(
              text: l10n.alreadyHaveAccount,
              action: l10n.login,
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                  context, '/login', (r) => false),
            ),
          ],
        );
      },
    );
  }
}
