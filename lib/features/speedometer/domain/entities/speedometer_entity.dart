/// Speedometer Feature — Domain Layer
/// Entity representing the current speedometer state.
library;

import '../../../../../../core/utils/gps_utils.dart';

/// Immutable entity representing the current speed reading.
class SpeedometerEntity {
  const SpeedometerEntity({
    required this.speedMs,
    required this.unit,
    this.maxSpeed = 0.0,
    this.accuracy = 0.0,
    this.altitude = 0.0,
    this.latitude,
    this.longitude,
    this.heading = 0.0,
    this.timestamp,
  });

  /// Raw speed in meters per second from GPS
  final double speedMs;

  /// Display unit (km/h or mph)
  final SpeedUnit unit;

  /// Maximum speed recorded in the session (in display unit)
  final double maxSpeed;

  /// GPS accuracy in meters
  final double accuracy;

  /// Altitude in meters
  final double altitude;

  final double? latitude;
  final double? longitude;

  /// Heading in degrees (0 = North)
  final double heading;

  final DateTime? timestamp;

  /// Speed converted to the chosen display unit
  double get displaySpeed => GpsUtils.convertSpeed(speedMs, unit);

  /// Unit label string
  String get unitLabel => unit == SpeedUnit.kmh ? 'km/h' : 'mph';

  SpeedometerEntity copyWith({
    double? speedMs,
    SpeedUnit? unit,
    double? maxSpeed,
    double? accuracy,
    double? altitude,
    double? latitude,
    double? longitude,
    double? heading,
    DateTime? timestamp,
  }) {
    return SpeedometerEntity(
      speedMs: speedMs ?? this.speedMs,
      unit: unit ?? this.unit,
      maxSpeed: maxSpeed ?? this.maxSpeed,
      accuracy: accuracy ?? this.accuracy,
      altitude: altitude ?? this.altitude,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      heading: heading ?? this.heading,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  static SpeedometerEntity empty() => const SpeedometerEntity(
        speedMs: 0.0,
        unit: SpeedUnit.kmh,
      );
}
