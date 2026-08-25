import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:drift/drift.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/app_database.dart';
import 'gps_quality_filter.dart';
import 'ordered_async_queue.dart';

const _activeTripIdKey = 'recording_active_trip_id';
const _activeTripStartKey = 'recording_active_trip_start';
const _notificationTitle = 'SpeedLoop — Trip recording';
const _notificationText = 'Location recording is active';

class RecordedPosition {
  const RecordedPosition({
    required this.tripId,
    required this.latitude,
    required this.longitude,
    required this.speedKmh,
    required this.altitude,
    required this.accuracy,
    required this.timestamp,
    required this.distanceMeters,
  });

  final int tripId;
  final double latitude;
  final double longitude;
  final double speedKmh;
  final double altitude;
  final double accuracy;
  final DateTime timestamp;
  final double distanceMeters;

  factory RecordedPosition.fromMap(Map<String, dynamic> map) =>
      RecordedPosition(
        tripId: map['trip_id'] as int,
        latitude: (map['lat'] as num).toDouble(),
        longitude: (map['lng'] as num).toDouble(),
        speedKmh: (map['speed_kmh'] as num).toDouble(),
        altitude: (map['altitude'] as num).toDouble(),
        accuracy: (map['accuracy'] as num).toDouble(),
        timestamp: DateTime.parse(map['timestamp'] as String),
        distanceMeters: (map['distance_m'] as num).toDouble(),
      );
}

class LocationRecordingException implements Exception {
  const LocationRecordingException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract class TripLocationService {
  Stream<RecordedPosition> get positions;
  Stream<String> get errors;
  Future<void> ensurePermissions();
  Future<void> startService({
    required int tripId,
    required DateTime startTime,
  });
  Future<void> stopService({required int tripId});
  Future<({int tripId, DateTime startTime, bool serviceRunning})?>
      activeSession();
}

/// Owns the single platform worker used for trip location and point writes.
class BackgroundLocationService implements TripLocationService {
  BackgroundLocationService({FlutterBackgroundService? service})
      : _service = service ?? FlutterBackgroundService();

  final FlutterBackgroundService _service;
  static Future<void>? _initialization;

  static bool get _isSupportedPlatform => Platform.isAndroid || Platform.isIOS;

  @override
  Stream<RecordedPosition> get positions => _isSupportedPlatform
      ? _service
          .on('position')
          .where((event) => event != null)
          .map((event) => RecordedPosition.fromMap(event!))
      : const Stream<RecordedPosition>.empty();

  @override
  Stream<String> get errors => _isSupportedPlatform
      ? _service
          .on('recordingError')
          .where((event) => event?['message'] != null)
          .map((event) => event!['message'] as String)
      : const Stream<String>.empty();

  static Future<void> init() async {
    final existing = _initialization;
    if (existing != null) return existing;
    final future = _configure();
    _initialization = future;
    try {
      await future;
    } catch (_) {
      if (identical(_initialization, future)) _initialization = null;
      rethrow;
    }
  }

