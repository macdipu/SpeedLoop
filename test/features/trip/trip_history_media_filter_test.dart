import 'package:flutter_test/flutter_test.dart';
import 'package:speedloop/features/trip/domain/entities/trip_entity.dart';
import 'package:speedloop/features/trip/domain/services/trip_history_media_filter.dart';

void main() {
  const service = TripHistoryMediaFilterService();

  final trips = [
    TripEntity(id: 1, startTime: DateTime.utc(2026, 1, 1)),
    TripEntity(id: 2, startTime: DateTime.utc(2026, 1, 2)),
    TripEntity(id: 3, startTime: DateTime.utc(2026, 1, 3)),
  ];

  test('all filter returns every trip', () {
    final filtered = service.apply(
      trips: trips,
      clipCounts: const {2: 1},
      protectedClipCounts: const {3: 1},
      filter: TripHistoryMediaFilter.all,
    );

    expect(filtered.map((trip) => trip.id), [1, 2, 3]);
  });

  test('with clips filter keeps only trips with any linked clip', () {
    final filtered = service.apply(
      trips: trips,
      clipCounts: const {2: 2, 3: 1},
      protectedClipCounts: const {},
      filter: TripHistoryMediaFilter.withClips,
    );

    expect(filtered.map((trip) => trip.id), [2, 3]);
  });

  test('incidents filter keeps only trips with protected clips', () {
    final filtered = service.apply(
      trips: trips,
      clipCounts: const {2: 2, 3: 1},
      protectedClipCounts: const {3: 1},
      filter: TripHistoryMediaFilter.incidents,
    );

    expect(filtered.map((trip) => trip.id), [3]);
  });
}
