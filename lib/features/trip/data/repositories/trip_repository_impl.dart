/// Trip Repository Implementation (Data Layer)
/// Uses Drift DAOs for local persistence.
library;

import 'package:drift/drift.dart' as drift;
import 'package:get/get.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/trip_entity.dart';
import '../../domain/repositories/trip_repository.dart';

class TripRepositoryImpl implements TripRepository {
  TripRepositoryImpl() : _db = Get.find<AppDatabase>();

  final AppDatabase _db;
  TripDao get _tripDao => _db.tripDao;
  TripPointDao get _pointDao => _db.tripPointDao;

  @override
  Future<int> startTrip(DateTime startTime, {String? title}) =>
      _tripDao.insertTrip(TripsTableCompanion.insert(
        startTime: startTime,
        title: drift.Value(title),
      ));

  @override
  Future<void> stopTrip(
    int tripId, {
    required double distanceMeters,
    required double avgSpeedKmh,
    required double maxSpeedKmh,
    required int durationSeconds,
    required DateTime endTime,
  }) async {
    final trip = await _tripDao.getTripById(tripId);
    if (trip == null) return;
    await _tripDao.updateTrip(trip.copyWith(
      endTime: drift.Value(endTime),
      distance: distanceMeters,
      avgSpeed: avgSpeedKmh,
      maxSpeed: maxSpeedKmh,
      durationSeconds: durationSeconds,
    ));
  }

  @override
  Future<void> addTripPoint(TripPointEntity point) =>
      _pointDao.insertPoint(TripPointsTableCompanion.insert(
        tripId: point.tripId,
        latitude: point.latitude,
        longitude: point.longitude,
        speed: drift.Value(point.speedKmh),
        accuracy: drift.Value(point.accuracy),
        altitude: drift.Value(point.altitude),
        timestamp: point.timestamp,
      ));

  @override
  Future<void> saveImportedTrip(TripEntity trip) async {
    final tripId = await _tripDao.insertTrip(TripsTableCompanion.insert(
      startTime: trip.startTime,
      endTime: drift.Value(trip.endTime),
      title: drift.Value(trip.title),
      distance: drift.Value(trip.distanceMeters),
      avgSpeed: drift.Value(trip.avgSpeedKmh),
      maxSpeed: drift.Value(trip.maxSpeedKmh),
      durationSeconds: drift.Value(trip.durationSeconds),
    ));

    final companions = trip.points
        .map((p) => TripPointsTableCompanion.insert(
              tripId: tripId,
              latitude: p.latitude,
              longitude: p.longitude,
              speed: drift.Value(p.speedKmh),
              accuracy: drift.Value(p.accuracy),
              altitude: drift.Value(p.altitude),
              timestamp: p.timestamp,
            ))
        .toList();

    await _pointDao.insertPoints(companions);
  }

  @override
  Future<List<TripEntity>> getAllTrips() async {
    final rows = await _tripDao.getAllTrips();
    return rows.map((r) => TripEntity.fromDb(r)).toList();
  }

  @override
  Stream<List<TripEntity>> watchAllTrips() => _tripDao
      .watchAllTrips()
      .map((rows) => rows.map((r) => TripEntity.fromDb(r)).toList());

  @override
  Future<TripEntity?> getTripById(int id) async {
    final row = await _tripDao.getTripById(id);
    if (row == null) return null;
    final pointRows = await _pointDao.getPointsForTrip(id);
    final points = pointRows.map(TripPointEntity.fromDb).toList();
    return TripEntity.fromDb(row, points: points);
  }

  @override
  Future<void> deleteTrip(int id) => _tripDao.deleteTrip(id);
}
