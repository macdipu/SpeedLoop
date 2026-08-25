import 'dart:math' as math;

import 'package:geolocator/geolocator.dart';

import '../utils/gps_utils.dart';

/// Tunable quality limits for vehicle-oriented GPS recording.
class GpsQualityConfig {
  const GpsQualityConfig({
    this.maxHorizontalAccuracyMeters = 40,
    this.maxReportedSpeedMetersPerSecond = 75,
    this.maxDerivedSpeedMetersPerSecond = 75,
    this.minimumMovementMeters = 3,
    this.accuracyMovementFactor = 0.25,
    this.maxAccuracyMovementAllowanceMeters = 10,
  });

  final double maxHorizontalAccuracyMeters;
  final double maxReportedSpeedMetersPerSecond;
  final double maxDerivedSpeedMetersPerSecond;
  final double minimumMovementMeters;
  final double accuracyMovementFactor;
  final double maxAccuracyMovementAllowanceMeters;
}

enum GpsRejectionReason {
  invalidCoordinates,
  poorAccuracy,
  staleTimestamp,
  impossibleReportedSpeed,
  implausibleJump,
  stationaryDrift,
}

class GpsQualityResult {
  const GpsQualityResult.accepted({required this.distanceMeters})
      : accepted = true,
        rejectionReason = null;

  const GpsQualityResult.rejected(this.rejectionReason)
      : accepted = false,
        distanceMeters = 0;

  final bool accepted;
  final double distanceMeters;
  final GpsRejectionReason? rejectionReason;
}

/// Stateful filter. Create one instance per trip so samples never leak between
/// recording sessions. Distance inside the combined accuracy envelope is
/// treated as stationary drift rather than real travel.
class GpsQualityFilter {
  GpsQualityFilter({this.config = const GpsQualityConfig()});

  final GpsQualityConfig config;
  Position? _lastAccepted;

  Position? get lastAccepted => _lastAccepted;

  void reset() => _lastAccepted = null;

  /// Restores the last durably persisted sample after a worker restart.
  void seed(Position position) => _lastAccepted = position;

  GpsQualityResult evaluate(Position position) {
    if (!position.latitude.isFinite ||
        !position.longitude.isFinite ||
        position.latitude.abs() > 90 ||
        position.longitude.abs() > 180) {
      return const GpsQualityResult.rejected(
        GpsRejectionReason.invalidCoordinates,
      );
    }
    if (!position.accuracy.isFinite ||
        position.accuracy < 0 ||
        position.accuracy > config.maxHorizontalAccuracyMeters) {
      return const GpsQualityResult.rejected(GpsRejectionReason.poorAccuracy);
    }
    if (position.speed.isFinite &&
        position.speed > config.maxReportedSpeedMetersPerSecond) {
      return const GpsQualityResult.rejected(
        GpsRejectionReason.impossibleReportedSpeed,
      );
    }

    final previous = _lastAccepted;
    if (previous == null) {
      _lastAccepted = position;
      return const GpsQualityResult.accepted(distanceMeters: 0);
    }

    final elapsedSeconds =
        position.timestamp.difference(previous.timestamp).inMilliseconds /
            1000.0;
    if (elapsedSeconds <= 0) {
      return const GpsQualityResult.rejected(GpsRejectionReason.staleTimestamp);
    }

    final distance = GpsUtils.haversineDistance(
      previous.latitude,
      previous.longitude,
      position.latitude,
      position.longitude,
    );
    final uncertainty = previous.accuracy + position.accuracy;
    final effectiveDistance = math.max(0.0, distance - uncertainty);
    if (effectiveDistance / elapsedSeconds >
        config.maxDerivedSpeedMetersPerSecond) {
      return const GpsQualityResult.rejected(
          GpsRejectionReason.implausibleJump);
    }

    final movementThreshold = math.max(
      config.minimumMovementMeters,
      math.min(
        config.maxAccuracyMovementAllowanceMeters,
        uncertainty * config.accuracyMovementFactor,
      ),
    );
    if (distance < movementThreshold) {
      return const GpsQualityResult.rejected(
          GpsRejectionReason.stationaryDrift);
    }

    _lastAccepted = position;
    return GpsQualityResult.accepted(distanceMeters: distance);
  }
}
