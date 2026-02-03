import 'package:flutter/material.dart';
import '../../models/benchmark_models.dart';

class CustomPaintRenderer extends StatelessWidget {
  final BenchmarkData data;
  final Map<String, Offset> positions;

  const CustomPaintRenderer({
    super.key,
    required this.data,
    required this.positions,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BenchmarkPainter(
        connections: data.connections,
        positions: positions,
      ),
      size: Size.infinite,
    );
  }
}

class _BenchmarkPainter extends CustomPainter {
  final List<BenchmarkConnection> connections;
  final Map<String, Offset> positions;

  _BenchmarkPainter({
    required this.connections,
    required this.positions,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (final conn in connections) {
      final p1 = positions[conn.fromId];
      final p2 = positions[conn.toId];
      if (p1 == null || p2 == null) continue;

      linePaint.color = Colors.blue.withOpacity(conn.similarity * 0.8);
      canvas.drawLine(p1, p2, linePaint);
    }

    final nodePaint = Paint()..color = Colors.white;
    for (final pos in positions.values) {
      canvas.drawCircle(pos, 4, nodePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BenchmarkPainter oldDelegate) => true;
}