  static Future<void> _configure() async {
    if (!_isSupportedPlatform) return;
    final service = FlutterBackgroundService();
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onLocationWorkerStart,
        autoStart: false,
        autoStartOnBoot: false,
        isForegroundMode: true,
        initialNotificationTitle: _notificationTitle,
        initialNotificationContent: _notificationText,
        foregroundServiceNotificationId: 2401,
        foregroundServiceTypes: const [AndroidForegroundType.location],
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onLocationWorkerStart,
        onBackground: onIosBackgroundFetch,
      ),
    );
  }

  @override
  Future<void> ensurePermissions() async {
    if (!_isSupportedPlatform) {
      throw const LocationRecordingException(
        'Background trip recording is available only on Android and iOS.',
      );
    }
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationRecordingException('Location services are disabled.');
    }

    var location = await Geolocator.checkPermission();
    if (location == LocationPermission.denied) {
      location = await Geolocator.requestPermission();
    }
    if (location == LocationPermission.denied) {
      throw const LocationRecordingException('Location permission was denied.');
    }
    if (location == LocationPermission.deniedForever) {
      throw const LocationRecordingException(
        'Location permission is permanently denied. Enable it in Settings.',
      );
    }
    if (Platform.isIOS && location != LocationPermission.always) {
      throw const LocationRecordingException(
        'Set location access to Always in iOS Settings to record trips in the background.',
      );
    }
    if (Platform.isAndroid) {
      var notification = await Permission.notification.status;
      if (!notification.isGranted) {
        notification = await Permission.notification.request();
      }
      if (!notification.isGranted) {
        throw const LocationRecordingException(
          'Notification permission is required to show the active trip recording.',
        );
      }
    }
  }

  @override
  Future<void> startService({
    required int tripId,
    required DateTime startTime,
  }) async {
    await init();
    await ensurePermissions();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_activeTripIdKey, tripId);
    await prefs.setString(_activeTripStartKey, startTime.toIso8601String());

    final started = Completer<void>();
    late final StreamSubscription<Map<String, dynamic>?> subscription;
    subscription = _service.on('trackingStarted').listen((event) {
      if (event?['trip_id'] == tripId && !started.isCompleted) {
        started.complete();
      }
    });
    try {
      if (!await _service.isRunning()) {
        if (!await _service.startService()) {
          throw const LocationRecordingException(
            'The background location service could not be started.',
          );
        }
      } else {
        _service.invoke('startTracking', {'trip_id': tripId});
      }
      await started.future.timeout(
        const Duration(seconds: 12),
        onTimeout: () => throw const LocationRecordingException(
          'Timed out while starting background trip recording.',
        ),
      );
    } catch (_) {
      await prefs.remove(_activeTripIdKey);
      await prefs.remove(_activeTripStartKey);
      rethrow;
    } finally {
      await subscription.cancel();
    }
  }

  @override
  Future<void> stopService({required int tripId}) async {
    if (!_isSupportedPlatform) {
      await _clearActiveSession();
      return;
    }
    if (!await _service.isRunning()) {
      await _clearActiveSession();
      return;
    }
    final stopped = Completer<bool>();
    late final StreamSubscription<Map<String, dynamic>?> subscription;
    subscription = _service.on('trackingStopped').listen((event) {
      if (event?['trip_id'] == tripId && !stopped.isCompleted) {
        stopped.complete(event?['had_errors'] == true);
      }
    });
    try {
      _service.invoke('stopTracking', {'trip_id': tripId});
      final hadErrors = await stopped.future.timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw const LocationRecordingException(
          'Timed out while flushing background location writes.',
        ),
      );
      if (hadErrors) {
        throw const LocationRecordingException(
          'One or more location points could not be saved.',
        );
      }
    } finally {
      await subscription.cancel();
      await _clearActiveSession();
    }
  }

  @override
  Future<({int tripId, DateTime startTime, bool serviceRunning})?>
      activeSession() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(_activeTripIdKey);
    final start = DateTime.tryParse(prefs.getString(_activeTripStartKey) ?? '');
    if (id == null || start == null) return null;
    return (
      tripId: id,
      startTime: start,
      serviceRunning: _isSupportedPlatform && await _service.isRunning(),
    );
  }

  Future<void> _clearActiveSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeTripIdKey);
    await prefs.remove(_activeTripStartKey);
  }
}

@pragma('vm:entry-point')
void onLocationWorkerStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  final worker = _LocationRecordingWorker(service);
  service.on('startTracking').listen((event) {
    final tripId = event?['trip_id'] as int?;
    if (tripId != null) unawaited(worker.start(tripId));
  });
  service.on('stopTracking').listen((event) {
    final tripId = event?['trip_id'] as int?;
    if (tripId != null) unawaited(worker.stop(tripId));
  });

  final prefs = await SharedPreferences.getInstance();
  final activeTripId = prefs.getInt(_activeTripIdKey);
  if (activeTripId != null) {
    await worker.start(activeTripId);
  } else {
    await service.stopSelf();
  }
}

