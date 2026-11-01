import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:findar/core/services/cloudinary_service.dart';
import 'package:findar/core/widgets/f_icon.dart';
import 'package:findar/core/widgets/ui.dart';
import 'package:findar/l10n/app_localizations.dart';
import 'package:findar/logic/cubits/auth_cubit.dart';
import 'package:findar/logic/cubits/profile_cubit.dart';

/// Asks gallery/camera, uploads the photo and saves it on the profile.
/// [uploading] is set while the upload runs (for a spinner on the avatar).
Future<void> changeProfilePhoto(
  BuildContext context, {
  ValueNotifier<bool>? uploading,
}) async {
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
            onTap: () => Navigator.pop(ctx, ImageSource.gallery),
          ),
          MenuRow(
            icon: FIcons.camera,
            title: l10n.takePhoto,
            onTap: () => Navigator.pop(ctx, ImageSource.camera),
          ),
        ]),
      ),
    ),
  );
  if (source == null || !context.mounted) return;

  final image = await ImagePicker().pickImage(
      source: source, maxWidth: 1024, maxHeight: 1024, imageQuality: 85);
  if (image == null || !context.mounted) return;

  final auth = context.read<AuthCubit>();
  final profile = context.read<ProfileCubit>();
  uploading?.value = true;
  try {
    final result = await CloudinaryService().uploadProfilePicture(image.path);
    if (result.success && result.url != null) {
      await auth.updateProfile(profilePic: result.url);
      await profile.fetchProfile();
      if (context.mounted) showAppSnack(context, l10n.profilePictureUpdated);
    } else if (context.mounted) {
      showAppSnack(context, l10n.uploadFailed);
    }
  } catch (_) {
    if (context.mounted) showAppSnack(context, l10n.uploadFailed);
  } finally {
    uploading?.value = false;
  }
}
