import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'dart:typed_data';

class ProfilePictureSetupCubit extends Cubit<ProfilePictureSetupState> {
  ProfilePictureSetupCubit() : super(ProfilePictureSetupState());

  void setImage({File? imageFile, Uint8List? imageBytes}) {
    emit(
      state.copyWith(
        imageFile: imageFile,
        imageBytes: imageBytes,
        hasImage: true,
      ),
    );
  }

  void clearImage() {
    emit(state.copyWith(imageFile: null, imageBytes: null, hasImage: false));
  }

  void setUploading(bool isUploading) {
    emit(state.copyWith(isUploading: isUploading));
  }

  // This would be called when user clicks "Upload" button
  Future<void> uploadProfilePicture() async {
    emit(state.copyWith(isUploading: true));

    // TODO: Implement actual API upload here
    // For now, simulate upload delay
    await Future.delayed(const Duration(seconds: 2));

    emit(state.copyWith(isUploading: false, uploadComplete: true));
  }

  // This would be called when user clicks "Ignore" button
  void skipProfilePicture() {
    emit(
      state.copyWith(
        imageFile: null,
        imageBytes: null,
        hasImage: false,
        uploadComplete: true,
      ),
    );
  }
}

class ProfilePictureSetupState {
  final File? imageFile;
  final Uint8List? imageBytes;
  final bool hasImage;
  final bool isUploading;
  final bool uploadComplete;

  ProfilePictureSetupState({
    this.imageFile,
    this.imageBytes,
    this.hasImage = false,
    this.isUploading = false,
    this.uploadComplete = false,
  });

  ProfilePictureSetupState copyWith({
    File? imageFile,
    Uint8List? imageBytes,
    bool? hasImage,
    bool? isUploading,
    bool? uploadComplete,
  }) {
    return ProfilePictureSetupState(
      imageFile: imageFile ?? this.imageFile,
      imageBytes: imageBytes ?? this.imageBytes,
      hasImage: hasImage ?? this.hasImage,
      isUploading: isUploading ?? this.isUploading,
      uploadComplete: uploadComplete ?? this.uploadComplete,
    );
  }
}
