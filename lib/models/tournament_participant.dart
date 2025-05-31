class TournamentParticipant {
  final String userId;
  final String tournamentId;
  final DateTime registrationTime;
  String status; // 'active', 'withdrawn', 'disqualified'
  double score;
  int rank;
  int matchesPlayed;
  int matchesWon;
  int matchesLost;
  int matchesDraw;
  
  TournamentParticipant({
    required this.userId,
    required this.tournamentId,
    required this.registrationTime,
    required this.status,
    required this.score,
    required this.rank,
    required this.matchesPlayed,
    required this.matchesWon,
    required this.matchesLost,
    required this.matchesDraw,
  });
  
  factory TournamentParticipant.fromMap(Map<String, dynamic> map, String id) {
    return TournamentParticipant(
      userId: id,
      tournamentId: map['tournamentId'] ?? '',
      registrationTime: map['registrationTime'] != null 
          ? (map['registrationTime'] as dynamic).toDate() 
          : DateTime.now(),
      status: map['status'] ?? 'active',
      score: (map['score'] ?? 0).toDouble(),
      rank: map['rank'] ?? 0,
      matchesPlayed: map['matchesPlayed'] ?? 0,
      matchesWon: map['matchesWon'] ?? 0,
      matchesLost: map['matchesLost'] ?? 0,
      matchesDraw: map['matchesDraw'] ?? 0,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'tournamentId': tournamentId,
      'registrationTime': registrationTime,
      'status': status,
      'score': score,
      'rank': rank,
      'matchesPlayed': matchesPlayed,
      'matchesWon': matchesWon,
      'matchesLost': matchesLost,
      'matchesDraw': matchesDraw,
    };
  }
}
