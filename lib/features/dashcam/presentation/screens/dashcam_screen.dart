/// DashcamScreen
/// Professional action-camera / dashcam HUD with loop recording support.
library;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/utils/app_theme.dart';
import '../../../../core/utils/gps_utils.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';
import '../../data/dashcam_clip_repository.dart';
import '../widgets/clip_thumbnail.dart';
import '../widgets/clip_preview_sheet.dart';
import '../controllers/dashcam_controller.dart';

class DashcamScreen extends StatelessWidget {
  DashcamScreen({super.key});

  final DashcamController controller = Get.find<DashcamController>();
  final SettingsController settings = Get.find<SettingsController>();

  Future<void> _openClipLibrary(BuildContext context) async {
    await controller.refreshSavedClips();
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ClipLibrarySheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Camera preview ─────────────────────────────────────────────
          Obx(() {
            if (!controller.isInitialized.value ||
                controller.cameraController == null) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            final cam = controller.cameraController!;
            final previewSize = cam.value.previewSize;
            return SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: previewSize?.height ?? 1080,
                  height: previewSize?.width ?? 1920,
                  child: CameraPreview(cam),
                ),
              ),
            );
          }),

          // ── Top HUD bar ─────────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
                child: Row(
                  children: [
                    // REC indicator or STANDBY
                    Obx(() => controller.isRecording.value
                        ? _RecIndicator(
                            elapsed: controller.totalElapsedSeconds.value)
                        : const Text(
                            'STANDBY',
                            style: TextStyle(
                              color: Colors.white54,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              letterSpacing: 2,
                            ),
                          )),

                    const Spacer(),

                    // "SAVING" badge during clip transition
                    Obx(() => controller.isSwitchingClip.value
                        ? const Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: _PillBadge(
                                label: 'SAVING', color: Colors.orange),
                          )
                        : const SizedBox.shrink()),

                    // Resolution
                    Obx(() => _PillBadge(
                          label: controller.resolutionLabel.value,
                          color: Colors.white24,
                        )),
                    const SizedBox(width: 8),
                    Obx(() => IconButton(
                          onPressed: () => _openClipLibrary(context),
                          tooltip: 'Saved clips',
                          style: IconButton.styleFrom(
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.1),
                          ),
                          icon: Badge.count(
                            isLabelVisible: controller.savedClips.isNotEmpty,
                            count: controller.savedClips.length,
                            backgroundColor: AppColors.primary,
                            textColor: Colors.black,
                            child: const Icon(
                              Icons.video_library_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            left: 16,
            right: 16,
            bottom: 220,
            child: Obx(() {
              final message = controller.lastError.value;
              if (message == null || message.isEmpty) {
                return const SizedBox.shrink();
              }
              return _StatusBanner(
                message: message,
                isCritical: controller.isStorageFull.value,
              );
            }),
          ),

          // ── Bottom overlay (speed + loop info + controls) ───────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Speed badge + lock row
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Speed
                          Obx(() {
                            final unit = settings.speedUnit.value;
                            final kmh =
                                controller.tripController.currentSpeed.value;
                            final disp = unit == SpeedUnit.kmh
                                ? kmh
                                : GpsUtils.kmhToMph(kmh);
                            final label =
                                unit == SpeedUnit.kmh ? 'km/h' : 'mph';
                            return _SpeedBadge(speed: disp, unit: label);
                          }),
                          const Spacer(),

                          Obx(() {
                            if (!controller.isRecording.value) {
                              return const SizedBox.shrink();
                            }
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _EventButton(controller: controller),
                                const SizedBox(width: 10),
                                _LockButton(controller: controller),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),

                    // Loop info card (recording + loop enabled)
                    Obx(() {
                      final recording = controller.isRecording.value;
                      final total = controller.clipTotalSeconds.value;
                      if (!recording || total == 0) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                        child: _LoopInfoCard(controller: controller),
                      );
                    }),

                    // Record button
                    Padding(
                      padding: const EdgeInsets.only(bottom: 28),
                      child: Obx(() => _RecordButton(
                            isRecording: controller.isRecording.value,
                            onTap: controller.toggleRecording,
                          )),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loop Info Card
// ─────────────────────────────────────────────────────────────────────────────

class _LoopInfoCard extends StatelessWidget {
  const _LoopInfoCard({required this.controller});
  final DashcamController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final elapsed = controller.clipElapsedSeconds.value;
      final total = controller.clipTotalSeconds.value;
      final remaining = (total - elapsed).clamp(0, total);
      final progress = total > 0 ? (elapsed / total).clamp(0.0, 1.0) : 0.0;
      final storageMb = controller.storageMbUsed.value;
      final storageStr = storageMb < 1024
          ? '${storageMb.toStringAsFixed(1)} MB'
          : '${(storageMb / 1024).toStringAsFixed(2)} GB';
      final segCount = controller.segmentCount.value;

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: loop label + segment count
            Row(
              children: [
                const Icon(Icons.loop, color: AppColors.primary, size: 13),
                const SizedBox(width: 5),
                Text(
                  '${'loop_recording'.tr}  ${total ~/ 60} min',
                  style: const TextStyle(
                      color: Colors.white60, fontSize: 11, letterSpacing: 0.5),
                ),
                const Spacer(),
                if (segCount > 0)
                  Text(
                    '$segCount clips',
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // Clip timer
            Row(
              children: [
                Text(
                  'current_clip'.tr,
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
                const Spacer(),
                Text(
                  '${DashcamController.formatClock(elapsed)}  /  ${DashcamController.formatClock(total)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'RobotoMono',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 5,
                backgroundColor: Colors.white12,
                valueColor: AlwaysStoppedAnimation(
                  progress < 0.8
                      ? AppColors.primary
                      : progress < 0.95
                          ? Colors.orange
                          : Colors.red,
                ),
              ),
            ),

            const SizedBox(height: 6),

            // Countdown + storage
            Row(
              children: [
                const Icon(Icons.timer_outlined,
                    color: Colors.white38, size: 12),
                const SizedBox(width: 4),
                Text(
                  'next_clip_in'.tr,
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
                const SizedBox(width: 6),
                Text(
                  remaining >= 60
                      ? DashcamController.formatClock(remaining)
                      : '${remaining}s',
                  style: TextStyle(
                    color: remaining <= 10 ? Colors.orange : Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'RobotoMono',
                  ),
                ),
                const Spacer(),
                const Icon(Icons.folder_outlined,
                    color: Colors.white24, size: 12),
                const SizedBox(width: 3),
                Text(storageStr,
                    style:
                        const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.message,
    required this.isCritical,
  });

  final String message;
  final bool isCritical;

  @override
  Widget build(BuildContext context) {
    final accent = isCritical ? Colors.redAccent : Colors.orangeAccent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.65)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCritical ? Icons.warning_amber_rounded : Icons.info_outline,
            color: accent,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _ClipFilter { all, locked, unlocked }

class _ClipLibrarySheet extends StatefulWidget {
  const _ClipLibrarySheet({required this.controller});

  final DashcamController controller;

  @override
  State<_ClipLibrarySheet> createState() => _ClipLibrarySheetState();
}

class _ClipLibrarySheetState extends State<_ClipLibrarySheet> {
  _ClipFilter _filter = _ClipFilter.all;

  List<DashcamClipMetadata> _visibleClips(List<DashcamClipMetadata> clips) {
    switch (_filter) {
      case _ClipFilter.all:
        return clips;
      case _ClipFilter.locked:
        return clips.where((clip) => clip.isLocked).toList();
      case _ClipFilter.unlocked:
        return clips.where((clip) => !clip.isLocked).toList();
    }
  }

  String _storageLabel(int bytes) {
    final megabytes = bytes / (1024 * 1024);
    if (megabytes < 1024) return '${megabytes.toStringAsFixed(1)} MB';
    return '${(megabytes / 1024).toStringAsFixed(2)} GB';
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.68,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF111315),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Saved Clips',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Manage protected clips and storage usage',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Obx(
                      () => Text(
                        '${widget.controller.savedClips.length} clips',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Obx(() {
                final clips = widget.controller.savedClips;
                final lockedCount = clips.where((clip) => clip.isLocked).length;
                final totalBytes =
                    clips.fold<int>(0, (sum, clip) => sum + clip.sizeBytes);
                final lockedBytes = clips
                    .where((clip) => clip.isLocked)
                    .fold<int>(0, (sum, clip) => sum + clip.sizeBytes);

                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _LibraryStatPill(
                              label: 'Stored',
                              value: _storageLabel(totalBytes),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _LibraryStatPill(
                              label: 'Protected',
                              value:
                                  '$lockedCount • ${_storageLabel(lockedBytes)}',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _FilterChipButton(
                              label: 'All',
                              selected: _filter == _ClipFilter.all,
                              onTap: () =>
                                  setState(() => _filter = _ClipFilter.all),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _FilterChipButton(
                              label: 'Locked',
                              selected: _filter == _ClipFilter.locked,
                              onTap: () =>
                                  setState(() => _filter = _ClipFilter.locked),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _FilterChipButton(
                              label: 'Unlocked',
                              selected: _filter == _ClipFilter.unlocked,
                              onTap: () => setState(
                                  () => _filter = _ClipFilter.unlocked),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
              Expanded(
                child: Obx(() {
                  final clips = _visibleClips(widget.controller.savedClips);
                  if (clips.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          _filter == _ClipFilter.all
                              ? 'No saved clips yet. Finalized dashcam segments will appear here.'
                              : 'No clips match the current filter.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 14),
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: clips.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, index) => _ClipTile(
                      controller: widget.controller,
                      clip: clips[index],
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LibraryStatPill extends StatelessWidget {
  const _LibraryStatPill({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({
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
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.18)
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
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _ClipTile extends StatelessWidget {
  const _ClipTile({required this.controller, required this.clip});

  final DashcamController controller;
  final DashcamClipMetadata clip;

  @override
  Widget build(BuildContext context) {
    final sizeMb = clip.sizeBytes / (1024 * 1024);
    final createdLabel = DateFormat('MMM d, HH:mm').format(clip.createdAt);
    final filename = clip.path.split('/').last;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: clip.isLocked
              ? Colors.amber.withValues(alpha: 0.5)
              : Colors.white10,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipThumbnail(path: clip.path),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                clip.isLocked ? Icons.lock : Icons.lock_open_outlined,
                color: clip.isLocked ? Colors.amber : Colors.white38,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  filename,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${sizeMb.toStringAsFixed(1)} MB',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            createdLabel,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          if (clip.incidentType case final incident?) ...[
            const SizedBox(height: 8),
            _IncidentBadge(
              label: incident.label,
              segment: clip.incidentSegment,
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => ClipPreviewSheet(
                        path: clip.path,
                        title: filename,
                        incidentOffsetMs: clip.incidentOffsetMs,
                      ),
                    );
                  },
                  icon: const Icon(Icons.play_circle_outline, size: 16),
                  label: const Text('Preview'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await controller.setClipLocked(clip.path, !clip.isLocked);
                  },
                  icon: Icon(
                    clip.isLocked ? Icons.lock_open : Icons.lock,
                    size: 16,
                  ),
                  label: Text(clip.isLocked ? 'Unlock' : 'Lock'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        clip.isLocked ? Colors.amber : Colors.white,
                    side: BorderSide(
                      color: clip.isLocked ? Colors.amber : Colors.white24,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await Share.shareXFiles(
                      [XFile(clip.path)],
                      subject: 'SpeedLoop dashcam clip',
                    );
                  },
                  icon: const Icon(Icons.share_outlined, size: 16),
                  label: const Text('Share'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        backgroundColor: const Color(0xFF1A1D20),
                        title: const Text('Delete clip'),
                        content: const Text(
                          'This deletes the saved video file from local storage.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await controller.deleteSavedClip(clip.path);
                    }
                  },
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Delete'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red.withValues(alpha: 0.16),
                    foregroundColor: Colors.red.shade200,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IncidentBadge extends StatelessWidget {
  const _IncidentBadge({required this.label, required this.segment});

  final String label;
  final DashcamIncidentSegment? segment;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
      ),
      child: Text(
        'INCIDENT · ${label.toUpperCase()}'
        '${segment == null ? '' : ' · ${segment!.label.toUpperCase()}'}',
        style: TextStyle(
          color: Colors.red.shade200,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HUD widgets
// ─────────────────────────────────────────────────────────────────────────────

class _RecIndicator extends StatelessWidget {
  const _RecIndicator({required this.elapsed});
  final int elapsed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const _BlinkingDot(),
        const SizedBox(width: 6),
        Text(
          'REC  ${DashcamController.formatClock(elapsed)}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
            letterSpacing: 1,
            fontFamily: 'RobotoMono',
          ),
        ),
      ],
    );
  }
}

class _BlinkingDot extends StatefulWidget {
  const _BlinkingDot();

  @override
  State<_BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<_BlinkingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.4 + _anim.value * 0.6),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _PillBadge extends StatelessWidget {
  const _PillBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
            color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _SpeedBadge extends StatelessWidget {
  const _SpeedBadge({required this.speed, required this.unit});
  final double speed;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            speed.toStringAsFixed(0),
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 44,
              fontWeight: FontWeight.w900,
              height: 1.0,
              shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
            ),
          ),
          Text(
            unit,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _LockButton extends StatelessWidget {
  const _LockButton({required this.controller});
  final DashcamController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final locked = controller.isCurrentClipLocked.value;
      return GestureDetector(
        onTap: controller.toggleLock,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: locked
                ? Colors.amber.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.1),
            border: Border.all(
              color: locked ? Colors.amber : Colors.white38,
              width: 2,
            ),
          ),
          child: Icon(
            locked ? Icons.lock : Icons.lock_open_outlined,
            color: locked ? Colors.amber : Colors.white54,
            size: 22,
          ),
        ),
      );
    });
  }
}

class _EventButton extends StatelessWidget {
  const _EventButton({required this.controller});

  final DashcamController controller;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: controller.markEvent,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          color: Colors.red.withValues(alpha: 0.18),
          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.7)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_rounded,
                color: Colors.redAccent, size: 18),
            SizedBox(width: 6),
            Text(
              'EVENT',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordButton extends StatefulWidget {
  const _RecordButton({required this.isRecording, required this.onTap});
  final bool isRecording;
  final VoidCallback onTap;

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
  void didUpdateWidget(_RecordButton old) {
    super.didUpdateWidget(old);
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
          final pulse = widget.isRecording ? 1.0 + _anim.value * 0.08 : 1.0;
          return Transform.scale(
            scale: pulse,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  if (widget.isRecording)
                    BoxShadow(
                      color: Colors.red.withValues(alpha: _anim.value * 0.6),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                ],
              ),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: widget.isRecording ? Colors.red : AppColors.primary,
                  shape:
                      widget.isRecording ? BoxShape.rectangle : BoxShape.circle,
                  borderRadius:
                      widget.isRecording ? BorderRadius.circular(10) : null,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
