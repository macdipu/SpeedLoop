import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:speedloop/core/services/background_location_service.dart';
import 'package:speedloop/features/trip/domain/entities/trip_entity.dart';
import 'package:speedloop/features/trip/domain/repositories/trip_repository.dart';
import 'package:speedloop/features/trip/presentation/controllers/trip_controller.dart';

class FakeTripRepository implements TripRepository {
  int startCalls = 0;
  int stopCalls = 0;
  int deleteCalls = 0;
  int addPointCalls = 0;
  int nextId = 1;
  final Map<int, TripEntity> trips = {};

  @override
  Future<int> startTrip(DateTime startTime, {String? title}) async {
    startCalls++;
    final id = nextId++;
    trips[id] = TripEntity(id: id, startTime: startTime, title: title);
    return id;
  }

  @override
  Future<void> stopTrip(
    int tripId, {
    required double distanceMeters,
    required double avgSpeedKmh,
    required double maxSpeedKmh,
    required int durationSeconds,
    required DateTime endTime,
  }) async {
    stopCalls++;
    trips[tripId] = trips[tripId]!.copyWith(
      endTime: endTime,
      distanceMeters: distanceMeters,
      avgSpeedKmh: avgSpeedKmh,
      maxSpeedKmh: maxSpeedKmh,
      durationSeconds: durationSeconds,
    );
  }

  @override
  Future<void> addTripPoint(TripPointEntity point) async => addPointCalls++;

  @override
  Future<void> deleteTrip(int id) async {
    deleteCalls++;
    trips.remove(id);
  }

  @override
  Future<List<TripEntity>> getAllTrips() async => trips.values.toList();

  @override
  Future<TripEntity?> getTripById(int id) async => trips[id];

  @override
  Future<void> saveImportedTrip(TripEntity trip) async {}

  @override
  Stream<List<TripEntity>> watchAllTrips() => const Stream.empty();
}

class FakeTripLocationService implements TripLocationService {
  final positionsController = StreamController<RecordedPosition>.broadcast();
  final errorsController = StreamController<String>.broadcast();
  int startCalls = 0;
  int stopCalls = 0;
  Object? permissionError;
  Completer<void>? startGate;
  Completer<void>? stopGate;
  ({int tripId, DateTime startTime, bool serviceRunning})? session;

  @override
  Stream<String> get errors => errorsController.stream;

  @override
  Stream<RecordedPosition> get positions => positionsController.stream;

  @override
  Future<({int tripId, DateTime startTime, bool serviceRunning})?>
      activeSession() async => session;

  @override
  Future<void> ensurePermissions() async {
    if (permissionError != null) throw permissionError!;
  }

  @override
  Future<void> startService({
    required int tripId,
    required DateTime startTime,
  }) async {
    startCalls++;
    await startGate?.future;
    session = (tripId: tripId, startTime: startTime, serviceRunning: true);
  }

  @override
  Future<void> stopService({required int tripId}) async {
    stopCalls++;
    await stopGate?.future;
    session = null;
  }

  Future<void> close() async {
    await positionsController.close();
    await errorsController.close();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeTripRepository repository;
  late FakeTripLocationService location;
  late TripController controller;

  setUp(() async {
    Get.testMode = true;
    repository = FakeTripRepository();
    location = FakeTripLocationService();
    controller = TripController(
      repository: repository,
      locationService: location,
    );
    controller.onInit();
    await Future<void>.delayed(Duration.zero);
  });

  tearDown(() async {
    controller.onClose();
    await location.close();
    Get.reset();
  });

  test('duplicate starts share one transition, row and location worker',
      () async {
    location.startGate = Completer<void>();
    final first = controller.startTrip();
    final second = controller.startTrip();
    await Future<void>.delayed(Duration.zero);

    expect(controller.recordingState.value, TripRecordingState.starting);
    expect(repository.startCalls, 1);
    expect(location.startCalls, 1);
    location.startGate!.complete();
    await Future.wait([first, second]);
    expect(controller.recordingState.value, TripRecordingState.recording);
  });

  test('duplicate stops flush and finalize exactly once', () async {
    await controller.startTrip();
    location.stopGate = Completer<void>();
    final first = controller.stopTrip();
    final second = controller.stopTrip();
    await Future<void>.delayed(Duration.zero);

    expect(controller.recordingState.value, TripRecordingState.stopping);
    expect(location.stopCalls, 1);
    location.stopGate!.complete();
    await Future.wait([first, second]);
    expect(repository.stopCalls, 1);
    expect(controller.recordingState.value, TripRecordingState.idle);
  });

  test('stop during start waits for startup then performs one clean stop',
      () async {
    location.startGate = Completer<void>();
    final start = controller.startTrip();
    await Future<void>.delayed(Duration.zero);
    final stop = controller.stopTrip();
    location.startGate!.complete();
    await Future.wait([start, stop]);

    expect(repository.startCalls, 1);
    expect(location.startCalls, 1);
    expect(location.stopCalls, 1);
    expect(repository.stopCalls, 1);
  });

  test('permission failure creates no trip row and exposes error state',
      () async {
    location.permissionError =
        const LocationRecordingException('permission denied');
    await controller.startTrip();

    expect(repository.startCalls, 0);
    expect(location.startCalls, 0);
    expect(controller.recordingState.value, TripRecordingState.error);
    expect(controller.lastError.value, contains('permission denied'));
  });

  test('consumes only persisted worker events for the active trip', () async {
    await controller.startTrip();
    final tripId = controller.currentTripId.value!;
    location.positionsController.add(
      RecordedPosition(
        tripId: tripId,
        latitude: 23,
        longitude: 90,
        speedKmh: 50,
        altitude: 10,
        accuracy: 5,
        timestamp: DateTime.utc(2026),
        distanceMeters: 25,
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(controller.livePoints, hasLength(1));
    expect(controller.currentDistance.value, 25);
    expect(repository.addPointCalls, 0);
  });
}
