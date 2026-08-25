library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

Duration incidentPreviewStart({
  required int incidentOffsetMs,
  required Duration duration,
  Duration contextLead = const Duration(seconds: 2),
}) {
  final contextualStartMs = incidentOffsetMs - contextLead.inMilliseconds;
  final boundedMs = contextualStartMs.clamp(0, duration.inMilliseconds).toInt();
  return Duration(milliseconds: boundedMs);
}

class ClipPreviewSheet extends StatefulWidget {
  const ClipPreviewSheet({
    super.key,
    required this.path,
    required this.title,
    this.incidentOffsetMs,
  });

  final String path;
  final String title;
  final int? incidentOffsetMs;

  @override
  State<ClipPreviewSheet> createState() => _ClipPreviewSheetState();
}

class _ClipPreviewSheetState extends State<ClipPreviewSheet> {
  late final VideoPlayerController _controller;
  late final Future<void> _initializeFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.path));
    _initializeFuture = _initialize();
  }

  Future<void> _initialize() async {
    await _controller.initialize();
    final incidentOffsetMs = widget.incidentOffsetMs;
    if (incidentOffsetMs == null) return;
    await _controller.seekTo(
      incidentPreviewStart(
        incidentOffsetMs: incidentOffsetMs,
        duration: _controller.value.duration,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111315),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: Colors.white12),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FutureBuilder<void>(
                future: _initializeFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return const AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Center(
                        child: Text(
                          'This clip could not be opened.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    );
                  }
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio == 0
                          ? 16 / 9
                          : _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
              if (widget.incidentOffsetMs case final offset?) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Incident at ${_formatDuration(Duration(milliseconds: offset))}',
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
              ],
              ValueListenableBuilder<VideoPlayerValue>(
                valueListenable: _controller,
                builder: (context, value, _) {
                  if (!value.isInitialized) return const SizedBox.shrink();
                  final durationMs = value.duration.inMilliseconds;
                  final positionMs = value.position.inMilliseconds.clamp(
                    0,
                    durationMs == 0 ? 0 : durationMs,
                  );
                  return Column(
                    children: [
                      Slider(
                        value: durationMs == 0 ? 0 : positionMs / durationMs,
                        onChanged: (fraction) {
                          final targetMs = (durationMs * fraction).round();
                          _controller.seekTo(Duration(milliseconds: targetMs));
                        },
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              if (value.isPlaying) {
                                _controller.pause();
                              } else {
                                _controller.play();
                              }
                            },
                            icon: Icon(
                              value.isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            _formatDuration(value.position),
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const Text(
                            ' / ',
                            style: TextStyle(color: Colors.white38),
                          ),
                          Text(
                            _formatDuration(value.duration),
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
