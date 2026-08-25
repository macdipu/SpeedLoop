/// SpeedAlertService
/// Uses flutter_tts to announce a spoken speed warning when the user
/// exceeds the configured speed limit. Enforces a minimum interval between
/// alerts so they don't fire every GPS ping.
library;

import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';

import '../utils/gps_utils.dart';
import '../../features/settings/presentation/controllers/settings_controller.dart';

class SpeedAlertService {
  static final SpeedAlertService _instance = SpeedAlertService._();
  factory SpeedAlertService() => _instance;
  SpeedAlertService._();

  final _tts = FlutterTts();
  DateTime? _lastAlertTime;

  static const int _cooldownSeconds = 10;

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _initialized = true;
  }

  /// Call on every GPS position update.
  /// [speedKmh] — current speed in km/h (always km/h, regardless of display unit).
  Future<void> checkSpeed(double speedKmh) async {
    final settings = Get.find<SettingsController>();
    if (!settings.speedAlertEnabled.value) return;

    final limitKmh = settings.speedLimitKmh.value;

    // Compare both in km/h — limitKmh is always stored in km/h
    if (speedKmh > limitKmh) {
      final now = DateTime.now();
      if (_lastAlertTime == null ||
          now.difference(_lastAlertTime!).inSeconds >= _cooldownSeconds) {
        _lastAlertTime = now;
        await init();
        // Announce in user's display unit
        final unit = settings.speedUnit.value;
        final displaySpeed =
            unit == SpeedUnit.kmh ? speedKmh : GpsUtils.kmhToMph(speedKmh);
        final unitLabel = unit == SpeedUnit.kmh ? 'km/h' : 'mph';
        final msg =
            'Speed limit exceeded. You are going ${displaySpeed.toStringAsFixed(0)} $unitLabel.';
        await _tts.speak(msg);
      }
    }
  }

  Future<void> dispose() async {
    await _tts.stop();
  }
}
