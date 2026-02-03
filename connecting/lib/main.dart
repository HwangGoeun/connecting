import 'package:flutter/material.dart';
import 'screens/word_visualizer_screen.dart';

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
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Connecting: A Semantic Map of Words'),
        ),
        body: const WordVisualizer(),
      ),
    );
  }
}
