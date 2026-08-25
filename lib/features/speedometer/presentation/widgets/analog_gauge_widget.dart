/// Analog Gauge Widget — custom-painted speedometer needle gauge.
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_theme.dart';
import '../../../../core/utils/gps_utils.dart';
import '../controllers/speedometer_controller.dart';

class AnalogGaugeWidget extends StatelessWidget {
  const AnalogGaugeWidget({super.key, required this.controller});
  final SpeedometerController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final s = controller.speedometer.value;
      final maxVal = s.unit == SpeedUnit.kmh ? 220.0 : 140.0;
      final fraction = (s.displaySpeed / maxVal).clamp(0.0, 1.0);

      return Container(
        color: context.bgColor,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 300,
                height: 300,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(end: fraction),
                  duration: const Duration(milliseconds: 300),
                  builder: (_, val, __) => CustomPaint(
                    painter: _GaugePainter(
                      fraction: val,
                      isDark: context.isDark,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 60),
                          Text(
                            s.displaySpeed.toStringAsFixed(0),
                            style: TextStyle(
                              color: context.primaryColor,
                              fontSize: 52,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -2,
                            ),
                          ),
                          Text(
                            s.unitLabel.toUpperCase(),
                            style: TextStyle(
                              color: context.textSecondaryColor,
                              fontSize: 14,
                              letterSpacing: 4,
                            ),
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
      );
    });
  }
}

class _GaugePainter extends CustomPainter {
  const _GaugePainter({required this.fraction, required this.isDark});
  final double fraction;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 16;

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..color = isDark ? AppColors.gaugeRing : AppColors.cardLightBorder;

    const startAngle = math.pi * 0.75;
    const sweepAngle = math.pi * 1.5;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      trackPaint,
    );

    if (fraction > 0) {
      final arcColor = fraction < 0.5
          ? AppColors.gaugeLow
          : fraction < 0.8
              ? AppColors.gaugeMid
              : AppColors.gaugeHigh;

      final arcPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          startAngle: startAngle,
          endAngle: startAngle + sweepAngle * fraction,
          colors: [AppColors.gaugeLow, arcColor],
        ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle * fraction,
        false,
        arcPaint,
      );
    }

    // Tick marks
    final tickPaint = Paint()
      ..color =
          (isDark ? AppColors.textDisabled : AppColors.textDisabledOnLight)
              .withValues(alpha: 0.5)
      ..strokeWidth = 1.5;

    for (int i = 0; i <= 10; i++) {
      final angle = startAngle + (sweepAngle * i / 10);
      final outer = Offset(
        center.dx + (radius - 4) * math.cos(angle),
        center.dy + (radius - 4) * math.sin(angle),
      );
      final inner = Offset(
        center.dx + (radius - 18) * math.cos(angle),
        center.dy + (radius - 18) * math.sin(angle),
      );
      canvas.drawLine(inner, outer, tickPaint);
    }

    // Needle
    final needleAngle = startAngle + sweepAngle * fraction;
    final needleEnd = Offset(
      center.dx + (radius - 28) * math.cos(needleAngle),
      center.dy + (radius - 28) * math.sin(needleAngle),
    );
    final needlePaint = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, needleEnd, needlePaint);

    // Center dot
    canvas.drawCircle(
      center,
      8,
      Paint()..color = AppColors.accent,
    );
    canvas.drawCircle(
      center,
      4,
      Paint()..color = isDark ? AppColors.bgDark : AppColors.bgLight,
    );
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.fraction != fraction || old.isDark != isDark;
}
