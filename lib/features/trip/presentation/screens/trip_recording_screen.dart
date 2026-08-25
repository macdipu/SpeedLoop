/// TripRecordingScreen — Start/Stop trip recording with live stats display.
library;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as flutter_map;
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart' as latlong2;

import '../../../../core/utils/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/gps_utils.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';
import '../controllers/trip_controller.dart';

class TripRecordingScreen extends StatelessWidget {
  TripRecordingScreen({super.key});

  final controller = Get.find<TripController>();
  final settings = Get.find<SettingsController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('trip_recording'.tr),
      ),
      body: Obx(() {
        final state = controller.recordingState.value;
        final recording = state == TripRecordingState.recording ||
            state == TripRecordingState.stopping;
        final transitioning = state == TripRecordingState.starting ||
            state == TripRecordingState.stopping;
        final unit = settings.speedUnit.value;
        final unitLabel = unit == SpeedUnit.kmh ? 'km/h' : 'mph';
        final dispSpeed = unit == SpeedUnit.kmh
            ? controller.currentSpeed.value
            : GpsUtils.kmhToMph(controller.currentSpeed.value);
        final dispMax = unit == SpeedUnit.kmh
            ? controller.maxSpeed.value
            : GpsUtils.kmhToMph(controller.maxSpeed.value);

        if (recording) {
          // ── Active recording layout ─────────────────────────────────
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              children: [
                _RecordButton(
                  isRecording: true,
                  isBusy: transitioning,
                  onTap: transitioning ? null : controller.stopTrip,
                ),
                const SizedBox(height: 24),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.6,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _LiveStatCard(
                      label: 'ELAPSED',
                      value: Formatters.duration(
                          Duration(seconds: controller.elapsedSeconds.value)),
                      icon: Icons.timer,
                      color: AppColors.primary,
                    ),
                    _LiveStatCard(
                      label: 'DISTANCE',
                      value:
                          Formatters.distance(controller.currentDistance.value),
                      icon: Icons.route,
                      color: AppColors.info,
                    ),
                    _LiveStatCard(
                      label: 'SPEED',
                      value: '${dispSpeed.toStringAsFixed(1)} $unitLabel',
                      icon: Icons.speed,
                      color: AppColors.gaugeLow,
                    ),
                    _LiveStatCard(
                      label: 'MAX SPEED',
                      value: '${dispMax.toStringAsFixed(1)} $unitLabel',
                      icon: Icons.flash_on,
                      color: AppColors.accent,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _LiveTripMap(controller: controller),
                  ),
                ),
              ],
            ),
          );
        }

        // ── Idle layout — button + hint centered ───────────────────────
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _RecordButton(
                isRecording: false,
                isBusy: transitioning,
                onTap: transitioning ? null : controller.startTrip,
              ),
              const SizedBox(height: 32),
              Icon(Icons.route_outlined,
                  size: 48, color: context.textDisabledColor),
              const SizedBox(height: 12),
              Text(
                'Press START to begin recording\nyour trip',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: context.textSecondaryColor, fontSize: 16),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------

class _LiveTripMap extends StatefulWidget {
  const _LiveTripMap({required this.controller});
  final TripController controller;

  @override
  State<_LiveTripMap> createState() => _LiveTripMapState();
}

class _LiveTripMapState extends State<_LiveTripMap> {
  late final flutter_map.MapController _mapController;
  bool _mapReady = false;
  Worker? _posWorker;

  @override
  void initState() {
    super.initState();
    _mapController = flutter_map.MapController();
    _posWorker = ever(widget.controller.livePoints, (_) {
      if (_mapReady && widget.controller.livePoints.isNotEmpty) {
        final last = widget.controller.livePoints.last;
        _mapController.move(
          latlong2.LatLng(last.latitude, last.longitude),
          _mapController.camera.zoom,
        );
      }
    });
  }

  @override
  void dispose() {
    _posWorker?.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final points = widget.controller.livePoints;
      final center = points.isNotEmpty
          ? latlong2.LatLng(points.last.latitude, points.last.longitude)
          : const latlong2.LatLng(0, 0);

      return flutter_map.FlutterMap(
        mapController: _mapController,
        options: flutter_map.MapOptions(
          initialCenter: center,
          initialZoom: 16,
          onMapReady: () => _mapReady = true,
          interactionOptions: const flutter_map.InteractionOptions(
            flags: flutter_map.InteractiveFlag.all,
          ),
        ),
        children: [
          flutter_map.TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.chowdhuryelab.speedloop',
          ),
          if (points.length >= 2)
            flutter_map.PolylineLayer(
              polylines: [
                flutter_map.Polyline(
                  points: points
                      .map((p) => latlong2.LatLng(p.latitude, p.longitude))
                      .toList(),
                  color: AppColors.primary,
                  strokeWidth: 4.0,
                ),
              ],
            ),
          if (points.isNotEmpty)
            flutter_map.MarkerLayer(
              markers: [
                flutter_map.Marker(
                  point: center,
                  width: 24,
                  height: 24,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
        ],
      );
    });
  }
}

// ---------------------------------------------------------------------------

class _RecordButton extends StatefulWidget {
  const _RecordButton({
    required this.isRecording,
    required this.isBusy,
    required this.onTap,
  });
  final bool isRecording;
  final bool isBusy;
  final VoidCallback? onTap;

  @override
  State<_RecordButton> createState() => _RecordButtonState();
}

class _RecordButtonState extends State<_RecordButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    if (widget.isRecording) _anim.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_RecordButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !_anim.isAnimating) {
      _anim.repeat(reverse: true);
    } else if (!widget.isRecording && _anim.isAnimating) {
      _anim.stop();
      _anim.value = 0;
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, __) {
          final scale = widget.isRecording ? 1.0 + _anim.value * 0.06 : 1.0;
          return Transform.scale(
            scale: scale,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isRecording
                    ? AppColors.error.withValues(alpha: 0.15)
                    : AppColors.primary.withValues(alpha: 0.15),
                border: Border.all(
                  color:
                      widget.isRecording ? AppColors.error : AppColors.primary,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (widget.isRecording
                            ? AppColors.error
                            : AppColors.primary)
                        .withValues(
                      alpha: widget.isRecording ? _anim.value * 0.5 : 0.3,
                    ),
                    blurRadius: 30,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.isBusy
                        ? Icons.hourglass_top
                        : widget.isRecording
                            ? Icons.stop
                            : Icons.play_arrow,
                    size: 48,
                    color: widget.isRecording
                        ? AppColors.error
                        : AppColors.primary,
                  ),
                  Text(
                    widget.isBusy
                        ? 'WAIT'
                        : widget.isRecording
                            ? 'STOP'
                            : 'START',
                    style: TextStyle(
                      color: widget.isRecording
                          ? AppColors.error
                          : AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _LiveStatCard extends StatelessWidget {
  const _LiveStatCard({
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
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                      color: color,
                      fontSize: 11,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          Text(value,
              style: TextStyle(
                  color: context.textPrimaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
