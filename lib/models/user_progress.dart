class UserProgress {
  final String userId;
  List<String> completedLessons;
  List<String> completedPuzzles;
  List<String> studiedOpenings;
  String skillLevel;
  int xp;
  int streak;
  DateTime lastActivity;
  
  UserProgress({
    required this.userId,
    required this.completedLessons,
    required this.completedPuzzles,
    required this.studiedOpenings,
    required this.skillLevel,
    required this.xp,
    required this.streak,
    required this.lastActivity,
  });
  
  factory UserProgress.fromMap(Map<String, dynamic> map, String userId) {
    return UserProgress(
      userId: userId,
      completedLessons: List<String>.from(map['completedLessons'] ?? []),
      completedPuzzles: List<String>.from(map['completedPuzzles'] ?? []),
      studiedOpenings: List<String>.from(map['studiedOpenings'] ?? []),
      skillLevel: map['skillLevel'] ?? 'beginner',
      xp: map['xp'] ?? 0,
      streak: map['streak'] ?? 0,
      lastActivity: map['lastActivity'] != null 
          ? (map['lastActivity'] as dynamic).toDate() 
          : DateTime.now(),
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'completedLessons': completedLessons,
      'completedPuzzles': completedPuzzles,
      'studiedOpenings': studiedOpenings,
      'skillLevel': skillLevel,
      'xp': xp,
      'streak': streak,
      'lastActivity': lastActivity,
    };
  }
}
