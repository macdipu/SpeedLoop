import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:speedloop/core/services/gps_quality_filter.dart';

void main() {
  Position position({
    required double latitude,
    required double longitude,
    required DateTime timestamp,
    double accuracy = 5,
    double speed = 10,
  }) =>
      Position(
        latitude: latitude,
        longitude: longitude,
        timestamp: timestamp,
        accuracy: accuracy,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: speed,
        speedAccuracy: 0,
      );

  final start = DateTime.utc(2026);

  test('rejects stationary drift inside the accuracy envelope', () {
    final filter = GpsQualityFilter();
    expect(
      filter
          .evaluate(position(latitude: 0, longitude: 0, timestamp: start))
          .accepted,
      isTrue,
    );
    final result = filter.evaluate(
      position(
        latitude: 0,
        longitude: 0.00001,
        timestamp: start.add(const Duration(seconds: 2)),
        speed: 0,
      ),
    );
    expect(result.accepted, isFalse);
    expect(result.rejectionReason, GpsRejectionReason.stationaryDrift);
  });

  test('accepts plausible normal driving movement', () {
    final filter = GpsQualityFilter();
    filter.evaluate(position(latitude: 0, longitude: 0, timestamp: start));
    final result = filter.evaluate(
      position(
        latitude: 0,
        longitude: 0.001,
        timestamp: start.add(const Duration(seconds: 5)),
        speed: 22,
      ),
    );
    expect(result.accepted, isTrue);
    expect(result.distanceMeters, closeTo(111.2, 1));
  });

  test('rejects poor accuracy, teleport, duplicate and stale samples', () {
    final poor = GpsQualityFilter().evaluate(
      position(
        latitude: 0,
        longitude: 0,
        timestamp: start,
        accuracy: 80,
      ),
    );
    expect(poor.rejectionReason, GpsRejectionReason.poorAccuracy);

    final filter = GpsQualityFilter();
    filter.evaluate(position(latitude: 0, longitude: 0, timestamp: start));
    expect(
      filter
          .evaluate(
            position(
              latitude: 1,
              longitude: 1,
              timestamp: start.add(const Duration(seconds: 1)),
            ),
          )
          .rejectionReason,
      GpsRejectionReason.implausibleJump,
    );
    expect(
      filter
          .evaluate(position(latitude: 0, longitude: 0.001, timestamp: start))
          .rejectionReason,
      GpsRejectionReason.staleTimestamp,
    );
    expect(
      filter
          .evaluate(
            position(
              latitude: 0,
              longitude: 0.001,
              timestamp: start.subtract(const Duration(seconds: 1)),
            ),
          )
          .rejectionReason,
      GpsRejectionReason.staleTimestamp,
    );
  });

  test('rejects impossible reported vehicle speed', () {
    final result = GpsQualityFilter().evaluate(
      position(
        latitude: 0,
        longitude: 0,
        timestamp: start,
        speed: 100,
      ),
    );
    expect(result.rejectionReason, GpsRejectionReason.impossibleReportedSpeed);
  });
}
