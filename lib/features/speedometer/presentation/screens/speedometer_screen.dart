/// SpeedometerScreen
/// The main speedometer UI with tab-based switching between:
/// Digital, Analog, HUD, and Map modes.
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_theme.dart';
import '../controllers/speedometer_controller.dart';
import '../widgets/analog_gauge_widget.dart';
import '../widgets/digital_speed_widget.dart';
import '../widgets/hud_overlay_widget.dart';
import '../widgets/map_speedometer_widget.dart';

class SpeedometerScreen extends StatelessWidget {
  SpeedometerScreen({super.key});

  final controller = Get.find<SpeedometerController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.mode.value == SpeedometerMode.hud) {
        return HudOverlayWidget(controller: controller);
      }

      return Scaffold(
        appBar: AppBar(
          title: Text('speedometer'.tr),
          actions: [
            TextButton(
              onPressed: controller.switchUnit,
              child: Obx(() => Text(
                    controller.speedometer.value.unitLabel.toUpperCase(),
                    style: TextStyle(
                      color: context.primaryColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  )),
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => Get.toNamed('/settings'),
            ),
          ],
        ),
        body: Column(
          children: [
            Obx(() => _GpsStatusBar(
                  isConnected: controller.isConnected.value,
                  accuracy: controller.speedometer.value.accuracy,
                  error: controller.errorMessage.value,
                )),
            _ModeTabs(controller: controller),
            Expanded(
              child: Obx(() {
                switch (controller.mode.value) {
                  case SpeedometerMode.digital:
                    return DigitalSpeedWidget(controller: controller);
                  case SpeedometerMode.analog:
                    return AnalogGaugeWidget(controller: controller);
                  case SpeedometerMode.map:
                    return MapSpeedometerWidget(controller: controller);
                  default:
                    return DigitalSpeedWidget(controller: controller);
                }
              }),
            ),
            _StatsBar(controller: controller),
          ],
        ),
      );
    });
  }
}

// ---------------------------------------------------------------------------

class _GpsStatusBar extends StatelessWidget {
  const _GpsStatusBar({
    required this.isConnected,
    required this.accuracy,
    this.error,
  });

  final bool isConnected;
  final double accuracy;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: context.cardColor,
      child: Row(
        children: [
          Icon(
            Icons.gps_fixed,
            size: 16,
            color: isConnected ? AppColors.primary : AppColors.error,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              error != null
                  ? 'GPS Error: $error'
                  : isConnected
                      ? 'GPS Connected  •  ±${accuracy.toStringAsFixed(0)}m'
                      : 'Connecting…',
              style: TextStyle(
                color: context.textSecondaryColor,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _ModeTabs extends StatelessWidget {
  const _ModeTabs({required this.controller});
  final SpeedometerController controller;

  @override
  Widget build(BuildContext context) {
    final modes = [
      (SpeedometerMode.digital, Icons.display_settings_outlined, 'Digital'),
      (SpeedometerMode.analog, Icons.speed, 'Analog'),
      (SpeedometerMode.hud, Icons.remove_red_eye_outlined, 'HUD'),
      (SpeedometerMode.map, Icons.map_outlined, 'Map'),
    ];

    return Container(
      color: context.cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: modes.map((m) {
          return Obx(() {
            final isActive = controller.mode.value == m.$1;
            return GestureDetector(
              onTap: () => controller.setMode(m.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive
                      ? context.primaryColor.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? context.primaryColor : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(m.$2,
                        size: 16,
                        color: isActive
                            ? context.primaryColor
                            : context.textSecondaryColor),
                    const SizedBox(width: 4),
                    Text(
                      m.$3,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? context.primaryColor
                            : context.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        }).toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _StatsBar extends StatelessWidget {
  const _StatsBar({required this.controller});
  final SpeedometerController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final s = controller.speedometer.value;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        color: context.cardColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _StatItem(
              label: 'MAX',
              value: s.maxSpeed.toStringAsFixed(1),
              unit: s.unitLabel,
              color: AppColors.accent,
            ),
            _StatItem(
              label: 'ALT',
              value: s.altitude.toStringAsFixed(0),
              unit: 'm',
              color: AppColors.info,
            ),
            _StatItem(
              label: 'HDG',
              value: s.heading.toStringAsFixed(0),
              unit: '°',
              color: context.primaryColor,
            ),
          ],
        ),
      );
    });
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  final String label, value, unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: TextStyle(
                color: context.textSecondaryColor,
                fontSize: 11,
                letterSpacing: 1.5)),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                  text: value,
                  style: TextStyle(
                      color: color, fontSize: 22, fontWeight: FontWeight.w700)),
              TextSpan(
                  text: ' $unit',
                  style: TextStyle(
                      color: context.textSecondaryColor, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}
