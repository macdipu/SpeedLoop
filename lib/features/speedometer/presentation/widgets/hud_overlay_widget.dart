/// HUD Overlay Widget — neon green speed overlay, designed to reflect in windshield.
/// Full-screen black background with mirrored/flipped text for HUD projection.
/// Phase 7: Shows a red warning indicator when speed limit is exceeded.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_theme.dart';
import '../../../../core/utils/gps_utils.dart';
import '../controllers/speedometer_controller.dart';
import '../../../../features/settings/presentation/controllers/settings_controller.dart';

class HudOverlayWidget extends StatefulWidget {
  const HudOverlayWidget({super.key, required this.controller});
  final SpeedometerController controller;

  @override
  State<HudOverlayWidget> createState() => _HudOverlayWidgetState();
}

class _HudOverlayWidgetState extends State<HudOverlayWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _warnAnim;
  late final Animation<double> _warnOpacity;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Pulsing animation for speed warning
    _warnAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _warnOpacity = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _warnAnim, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _warnAnim.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();

    return GestureDetector(
      onTap: () => widget.controller.setMode(SpeedometerMode.digital),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Obx(() {
          final s = widget.controller.speedometer.value;

          // Check if speed exceeds limit
          final speedKmh = GpsUtils.msToKmh(s.speedMs);
          final limitKmh = settings.speedLimitKmh.value;
          final alertEnabled = settings.speedAlertEnabled.value;
          final isOverLimit = alertEnabled && speedKmh > limitKmh;
          final unit = settings.speedUnit.value;
          final limitDisplay =
              unit == SpeedUnit.kmh ? limitKmh : GpsUtils.kmhToMph(limitKmh);
          final unitLabel = unit == SpeedUnit.kmh ? 'km/h' : 'mph';
          return Stack(
            children: [
              Transform(
                // Mirror horizontally for HUD windshield reflection
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..scaleByDouble(-1.0, 1.0, 1.0, 1.0),
                child: Stack(
                  children: [
                    // Main speed display
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Speed number
                          Text(
                            s.displaySpeed.toStringAsFixed(0),
                            style: TextStyle(
                              color: isOverLimit
                                  ? AppColors.error
                                  : AppColors.hudGreen,
                              fontSize: 120,
                              fontWeight: FontWeight.w900,
                              shadows: [
                                Shadow(
                                  color: isOverLimit
                                      ? AppColors.error
                                      : AppColors.hudGreen,
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                          ),
                          // Unit label
                          Text(
                            s.unitLabel.toUpperCase(),
                            style: TextStyle(
                              color: isOverLimit
                                  ? AppColors.error
                                  : AppColors.hudGreen,
                              fontSize: 28,
                              letterSpacing: 12,
                              shadows: [
                                Shadow(
                                  color: isOverLimit
                                      ? AppColors.error
                                      : AppColors.hudGreen,
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Heading info
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.navigation,
                                color:
                                    AppColors.hudGreen.withValues(alpha: 0.6),
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${s.heading.toStringAsFixed(0)}°',
                                style: TextStyle(
                                  color:
                                      AppColors.hudGreen.withValues(alpha: 0.6),
                                  fontSize: 18,
                                  letterSpacing: 4,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Icon(
                                Icons.terrain,
                                color:
                                    AppColors.hudGreen.withValues(alpha: 0.6),
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${s.altitude.toStringAsFixed(0)}m',
                                style: TextStyle(
                                  color:
                                      AppColors.hudGreen.withValues(alpha: 0.6),
                                  fontSize: 18,
                                  letterSpacing: 4,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Speed limit warning overlay (Phase 7)
                    if (isOverLimit)
                      Positioned(
                        top: 20,
                        right: 20,
                        child: AnimatedBuilder(
                          animation: _warnOpacity,
                          builder: (_, __) => Opacity(
                            opacity: _warnOpacity.value,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.error,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.warning_amber_rounded,
                                      color: AppColors.error, size: 18),
                                  const SizedBox(width: 6),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'OVER LIMIT',
                                        style: TextStyle(
                                          color: AppColors.error,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                      Text(
                                        '${limitDisplay.toStringAsFixed(0)} $unitLabel',
                                        style: const TextStyle(
                                          color: AppColors.error,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Explicit, un-mirrored close button
              Positioned(
                top: 24,
                left: 24,
                child: SafeArea(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () =>
                          widget.controller.setMode(SpeedometerMode.digital),
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.hudGreen.withValues(alpha: 0.5),
                          ),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: AppColors.hudGreen,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
