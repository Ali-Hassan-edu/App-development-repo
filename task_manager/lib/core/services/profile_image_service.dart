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

      // Get the app's documents directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String imagesDir = path.join(appDir.path, 'profile_images');

      // Create directory if it doesn't exist
      final Directory dir = Directory(imagesDir);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // Save image with user ID as filename
      final String fileName = '$userId.jpg';
      final String filePath = path.join(imagesDir, fileName);

      // Copy the selected image to the app directory
      final File savedImage = await File(image.path).copy(filePath);

      return savedImage.path;
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

      // Get the app's documents directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String imagesDir = path.join(appDir.path, 'profile_images');

      // Create directory if it doesn't exist
      final Directory dir = Directory(imagesDir);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      // Save image with user ID as filename
      final String fileName = '$userId.jpg';
      final String filePath = path.join(imagesDir, fileName);

      // Copy the captured image to the app directory
      final File savedImage = await File(image.path).copy(filePath);

      return savedImage.path;
    } catch (e) {
      debugPrint('Error capturing image: $e');
      return null;
    }
  }

  Future<File?> getProfileImage(String userId) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String imagesDir = path.join(appDir.path, 'profile_images');
      final String filePath = path.join(imagesDir, '$userId.jpg');

      final File imageFile = File(filePath);
      if (await imageFile.exists()) {
        return imageFile;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting profile image: $e');
      return null;
    }
  }

  Future<void> deleteProfileImage(String userId) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String imagesDir = path.join(appDir.path, 'profile_images');
      final String filePath = path.join(imagesDir, '$userId.jpg');

      final File imageFile = File(filePath);
      if (await imageFile.exists()) {
        await imageFile.delete();
      }
    } catch (e) {
      debugPrint('Error deleting profile image: $e');
    }
  }
}
