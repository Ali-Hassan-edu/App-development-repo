import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/services/profile_image_service.dart';
import 'full_image_viewer.dart';

class ProfileAvatar extends StatefulWidget {
  final String userId;
  final String userName;
  final double radius;
  final bool canZoom;

  const ProfileAvatar({
    super.key,
    required this.userId,
    required this.userName,
    this.radius = 24,
    this.canZoom = true,
  });

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  final _profileService = ProfileImageService();
  File? _imageFile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(ProfileAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final file = await _profileService.getProfileImage(widget.userId);
    if (mounted) {
      setState(() {
        _imageFile = file;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final initials = widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : 'U';
    
    Widget avatar = CircleAvatar(
      radius: widget.radius,
      backgroundColor: const Color(0xFF0D47A1).withOpacity(0.1),
      child: _isLoading 
          ? const CircularProgressIndicator(strokeWidth: 2)
          : _imageFile != null
              ? ClipOval(
                  child: Hero(
                    tag: 'profile_image_${_imageFile!.path}',
                    child: Image.file(_imageFile!, width: widget.radius * 2, height: widget.radius * 2, fit: BoxFit.cover),
                  ),
                )
              : Text(
                  initials,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0D47A1),
                    fontSize: widget.radius * 0.8,
                  ),
                ),
    );

    if (widget.canZoom && _imageFile != null) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FullImageViewer(
                imageFile: _imageFile,
                title: widget.userName,
              ),
            ),
          );
        },
        child: avatar,
      );
    }

    return avatar;
  }
}