@pragma('vm:entry-point')
Future<bool> onIosBackgroundFetch(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  // Continuous tracking is owned by Core Location's `location` background
  // mode. Background fetch is deliberately not presented as a recorder.
  return true;
}

class _LocationRecordingWorker {
  _LocationRecordingWorker(this.service);

  final ServiceInstance service;
  final GpsQualityFilter _filter = GpsQualityFilter();
  StreamSubscription<Position>? _positionSubscription;
  AppDatabase? _database;
  late OrderedAsyncQueue _writes;
  int? _tripId;
  bool _stopping = false;

  Future<void> start(int tripId) async {
    if (_tripId == tripId && _positionSubscription != null) {
      service.invoke('trackingStarted', {'trip_id': tripId});
      return;
    }
    if (_tripId != null) await stop(_tripId!, stopWorker: false);

    _tripId = tripId;
    _stopping = false;
    _filter.reset();
    _writes = OrderedAsyncQueue(
      onError: (error, _) {
        service.invoke('recordingError', {'message': error.toString()});
      },
    );
    _database = AppDatabase();
    final lastPoint = await _database!.tripPointDao.getLastPointForTrip(tripId);
    if (lastPoint != null) {
      _filter.seed(
        Position(
          latitude: lastPoint.latitude,
          longitude: lastPoint.longitude,
          timestamp: lastPoint.timestamp,
          accuracy: lastPoint.accuracy,
          altitude: lastPoint.altitude,
          altitudeAccuracy: 0,
          heading: 0,
          headingAccuracy: 0,
          speed: lastPoint.speed / 3.6,
          speedAccuracy: 0,
        ),
      );
    }
    final settings = Platform.isAndroid
        ? AndroidSettings(
            accuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: 0,
            intervalDuration: const Duration(seconds: 1),
          )
        : AppleSettings(
            accuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: 0,
            activityType: ActivityType.automotiveNavigation,
            pauseLocationUpdatesAutomatically: false,
            showBackgroundLocationIndicator: true,
            allowBackgroundLocationUpdates: true,
          );

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: settings,
    ).listen(_onPosition, onError: _onLocationError);
    service.invoke('trackingStarted', {'trip_id': tripId});
  }

  void _onPosition(Position position) {
    if (_stopping || _tripId == null) return;
    final quality = _filter.evaluate(position);
    if (!quality.accepted) return;
    final tripId = _tripId!;
    final speedKmh = (position.speed < 0 ? 0 : position.speed) * 3.6;
    _writes.add(() async {
      final database = _database;
      if (database == null) return;
      await database.tripPointDao.insertPoint(
        TripPointsTableCompanion.insert(
          tripId: tripId,
          latitude: position.latitude,
          longitude: position.longitude,
          speed: Value(speedKmh),
          accuracy: Value(position.accuracy),
          altitude: Value(position.altitude),
          timestamp: position.timestamp,
        ),
      );
      service.invoke('position', {
        'trip_id': tripId,
        'lat': position.latitude,
        'lng': position.longitude,
        'speed_kmh': speedKmh,
        'altitude': position.altitude,
        'accuracy': position.accuracy,
        'timestamp': position.timestamp.toIso8601String(),
        'distance_m': quality.distanceMeters,
      });
      if (service is AndroidServiceInstance) {
        (service as AndroidServiceInstance).setForegroundNotificationInfo(
          title: _notificationTitle,
          content: '${speedKmh.toStringAsFixed(1)} km/h • location active',
        );
      }
    });
  }

  void _onLocationError(Object error, StackTrace stackTrace) {
    service.invoke('recordingError', {'message': error.toString()});
  }

  Future<void> stop(int tripId, {bool stopWorker = true}) async {
    if (_tripId != tripId || _stopping) return;
    _stopping = true;
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    _writes.seal();
    await _writes.flush();
    await _database?.close();
    _database = null;
    _tripId = null;
    service.invoke('trackingStopped', {
      'trip_id': tripId,
      'had_errors': _writes.hasError,
    });
    if (stopWorker) await service.stopSelf();
    _stopping = false;
  }
}
