import 'package:flutter/material.dart';
import '../models/word_models.dart';

class ConnectionAndCirclePainter extends CustomPainter {
  final List<WordConnection> connections;
  final Map<String, Offset> wordPositions;

  ConnectionAndCirclePainter(
      {required this.connections, required this.wordPositions});

  @override
  void paint(Canvas canvas, Size size) {
    for (var conn in connections) {
      final p1 = wordPositions[conn.from];
      final p2 = wordPositions[conn.to];
      if (p1 == null || p2 == null) continue;

      final paint = Paint()
        ..color = Colors.white.withOpacity(conn.similarity)
        ..strokeWidth = conn.similarity * 2;

      canvas.drawLine(p1, p2, paint);
    }

    final circlePaint = Paint()..color = Colors.white;
    for (var entry in wordPositions.entries) {
      canvas.drawCircle(entry.value, 4, circlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
