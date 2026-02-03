import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../models/benchmark_models.dart';
import '../utils/benchmark_data_generator.dart';
import '../widgets/benchmark/custom_paint_renderer.dart';
import '../widgets/benchmark/widget_based_renderer.dart';

class BenchmarkScreen extends StatefulWidget {
  const BenchmarkScreen({super.key});

  @override
  State<BenchmarkScreen> createState() => _BenchmarkScreenState();
}

class _BenchmarkScreenState extends State<BenchmarkScreen>
    with SingleTickerProviderStateMixin {
  int _nodeCount = 50;
  bool _isAnimating = false;
  bool _useCustomPaint = true; // true: CustomPaint, false: Widget-based

  final BenchmarkDataGenerator _generator = BenchmarkDataGenerator();
  BenchmarkData? _benchmarkData;

  late Ticker _ticker;
  double _time = 0;
  Duration _previousTime = Duration.zero;

  int _frameCount = 0;
  double _fps = 0;
  DateTime _lastFpsUpdate = DateTime.now();

  final List<int> _nodeCounts = [10, 25, 50, 100, 200];

  @override
  void initState() {
    super.initState();
    _generateData();
    _ticker = createTicker(_onTick);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _generateData() {
    _benchmarkData = _generator.generate(
      nodeCount: _nodeCount,
      connectionDensity: 0.3,
    );
  }

  void _setNodeCount(int count) {
    setState(() {
      _nodeCount = count;
      _generateData();
      _resetFps();
    });
  }

  void _toggleRenderer() {
    setState(() {
      _useCustomPaint = !_useCustomPaint;
      _resetFps();
    });
  }

  void _toggleAnimation() {
    setState(() {
      _isAnimating = !_isAnimating;
      if (_isAnimating) {
        _time = 0;
        _previousTime = Duration.zero;
        _resetFps();
        _ticker.start();
      } else {
        _ticker.stop();
      }
    });
  }

  void _resetFps() {
    _frameCount = 0;
    _fps = 0;
    _lastFpsUpdate = DateTime.now();
  }

  void _onTick(Duration elapsed) {
    if (_previousTime != Duration.zero) {
      final delta = (elapsed - _previousTime).inMicroseconds / 1000000.0;
      _time += delta;
    }
    _previousTime = elapsed;

    _frameCount++;
    final now = DateTime.now();
    if (now.difference(_lastFpsUpdate).inMilliseconds >= 1000) {
      _fps = _frameCount.toDouble();
      _frameCount = 0;
      _lastFpsUpdate = now;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final widgetCount = _useCustomPaint
        ? 1
        : 1 + (_benchmarkData?.connections.length ?? 0) * 2 + (_benchmarkData?.nodes.length ?? 0) * 2;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Performance Benchmark'),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          _buildControlPanel(),
          _buildRendererToggle(),
          Expanded(
            child: _benchmarkData == null
                ? const Center(child: CircularProgressIndicator())
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final canvasSize = constraints.biggest;
                      final basePositions = _benchmarkData!.getPositions(canvasSize);

                      final positions = _isAnimating
                          ? _generator.animatePositions(basePositions, _time, 25)
                          : basePositions;

                      return Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _useCustomPaint ? Colors.blue : Colors.orange,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(9),
                          child: Stack(
                            children: [
                              _useCustomPaint
                                  ? CustomPaintRenderer(
                                      data: _benchmarkData!,
                                      positions: positions,
                                    )
                                  : WidgetBasedRenderer(
                                      data: _benchmarkData!,
                                      positions: positions,
                                    ),
                              Positioned(
                                right: 16,
                                bottom: 16,
                                child: _buildFpsOverlay(widgetCount),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Text('Nodes: ', style: TextStyle(color: Colors.white)),
          const SizedBox(width: 8),
          ..._nodeCounts.map((count) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text('$count'),
                  selected: _nodeCount == count,
                  onSelected: (selected) {
                    if (selected) _setNodeCount(count);
                  },
                  selectedColor: Colors.blue,
                  labelStyle: TextStyle(
                    color: _nodeCount == count ? Colors.white : Colors.grey,
                  ),
                ),
              )),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _toggleAnimation,
            icon: Icon(_isAnimating ? Icons.stop : Icons.play_arrow),
            label: Text(_isAnimating ? 'Stop' : 'Animate'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isAnimating ? Colors.red : Colors.green,
              minimumSize: const Size(120, 48),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRendererToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!_useCustomPaint) _toggleRenderer();
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _useCustomPaint ? Colors.blue : Colors.grey[900],
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                  border: Border.all(
                    color: _useCustomPaint ? Colors.blue : Colors.grey[700]!,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'CustomPaint',
                      style: TextStyle(
                        color: _useCustomPaint ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '1 widget',
                      style: TextStyle(
                        color: _useCustomPaint ? Colors.white70 : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_useCustomPaint) _toggleRenderer();
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: !_useCustomPaint ? Colors.orange : Colors.grey[900],
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                  border: Border.all(
                    color: !_useCustomPaint ? Colors.orange : Colors.grey[700]!,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Widget-based',
                      style: TextStyle(
                        color: !_useCustomPaint ? Colors.white : Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${1 + (_benchmarkData?.connections.length ?? 0) * 2 + (_benchmarkData?.nodes.length ?? 0) * 2} widgets',
                      style: TextStyle(
                        color: !_useCustomPaint ? Colors.white70 : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFpsOverlay(int widgetCount) {
    final color = _useCustomPaint ? Colors.blue : Colors.orange;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${_fps.toStringAsFixed(0)} FPS',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 32,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$widgetCount widgets',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
