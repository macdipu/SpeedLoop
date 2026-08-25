import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../settings/presentation/controllers/settings_controller.dart';
import '../../../trip/presentation/controllers/trip_controller.dart';
import '../../data/dashcam_camera_driver.dart';
import '../../data/dashcam_clip_repository.dart';

class DashcamController extends GetxController with WidgetsBindingObserver {
  DashcamController({
    DashcamCameraDriver? cameraDriver,
    DashcamClipRepository? clipRepository,
    Future<Directory> Function()? directoryProvider,
    SettingsController? settingsController,
    TripController? injectedTripController,
    String Function()? incidentIdGenerator,
  })  : _camera = cameraDriver ?? PluginDashcamCameraDriver(),
        _clipRepository = clipRepository ?? DriftDashcamClipRepository(),
        _directoryProvider = directoryProvider ?? _defaultDirectoryProvider,
        _injectedSettings = settingsController,
        _injectedTripController = injectedTripController,
        _incidentIdGenerator = incidentIdGenerator ?? const Uuid().v4 {
    _storage = DashcamStorageManager(repository: _clipRepository);
  }

  static const int maxStorageBytes = 500 * 1024 * 1024;
  static const int safeContinuousSegmentSeconds = 60;
  static const int recordingHeadroomBytes = 100 * 1024 * 1024;
  static const double autoLockMinStartingSpeedKmh = 35;
  static const double autoLockMinSpeedDropKmh = 25;
  static const int autoLockDetectionWindowSeconds = 2;
  static const int autoLockCooldownSeconds = 8;

  final DashcamCameraDriver _camera;
  final DashcamClipRepository _clipRepository;
  final Future<Directory> Function() _directoryProvider;
  final SettingsController? _injectedSettings;
  final TripController? _injectedTripController;
  final String Function() _incidentIdGenerator;
  late final DashcamStorageManager _storage;

  CameraController? get cameraController => _camera.previewController;
  SettingsController get _settings =>
      _injectedSettings ?? Get.find<SettingsController>();
  TripController get tripController =>
      _injectedTripController ?? Get.find<TripController>();

  final isInitialized = false.obs;
  final isRecording = false.obs;
  final isFinalizing = false.obs;
  final isStorageFull = false.obs;
  final lastError = RxnString();
  final totalElapsedSeconds = 0.obs;
  final clipElapsedSeconds = 0.obs;
  final clipTotalSeconds = 0.obs;
  final segmentCount = 0.obs;
  final storageMbUsed = 0.0.obs;
  final resolutionLabel = '1080p'.obs;
  final isCurrentClipLocked = false.obs;
  final isSwitchingClip = false.obs;
  final savedClips = <DashcamClipMetadata>[].obs;

