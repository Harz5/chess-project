class Opening {
  final String id;
  final String name;
  final String description;
  final String eco;
  final String pgn;
  final String category;
  final int popularity;
  final int xpReward;
  final List<String> tags;
  final Map<String, dynamic> variations;
  final DateTime createdAt;

  Opening({
    required this.name,
    required this.description,
    required this.eco,
    required this.pgn,
    required this.category,
    required this.popularity,
    required this.xpReward,
    List<String>? tags,
    Map<String, dynamic>? variations,
    DateTime? createdAt,
    String? id,
  })  : this.id = id ?? '',
        this.tags = tags ?? [],
        variations = variations ?? {},
        this.createdAt = createdAt ?? DateTime.now();

  factory Opening.fromMap(Map<String, dynamic> map, String id) {
    return Opening(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      eco: map['eco'] ?? '',
      pgn: map['pgn'] ?? '',
      category: map['category'] ?? '',
      popularity: map['popularity'] ?? 0,
      xpReward: map['xpReward'] ?? 10,
      tags: List<String>.from(map['tags'] ?? []),
      variations: Map<String, dynamic>.from(map['variations'] ?? {}),
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'eco': eco,
      'pgn': pgn,
      'category': category,
      'popularity': popularity,
      'xpReward': xpReward,
      'tags': tags,
      'variations': variations,
      'createdAt': createdAt,
    };
  }
}
