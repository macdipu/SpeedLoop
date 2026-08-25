/// SpeedometerController — GetX Controller
/// Manages real-time GPS speed tracking, unit switching, and session max-speed.
/// Unit is kept in sync with SettingsController as the single source of truth.
library;

import 'dart:async';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/utils/gps_utils.dart';
import '../../../../features/settings/presentation/controllers/settings_controller.dart';
import '../../domain/entities/speedometer_entity.dart';
import '../../data/repositories/speedometer_repository_impl.dart';

/// View modes for the speedometer screen
enum SpeedometerMode { digital, analog, hud, map }

class SpeedometerController extends GetxController {
  final _repo = SpeedometerRepositoryImpl();

  // --------------------------------------------------------------------------
  // Reactive state
  // --------------------------------------------------------------------------

  final speedometer = SpeedometerEntity.empty().obs;
  final mode = SpeedometerMode.digital.obs;
  final isConnected = false.obs;
  final errorMessage = RxnString();

  double _sessionMaxSpeed = 0.0;
  StreamSubscription<Position>? _positionSub;

  // --------------------------------------------------------------------------
  // Lifecycle
  // --------------------------------------------------------------------------

  @override
  void onInit() {
    super.onInit();
    _syncWithSettings();
    _startTracking();
  }

  @override
  void onClose() {
    _positionSub?.cancel();
    super.onClose();
  }

  // --------------------------------------------------------------------------
  // Public methods
  // --------------------------------------------------------------------------

  /// Toggle unit — updates SettingsController (single source of truth),
  /// which triggers the ever() listener to update the speedometer entity.
  void switchUnit() {
    final settings = Get.find<SettingsController>();
    final newUnit =
        speedometer.value.unit == SpeedUnit.kmh ? SpeedUnit.mph : SpeedUnit.kmh;
    settings.setSpeedUnit(newUnit);
  }

  void setMode(SpeedometerMode m) => mode.value = m;

  // --------------------------------------------------------------------------
  // Private: settings sync
  // --------------------------------------------------------------------------

  void _syncWithSettings() {
    final settings = Get.find<SettingsController>();

    // Set initial unit from persisted settings
    speedometer.value =
        speedometer.value.copyWith(unit: settings.speedUnit.value);

    // React to unit changes (from Settings screen or Speedometer toggle)
    ever(settings.speedUnit, (SpeedUnit newUnit) {
      _sessionMaxSpeed = 0;
      speedometer.value =
          speedometer.value.copyWith(unit: newUnit, maxSpeed: 0);
    });
  }

  // --------------------------------------------------------------------------
  // Private: GPS stream
  // --------------------------------------------------------------------------

  Future<void> _startTracking() async {
    try {
      await GpsUtils.ensurePermissions();
      isConnected.value = true;
      errorMessage.value = null;

      _positionSub = _repo.positionStream.listen(
        _onPosition,
        onError: _onError,
      );
    } catch (e) {
      errorMessage.value = e.toString();
      isConnected.value = false;
    }
  }

  void _onPosition(Position pos) {
    final rawSpeed = GpsUtils.sanitizeSpeed(pos.speed); // m/s
    final displaySpeed =
        GpsUtils.convertSpeed(rawSpeed, speedometer.value.unit);

    if (displaySpeed > _sessionMaxSpeed) {
      _sessionMaxSpeed = displaySpeed;
    }

    speedometer.value = SpeedometerEntity(
      speedMs: rawSpeed,
      unit: speedometer.value.unit,
      maxSpeed: _sessionMaxSpeed,
      accuracy: pos.accuracy,
      altitude: pos.altitude,
      latitude: pos.latitude,
      longitude: pos.longitude,
      heading: pos.heading,
      timestamp: pos.timestamp,
    );
  }

  void _onError(Object error) {
    errorMessage.value = error.toString();
    isConnected.value = false;
  }
}
