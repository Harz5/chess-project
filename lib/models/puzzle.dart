class Puzzle {
  final String id;
  final String title;
  final String description;
  final String fen;
  final String solution;
  final String category;
  final String difficulty;
  final int xpReward;
  final List<String> tags;
  final Map<String, dynamic> hints;
  final DateTime createdAt;

  Puzzle({
    required this.title,
    required this.description,
    required this.fen,
    required this.solution,
    required this.category,
    required this.difficulty,
    required this.xpReward,
    List<String>? tags,
    Map<String, dynamic>? hints,
    DateTime? createdAt,
    String? id,
  })  : id = id ?? '',
        tags = tags ?? [],
        this.hints = hints ?? {},
        createdAt = createdAt ?? DateTime.now();

  factory Puzzle.fromMap(Map<String, dynamic> map, String id) {
    return Puzzle(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      fen: map['fen'] ?? '',
      solution: map['solution'] ?? '',
      category: map['category'] ?? '',
      difficulty: map['difficulty'] ?? 'beginner',
      xpReward: map['xpReward'] ?? 10,
      tags: List<String>.from(map['tags'] ?? []),
      hints: Map<String, dynamic>.from(map['hints'] ?? {}),
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'fen': fen,
      'solution': solution,
      'category': category,
      'difficulty': difficulty,
      'xpReward': xpReward,
      'tags': tags,
      'hints': hints,
      'createdAt': createdAt,
    };
  }
}
