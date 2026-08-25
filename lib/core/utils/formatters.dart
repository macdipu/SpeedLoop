/// Formatters
/// Utility functions for formatting speed, distance, duration, and time
/// for display in the UI.
library;

class Formatters {
  Formatters._();

  // --------------------------------------------------------------------------
  // Speed
  // --------------------------------------------------------------------------

  /// Format speed with one decimal place and unit suffix.
  /// e.g., 72.4 km/h  or  45.0 mph
  static String speed(double speed, String unit) =>
      '${speed.toStringAsFixed(1)} $unit';

  /// Format speed as integer (cleaner for digital display).
  static String speedInt(double speed) => speed.toStringAsFixed(0);

  // --------------------------------------------------------------------------
  // Distance
  // --------------------------------------------------------------------------

  /// Format distance in meters to a human-readable string.
  /// < 1000 m → "950 m"
  /// >= 1000 m → "12.34 km"
  static String distance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(2)} km';
    }
  }

  /// Distance in miles
  static String distanceMiles(double meters) {
    final miles = meters / 1609.344;
    return '${miles.toStringAsFixed(2)} mi';
  }

  // --------------------------------------------------------------------------
  // Duration
  // --------------------------------------------------------------------------

  /// Format duration as HH:MM:SS
  static String duration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  /// Format duration as short human-readable string
  /// e.g., "1h 23m" or "45m 12s"
  static String durationShort(Duration d) {
    if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    } else if (d.inMinutes > 0) {
      return '${d.inMinutes}m ${d.inSeconds.remainder(60)}s';
    } else {
      return '${d.inSeconds}s';
    }
  }

  // --------------------------------------------------------------------------
  // DateTime
  // --------------------------------------------------------------------------

  /// Format DateTime as "16 Mar 2026"
  static String date(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  /// Format DateTime as "13:45:02"
  static String time(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  /// Format DateTime as "16 Mar 2026  13:45"
  static String dateTime(DateTime dt) => '${date(dt)}  ${time(dt)}';
}
