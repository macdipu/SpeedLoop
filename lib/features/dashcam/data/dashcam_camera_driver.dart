import 'dart:math' as math;

import 'package:camera/camera.dart';

abstract class DashcamCameraDriver {
  CameraController? get previewController;
  bool get isInitialized;
  bool get isRecording;
  int? get maxPreviewDimension;

  Future<void> initialize();
  Future<void> startRecording();
  Future<XFile> stopRecording();
  Future<void> dispose();
}

class PluginDashcamCameraDriver implements DashcamCameraDriver {
  CameraController? _controller;

  @override
  CameraController? get previewController => _controller;

  @override
  bool get isInitialized => _controller?.value.isInitialized ?? false;

  @override
  bool get isRecording => _controller?.value.isRecordingVideo ?? false;

  @override
  int? get maxPreviewDimension {
    final size = _controller?.value.previewSize;
    return size == null ? null : math.max(size.width, size.height).toInt();
  }

  @override
  Future<void> initialize() async {
    if (isInitialized) return;
    final cameras = await availableCameras();
    if (cameras.isEmpty) throw StateError('No camera is available.');
    final back = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );
    final controller = CameraController(
      back,
      ResolutionPreset.high,
      enableAudio: true,
    );
    await controller.initialize();
    _controller = controller;
  }

  @override
  Future<void> startRecording() async {
    final controller = _controller;
    if (controller == null) throw StateError('Camera is not initialized.');
    await controller.startVideoRecording();
  }

  @override
  Future<XFile> stopRecording() async {
    final controller = _controller;
    if (controller == null) throw StateError('Camera is not initialized.');
    return controller.stopVideoRecording();
  }

  @override
  Future<void> dispose() async {
    final controller = _controller;
    _controller = null;
    await controller?.dispose();
  }
}
