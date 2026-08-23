/// TripDetailsScreen — detailed view of a trip with route map and stats.

import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/utils/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/gpx_utils.dart';
import '../../../../core/utils/gps_utils.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';
import '../../domain/entities/trip_entity.dart';
import '../controllers/trip_controller.dart';

class TripDetailsScreen extends StatefulWidget {
  const TripDetailsScreen({super.key});

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  final controller = Get.find<TripController>();
  final settings = Get.find<SettingsController>();

  TripEntity? trip;
  bool loading = true;

  // Playback
  int _playbackIdx = 0;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    final id = Get.arguments as int?;
    if (id != null) _loadTrip(id);
  }

  Future<void> _loadTrip(int id) async {
    final t = await controller.getTrip(id);
    if (mounted) setState(() { trip = t; loading = false; });
  }

  void _togglePlayback() {
    if (trip == null || trip!.points.isEmpty) return;
    setState(() => _isPlaying = !_isPlaying);
    if (_isPlaying) _runPlayback();
  }

  void _runPlayback() async {
    while (_isPlaying && _playbackIdx < trip!.points.length - 1) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) setState(() => _playbackIdx++);
    }
    if (mounted) setState(() => _isPlaying = false);
  }

  Future<void> _exportGpx() async {
    if (trip == null) return;
    try {
      final xmlString = GpxUtils.generateGpx(trip!);
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/trip_${trip!.startTime.millisecondsSinceEpoch}.gpx';
      final file = File(path);
      await file.writeAsString(xmlString);
      await Share.shareXFiles([XFile(path)], subject: 'GPX Export - Trip');
    } catch (e) {
      Get.snackbar('export_failed'.tr, e.toString(),
          snackPosition: SnackPosition.BOTTOM);

    }
  }

  void _shareCard() {
    if (trip == null) return;
    final unit = settings.speedUnit.value;
    final label = unit == SpeedUnit.kmh ? 'km/h' : 'mph';
    final avg = unit == SpeedUnit.kmh
        ? trip!.avgSpeedKmh
        : GpsUtils.kmhToMph(trip!.avgSpeedKmh);
    final max = unit == SpeedUnit.kmh
        ? trip!.maxSpeedKmh
        : GpsUtils.kmhToMph(trip!.maxSpeedKmh);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SharePreviewSheet(
        trip: trip!,
        avgSpeed: avg,
        maxSpeed: max,
        speedLabel: label,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        body: Center(
            child: CircularProgressIndicator(color: context.primaryColor)),
      );
    }

    if (trip == null) {
      return Scaffold(
        body: Center(
            child: Text('Trip not found',
                style: TextStyle(color: context.textSecondaryColor))),
      );
    }

    final points = trip!.points;
    final latLngs = points.map((p) => LatLng(p.latitude, p.longitude)).toList();
    final center =
        latLngs.isNotEmpty ? latLngs[_playbackIdx] : const LatLng(0, 0);

    return Scaffold(
      appBar: AppBar(
        title: Text(trip!.title ?? 'Trip Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: _shareCard,
            tooltip: 'Share trip',
          ),
          IconButton(
            icon: Icon(Icons.download, color: context.primaryColor),
            onPressed: _exportGpx,
            tooltip: 'export_gpx'.tr,
          ),
          if (points.isNotEmpty)
            IconButton(
              icon: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: context.primaryColor,
              ),
              onPressed: _togglePlayback,
              tooltip: 'Playback route',
            ),
        ],
      ),
      body: Column(
        children: [
          // Map with route
          SizedBox(
            height: 300,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: center,
                initialZoom: 14,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.chowdhuryelab.speedloop',
                ),
                if (latLngs.length >= 2)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: latLngs,
                        color: context.primaryColor,
                        strokeWidth: 3.5,
                      ),
                    ],
                  ),
                if (latLngs.isNotEmpty)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: latLngs.first,
                        width: 28, height: 28,
                        child: const Icon(Icons.circle,
                            color: AppColors.success, size: 20),
                      ),
                      Marker(
                        point: latLngs[_playbackIdx],
                        width: 32, height: 32,
                        child: const Icon(Icons.navigation,
                            color: AppColors.accent, size: 28),
                      ),
                      Marker(
                        point: latLngs.last,
                        width: 28, height: 28,
                        child: const Icon(Icons.flag,
                            color: AppColors.error, size: 24),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Stats
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _statRow(context, 'Start',
                      Formatters.dateTime(trip!.startTime)),
                  _statRow(
                      context,
                      'End',
                      trip!.endTime != null
                          ? Formatters.dateTime(trip!.endTime!)
                          : '—'),
                  _statRow(context, 'Duration',
                      Formatters.duration(trip!.duration)),
                  _statRow(context, 'Distance',
                      Formatters.distance(trip!.distanceMeters)),
                  Obx(() {
                    final unit = settings.speedUnit.value;
                    final label = unit == SpeedUnit.kmh ? 'km/h' : 'mph';
                    final avg = unit == SpeedUnit.kmh
                        ? trip!.avgSpeedKmh
                        : GpsUtils.kmhToMph(trip!.avgSpeedKmh);
                    final max = unit == SpeedUnit.kmh
                        ? trip!.maxSpeedKmh
                        : GpsUtils.kmhToMph(trip!.maxSpeedKmh);
                    return Column(children: [
                      _statRow(context, 'Avg Speed',
                          '${avg.toStringAsFixed(1)} $label'),
                      _statRow(context, 'Max Speed',
                          '${max.toStringAsFixed(1)} $label'),
                    ]);
                  }),
                  _statRow(context, 'GPS Points', '${points.length}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Text(label,
              style: TextStyle(
                  color: context.textSecondaryColor, fontSize: 14)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  color: context.textPrimaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Share Preview Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _SharePreviewSheet extends StatefulWidget {
  const _SharePreviewSheet({
    required this.trip,
    required this.avgSpeed,
    required this.maxSpeed,
    required this.speedLabel,
  });

  final TripEntity trip;
  final double avgSpeed, maxSpeed;
  final String speedLabel;

  @override
  State<_SharePreviewSheet> createState() => _SharePreviewSheetState();
}

class _SharePreviewSheetState extends State<_SharePreviewSheet> {
  final _cardKey = GlobalKey();
  bool _sharing = false;

  Future<void> _doShare() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      final boundary =
          _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final bytes = byteData.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/trip_share_${widget.trip.id ?? 0}.png');
      await file.writeAsBytes(bytes);

      if (mounted) Navigator.of(context).pop();

      await Share.shareXFiles(
        [XFile(file.path)],
        subject:
            'Trip · ${Formatters.distance(widget.trip.distanceMeters)} · ${Formatters.duration(widget.trip.duration)}',
      );
    } catch (e) {
      Get.snackbar('Share Failed', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: context.cardBorderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text('Preview',
                    style: TextStyle(
                        color: context.textPrimaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
                const Spacer(),
                Text('Tap Share to export as image',
                    style: TextStyle(
                        color: context.textDisabledColor, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Card preview — this is what gets captured
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: RepaintBoundary(
              key: _cardKey,
              child: _TripShareCard(
                trip: widget.trip,
                avgSpeed: widget.avgSpeed,
                maxSpeed: widget.maxSpeed,
                speedLabel: widget.speedLabel,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Share button
          Padding(
            padding: EdgeInsets.fromLTRB(
                20, 0, 20, MediaQuery.of(context).padding.bottom + 16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _sharing ? null : _doShare,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: _sharing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child:
                            CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.share_outlined),
                label: Text(_sharing ? 'Saving...' : 'Share',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Share Card — captured as PNG from the preview sheet
// ─────────────────────────────────────────────────────────────────────────────

class _TripShareCard extends StatelessWidget {
  const _TripShareCard({
    required this.trip,
    required this.avgSpeed,
    required this.maxSpeed,
    required this.speedLabel,
  });

  final TripEntity trip;
  final double avgSpeed, maxSpeed;
  final String speedLabel;

  static const _bg1     = Color(0xFF050B1A);
  static const _bg2     = Color(0xFF0C1830);
  static const _surface = Color(0xFF0A1628);
  static const _accent  = Color(0xFF3B82F6);
  static const _violet  = Color(0xFF8B5CF6);
  static const _cyan    = Color(0xFF06B6D4);
  static const _green   = Color(0xFF22C55E);
  static const _red     = Color(0xFFEF4444);
  static const _text    = Colors.white;
  static const _sub     = Color(0xFF8898AA);
  static const _divider = Color(0xFF1A2E45);

  @override
  Widget build(BuildContext context) {
    final points = trip.points
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();

    final dateStr = DateFormat('MMM d, yyyy').format(trip.startTime);
    final timeStr = DateFormat('h:mm a').format(trip.startTime);

    return SizedBox(
      width: 400,
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_bg1, _bg2],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Top gradient bar ───────────────────────────────────────
              Container(
                height: 4,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_accent, _violet, _cyan],
                  ),
                ),
              ),

              // ── Header: branding + date ───────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // App icon circle
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [_accent, _violet],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _accent.withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.speed,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SPEEDLOOP',
                          style: TextStyle(
                            color: _accent,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          trip.title ?? 'Trip Summary',
                          style: const TextStyle(
                            color: _text,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(dateStr,
                            style: const TextStyle(
                                color: _sub,
                                fontSize: 11,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 2),
                        Text(timeStr,
                            style: const TextStyle(
                                color: _sub, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Hero stat: max speed ──────────────────────────────────
              Container(
                width: double.infinity,
                color: _surface,
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Column(
                  children: [
                    Text(
                      'MAX SPEED',
                      style: TextStyle(
                        color: _accent.withValues(alpha: 0.8),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          maxSpeed.toStringAsFixed(1),
                          style: const TextStyle(
                            color: _text,
                            fontSize: 60,
                            fontWeight: FontWeight.w800,
                            height: 1.0,
                            letterSpacing: -2,
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(bottom: 9, left: 8),
                          child: Text(
                            speedLabel,
                            style: TextStyle(
                              color: _accent.withValues(alpha: 0.9),
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Route visualization ────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 230,
                child: Stack(
                  children: [
                    // Background
                    Container(color: const Color(0xFF060E1D)),
                    // Dot grid
                    CustomPaint(
                      size: const Size(400, 230),
                      painter: _DotGridPainter(),
                    ),
                    // Route
                    CustomPaint(
                      size: const Size(400, 230),
                      painter: _RoutePainter(
                        points: points,
                        accent: _accent,
                        cyan: _cyan,
                        green: _green,
                        red: _red,
                      ),
                    ),
                    // Top fade into hero section
                    Positioned(
                      top: 0, left: 0, right: 0,
                      child: Container(
                        height: 28,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [_surface, Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                    // Bottom fade into stats
                    Positioned(
                      bottom: 0, left: 0, right: 0,
                      child: Container(
                        height: 28,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [_bg2, Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                    if (points.isEmpty)
                      const Center(
                        child: Text('No route data',
                            style:
                                TextStyle(color: _sub, fontSize: 13)),
                      ),
                    // Start / End legend
                    if (points.isNotEmpty)
                      Positioned(
                        right: 14,
                        bottom: 14,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _routeLegendItem(_green, 'Start'),
                            const SizedBox(height: 4),
                            _routeLegendItem(_red, 'End'),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // ── 3-stat strip ─────────────────────────────────────────
              Container(
                color: _surface,
                padding: const EdgeInsets.symmetric(
                    vertical: 18, horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                        child: _statCell(
                            'DISTANCE',
                            Formatters.distance(trip.distanceMeters))),
                    _vDivider(),
                    Expanded(
                        child: _statCell(
                            'DURATION',
                            Formatters.duration(trip.duration))),
                    _vDivider(),
                    Expanded(
                        child: _statCell(
                            'AVG SPEED',
                            '${avgSpeed.toStringAsFixed(1)} $speedLabel')),
                  ],
                ),
              ),

              // ── Footer ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                          color: _accent, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'SpeedLoop',
                      style: TextStyle(
                        color: _sub,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                          color: _violet, shape: BoxShape.circle),
                    ),
                  ],
                ),
              ),

              // ── Bottom gradient bar ───────────────────────────────────
              Container(
                height: 4,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_cyan, _violet, _accent],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _routeLegendItem(Color dot, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(
                color: _sub, fontSize: 10, fontWeight: FontWeight.w500)),
      ],
    );
  }

  static Widget _statCell(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _sub,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: _text,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  static Widget _vDivider() {
    return Container(width: 1, height: 38, color: _divider);
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF112035)
      ..strokeWidth = 1;
    const gap = 18.0;
    for (double x = gap / 2; x < size.width; x += gap) {
      for (double y = gap / 2; y < size.height; y += gap) {
        canvas.drawCircle(Offset(x, y), 1.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter _) => false;
}

class _RoutePainter extends CustomPainter {
  const _RoutePainter({
    required this.points,
    required this.accent,
    required this.cyan,
    required this.green,
    required this.red,
  });

  final List<LatLng> points;
  final Color accent, cyan, green, red;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) {
      if (points.length == 1) {
        canvas.drawCircle(Offset(size.width / 2, size.height / 2), 6,
            Paint()..color = green);
      }
      return;
    }

    const pad = 36.0;
    double minLat = points.map((p) => p.latitude).reduce(math.min);
    double maxLat = points.map((p) => p.latitude).reduce(math.max);
    double minLng = points.map((p) => p.longitude).reduce(math.min);
    double maxLng = points.map((p) => p.longitude).reduce(math.max);

    final latSpan = (maxLat - minLat).abs().clamp(0.0001, 360.0);
    final lngSpan = (maxLng - minLng).abs().clamp(0.0001, 360.0);

    final w = size.width - pad * 2;
    final h = size.height - pad * 2;

    final scaleX = w / lngSpan;
    final scaleY = h / latSpan;
    final scale = math.min(scaleX, scaleY);
    final offsetX = pad + (w - lngSpan * scale) / 2;
    final offsetY = pad + (h - latSpan * scale) / 2;

    Offset project(LatLng ll) => Offset(
          offsetX + (ll.longitude - minLng) * scale,
          offsetY + (maxLat - ll.latitude) * scale,
        );

    final first = project(points.first);
    final last = project(points.last);

    final path = ui.Path()..moveTo(first.dx, first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(project(p).dx, project(p).dy);
    }

    // Outer glow (wide, soft)
    canvas.drawPath(
      path,
      Paint()
        ..color = accent.withValues(alpha: 0.12)
        ..strokeWidth = 16
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Inner glow (narrower)
    canvas.drawPath(
      path,
      Paint()
        ..color = accent.withValues(alpha: 0.28)
        ..strokeWidth = 7
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Route line with gradient shader
    final routeRect = Rect.fromPoints(first, last);
    canvas.drawPath(
      path,
      Paint()
        ..shader = ui.Gradient.linear(
          routeRect.topLeft,
          routeRect.bottomRight,
          [accent, cyan],
        )
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Start dot: green ring + white center
    _drawMarker(canvas, first, green);
    // End dot: red ring + white center
    _drawMarker(canvas, last, red);
  }

  void _drawMarker(Canvas canvas, Offset pos, Color color) {
    canvas.drawCircle(pos, 8,
        Paint()..color = color.withValues(alpha: 0.25));
    canvas.drawCircle(pos, 5,
        Paint()..color = color);
    canvas.drawCircle(
        pos,
        3,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(_RoutePainter old) => old.points != points;
}
