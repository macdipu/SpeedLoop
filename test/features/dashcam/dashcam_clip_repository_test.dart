import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speedloop/core/database/app_database.dart';
import 'package:speedloop/features/dashcam/data/dashcam_clip_repository.dart';

void main() {
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
