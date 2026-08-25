/// Analysis Feature — Domain Entity
/// Holds computed statistics for a trip analysis session.
library;

/// Result of a 0→N km/h acceleration event
class AccelerationEvent {
  const AccelerationEvent({
    required this.targetKmh,
    required this.seconds,
    required this.startIndex,
    required this.endIndex,
  });
  final double targetKmh;
  final double seconds;
  final int startIndex;
  final int endIndex;
}

/// Statistics for one trip segment
class TripSegment {
  const TripSegment({
    required this.segmentNumber,
    required this.startIndex,
    required this.endIndex,
    required this.maxSpeedKmh,
    required this.avgSpeedKmh,
    required this.distanceMeters,
  });
  final int segmentNumber;
  final int startIndex;
  final int endIndex;
  final double maxSpeedKmh;
  final double avgSpeedKmh;
  final double distanceMeters;
}

/// Full analysis result for a trip
class TripAnalysisEntity {
  const TripAnalysisEntity({
    required this.tripId,
    required this.topSpeedKmh,
    required this.avgSpeedKmh,
    required this.totalDistanceMeters,
    required this.durationSeconds,
    this.acceleration0to60,
    this.acceleration0to100,
    this.segments = const [],
  });

  final int tripId;
  final double topSpeedKmh;
  final double avgSpeedKmh;
  final double totalDistanceMeters;
  final int durationSeconds;
  final AccelerationEvent? acceleration0to60;
  final AccelerationEvent? acceleration0to100;
  final List<TripSegment> segments;
}
