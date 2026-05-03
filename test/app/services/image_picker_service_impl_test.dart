import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:social_app/app/media/image_picker_service_impl.dart';

class MockImagePicker extends Mock implements ImagePicker {}

void main() {
  late MockImagePicker imagePicker;
  late ImagePickerServiceImpl imagePickerService;
  group('pickFromGallery', () {
    setUp(() {
      imagePicker = MockImagePicker();
      imagePickerService = ImagePickerServiceImpl(imagePicker);
    });
    test(
      'given the image picker returns an image when pickFromGallery is called '
      'then returns the picked image',
      () async {
        // Arrange
        final expectedResult = XFile('path/to/image.jpg');
        when(
          () => imagePicker.pickImage(source: ImageSource.gallery),
        ).thenAnswer(
          (_) async => expectedResult,
        );

        // Act
        final result = await imagePickerService.pickFromGallery();

        // Assert
        expect(result, expectedResult);
        verify(
          () => imagePicker.pickImage(source: ImageSource.gallery),
        ).called(1);
      },
    );

    test(
      'Given the image picker returns null when pickFromGallery is called '
      'then returns null',
      () async {
        // Arrange
        when(
          () => imagePicker.pickImage(source: ImageSource.gallery),
        ).thenAnswer(
          (_) async => null,
        );

        // Act
        final result = await imagePickerService.pickFromGallery();

        // Assert
        expect(result, null);
        verify(
          () => imagePicker.pickImage(source: ImageSource.gallery),
        ).called(1);
      },
    );
  });
}
