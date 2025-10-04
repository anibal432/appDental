// lib/ai_dental/screens/analysis_results_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../services/dental_ai_service.dart';

class AnalysisResultsScreen extends StatelessWidget {
  final String imagePath;
  final Map<String, double> predictions;

  const AnalysisResultsScreen({
    super.key,
    required this.imagePath,
    required this.predictions,
  });

  Color _getDiagnosisColor(String diagnosis) {
    if (diagnosis.contains('Saludable')) return Colors.green;
    if (diagnosis.contains('Inicial')) return Colors.orange;
    if (diagnosis.contains('Avanzada')) return Colors.red;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    final aiService = DentalAiService();
    final primaryDiagnosis = aiService.getPrimaryDiagnosis(predictions);
    final recommendations = aiService.getRecommendations(primaryDiagnosis);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados del Análisis'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen analizada
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: FileImage(File(imagePath)),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Diagnóstico principal
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getDiagnosisColor(primaryDiagnosis).withAlpha(40),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getDiagnosisColor(primaryDiagnosis),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'DIAGNÓSTICO PRINCIPAL',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    primaryDiagnosis,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _getDiagnosisColor(primaryDiagnosis),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Todas las predicciones
            const Text(
              'ANÁLISIS DETALLADO:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),

            ...predictions.entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(entry.key),
                      ),
                      SizedBox(
                        width: 100,
                        child: LinearProgressIndicator(
                          value: entry.value,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            entry.value > 0.7
                                ? Colors.red
                                : entry.value > 0.4
                                    ? Colors.orange
                                    : Colors.green,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${(entry.value * 100).toStringAsFixed(1)}%'),
                    ],
                  ),
                )),

            const SizedBox(height: 20),

            // Recomendaciones
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'RECOMENDACIONES:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...recommendations.map((rec) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.arrow_forward_ios, size: 16),
                            const SizedBox(width: 8),
                            Expanded(child: Text(rec)),
                          ],
                        ),
                      )),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Advertencia médica
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '⚠️ IMPORTANTE: Este análisis es realizado por IA y tiene '
                'fines informativos. Siempre consulta con un profesional '
                'de la salud dental para diagnóstico y tratamiento preciso.',
                style: TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
