import 'dart:math';

/// Service für die Schach-Community-Plattform
class CommunityService {
  // Singleton-Instanz
  static final CommunityService _instance = CommunityService._internal();

  factory CommunityService() {
    return _instance;
  }

  // Benutzerprofile
  final Map<String, UserProfile> _userProfiles = {};

  // Freundeslisten
  final Map<String, List<String>> _friendLists = {};

  // Turniere
  final List<Tournament> _tournaments = [];

  // Clans/Teams
  final Map<String, Clan> _clans = {};

  // Chat-Nachrichten
  final List<ChatMessage> _chatMessages = [];

  // Live-Streams
  final List<LiveStream> _liveStreams = [];

  CommunityService._internal() {
    _initializeDemoData();
  }

  /// Initialisiert Demo-Daten für die Community-Plattform
  void _initializeDemoData() {
    // Erstelle einige Beispielbenutzer
    _userProfiles['user1'] = UserProfile(
      username: 'GrandMaster42',
      displayName: 'Anna Schmidt',
      rating: 1850,
      country: 'Deutschland',
      memberSince: DateTime(2023, 5, 15),
      gamesPlayed: 342,
      winRate: 0.68,
      avatarUrl: 'assets/avatars/user1.png',
    );

    _userProfiles['user2'] = UserProfile(
      username: 'ChessWizard',
      displayName: 'Michael Johnson',
      rating: 2100,
      country: 'USA',
      memberSince: DateTime(2022, 11, 3),
      gamesPlayed: 567,
      winRate: 0.72,
      avatarUrl: 'assets/avatars/user2.png',
    );

    _userProfiles['user3'] = UserProfile(
      username: 'QueenMaster',
      displayName: 'Sophie Dubois',
      rating: 1950,
      country: 'Frankreich',
      memberSince: DateTime(2023, 2, 28),
      gamesPlayed: 289,
      winRate: 0.65,
      avatarUrl: 'assets/avatars/user3.png',
    );

    // Erstelle Freundeslisten
    _friendLists['user1'] = ['user2', 'user3'];
    _friendLists['user2'] = ['user1'];
    _friendLists['user3'] = ['user1'];

    // Erstelle Beispielturniere
    _tournaments.add(Tournament(
      id: 'tournament1',
      name: 'Wöchentliches Blitzturnier',
      description: 'Ein schnelles Turnier für alle Spielstärken',
      startDate: DateTime.now().add(const Duration(days: 2)),
      endDate: DateTime.now().add(const Duration(days: 2, hours: 4)),
      format: TournamentFormat.swiss,
      timeControl: '5+2',
      participants: ['user1', 'user2', 'user3'],
      status: TournamentStatus.registrationOpen,
    ));

    _tournaments.add(Tournament(
      id: 'tournament2',
      name: 'Meisterschaftsturnier',
      description: 'Ein Turnier für fortgeschrittene Spieler',
      startDate: DateTime.now().add(const Duration(days: 7)),
      endDate: DateTime.now().add(const Duration(days: 14)),
      format: TournamentFormat.knockout,
      timeControl: '15+10',
      participants: ['user2'],
      status: TournamentStatus.registrationOpen,
      minRating: 1800,
    ));

    // Erstelle Beispiel-Clans
    _clans['clan1'] = Clan(
      id: 'clan1',
      name: 'Schachmeister',
      description: 'Ein Clan für ambitionierte Spieler',
      founderUsername: 'user2',
      members: ['user1', 'user2'],
      rating: 2000,
      wins: 15,
      losses: 5,
      draws: 3,
      createdAt: DateTime(2023, 6, 10),
    );

    // Erstelle Beispiel-Chat-Nachrichten
    _chatMessages.add(ChatMessage(
      id: 'msg1',
      senderUsername: 'user1',
      receiverUsername: 'user2',
      content: 'Gutes Spiel gestern!',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      isRead: true,
    ));

    _chatMessages.add(ChatMessage(
      id: 'msg2',
      senderUsername: 'user2',
      receiverUsername: 'user1',
      content: 'Danke, du hast auch gut gespielt!',
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      isRead: true,
    ));

    // Erstelle Beispiel-Live-Streams
    _liveStreams.add(LiveStream(
      id: 'stream1',
      title: 'Analyse der Weltmeisterschaft',
      streamerUsername: 'user2',
      description: 'Wir analysieren die Partien der letzten Weltmeisterschaft',
      startTime: DateTime.now().add(const Duration(hours: 1)),
      viewers: 42,
      isLive: false,
    ));
  }

  /// Gibt ein Benutzerprofil zurück
  UserProfile? getUserProfile(String username) {
    return _userProfiles[username];
  }

  /// Erstellt oder aktualisiert ein Benutzerprofil
  void updateUserProfile(String username, UserProfile profile) {
    _userProfiles[username] = profile;
  }

