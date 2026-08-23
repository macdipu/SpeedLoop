/// Map Speedometer Widget — current position on OpenStreetMap with speed overlay.

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_theme.dart';
import '../controllers/speedometer_controller.dart';

class MapSpeedometerWidget extends StatefulWidget {
  const MapSpeedometerWidget({super.key, required this.controller});
  final SpeedometerController controller;

  @override
  State<MapSpeedometerWidget> createState() => _MapSpeedometerWidgetState();
}

class _MapSpeedometerWidgetState extends State<MapSpeedometerWidget> {
  late final MapController _mapController;
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _recenterMap() {
    if (!_isMapReady) return;
    final s = widget.controller.speedometer.value;
    final lat = s.latitude ?? 0.0;
    final lon = s.longitude ?? 0.0;
    _mapController.move(LatLng(lat, lon), _mapController.camera.zoom);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final s = widget.controller.speedometer.value;
      final lat = s.latitude ?? 0.0;
      final lon = s.longitude ?? 0.0;
      final center = LatLng(lat, lon);

      return Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 16,
              onMapReady: () => setState(() => _isMapReady = true),
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.chowdhuryelab.speedloop',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: center,
                    width: 40,
                    height: 40,
                    child: Transform.rotate(
                      angle: s.heading * 3.14159 / 180,
                      child: Icon(
                        Icons.navigation,
                        color: context.primaryColor,
                        size: 36,
                        shadows: const [
                          Shadow(color: Colors.black54, blurRadius: 8)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Recenter FAB
          Positioned(
            top: 24,
            right: 24,
            child: SafeArea(
              child: FloatingActionButton(
                heroTag: 'map_recenter_fab',
                onPressed: _recenterMap,
                backgroundColor: context.cardColor,
                foregroundColor: context.primaryColor,
                mini: true,
                elevation: 4,
                child: const Icon(Icons.my_location),
              ),
            ),
          ),

          // Speed overlay card
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  color: context.cardColor.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: context.primaryColor.withOpacity(0.3)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      s.displaySpeed.toStringAsFixed(0),
                      style: TextStyle(
                        color: context.primaryColor,
                        fontSize: 56,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      s.unitLabel.toUpperCase(),
                      style: TextStyle(
                        color: context.textSecondaryColor,
                        fontSize: 14,
                        letterSpacing: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
