/// Core Database Module
/// Configures the Drift SQLite database for SpeedLoop app.

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

// ---------------------------------------------------------------------------
// DATABASE
// ---------------------------------------------------------------------------

@DriftDatabase(tables: [TripsTable, TripPointsTable], daos: [TripDao, TripPointDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async { await m.createAll(); },
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
      (select(tripsTable)..orderBy([(t) => OrderingTerm.desc(t.startTime)])).get();

  Stream<List<TripsTableData>> watchAllTrips() =>
      (select(tripsTable)..orderBy([(t) => OrderingTerm.desc(t.startTime)])).watch();

  Future<TripsTableData?> getTripById(int id) =>
      (select(tripsTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertTrip(TripsTableCompanion trip) =>
      into(tripsTable).insert(trip);

  Future<bool> updateTrip(TripsTableData trip) => update(tripsTable).replace(trip);

  Future<int> deleteTrip(int id) =>
      (delete(tripsTable)..where((t) => t.id.equals(id))).go();
}

@DriftAccessor(tables: [TripPointsTable])
class TripPointDao extends DatabaseAccessor<AppDatabase> with _$TripPointDaoMixin {
  TripPointDao(super.db);

  Future<List<TripPointsTableData>> getPointsForTrip(int tripId) =>
      (select(tripPointsTable)
            ..where((p) => p.tripId.equals(tripId))
            ..orderBy([(p) => OrderingTerm.asc(p.timestamp)]))
          .get();

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
