import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:speedloop/features/dashcam/data/dashcam_clip_repository.dart';

class MemoryClipRepository implements DashcamClipRepository {
  final Map<String, DashcamClipMetadata> clips = {};

  @override
  Future<void> deleteMetadata(String path) async => clips.remove(path);

  @override
  Future<List<DashcamClipMetadata>> getAll() async => clips.values.toList();

  @override
  Future<List<DashcamClipMetadata>> getForTrip(int tripId) async =>
      clips.values.where((clip) => clip.tripId == tripId).toList();

  @override
  Future<Map<int, int>> getClipCountsByTripIds(List<int> tripIds) async {
    final counts = <int, int>{};
    for (final clip in clips.values) {
      final tripId = clip.tripId;
      if (tripId != null && tripIds.contains(tripId)) {
        counts[tripId] = (counts[tripId] ?? 0) + 1;
      }
    }
    return counts;
  }

  @override
  Future<Map<int, int>> getProtectedClipCountsByTripIds(
      List<int> tripIds) async {
    final counts = <int, int>{};
    for (final clip in clips.values) {
      final tripId = clip.tripId;
      if (tripId != null && tripIds.contains(tripId) && clip.isLocked) {
        counts[tripId] = (counts[tripId] ?? 0) + 1;
      }
    }
    return counts;
  }

  @override
  Future<void> setLocked(String path, bool locked) async {
    final clip = clips[path]!;
    clips[path] = DashcamClipMetadata(
      path: clip.path,
      createdAt: clip.createdAt,
      isLocked: locked,
      sizeBytes: clip.sizeBytes,
      tripId: clip.tripId,
    );
  }

  @override
  Future<void> upsert(DashcamClipMetadata metadata) async {
    clips[metadata.path] = metadata;
  }
}

void main() {
  late Directory directory;
  late MemoryClipRepository repository;
  late DashcamStorageManager manager;

  setUp(() async {
    directory =
        await Directory.systemTemp.createTemp('speedloop_dashcam_test_');
    repository = MemoryClipRepository();
    manager = DashcamStorageManager(repository: repository);
  });

  tearDown(() async {
    if (await directory.exists()) await directory.delete(recursive: true);
  });

  Future<String> addClip(
    String name,
    int size, {
    required DateTime createdAt,
    bool locked = false,
  }) async {
    final file = File('${directory.path}/$name.mp4');
    await file.writeAsBytes(List.filled(size, 1));
    await repository.upsert(
      DashcamClipMetadata(
        path: file.path,
        createdAt: createdAt,
        isLocked: locked,
        sizeBytes: size,
      ),
    );
    return file.path;
  }

  test('locked metadata survives manager recreation and cleanup', () async {
    final now = DateTime.utc(2026);
    final locked = await addClip('locked', 70, createdAt: now, locked: true);
    final unlocked = await addClip(
      'unlocked',
      50,
      createdAt: now.add(const Duration(seconds: 1)),
    );

    manager = DashcamStorageManager(repository: repository);
    final result = await manager.enforceQuota(
      directory: directory,
      maxBytes: 80,
    );

    expect(await File(locked).exists(), isTrue);
    expect(await File(unlocked).exists(), isFalse);
    expect(repository.clips[locked]!.isLocked, isTrue);
    expect(result.totalBytes, 70);
  });

  test('unlocking makes a clip eligible for oldest-first cleanup', () async {
    final now = DateTime.utc(2026);
    final first = await addClip('first', 60, createdAt: now, locked: true);
    await addClip(
      'second',
      60,
      createdAt: now.add(const Duration(seconds: 1)),
    );
    await repository.setLocked(first, false);

    final result = await manager.enforceQuota(
      directory: directory,
      maxBytes: 60,
    );
    expect(result.deletedPaths, [first]);
  });

  test('all-storage-locked condition never deletes protected clips', () async {
    final now = DateTime.utc(2026);
    final first = await addClip('first', 60, createdAt: now, locked: true);
    final second = await addClip(
      'second',
      60,
      createdAt: now.add(const Duration(seconds: 1)),
      locked: true,
    );

    final result = await manager.enforceQuota(
      directory: directory,
      maxBytes: 100,
    );
    expect(result.canRecord, isFalse);
    expect(result.deletedPaths, isEmpty);
    expect(await File(first).exists(), isTrue);
    expect(await File(second).exists(), isTrue);
  });

  test('reconcile adds legacy files and removes only stale metadata', () async {
    final legacy = File('${directory.path}/legacy.mp4');
    await legacy.writeAsBytes([1, 2, 3]);
    await repository.upsert(
      DashcamClipMetadata(
        path: '${directory.path}/missing.mp4',
        createdAt: DateTime.utc(2020),
        isLocked: true,
        sizeBytes: 10,
      ),
    );

    final clips = await manager.reconcile(directory);
    expect(clips, hasLength(1));
    expect(clips.single.path, legacy.path);
    expect(clips.single.isLocked, isFalse);
  });
}
