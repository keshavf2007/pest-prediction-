/// Prediction model for storing API response data
class PredictionModel {
  final String result;
  final double confidence;
  final String solution;
  final Map<String, dynamic>? allPredictions;

  PredictionModel({
    required this.result,
    required this.confidence,
    required this.solution,
    this.allPredictions,
  });

  /// Factory constructor to create PredictionModel from JSON
  factory PredictionModel.fromJson(Map<String, dynamic> json) {
    return PredictionModel(
      result: json['result'] ?? 'Unknown',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      solution: json['solution'] ?? 'No solution available',
      allPredictions: json['all_predictions'],
    );
  }

  /// Convert to JSON for storage/transmission
  Map<String, dynamic> toJson() {
    return {
      'result': result,
      'confidence': confidence,
      'solution': solution,
      'all_predictions': allPredictions,
    };
  }

  @override
  String toString() =>
      'PredictionModel(result: $result, confidence: $confidence%)';
}
