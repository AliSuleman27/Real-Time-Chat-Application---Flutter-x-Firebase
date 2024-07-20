import 'dart:io';

import 'package:image_picker/image_picker.dart';

class MediaService {
  final ImagePicker _picker = ImagePicker();
  MediaService();

  Future<File?> getFileFromGallery() async {
    final XFile? _file = await _picker.pickImage(source: ImageSource.gallery);

    if (_file != null) {
      return File(_file.path);
    } else {
      return null;
    }
  }
}
