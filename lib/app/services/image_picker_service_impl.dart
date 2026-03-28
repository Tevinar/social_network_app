import 'package:image_picker/image_picker.dart';
import 'package:social_app/core/services/image_picker_service.dart';

class ImagePickerServiceImpl implements ImagePickerService {
  final ImagePicker _picker;

  ImagePickerServiceImpl(this._picker);

  @override
  Future<XFile?> pickFromGallery() {
    return _picker.pickImage(source: ImageSource.gallery);
  }
}
