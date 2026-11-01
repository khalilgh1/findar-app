import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:findar/core/theme/findar_tokens.dart';
import 'package:findar/core/widgets/f_icon.dart';
import 'package:findar/core/widgets/ui.dart';
import 'package:findar/features/profile/profile_photo.dart';
import 'package:findar/l10n/app_localizations.dart';
import 'package:findar/logic/cubits/profile_cubit.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _uploading = ValueNotifier(false);
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final d = context.read<ProfileCubit>().state['data'];
    if (d is Map) {
      _name.text = (d['username'] ?? '') as String;
      _email.text = (d['email'] ?? '') as String;
      _phone.text = (d['phone'] ?? '') as String;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _uploading.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<ProfileCubit>();
    setState(() => _saving = true);
    await cubit.updateProfile(
      name: _name.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    final st = cubit.state;
    if (st['state'] == 'done') {
      showAppSnack(context, (st['message'] as String?) ?? l10n.success);
      Navigator.pop(context);
    } else {
      showAppSnack(context, (st['message'] as String?) ?? l10n.errorOccurred);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.fc;
    final d = context.select<ProfileCubit, Map?>(
        (p) => p.state['data'] is Map ? p.state['data'] as Map : null);

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          FTopBar(title: l10n.editProfile),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  Center(
                    child: ValueListenableBuilder<bool>(
                      valueListenable: _uploading,
                      builder: (context, busy, child) => Stack(children: [
                        child!,
                        if (busy)
                          Positioned.fill(
                            child: Container(
                              decoration: const BoxDecoration(
                                  color: Color(0x66111317),
                                  shape: BoxShape.circle),
                              alignment: Alignment.center,
                              child: const CircularProgressIndicator(
                                  strokeWidth: 2.6, color: Colors.white),
                            ),
                          ),
                      ]),
                      child: InitialsAvatar(
                        name: _name.text.isEmpty
                            ? (d?['username'] as String?)
                            : _name.text,
                        imageUrl: d?['profilePic'] as String?,
                        size: 96,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: FButton(
                      label: l10n.changePhoto,
                      icon: FIcons.camera,
                      kind: FButtonKind.secondary,
                      height: 40,
                      expand: false,
                      onPressed: () =>
                          changeProfilePhoto(context, uploading: _uploading),
                    ),
                  ),
                  const SizedBox(height: 20),
                  AppField(
                    label: l10n.fullName,
                    controller: _name,
                    icon: FIcons.user,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.name],
                    validator: (v) => (v == null || v.trim().length < 2)
                        ? l10n.nameRequired
                        : null,
                  ),
                  const SizedBox(height: 20),
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
                      if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$')
                          .hasMatch(t)) {
                        return l10n.invalidEmail;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  AppField(
                    label: l10n.phoneNumber,
                    controller: _phone,
                    icon: FIcons.phone,
                    keyboardType: TextInputType.phone,
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
                ],
              ),
            ),
          ),
          StickyBar(
            child: FButton(
                label: l10n.saveChanges, loading: _saving, onPressed: _save),
          ),
        ]),
      ),
    );
  }
}
