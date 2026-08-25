import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speedloop/core/database/app_database.dart';
import 'package:speedloop/features/dashcam/data/dashcam_clip_repository.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  test('v3 migration preserves clips and adds nullable incident metadata',
      () async {
    final temporary = await Directory.systemTemp.createTemp('speedloop_db_v3_');
    final databaseFile = File('${temporary.path}/speedloop.sqlite');
    final oldDatabase = sqlite.sqlite3.open(databaseFile.path);
    oldDatabase.execute('''
      CREATE TABLE dashcam_clips (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        trip_id INTEGER NULL,
        path TEXT NOT NULL UNIQUE,
        created_at INTEGER NOT NULL,
        is_locked INTEGER NOT NULL DEFAULT 0 CHECK (is_locked IN (0, 1)),
        size_bytes INTEGER NOT NULL DEFAULT 0
      )
    ''');
    oldDatabase.execute(
      "INSERT INTO dashcam_clips "
      "(trip_id, path, created_at, is_locked, size_bytes) "
      "VALUES (9, '${temporary.path}/legacy.mp4', 1787616000, 1, 321)",
    );
    oldDatabase.execute('PRAGMA user_version = 3');
    oldDatabase.dispose();

    final database = AppDatabase.forTesting(NativeDatabase(databaseFile));
    final repository = DriftDashcamClipRepository(database: database);
    final restored = await repository.getAll();

    expect(restored, hasLength(1));
    expect(restored.single.path, '${temporary.path}/legacy.mp4');
    expect(restored.single.isLocked, isTrue);
    expect(restored.single.incidentType, isNull);

    await repository.upsert(
      DashcamClipMetadata(
        tripId: 9,
        path: restored.single.path,
        createdAt: restored.single.createdAt,
        isLocked: true,
        sizeBytes: restored.single.sizeBytes,
        incidentType: DashcamIncidentType.manualEvent,
      ),
    );
    expect(
      (await repository.getAll()).single.incidentType,
      DashcamIncidentType.manualEvent,
    );

    await database.close();
    await temporary.delete(recursive: true);
  });

  test('SQLite lock metadata survives database and repository recreation',
      () async {
    final temporary = await Directory.systemTemp.createTemp('speedloop_db_');
    final databaseFile = File('${temporary.path}/speedloop.sqlite');
    final clipPath = '${temporary.path}/protected.mp4';
    final createdAt = DateTime.utc(2026, 8, 25);

    var database = AppDatabase.forTesting(NativeDatabase(databaseFile));
    var repository = DriftDashcamClipRepository(database: database);
    await repository.upsert(
      DashcamClipMetadata(
        tripId: 42,
        path: clipPath,
        createdAt: createdAt,
        isLocked: true,
        sizeBytes: 1234,
        incidentType: DashcamIncidentType.severeBraking,
      ),
    );
    await database.close();

    database = AppDatabase.forTesting(NativeDatabase(databaseFile));
    repository = DriftDashcamClipRepository(database: database);
    final restored = await repository.getAll();
    final byTrip = await repository.getForTrip(42);

    expect(restored, hasLength(1));
    expect(restored.single.path, clipPath);
    expect(restored.single.isLocked, isTrue);
    expect(restored.single.sizeBytes, 1234);
    expect(restored.single.tripId, 42);
    expect(
      restored.single.incidentType,
      DashcamIncidentType.severeBraking,
    );
    expect(byTrip, hasLength(1));
    expect(byTrip.single.path, clipPath);
    expect(byTrip.single.incidentType, DashcamIncidentType.severeBraking);

    await database.close();
    await temporary.delete(recursive: true);
  });

  test('SQLite clip counts are aggregated by trip id', () async {
    final temporary = await Directory.systemTemp.createTemp('speedloop_db_');
    final databaseFile = File('${temporary.path}/speedloop.sqlite');

    final database = AppDatabase.forTesting(NativeDatabase(databaseFile));
    final repository = DriftDashcamClipRepository(database: database);
    await repository.upsert(
      DashcamClipMetadata(
        tripId: 7,
        path: '${temporary.path}/one.mp4',
        createdAt: DateTime.utc(2026, 8, 25, 10),
        isLocked: false,
        sizeBytes: 10,
      ),
    );
    await repository.upsert(
      DashcamClipMetadata(
        tripId: 7,
        path: '${temporary.path}/two.mp4',
        createdAt: DateTime.utc(2026, 8, 25, 11),
        isLocked: true,
        sizeBytes: 11,
      ),
    );
    await repository.upsert(
      DashcamClipMetadata(
        tripId: 9,
        path: '${temporary.path}/three.mp4',
        createdAt: DateTime.utc(2026, 8, 25, 12),
        isLocked: false,
        sizeBytes: 12,
      ),
    );

    final counts = await repository.getClipCountsByTripIds([7, 9, 11]);

    expect(counts, {
      7: 2,
      9: 1,
    });

    await database.close();
    await temporary.delete(recursive: true);
  });

  test('SQLite protected clip counts are aggregated by trip id', () async {
    final temporary = await Directory.systemTemp.createTemp('speedloop_db_');
    final databaseFile = File('${temporary.path}/speedloop.sqlite');

    final database = AppDatabase.forTesting(NativeDatabase(databaseFile));
    final repository = DriftDashcamClipRepository(database: database);
    await repository.upsert(
      DashcamClipMetadata(
        tripId: 5,
        path: '${temporary.path}/one.mp4',
        createdAt: DateTime.utc(2026, 8, 25, 10),
        isLocked: true,
        sizeBytes: 10,
      ),
    );
    await repository.upsert(
      DashcamClipMetadata(
        tripId: 5,
        path: '${temporary.path}/two.mp4',
        createdAt: DateTime.utc(2026, 8, 25, 11),
        isLocked: false,
        sizeBytes: 11,
      ),
    );
    await repository.upsert(
      DashcamClipMetadata(
        tripId: 6,
        path: '${temporary.path}/three.mp4',
        createdAt: DateTime.utc(2026, 8, 25, 12),
        isLocked: true,
        sizeBytes: 12,
      ),
    );

    final counts = await repository.getProtectedClipCountsByTripIds([5, 6, 7]);

    expect(counts, {
      5: 1,
      6: 1,
    });

    await database.close();
    await temporary.delete(recursive: true);
  });
}
