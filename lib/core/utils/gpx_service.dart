/// GPX Service
/// Handles import and export of GPX (GPS Exchange Format) files.
/// Supports reading GPX track points and exporting trips as GPX.

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart';
import 'package:share_plus/share_plus.dart';

import 'package:speedloop/features/trip/domain/entities/trip_entity.dart';

class GpxService {
  GpxService._();

  // --------------------------------------------------------------------------
  // Export
  // --------------------------------------------------------------------------

  /// Exports a [TripEntity] as a GPX file and returns the file path.
  static Future<String> exportTrip(TripEntity trip) async {
    final gpx = _buildGpx(trip);
    final dir = await getApplicationDocumentsDirectory();
    final file = File(
        '${dir.path}/trip_${trip.id}_${trip.startTime.millisecondsSinceEpoch}.gpx');
    await file.writeAsString(gpx);
    return file.path;
  }

  /// Export and share via system share sheet.
  static Future<void> shareTrip(TripEntity trip) async {
    final path = await exportTrip(trip);
    await Share.shareXFiles([XFile(path)], text: 'GPS Trip Export');
  }

  static String _buildGpx(TripEntity trip) {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element('gpx', attributes: {
      'version': '1.1',
      'creator': 'SpeedLoop - chowdhuryelab',
      'xmlns': 'http://www.topografix.com/GPX/1/1',
    }, nest: () {
      builder.element('metadata', nest: () {
        builder.element('name',
            nest: trip.title ?? 'Trip ${trip.id}');
        builder.element('time',
            nest: trip.startTime.toIso8601String());
      });
      builder.element('trk', nest: () {
        builder.element('name',
            nest: trip.title ?? 'Trip ${trip.id}');
        builder.element('trkseg', nest: () {
          for (final point in trip.points) {
            builder.element('trkpt', attributes: {
              'lat': point.latitude.toString(),
              'lon': point.longitude.toString(),
            }, nest: () {
              builder.element('ele',
                  nest: point.altitude.toString());
              builder.element('time',
                  nest: point.timestamp.toIso8601String());
              builder.element('extensions', nest: () {
                builder.element('speed',
                    nest: point.speedKmh.toString());
              });
            });
          }
        });
      });
    });
    return builder.buildDocument().toString();
  }

  // --------------------------------------------------------------------------
  // Import
  // --------------------------------------------------------------------------

  /// Parses a GPX file and returns a list of TripPointEntity-like maps.
  /// Returns list of {lat, lon, ele, time, speed}.
  static Future<List<Map<String, dynamic>>> importGpx(String filePath) async {
    final file = File(filePath);
    if (!file.existsSync()) throw Exception('File not found: $filePath');

    final content = await file.readAsString();
    final document = XmlDocument.parse(content);

    final trkpts = document.findAllElements('trkpt');
    final points = <Map<String, dynamic>>[];

    for (final trkpt in trkpts) {
      final lat = double.tryParse(trkpt.getAttribute('lat') ?? '') ?? 0.0;
      final lon = double.tryParse(trkpt.getAttribute('lon') ?? '') ?? 0.0;
      final ele = double.tryParse(
              trkpt.findElements('ele').firstOrNull?.innerText ?? '') ??
          0.0;
      final timeStr =
          trkpt.findElements('time').firstOrNull?.innerText ?? '';
      final time = DateTime.tryParse(timeStr) ?? DateTime.now();
      final speedEl = trkpt.findAllElements('speed').firstOrNull;
      final speed = double.tryParse(speedEl?.innerText ?? '') ?? 0.0;

      points.add({
        'lat': lat,
        'lon': lon,
        'ele': ele,
        'time': time,
        'speed': speed,
      });
    }

    return points;
  }
}
