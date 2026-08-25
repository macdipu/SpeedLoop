import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speedloop/core/database/app_database.dart';
import 'package:speedloop/features/dashcam/data/dashcam_clip_repository.dart';

void main() {
  test('SQLite lock metadata survives database and repository recreation', () async {
    final temporary = await Directory.systemTemp.createTemp('speedloop_db_');
    final databaseFile = File('${temporary.path}/speedloop.sqlite');
    final clipPath = '${temporary.path}/protected.mp4';
    final createdAt = DateTime.utc(2026, 8, 25);

    var database = AppDatabase.forTesting(NativeDatabase(databaseFile));
    var repository = DriftDashcamClipRepository(database: database);
    await repository.upsert(
      DashcamClipMetadata(
        path: clipPath,
        createdAt: createdAt,
        isLocked: true,
        sizeBytes: 1234,
      ),
    );
    await database.close();

    database = AppDatabase.forTesting(NativeDatabase(databaseFile));
    repository = DriftDashcamClipRepository(database: database);
    final restored = await repository.getAll();

    expect(restored, hasLength(1));
    expect(restored.single.path, clipPath);
    expect(restored.single.isLocked, isTrue);
    expect(restored.single.sizeBytes, 1234);

    await database.close();
    await temporary.delete(recursive: true);
  });
}
