import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:speedloop/core/services/background_location_service.dart';
import 'package:speedloop/features/dashcam/data/dashcam_camera_driver.dart';
import 'package:speedloop/features/dashcam/data/dashcam_clip_repository.dart';
import 'package:speedloop/features/dashcam/presentation/controllers/dashcam_controller.dart';
import 'package:speedloop/features/settings/presentation/controllers/settings_controller.dart';
import 'package:speedloop/features/trip/domain/entities/trip_entity.dart';
import 'package:speedloop/features/trip/domain/repositories/trip_repository.dart';
import 'package:speedloop/features/trip/presentation/controllers/trip_controller.dart';

class FakeCameraDriver implements DashcamCameraDriver {
  FakeCameraDriver(this.directory);
  final Directory directory;
  int startCalls = 0;
  int stopCalls = 0;
  int disposeCalls = 0;
  bool recording = false;
  bool initialized = false;

  @override
  bool get isInitialized => initialized;
  @override
  bool get isRecording => recording;
  @override
  int? get maxPreviewDimension => 1080;
  @override
  CameraController? get previewController => null;

  @override
  Future<void> initialize() async => initialized = true;

  @override
  Future<void> startRecording() async {
    startCalls++;
    recording = true;
  }

  @override
  Future<XFile> stopRecording() async {
    stopCalls++;
    recording = false;
    final source = File('${directory.path}/source_$stopCalls.tmp');
    await source.writeAsBytes([1, 2, 3]);
    return XFile(source.path);
  }

  @override
  Future<void> dispose() async {
    disposeCalls++;
    initialized = false;
  }
}

class MemoryRepository implements DashcamClipRepository {
  final Map<String, DashcamClipMetadata> clips = {};
  @override
  Future<void> deleteMetadata(String path) async => clips.remove(path);
  @override
  Future<List<DashcamClipMetadata>> getAll() async => clips.values.toList();
  @override
  Future<void> setLocked(String path, bool locked) async {
    final old = clips[path]!;
    clips[path] = DashcamClipMetadata(
      path: old.path,
      createdAt: old.createdAt,
      isLocked: locked,
      sizeBytes: old.sizeBytes,
    );
  }

  @override
  Future<void> upsert(DashcamClipMetadata metadata) async {
    clips[metadata.path] = metadata;
  }
}

class NoopTripRepository implements TripRepository {
  @override
  Future<void> addTripPoint(TripPointEntity point) async {}
  @override
  Future<void> deleteTrip(int id) async {}
  @override
  Future<List<TripEntity>> getAllTrips() async => [];
  @override
  Future<TripEntity?> getTripById(int id) async => null;
  @override
  Future<void> saveImportedTrip(TripEntity trip) async {}
  @override
  Future<int> startTrip(DateTime startTime, {String? title}) async => 1;
  @override
  Future<void> stopTrip(
    int tripId, {
    required double distanceMeters,
    required double avgSpeedKmh,
    required double maxSpeedKmh,
    required int durationSeconds,
    required DateTime endTime,
  }) async {}
  @override
  Stream<List<TripEntity>> watchAllTrips() => const Stream.empty();
}

class NoopLocationService implements TripLocationService {
  @override
  Stream<String> get errors => const Stream.empty();
  @override
  Stream<RecordedPosition> get positions => const Stream.empty();
  @override
  Future<({int tripId, DateTime startTime, bool serviceRunning})?>
      activeSession() async => null;
  @override
  Future<void> ensurePermissions() async {}
  @override
  Future<void> startService({
    required int tripId,
    required DateTime startTime,
  }) async {}
  @override
  Future<void> stopService({required int tripId}) async {}
}

class StubTripController extends TripController {
  StubTripController()
      : super(
          repository: NoopTripRepository(),
          locationService: NoopLocationService(),
        );

  int startCalls = 0;
  int stopCalls = 0;

  @override
  Future<void> startTrip() async {
    startCalls++;
    isRecording.value = true;
    recordingState.value = TripRecordingState.recording;
  }

  @override
  Future<void> stopTrip() async {
    stopCalls++;
    isRecording.value = false;
    recordingState.value = TripRecordingState.idle;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late FakeCameraDriver camera;
  late MemoryRepository repository;
  late StubTripController trip;
  late DashcamController controller;

  setUp(() async {
    Get.testMode = true;
    directory =
        await Directory.systemTemp.createTemp('dashcam_controller_test_');
    camera = FakeCameraDriver(directory);
    repository = MemoryRepository();
    trip = StubTripController();
    controller = DashcamController(
      cameraDriver: camera,
      clipRepository: repository,
      directoryProvider: () async => directory,
      settingsController: SettingsController(),
      injectedTripController: trip,
    );
    controller.onInit();
    await Future<void>.delayed(const Duration(milliseconds: 10));
  });

  tearDown(() async {
    await controller.shutdown();
    controller.onClose();
    if (await directory.exists()) await directory.delete(recursive: true);
    Get.reset();
  });

  test('background transition finalizes recording and does not restart',
      () async {
    await controller.toggleRecording();
    expect(controller.isRecording.value, isTrue);
    expect(trip.startCalls, 1);

    controller.didChangeAppLifecycleState(AppLifecycleState.paused);
    await controller.finalizeRecording();
    controller.didChangeAppLifecycleState(AppLifecycleState.resumed);

    expect(controller.isRecording.value, isFalse);
    expect(camera.stopCalls, 1);
    expect(repository.clips, hasLength(1));
    expect(trip.stopCalls, 1);
    expect(camera.recording, isFalse);
  });

  test('simultaneous finalization executes camera stop once', () async {
    await controller.toggleRecording();
    await Future.wait([
      controller.finalizeRecording(),
      controller.finalizeRecording(),
      controller.finalizeRecording(),
    ]);
    expect(camera.stopCalls, 1);
    expect(repository.clips, hasLength(1));
  });

  test('current clip lock is persisted with the finalized file', () async {
    await controller.toggleRecording();
    controller.toggleLock();
    await controller.finalizeRecording();
    expect(repository.clips.values.single.isLocked, isTrue);
  });

  test('shutdown finalizes before camera disposal', () async {
    await controller.toggleRecording();
    await controller.shutdown();
    expect(camera.stopCalls, 1);
    expect(camera.disposeCalls, 1);
    expect(repository.clips, hasLength(1));
  });
}