  Timer? _uiTimer;
  Timer? _cycleTimer;
  DateTime? _recordingStart;
  DateTime? _clipStart;
  bool _ownsTripRecording = false;
  Future<void>? _finalizationFuture;
  Future<void>? _cycleFuture;
  bool _cameraDisposed = false;
  Worker? _speedWorker;
  double? _lastObservedSpeedKmh;
  DateTime? _lastObservedSpeedAt;
  DateTime? _lastAutoLockAt;
  _IncidentContext? _currentIncident;
  _IncidentContext? _nextIncident;
  String? _lastFinalizedClipPath;
  Future<void>? _incidentProtectionFuture;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _speedWorker =
        ever<double>(tripController.currentSpeed, _handleSpeedSample);
    unawaited(_initialize());
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _speedWorker?.dispose();
    // GetX lifecycle callbacks are synchronous. The shared shutdown future owns
    // ordering and disposes the camera only after any clip is finalized.
    unawaited(shutdown());
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        if (isRecording.value) unawaited(finalizeRecording());
        break;
      case AppLifecycleState.detached:
        unawaited(shutdown());
        break;
      case AppLifecycleState.resumed:
        // Privacy stops are never automatically restarted.
        break;
    }
  }

  Future<void> _initialize() async {
    try {
      final directory = await _directoryProvider();
      await _storage.reconcile(directory);
      await _refreshStorage(directory);
      await refreshSavedClips();
      await _camera.initialize();
      _cameraDisposed = false;
      final dimension = _camera.maxPreviewDimension;
      if (dimension != null) resolutionLabel.value = _resLabel(dimension);
      isInitialized.value = true;
    } catch (error) {
      _setError('Could not initialize camera: $error');
    }
  }

  Future<void> toggleRecording() async {
    if (!isInitialized.value || isFinalizing.value) return;
    if (isRecording.value) {
      await finalizeRecording();
    } else {
      await _startRecording();
    }
  }

  void toggleLock() {
    if (!isRecording.value) return;
    isCurrentClipLocked.value = !isCurrentClipLocked.value;
    if (!isCurrentClipLocked.value) {
      _currentIncident = null;
      _nextIncident = null;
    }
  }

  void markEvent({
    String message = 'Current clip marked and protected.',
    DashcamIncidentType incidentType = DashcamIncidentType.manualEvent,
  }) {
    if (!isRecording.value) return;
    final now = DateTime.now();
    final existing = _currentIncident;
    final incidentId = existing?.id ?? _incidentIdGenerator();
    final occurredAt = existing?.occurredAt ?? now;
    final offsetMs = now.difference(_clipStart ?? now).inMilliseconds;
    final incident = _IncidentContext(
      id: incidentId,
      type: incidentType,
      occurredAt: occurredAt,
      segment: DashcamIncidentSegment.event,
      offsetMs: offsetMs < 0 ? 0 : offsetMs,
    );
    _currentIncident = incident;
    _nextIncident = incident.forSegment(DashcamIncidentSegment.after);
    if (!isCurrentClipLocked.value) {
      isCurrentClipLocked.value = true;
    }
    final previousPath = _lastFinalizedClipPath;
    if (previousPath != null) {
      _queuePreviousSegmentProtection(previousPath, incident);
    }
    if (Get.context != null) {
      Get.rawSnackbar(
        message: message,
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.black87,
      );
    }
  }

  void _handleSpeedSample(double speedKmh) {
    final observedAt = DateTime.now();
    final previousSpeed = _lastObservedSpeedKmh;
    final previousAt = _lastObservedSpeedAt;
    _lastObservedSpeedKmh = speedKmh;
    _lastObservedSpeedAt = observedAt;

    if (!isRecording.value || previousSpeed == null || previousAt == null) {
      return;
    }

    final elapsed = observedAt.difference(previousAt);
    final dropKmh = previousSpeed - speedKmh;
    if (previousSpeed < autoLockMinStartingSpeedKmh ||
        dropKmh < autoLockMinSpeedDropKmh ||
        elapsed.inMilliseconds <= 0 ||
        elapsed.inSeconds > autoLockDetectionWindowSeconds) {
      return;
    }

    final lastAutoLockAt = _lastAutoLockAt;
    if (lastAutoLockAt != null &&
        observedAt.difference(lastAutoLockAt).inSeconds <
            autoLockCooldownSeconds) {
      return;
    }

    _lastAutoLockAt = observedAt;
    markEvent(
      message: 'Severe braking detected. Current clip protected.',
      incidentType: DashcamIncidentType.severeBraking,
    );
  }

  Future<void> setClipLocked(String path, bool locked) async {
    await _clipRepository.setLocked(path, locked);
    await refreshSavedClips();
  }

  Future<void> refreshSavedClips() async {
    final clips = await _clipRepository.getAll();
    clips.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    savedClips.assignAll(clips);
  }

  Future<void> deleteSavedClip(String path) async {
    if (isRecording.value) {
      _setError('Stop recording before deleting a saved clip.');
      return;
    }
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
    await _clipRepository.deleteMetadata(path);
    final directory = await _directoryProvider();
    await _refreshStorage(directory);
    await refreshSavedClips();
  }

  Future<void> _startRecording() async {
    final existingFinalization = _finalizationFuture;
    if (existingFinalization != null) await existingFinalization;
    final directory = await _directoryProvider();
    final quota = await _storage.enforceQuota(
      directory: directory,
      maxBytes: _recordingBudgetBytes,
    );
    await _applyStorageResult(quota);
    if (!quota.canRecord) {
      isStorageFull.value = true;
      _setError(
          'Locked dashcam clips fill the storage budget. Unlock or remove a clip to continue.');
      return;
    }

    try {
      // Start any linked trip before opening the camera recording. Permission
      // dialogs can make the app inactive; opening them after camera start
      // would race the privacy lifecycle finalizer.
      if (!tripController.isRecording.value) {
        await tripController.startTrip();
        _ownsTripRecording = tripController.isRecording.value;
      }

      final selectedSeconds = _settings.loopDuration.value.minutes * 60;
      // Physical files are always bounded so long recordings cannot outgrow
      // the storage cap before quota cleanup runs.
      clipTotalSeconds.value = _physicalSegmentSeconds(selectedSeconds);
      await _camera.startRecording();
      final now = DateTime.now();
      _recordingStart = now;
      _clipStart = now;
      totalElapsedSeconds.value = 0;
      clipElapsedSeconds.value = 0;
      segmentCount.value = 0;
      isCurrentClipLocked.value = false;
      _currentIncident = null;
      _nextIncident = null;
      _lastFinalizedClipPath = null;
      isSwitchingClip.value = false;
      isStorageFull.value = false;
      lastError.value = null;
      isRecording.value = true;
      _startUiTimer();
      _scheduleCycleTimer(clipTotalSeconds.value);
    } catch (error) {
      _setError('Failed to start recording: $error');
      await finalizeRecording();
    }
  }

  Future<void> finalizeRecording() {
    final existing = _finalizationFuture;
    if (existing != null) return existing;
    final future = _finalizeRecordingInternal();
    _finalizationFuture = future;
    return future.whenComplete(() => _finalizationFuture = null);
  }

  Future<void> _finalizeRecordingInternal() async {
    isFinalizing.value = true;
    isRecording.value = false;
    _uiTimer?.cancel();
    _cycleTimer?.cancel();
    _uiTimer = null;
    _cycleTimer = null;
    try {
      await _cycleFuture;
      if (_camera.isRecording) {
        final file = await _camera.stopRecording();
        await _saveChunk(
          file,
          locked: isCurrentClipLocked.value,
          incident: _currentIncident,
        );
      }
      await _flushIncidentProtection();
      final directory = await _directoryProvider();
      final result = await _storage.enforceQuota(
        directory: directory,
        maxBytes: maxStorageBytes,
      );
      await _applyStorageResult(result);
      if (result.canRecord) {
        final headroom = await _storage.enforceQuota(
          directory: directory,
          maxBytes: _recordingBudgetBytes,
        );
        await _applyStorageResult(headroom);
        if (!headroom.canRecord) {
          isStorageFull.value = true;
          _setError(
            'Locked dashcam clips leave too little free space for another segment.',
          );
        }
      }
      await refreshSavedClips();
    } catch (error) {
      _setError('Could not safely finalize the dashcam clip: $error');
    } finally {
      isCurrentClipLocked.value = false;
      _currentIncident = null;
      _nextIncident = null;
      isSwitchingClip.value = false;
      if (_ownsTripRecording && tripController.isRecording.value) {
        await tripController.stopTrip();
      }
      _ownsTripRecording = false;
      isFinalizing.value = false;
    }
  }

  Future<void> shutdown() async {
    await finalizeRecording();
    if (_cameraDisposed) return;
    _cameraDisposed = true;
    isInitialized.value = false;
    await _camera.dispose();
  }

  void _scheduleCycleTimer(int seconds) {
    _cycleTimer?.cancel();
    _cycleTimer = Timer(Duration(seconds: seconds), () {
      if (_cycleFuture != null) return;
      final future = _cycleClip();
      _cycleFuture = future;
      unawaited(future.whenComplete(() => _cycleFuture = null));
    });
  }

  Future<void> _cycleClip() async {
    if (!isRecording.value || !_camera.isRecording) return;
    isSwitchingClip.value = true;
    try {
      final file = await _camera.stopRecording();
      await _saveChunk(
        file,
        locked: isCurrentClipLocked.value,
        incident: _currentIncident,
      );
      await _flushIncidentProtection();
      final directory = await _directoryProvider();
      final result = await _storage.enforceQuota(
        directory: directory,
        maxBytes: maxStorageBytes,
      );
      await _applyStorageResult(result);
      if (!result.canRecord) {
        isStorageFull.value = true;
        isRecording.value = false;
        _uiTimer?.cancel();
        _setError(
            'Recording stopped because locked clips fill the storage budget.');
        if (_ownsTripRecording && tripController.isRecording.value) {
          await tripController.stopTrip();
          _ownsTripRecording = false;
        }
        return;
      }
      final headroom = await _storage.enforceQuota(
        directory: directory,
        maxBytes: _recordingBudgetBytes,
      );
      await _applyStorageResult(headroom);
      if (!headroom.canRecord) {
        isStorageFull.value = true;
        isRecording.value = false;
        _uiTimer?.cancel();
        _setError(
            'Recording stopped because locked clips leave too little free space for another segment.');
        if (_ownsTripRecording && tripController.isRecording.value) {
          await tripController.stopTrip();
          _ownsTripRecording = false;
        }
        return;
      }
      if (!isRecording.value) return;
      await _camera.startRecording();
      _clipStart = DateTime.now();
      clipElapsedSeconds.value = 0;
      _currentIncident = _nextIncident;
      _nextIncident = null;
      isCurrentClipLocked.value = _currentIncident != null;
      segmentCount.value++;
      _showSegmentToast();
      _scheduleCycleTimer(clipTotalSeconds.value);
      await refreshSavedClips();
    } catch (error) {
      isRecording.value = false;
      _uiTimer?.cancel();
      _setError('Dashcam segment transition failed: $error');
    } finally {
      isSwitchingClip.value = false;
    }
  }

  Future<void> _saveChunk(
    XFile source, {
    required bool locked,
    required _IncidentContext? incident,
  }) async {
    final directory = await _directoryProvider();
    final now = DateTime.now();
    final name = 'VID_${now.microsecondsSinceEpoch}.mp4';
    final destination = '${directory.path}${Platform.pathSeparator}$name';
    final saved = await File(source.path).rename(destination);
    await _clipRepository.upsert(
      DashcamClipMetadata(
        tripId: tripController.currentTripId.value,
        path: destination,
        createdAt: now,
        isLocked: locked || incident != null,
        sizeBytes: await saved.length(),
        incidentType: incident?.type,
        incidentId: incident?.id,
        incidentAt: incident?.occurredAt,
        incidentOffsetMs: incident?.offsetMs,
        incidentSegment: incident?.segment,
      ),
    );
    _lastFinalizedClipPath = destination;
    await refreshSavedClips();
  }

  void _queuePreviousSegmentProtection(
    String path,
    _IncidentContext incident,
  ) {
    final previous = _incidentProtectionFuture ?? Future<void>.value();
    final protection = previous.then((_) async {
      final matches = savedClips.where((clip) => clip.path == path);
      if (matches.isEmpty) return;
      final clip = matches.first;
      // Never overwrite a separate incident already attached to the clip.
      if (clip.incidentId != null && clip.incidentId != incident.id) return;
      final segment = clip.incidentSegment == DashcamIncidentSegment.event
          ? DashcamIncidentSegment.event
          : DashcamIncidentSegment.before;
      await _clipRepository.upsert(
        clip.withIncident(
          type: incident.type,
          id: incident.id,
          occurredAt: incident.occurredAt,
          segment: segment,
          offsetMs: segment == DashcamIncidentSegment.event
              ? clip.incidentOffsetMs
              : null,
        ),
      );
      await refreshSavedClips();
    });
    _incidentProtectionFuture = protection;
    unawaited(
      protection.catchError((Object error, StackTrace stackTrace) {
        _setError('Could not protect the preceding dashcam segment: $error');
      }),
    );
  }

  Future<void> _flushIncidentProtection() async {
    final protection = _incidentProtectionFuture;
    if (protection == null) return;
    try {
      await protection;
    } catch (_) {
      // The queued future reports the actionable error when it fails.
    } finally {
      if (identical(_incidentProtectionFuture, protection)) {
        _incidentProtectionFuture = null;
      }
    }
  }

  @visibleForTesting
  Future<void> cycleClipForTesting() => _cycleClip();

  Future<void> _applyStorageResult(DashcamStorageResult result) async {
    storageMbUsed.value = result.totalBytes / (1024 * 1024);
    isStorageFull.value = !result.canRecord;
  }

  Future<void> _refreshStorage(Directory directory) async {
    final result = await _storage.enforceQuota(
      directory: directory,
      maxBytes: maxStorageBytes,
    );
    await _applyStorageResult(result);
  }

  int get _recordingBudgetBytes => maxStorageBytes > recordingHeadroomBytes
      ? maxStorageBytes - recordingHeadroomBytes
      : maxStorageBytes;

  int _physicalSegmentSeconds(int selectedSeconds) {
    if (selectedSeconds <= 0) return safeContinuousSegmentSeconds;
    return selectedSeconds < safeContinuousSegmentSeconds
        ? selectedSeconds
        : safeContinuousSegmentSeconds;
  }

  void _startUiTimer() {
    _uiTimer?.cancel();
    _uiTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final recordingStart = _recordingStart;
      final clipStart = _clipStart;
      if (recordingStart != null) {
        totalElapsedSeconds.value =
            DateTime.now().difference(recordingStart).inSeconds;
      }
      if (clipStart != null) {
        clipElapsedSeconds.value =
            DateTime.now().difference(clipStart).inSeconds;
      }
    });
  }

  void _showSegmentToast() {
    if (Get.context == null) return;
    Get.rawSnackbar(
      message: 'new_segment_started'.tr,
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.black87,
    );
  }

  void _setError(String message) {
    lastError.value = message;
    if (Get.context != null) {
      Get.snackbar('Dashcam', message, snackPosition: SnackPosition.BOTTOM);
    }
  }

  static Future<Directory> _defaultDirectoryProvider() async {
    final root = await getApplicationDocumentsDirectory();
    final directory = Directory('${root.path}/dashcam');
    if (!await directory.exists()) await directory.create(recursive: true);
    return directory;
  }

  static String _resLabel(int maxDimension) {
    if (maxDimension >= 2160) return '4K';
    if (maxDimension >= 1440) return '1440p';
    if (maxDimension >= 1080) return '1080p';
    if (maxDimension >= 720) return '720p';
    return '480p';
  }

  static String formatClock(int totalSecs) {
    final minutes = (totalSecs ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSecs % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _IncidentContext {
  const _IncidentContext({
    required this.id,
    required this.type,
    required this.occurredAt,
    required this.segment,
    this.offsetMs,
  });

  final String id;
  final DashcamIncidentType type;
  final DateTime occurredAt;
  final DashcamIncidentSegment segment;
  final int? offsetMs;

  _IncidentContext forSegment(DashcamIncidentSegment nextSegment) {
    return _IncidentContext(
      id: id,
      type: type,
      occurredAt: occurredAt,
      segment: nextSegment,
    );
  }
}
