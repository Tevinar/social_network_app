/// Typed helpers for reading validated values from decoded JSON maps.
class JsonReader {
  const JsonReader._();

  /// Reads a required string field from [json].
  ///
  /// Throws a [FormatException] when [field] is missing or is not a string.
  static String readString(Map<String, dynamic> json, String field) {
    final value = json[field];
    if (value is! String) {
      throw FormatException('Invalid field "$field": expected string');
    }
    return value;
  }

  /// Reads an optional string field from [json].
  ///
  /// Returns `null` when the field is absent or explicitly null.
  /// Throws a [FormatException] when the field exists but is not a string.
  static String? readNullableString(
    Map<String, dynamic> json,
    String field,
  ) {
    final value = json[field];
    if (value == null) {
      return null;
    }
    if (value is! String) {
      throw FormatException(
        'Invalid field "$field": expected string or null',
      );
    }
    return value;
  }

  /// Reads a required object field from [json].
  ///
  /// Throws a [FormatException] when [field] is missing or is not a JSON
  /// object.
  static Map<String, dynamic> readObject(
    Map<String, dynamic> json,
    String field,
  ) {
    final value = json[field];
    if (value is! Map<String, dynamic>) {
      throw FormatException('Invalid field "$field": expected object');
    }
    return value;
  }

  /// Converts [value] to a JSON object map.
  ///
  /// Throws a [FormatException] when [value] is not a JSON object.
  static Map<String, dynamic> asObject(dynamic value, String field) {
    if (value is! Map<String, dynamic>) {
      throw FormatException('Invalid field "$field": expected object');
    }
    return value;
  }

  /// Reads a required list field from [json].
  ///
  /// Throws a [FormatException] when [field] is missing or is not a JSON
  /// array.
  static List<dynamic> readList(Map<String, dynamic> json, String field) {
    final value = json[field];
    if (value is! List<dynamic>) {
      throw FormatException('Invalid field "$field": expected list');
    }
    return value;
  }

  /// Reads a required list of strings field from [json].
  ///
  /// Throws a [FormatException] when [field] is missing, is not a JSON array,
  /// or contains at least one non-string item.
  static List<String> readStringList(Map<String, dynamic> json, String field) {
    final value = readList(json, field);

    for (final item in value) {
      if (item is! String) {
        throw FormatException(
          'Invalid field "$field": expected list of strings',
        );
      }
    }

    return value.cast<String>();
  }

  /// Reads a required ISO-8601 date-time field from [json].
  ///
  /// Throws a [FormatException] when [field] is missing, is not a string, or
  /// cannot be parsed by [DateTime.parse].
  static DateTime readDateTime(Map<String, dynamic> json, String field) {
    final value = json[field];
    if (value is! String) {
      throw FormatException('Invalid field "$field": expected ISO date string');
    }

    try {
      return DateTime.parse(value);
    } on FormatException {
      throw FormatException(
        'Invalid field "$field": expected valid ISO date string',
      );
    }
  }
}