  /// Gibt die Freundesliste eines Benutzers zurück
  List<String> getFriendList(String username) {
    return _friendLists[username] ?? [];
  }

  /// Fügt einen Freund zur Freundesliste hinzu
  void addFriend(String username, String friendUsername) {
    if (!_friendLists.containsKey(username)) {
      _friendLists[username] = [];
    }

    if (!_friendLists[username]!.contains(friendUsername)) {
      _friendLists[username]!.add(friendUsername);
    }
  }

  /// Entfernt einen Freund von der Freundesliste
  void removeFriend(String username, String friendUsername) {
    if (_friendLists.containsKey(username)) {
      _friendLists[username]!.remove(friendUsername);
    }
  }

  /// Gibt alle verfügbaren Turniere zurück
  List<Tournament> getAllTournaments() {
    return _tournaments;
  }

  /// Gibt ein bestimmtes Turnier zurück
  Tournament? getTournament(String tournamentId) {
    return _tournaments.firstWhere(
      (tournament) => tournament.id == tournamentId,
      orElse: () => throw Exception('Turnier nicht gefunden'),
    );
  }

  /// Erstellt ein neues Turnier
  void createTournament(Tournament tournament) {
    _tournaments.add(tournament);
  }

  /// Meldet einen Benutzer für ein Turnier an
  void registerForTournament(String tournamentId, String username) {
    final tournament = getTournament(tournamentId);
    if (tournament != null &&
        tournament.status == TournamentStatus.registrationOpen) {
      if (!tournament.participants.contains(username)) {
        tournament.participants.add(username);
      }
    }
  }

  /// Gibt alle Clans zurück
  List<Clan> getAllClans() {
    return _clans.values.toList();
  }

  /// Gibt einen bestimmten Clan zurück
  Clan? getClan(String clanId) {
    return _clans[clanId];
  }

  /// Erstellt einen neuen Clan
  void createClan(Clan clan) {
    _clans[clan.id] = clan;
  }

  /// Fügt einen Benutzer zu einem Clan hinzu
  void addUserToClan(String clanId, String username) {
    final clan = getClan(clanId);
    if (clan != null && !clan.members.contains(username)) {
      clan.members.add(username);
    }
  }

  /// Entfernt einen Benutzer aus einem Clan
  void removeUserFromClan(String clanId, String username) {
    final clan = getClan(clanId);
    if (clan != null) {
      clan.members.remove(username);
    }
  }

  /// Sendet eine Chat-Nachricht
  void sendChatMessage(ChatMessage message) {
    _chatMessages.add(message);
  }

  /// Gibt alle Chat-Nachrichten zwischen zwei Benutzern zurück
  List<ChatMessage> getChatMessages(String user1, String user2) {
    return _chatMessages
        .where((message) =>
            (message.senderUsername == user1 &&
                message.receiverUsername == user2) ||
            (message.senderUsername == user2 &&
                message.receiverUsername == user1))
        .toList();
  }

  /// Markiert eine Nachricht als gelesen
  void markMessageAsRead(String messageId) {
    final message = _chatMessages.firstWhere(
      (message) => message.id == messageId,
      orElse: () => throw Exception('Nachricht nicht gefunden'),
    );

    message.isRead = true;
  }

  /// Gibt alle Live-Streams zurück
  List<LiveStream> getAllLiveStreams() {
    return _liveStreams;
  }

  /// Gibt einen bestimmten Live-Stream zurück
  LiveStream? getLiveStream(String streamId) {
    return _liveStreams.firstWhere(
      (stream) => stream.id == streamId,
      orElse: () => throw Exception('Stream nicht gefunden'),
    );
  }

  /// Erstellt einen neuen Live-Stream
  void createLiveStream(LiveStream stream) {
    _liveStreams.add(stream);
  }

  /// Beendet einen Live-Stream
  void endLiveStream(String streamId) {
    final stream = getLiveStream(streamId);
    if (stream != null) {
      stream.isLive = false;
    }
  }

  /// Fügt einen Kommentar zu einem Live-Stream hinzu
  void addStreamComment(String streamId, StreamComment comment) {
    final stream = getLiveStream(streamId);
    if (stream != null) {
      stream.comments.add(comment);
    }
  }

  /// Gibt die Rangliste der Spieler zurück
  List<UserProfile> getLeaderboard({int limit = 10}) {
    final leaderboard = _userProfiles.values.toList();
    leaderboard.sort((a, b) => b.rating.compareTo(a.rating));
    return leaderboard.take(limit).toList();
  }

  /// Gibt die Rangliste der Clans zurück
  List<Clan> getClanLeaderboard({int limit = 10}) {
    final leaderboard = _clans.values.toList();
    leaderboard.sort((a, b) => b.rating.compareTo(a.rating));
    return leaderboard.take(limit).toList();
  }

