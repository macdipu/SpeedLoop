/// Trip Feature — Domain Entities
/// Pure domain objects — no framework or database dependencies.
library;

import '../../../../core/database/app_database.dart';

/// Represents a single GPS measurement point during a trip.
class TripPointEntity {
  const TripPointEntity({
    this.id,
    required this.tripId,
    required this.latitude,
    required this.longitude,
    required this.speedKmh,
    required this.timestamp,
    this.accuracy = 0.0,
    this.altitude = 0.0,
  });

  final int? id;
  final int tripId;
  final double latitude;
  final double longitude;

  /// Speed in km/h at this point
  final double speedKmh;
  final double accuracy;
  final double altitude;
  final DateTime timestamp;

  factory TripPointEntity.fromDb(TripPointsTableData row) => TripPointEntity(
        id: row.id,
        tripId: row.tripId,
        latitude: row.latitude,
        longitude: row.longitude,
        speedKmh: row.speed,
        accuracy: row.accuracy,
        altitude: row.altitude,
        timestamp: row.timestamp,
      );
}

/// Represents a complete trip with metadata and route points.
class TripEntity {
  const TripEntity({
    this.id,
    this.title,
    required this.startTime,
    this.endTime,
    this.distanceMeters = 0.0,
    this.avgSpeedKmh = 0.0,
    this.maxSpeedKmh = 0.0,
    this.durationSeconds = 0,
    this.points = const [],
  });

  final int? id;
  final String? title;
  final DateTime startTime;
  final DateTime? endTime;

  /// Total distance in meters
  final double distanceMeters;

  /// Average speed in km/h
  final double avgSpeedKmh;

  /// Maximum speed in km/h
  final double maxSpeedKmh;

  final int durationSeconds;

  /// Route points
  final List<TripPointEntity> points;

  Duration get duration => Duration(seconds: durationSeconds);

  bool get isActive => endTime == null;

  factory TripEntity.fromDb(TripsTableData row,
          {List<TripPointEntity> points = const []}) =>
      TripEntity(
        id: row.id,
        title: row.title,
        startTime: row.startTime,
        endTime: row.endTime,
        distanceMeters: row.distance,
        avgSpeedKmh: row.avgSpeed,
        maxSpeedKmh: row.maxSpeed,
        durationSeconds: row.durationSeconds,
        points: points,
      );

  TripEntity copyWith({
    int? id,
    String? title,
    DateTime? startTime,
    DateTime? endTime,
    double? distanceMeters,
    double? avgSpeedKmh,
    double? maxSpeedKmh,
    int? durationSeconds,
    List<TripPointEntity>? points,
  }) {
    return TripEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      avgSpeedKmh: avgSpeedKmh ?? this.avgSpeedKmh,
      maxSpeedKmh: maxSpeedKmh ?? this.maxSpeedKmh,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      points: points ?? this.points,
    );
  }
}
