class Lesson {
  final String id;
  final String title;
  final String description;
  final String content;
  final String category;
  final String difficulty;
  final int xpReward;
  final List<String> tags;
  final Map<String, dynamic> resources;
  final DateTime createdAt;
  final DateTime updatedAt;

  Lesson({
    required this.title,
    required this.description,
    required this.content,
    required this.category,
    required this.difficulty,
    required this.xpReward,
    List<String>? tags,
    Map<String, dynamic>? resources,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? id,
  })  : id = id ?? '',
        tags = tags ?? [],
        resources = resources ?? {},
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Lesson.fromMap(Map<String, dynamic> map, String id) {
    return Lesson(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      content: map['content'] ?? '',
      category: map['category'] ?? '',
      difficulty: map['difficulty'] ?? 'beginner',
      xpReward: map['xpReward'] ?? 10,
      tags: List<String>.from(map['tags'] ?? []),
      resources: Map<String, dynamic>.from(map['resources'] ?? {}),
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as dynamic).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'content': content,
      'category': category,
      'difficulty': difficulty,
      'xpReward': xpReward,
      'tags': tags,
      'resources': resources,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
