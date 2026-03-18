import 'dart:io';

import 'package:social_network_app/core/services/image_picker_service.dart';
import 'package:get_it/get_it.dart';

Future<File?> pickImage() async {
  final xFile = await GetIt.I<ImagePickerService>().pickFromGallery();
  return xFile != null ? File(xFile.path) : null;
}
