import 'package:image_picker/image_picker.dart';

/// An image picker service.
// ignore: one_member_abstracts
abstract class ImagePickerService {
  /// The pick from gallery.
  Future<XFile?> pickFromGallery();
}
