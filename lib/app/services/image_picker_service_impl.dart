import 'package:image_picker/image_picker.dart';
import 'package:social_app/core/services/image_picker_service.dart';

/// An image picker service impl.
class ImagePickerServiceImpl implements ImagePickerService {
  /// Creates a [ImagePickerServiceImpl].
  ImagePickerServiceImpl(this._picker);
  final ImagePicker _picker;

  @override
  Future<XFile?> pickFromGallery() {
    return _picker.pickImage(source: ImageSource.gallery);
  }
}
