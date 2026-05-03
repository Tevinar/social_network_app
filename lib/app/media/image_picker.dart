import 'dart:io';

import 'package:image_picker/image_picker.dart';

final _imagePicker = ImagePicker();

/// Opens the system gallery and returns the selected image as a [File].
///
/// Returns `null` when the user cancels the picker.
Future<File?> pickImageFromGallery() async {
  final pickedFile = await _imagePicker.pickImage(
    source: ImageSource.gallery,
  );

  if (pickedFile == null) {
    return null;
  }

  return File(pickedFile.path);
}
