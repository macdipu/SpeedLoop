/// TripHistoryScreen — list of all recorded trips with summary cards.
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app_pages.dart';
import '../../../../core/utils/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/gps_utils.dart';
import '../../../dashcam/data/dashcam_clip_repository.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';
import '../../domain/entities/trip_entity.dart';
import '../../domain/services/trip_history_insights.dart';
import '../../domain/services/trip_history_media_filter.dart';
import '../controllers/trip_controller.dart';

class TripHistoryScreen extends StatefulWidget {
  const TripHistoryScreen({super.key});

  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> {
  final controller = Get.find<TripController>();
  final settings = Get.find<SettingsController>();
  final insightsBuilder = const TripHistoryInsightsBuilder();
  final mediaFilterService = const TripHistoryMediaFilterService();
  final clipRepository = DriftDashcamClipRepository();

  TripHistoryMediaFilter _selectedFilter = TripHistoryMediaFilter.all;

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
                    color: context.textSecondaryColor,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Go to the Record tab and press START',
                  style: TextStyle(
                    color: context.textDisabledColor,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        }

        final unit = settings.speedUnit.value;
        final insights = insightsBuilder.build(trips);
        final tripIds = trips.map((trip) => trip.id).whereType<int>().toList();
        return FutureBuilder<
            ({
              Map<int, int> clips,
              Map<int, int> protected,
            })>(
          future: () async {
            final clips = await clipRepository.getClipCountsByTripIds(tripIds);
            final protected =
                await clipRepository.getProtectedClipCountsByTripIds(tripIds);
            return (clips: clips, protected: protected);
          }(),
          builder: (context, snapshot) {
            final clipCounts = snapshot.data?.clips ?? const <int, int>{};
            final protectedCounts =
                snapshot.data?.protected ?? const <int, int>{};
            final filteredTrips = mediaFilterService.apply(
              trips: trips,
              clipCounts: clipCounts,
              protectedClipCounts: protectedCounts,
              filter: _selectedFilter,
            );

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _HistoryInsightsCard(insights: insights, unit: unit),
                const SizedBox(height: 16),
                _HistoryFilterRow(
                  selectedFilter: _selectedFilter,
                  onFilterSelected: (filter) {
                    setState(() => _selectedFilter = filter);
                  },
                ),
                const SizedBox(height: 16),
                if (filteredTrips.isEmpty)
                  const _EmptyFilterState()
                else
                  ...List.generate(
                    filteredTrips.length,
                    (i) => Padding(
                      padding: EdgeInsets.only(
                        bottom: i == filteredTrips.length - 1 ? 0 : 12,
                      ),
                      child: _TripCard(
                        trip: filteredTrips[i],
                        unit: unit,
                        clipCount: clipCounts[filteredTrips[i].id] ?? 0,
                        protectedClipCount:
                            protectedCounts[filteredTrips[i].id] ?? 0,
                        onTap: () => Get.toNamed(
                          Routes.tripDetails,
                          arguments: filteredTrips[i].id,
                        ),
                        onDelete: () =>
                            _confirmDelete(context, filteredTrips[i]),
                        onAnalyze: () => Get.toNamed(
                          Routes.tripAnalysis,
                          arguments: filteredTrips[i].id,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      }),
    );
  }

  void _confirmDelete(BuildContext context, TripEntity trip) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: context.cardColor,
        title: Text(
          'delete_trip'.tr,
          style: TextStyle(color: context.textPrimaryColor),
        ),
        content: Text(
          'cannot_undo'.tr,
          style: TextStyle(color: context.textSecondaryColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'cancel'.tr,
              style: TextStyle(color: context.textSecondaryColor),
            ),
          ),
          TextButton(
            onPressed: () {
              controller.deleteTrip(trip.id!);
              Navigator.pop(context);
            },
            child: Text(
              'delete'.tr,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryInsightsCard extends StatelessWidget {
  const _HistoryInsightsCard({
    required this.insights,
    required this.unit,
  });

  final TripHistoryInsights insights;
  final SpeedUnit unit;

  @override
  Widget build(BuildContext context) {
    final topSpeed = unit == SpeedUnit.kmh
        ? insights.topSpeedKmh
        : GpsUtils.kmhToMph(insights.topSpeedKmh);
    final speedLabel = unit == SpeedUnit.kmh ? 'km/h' : 'mph';
    final totalDistance = unit == SpeedUnit.kmh
        ? Formatters.distance(insights.totalDistanceMeters)
        : Formatters.distanceMiles(insights.totalDistanceMeters);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF131A20),
            Color(0xFF1E2A33),
          ],
        ),
        border: Border.all(color: context.cardBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Drive Insights',
            style: TextStyle(
              color: context.textPrimaryColor,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your trip history at a glance',
            style: TextStyle(
              color: context.textSecondaryColor,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _HistoryMetric(
                  label: 'Trips',
                  value: insights.tripCount.toString(),
                  icon: Icons.route,
                ),
              ),
              Expanded(
                child: _HistoryMetric(
                  label: 'Distance',
                  value: totalDistance,
                  icon: Icons.straighten,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _HistoryMetric(
                  label: 'Drive Time',
                  value: Formatters.durationShort(insights.totalDuration),
                  icon: Icons.schedule,
                ),
              ),
              Expanded(
                child: _HistoryMetric(
                  label: 'Top Speed',
                  value: '${topSpeed.toStringAsFixed(1)} $speedLabel',
                  icon: Icons.speed,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HistoryFilterRow extends StatelessWidget {
  const _HistoryFilterRow({
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  final TripHistoryMediaFilter selectedFilter;
  final ValueChanged<TripHistoryMediaFilter> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _HistoryFilterChip(
            label: 'All',
            selected: selectedFilter == TripHistoryMediaFilter.all,
            onTap: () => onFilterSelected(TripHistoryMediaFilter.all),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _HistoryFilterChip(
            label: 'With Clips',
            selected: selectedFilter == TripHistoryMediaFilter.withClips,
            onTap: () => onFilterSelected(TripHistoryMediaFilter.withClips),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _HistoryFilterChip(
            label: 'Incidents',
            selected: selectedFilter == TripHistoryMediaFilter.incidents,
            onTap: () => onFilterSelected(TripHistoryMediaFilter.incidents),
          ),
        ),
      ],
    );
  }
}

class _HistoryFilterChip extends StatelessWidget {
  const _HistoryFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.16)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.white10,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? AppColors.primary : Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _EmptyFilterState extends StatelessWidget {
  const _EmptyFilterState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.cardBorderColor),
      ),
      child: Column(
        children: [
          Icon(Icons.filter_alt_off,
              size: 36, color: context.textDisabledColor),
          const SizedBox(height: 12),
          Text(
            'No trips match this filter.',
            style: TextStyle(
              color: context.textPrimaryColor,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try another filter or keep recording to build trip history.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.textSecondaryColor,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryMetric extends StatelessWidget {
  const _HistoryMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: context.textPrimaryColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: context.textSecondaryColor,
              fontSize: 12,
            ),
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
    required this.clipCount,
    required this.protectedClipCount,
    required this.onTap,
    required this.onDelete,
    required this.onAnalyze,
  });

  final TripEntity trip;
  final SpeedUnit unit;
  final int clipCount;
  final int protectedClipCount;
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
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (clipCount > 0) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.videocam_outlined,
                          color: AppColors.primary,
                          size: 14,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '$clipCount',
                          style: TextStyle(
                            color: context.textPrimaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                if (protectedClipCount > 0) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.redAccent.withValues(alpha: 0.35),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.redAccent,
                          size: 14,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'INCIDENT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                IconButton(
                  onPressed: onAnalyze,
                  icon: Icon(
                    Icons.bar_chart,
                    color: context.primaryColor,
                    size: 20,
                  ),
                  tooltip: 'Analyze',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                    size: 20,
                  ),
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
                ),
                _TripStat(
                  icon: Icons.speed,
                  label: '${avg.toStringAsFixed(1)} $unitLabel avg',
                ),
                _TripStat(
                  icon: Icons.flash_on,
                  label: '${max.toStringAsFixed(1)} $unitLabel max',
                ),
                _TripStat(
                  icon: Icons.timer,
                  label: Formatters.durationShort(trip.duration),
                ),
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
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: context.textSecondaryColor),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(color: context.textSecondaryColor, fontSize: 12),
        ),
      ],
    );
  }
}
