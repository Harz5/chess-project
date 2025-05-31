import 'package:flutter/material.dart';
import '../services/tournament_service.dart';
import '../models/tournament.dart';
import '../models/tournament_match.dart';
import '../models/tournament_participant.dart';

/// Provider für die Verwaltung der Turnierfunktionalität
class TournamentProvider extends ChangeNotifier {
  final TournamentService _tournamentService = TournamentService();

  // Turniere
  List<Tournament> _upcomingTournaments = [];
  List<Tournament> _ongoingTournaments = [];
  List<Tournament> _completedTournaments = [];
  List<Tournament> _userTournaments = [];

  final bool _isLoadingTournaments = false;
  String _tournamentsError = '';

  // Aktuelles Turnier
  Tournament? _currentTournament;
  List<TournamentParticipant> _participants = [];
  List<TournamentMatch> _matches = [];
  List<TournamentMatch> _userMatches = [];

  bool _isLoadingTournamentDetails = false;
  String _tournamentDetailsError = '';

  // Turniererstellung
  bool _isCreatingTournament = false;
  String _creationError = '';

  // Getter
  List<Tournament> get upcomingTournaments => _upcomingTournaments;
  List<Tournament> get ongoingTournaments => _ongoingTournaments;
  List<Tournament> get completedTournaments => _completedTournaments;
  List<Tournament> get userTournaments => _userTournaments;

  bool get isLoadingTournaments => _isLoadingTournaments;
  String get tournamentsError => _tournamentsError;

  Tournament? get currentTournament => _currentTournament;
  List<TournamentParticipant> get participants => _participants;
  List<TournamentMatch> get matches => _matches;
  List<TournamentMatch> get userMatches => _userMatches;

  bool get isLoadingTournamentDetails => _isLoadingTournamentDetails;
  String get tournamentDetailsError => _tournamentDetailsError;

  bool get isCreatingTournament => _isCreatingTournament;
  String get creationError => _creationError;

  // Konstruktor
  TournamentProvider() {
    _initializeStreams();
  }

  // Initialisiert alle Streams
  void _initializeStreams() {
    // Kommende Turniere
    _tournamentService.getUpcomingTournaments().listen((tournaments) {
      _upcomingTournaments = tournaments;
      notifyListeners();
    }, onError: (error) {
      _tournamentsError = 'Fehler beim Laden der kommenden Turniere: $error';
      notifyListeners();
    });

    // Laufende Turniere
    _tournamentService.getOngoingTournaments().listen((tournaments) {
      _ongoingTournaments = tournaments;
      notifyListeners();
    }, onError: (error) {
      _tournamentsError = 'Fehler beim Laden der laufenden Turniere: $error';
      notifyListeners();
    });

    // Abgeschlossene Turniere
    _tournamentService.getCompletedTournaments().listen((tournaments) {
      _completedTournaments = tournaments;
      notifyListeners();
    }, onError: (error) {
      _tournamentsError =
          'Fehler beim Laden der abgeschlossenen Turniere: $error';
      notifyListeners();
    });

    // Benutzerturniere
    _tournamentService.getUserTournaments('').listen((tournaments) {
      _userTournaments = tournaments;
      notifyListeners();
    }, onError: (error) {
      _tournamentsError = 'Fehler beim Laden der Benutzerturniere: $error';
      notifyListeners();
    });
  }

  // Lädt ein bestimmtes Turnier
  Future<void> loadTournament(String tournamentId) async {
    _isLoadingTournamentDetails = true;
    _tournamentDetailsError = '';
    notifyListeners();

    try {
      _currentTournament = await _tournamentService.getTournament(tournamentId);

      if (_currentTournament != null) {
        // Initialisiere Streams für Teilnehmer und Matches
        _tournamentService.getTournamentParticipants(tournamentId).listen(
            (participants) {
          _participants = participants;
          notifyListeners();
        }, onError: (error) {
          _tournamentDetailsError = 'Fehler beim Laden der Teilnehmer: $error';
          notifyListeners();
        });

        _tournamentService.getTournamentMatches(tournamentId).listen((matches) {
          _matches = matches;
          notifyListeners();
        }, onError: (error) {
          _tournamentDetailsError = 'Fehler beim Laden der Matches: $error';
          notifyListeners();
        });

        _tournamentService.getUserTournamentMatches(tournamentId).listen(
            (matches) {
          _userMatches = matches;
          notifyListeners();
        }, onError: (error) {
          _tournamentDetailsError =
              'Fehler beim Laden der Benutzermatches: $error';
          notifyListeners();
        });
      }

      _isLoadingTournamentDetails = false;
      notifyListeners();
    } catch (e) {
      _tournamentDetailsError = 'Fehler beim Laden des Turniers: $e';
      _isLoadingTournamentDetails = false;
      notifyListeners();
    }
  }

