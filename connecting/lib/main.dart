import 'package:flutter/material.dart';
import 'screens/word_visualizer_screen.dart';
import 'screens/benchmark_screen.dart';

const String apiBaseUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://localhost:10000',
);

void main() {
  runApp(const WordVisualizerApp());
}

class WordVisualizerApp extends StatelessWidget {
  const WordVisualizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word Visualizer',
      theme: ThemeData.dark(),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Connecting: A Semantic Map of Words'),
        actions: [
          IconButton(
            icon: const Icon(Icons.speed),
            tooltip: 'Performance Benchmark',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BenchmarkScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: const WordVisualizer(),
    );
  }
}
