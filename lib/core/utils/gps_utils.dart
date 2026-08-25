/// GPS Utilities
/// Provides helpers for GPS-based calculations:
///   - Speed unit conversion (m/s → km/h, mph)
///   - Haversine distance calculation
///   - Position stream configuration
library;

import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';

/// Supported speed units
enum SpeedUnit { kmh, mph }

class GpsUtils {
  GpsUtils._();

  // --------------------------------------------------------------------------
  // Speed Conversion
  // --------------------------------------------------------------------------

  /// Convert meters per second to km/h
  static double msToKmh(double ms) => ms * 3.6;

  /// Convert meters per second to mph
  static double msToMph(double ms) => ms * 2.23694;

  /// Convert km/h to mph
  static double kmhToMph(double kmh) => kmh * 0.621371;

  /// Convert mph to km/h
  static double mphToKmh(double mph) => mph * 1.60934;

  /// Convert a speed in m/s to display unit
  static double convertSpeed(double speedMs, SpeedUnit unit) {
    switch (unit) {
      case SpeedUnit.kmh:
        return msToKmh(speedMs);
      case SpeedUnit.mph:
        return msToMph(speedMs);
    }
  }

  // --------------------------------------------------------------------------
  // Haversine Distance
  // --------------------------------------------------------------------------

  static const double _earthRadiusMeters = 6371000.0;

  /// Calculates the great-circle distance between two lat/lon points in meters.
  static double haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(lat1)) *
            math.cos(_toRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return _earthRadiusMeters * c;
  }

  static double _toRad(double deg) => deg * (math.pi / 180.0);

  // --------------------------------------------------------------------------
  // Geolocator Configuration
  // --------------------------------------------------------------------------

  /// Location settings optimised for real-time GPS tracking.
  static const LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.bestForNavigation,
    distanceFilter: 0, // receive every update
  );

  /// Request location permissions and throw if denied.
  static Future<void> ensurePermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }
  }

  // --------------------------------------------------------------------------
  // Helpers
  // --------------------------------------------------------------------------

  /// Returns a safe speed value (0.0 if negative from GPS noise).
  static double sanitizeSpeed(double speedMs) => speedMs < 0 ? 0.0 : speedMs;

  /// Calculates bearing between two points in degrees (0-360).
  static double bearing(double lat1, double lon1, double lat2, double lon2) {
    final dLon = _toRad(lon2 - lon1);
    final y = math.sin(dLon) * math.cos(_toRad(lat2));
    final x = math.cos(_toRad(lat1)) * math.sin(_toRad(lat2)) -
        math.sin(_toRad(lat1)) * math.cos(_toRad(lat2)) * math.cos(dLon);
    return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
  }
}
