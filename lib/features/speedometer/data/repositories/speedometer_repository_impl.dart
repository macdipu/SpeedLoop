/// Speedometer Repository Implementation (Data Layer)
/// Wraps geolocator position stream.
library;

import 'package:geolocator/geolocator.dart';

import '../../../../core/utils/gps_utils.dart';
import '../../domain/repositories/speedometer_repository.dart';

class SpeedometerRepositoryImpl implements SpeedometerRepository {
  @override
  Stream<Position> get positionStream =>
      Geolocator.getPositionStream(locationSettings: GpsUtils.locationSettings);

  @override
  Future<Position?> getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition();
    } catch (_) {
      return null;
    }
  }
}
