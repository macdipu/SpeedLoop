/// GPX Utils
/// Handles reading and writing standard GPX XML files.
library;

import 'dart:io';
import 'package:xml/xml.dart';
import '../../features/trip/domain/entities/trip_entity.dart';

class GpxUtils {
  /// Converts a TripEntity into a GPX string.
  static String generateGpx(TripEntity trip) {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');

    builder.element('gpx', attributes: {
      'version': '1.1',
      'creator': 'SpeedLoop - Chowdhury eLab',
      'xmlns': 'http://www.topografix.com/GPX/1/1',
      'xmlns:xsi': 'http://www.w3.org/2001/XMLSchema-instance',
      'xsi:schemaLocation':
          'http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd',
    }, nest: () {
      builder.element('metadata', nest: () {
        builder.element('time', nest: trip.startTime.toUtc().toIso8601String());
        builder.element('name', nest: trip.title ?? 'Recorded Trip');
      });

      builder.element('trk', nest: () {
        builder.element('name', nest: trip.title ?? 'Track');
        builder.element('trkseg', nest: () {
          for (final point in trip.points) {
            builder.element('trkpt', attributes: {
              'lat': point.latitude.toString(),
              'lon': point.longitude.toString(),
            }, nest: () {
              builder.element('ele', nest: point.altitude.toString());
              builder.element('time',
                  nest: point.timestamp.toUtc().toIso8601String());
              builder.element('extensions', nest: () {
                builder.element('speed_kmh', nest: point.speedKmh.toString());
              });
            });
          }
        });
      });
    });

    final doc = builder.buildDocument();
    return doc.toXmlString(pretty: true, indent: '  ');
  }

  /// Parses a GPX file into a list of generic TripPoints + start Time
  static Future<TripEntity?> parseGpx(File file) async {
    try {
      final text = await file.readAsString();
      final doc = XmlDocument.parse(text);

      final trkpts = doc.findAllElements('trkpt');
      if (trkpts.isEmpty) return null;

      final points = <TripPointEntity>[];
      DateTime? startTime;

      for (final pt in trkpts) {
        final latStr = pt.getAttribute('lat');
        final lonStr = pt.getAttribute('lon');
        if (latStr == null || lonStr == null) continue;

        final lat = double.tryParse(latStr);
        final lon = double.tryParse(lonStr);
        if (lat == null ||
            lon == null ||
            !lat.isFinite ||
            !lon.isFinite ||
            lat.abs() > 90 ||
            lon.abs() > 180) {
          continue;
        }

        // Elevation
        final eleNode = pt.findElements('ele');
        final ele = eleNode.isNotEmpty
            ? double.tryParse(eleNode.first.innerText) ?? 0.0
            : 0.0;

        // Time
        final timeNode = pt.findElements('time');
        DateTime time;
        if (timeNode.isNotEmpty) {
          time = DateTime.tryParse(timeNode.first.innerText) ?? DateTime.now();
        } else {
          time = DateTime.now(); // Fallback
        }

        startTime ??= time;

        // Try getting extended speed if exported by this app
        double speed = 0.0;
        final extNode = pt.findElements('extensions');
        if (extNode.isNotEmpty) {
          final spdNode = extNode.first.findElements('speed_kmh');
          if (spdNode.isNotEmpty) {
            speed = double.tryParse(spdNode.first.innerText) ?? 0.0;
          }
        }

        points.add(TripPointEntity(
          tripId: 0, // Assigned later
          latitude: lat,
          longitude: lon,
          altitude: ele,
          timestamp: time,
          speedKmh: speed,
          accuracy: 0.0,
        ));
      }

      if (points.isEmpty) return null;

      // Calculate minimal stats from points
      final endTime = points.last.timestamp;
      final duration = endTime.difference(startTime!).inSeconds;

      return TripEntity(
        title: 'Imported Trip',
        startTime: startTime,
        endTime: endTime,
        distanceMeters: 0, // Recalculated dynamically if needed
        durationSeconds: duration,
        maxSpeedKmh: 0,
        avgSpeedKmh: 0,
        points: points,
      );
    } catch (e) {
      return null;
    }
  }
}
