import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:get/get.dart';

import '../../../core/database/app_database.dart';

enum DashcamIncidentType { manualEvent, severeBraking }

extension DashcamIncidentTypeDisplay on DashcamIncidentType {
  String get label => switch (this) {
        DashcamIncidentType.manualEvent => 'Manual event',
        DashcamIncidentType.severeBraking => 'Severe braking',
      };
}

class DashcamClipMetadata {
  const DashcamClipMetadata({
    required this.path,
    required this.createdAt,
    required this.isLocked,
    required this.sizeBytes,
    this.tripId,
    this.incidentType,
  });

  final String path;
  final DateTime createdAt;
  final bool isLocked;
  final int sizeBytes;
  final int? tripId;
  final DashcamIncidentType? incidentType;
}

abstract class DashcamClipRepository {
  Future<List<DashcamClipMetadata>> getAll();
  Future<List<DashcamClipMetadata>> getForTrip(int tripId);
  Future<Map<int, int>> getClipCountsByTripIds(List<int> tripIds);
  Future<Map<int, int>> getProtectedClipCountsByTripIds(List<int> tripIds);
  Future<void> upsert(DashcamClipMetadata metadata);
  Future<void> setLocked(String path, bool locked);
  Future<void> deleteMetadata(String path);
}

class DriftDashcamClipRepository implements DashcamClipRepository {
  DriftDashcamClipRepository({AppDatabase? database})
      : _database = database ?? Get.find<AppDatabase>();

  final AppDatabase _database;

  @override
  Future<List<DashcamClipMetadata>> getAll() async {
    final rows = await _database.dashcamClipDao.getAllClips();
    return rows
        .map(
          (row) => DashcamClipMetadata(
            path: row.path,
            createdAt: row.createdAt,
            isLocked: row.isLocked,
            sizeBytes: row.sizeBytes,
            tripId: row.tripId,
            incidentType: _parseIncidentType(row.incidentType),
          ),
        )
        .toList();
  }

  @override
  Future<List<DashcamClipMetadata>> getForTrip(int tripId) async {
    final rows = await _database.dashcamClipDao.getClipsForTrip(tripId);
    return rows
        .map(
          (row) => DashcamClipMetadata(
            path: row.path,
            createdAt: row.createdAt,
            isLocked: row.isLocked,
            sizeBytes: row.sizeBytes,
            tripId: row.tripId,
            incidentType: _parseIncidentType(row.incidentType),
          ),
        )
        .toList();
  }

  @override
  Future<Map<int, int>> getClipCountsByTripIds(List<int> tripIds) =>
      _database.dashcamClipDao.getClipCountsForTrips(tripIds);

  @override
  Future<Map<int, int>> getProtectedClipCountsByTripIds(List<int> tripIds) =>
      _database.dashcamClipDao.getLockedClipCountsForTrips(tripIds);

  @override
  Future<void> upsert(DashcamClipMetadata metadata) =>
      _database.dashcamClipDao.upsertClip(
        DashcamClipsTableCompanion(
          tripId: drift.Value(metadata.tripId),
          path: drift.Value(metadata.path),
          createdAt: drift.Value(metadata.createdAt),
          isLocked: drift.Value(metadata.isLocked),
          sizeBytes: drift.Value(metadata.sizeBytes),
          incidentType: drift.Value(metadata.incidentType?.name),
        ),
      );

  @override
  Future<void> setLocked(String path, bool locked) async {
    await _database.dashcamClipDao.setLocked(path, locked);
  }

  @override
  Future<void> deleteMetadata(String path) async {
    await _database.dashcamClipDao.deleteByPath(path);
  }

  static DashcamIncidentType? _parseIncidentType(String? stored) {
    if (stored == null) return null;
    for (final type in DashcamIncidentType.values) {
      if (type.name == stored) return type;
    }
    // Unknown values from a future app version must not make old clients fail
    // to load or protect the associated recording.
    return null;
  }
}

class DashcamStorageResult {
  const DashcamStorageResult({
    required this.totalBytes,
    required this.lockedBytes,
    required this.deletedPaths,
    required this.canRecord,
  });

  final int totalBytes;
  final int lockedBytes;
  final List<String> deletedPaths;
  final bool canRecord;
}

class DashcamStorageManager {
  DashcamStorageManager({required this.repository});

  final DashcamClipRepository repository;

  Future<List<DashcamClipMetadata>> reconcile(Directory directory) async {
    if (!await directory.exists()) await directory.create(recursive: true);
    final files = await directory
        .list()
        .where((entry) => entry is File && entry.path.endsWith('.mp4'))
        .cast<File>()
        .toList();
    final metadata = await repository.getAll();
    final byPath = {for (final clip in metadata) clip.path: clip};
    final filePaths = files.map((file) => file.path).toSet();

    for (final stale in metadata.where(
      (clip) => !filePaths.contains(clip.path),
    )) {
      await repository.deleteMetadata(stale.path);
    }
    for (final file in files) {
      final existing = byPath[file.path];
      final size = await file.length();
      final created = await file.lastModified();
      if (existing == null || existing.sizeBytes != size) {
        await repository.upsert(
          DashcamClipMetadata(
            path: file.path,
            createdAt: existing?.createdAt ?? created,
            isLocked: existing?.isLocked ?? false,
            sizeBytes: size,
            tripId: existing?.tripId,
          ),
        );
      }
    }
    return repository.getAll();
  }

  Future<DashcamStorageResult> enforceQuota({
    required Directory directory,
    required int maxBytes,
  }) async {
    final clips = await reconcile(directory);
    var total = clips.fold<int>(0, (sum, clip) => sum + clip.sizeBytes);
    final lockedBytes = clips
        .where((clip) => clip.isLocked)
        .fold<int>(0, (sum, clip) => sum + clip.sizeBytes);
    final unlocked = clips.where((clip) => !clip.isLocked).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final deleted = <String>[];

    while (total > maxBytes && unlocked.isNotEmpty) {
      final oldest = unlocked.removeAt(0);
      final file = File(oldest.path);
      if (await file.exists()) await file.delete();
      await repository.deleteMetadata(oldest.path);
      total -= oldest.sizeBytes;
      deleted.add(oldest.path);
    }

    return DashcamStorageResult(
      totalBytes: total,
      lockedBytes: lockedBytes,
      deletedPaths: deleted,
      canRecord: lockedBytes < maxBytes && total <= maxBytes,
    );
  }
}
