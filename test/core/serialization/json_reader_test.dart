import 'package:flutter_test/flutter_test.dart';
import 'package:social_app/core/serialization/json_reader.dart';

void main() {
  group('JsonReader', () {
    test('readString returns the string value for a required field', () {
      expect(
        JsonReader.readString({'name': 'Alice'}, 'name'),
        'Alice',
      );
    });

    test('readNullableString returns null for a null field', () {
      expect(
        JsonReader.readNullableString({'nickname': null}, 'nickname'),
        isNull,
      );
    });

    test('readObject returns the nested map for an object field', () {
      expect(
        JsonReader.readObject({
          'user': {'id': '1'},
        }, 'user'),
        {'id': '1'},
      );
    });

    test('asObject throws when the provided value is not a json object', () {
      expect(
        () => JsonReader.asObject('not-an-object', 'user'),
        throwsA(isA<FormatException>()),
      );
    });

    test('readStringList returns a list of strings', () {
      expect(
        JsonReader.readStringList({
          'topics': ['dart', 'flutter'],
        }, 'topics'),
        ['dart', 'flutter'],
      );
    });

    test('readStringList throws when one item is not a string', () {
      expect(
        () => JsonReader.readStringList({
          'topics': ['dart', 1],
        }, 'topics'),
        throwsA(isA<FormatException>()),
      );
    });

    test('readDateTime parses an ISO date string', () {
      expect(
        JsonReader.readDateTime({
          'createdAt': '2026-01-01T12:34:56.000Z',
        }, 'createdAt'),
        DateTime.parse('2026-01-01T12:34:56.000Z'),
      );
    });

    test('readDateTime throws when the date string is invalid', () {
      expect(
        () => JsonReader.readDateTime({
          'createdAt': 'not-a-date',
        }, 'createdAt'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
