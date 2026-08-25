import 'dart:math' as math;

import '../../../../core/utils/gps_utils.dart';
import '../../../trip/domain/entities/trip_entity.dart';
import '../entities/analysis_entity.dart';

class TripAnalyzer {
  const TripAnalyzer({this.segmentLengthMeters = 1000});

  final double segmentLengthMeters;

  TripAnalysisEntity analyze(TripEntity trip) {
    final points = trip.points;
    var topSpeed = 0.0;
    var totalSpeed = 0.0;
    AccelerationEvent? best60;
    AccelerationEvent? best100;
    int? attemptStart;
    var attemptCompleted60 = false;
    var attemptCompleted100 = false;

    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      topSpeed = math.max(topSpeed, point.speedKmh);
      totalSpeed += point.speedKmh;

      if (point.speedKmh < 2) {
        attemptStart = i;
        attemptCompleted60 = false;
        attemptCompleted100 = false;
        continue;
      }
      final start = attemptStart;
      if (start == null) continue;

      if (!attemptCompleted60 && point.speedKmh >= 60) {
        final candidate = _event(points, start, i, 60);
        if (candidate != null &&
            (best60 == null || candidate.seconds < best60.seconds)) {
          best60 = candidate;
        }
        attemptCompleted60 = true;
      }
      if (!attemptCompleted100 && point.speedKmh >= 100) {
        final candidate = _event(points, start, i, 100);
        if (candidate != null &&
            (best100 == null || candidate.seconds < best100.seconds)) {
          best100 = candidate;
        }
        attemptCompleted100 = true;
      }
    }

    return TripAnalysisEntity(
      tripId: trip.id ?? 0,
      topSpeedKmh: topSpeed,
      avgSpeedKmh: points.isEmpty ? 0 : totalSpeed / points.length,
      totalDistanceMeters: trip.distanceMeters,
      durationSeconds: trip.durationSeconds,
      acceleration0to60: best60,
      acceleration0to100: best100,
      segments: buildSegments(points),
    );
  }

  AccelerationEvent? _event(
    List<TripPointEntity> points,
    int start,
    int end,
    double target,
  ) {
    final seconds = points[end]
            .timestamp
            .difference(points[start].timestamp)
            .inMilliseconds /
        1000.0;
    if (seconds <= 0) return null;
    return AccelerationEvent(
      targetKmh: target,
      seconds: seconds,
      startIndex: start,
      endIndex: end,
    );
  }

  /// Splits geographic distance into ~1 km buckets. An edge crossing a
  /// boundary is proportionally allocated to both segments, avoiding the
  /// sample-frequency bias of assigning the entire edge to one side.
  List<TripSegment> buildSegments(List<TripPointEntity> points) {
    if (points.length < 2 || segmentLengthMeters <= 0) return const [];
    final segments = <TripSegment>[];
    var startIndex = 0;
    var distance = 0.0;
    var weightedSpeed = 0.0;
    var weight = 0.0;
    var maxSpeed = points.first.speedKmh;

    for (var i = 1; i < points.length; i++) {
      final previous = points[i - 1];
      final current = points[i];
      var remaining = GpsUtils.haversineDistance(
        previous.latitude,
        previous.longitude,
        current.latitude,
        current.longitude,
      );
      if (!remaining.isFinite || remaining <= 0) continue;
      final edgeSpeed = (previous.speedKmh + current.speedKmh) / 2;

      while (remaining > 0) {
        final capacity = segmentLengthMeters - distance;
        final allocated = math.min(remaining, capacity);
        distance += allocated;
        weightedSpeed += edgeSpeed * allocated;
        weight += allocated;
        maxSpeed = math.max(maxSpeed, current.speedKmh);
        remaining -= allocated;

        if (distance >= segmentLengthMeters - 0.001) {
          segments.add(
            TripSegment(
              segmentNumber: segments.length + 1,
              startIndex: startIndex,
              endIndex: i,
              maxSpeedKmh: maxSpeed,
              avgSpeedKmh: weight == 0 ? 0 : weightedSpeed / weight,
              distanceMeters: distance,
            ),
          );
          startIndex = i - 1;
          distance = 0;
          weightedSpeed = 0;
          weight = 0;
          maxSpeed = math.max(previous.speedKmh, current.speedKmh);
        }
      }
    }

    if (distance > 0) {
      segments.add(
        TripSegment(
          segmentNumber: segments.length + 1,
          startIndex: startIndex,
          endIndex: points.length - 1,
          maxSpeedKmh: maxSpeed,
          avgSpeedKmh: weight == 0 ? 0 : weightedSpeed / weight,
          distanceMeters: distance,
        ),
      );
    }
    return segments;
  }
}
