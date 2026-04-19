import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

/// Loading indicator widget shown while processing predictions
class LoadingIndicator extends StatelessWidget {
  final String? message;

  const LoadingIndicator({
    Key? key,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitCircle(
            color: Colors.green[700]!,
            size: 60,
          ),
          const SizedBox(height: 24),
          Text(
            message ?? 'Analyzing image...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
