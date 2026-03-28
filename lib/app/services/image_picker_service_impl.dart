import 'package:image_picker/image_picker.dart';
import 'package:social_app/core/services/image_picker_service.dart';

class ImagePickerServiceImpl implements ImagePickerService {
  ImagePickerServiceImpl(this._picker);
  final ImagePicker _picker;

  @override
  Future<XFile?> pickFromGallery() {
    return _picker.pickImage(source: ImageSource.gallery);
  }
}
