/// BackgroundLocationService
/// Manages a background isolate (flutter_background_service) that keeps
/// Geolocator broadcasting position updates even when the app is minimized.

import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLatKey = 'bg_lat';
const _kLngKey = 'bg_lng';
const _kSpeedKey = 'bg_speed_kmh';
const _kAltKey = 'bg_altitude';
const _kTsKey = 'bg_timestamp';

// ---------------------------------------------------------------------------
// Top-level entry points — must be top-level for flutter_background_service
// ---------------------------------------------------------------------------

@pragma('vm:entry-point')
void onBgServiceStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  service.on('stopService').listen((_) async {
    await service.stopSelf();
  });

  Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    ),
  ).listen((pos) async {
    final speedKmh = (pos.speed < 0 ? 0 : pos.speed) * 3.6;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kLatKey, pos.latitude);
    await prefs.setDouble(_kLngKey, pos.longitude);
    await prefs.setDouble(_kSpeedKey, speedKmh);
    await prefs.setDouble(_kAltKey, pos.altitude);
    await prefs.setString(_kTsKey, pos.timestamp.toIso8601String());

    service.invoke('position', {
      'lat': pos.latitude,
      'lng': pos.longitude,
      'speed_kmh': speedKmh,
      'altitude': pos.altitude,
      'timestamp': pos.timestamp.toIso8601String(),
      'accuracy': pos.accuracy,
      'heading': pos.heading,
    });

    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: 'SpeedLoop — Recording',
        content: '${speedKmh.toStringAsFixed(1)} km/h',
      );
    }
  });
}

@pragma('vm:entry-point')
Future<bool> onBgServiceIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

// ---------------------------------------------------------------------------
// BackgroundLocationService
// ---------------------------------------------------------------------------

@pragma('vm:entry-point')
class BackgroundLocationService {
  static final BackgroundLocationService _instance =
      BackgroundLocationService._();
  factory BackgroundLocationService() => _instance;
  BackgroundLocationService._();

  static Future<void> init() async {
    final service = FlutterBackgroundService();
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onBgServiceStart,
        autoStart: false,
        isForegroundMode: false,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onBgServiceStart,
        onBackground: onBgServiceIosBackground,
      ),
    );
  }

  Future<void> startService() async {
    try {
      // Android 13+ requires POST_NOTIFICATIONS to show foreground service notification
      if (Platform.isAndroid) {
        final status = await Permission.notification.status;
        if (!status.isGranted) {
          await Permission.notification.request();
          // If still not granted, skip background service; foreground GPS still works
          if (!await Permission.notification.isGranted) return;
        }
      }
      await FlutterBackgroundService().startService();
    } catch (_) {}
  }

  Future<void> stopService() async {
    try {
      FlutterBackgroundService().invoke('stopService');
    } catch (_) {}
  }

  Future<bool> get isRunning => FlutterBackgroundService().isRunning();
}
