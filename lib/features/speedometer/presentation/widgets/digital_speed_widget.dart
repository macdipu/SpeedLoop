/// Digital Speed Widget — large numeric display with animated speed bar.
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_theme.dart';
import '../../../../core/utils/gps_utils.dart';
import '../controllers/speedometer_controller.dart';

class DigitalSpeedWidget extends StatelessWidget {
  const DigitalSpeedWidget({super.key, required this.controller});
  final SpeedometerController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final s = controller.speedometer.value;
      final speed = s.displaySpeed;

      return Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: context.isDark
                ? [const Color(0xFF1A2035), AppColors.bgDark]
                : [const Color(0xFFEBF4F0), AppColors.bgLight],
            radius: 1.2,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(end: speed),
                duration: const Duration(milliseconds: 300),
                builder: (_, val, __) => Text(
                  val.toStringAsFixed(0),
                  style: TextStyle(
                    color: context.primaryColor,
                    fontSize: 96,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -4,
                    height: 1.0,
                  ),
                ),
              ),
              Text(
                s.unitLabel.toUpperCase(),
                style: TextStyle(
                  color: context.textSecondaryColor,
                  fontSize: 18,
                  letterSpacing: 6,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 32),
              _SpeedBar(
                speed: speed,
                maxDisplay: s.unit == SpeedUnit.kmh ? 220 : 140,
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _SpeedBar extends StatelessWidget {
  const _SpeedBar({required this.speed, required this.maxDisplay});
  final double speed;
  final double maxDisplay;

  @override
  Widget build(BuildContext context) {
    final fraction = (speed / maxDisplay).clamp(0.0, 1.0);
    final color = fraction < 0.5
        ? AppColors.gaugeLow
        : fraction < 0.8
            ? AppColors.gaugeMid
            : AppColors.gaugeHigh;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: fraction),
              duration: const Duration(milliseconds: 300),
              builder: (_, val, __) => LinearProgressIndicator(
                value: val,
                minHeight: 8,
                backgroundColor: context.cardBorderColor,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0',
                  style: TextStyle(
                      color: context.textDisabledColor, fontSize: 11)),
              Text('${maxDisplay.toInt()}',
                  style: TextStyle(
                      color: context.textDisabledColor, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
