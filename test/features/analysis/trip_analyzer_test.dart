import 'package:flutter_test/flutter_test.dart';
import 'package:speedloop/features/analysis/domain/services/trip_analyzer.dart';
import 'package:speedloop/features/trip/domain/entities/trip_entity.dart';

void main() {
  final start = DateTime.utc(2026);

  TripPointEntity point(
    int index,
    double longitude, {
    double speed = 50,
    int secondsPerPoint = 1,
  }) =>
      TripPointEntity(
        tripId: 1,
        latitude: 0,
        longitude: longitude,
        speedKmh: speed,
        timestamp: start.add(Duration(seconds: index * secondsPerPoint)),
        accuracy: 5,
      );

  List<TripPointEntity> route(double meters, int intervals) {
    final degrees = meters / 111195.0;
    return List.generate(
      intervals + 1,
      (index) => point(index, degrees * index / intervals),
    );
  }

  test('segments equivalent routes by distance, not sample count', () {
    const analyzer = TripAnalyzer();
    final sparse = analyzer.buildSegments(route(2500, 5));
    final dense = analyzer.buildSegments(route(2500, 100));

    expect(sparse, hasLength(3));
    expect(dense, hasLength(3));
    for (final segments in [sparse, dense]) {
      expect(segments[0].distanceMeters, closeTo(1000, 0.1));
      expect(segments[1].distanceMeters, closeTo(1000, 0.1));
      expect(segments[2].distanceMeters, closeTo(500, 2));
    }
  });

  test('preserves the best completed acceleration after a later stop', () {
    final speeds = <double>[0, 30, 60, 100, 0, 20, 60, 80, 100, 0];
    final points = [
      for (var i = 0; i < speeds.length; i++)
        point(i, i * 0.0001, speed: speeds[i]),
    ];
    final result = const TripAnalyzer().analyze(
      TripEntity(
        id: 1,
        startTime: start,
        durationSeconds: 9,
        points: points,
      ),
    );

    expect(result.acceleration0to60, isNotNull);
    expect(result.acceleration0to100, isNotNull);
    expect(result.acceleration0to60!.seconds, 2);
    expect(result.acceleration0to100!.seconds, 3);
  });

  test('selects a faster later completed run', () {
    final points = [
      point(0, 0, speed: 0),
      point(1, 0.0001, speed: 30),
      point(2, 0.0002, speed: 60),
      point(3, 0.0003, speed: 100),
      point(4, 0.0004, speed: 0),
      TripPointEntity(
        tripId: 1,
        latitude: 0,
        longitude: 0.0005,
        speedKmh: 60,
        timestamp: start.add(const Duration(milliseconds: 4500)),
      ),
      point(5, 0.0006, speed: 100),
    ];
    final result = const TripAnalyzer().analyze(
      TripEntity(id: 1, startTime: start, points: points),
    );
    expect(result.acceleration0to60!.seconds, 0.5);
    expect(result.acceleration0to100!.seconds, 1);
  });

  test('handles empty and one-point trips', () {
    const analyzer = TripAnalyzer();
    final empty = analyzer.analyze(TripEntity(id: 1, startTime: start));
    expect(empty.segments, isEmpty);
    expect(empty.avgSpeedKmh, 0);
    expect(
      analyzer.buildSegments([point(0, 0)]),
      isEmpty,
    );
  });
}
