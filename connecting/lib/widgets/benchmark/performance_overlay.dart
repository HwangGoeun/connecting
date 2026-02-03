import 'package:flutter/material.dart';

class BenchmarkOverlay extends StatelessWidget {
  final double fps;
  final double buildTimeMs;
  final int widgetCount;
  final String title;
  final bool isFaster;

  const BenchmarkOverlay({
    super.key,
    required this.fps,
    required this.buildTimeMs,
    required this.widgetCount,
    required this.title,
    this.isFaster = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          _buildMetricRow('FPS', fps.toStringAsFixed(1), isFaster ? Colors.green : Colors.orange),
          _buildMetricRow(
              'Build', '${buildTimeMs.toStringAsFixed(2)} ms', isFaster ? Colors.green : Colors.orange),
          _buildMetricRow('Widgets', widgetCount.toString(), Colors.grey),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Color _getFpsColor(double fps) {
    if (fps >= 55) return Colors.green;
    if (fps >= 30) return Colors.orange;
    return Colors.red;
  }

  Color _getBuildColor(double ms) {
    if (ms < 2) return Colors.green;
    if (ms < 8) return Colors.orange;
    return Colors.red;
  }
}
