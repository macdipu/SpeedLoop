/// SettingsController — GetX Controller
/// Manages user preferences: speed unit, theme, language, speed alerts, loop recording.
/// Persists settings using Shared Preferences.
library;

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/utils/gps_utils.dart';

// ---------------------------------------------------------------------------
// Loop Recording duration enum
// ---------------------------------------------------------------------------

enum LoopDuration { off, one, three, five, ten }

extension LoopDurationX on LoopDuration {
  int get minutes => const [0, 1, 3, 5, 10][index];

  String get label {
    switch (this) {
      case LoopDuration.off:
        return 'Off';
      case LoopDuration.one:
        return '1 min';
      case LoopDuration.three:
        return '3 min';
      case LoopDuration.five:
        return '5 min';
      case LoopDuration.ten:
        return '10 min';
    }
  }
}

// ---------------------------------------------------------------------------
// SettingsController
// ---------------------------------------------------------------------------

class SettingsController extends GetxController {
  late final SharedPreferences _prefs;

  // --------------------------------------------------------------------------
  // Reactive state
  // --------------------------------------------------------------------------
  final speedUnit = SpeedUnit.kmh.obs;
  final isDarkMode = true.obs;
  final locale = const Locale('en').obs;

  final speedAlertEnabled = false.obs;
  final speedLimitKmh = 120.0.obs;

  final loopDuration = LoopDuration.off.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();

    final unitIndex = _prefs.getInt('speedUnit') ?? 0;
    speedUnit.value = SpeedUnit.values[unitIndex];

    isDarkMode.value = _prefs.getBool('isDarkMode') ?? true;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);

    final localeCode = _prefs.getString('locale') ?? 'en';
    locale.value = Locale(localeCode);
    Get.updateLocale(locale.value);

    speedAlertEnabled.value = _prefs.getBool('speedAlertEnabled') ?? false;
    speedLimitKmh.value = _prefs.getDouble('speedLimitKmh') ?? 120.0;

    final loopIndex = _prefs.getInt('loopDuration') ?? 0;
    loopDuration.value =
        LoopDuration.values[loopIndex.clamp(0, LoopDuration.values.length - 1)];
  }

  // --------------------------------------------------------------------------
  // Speed unit
  // --------------------------------------------------------------------------

  void setSpeedUnit(SpeedUnit unit) {
    speedUnit.value = unit;
    _prefs.setInt('speedUnit', unit.index);
  }

  void toggleSpeedUnit() {
    final newUnit =
        speedUnit.value == SpeedUnit.kmh ? SpeedUnit.mph : SpeedUnit.kmh;
    setSpeedUnit(newUnit);
  }

  String get speedUnitLabel =>
      speedUnit.value == SpeedUnit.kmh ? 'km/h' : 'mph';

  // --------------------------------------------------------------------------
  // Theme
  // --------------------------------------------------------------------------

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    _prefs.setBool('isDarkMode', isDarkMode.value);
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  // --------------------------------------------------------------------------
  // Language
  // --------------------------------------------------------------------------

  void setLocale(Locale l) {
    locale.value = l;
    _prefs.setString('locale', l.languageCode);
    Get.updateLocale(l);
  }

  // --------------------------------------------------------------------------
  // Speed Limit Alerts
  // --------------------------------------------------------------------------

  void toggleSpeedAlert() {
    speedAlertEnabled.value = !speedAlertEnabled.value;
    _prefs.setBool('speedAlertEnabled', speedAlertEnabled.value);
  }

  void setSpeedLimit(double kmh) {
    speedLimitKmh.value = kmh;
    _prefs.setDouble('speedLimitKmh', kmh);
  }

  // --------------------------------------------------------------------------
  // Loop Recording
  // --------------------------------------------------------------------------

  void setLoopDuration(LoopDuration d) {
    loopDuration.value = d;
    _prefs.setInt('loopDuration', d.index);
  }

  // --------------------------------------------------------------------------
  // Supported locales
  // --------------------------------------------------------------------------

  static const List<Map<String, dynamic>> supportedLocales = [
    {'code': 'en', 'label': 'English'},
    {'code': 'es', 'label': 'Español'},
    {'code': 'fr', 'label': 'Français'},
    {'code': 'de', 'label': 'Deutsch'},
    {'code': 'it', 'label': 'Italiano'},
    {'code': 'pt', 'label': 'Português'},
    {'code': 'ru', 'label': 'Русский'},
    {'code': 'zh', 'label': '中文'},
    {'code': 'ja', 'label': '日本語'},
    {'code': 'ko', 'label': '한국어'},
    {'code': 'ar', 'label': 'العربية'},
    {'code': 'hi', 'label': 'हिन्दी'},
    {'code': 'bn', 'label': 'বাংলা'},
    {'code': 'tr', 'label': 'Türkçe'},
    {'code': 'nl', 'label': 'Nederlands'},
    {'code': 'pl', 'label': 'Polski'},
    {'code': 'sv', 'label': 'Svenska'},
    {'code': 'da', 'label': 'Dansk'},
    {'code': 'fi', 'label': 'Suomi'},
    {'code': 'nb', 'label': 'Norsk'},
    {'code': 'cs', 'label': 'Čeština'},
    {'code': 'sk', 'label': 'Slovenčina'},
    {'code': 'hu', 'label': 'Magyar'},
    {'code': 'ro', 'label': 'Română'},
    {'code': 'bg', 'label': 'Български'},
    {'code': 'uk', 'label': 'Українська'},
    {'code': 'id', 'label': 'Bahasa Indonesia'},
    {'code': 'ms', 'label': 'Bahasa Melayu'},
    {'code': 'vi', 'label': 'Tiếng Việt'},
    {'code': 'th', 'label': 'ภาษาไทย'},
  ];
}
