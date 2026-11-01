import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:findar/core/motion/motion.dart';
import 'package:findar/core/theme/findar_tokens.dart';
import 'package:findar/core/widgets/decor/decor.dart';
import 'package:findar/core/widgets/f_icon.dart';
import 'package:findar/core/widgets/ui.dart';
import 'package:findar/features/auth/widgets/auth_scaffold.dart';
import 'package:findar/l10n/app_localizations.dart';
import 'package:findar/logic/cubits/auth_cubit.dart';
import 'package:findar/logic/cubits/profile_picture_setup_cubit.dart';

class ProfilePictureSetupScreen extends StatefulWidget {
  const ProfilePictureSetupScreen({super.key});

  @override
  State<ProfilePictureSetupScreen> createState() =>
      _ProfilePictureSetupScreenState();
}

class _ProfilePictureSetupScreenState extends State<ProfilePictureSetupScreen> {
  Future<void> _pick(ImageSource source) async {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<ProfilePictureSetupCubit>();
    if (cubit.state.isUploading) return;
    try {
      final image = await ImagePicker().pickImage(
          source: source, maxWidth: 1024, maxHeight: 1024, imageQuality: 85);
      if (image == null) return;
      if (kIsWeb) {
        cubit.setImage(imageBytes: await image.readAsBytes());
      } else {
        cubit.setImage(imageFile: File(image.path));
      }
    } catch (e) {
      if (mounted) showAppSnack(context, l10n.errorPickingImage('$e'));
    }
  }

  Future<void> _chooseSource() async {
    final l10n = AppLocalizations.of(context)!;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            MenuRow(
                icon: FIcons.image,
                title: l10n.chooseFromGallery,
                onTap: () => Navigator.pop(ctx, ImageSource.gallery)),
            MenuRow(
                icon: FIcons.camera,
                title: l10n.takePhoto,
                onTap: () => Navigator.pop(ctx, ImageSource.camera)),
          ]),
        ),
      ),
    );
    if (source != null) await _pick(source);
  }

  Future<void> _upload() async {
    final l10n = AppLocalizations.of(context)!;
    final url =
        await context.read<ProfilePictureSetupCubit>().uploadProfilePicture();
    if (url == null && mounted) showAppSnack(context, l10n.uploadFailed);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.fc;
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<ProfilePictureSetupCubit, ProfilePictureSetupState>(
      listenWhen: (a, b) => !a.uploadComplete && b.uploadComplete,
      listener: (context, state) async {
        if (state.uploadedImageUrl != null) {
          await context
              .read<AuthCubit>()
              .updateProfile(profilePic: state.uploadedImageUrl);
        }
        if (!context.mounted) return;
        Navigator.pushReplacementNamed(context, '/home');
      },
      builder: (context, state) {
        ImageProvider? img;
        if (state.imageBytes != null) img = MemoryImage(state.imageBytes!);
        if (state.imageFile != null) img = FileImage(state.imageFile!);

        return AuthScaffold(
          trailing: TextButton(
            onPressed: state.isUploading
                ? null
                : () => context
                    .read<ProfilePictureSetupCubit>()
                    .skipProfilePicture(),
            style: TextButton.styleFrom(
                textStyle:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            child: Text(l10n.skip),
          ),
          children: [
            const SizedBox(height: 8),
            Text(l10n.addProfilePhoto,
                textAlign: TextAlign.center,
                style: context.tt.headlineLarge?.copyWith(fontSize: 28)),
            const SizedBox(height: 8),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 290),
                child: Text(l10n.addProfilePhotoBody,
                    textAlign: TextAlign.center,
                    style: context.tt.bodyLarge?.copyWith(color: c.muted)),
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: SizedBox(
                width: 168,
                height: 168,
                child: Stack(clipBehavior: Clip.none, children: [
                  const Positioned(
                    left: -66,
                    top: -66,
                    child: IgnorePointer(
                      child: SizedBox.square(
                        dimension: 300,
                        child:
                            Rings(radii: [112, 140], opacities: [0.18, 0.09]),
                      ),
                    ),
                  ),
                  const Positioned(
                      left: -64,
                      top: 6,
                      child: GlassTile(
                          icon: FIcons.image,
                          size: 44,
                          rotation: -10,
                          light: true)),
                  const Positioned(
                      right: -60,
                      top: 104,
                      child: GlassTile(
                          icon: FIcons.camera,
                          size: 40,
                          rotation: 10,
                          light: true)),
                  const Positioned(
                      right: -20, top: -14, child: Sparkle(size: 14)),
                  const Positioned(
                      left: -10, bottom: -20, child: Sparkle(size: 10)),
                  Semantics(
                    button: true,
                    label: l10n.chooseFromGallery,
                    excludeSemantics: true,
                    child: Pressable(
                      button: false,
                      onTap: state.isUploading ? null : _chooseSource,
                      child: AnimatedSwitcher(
                        duration: Motion.medium,
                        child: img == null
                            ? CustomPaint(
                                key: const ValueKey('empty'),
                                painter: _DashedCircle(c.accent),
                                child: Container(
                                  width: 168,
                                  height: 168,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [c.accentT, c.bg],
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: FIcon(FIcons.user,
                                      size: 64,
                                      strokeWidth: 1.4,
                                      color: c.accent),
                                ),
                              )
                            : Container(
                                key: const ValueKey('img'),
                                width: 168,
                                height: 168,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: img, fit: BoxFit.cover),
                                ),
                              ),
                      ),
                    ),
                  ),
                  if (state.isUploading)
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                            color: Color(0x66111317), shape: BoxShape.circle),
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(
                            strokeWidth: 2.6, color: Colors.white),
                      ),
                    ),
                  PositionedDirectional(
                    end: 6,
                    bottom: 6,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: FindarColors.brandGradient,
                        border: Border.all(color: c.bg, width: 3),
                      ),
                      alignment: Alignment.center,
                      child: const FIcon(FIcons.camera,
                          size: 20, color: Colors.white),
                    ),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 44),
            if (!state.hasImage) ...[
              FButton(
                label: l10n.chooseFromGallery,
                icon: FIcons.image,
                onPressed: () => _pick(ImageSource.gallery),
              ),
              const SizedBox(height: 14),
              FButton(
                label: l10n.takePhoto,
                icon: FIcons.camera,
                kind: FButtonKind.secondary,
                onPressed: () => _pick(ImageSource.camera),
              ),
            ] else ...[
              FButton(
                label: l10n.continueLabel,
                loading: state.isUploading,
                onPressed: _upload,
              ),
              const SizedBox(height: 14),
              FButton(
                label: l10n.changePhoto,
                icon: FIcons.camera,
                kind: FButtonKind.secondary,
                onPressed: state.isUploading ? null : _chooseSource,
              ),
            ],
          ],
        );
      },
    );
  }
}

class _DashedCircle extends CustomPainter {
  _DashedCircle(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2 - 1;
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final path = Path()
      ..addOval(Rect.fromCircle(center: size.center(Offset.zero), radius: r));
    for (final m in path.computeMetrics()) {
      var d = 0.0;
      while (d < m.length) {
        canvas.drawPath(m.extractPath(d, d + 6), p);
        d += 11;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedCircle old) => old.color != color;
}
