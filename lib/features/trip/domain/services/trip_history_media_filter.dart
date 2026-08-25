library;

import '../entities/trip_entity.dart';

enum TripHistoryMediaFilter { all, withClips, incidents }

class TripHistoryMediaFilterService {
  const TripHistoryMediaFilterService();

  List<TripEntity> apply({
    required List<TripEntity> trips,
    required Map<int, int> clipCounts,
    required Map<int, int> protectedClipCounts,
    required TripHistoryMediaFilter filter,
  }) {
    switch (filter) {
      case TripHistoryMediaFilter.all:
        return trips;
      case TripHistoryMediaFilter.withClips:
        return trips
            .where((trip) => (clipCounts[trip.id] ?? 0) > 0)
            .toList(growable: false);
      case TripHistoryMediaFilter.incidents:
        return trips
            .where((trip) => (protectedClipCounts[trip.id] ?? 0) > 0)
            .toList(growable: false);
    }
  }
}
