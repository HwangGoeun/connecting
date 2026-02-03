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
