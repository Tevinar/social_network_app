import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// A disk cache for remote image files.
// ignore: one_member_abstracts
abstract interface class ImageFileCache {
  /// Returns a cached file when available or downloads and persists it.
  Future<File?> getOrDownload({
    required String cacheKey,
    required String imageUrl,
  });
}

/// A file-based implementation of [ImageFileCache].
class ImageFileCacheImpl implements ImageFileCache {
  Future<Directory> get _cacheDir async {
    final baseDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${baseDir.path}/image_cache');
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<File> _fileFor(String cacheKey) async {
    final dir = await _cacheDir;
    return File('${dir.path}/$cacheKey.img');
  }

  Future<File?> _getCachedFile(String cacheKey) async {
    final file = await _fileFor(cacheKey);
    if (file.existsSync()) {
      return file;
    }
    return null;
  }

  @override
  Future<File?> getOrDownload({
    required String cacheKey,
    required String imageUrl,
  }) async {
    final cachedFile = await _getCachedFile(cacheKey);
    if (cachedFile != null) {
      return cachedFile;
    }

    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(imageUrl));
      final response = await request.close();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return null;
      }

      final bytes = await consolidateHttpClientResponseBytes(response);
      final file = await _fileFor(cacheKey);
      await file.writeAsBytes(bytes, flush: true);
      return file;
    } on Exception {
      return null;
    } finally {
      client.close(force: true);
    }
  }
}