  // Erstellt ein neues Turnier
  Future<String?> createTournament(Tournament tournament) async {
    _isCreatingTournament = true;
    _creationError = '';
    notifyListeners();

    try {
      final tournamentId =
          await _tournamentService.createTournament(tournament);

      _isCreatingTournament = false;
      notifyListeners();

      return tournamentId;
    } catch (e) {
      _creationError = 'Fehler beim Erstellen des Turniers: $e';
      _isCreatingTournament = false;
      notifyListeners();
      return null;
    }
  }

  // Aktualisiert ein Turnier
  Future<bool> updateTournament(Tournament tournament) async {
    try {
      final success = await _tournamentService.updateTournament(tournament);

      if (success && _currentTournament?.id == tournament.id) {
        _currentTournament = tournament;
        notifyListeners();
      }

      return success;
    } catch (e) {
      _tournamentDetailsError = 'Fehler beim Aktualisieren des Turniers: $e';
      notifyListeners();
      return false;
    }
  }

  // Löscht ein Turnier
  Future<bool> deleteTournament(String tournamentId) async {
    try {
      final success = await _tournamentService.deleteTournament(tournamentId);

      if (success && _currentTournament?.id == tournamentId) {
        _currentTournament = null;
        _participants = [];
        _matches = [];
        _userMatches = [];
        notifyListeners();
      }

      return success;
    } catch (e) {
      _tournamentDetailsError = 'Fehler beim Löschen des Turniers: $e';
      notifyListeners();
      return false;
    }
  }

  // Registriert den Benutzer für ein Turnier
  Future<bool> registerForTournament(String tournamentId) async {
    try {
      return await _tournamentService.registerForTournament(tournamentId);
    } catch (e) {
      _tournamentDetailsError = 'Fehler bei der Turnierregistrierung: $e';
      notifyListeners();
      return false;
    }
  }

  // Meldet den Benutzer von einem Turnier ab
  Future<bool> unregisterFromTournament(String tournamentId) async {
    try {
      return await _tournamentService.unregisterFromTournament(tournamentId);
    } catch (e) {
      _tournamentDetailsError = 'Fehler bei der Turnierregistrierung: $e';
      notifyListeners();
      return false;
    }
  }

  // Übermittelt ein Matchergebnis
  Future<bool> submitMatchResult(String tournamentId, String matchId,
      String winnerId, Map<String, dynamic> gameData) async {
    try {
      return await _tournamentService.submitMatchResult(
          tournamentId, matchId, winnerId, gameData);
    } catch (e) {
      _tournamentDetailsError = 'Fehler beim Übermitteln des Ergebnisses: $e';
      notifyListeners();
      return false;
    }
  }

  // Startet ein Turnier
  Future<bool> startTournament(String tournamentId) async {
    try {
      return await _tournamentService.startTournament(tournamentId);
    } catch (e) {
      _tournamentDetailsError = 'Fehler beim Starten des Turniers: $e';
      notifyListeners();
      return false;
    }
  }

  // Beendet ein Turnier
  Future<bool> endTournament(String tournamentId) async {
    try {
      return await _tournamentService.endTournament(tournamentId);
    } catch (e) {
      _tournamentDetailsError = 'Fehler beim Beenden des Turniers: $e';
      notifyListeners();
      return false;
    }
  }

  // Schreitet zur nächsten Runde fort
  Future<bool> advanceToNextRound(String tournamentId) async {
    try {
      return await _tournamentService.advanceToNextRound(tournamentId);
    } catch (e) {
      _tournamentDetailsError =
          'Fehler beim Fortschreiten zur nächsten Runde: $e';
      notifyListeners();
      return false;
    }
  }

  // Aktualisiert die Rangliste
  Future<bool> updateRankings(String tournamentId) async {
    try {
      return await _tournamentService.updateRankings(tournamentId);
    } catch (e) {
      _tournamentDetailsError = 'Fehler beim Aktualisieren der Rangliste: $e';
      notifyListeners();
      return false;
    }
  }
}
