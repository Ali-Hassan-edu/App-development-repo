import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ProfileImageService {
  static final ProfileImageService _instance = ProfileImageService._internal();
  factory ProfileImageService() => _instance;
  ProfileImageService._internal();

  final ImagePicker _picker = ImagePicker();

  Future<String?> pickAndSaveImage(String userId) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image == null) return null;
      return await _saveImage(image.path, userId);
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  Future<String?> captureAndSaveImage(String userId) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (image == null) return null;
      return await _saveImage(image.path, userId);
    } catch (e) {
      debugPrint('Error capturing image: $e');
      return null;
    }
  }

  Future<String?> _saveImage(String sourcePath, String userId) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String imagesDir = path.join(appDir.path, 'profile_images');
    final Directory dir = Directory(imagesDir);
    if (!await dir.exists()) await dir.create(recursive: true);
    final String filePath = path.join(imagesDir, '$userId.jpg');
    final File savedImage = await File(sourcePath).copy(filePath);
    return savedImage.path;
  }

  Future<File?> getProfileImage(String userId) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String filePath = path.join(appDir.path, 'profile_images', '$userId.jpg');
      final File imageFile = File(filePath);
      if (await imageFile.exists()) return imageFile;
      return null;
    } catch (e) {
      debugPrint('Error getting profile image: $e');
      return null;
    }
  }

  Future<void> deleteProfileImage(String userId) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String filePath = path.join(appDir.path, 'profile_images', '$userId.jpg');
      final File imageFile = File(filePath);
      if (await imageFile.exists()) await imageFile.delete();
    } catch (e) {
      debugPrint('Error deleting profile image: $e');
    }
  }
}
