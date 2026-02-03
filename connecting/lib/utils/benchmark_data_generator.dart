import 'dart:math';
import 'dart:ui';
import '../models/benchmark_models.dart';

class BenchmarkDataGenerator {
  final Random _random;

  BenchmarkDataGenerator({int seed = 42}) : _random = Random(seed);

  BenchmarkData generate({
    required int nodeCount,
    double connectionDensity = 0.3,
  }) {
    final nodes = <BenchmarkNode>[];
    final connections = <BenchmarkConnection>[];

    // 노드 생성 (원형 분포)
    for (int i = 0; i < nodeCount; i++) {
      final angle = (i / nodeCount) * 2 * pi + _random.nextDouble() * 0.3;
      final radius = 0.15 + _random.nextDouble() * 0.3;

      nodes.add(BenchmarkNode(
        id: 'node_$i',
        x: 0.5 + cos(angle) * radius,
        y: 0.5 + sin(angle) * radius,
      ));
    }

    // 연결 생성
    for (int i = 0; i < nodeCount; i++) {
      for (int j = i + 1; j < nodeCount; j++) {
        if (_random.nextDouble() < connectionDensity) {
          connections.add(BenchmarkConnection(
            fromId: nodes[i].id,
            toId: nodes[j].id,
            similarity: 0.3 + _random.nextDouble() * 0.7,
          ));
        }
      }
    }

    return BenchmarkData(nodes: nodes, connections: connections);
  }

  /// 애니메이션용 위치 변환
  Map<String, Offset> animatePositions(
    Map<String, Offset> original,
    double time,
    double amplitude,
  ) {
    return original.map((key, offset) {
      final hash = key.hashCode;
      final phase = hash * 0.001;
      return MapEntry(
        key,
        Offset(
          offset.dx + sin(time * 2 + phase) * amplitude,
          offset.dy + cos(time * 1.5 + phase) * amplitude,
        ),
      );
    });
  }
}
