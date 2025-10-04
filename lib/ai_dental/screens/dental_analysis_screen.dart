// lib/ai_dental/screens/dental_analysis_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import '../services/dental_ai_service.dart';
import '../services/camera_service.dart';
import 'analysis_results_screen.dart';

class DentalAnalysisScreen extends StatefulWidget {
  const DentalAnalysisScreen({super.key});

  @override
  State<DentalAnalysisScreen> createState() => _DentalAnalysisScreenState();
}

class _DentalAnalysisScreenState extends State<DentalAnalysisScreen> {
  final DentalAiService _aiService = DentalAiService();
  final CameraService _cameraService = CameraService();
  final ImagePicker _imagePicker = ImagePicker();

  bool _isLoading = false;
  bool _cameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _aiService.loadModel();
  }

  Future<void> _initializeCamera() async {
    try {
      await _cameraService.initializeCamera();
      setState(() {
        _cameraInitialized = true;
      });
    } catch (e) {
      debugPrint('Error inicializando cámara: $e');
    }
  }

  Future<void> _takePhoto() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final XFile? photo = await _cameraService.takePicture();
      if (photo != null) {
        _analyzeImage(File(photo.path));
      }
    } catch (e) {
      _showError('Error tomando foto: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        _analyzeImage(File(image.path));
      }
    } catch (e) {
      _showError('Error seleccionando imagen: $e');
    }
  }

  Future<void> _analyzeImage(File imageFile) async {
    try {
      final predictions = await _aiService.analyzeImage(imageFile);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnalysisResultsScreen(
              imagePath: imageFile.path,
              predictions: predictions,
            ),
          ),
        );
      }
    } catch (e) {
      _showError('Error analizando imagen: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _cameraService.dispose();
    _aiService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Análisis Dental IA'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.teal),
                  SizedBox(height: 16),
                  Text('Analizando imagen...'),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Vista de cámara
                  if (_cameraInitialized && _cameraService.controller != null)
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.teal, width: 2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: CameraPreview(_cameraService.controller!),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt,
                                  size: 60, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('Inicializando cámara...'),
                            ],
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _takePhoto,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Tomar Foto'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pickFromGallery,
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Galería'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Información
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.teal.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '📸 Toma una foto clara de tus dientes o encías. '
                      'Asegúrate de buena iluminación y enfoque.',
                      style: TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
