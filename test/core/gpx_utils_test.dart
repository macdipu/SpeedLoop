import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:speedloop/core/utils/gpx_utils.dart';
import 'package:speedloop/features/trip/domain/entities/trip_entity.dart';

void main() {
  late Directory directory;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('speedloop_gpx_test_');
  });
  tearDown(() async {
    await directory.delete(recursive: true);
  });

  test('export-import round trip preserves route fields', () async {
    final start = DateTime.utc(2026, 1, 2, 3, 4, 5);
    final trip = TripEntity(
      id: 1,
      title: 'Round trip',
      startTime: start,
      points: [
        TripPointEntity(
          tripId: 1,
          latitude: 23.7,
          longitude: 90.4,
          speedKmh: 35.5,
          altitude: 12,
          timestamp: start,
        ),
        TripPointEntity(
          tripId: 1,
          latitude: 23.701,
          longitude: 90.401,
          speedKmh: 42,
          altitude: 13,
          timestamp: start.add(const Duration(seconds: 5)),
        ),
      ],
    );
    final file = File('${directory.path}/roundtrip.gpx');
    await file.writeAsString(GpxUtils.generateGpx(trip));

    final imported = await GpxUtils.parseGpx(file);
    expect(imported, isNotNull);
    expect(imported!.points, hasLength(2));
    expect(imported.points.first.latitude, 23.7);
    expect(imported.points.first.speedKmh, 35.5);
    expect(
        imported.points.last.timestamp, start.add(const Duration(seconds: 5)));
  });

  test('malformed and point-free GPX return null', () async {
    final malformed = File('${directory.path}/malformed.gpx');
    await malformed.writeAsString('<gpx><trkpt');
    expect(await GpxUtils.parseGpx(malformed), isNull);

    final empty = File('${directory.path}/empty.gpx');
    await empty.writeAsString('<gpx version="1.1"><trk/></gpx>');
    expect(await GpxUtils.parseGpx(empty), isNull);
  });

  test('missing optional elevation, time and speed are handled', () async {
    final file = File('${directory.path}/missing.gpx');
    await file.writeAsString(
      '<gpx version="1.1"><trk><trkseg>'
      '<trkpt lat="23.0" lon="90.0"/>'
      '</trkseg></trk></gpx>',
    );
    final imported = await GpxUtils.parseGpx(file);
    expect(imported, isNotNull);
    expect(imported!.points.single.altitude, 0);
    expect(imported.points.single.speedKmh, 0);
  });

  test('invalid coordinates do not silently become zero', () async {
    final file = File('${directory.path}/invalid.gpx');
    await file.writeAsString(
      '<gpx version="1.1"><trk><trkseg>'
      '<trkpt lat="invalid" lon="90.0"/>'
      '</trkseg></trk></gpx>',
    );
    expect(await GpxUtils.parseGpx(file), isNull);
  });
}
