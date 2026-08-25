/// TripHistoryScreen — list of all recorded trips with summary cards.
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app_pages.dart';
import '../../../../core/utils/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/gps_utils.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';
import '../../domain/entities/trip_entity.dart';
import '../controllers/trip_controller.dart';

class TripHistoryScreen extends StatelessWidget {
  TripHistoryScreen({super.key});

  final controller = Get.find<TripController>();
  final settings = Get.find<SettingsController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('trips'.tr),
        actions: [
          IconButton(
            icon: Icon(Icons.file_upload_outlined, color: context.primaryColor),
            onPressed: controller.importGpx,
            tooltip: 'import_gpx'.tr,
          ),
        ],
      ),
      body: Obx(() {
        final trips = controller.trips;
        if (trips.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.route, size: 72, color: context.textDisabledColor),
                const SizedBox(height: 16),
                Text(
                  'no_trips'.tr,
                  style: TextStyle(
                      color: context.textSecondaryColor, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Go to the Record tab and press START',
                  style:
                      TextStyle(color: context.textDisabledColor, fontSize: 13),
                ),
              ],
            ),
          );
        }

        final unit = settings.speedUnit.value;
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: trips.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) => _TripCard(
            trip: trips[i],
            unit: unit,
            onTap: () => Get.toNamed(
              Routes.tripDetails,
              arguments: trips[i].id,
            ),
            onDelete: () => _confirmDelete(context, trips[i]),
            onAnalyze: () => Get.toNamed(
              Routes.tripAnalysis,
              arguments: trips[i].id,
            ),
          ),
        );
      }),
    );
  }

  void _confirmDelete(BuildContext context, TripEntity trip) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.cardColor,
        title: Text('delete_trip'.tr,
            style: TextStyle(color: context.textPrimaryColor)),
        content: Text('cannot_undo'.tr,
            style: TextStyle(color: context.textSecondaryColor)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr,
                style: TextStyle(color: context.textSecondaryColor)),
          ),
          TextButton(
            onPressed: () {
              controller.deleteTrip(trip.id!);
              Navigator.pop(context);
            },
            child: Text('delete'.tr,
                style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({
    required this.trip,
    required this.unit,
    required this.onTap,
    required this.onDelete,
    required this.onAnalyze,
  });

  final TripEntity trip;
  final SpeedUnit unit;
  final VoidCallback onTap, onDelete, onAnalyze;

  @override
  Widget build(BuildContext context) {
    final unitLabel = unit == SpeedUnit.kmh ? 'km/h' : 'mph';
    final avg = unit == SpeedUnit.kmh
        ? trip.avgSpeedKmh
        : GpsUtils.kmhToMph(trip.avgSpeedKmh);
    final max = unit == SpeedUnit.kmh
        ? trip.maxSpeedKmh
        : GpsUtils.kmhToMph(trip.maxSpeedKmh);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.cardBorderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    trip.title ?? Formatters.dateTime(trip.startTime),
                    style: TextStyle(
                        color: context.textPrimaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  onPressed: onAnalyze,
                  icon: Icon(Icons.bar_chart,
                      color: context.primaryColor, size: 20),
                  tooltip: 'Analyze',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline,
                      color: AppColors.error, size: 20),
                  tooltip: 'Delete',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _TripStat(
                    icon: Icons.route,
                    label: Formatters.distance(trip.distanceMeters),
                    context: context),
                _TripStat(
                    icon: Icons.speed,
                    label: '${avg.toStringAsFixed(1)} $unitLabel avg',
                    context: context),
                _TripStat(
                    icon: Icons.flash_on,
                    label: '${max.toStringAsFixed(1)} $unitLabel max',
                    context: context),
                _TripStat(
                    icon: Icons.timer,
                    label: Formatters.durationShort(trip.duration),
                    context: context),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TripStat extends StatelessWidget {
  const _TripStat({
    required this.icon,
    required this.label,
    required this.context,
  });
  final IconData icon;
  final String label;
  // ignore: unused_field
  final BuildContext context;

  @override
  Widget build(BuildContext ctx) {
    return Row(
      children: [
        Icon(icon, size: 14, color: ctx.textSecondaryColor),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(color: ctx.textSecondaryColor, fontSize: 12)),
      ],
    );
  }
}