  /// Erstellt ein neues Turnier mit zufälligen Paarungen
  void createTournamentPairings(String tournamentId) {
    final tournament = getTournament(tournamentId);
    if (tournament != null &&
        tournament.status == TournamentStatus.registrationClosed) {
      // Erstelle zufällige Paarungen
      final participants = List<String>.from(tournament.participants);
      participants.shuffle(Random());

      final pairings = <TournamentPairing>[];

      for (int i = 0; i < participants.length - 1; i += 2) {
        pairings.add(TournamentPairing(
          player1: participants[i],
          player2: participants[i + 1],
          result: TournamentPairingResult.notPlayed,
        ));
      }

      // Bei ungerader Anzahl von Teilnehmern erhält der letzte ein Freilos
      if (participants.length % 2 != 0 && participants.isNotEmpty) {
        pairings.add(TournamentPairing(
          player1: participants.last,
          player2: null, // Freilos
          result: TournamentPairingResult.player1Win, // Automatischer Sieg
        ));
      }

      tournament.pairings = pairings;
      tournament.status = TournamentStatus.inProgress;
    }
  }

  /// Aktualisiert das Ergebnis einer Turnierpaarung
  void updateTournamentPairingResult(
      String tournamentId, int pairingIndex, TournamentPairingResult result) {
    final tournament = getTournament(tournamentId);
    if (tournament != null &&
        tournament.status == TournamentStatus.inProgress &&
        pairingIndex < tournament.pairings.length) {
      tournament.pairings[pairingIndex].result = result;

      // Prüfe, ob alle Paarungen gespielt wurden
      final allPairingsPlayed = tournament.pairings.every(
          (pairing) => pairing.result != TournamentPairingResult.notPlayed);

      if (allPairingsPlayed) {
        tournament.status = TournamentStatus.completed;
      }
    }
  }
}

/// Benutzerprofil
class UserProfile {
  final String username;
  String displayName;
  int rating;
  String country;
  final DateTime memberSince;
  int gamesPlayed;
  double winRate;
  String avatarUrl;

  UserProfile({
    required this.username,
    required this.displayName,
    required this.rating,
    required this.country,
    required this.memberSince,
    required this.gamesPlayed,
    required this.winRate,
    required this.avatarUrl,
  });
}

/// Turnier
class Tournament {
  final String id;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final TournamentFormat format;
  final String timeControl;
  final List<String> participants;
  TournamentStatus status;
  List<TournamentPairing> pairings;
  final int? minRating;
  final int? maxRating;

  Tournament({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.format,
    required this.timeControl,
    required this.participants,
    required this.status,
    this.pairings = const [],
    this.minRating,
    this.maxRating,
  });
}

/// Turnierpaarung
class TournamentPairing {
  final String player1;
  final String? player2; // Null bedeutet Freilos
  TournamentPairingResult result;

  TournamentPairing({
    required this.player1,
    required this.player2,
    required this.result,
  });
}

/// Turnierformat
enum TournamentFormat {
  knockout,
  roundRobin,
  swiss,
}

/// Turnierstatus
enum TournamentStatus {
  registrationOpen,
  registrationClosed,
  inProgress,
  completed,
}

/// Ergebnis einer Turnierpaarung
enum TournamentPairingResult {
  notPlayed,
  player1Win,
  player2Win,
  draw,
}

/// Clan/Team
class Clan {
  final String id;
  String name;
  String description;
  final String founderUsername;
  List<String> members;
  int rating;
  int wins;
  int losses;
  int draws;
  final DateTime createdAt;

  Clan({
    required this.id,
    required this.name,
    required this.description,
    required this.founderUsername,
    required this.members,
    required this.rating,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.createdAt,
  });
}

/// Chat-Nachricht
class ChatMessage {
  final String id;
  final String senderUsername;
  final String receiverUsername;
  final String content;
  final DateTime timestamp;
  bool isRead;

  ChatMessage({
    required this.id,
    required this.senderUsername,
    required this.receiverUsername,
    required this.content,
    required this.timestamp,
    required this.isRead,
  });
}

/// Live-Stream
class LiveStream {
  final String id;
  final String title;
  final String streamerUsername;
  final String description;
  final DateTime startTime;
  int viewers;
  bool isLive;
  final List<StreamComment> comments;

  LiveStream({
    required this.id,
    required this.title,
    required this.streamerUsername,
    required this.description,
    required this.startTime,
    required this.viewers,
    required this.isLive,
    this.comments = const [],
  });
}

/// Stream-Kommentar
class StreamComment {
  final String id;
  final String username;
  final String content;
  final DateTime timestamp;

  StreamComment({
    required this.id,
    required this.username,
    required this.content,
    required this.timestamp,
  });
}
