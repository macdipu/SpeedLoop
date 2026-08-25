import 'package:flutter_test/flutter_test.dart';
import 'package:speedloop/features/trip/domain/entities/trip_entity.dart';
import 'package:speedloop/features/trip/domain/services/trip_history_insights.dart';

void main() {
  const builder = TripHistoryInsightsBuilder();

  test('aggregates trip count, distance, duration, and top speed', () {
    final insights = builder.build([
      TripEntity(
        startTime: DateTime.utc(2026, 1, 1),
        distanceMeters: 1200,
        durationSeconds: 180,
        maxSpeedKmh: 48,
      ),
      TripEntity(
        startTime: DateTime.utc(2026, 1, 2),
        distanceMeters: 3400,
        durationSeconds: 420,
        maxSpeedKmh: 73,
      ),
    ]);

    expect(insights.tripCount, 2);
    expect(insights.totalDistanceMeters, 4600);
    expect(insights.totalDuration, const Duration(minutes: 10));
    expect(insights.topSpeedKmh, 73);
  });

  test('returns zeroed insights for an empty history', () {
    final insights = builder.build(const []);

    expect(insights.tripCount, 0);
    expect(insights.totalDistanceMeters, 0);
    expect(insights.totalDuration, Duration.zero);
    expect(insights.topSpeedKmh, 0);
  });
}
