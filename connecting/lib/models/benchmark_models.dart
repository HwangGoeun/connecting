import 'dart:ui';

class BenchmarkNode {
  final String id;
  final double x;
  final double y;

  BenchmarkNode({required this.id, required this.x, required this.y});

  Offset toOffset(Size canvasSize) {
    return Offset(x * canvasSize.width, y * canvasSize.height);
  }
}

class BenchmarkConnection {
  final String fromId;
  final String toId;
  final double similarity;

  BenchmarkConnection({
    required this.fromId,
    required this.toId,
    required this.similarity,
  });
}

class BenchmarkData {
  final List<BenchmarkNode> nodes;
  final List<BenchmarkConnection> connections;

  BenchmarkData({required this.nodes, required this.connections});

  Map<String, Offset> getPositions(Size canvasSize) {
    return {for (var node in nodes) node.id: node.toOffset(canvasSize)};
  }
}
