import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CameraPickerHelper {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (image != null) {
      return File(image.path);
    }

    return null;
  }
}
