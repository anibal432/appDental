// lib/ai_dental/models/analysis_result.dart
class DentalAnalysisResult {
  final String id;
  final DateTime analysisDate;
  final String imagePath;
  final Map<String, double> predictions;
  final String primaryDiagnosis;
  final String confidence;
  final List<String> recommendations;

  DentalAnalysisResult({
    required this.id,
    required this.analysisDate,
    required this.imagePath,
    required this.predictions,
    required this.primaryDiagnosis,
    required this.confidence,
    required this.recommendations,
  });

  factory DentalAnalysisResult.fromMap(Map<String, dynamic> data) {
    return DentalAnalysisResult(
      id: data['id'] ?? '',
      analysisDate: DateTime.parse(data['analysisDate']),
      imagePath: data['imagePath'] ?? '',
      predictions: Map<String, double>.from(data['predictions']),
      primaryDiagnosis: data['primaryDiagnosis'] ?? '',
      confidence: data['confidence'] ?? '',
      recommendations: List<String>.from(data['recommendations']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'analysisDate': analysisDate.toIso8601String(),
      'imagePath': imagePath,
      'predictions': predictions,
      'primaryDiagnosis': primaryDiagnosis,
      'confidence': confidence,
      'recommendations': recommendations,
    };
  }
}
