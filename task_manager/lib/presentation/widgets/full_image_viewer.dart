import 'dart:io';
import 'package:flutter/material.dart';

class FullImageViewer extends StatelessWidget {
  final File? imageFile;
  final String? imageUrl;
  final String title;
  final List<Widget>? actions;

  const FullImageViewer({
    super.key,
    this.imageFile,
    this.imageUrl,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: actions,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Hero(
            tag: 'profile_image_${imageFile?.path ?? imageUrl}',
            child: imageFile != null
                ? Image.file(imageFile!)
                : imageUrl != null
                    ? Image.network(imageUrl!)
                    : const Icon(Icons.person, size: 100, color: Colors.white24),
          ),
        ),
      ),
    );
  }
}
