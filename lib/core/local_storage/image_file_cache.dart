import 'dart:io';
import 'dart:typed_data';

import 'package:social_app/core/local_storage/app_directory_provider.dart';
import 'package:social_app/core/logging/app_logger.dart';
import 'package:social_app/core/network/http_downloader.dart';

/// A disk cache for remote image files.
// ignore: one_member_abstracts
abstract interface class ImageFileCache {
  /// Returns a cached file when available or downloads and persists it.
  Future<File?> getOrDownload({
    required String cacheKey,
    required String imageUrl,
  });
}

/// An implementation of [ImageFileCache] that uses the device's file system
/// to cache images.
class ImageFileCacheImpl implements ImageFileCache {
  /// Creates an [ImageFileCacheImpl].
  ImageFileCacheImpl({
    AppDirectoryProvider? directoryProvider,
    HttpDownloader? httpDownloader,
  }) : _directoryProvider =
           directoryProvider ?? PathProviderAppDirectoryProvider(),
       _httpDownloader = httpDownloader ?? DartHttpDownloader();

  final AppDirectoryProvider _directoryProvider;
  final HttpDownloader _httpDownloader;

  Future<Directory> get _cacheDir async {
    final baseDir = await _directoryProvider.getApplicationDocumentsDirectory();
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

    try {
      final bytes = await _downloadImage(Uri.parse(imageUrl));
      final file = await _fileFor(cacheKey);
      await file.writeAsBytes(bytes, flush: true);
      return file;
    } on Exception catch (e, stackTrace) {
      appLogger.error(
        'Failed to download or cache image for $cacheKey from $imageUrl',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  Future<Uint8List> _downloadImage(Uri uri) {
    return _httpDownloader.downloadBytes(uri);
  }
}
