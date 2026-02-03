import 'package:flutter/material.dart';
import '../../models/benchmark_models.dart';

class WidgetBasedRenderer extends StatelessWidget {
  final BenchmarkData data;
  final Map<String, Offset> positions;

  const WidgetBasedRenderer({
    super.key,
    required this.data,
    required this.positions,
  });

  @override
  Widget build(BuildContext context) {
    final connectionWidgets = data.connections.map((conn) {
      final p1 = positions[conn.fromId];
      final p2 = positions[conn.toId];
      if (p1 == null || p2 == null) return const SizedBox.shrink();

      return _ConnectionLineWidget(
        start: p1,
        end: p2,
        opacity: conn.similarity,
      );
    }).toList();

    final nodeWidgets = positions.entries.map((entry) {
      return Positioned(
        left: entry.value.dx - 4,
        top: entry.value.dy - 4,
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      );
    }).toList();

    return Stack(
      children: [
        ...connectionWidgets,
        ...nodeWidgets,
      ],
    );
  }
}

class _ConnectionLineWidget extends StatelessWidget {
  final Offset start;
  final Offset end;
  final double opacity;

  const _ConnectionLineWidget({
    required this.start,
    required this.end,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _SingleLinePainter(
          start: start,
          end: end,
          opacity: opacity,
        ),
      ),
    );
  }
}

class _SingleLinePainter extends CustomPainter {
  final Offset start;
  final Offset end;
  final double opacity;

  _SingleLinePainter({
    required this.start,
    required this.end,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.orange.withOpacity(opacity * 0.8)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(covariant _SingleLinePainter oldDelegate) => true;
}
