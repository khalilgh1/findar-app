import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Result class for Cloudinary upload operations
class CloudinaryUploadResult {
  final bool success;
  final String? url;
  final String? publicId;
  final String? error;

  CloudinaryUploadResult({
    required this.success,
    this.url,
    this.publicId,
    this.error,
  });

  @override
  String toString() {
    return 'CloudinaryUploadResult(success: $success, url: $url, error: $error)';
  }
}

/// Result class for multiple image uploads
class CloudinaryBatchUploadResult {
  final bool success;
  final String? mainImageUrl;
  final List<String> additionalImageUrls;
  final String? error;

  CloudinaryBatchUploadResult({
    required this.success,
    this.mainImageUrl,
    this.additionalImageUrls = const [],
    this.error,
  });

  /// Returns all URLs (main + additional)
  List<String> get allUrls {
    final urls = <String>[];
    if (mainImageUrl != null) urls.add(mainImageUrl!);
    urls.addAll(additionalImageUrls);
    return urls;
  }
}

/// Service for handling image uploads to Cloudinary
class CloudinaryService {
  // Cloudinary configuration
  static const String _cloudName = 'da5xjc4dx';
  static const String _uploadPreset = 'findar';
  static const String _apiKey = '199445338344885';

  // Upload endpoint
  String get _uploadUrl =>
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

  /// Uploads a single image to Cloudinary
  /// 
  /// [imagePath] - The local file path of the image to upload
  /// [folder] - Optional folder name in Cloudinary (e.g., 'listings', 'profiles')
  /// 
  /// Returns [CloudinaryUploadResult] with the uploaded image URL or error
  Future<CloudinaryUploadResult> uploadImage(
    String imagePath, {
    String? folder,
  }) async {
    try {
      final file = File(imagePath);
      
      if (!await file.exists()) {
        return CloudinaryUploadResult(
          success: false,
          error: 'File not found: $imagePath',
        );
      }

      print('📤 Uploading image to Cloudinary: $imagePath');

      // Create multipart request
      final request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath('file', imagePath),
      );

      // Add upload preset (required for unsigned uploads)
      request.fields['upload_preset'] = _uploadPreset;
      request.fields['api_key'] = _apiKey;

      // Add optional folder
      if (folder != null) {
        request.fields['folder'] = folder;
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final url = data['secure_url'] as String?;
        final publicId = data['public_id'] as String?;

        print('✅ Image uploaded successfully: $url');

        return CloudinaryUploadResult(
          success: true,
          url: url,
          publicId: publicId,
        );
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['error']?['message'] ?? 'Upload failed';
        
        print('❌ Cloudinary upload failed: $errorMessage');
        
        return CloudinaryUploadResult(
          success: false,
          error: errorMessage,
        );
      }
    } catch (e) {
      print('❌ Cloudinary upload error: $e');
      return CloudinaryUploadResult(
        success: false,
        error: 'Upload failed: $e',
      );
    }
  }

  /// Uploads multiple images to Cloudinary
  /// 
  /// [imagePaths] - List of local file paths to upload
  /// [folder] - Optional folder name in Cloudinary
  /// 
  /// Returns list of [CloudinaryUploadResult] for each image
  Future<List<CloudinaryUploadResult>> uploadMultipleImages(
    List<String> imagePaths, {
    String? folder,
  }) async {
    final results = <CloudinaryUploadResult>[];

    for (final path in imagePaths) {
      final result = await uploadImage(path, folder: folder);
      results.add(result);
    }

    return results;
  }

  /// Uploads images for a listing post
  /// 
  /// [mainImagePath] - The main/cover image path
  /// [additionalImagePaths] - Optional list of additional image paths
  /// 
  /// Returns [CloudinaryBatchUploadResult] with main_pic URL and pics URLs
  /// ready to be sent to the backend
  Future<CloudinaryBatchUploadResult> uploadListingImages({
    required String mainImagePath,
    List<String>? additionalImagePaths,
  }) async {
    try {
      print('📸 Starting listing images upload...');

      // Upload main image
      final mainResult = await uploadImage(mainImagePath, folder: 'listings');
      
      if (!mainResult.success) {
        return CloudinaryBatchUploadResult(
          success: false,
          error: 'Failed to upload main image: ${mainResult.error}',
        );
      }

      // Upload additional images if provided
      final additionalUrls = <String>[];
      
      if (additionalImagePaths != null && additionalImagePaths.isNotEmpty) {
        print('📸 Uploading ${additionalImagePaths.length} additional images...');
        
        for (final path in additionalImagePaths) {
          final result = await uploadImage(path, folder: 'listings');
          
          if (result.success && result.url != null) {
            additionalUrls.add(result.url!);
          } else {
            print('⚠️ Failed to upload additional image: $path');
            // Continue with other images even if one fails
          }
        }
      }

      print('✅ All images uploaded successfully');
      print('   Main: ${mainResult.url}');
      print('   Additional: $additionalUrls');

      return CloudinaryBatchUploadResult(
        success: true,
        mainImageUrl: mainResult.url,
        additionalImageUrls: additionalUrls,
      );
    } catch (e) {
      print('❌ Batch upload failed: $e');
      return CloudinaryBatchUploadResult(
        success: false,
        error: 'Batch upload failed: $e',
      );
    }
  }

  /// Uploads a profile picture
  /// 
  /// [imagePath] - The local file path of the profile image
  /// 
  /// Returns [CloudinaryUploadResult] with the uploaded image URL
  Future<CloudinaryUploadResult> uploadProfilePicture(String imagePath) async {
    return uploadImage(imagePath, folder: 'profiles');
  }

  /// Extracts the public ID from a Cloudinary URL
  /// Useful for deleting or transforming images later
  String? extractPublicId(String cloudinaryUrl) {
    try {
      final uri = Uri.parse(cloudinaryUrl);
      final pathSegments = uri.pathSegments;
      
      // Find the 'upload' segment and get everything after version
      final uploadIndex = pathSegments.indexOf('upload');
      if (uploadIndex == -1 || uploadIndex + 2 >= pathSegments.length) {
        return null;
      }

      // Skip 'upload' and version (v1234567890)
      final relevantSegments = pathSegments.sublist(uploadIndex + 2);
      final publicIdWithExtension = relevantSegments.join('/');
      
      // Remove file extension
      final lastDotIndex = publicIdWithExtension.lastIndexOf('.');
      if (lastDotIndex != -1) {
        return publicIdWithExtension.substring(0, lastDotIndex);
      }
      
      return publicIdWithExtension;
    } catch (e) {
      print('Error extracting public ID: $e');
      return null;
    }
  }
}
