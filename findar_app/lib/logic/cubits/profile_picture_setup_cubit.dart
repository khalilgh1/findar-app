import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:findar/core/services/cloudinary_service.dart';

class ProfilePictureSetupCubit extends Cubit<ProfilePictureSetupState> {
  final CloudinaryService _cloudinaryService = CloudinaryService();

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

  /// Upload profile picture to Cloudinary and return the URL
  Future<String?> uploadProfilePicture() async {
    if (state.imageFile == null) {
      return null;
    }

    emit(state.copyWith(isUploading: true));

    try {
      // Upload to Cloudinary
      final result = await _cloudinaryService.uploadProfilePicture(
        state.imageFile!.path,
      );

      if (result.success && result.url != null) {
        emit(state.copyWith(
          isUploading: false,
          uploadComplete: true,
          uploadedImageUrl: result.url,
        ));
        return result.url;
      } else {
        emit(state.copyWith(
          isUploading: false,
          uploadComplete: false,
        ));
        return null;
      }
    } catch (e) {
      print('Error uploading profile picture: $e');
      emit(state.copyWith(
        isUploading: false,
        uploadComplete: false,
      ));
      return null;
    }
  }

  /// Skip profile picture setup
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
  final String? uploadedImageUrl;

  ProfilePictureSetupState({
    this.imageFile,
    this.imageBytes,
    this.hasImage = false,
    this.isUploading = false,
    this.uploadComplete = false,
    this.uploadedImageUrl,
  });

  ProfilePictureSetupState copyWith({
    File? imageFile,
    Uint8List? imageBytes,
    bool? hasImage,
    bool? isUploading,
    bool? uploadComplete,
    String? uploadedImageUrl,
  }) {
    return ProfilePictureSetupState(
      imageFile: imageFile ?? this.imageFile,
      imageBytes: imageBytes ?? this.imageBytes,
      hasImage: hasImage ?? this.hasImage,
      isUploading: isUploading ?? this.isUploading,
      uploadComplete: uploadComplete ?? this.uploadComplete,
      uploadedImageUrl: uploadedImageUrl ?? this.uploadedImageUrl,
    );
  }
}
