import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

import '../../../../core/services/background_location_service.dart';
import '../../../../core/services/speed_alert_service.dart';
import '../../../../core/utils/gps_utils.dart';
import '../../../../core/utils/gpx_utils.dart';
import '../../data/repositories/trip_repository_impl.dart';
import '../../domain/entities/trip_entity.dart';
import '../../domain/repositories/trip_repository.dart';

enum TripRecordingState { idle, starting, recording, stopping, error }

class TripController extends GetxController {
  TripController({
    TripRepository? repository,
    TripLocationService? locationService,
    SpeedAlertService? alertService,
  })  : _repo = repository ?? TripRepositoryImpl(),
        _locationService = locationService ?? BackgroundLocationService(),
        _alertService = alertService ?? SpeedAlertService();

  final TripRepository _repo;
  final TripLocationService _locationService;
  final SpeedAlertService _alertService;

  final recordingState = TripRecordingState.idle.obs;
  final isRecording = false.obs;
  final currentTripId = RxnInt();
  final trips = <TripEntity>[].obs;
  final livePoints = <TripPointEntity>[].obs;
  final lastError = RxnString();

  final currentDistance = 0.0.obs;
  final currentSpeed = 0.0.obs;
  final maxSpeed = 0.0.obs;
  final elapsedSeconds = 0.obs;
  final isOverSpeedLimit = false.obs;

  StreamSubscription<RecordedPosition>? _positionSubscription;
  StreamSubscription<String>? _errorSubscription;
  Timer? _timer;
  double _totalDistance = 0;
  double _speedSum = 0;
  int _speedCount = 0;
  DateTime? _startTime;
  Future<void>? _startFuture;
  Future<void>? _stopFuture;
  bool _stopRequested = false;

  bool get isTransitioning =>
      recordingState.value == TripRecordingState.starting ||
      recordingState.value == TripRecordingState.stopping;

  bool get canStart =>
      recordingState.value == TripRecordingState.idle ||
      recordingState.value == TripRecordingState.error;

  @override
  void onInit() {
    super.onInit();
    _positionSubscription = _locationService.positions.listen(_onPosition);
    _errorSubscription = _locationService.errors.listen(_onRecordingError);
    unawaited(_initialize());
  }

  @override
  void onClose() {
    _timer?.cancel();
    unawaited(_positionSubscription?.cancel());
    unawaited(_errorSubscription?.cancel());
    // Do not stop the worker here: Android may destroy the activity while the
    // foreground location service must continue recording.
    super.onClose();
  }

  Future<void> _initialize() async {
    await _loadTrips();
    final session = await _locationService.activeSession();
    if (session == null) return;

    final trip = await _repo.getTripById(session.tripId);
    if (trip == null || !trip.isActive) {
      await _locationService.stopService(tripId: session.tripId);
      return;
    }
    currentTripId.value = session.tripId;
    _startTime = session.startTime;
    _restoreStatistics(trip.points);
    if (!session.serviceRunning) {
      try {
        await _locationService.startService(
          tripId: session.tripId,
          startTime: session.startTime,
        );
      } catch (error) {
        _setError(error);
        return;
      }
    }
    _enterRecordingState();
  }

  Future<void> startTrip() {
    if (recordingState.value == TripRecordingState.starting) {
      return _startFuture ?? Future<void>.value();
    }
    if (recordingState.value == TripRecordingState.recording ||
        recordingState.value == TripRecordingState.stopping) {
      return Future<void>.value();
    }
    final pending = _startTripInternal();
    _startFuture = pending;
    return pending.whenComplete(() => _startFuture = null);
  }

  Future<void> _startTripInternal() async {
    recordingState.value = TripRecordingState.starting;
    lastError.value = null;
    _stopRequested = false;

    // An interrupted active session is resumed rather than creating another
    // database row.
    if (currentTripId.value != null && _startTime != null) {
      try {
        await _locationService.startService(
          tripId: currentTripId.value!,
          startTime: _startTime!,
        );
        _enterRecordingState();
      } catch (error) {
        _setError(error);
      }
      if (_stopRequested) await stopTrip();
      return;
    }

    final startTime = DateTime.now();
    int? tripId;
    try {
      await _locationService.ensurePermissions();
      _resetStatistics();
      tripId = await _repo.startTrip(startTime);
      currentTripId.value = tripId;
      _startTime = startTime;
      await _locationService.startService(
        tripId: tripId,
        startTime: startTime,
      );
      _enterRecordingState();
    } catch (error) {
      if (tripId != null) {
        try {
          await _locationService.stopService(tripId: tripId);
          await _repo.deleteTrip(tripId);
          currentTripId.value = null;
          _startTime = null;
        } catch (_) {
          // Preserve the row if cleanup cannot be proven safe.
        }
      }
      _setError(error);
    }
    if (_stopRequested) await stopTrip();
  }

  Future<void> stopTrip() async {
    if (recordingState.value == TripRecordingState.starting) {
      _stopRequested = true;
      await _startFuture;
    }
    if (recordingState.value == TripRecordingState.stopping) {
      return _stopFuture ?? Future<void>.value();
    }
    if (recordingState.value != TripRecordingState.recording ||
        currentTripId.value == null) {
      return;
    }
    final pending = _stopTripInternal();
    _stopFuture = pending;
    await pending.whenComplete(() => _stopFuture = null);
  }

