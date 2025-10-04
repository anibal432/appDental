// lib/ai_dental/services/dental_ai_service.dart
import 'dart:io';
import 'dart:developer' as developer;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class DentalAiService {
  static const String modelPath = 'assets/models/dental_model.tflite';
  static const List<String> labels = [
    'Saludable',
    'Caries Inicial',
    'Caries Avanzada',
    'Gingivitis',
    'Placa Dental',
    'Sarro',
    'Esmalte Desgastado'
  ];

  Interpreter? _interpreter;
  bool _isLoaded = false;

  Future<void> loadModel() async {
    try {
      final options = InterpreterOptions();

      _interpreter = await Interpreter.fromAsset(modelPath, options: options);
      _isLoaded = true;
      developer.log('✅ Modelo de IA cargado correctamente', name: 'DentalAI');
    } catch (e) {
      developer.log('❌ Error cargando modelo: $e',
          name: 'DentalAI', level: 1000);
      _isLoaded = false;
    }
  }

  Future<Map<String, double>> analyzeImage(File imageFile) async {
    if (!_isLoaded || _interpreter == null) {
      await loadModel();
    }

    try {
      // Preprocesar imagen
      List<List<List<List<double>>>> input = await _preprocessImage(imageFile);

      // Ejecutar inferencia - CORREGIDO: casting explícito
      List<List<double>> output = _castTo2DDouble(
          List<double>.filled(1 * labels.length, 0.0)
              .reshape([1, labels.length]));

      _interpreter!.run(input, output);

      // Procesar resultados
      return _processOutput(output);
    } catch (e) {
      developer.log('❌ Error en análisis: $e', name: 'DentalAI', level: 1000);
      return {};
    }
  }

  Future<List<List<List<List<double>>>>> _preprocessImage(
      File imageFile) async {
    // Leer y redimensionar imagen
    var imageBytes = await imageFile.readAsBytes();
    var image = img.decodeImage(imageBytes)!;
    var resizedImage = img.copyResize(image, width: 224, height: 224);

    // Convertir a tensor - CORREGIDO: casting explícito
    List<List<List<List<double>>>> input = _castTo4DDouble(
        List<double>.filled(1 * 224 * 224 * 3, 0.0).reshape([1, 224, 224, 3]));

    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        img.Pixel pixel = resizedImage.getPixel(x, y);

        input[0][y][x][0] = pixel.r.toDouble() / 255.0;
        input[0][y][x][1] = pixel.g.toDouble() / 255.0;
        input[0][y][x][2] = pixel.b.toDouble() / 255.0;
      }
    }

    return input;
  }

  // CORREGIDO: Funciones auxiliares para casting de tipos
  List<List<double>> _castTo2DDouble(List<dynamic> dynamicList) {
    return List<List<double>>.from(
        dynamicList.map((item) => List<double>.from(item as List<dynamic>)));
  }

  List<List<List<List<double>>>> _castTo4DDouble(List<dynamic> dynamicList) {
    return List<List<List<List<double>>>>.from(dynamicList.map((item1) =>
        List<List<List<double>>>.from((item1 as List<dynamic>).map((item2) =>
            List<List<double>>.from((item2 as List<dynamic>).map((item3) =>
                List<double>.from((item3 as List<dynamic>)
                    .map((item4) => (item4 as num).toDouble()))))))));
  }

  Map<String, double> _processOutput(List<List<double>> output) {
    Map<String, double> results = {};

    for (int i = 0; i < labels.length; i++) {
      results[labels[i]] = output[0][i];
    }

    // Ordenar por confianza
    var sortedEntries = results.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedEntries);
  }

  String getPrimaryDiagnosis(Map<String, double> predictions) {
    if (predictions.isEmpty) return 'No se pudo analizar';

    var primary = predictions.entries.first;
    return '${primary.key} (${(primary.value * 100).toStringAsFixed(1)}% confianza)';
  }

  List<String> getRecommendations(String diagnosis) {
    Map<String, List<String>> recommendationMap = {
      'Saludable': [
        '¡Excelente! Mantén tu rutina de higiene dental',
        'Visita al dentista cada 6 meses para controles',
        'Continúa con cepillado 3 veces al día'
      ],
      'Caries Inicial': [
        'Consulta con tu dentista para tratamiento temprano',
        'Usa pasta dental con flúor',
        'Reduce consumo de azúcares',
        'Aplica selladores dentales'
      ],
      'Caries Avanzada': [
        '⚠️ Consulta URGENTE con dentista',
        'Posible necesidad de empaste o endodoncia',
        'Evita alimentos duros o pegajosos',
        'Mantén excelente higiene en la zona afectada'
      ],
      'Gingivitis': [
        'Mejora técnica de cepillado',
        'Usa hilo dental diariamente',
        'Considera enjuague bucal antibacteriano',
        'Masajea encías suavemente'
      ],
      'Placa Dental': [
        'Cepillado más minucioso',
        'Usa revelador de placa para identificar zonas',
        'Limpieza dental profesional cada 6 meses',
        'Considera cepillo eléctrico'
      ],
      'Sarro': [
        'Limpieza dental profesional necesaria',
        'No intentes remover sarro en casa',
        'Usa cepillo adecuado para prevención',
        'Control cada 4-6 meses'
      ],
      'Esmalte Desgastado': [
        'Consulta con dentista para evaluación',
        'Usa pasta dental para esmalte sensible',
        'Evita alimentos ácidos',
        'Considera tratamientos de remineralización'
      ]
    };

    // Buscar la clave principal (primera palabra del diagnóstico)
    String primaryKey = diagnosis.split(' ')[0];
    return recommendationMap[primaryKey] ??
        [
          'Consulta con profesional dental',
          'Mantén buena higiene oral',
          'Programa cita con dentista'
        ];
  }

  void dispose() {
    _interpreter?.close();
  }
}
