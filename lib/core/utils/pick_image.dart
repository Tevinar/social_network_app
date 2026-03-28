import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:social_app/core/services/image_picker_service.dart';

Future<File?> pickImage() async {
  final xFile = await GetIt.I<ImagePickerService>().pickFromGallery();
  return xFile != null ? File(xFile.path) : null;
}