  Future<void> _stopTripInternal() async {
    recordingState.value = TripRecordingState.stopping;
    isRecording.value = false;
    _timer?.cancel();
    _timer = null;
    final tripId = currentTripId.value!;
    try {
      // The worker acknowledges only after cancelling GPS and flushing its
      // ordered SQLite write queue.
      await _locationService.stopService(tripId: tripId);
      final averageSpeed = _speedCount == 0 ? 0.0 : _speedSum / _speedCount;
      await _repo.stopTrip(
        tripId,
        distanceMeters: _totalDistance,
        avgSpeedKmh: averageSpeed,
        maxSpeedKmh: maxSpeed.value,
        durationSeconds: elapsedSeconds.value,
        endTime: DateTime.now(),
      );
      currentTripId.value = null;
      _startTime = null;
      isOverSpeedLimit.value = false;
      recordingState.value = TripRecordingState.idle;
      await _loadTrips();
    } catch (error) {
      _setError(error);
    }
  }

  Future<void> deleteTrip(int id) async {
    if (id == currentTripId.value) return;
    await _repo.deleteTrip(id);
    await _loadTrips();
  }

  Future<void> importGpx() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['gpx'],
      );
      if (result == null || result.files.single.path == null) return;
      final trip = await GpxUtils.parseGpx(File(result.files.single.path!));
      if (trip == null) {
        _showMessage('Import Failed', 'Invalid GPX format or no track points.');
        return;
      }

      var distance = 0.0;
      var maxSpd = 0.0;
      var speedSum = 0.0;
      for (var i = 0; i < trip.points.length; i++) {
        final point = trip.points[i];
        if (point.speedKmh > maxSpd) maxSpd = point.speedKmh;
        speedSum += point.speedKmh;
        if (i > 0) {
          final previous = trip.points[i - 1];
          distance += GpsUtils.haversineDistance(
            previous.latitude,
            previous.longitude,
            point.latitude,
            point.longitude,
          );
        }
      }
      await _repo.saveImportedTrip(
        trip.copyWith(
          distanceMeters: distance,
          maxSpeedKmh: maxSpd,
          avgSpeedKmh: trip.points.isEmpty ? 0 : speedSum / trip.points.length,
        ),
      );
      await _loadTrips();
      _showMessage('Success', 'GPX imported successfully!');
    } catch (error) {
      _showMessage('Import Error', 'Could not read file: $error');
    }
  }

  Future<TripEntity?> getTrip(int id) => _repo.getTripById(id);

  void _onPosition(RecordedPosition position) {
    if (recordingState.value != TripRecordingState.recording ||
        position.tripId != currentTripId.value) {
      return;
    }
    currentSpeed.value = position.speedKmh;
    if (position.speedKmh > maxSpeed.value) {
      maxSpeed.value = position.speedKmh;
    }
    _speedSum += position.speedKmh;
    _speedCount++;
    _totalDistance += position.distanceMeters;
    currentDistance.value = _totalDistance;
    livePoints.add(
      TripPointEntity(
        tripId: position.tripId,
        latitude: position.latitude,
        longitude: position.longitude,
        speedKmh: position.speedKmh,
        accuracy: position.accuracy,
        altitude: position.altitude,
        timestamp: position.timestamp,
      ),
    );
    unawaited(_alertService.checkSpeed(position.speedKmh).catchError((_) {}));
  }

  void _onRecordingError(String message) {
    lastError.value = message;
    _showMessage('Recording warning', message);
  }

  void _enterRecordingState() {
    recordingState.value = TripRecordingState.recording;
    isRecording.value = true;
    _updateElapsed();
    _timer?.cancel();
    _timer =
        Timer.periodic(const Duration(seconds: 1), (_) => _updateElapsed());
  }

  void _updateElapsed() {
    final start = _startTime;
    if (start != null) {
      elapsedSeconds.value =
          DateTime.now().difference(start).inSeconds.clamp(0, 1 << 31);
    }
  }

  void _resetStatistics() {
    _totalDistance = 0;
    _speedSum = 0;
    _speedCount = 0;
    currentDistance.value = 0;
    currentSpeed.value = 0;
    maxSpeed.value = 0;
    elapsedSeconds.value = 0;
    isOverSpeedLimit.value = false;
    livePoints.clear();
  }

  void _restoreStatistics(List<TripPointEntity> points) {
    _resetStatistics();
    livePoints.assignAll(points);
    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      _speedSum += point.speedKmh;
      _speedCount++;
      if (point.speedKmh > maxSpeed.value) maxSpeed.value = point.speedKmh;
      if (i > 0) {
        final previous = points[i - 1];
        _totalDistance += GpsUtils.haversineDistance(
          previous.latitude,
          previous.longitude,
          point.latitude,
          point.longitude,
        );
      }
    }
    currentDistance.value = _totalDistance;
    if (points.isNotEmpty) currentSpeed.value = points.last.speedKmh;
  }

  void _setError(Object error) {
    final message = error.toString();
    isRecording.value = false;
    recordingState.value = TripRecordingState.error;
    lastError.value = message;
    _showMessage('Trip recording error', message);
  }

  void _showMessage(String title, String message) {
    if (Get.context != null) Get.snackbar(title, message);
  }

  Future<void> _loadTrips() async {
    trips.assignAll(await _repo.getAllTrips());
  }
}
