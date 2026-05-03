import 'dart:io';

import 'package:image_picker/image_picker.dart';

final _imagePicker = ImagePicker();

Future<File?> pickImageFromGallery() async {
  final pickedFile = await _imagePicker.pickImage(
    source: ImageSource.gallery,
  );

  if (pickedFile == null) {
    return null;
  }

  return File(pickedFile.path);
}
