library;

import '../../domain/entities/trip_entity.dart';

class TripHistoryInsights {
  const TripHistoryInsights({
    required this.tripCount,
    required this.totalDistanceMeters,
    required this.totalDuration,
    required this.topSpeedKmh,
  });

  final int tripCount;
  final double totalDistanceMeters;
  final Duration totalDuration;
  final double topSpeedKmh;
}

class TripHistoryInsightsBuilder {
  const TripHistoryInsightsBuilder();

  TripHistoryInsights build(List<TripEntity> trips) {
    var totalDistanceMeters = 0.0;
    var totalDurationSeconds = 0;
    var topSpeedKmh = 0.0;

    for (final trip in trips) {
      totalDistanceMeters += trip.distanceMeters;
      totalDurationSeconds += trip.durationSeconds;
      if (trip.maxSpeedKmh > topSpeedKmh) {
        topSpeedKmh = trip.maxSpeedKmh;
      }
    }

    return TripHistoryInsights(
      tripCount: trips.length,
      totalDistanceMeters: totalDistanceMeters,
      totalDuration: Duration(seconds: totalDurationSeconds),
      topSpeedKmh: topSpeedKmh,
    );
  }
}
