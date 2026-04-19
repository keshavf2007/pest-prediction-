import 'package:flutter/material.dart';
import 'package:pest_detection_app/models/prediction_model.dart';

/// Widget to display prediction results in a card format
class ResultCard extends StatelessWidget {
  final PredictionModel prediction;

  const ResultCard({
    Key? key,
    required this.prediction,
  }) : super(key: key);

  /// Get color based on confidence level
  Color _getConfidenceColor(double confidence) {
    if (confidence >= 80) {
      return Colors.green;
    } else if (confidence >= 60) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final confidenceColor = _getConfidenceColor(prediction.confidence);

    return Card(
      elevation: 8,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Result title
            Text(
              'Detection Result',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 12),

            // Pest/Disease name
            Text(
              prediction.result,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                  ),
            ),
            const SizedBox(height: 16),

            // Confidence percentage with visual indicator
            Row(
              children: [
                Text(
                  'Confidence: ',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                Text(
                  '${prediction.confidence.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: confidenceColor,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Confidence bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: prediction.confidence / 100,
                minHeight: 8,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(confidenceColor),
              ),
            ),
            const SizedBox(height: 20),

            // Treatment solution
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.green[300]!,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.green[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Suggested Treatment',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    prediction.solution,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[800],
                          height: 1.5,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
