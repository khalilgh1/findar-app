import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

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
  Future<String?> uploadProfilePicture() async {
    emit(state.copyWith(isUploading: true));

    // TODO: Implement actual API upload here
    // For now, simulate upload delay and return a mock URL or base64 string
    await Future.delayed(const Duration(seconds: 2));

    // If we have imageBytes (from web), convert to base64 or URL
    // If we have imageFile (from mobile), upload to server and get URL
    String? profilePicUrl;
    if (state.imageBytes != null) {
      // For web: convert bytes to base64 and create data URL
      final base64String = base64Encode(state.imageBytes!);
      profilePicUrl = 'data:image/png;base64,$base64String';
    } else if (state.imageFile != null) {
      // For mobile: upload file to server and get URL back
      profilePicUrl = state.imageFile!.path; // Temporary - use actual uploaded URL
    }

    emit(state.copyWith(
      isUploading: false, 
      uploadComplete: true,
      uploadedImageUrl: profilePicUrl,
    ));
    
    return profilePicUrl;
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
