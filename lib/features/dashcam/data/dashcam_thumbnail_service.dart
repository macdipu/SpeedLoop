import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

typedef ThumbnailGenerator = Future<Uint8List?> Function(String videoPath);

/// Generates small poster frames without keeping a video decoder alive for
/// every row in the clip library.
///
/// Thumbnails are disposable UI cache, not clip metadata. The cache is bounded
/// and keyed by the clip's unique path, so losing it never affects a recording.
class DashcamThumbnailService {
  DashcamThumbnailService({
    ThumbnailGenerator? generator,
    Future<Directory> Function()? cacheDirectoryProvider,
    this.maxCachedThumbnails = 100,
  })  : _generator = generator ?? _generateThumbnail,
        _cacheDirectoryProvider =
            cacheDirectoryProvider ?? _defaultCacheDirectoryProvider;

  static final DashcamThumbnailService instance = DashcamThumbnailService();

  final ThumbnailGenerator _generator;
  final Future<Directory> Function() _cacheDirectoryProvider;
  final int maxCachedThumbnails;
  final Map<String, Future<File?>> _inFlight = <String, Future<File?>>{};

  Future<File?> thumbnailFor(String videoPath) {
    return _inFlight.putIfAbsent(videoPath, () {
      final future = _thumbnailFor(videoPath);
      unawaited(
        future.then<void>(
          (_) => _inFlight.remove(videoPath),
          onError: (Object _, StackTrace __) {
            _inFlight.remove(videoPath);
          },
        ),
      );
      return future;
    });
  }

  Future<File?> _thumbnailFor(String videoPath) async {
    final video = File(videoPath);
    if (!await video.exists()) return null;

    final cacheDirectory = await _cacheDirectoryProvider();
    if (!await cacheDirectory.exists()) {
      await cacheDirectory.create(recursive: true);
    }
    final destination = File(
      '${cacheDirectory.path}/${_cacheKey(videoPath)}.jpg',
    );
    if (await destination.exists() && await destination.length() > 0) {
      await destination.setLastModified(DateTime.now());
      return destination;
    }

    final bytes = await _generator(videoPath);
    if (bytes == null || bytes.isEmpty) return null;

    final temporary = File('${destination.path}.tmp');
    await temporary.writeAsBytes(bytes, flush: true);
    if (await destination.exists()) await destination.delete();
    await temporary.rename(destination.path);
    await _trimCache(cacheDirectory);
    return destination;
  }

  Future<void> deleteFor(String videoPath) async {
    final cacheDirectory = await _cacheDirectoryProvider();
    final thumbnail = File(
      '${cacheDirectory.path}/${_cacheKey(videoPath)}.jpg',
    );
    if (await thumbnail.exists()) await thumbnail.delete();
  }

  Future<void> _trimCache(Directory directory) async {
    if (maxCachedThumbnails < 1) return;
    final thumbnails = await directory
        .list()
        .where((entity) => entity is File && entity.path.endsWith('.jpg'))
        .cast<File>()
        .toList();
    if (thumbnails.length <= maxCachedThumbnails) return;

    final modified = await Future.wait(
      thumbnails
          .map((file) async => (file: file, at: await file.lastModified())),
    );
    modified.sort((a, b) => a.at.compareTo(b.at));
    final removeCount = modified.length - maxCachedThumbnails;
    for (final entry in modified.take(removeCount)) {
      await entry.file.delete();
    }
  }

  static String _cacheKey(String path) {
    // Stable FNV-1a hash avoids filesystem-hostile characters and keeps cache
    // filenames consistent across process restarts.
    var hash = 0xcbf29ce484222325;
    for (final byte in path.codeUnits) {
      hash ^= byte;
      hash = (hash * 0x100000001b3) & 0x7fffffffffffffff;
    }
    return hash.toRadixString(16).padLeft(16, '0');
  }

  static Future<Uint8List?> _generateThumbnail(String videoPath) {
    return VideoThumbnail.thumbnailData(
      video: videoPath,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 480,
      quality: 75,
      timeMs: 1000,
    );
  }

  static Future<Directory> _defaultCacheDirectoryProvider() async {
    final root = await getTemporaryDirectory();
    return Directory('${root.path}/speedloop_dashcam_thumbnails');
  }
}
