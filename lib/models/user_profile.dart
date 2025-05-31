class UserProfile {
  final String id;
  String username;
  String email;
  String? displayName;
  String? photoUrl;
  String? bio;
  int rating;
  int gamesPlayed;
  int gamesWon;
  int gamesLost;
  int gamesDraw;
  bool isOnline;
  DateTime lastSeen;
  List<String> friends;
  Map<String, dynamic> preferences;

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.bio,
    this.rating = 1200,
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.gamesLost = 0,
    this.gamesDraw = 0,
    this.isOnline = false,
    DateTime? lastSeen,
    List<String>? friends,
    Map<String, dynamic>? preferences,
  })  : lastSeen = lastSeen ?? DateTime.now(),
        friends = friends ?? [],
        preferences = preferences ?? {};

  factory UserProfile.fromMap(Map<String, dynamic> map, String id) {
    return UserProfile(
      id: id,
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'],
      photoUrl: map['photoUrl'],
      bio: map['bio'],
      rating: map['rating'] ?? 1200,
      gamesPlayed: map['gamesPlayed'] ?? 0,
      gamesWon: map['gamesWon'] ?? 0,
      gamesLost: map['gamesLost'] ?? 0,
      gamesDraw: map['gamesDraw'] ?? 0,
      isOnline: map['isOnline'] ?? false,
      lastSeen: map['lastSeen'] != null
          ? (map['lastSeen'] as dynamic).toDate()
          : DateTime.now(),
      friends: List<String>.from(map['friends'] ?? []),
      preferences: Map<String, dynamic>.from(map['preferences'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'bio': bio,
      'rating': rating,
      'gamesPlayed': gamesPlayed,
      'gamesWon': gamesWon,
      'gamesLost': gamesLost,
      'gamesDraw': gamesDraw,
      'isOnline': isOnline,
      'lastSeen': lastSeen,
      'friends': friends,
      'preferences': preferences,
    };
  }

  UserProfile copyWith({
    String? username,
    String? email,
    String? displayName,
    String? photoUrl,
    String? bio,
    int? rating,
    int? gamesPlayed,
    int? gamesWon,
    int? gamesLost,
    int? gamesDraw,
    bool? isOnline,
    DateTime? lastSeen,
    List<String>? friends,
    Map<String, dynamic>? preferences,
  }) {
    return UserProfile(
      id: id,
      username: username ?? this.username,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      rating: rating ?? this.rating,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      gamesWon: gamesWon ?? this.gamesWon,
      gamesLost: gamesLost ?? this.gamesLost,
      gamesDraw: gamesDraw ?? this.gamesDraw,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      friends: friends ?? List.from(this.friends),
      preferences: preferences ?? Map.from(this.preferences),
    );
  }

  void updateStats({
    bool won = false,
    bool lost = false,
    bool draw = false,
    int ratingChange = 0,
  }) {
    gamesPlayed++;

    if (won) {
      gamesWon++;
    } else if (lost) {
      gamesLost++;
    } else if (draw) {
      gamesDraw++;
    }

    rating += ratingChange;
  }
}
