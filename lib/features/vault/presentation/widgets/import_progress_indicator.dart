import 'package:flutter/material.dart';

class ImportProgressIndicator extends StatelessWidget {
  final double progress;

  const ImportProgressIndicator({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_outline, size: 48),
          const SizedBox(height: 16),
          const Text('Encrypting file...'),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: progress > 0 ? progress : null),
        ],
      ),
    );
  }
}
