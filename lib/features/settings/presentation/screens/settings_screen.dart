/// SettingsScreen — configure speed unit, theme, language, and speed alerts.
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_theme.dart';
import '../../../../core/utils/gps_utils.dart';
import '../controllers/settings_controller.dart';
// LoopDuration is defined in settings_controller.dart

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  final controller = Get.find<SettingsController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('settings'.tr)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Speed Unit
          _SettingsSection(
            title: 'speed_unit'.tr,
            child: Obx(() => Row(
                  children: [
                    _UnitChip(
                      label: 'km/h',
                      selected: controller.speedUnit.value == SpeedUnit.kmh,
                      onTap: () => controller.setSpeedUnit(SpeedUnit.kmh),
                    ),
                    const SizedBox(width: 12),
                    _UnitChip(
                      label: 'mph',
                      selected: controller.speedUnit.value == SpeedUnit.mph,
                      onTap: () => controller.setSpeedUnit(SpeedUnit.mph),
                    ),
                  ],
                )),
          ),

          const SizedBox(height: 16),

          // Theme
          _SettingsSection(
            title: 'theme'.tr,
            child: Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('dark_mode'.tr,
                        style: TextStyle(color: context.textPrimaryColor)),
                    Switch(
                      value: controller.isDarkMode.value,
                      onChanged: (_) => controller.toggleTheme(),
                      activeThumbColor: context.primaryColor,
                    ),
                  ],
                )),
          ),

          const SizedBox(height: 16),

          // Speed Limit Alert
          _SettingsSection(
            title: 'speed_limit_alert'.tr,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'enable_alert'.tr,
                              style: TextStyle(color: context.textPrimaryColor),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              controller.speedAlertEnabled.value
                                  ? 'alert_on'.tr
                                  : 'alert_off'.tr,
                              style: TextStyle(
                                color: context.textSecondaryColor,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: controller.speedAlertEnabled.value,
                          onChanged: (_) => controller.toggleSpeedAlert(),
                          activeThumbColor: AppColors.accent,
                        ),
                      ],
                    )),
                const SizedBox(height: 16),
                Obx(() {
                  final isKmh = controller.speedUnit.value == SpeedUnit.kmh;
                  final limitKmh = controller.speedLimitKmh.value;
                  final displayLimit =
                      isKmh ? limitKmh : GpsUtils.kmhToMph(limitKmh);
                  final unit = isKmh ? 'km/h' : 'mph';
                  final minVal = isKmh ? 20.0 : 10.0;
                  final maxVal = isKmh ? 200.0 : 125.0;
                  final clamped = displayLimit.clamp(minVal, maxVal);
                  final enabled = controller.speedAlertEnabled.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'speed_limit'.tr,
                            style: TextStyle(
                              color: context.textSecondaryColor,
                              fontSize: 13,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: enabled
                                  ? AppColors.accent.withValues(alpha: 0.15)
                                  : context.cardBorderColor
                                      .withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: enabled
                                    ? AppColors.accent
                                    : context.textDisabledColor,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '${clamped.toStringAsFixed(0)} $unit',
                              style: TextStyle(
                                color: enabled
                                    ? AppColors.accent
                                    : context.textSecondaryColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: clamped,
                        min: minVal,
                        max: maxVal,
                        divisions: isKmh ? 36 : 23,
                        activeColor: enabled
                            ? AppColors.accent
                            : context.textDisabledColor,
                        inactiveColor:
                            context.textDisabledColor.withValues(alpha: 0.3),
                        onChanged: enabled
                            ? (val) {
                                final kmh =
                                    isKmh ? val : GpsUtils.mphToKmh(val);
                                controller.setSpeedLimit(kmh);
                              }
                            : null,
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Loop Recording
          _SettingsSection(
            title: 'loop_recording'.tr,
            child: Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'loop_recording_desc'.tr,
                      style: TextStyle(
                          color: context.textDisabledColor, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: LoopDuration.values
                          .map((d) => _UnitChip(
                                label: d.label,
                                selected: controller.loopDuration.value == d,
                                onTap: () => controller.setLoopDuration(d),
                              ))
                          .toList(),
                    ),
                  ],
                )),
          ),

          const SizedBox(height: 16),

          // Language
          _SettingsSection(
            title:
                '${'language'.tr} (${SettingsController.supportedLocales.length})',
            child: Obx(() => Column(
                  children: SettingsController.supportedLocales
                      .map((l) => _LanguageTile(
                            code: l['code'] as String,
                            label: l['label'] as String,
                            selected: controller.locale.value.languageCode ==
                                l['code'],
                            onTap: () => controller
                                .setLocale(Locale(l['code'] as String)),
                          ))
                      .toList(),
                )),
          ),

          const SizedBox(height: 32),

          Center(
            child: Column(
              children: [
                Icon(Icons.speed, color: context.primaryColor, size: 40),
                const SizedBox(height: 8),
                Text('SpeedLoop',
                    style: TextStyle(
                        color: context.textPrimaryColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 16)),
                const SizedBox(height: 4),
                Text('v1.0.0  •  chowdhuryelab',
                    style: TextStyle(
                        color: context.textDisabledColor, fontSize: 12)),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.cardBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: context.textSecondaryColor,
                  fontSize: 12,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _UnitChip extends StatelessWidget {
  const _UnitChip(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? context.primaryColor.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? context.primaryColor : context.textDisabledColor,
            width: 1.5,
          ),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected
                    ? context.primaryColor
                    : context.textSecondaryColor,
                fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.code,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String code, label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        onTap: onTap,
        leading: Text(code.toUpperCase(),
            style: TextStyle(
                color: context.textDisabledColor,
                fontSize: 11,
                fontFamily: 'monospace',
                letterSpacing: 1)),
        title: Text(label,
            style: TextStyle(color: context.textPrimaryColor, fontSize: 14)),
        trailing: selected
            ? Icon(Icons.check_circle, color: context.primaryColor, size: 20)
            : null,
      ),
    );
  }
}
