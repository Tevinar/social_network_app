import 'dart:io';

import 'package:bloc_app/core/services/image_picker_service.dart';
import 'package:bloc_app/core/utils/pick_image.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';

class MockImagePickerService extends Mock implements ImagePickerService {}

void main() {
  late MockImagePickerService picker;

  setUp(() {
    picker = MockImagePickerService();
    GetIt.I.registerSingleton<ImagePickerService>(picker);
  });

  tearDown(() {
    GetIt.I.reset();
  });

  test('returns File when picker returns XFile', () async {
    // Arrange
    final xFile = XFile('/fake/path/image.png');
    when(() => picker.pickFromGallery()).thenAnswer((_) async => xFile);

    // Act
    final result = await pickImage();

    // Assert
    expect(result, isA<File>());
    expect(result!.path, '/fake/path/image.png');
  });

  test('returns null when picker returns null', () async {
    // Arrange
    when(() => picker.pickFromGallery()).thenAnswer((_) async => null);

    // Act
    final result = await pickImage();

    // Assert
    expect(result, isNull);
  });
}
