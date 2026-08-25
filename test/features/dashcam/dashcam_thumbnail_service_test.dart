import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:speedloop/features/dashcam/data/dashcam_thumbnail_service.dart';

void main() {
  late Directory temporaryDirectory;
  late Directory cacheDirectory;

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'speedloop_thumbnail_test_',
    );
    cacheDirectory = Directory('${temporaryDirectory.path}/cache');
  });

  tearDown(() async {
    if (await temporaryDirectory.exists()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  test('generates once and reuses the cached thumbnail', () async {
    final video = File('${temporaryDirectory.path}/clip.mp4');
    await video.writeAsBytes([1]);
    var generationCount = 0;
    final service = DashcamThumbnailService(
      generator: (_) async {
        generationCount++;
        return Uint8List.fromList([1, 2, 3]);
      },
      cacheDirectoryProvider: () async => cacheDirectory,
    );

    final first = await service.thumbnailFor(video.path);
    final second = await service.thumbnailFor(video.path);

    expect(first, isNotNull);
    expect(await first!.readAsBytes(), [1, 2, 3]);
    expect(second!.path, first.path);
    expect(generationCount, 1);
  });

  test('shares concurrent generation for the same clip', () async {
    final video = File('${temporaryDirectory.path}/clip.mp4');
    await video.writeAsBytes([1]);
    var generationCount = 0;
    final service = DashcamThumbnailService(
      generator: (_) async {
        generationCount++;
        await Future<void>.delayed(const Duration(milliseconds: 20));
        return Uint8List.fromList([4, 5, 6]);
      },
      cacheDirectoryProvider: () async => cacheDirectory,
    );

    final results = await Future.wait([
      service.thumbnailFor(video.path),
      service.thumbnailFor(video.path),
    ]);

    expect(results[0]!.path, results[1]!.path);
    expect(generationCount, 1);
  });

  test('returns null for a missing clip without invoking generator', () async {
    var generationCount = 0;
    final service = DashcamThumbnailService(
      generator: (_) async {
        generationCount++;
        return Uint8List(1);
      },
      cacheDirectoryProvider: () async => cacheDirectory,
    );

    expect(
      await service.thumbnailFor('${temporaryDirectory.path}/missing.mp4'),
      isNull,
    );
    expect(generationCount, 0);
  });

  test('bounds cache by removing the least recently used thumbnail', () async {
    final firstVideo = File('${temporaryDirectory.path}/first.mp4');
    final secondVideo = File('${temporaryDirectory.path}/second.mp4');
    await firstVideo.writeAsBytes([1]);
    await secondVideo.writeAsBytes([2]);
    final service = DashcamThumbnailService(
      generator: (_) async => Uint8List.fromList([7]),
      cacheDirectoryProvider: () async => cacheDirectory,
      maxCachedThumbnails: 1,
    );

    final first = await service.thumbnailFor(firstVideo.path);
    await first!.setLastModified(DateTime(2020));
    final second = await service.thumbnailFor(secondVideo.path);

    expect(await first.exists(), isFalse);
    expect(await second!.exists(), isTrue);
  });

  test('deletes a cached thumbnail without touching its video', () async {
    final video = File('${temporaryDirectory.path}/clip.mp4');
    await video.writeAsBytes([1]);
    final service = DashcamThumbnailService(
      generator: (_) async => Uint8List.fromList([8]),
      cacheDirectoryProvider: () async => cacheDirectory,
    );
    final thumbnail = await service.thumbnailFor(video.path);

    await service.deleteFor(video.path);

    expect(await thumbnail!.exists(), isFalse);
    expect(await video.exists(), isTrue);
  });
}
