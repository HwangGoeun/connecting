import 'package:flutter/scheduler.dart';

class PerformanceTracker {
  final List<double> _frameTimes = [];
  final List<double> _buildTimes = [];
  final int _maxSamples = 60;

  int _frameCount = 0;
  DateTime _lastFpsUpdate = DateTime.now();
  double _currentFps = 0;

  Ticker? _ticker;
  Duration _previousFrameTime = Duration.zero;

  final Stopwatch _buildStopwatch = Stopwatch();

  void startTracking(TickerProvider vsync) {
    _ticker = vsync.createTicker(_onTick);
    _ticker!.start();
  }

  void _onTick(Duration elapsed) {
    if (_previousFrameTime != Duration.zero) {
      final frameDuration = elapsed - _previousFrameTime;
      final frameTimeMs = frameDuration.inMicroseconds / 1000.0;

      _frameTimes.add(frameTimeMs);
      if (_frameTimes.length > _maxSamples) {
        _frameTimes.removeAt(0);
      }
    }
    _previousFrameTime = elapsed;
    _frameCount++;

    final now = DateTime.now();
    if (now.difference(_lastFpsUpdate).inMilliseconds >= 1000) {
      _currentFps = _frameCount.toDouble();
      _frameCount = 0;
      _lastFpsUpdate = now;
    }
  }

  void startBuild() {
    _buildStopwatch.reset();
    _buildStopwatch.start();
  }

  void endBuild() {
    _buildStopwatch.stop();
    final buildTimeMs = _buildStopwatch.elapsedMicroseconds / 1000.0;
    _buildTimes.add(buildTimeMs);
    if (_buildTimes.length > _maxSamples) {
      _buildTimes.removeAt(0);
    }
  }

  double get fps => _currentFps;

  double get averageFrameTime {
    if (_frameTimes.isEmpty) return 0;
    return _frameTimes.reduce((a, b) => a + b) / _frameTimes.length;
  }

  double get averageBuildTime {
    if (_buildTimes.isEmpty) return 0;
    return _buildTimes.reduce((a, b) => a + b) / _buildTimes.length;
  }

  double get lastBuildTime {
    if (_buildTimes.isEmpty) return 0;
    return _buildTimes.last;
  }

  void reset() {
    _frameTimes.clear();
    _buildTimes.clear();
    _frameCount = 0;
    _currentFps = 0;
  }

  void dispose() {
    _ticker?.dispose();
  }
}
