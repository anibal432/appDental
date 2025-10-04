// lib/ai_dental/services/camera_service.dart
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

class CameraService {
  CameraController? controller;
  List<CameraDescription>? cameras;

  Future<void> initializeCamera() async {
    try {
      cameras = await availableCameras();
      controller = CameraController(
        cameras!.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller!.initialize();
    } catch (e) {
      debugPrint('Error inicializando cámara: $e');
      rethrow;
    }
  }

  Future<XFile?> takePicture() async {
    if (controller == null || !controller!.value.isInitialized) {
      debugPrint('Cámara no inicializada');
      return null;
    }

    try {
      return await controller!.takePicture();
    } catch (e) {
      debugPrint('Error tomando foto: $e');
      return null;
    }
  }

  void dispose() {
    controller?.dispose();
  }
}
