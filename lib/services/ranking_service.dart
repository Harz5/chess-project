import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service für erweiterte Online-Funktionen wie Ranglisten und ELO-System.
class RankingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Standardwerte für neue Spieler
  static const int DEFAULT_ELO = 1200;
  static const int DEFAULT_WINS = 0;
  static const int DEFAULT_LOSSES = 0;
  static const int DEFAULT_DRAWS = 0;

  /// Erstellt oder aktualisiert ein Spielerprofil.
  Future<void> createOrUpdatePlayerProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    // Stelle sicher, dass der Benutzer angemeldet ist
    User? user = _auth.currentUser;
    user ??= await _signInAnonymously();

    // Überprüfe, ob das Profil bereits existiert
    final profileDoc =
        await _firestore.collection('player_profiles').doc(user.uid).get();

    if (profileDoc.exists) {
      // Aktualisiere das bestehende Profil
      await _firestore.collection('player_profiles').doc(user.uid).update({
        'displayName': displayName ??
            user.displayName ??
            'Spieler ${user.uid.substring(0, 5)}',
        'photoUrl': photoUrl ?? user.photoURL,
        'lastActive': FieldValue.serverTimestamp(),
      });
    } else {
      // Erstelle ein neues Profil
      await _firestore.collection('player_profiles').doc(user.uid).set({
        'userId': user.uid,
        'displayName': displayName ??
            user.displayName ??
            'Spieler ${user.uid.substring(0, 5)}',
        'photoUrl': photoUrl ?? user.photoURL,
        'elo': DEFAULT_ELO,
        'wins': DEFAULT_WINS,
        'losses': DEFAULT_LOSSES,
        'draws': DEFAULT_DRAWS,
        'gamesPlayed': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'lastActive': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Aktualisiert die ELO-Wertung nach einem Spiel.
  Future<void> updateEloRating(
      String opponentId, bool isWin, bool isDraw) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Hole die Spielerprofile
    final playerDoc =
        await _firestore.collection('player_profiles').doc(user.uid).get();
    final opponentDoc =
        await _firestore.collection('player_profiles').doc(opponentId).get();

    if (!playerDoc.exists || !opponentDoc.exists) return;

    final playerData = playerDoc.data() as Map<String, dynamic>;
    final opponentData = opponentDoc.data() as Map<String, dynamic>;

    final playerElo = playerData['elo'] as int;
    final opponentElo = opponentData['elo'] as int;

    // Berechne die neuen ELO-Werte
    final (newPlayerElo, newOpponentElo) =
        _calculateNewEloRatings(playerElo, opponentElo, isWin, isDraw);

    // Aktualisiere die Spielerstatistiken
    await _firestore.collection('player_profiles').doc(user.uid).update({
      'elo': newPlayerElo,
      'wins': FieldValue.increment(isWin ? 1 : 0),
      'losses': FieldValue.increment(isWin ? 0 : (isDraw ? 0 : 1)),
      'draws': FieldValue.increment(isDraw ? 1 : 0),
      'gamesPlayed': FieldValue.increment(1),
      'lastActive': FieldValue.serverTimestamp(),
    });

    // Aktualisiere die Gegnerstatistiken
    await _firestore.collection('player_profiles').doc(opponentId).update({
      'elo': newOpponentElo,
      'wins': FieldValue.increment(isWin ? 0 : (isDraw ? 0 : 1)),
      'losses': FieldValue.increment(isWin ? 1 : 0),
      'draws': FieldValue.increment(isDraw ? 1 : 0),
      'gamesPlayed': FieldValue.increment(1),
      'lastActive': FieldValue.serverTimestamp(),
    });

    // Füge das Spiel zur Spielhistorie hinzu
    await _firestore.collection('game_history').add({
      'playerIds': [user.uid, opponentId],
      'playerElos': [playerElo, opponentElo],
      'newPlayerElos': [newPlayerElo, newOpponentElo],
      'winnerId': isWin ? user.uid : (isDraw ? null : opponentId),
      'isDraw': isDraw,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Berechnet die neuen ELO-Werte für beide Spieler.
  (int, int) _calculateNewEloRatings(
      int playerElo, int opponentElo, bool isWin, bool isDraw) {
    // ELO-Konstante (K-Faktor)
    const int K = 32;

    // Erwartete Gewinnwahrscheinlichkeit
    final double expectedScore =
        1.0 / (1.0 + pow(10, (opponentElo - playerElo) / 400));

    // Tatsächliches Ergebnis
    final double actualScore = isWin ? 1.0 : (isDraw ? 0.5 : 0.0);

    // Berechne die ELO-Änderung
    final int eloChange = (K * (actualScore - expectedScore)).round();

    // Neue ELO-Werte
    final int newPlayerElo = playerElo + eloChange;
    final int newOpponentElo = opponentElo - eloChange;

    return (newPlayerElo, newOpponentElo);
  }

  /// Holt die Top-Spieler nach ELO-Wertung.
  Future<List<Map<String, dynamic>>> getTopPlayers({int limit = 10}) async {
    final querySnapshot = await _firestore
        .collection('player_profiles')
        .orderBy('elo', descending: true)
        .limit(limit)
        .get();

    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  /// Holt die Spielhistorie eines Spielers.
  Future<List<Map<String, dynamic>>> getPlayerGameHistory(String playerId,
      {int limit = 20}) async {
    final querySnapshot = await _firestore
        .collection('game_history')
        .where('playerIds', arrayContains: playerId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();

    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }

  /// Holt das Spielerprofil.
  Future<Map<String, dynamic>?> getPlayerProfile(String playerId) async {
    final doc =
        await _firestore.collection('player_profiles').doc(playerId).get();
    if (doc.exists) {
      return doc.data();
    }
    return null;
  }

  /// Holt das aktuelle Spielerprofil.
  Future<Map<String, dynamic>?> getCurrentPlayerProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    return getPlayerProfile(user.uid);
  }

  /// Meldet den Benutzer anonym an.
  Future<User> _signInAnonymously() async {
    final userCredential = await _auth.signInAnonymously();
    return userCredential.user!;
  }

  /// Hilfsfunktion für Potenzberechnung.
  double pow(num x, num exponent) {
    return x.toDouble() * exponent.toDouble();
  }
}
