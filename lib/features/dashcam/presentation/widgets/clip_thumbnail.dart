import 'dart:io';

import 'package:flutter/material.dart';

import '../../data/dashcam_thumbnail_service.dart';

class ClipThumbnail extends StatefulWidget {
  const ClipThumbnail({
    required this.path,
    this.height = 120,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    super.key,
  });

  final String path;
  final double height;
  final BorderRadius borderRadius;

  @override
  State<ClipThumbnail> createState() => _ClipThumbnailState();
}

class _ClipThumbnailState extends State<ClipThumbnail> {
  late Future<File?> _thumbnail;

  @override
  void initState() {
    super.initState();
    _thumbnail = DashcamThumbnailService.instance.thumbnailFor(widget.path);
  }

  @override
  void didUpdateWidget(covariant ClipThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      _thumbnail = DashcamThumbnailService.instance.thumbnailFor(widget.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: SizedBox(
        width: double.infinity,
        height: widget.height,
        child: FutureBuilder<File?>(
          future: _thumbnail,
          builder: (context, snapshot) {
            final thumbnail = snapshot.data;
            return Stack(
              fit: StackFit.expand,
              children: [
                if (thumbnail != null)
                  Image.file(
                    thumbnail,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const _ThumbnailFallback(),
                  )
                else
                  const _ThumbnailFallback(),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.45),
                      ],
                    ),
                  ),
                ),
                const Center(
                  child: Icon(
                    Icons.play_circle_fill,
                    color: Colors.white70,
                    size: 38,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ThumbnailFallback extends StatelessWidget {
  const _ThumbnailFallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Colors.black26,
      child: Center(
        child: Icon(Icons.videocam_outlined, color: Colors.white38, size: 34),
      ),
    );
  }
}
