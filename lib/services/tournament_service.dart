import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/tournament.dart';
import '../models/tournament_match.dart';
import '../models/tournament_participant.dart';

/// Service für Turnierfunktionalität
class TournamentService {
  // Singleton-Instanz
  static final TournamentService _instance = TournamentService._internal();
  factory TournamentService() => _instance;
  TournamentService._internal();

  // Firebase-Instanzen
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Turniere erstellen und verwalten
  Future<String?> createTournament(Tournament tournament) async {
    try {
      final docRef =
          await _firestore.collection('tournaments').add(tournament.toMap());
      return docRef.id;
    } catch (e) {
      print('Fehler beim Erstellen des Turniers: $e');
      return null;
    }
  }

  Future<bool> updateTournament(Tournament tournament) async {
    try {
      await _firestore
          .collection('tournaments')
          .doc(tournament.id)
          .update(tournament.toMap());
      return true;
    } catch (e) {
      print('Fehler beim Aktualisieren des Turniers: $e');
      return false;
    }
  }

  Future<bool> deleteTournament(String tournamentId) async {
    try {
      await _firestore.collection('tournaments').doc(tournamentId).delete();
      return true;
    } catch (e) {
      print('Fehler beim Löschen des Turniers: $e');
      return false;
    }
  }

  Future<Tournament?> getTournament(String tournamentId) async {
    try {
      final doc =
          await _firestore.collection('tournaments').doc(tournamentId).get();
      if (doc.exists) {
        return Tournament.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Fehler beim Abrufen des Turniers: $e');
      return null;
    }
  }

  // Turnierlisten abrufen
  Stream<List<Tournament>> getUpcomingTournaments() {
    return _firestore
        .collection('tournaments')
        .where('startTime', isGreaterThan: DateTime.now())
        .orderBy('startTime')
        .limit(20)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Tournament.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Stream<List<Tournament>> getOngoingTournaments() {
    final now = DateTime.now();
    return _firestore
        .collection('tournaments')
        .where('startTime', isLessThanOrEqualTo: now)
        .where('endTime', isGreaterThanOrEqualTo: now)
        .orderBy('startTime')
        .limit(20)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Tournament.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Stream<List<Tournament>> getCompletedTournaments() {
    return _firestore
        .collection('tournaments')
        .where('endTime', isLessThan: DateTime.now())
        .orderBy('endTime', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Tournament.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Stream<List<Tournament>> getUserTournaments(String userId) {
    return _firestore
        .collection('tournaments')
        .where('participants', arrayContains: userId)
        .orderBy('startTime', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Tournament.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Teilnehmer verwalten
  Future<bool> registerForTournament(String tournamentId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      // Prüfe, ob das Turnier existiert und Registrierungen offen sind
      final tournamentDoc =
          await _firestore.collection('tournaments').doc(tournamentId).get();
      if (!tournamentDoc.exists) return false;

      final tournamentData = tournamentDoc.data()!;
      final registrationOpen = tournamentData['registrationOpen'] ?? false;
      final maxParticipants = tournamentData['maxParticipants'] ?? 0;
      final participants =
          List<String>.from(tournamentData['participants'] ?? []);

      if (!registrationOpen) return false;
      if (maxParticipants > 0 && participants.length >= maxParticipants)
        return false;
      if (participants.contains(currentUser.uid))
        return true; // Bereits registriert

      // Erstelle Teilnehmer
      final participant = TournamentParticipant(
        userId: currentUser.uid,
        tournamentId: tournamentId,
        registrationTime: DateTime.now(),
        status: 'active',
        score: 0,
        rank: 0,
        matchesPlayed: 0,
        matchesWon: 0,
        matchesLost: 0,
        matchesDraw: 0,
      );

      // Füge Teilnehmer zum Turnier hinzu
      await _firestore.collection('tournaments').doc(tournamentId).update({
        'participants': FieldValue.arrayUnion([currentUser.uid]),
        'participantCount': FieldValue.increment(1),
      });

      // Speichere Teilnehmerdaten
      await _firestore
          .collection('tournaments')
          .doc(tournamentId)
          .collection('participants')
          .doc(currentUser.uid)
          .set(participant.toMap());

      return true;
    } catch (e) {
      print('Fehler bei der Turnierregistrierung: $e');
      return false;
    }
  }

  Future<bool> unregisterFromTournament(String tournamentId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    try {
      // Prüfe, ob das Turnier existiert und Registrierungen offen sind
      final tournamentDoc =
          await _firestore.collection('tournaments').doc(tournamentId).get();
      if (!tournamentDoc.exists) return false;

      final tournamentData = tournamentDoc.data()!;
      final registrationOpen = tournamentData['registrationOpen'] ?? false;
      final participants =
          List<String>.from(tournamentData['participants'] ?? []);

      if (!registrationOpen) return false;
      if (!participants.contains(currentUser.uid))
        return true; // Nicht registriert

      // Entferne Teilnehmer vom Turnier
      await _firestore.collection('tournaments').doc(tournamentId).update({
        'participants': FieldValue.arrayRemove([currentUser.uid]),
        'participantCount': FieldValue.increment(-1),
      });

      // Lösche Teilnehmerdaten
      await _firestore
          .collection('tournaments')
          .doc(tournamentId)
          .collection('participants')
          .doc(currentUser.uid)
          .delete();

      return true;
    } catch (e) {
      print('Fehler bei der Turnierregistrierung: $e');
      return false;
    }
  }

  Stream<List<TournamentParticipant>> getTournamentParticipants(
      String tournamentId) {
    return _firestore
        .collection('tournaments')
        .doc(tournamentId)
        .collection('participants')
        .orderBy('score', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TournamentParticipant.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Matches verwalten
  Future<String?> createMatch(TournamentMatch match) async {
    try {
      final docRef = await _firestore
          .collection('tournaments')
          .doc(match.tournamentId)
          .collection('matches')
          .add(match.toMap());
      return docRef.id;
    } catch (e) {
      print('Fehler beim Erstellen des Matches: $e');
      return null;
    }
  }

  Future<bool> updateMatch(TournamentMatch match) async {
    try {
      await _firestore
          .collection('tournaments')
          .doc(match.tournamentId)
          .collection('matches')
          .doc(match.id)
          .update(match.toMap());
      return true;
    } catch (e) {
      print('Fehler beim Aktualisieren des Matches: $e');
      return false;
    }
  }

  Stream<List<TournamentMatch>> getTournamentMatches(String tournamentId) {
    return _firestore
        .collection('tournaments')
        .doc(tournamentId)
        .collection('matches')
        .orderBy('scheduledTime')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TournamentMatch.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Stream<List<TournamentMatch>> getUserTournamentMatches(String tournamentId) {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('tournaments')
        .doc(tournamentId)
        .collection('matches')
        .where('players', arrayContains: currentUser.uid)
        .orderBy('scheduledTime')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TournamentMatch.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Turnierergebnisse
  Future<bool> submitMatchResult(String tournamentId, String matchId,
      String winnerId, Map<String, dynamic> gameData) async {
    try {
      final matchRef = _firestore
          .collection('tournaments')
          .doc(tournamentId)
          .collection('matches')
          .doc(matchId);

      final matchDoc = await matchRef.get();
      if (!matchDoc.exists) return false;

      final matchData = matchDoc.data()!;
      final players = List<String>.from(matchData['players']);

      if (players.length != 2) return false;

      final loserId = players[0] == winnerId ? players[1] : players[0];

      // Aktualisiere Match
      await matchRef.update({
        'completed': true,
        'winnerId': winnerId,
        'gameData': gameData,
        'completedTime': DateTime.now(),
      });

      // Aktualisiere Teilnehmerstatistiken
      if (winnerId != 'draw') {
        // Gewinner aktualisieren
        await _firestore
            .collection('tournaments')
            .doc(tournamentId)
            .collection('participants')
            .doc(winnerId)
            .update({
          'score': FieldValue.increment(1),
          'matchesPlayed': FieldValue.increment(1),
          'matchesWon': FieldValue.increment(1),
        });

        // Verlierer aktualisieren
        await _firestore
            .collection('tournaments')
            .doc(tournamentId)
            .collection('participants')
            .doc(loserId)
            .update({
          'matchesPlayed': FieldValue.increment(1),
          'matchesLost': FieldValue.increment(1),
        });
      } else {
        // Unentschieden
        for (final playerId in players) {
          await _firestore
              .collection('tournaments')
              .doc(tournamentId)
              .collection('participants')
              .doc(playerId)
              .update({
            'score': FieldValue.increment(0.5),
            'matchesPlayed': FieldValue.increment(1),
            'matchesDraw': FieldValue.increment(1),
          });
        }
      }

      return true;
    } catch (e) {
      print('Fehler beim Übermitteln des Matchergebnisses: $e');
      return false;
    }
  }

  Future<bool> updateRankings(String tournamentId) async {
    try {
      // Hole alle Teilnehmer sortiert nach Punktzahl
      final participantsSnapshot = await _firestore
          .collection('tournaments')
          .doc(tournamentId)
          .collection('participants')
          .orderBy('score', descending: true)
          .get();

      final participants = participantsSnapshot.docs;

      // Aktualisiere Rang für jeden Teilnehmer
      int rank = 1;
      for (int i = 0; i < participants.length; i++) {
        // Gleicher Rang bei gleicher Punktzahl
        if (i > 0 &&
            participants[i].data()['score'] ==
                participants[i - 1].data()['score']) {
          // Behalte den gleichen Rang wie der vorherige Teilnehmer
        } else {
          rank = i + 1;
        }

        await participants[i].reference.update({'rank': rank});
      }

      return true;
    } catch (e) {
      print('Fehler beim Aktualisieren der Rangliste: $e');
      return false;
    }
  }

  // Turnierphasen
  Future<bool> startTournament(String tournamentId) async {
    try {
      final tournamentRef =
          _firestore.collection('tournaments').doc(tournamentId);
      final tournamentDoc = await tournamentRef.get();

      if (!tournamentDoc.exists) return false;

      final tournamentData = tournamentDoc.data()!;
      final status = tournamentData['status'] as String?;

      if (status != 'scheduled') return false;

      // Aktualisiere Turnierstatus
      await tournamentRef.update({
        'status': 'ongoing',
        'registrationOpen': false,
        'startTime': DateTime.now(),
      });

      // Generiere erste Runde von Matches
      await _generateMatches(tournamentId);

      return true;
    } catch (e) {
      print('Fehler beim Starten des Turniers: $e');
      return false;
    }
  }

  Future<bool> endTournament(String tournamentId) async {
    try {
      final tournamentRef =
          _firestore.collection('tournaments').doc(tournamentId);
      final tournamentDoc = await tournamentRef.get();

      if (!tournamentDoc.exists) return false;

      final tournamentData = tournamentDoc.data()!;
      final status = tournamentData['status'] as String?;

      if (status != 'ongoing') return false;

      // Aktualisiere Rangliste ein letztes Mal
      await updateRankings(tournamentId);

      // Aktualisiere Turnierstatus
      await tournamentRef.update({
        'status': 'completed',
        'endTime': DateTime.now(),
      });

      return true;
    } catch (e) {
      print('Fehler beim Beenden des Turniers: $e');
      return false;
    }
  }

  Future<bool> advanceToNextRound(String tournamentId) async {
    try {
      // Prüfe, ob alle Matches der aktuellen Runde abgeschlossen sind
      final matchesSnapshot = await _firestore
          .collection('tournaments')
          .doc(tournamentId)
          .collection('matches')
          .where('round', isEqualTo: await _getCurrentRound(tournamentId))
          .get();

      for (final match in matchesSnapshot.docs) {
        if (!(match.data()['completed'] ?? false)) {
          return false; // Nicht alle Matches sind abgeschlossen
        }
      }

      // Aktualisiere Rangliste
      await updateRankings(tournamentId);

      // Generiere Matches für die nächste Runde
      await _generateMatches(tournamentId);

      return true;
    } catch (e) {
      print('Fehler beim Fortschreiten zur nächsten Runde: $e');
      return false;
    }
  }

  Future<int> _getCurrentRound(String tournamentId) async {
    try {
      final matchesSnapshot = await _firestore
          .collection('tournaments')
          .doc(tournamentId)
          .collection('matches')
          .orderBy('round', descending: true)
          .limit(1)
          .get();

      if (matchesSnapshot.docs.isEmpty) {
        return 0;
      }

      return matchesSnapshot.docs.first.data()['round'] ?? 0;
    } catch (e) {
      print('Fehler beim Abrufen der aktuellen Runde: $e');
      return 0;
    }
  }

  Future<void> _generateMatches(String tournamentId) async {
    try {
      final tournamentDoc =
          await _firestore.collection('tournaments').doc(tournamentId).get();
      if (!tournamentDoc.exists) return;

      final tournamentData = tournamentDoc.data()!;
      final format = tournamentData['format'] as String? ?? 'swiss';
      final currentRound = await _getCurrentRound(tournamentId);
      final nextRound = currentRound + 1;

      // Hole alle aktiven Teilnehmer
      final participantsSnapshot = await _firestore
          .collection('tournaments')
          .doc(tournamentId)
          .collection('participants')
          .where('status', isEqualTo: 'active')
          .get();

      final participants = participantsSnapshot.docs
          .map((doc) => TournamentParticipant.fromMap(doc.data(), doc.id))
          .toList();

      if (participants.isEmpty) return;

      // Generiere Matches basierend auf dem Turnierformat
      List<List<String>> pairings = [];

      switch (format) {
        case 'swiss':
          pairings =
              _generateSwissPairings(participants, nextRound, tournamentId);
          break;
        case 'elimination':
          pairings = _generateEliminationPairings(
              participants, nextRound, tournamentId);
          break;
        case 'roundrobin':
          pairings = _generateRoundRobinPairings(
              participants, nextRound, tournamentId);
          break;
        default:
          pairings =
              _generateSwissPairings(participants, nextRound, tournamentId);
      }

      // Erstelle Matches
      for (final pairing in pairings) {
        if (pairing.length == 2) {
          final match = TournamentMatch(
            tournamentId: tournamentId,
            round: nextRound,
            players: pairing,
            scheduledTime: DateTime.now().add(const Duration(minutes: 5)),
            status: 'scheduled',
            completed: false,
          );

          await createMatch(match);
        }
      }
    } catch (e) {
      print('Fehler beim Generieren von Matches: $e');
    }
  }

  List<List<String>> _generateSwissPairings(
      List<TournamentParticipant> participants,
      int round,
      String tournamentId) {
    // Sortiere Teilnehmer nach Punktzahl
    participants.sort((a, b) => b.score.compareTo(a.score));

    final List<List<String>> pairings = [];
    final Set<String> paired = {};

    // Einfache Paarung nach Punktzahl
    for (int i = 0; i < participants.length; i++) {
      if (paired.contains(participants[i].userId)) continue;

      paired.add(participants[i].userId);

      // Finde den nächsten nicht gepaarten Spieler
      for (int j = i + 1; j < participants.length; j++) {
        if (!paired.contains(participants[j].userId)) {
          paired.add(participants[j].userId);
          pairings.add([participants[i].userId, participants[j].userId]);
          break;
        }
      }
    }

    // Wenn ein Spieler übrig bleibt, erhält er ein Freilos
    if (participants.length % 2 != 0) {
      for (final participant in participants) {
        if (!paired.contains(participant.userId)) {
          // Freilos - in einer echten Implementierung würde hier ein Bye-Match erstellt
          break;
        }
      }
    }

    return pairings;
  }

  List<List<String>> _generateEliminationPairings(
      List<TournamentParticipant> participants,
      int round,
      String tournamentId) {
    // Für die erste Runde: Zufällige Paarungen
    if (round == 1) {
      participants.shuffle();
    } else {
      // Für spätere Runden: Nur Gewinner der vorherigen Runde paaren
      // In einer echten Implementierung würden hier die Gewinner der vorherigen Runde ermittelt
    }

    final List<List<String>> pairings = [];

    for (int i = 0; i < participants.length; i += 2) {
      if (i + 1 < participants.length) {
        pairings.add([participants[i].userId, participants[i + 1].userId]);
      }
    }

    return pairings;
  }

  List<List<String>> _generateRoundRobinPairings(
      List<TournamentParticipant> participants,
      int round,
      String tournamentId) {
    final n = participants.length;
    final List<List<String>> pairings = [];

    // Implementierung des Berger-Systems für Round Robin
    // Für ungerade Anzahl von Spielern füge einen Dummy-Spieler hinzu
    final List<TournamentParticipant> players = List.from(participants);
    if (n % 2 != 0) {
      players.add(TournamentParticipant(
        userId: 'dummy',
        tournamentId: tournamentId,
        registrationTime: DateTime.now(),
        status: 'active',
        score: 0,
        rank: 0,
        matchesPlayed: 0,
        matchesWon: 0,
        matchesLost: 0,
        matchesDraw: 0,
      ));
    }

    final numPlayers = players.length;
    final numRounds = numPlayers - 1;

    if (round > numRounds) return []; // Keine weiteren Runden nötig

    // Berechne Paarungen für die aktuelle Runde
    final List<String> fixed = [players[0].userId];
    final List<String> rotating =
        players.sublist(1).map((p) => p.userId).toList();

    // Rotiere die Spieler für die aktuelle Runde
    for (int i = 0; i < round - 1; i++) {
      final last = rotating.removeLast();
      rotating.insert(0, last);
    }

    // Erstelle Paarungen
    for (int i = 0; i < numPlayers ~/ 2; i++) {
      if (i == 0) {
        if (fixed[0] != 'dummy' && rotating[i] != 'dummy') {
          pairings.add([fixed[0], rotating[i]]);
        }
      } else {
        final idx = numPlayers - 1 - i;
        if (rotating[i] != 'dummy' && rotating[idx] != 'dummy') {
          pairings.add([rotating[i], rotating[idx]]);
        }
      }
    }

    return pairings;
  }
}
