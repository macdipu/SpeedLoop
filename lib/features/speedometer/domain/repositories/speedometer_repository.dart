/// Speedometer Repository Interface (Domain Layer)
/// Defines the contract for GPS data sourcing.
/// Implementations live in the data layer.
library;

import 'package:geolocator/geolocator.dart';

abstract class SpeedometerRepository {
  /// Stream of Position updates from GPS sensor
  Stream<Position> get positionStream;

  /// One-shot current position
  Future<Position?> getCurrentPosition();
}
