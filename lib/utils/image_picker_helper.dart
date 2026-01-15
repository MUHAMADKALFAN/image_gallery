import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  static Future<bool> _requestGalleryPermission() async {
    if (Platform.isAndroid) {

      if (await Permission.photos.isGranted) return true;

      if (await Permission.storage.isGranted) return true;

      final photos = await Permission.photos.request();
      final storage = await Permission.storage.request();

      return photos.isGranted || storage.isGranted;
    } else {
      final status = await Permission.photos.request();
      return status.isGranted;
    }
  }

  static Future<File?> pickFromGallery(BuildContext context) async {
    final hasPermission = await _requestGalleryPermission();

    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gallery permission denied')),
      );
      return null;
    }

    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (image != null) {
      return File(image.path);
    }
    return null;
  }
}
