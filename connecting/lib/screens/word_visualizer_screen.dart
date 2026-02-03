import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../main.dart';
import '../models/word_models.dart';
import '../widgets/animated_word.dart';
import '../widgets/connection_painter.dart';
import '../utils/layout_utils.dart';

class WordVisualizer extends StatefulWidget {
  const WordVisualizer({super.key});

  @override
  State<WordVisualizer> createState() => _WordVisualizerState();
}

class _WordVisualizerState extends State<WordVisualizer> {
  List<String> inputWords = [];
  List<WordPoint> points = [];
  List<WordConnection> connections = [];
  final TextEditingController _controller = TextEditingController();
  bool isLoading = false;

  Future<void> fetchWordPoints() async {
    if (inputWords.isEmpty) return;
    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/vectorize'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: utf8.encode(json.encode({'words': inputWords})),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final pointList =
            (data['points'] as List).map((e) => WordPoint.fromJson(e)).toList();
        final connList = (data['connections'] as List)
            .map((e) => WordConnection.fromJson(e))
            .toList();

        setState(() {
          points = pointList;
          connections = connList;
          isLoading = false;
        });
      } else {
        throw Exception('서버 응답 오류');
      }
    } catch (e) {
      print('에러 발생: $e');
      setState(() => isLoading = false);
    }
  }

  void addWord() {
    final word = _controller.text.trim();
    if (word.isEmpty || inputWords.contains(word)) return;
    setState(() {
      inputWords.add(word);
      _controller.clear();
    });
    fetchWordPoints();
  }

  void removeWord(String word) {
    setState(() {
      inputWords.remove(word);
    });
    fetchWordPoints();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: 'Enter Word',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => addWord(),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: isLoading ? null : addWord,
                child: const Text("ADD"),
              ),
            ],
          ),
        ),
        if (inputWords.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Wrap(
              spacing: 8,
              children: inputWords
                  .map((w) => Chip(
                        label: Text(w,
                            style: const TextStyle(color: Colors.white)),
                        backgroundColor: Colors.grey[800],
                        onDeleted: () => removeWord(w),
                      ))
                  .toList(),
            ),
          ),
        Expanded(
          child: Stack(
            children: [
              if (points.isNotEmpty)
                LayoutBuilder(
                  builder: (context, constraints) {
                    double minX =
                        points.map((e) => e.x).reduce((a, b) => a < b ? a : b);
                    double maxX =
                        points.map((e) => e.x).reduce((a, b) => a > b ? a : b);
                    double minY =
                        points.map((e) => e.y).reduce((a, b) => a < b ? a : b);
                    double maxY =
                        points.map((e) => e.y).reduce((a, b) => a > b ? a : b);

                    double scaleX = constraints.maxWidth / (maxX - minX + 1);
                    double scaleY = constraints.maxHeight / (maxY - minY + 1);

                    Map<String, Offset> wordPositions = {
                      for (var p in points)
                        p.word: Offset(
                          (p.x - minX) * scaleX,
                          (p.y - minY) * scaleY,
                        )
                    };

                    wordPositions = applyRepulsion(wordPositions, 40);

                    return InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 5.0,
                      boundaryMargin: const EdgeInsets.all(200),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CustomPaint(
                            painter: ConnectionAndCirclePainter(
                              connections: connections,
                              wordPositions: wordPositions,
                            ),
                            size: Size.infinite,
                          ),
                          ...points.map((word) {
                            final pos = wordPositions[word.word]!;
                            return AnimatedWord(
                              key: ValueKey(word.word),
                              word: word.word,
                              x: pos.dx - 30,
                              y: pos.dy - 20,
                            );
                          }),
                        ],
                      ),
                    );
                  },
                ),
              if (isLoading) const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ],
    );
  }
}
