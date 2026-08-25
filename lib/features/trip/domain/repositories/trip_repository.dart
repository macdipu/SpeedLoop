/// Trip Repository Interface (Domain Layer)
library;

import '../../domain/entities/trip_entity.dart';

abstract class TripRepository {
  Future<int> startTrip(DateTime startTime, {String? title});
  Future<void> stopTrip(
    int tripId, {
    required double distanceMeters,
    required double avgSpeedKmh,
    required double maxSpeedKmh,
    required int durationSeconds,
    required DateTime endTime,
  });
  Future<void> addTripPoint(TripPointEntity point);
  Future<void> saveImportedTrip(TripEntity trip);
  Future<List<TripEntity>> getAllTrips();
  Stream<List<TripEntity>> watchAllTrips();
  Future<TripEntity?> getTripById(int id);
  Future<void> deleteTrip(int id);
}
