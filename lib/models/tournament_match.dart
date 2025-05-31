class TournamentMatch {
  final String id;
  final String tournamentId;
  final int round;
  final List<String> players;
  final DateTime scheduledTime;
  String status; // 'scheduled', 'ongoing', 'completed', 'cancelled'
  bool completed;
  String? winnerId;
  Map<String, dynamic>? gameData;
  DateTime? completedTime;

  TournamentMatch({
    required this.tournamentId,
    required this.round,
    required this.players,
    required this.scheduledTime,
    required this.status,
    required this.completed,
    this.winnerId,
    this.gameData,
    this.completedTime,
    String? id,
  }) : id = id ?? '';

  factory TournamentMatch.fromMap(Map<String, dynamic> map, String id) {
    return TournamentMatch(
      id: id,
      tournamentId: map['tournamentId'] ?? '',
      round: map['round'] ?? 0,
      players: List<String>.from(map['players'] ?? []),
      scheduledTime: map['scheduledTime'] != null
          ? (map['scheduledTime'] as dynamic).toDate()
          : DateTime.now(),
      status: map['status'] ?? 'scheduled',
      completed: map['completed'] ?? false,
      winnerId: map['winnerId'],
      gameData: map['gameData'],
      completedTime: map['completedTime'] != null
          ? (map['completedTime'] as dynamic).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tournamentId': tournamentId,
      'round': round,
      'players': players,
      'scheduledTime': scheduledTime,
      'status': status,
      'completed': completed,
      'winnerId': winnerId,
      'gameData': gameData,
      'completedTime': completedTime,
    };
  }
}
