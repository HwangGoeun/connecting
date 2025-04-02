import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

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
        appBar:
            AppBar(title: const Text('Connecting: A Semantic Map of Words')),
        body: const WordVisualizer(),
      ),
    );
  }
}

class WordPoint {
  final String word;
  final double x, y;
  WordPoint({required this.word, required this.x, required this.y});

  factory WordPoint.fromJson(Map<String, dynamic> json) {
    return WordPoint(
      word: json['word'],
      x: json['x'],
      y: json['y'],
    );
  }
}

class WordConnection {
  final String from;
  final String to;
  final double similarity;
  WordConnection(
      {required this.from, required this.to, required this.similarity});

  factory WordConnection.fromJson(Map<String, dynamic> json) {
    return WordConnection(
      from: json['from'],
      to: json['to'],
      similarity: json['similarity'],
    );
  }
}

class AnimatedWord extends StatelessWidget {
  final String word;
  final double x;
  final double y;

  const AnimatedWord({
    super.key,
    required this.word,
    required this.x,
    required this.y,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 500),
      left: x,
      top: y,
      child: Text(
        word,
        style: GoogleFonts.notoSansKr(
          fontSize: 14,
          color: Colors.white,
          shadows: [
            Shadow(
              blurRadius: 6,
              color: Colors.white.withOpacity(0.8),
              offset: const Offset(0, 0),
            )
          ],
        ),
      ),
    );
  }
}

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

  Map<String, Offset> applyRepulsion(
      Map<String, Offset> positions, double minDistance) {
    const double force = 0.4;
    final result = Map<String, Offset>.from(positions);
    final entries = result.entries.toList();

    for (int i = 0; i < entries.length; i++) {
      for (int j = i + 1; j < entries.length; j++) {
        final a = entries[i];
        final b = entries[j];

        final dx = b.value.dx - a.value.dx;
        final dy = b.value.dy - a.value.dy;
        final distSq = dx * dx + dy * dy;

        if (distSq < minDistance * minDistance && distSq > 0.01) {
          final dist = sqrt(distSq);
          final repulsion = (minDistance - dist) * force;

          final offsetX = repulsion * dx / dist;
          final offsetY = repulsion * dy / dist;

          result[a.key] = result[a.key]! - Offset(offsetX, offsetY);
          result[b.key] = result[b.key]! + Offset(offsetX, offsetY);
        }
      }
    }

    return result;
  }

  Future<void> fetchWordPoints() async {
    if (inputWords.isEmpty) return;
    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8000/vectorize'),
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
                    labelText: '단어 입력',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => addWord(),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: isLoading ? null : addWord,
                child: const Text("추가"),
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
