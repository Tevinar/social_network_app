import 'dart:io';

import 'package:flutter/foundation.dart';

/// Downloads remote resources as bytes.
// ignore: one_member_abstracts
abstract interface class HttpDownloader {
  /// Downloads bytes from the given [uri].
  Future<Uint8List> downloadBytes(Uri uri);
}

/// `dart:io` implementation of [HttpDownloader].
class DartHttpDownloader implements HttpDownloader {
  @override
  Future<Uint8List> downloadBytes(Uri uri) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(uri);
      final response = await request.close();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'Failed to download resource: ${response.statusCode}',
          uri: uri,
        );
      }

      return consolidateHttpClientResponseBytes(response);
    } finally {
      client.close(force: true);
    }
  }
}
