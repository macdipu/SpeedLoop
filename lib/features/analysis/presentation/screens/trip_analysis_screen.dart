/// TripAnalysisScreen — shows acceleration stats, top speed, and segment breakdown.
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/gps_utils.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';
import '../controllers/analysis_controller.dart';

class TripAnalysisScreen extends StatefulWidget {
  const TripAnalysisScreen({super.key});

  @override
  State<TripAnalysisScreen> createState() => _TripAnalysisScreenState();
}

class _TripAnalysisScreenState extends State<TripAnalysisScreen> {
  final controller = Get.find<AnalysisController>();
  final settings = Get.find<SettingsController>();

  @override
  void initState() {
    super.initState();
    final id = Get.arguments as int?;
    if (id != null) controller.analyzeTrip(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('trip_analysis'.tr)),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
              child: CircularProgressIndicator(color: context.primaryColor));
        }

        final result = controller.analysisResult.value;
        if (result == null) {
          return Center(
            child: Text('No data',
                style: TextStyle(color: context.textSecondaryColor)),
          );
        }

        final unit = settings.speedUnit.value;
        final unitLabel = unit == SpeedUnit.kmh ? 'km/h' : 'mph';
        final topSpeed = unit == SpeedUnit.kmh
            ? result.topSpeedKmh
            : GpsUtils.kmhToMph(result.topSpeedKmh);
        final avgSpeed = unit == SpeedUnit.kmh
            ? result.avgSpeedKmh
            : GpsUtils.kmhToMph(result.avgSpeedKmh);

        final acc60Label = unit == SpeedUnit.kmh
            ? '0 → 60 km/h'
            : '0 → ${GpsUtils.kmhToMph(60).toStringAsFixed(0)} mph';
        final acc100Label = unit == SpeedUnit.kmh
            ? '0 → 100 km/h'
            : '0 → ${GpsUtils.kmhToMph(100).toStringAsFixed(0)} mph';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader('overview'.tr),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.6,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _AnalysisCard(
                    label: 'TOP SPEED',
                    value: '${topSpeed.toStringAsFixed(1)} $unitLabel',
                    icon: Icons.flash_on,
                    color: AppColors.accent,
                  ),
                  _AnalysisCard(
                    label: 'AVG SPEED',
                    value: '${avgSpeed.toStringAsFixed(1)} $unitLabel',
                    icon: Icons.speed,
                    color: context.primaryColor,
                  ),
                  _AnalysisCard(
                    label: 'DISTANCE',
                    value: Formatters.distance(result.totalDistanceMeters),
                    icon: Icons.route,
                    color: AppColors.info,
                  ),
                  _AnalysisCard(
                    label: 'DURATION',
                    value: Formatters.durationShort(
                        Duration(seconds: result.durationSeconds)),
                    icon: Icons.timer,
                    color: AppColors.gaugeLow,
                  ),
                ],
              ),
              const SizedBox(height: 28),
              _SectionHeader('acceleration'.tr),
              const SizedBox(height: 12),
              _AccelerationCard(
                label: acc60Label,
                event: result.acceleration0to60,
              ),
              const SizedBox(height: 12),
              _AccelerationCard(
                label: acc100Label,
                event: result.acceleration0to100,
              ),
              const SizedBox(height: 28),
              if (result.segments.isNotEmpty) ...[
                _SectionHeader('segment_breakdown'.tr),
                const SizedBox(height: 12),
                ...result.segments.map((seg) {
                  final segAvg = unit == SpeedUnit.kmh
                      ? seg.avgSpeedKmh
                      : GpsUtils.kmhToMph(seg.avgSpeedKmh);
                  final segMax = unit == SpeedUnit.kmh
                      ? seg.maxSpeedKmh
                      : GpsUtils.kmhToMph(seg.maxSpeedKmh);
                  return _SegmentRow(
                    number: seg.segmentNumber,
                    avgLabel: '${segAvg.toStringAsFixed(1)} $unitLabel avg',
                    maxLabel: '${segMax.toStringAsFixed(1)} $unitLabel max',
                  );
                }),
              ],
            ],
          ),
        );
      }),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(
            color: context.textPrimaryColor,
            fontSize: 18,
            fontWeight: FontWeight.w700));
  }
}

class _AnalysisCard extends StatelessWidget {
  const _AnalysisCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label, value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(label,
                  style: TextStyle(
                      color: color,
                      fontSize: 10,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w600)),
            ),
          ]),
          Text(value,
              style: TextStyle(
                  color: context.textPrimaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _AccelerationCard extends StatelessWidget {
  const _AccelerationCard({required this.label, required this.event});
  final String label;
  final dynamic event;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.cardBorderColor),
      ),
      child: Row(
        children: [
          const Icon(Icons.electric_bolt, color: AppColors.accent, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style:
                    TextStyle(color: context.textPrimaryColor, fontSize: 15)),
          ),
          event != null
              ? Text(
                  '${event.seconds.toStringAsFixed(2)} s',
                  style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 20,
                      fontWeight: FontWeight.w800),
                )
              : Text('not_detected'.tr,
                  style: TextStyle(
                      color: context.textDisabledColor, fontSize: 13)),
        ],
      ),
    );
  }
}

class _SegmentRow extends StatelessWidget {
  const _SegmentRow({
    required this.number,
    required this.avgLabel,
    required this.maxLabel,
  });

  final int number;
  final String avgLabel, maxLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.cardBorderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
                color: context.primaryColor.withValues(alpha: 0.15),
                shape: BoxShape.circle),
            child: Center(
              child: Text('$number',
                  style: TextStyle(
                      color: context.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              avgLabel,
              style: TextStyle(color: context.textSecondaryColor, fontSize: 13),
            ),
          ),
          Text(
            maxLabel,
            style: const TextStyle(
                color: AppColors.accent,
                fontSize: 13,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
