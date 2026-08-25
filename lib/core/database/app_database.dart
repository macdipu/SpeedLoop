/// Core Database Module
/// Configures the Drift SQLite database for SpeedLoop app.
library;

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

// ---------------------------------------------------------------------------
// TABLES
// ---------------------------------------------------------------------------

class TripsTable extends Table {
  @override
  String get tableName => 'trips';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 0, max: 200).nullable()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  RealColumn get distance => real().withDefault(const Constant(0.0))();
  RealColumn get avgSpeed => real().withDefault(const Constant(0.0))();
  RealColumn get maxSpeed => real().withDefault(const Constant(0.0))();
  IntColumn get durationSeconds => integer().withDefault(const Constant(0))();
}

class TripPointsTable extends Table {
  @override
  String get tableName => 'trip_points';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get tripId =>
      integer().references(TripsTable, #id, onDelete: KeyAction.cascade)();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  RealColumn get speed => real().withDefault(const Constant(0.0))();
  RealColumn get accuracy => real().withDefault(const Constant(0.0))();
  RealColumn get altitude => real().withDefault(const Constant(0.0))();
  DateTimeColumn get timestamp => dateTime()();
}

class DashcamClipsTable extends Table {
  @override
  String get tableName => 'dashcam_clips';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get path => text().unique()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isLocked => boolean().withDefault(const Constant(false))();
  IntColumn get sizeBytes => integer().withDefault(const Constant(0))();
}

// ---------------------------------------------------------------------------
// DATABASE
// ---------------------------------------------------------------------------

@DriftDatabase(
  tables: [TripsTable, TripPointsTable, DashcamClipsTable],
  daos: [TripDao, TripPointDao, DashcamClipDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) await m.createTable(dashcamClipsTable);
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'speedloop_db');
  }
}

// ---------------------------------------------------------------------------
// DAOs
// ---------------------------------------------------------------------------

@DriftAccessor(tables: [TripsTable, TripPointsTable])
class TripDao extends DatabaseAccessor<AppDatabase> with _$TripDaoMixin {
  TripDao(super.db);

  Future<List<TripsTableData>> getAllTrips() =>
      (select(tripsTable)..orderBy([(t) => OrderingTerm.desc(t.startTime)]))
          .get();

  Stream<List<TripsTableData>> watchAllTrips() =>
      (select(tripsTable)..orderBy([(t) => OrderingTerm.desc(t.startTime)]))
          .watch();

  Future<TripsTableData?> getTripById(int id) =>
      (select(tripsTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertTrip(TripsTableCompanion trip) =>
      into(tripsTable).insert(trip);

  Future<bool> updateTrip(TripsTableData trip) =>
      update(tripsTable).replace(trip);

  Future<int> deleteTrip(int id) =>
      (delete(tripsTable)..where((t) => t.id.equals(id))).go();
}

@DriftAccessor(tables: [TripPointsTable])
class TripPointDao extends DatabaseAccessor<AppDatabase>
    with _$TripPointDaoMixin {
  TripPointDao(super.db);

  Future<List<TripPointsTableData>> getPointsForTrip(int tripId) =>
      (select(tripPointsTable)
            ..where((p) => p.tripId.equals(tripId))
            ..orderBy([(p) => OrderingTerm.asc(p.timestamp)]))
          .get();

  Future<TripPointsTableData?> getLastPointForTrip(int tripId) =>
      (select(tripPointsTable)
            ..where((p) => p.tripId.equals(tripId))
            ..orderBy([(p) => OrderingTerm.desc(p.timestamp)])
            ..limit(1))
          .getSingleOrNull();

  Stream<List<TripPointsTableData>> watchPointsForTrip(int tripId) =>
      (select(tripPointsTable)
            ..where((p) => p.tripId.equals(tripId))
            ..orderBy([(p) => OrderingTerm.asc(p.timestamp)]))
          .watch();

  Future<void> insertPoints(List<TripPointsTableCompanion> points) =>
      batch((b) => b.insertAll(tripPointsTable, points));

  Future<int> insertPoint(TripPointsTableCompanion point) =>
      into(tripPointsTable).insert(point);

  Future<int> deletePointsForTrip(int tripId) =>
      (delete(tripPointsTable)..where((p) => p.tripId.equals(tripId))).go();
}

@DriftAccessor(tables: [DashcamClipsTable])
class DashcamClipDao extends DatabaseAccessor<AppDatabase>
    with _$DashcamClipDaoMixin {
  DashcamClipDao(super.db);

  Future<List<DashcamClipsTableData>> getAllClips() =>
      (select(dashcamClipsTable)
            ..orderBy([(clip) => OrderingTerm.asc(clip.createdAt)]))
          .get();

  Future<void> upsertClip(DashcamClipsTableCompanion clip) =>
      into(dashcamClipsTable).insertOnConflictUpdate(clip);

  Future<int> setLocked(String path, bool locked) =>
      (update(dashcamClipsTable)..where((clip) => clip.path.equals(path)))
          .write(
        DashcamClipsTableCompanion(isLocked: Value(locked)),
      );

  Future<int> deleteByPath(String path) =>
      (delete(dashcamClipsTable)..where((clip) => clip.path.equals(path))).go();
}
