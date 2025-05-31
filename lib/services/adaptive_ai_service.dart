import 'package:flutter/material.dart';
import '../models/chess_board.dart';
import '../models/chess_piece.dart';
import '../models/position.dart';
import 'package:stockfish/stockfish.dart';
import 'dart:async';
import 'dart:math';

/// Verbesserte KI-Service-Klasse mit adaptiver Schwierigkeitsanpassung
class AdaptiveAIService {
  // Singleton-Instanz
  static final AdaptiveAIService _instance = AdaptiveAIService._internal();
  factory AdaptiveAIService() => _instance;
  AdaptiveAIService._internal();

  // Stockfish-Engine
  late StockfishClient _stockfish;
  bool _isInitialized = false;

  // Schwierigkeitseinstellungen
  final Map<String, int> _difficultyLevels = {
    'Anfänger': 1,
    'Leicht': 5,
    'Mittel': 10,
    'Schwer': 15,
    'Experte': 20,
  };

  String _currentDifficulty = 'Mittel';
  int _currentSkillLevel = 10;

  // Adaptive Schwierigkeitsanpassung
  bool _adaptiveDifficultyEnabled = true;
  int _playerRating = 1200; // Anfängliche Spielerbewertung
  final int _aiRating = 1200; // Anfängliche KI-Bewertung
  final List<int> _playerPerformanceHistory = [];
  final int _adaptiveAdjustmentFactor = 50; // Wie schnell sich die KI anpasst

  // Spielstil-Einstellungen
  String _playStyle = 'Ausgewogen';
  final Map<String, Map<String, dynamic>> _playStyles = {
    'Ausgewogen': {
      'aggressiveness': 0.5,
      'defensiveness': 0.5,
      'creativity': 0.5,
      'positionality': 0.5,
    },
    'Aggressiv': {
      'aggressiveness': 0.9,
      'defensiveness': 0.3,
      'creativity': 0.7,
      'positionality': 0.4,
    },
    'Defensiv': {
      'aggressiveness': 0.2,
      'defensiveness': 0.9,
      'creativity': 0.4,
      'positionality': 0.7,
    },
    'Kreativ': {
      'aggressiveness': 0.6,
      'defensiveness': 0.5,
      'creativity': 0.9,
      'positionality': 0.3,
    },
    'Positionell': {
      'aggressiveness': 0.4,
      'defensiveness': 0.6,
      'creativity': 0.3,
      'positionality': 0.9,
    },
  };

  // Lernfähigkeit
  final Map<String, List<Move>> _openingMoves = {};
  final Map<String, Map<String, int>> _playerResponsePatterns = {};

  /// Initialisiert die Stockfish-Engine
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _stockfish = StockfishClient();
      await _stockfish.start();

      // Konfiguriere die Engine
      _stockfish.stdin = 'setoption name Skill Level value $_currentSkillLevel';
      _stockfish.stdin = 'setoption name Threads value 4';
      _stockfish.stdin = 'setoption name Hash value 128';

      _isInitialized = true;
    } catch (e) {
      print('Fehler bei der Initialisierung der Stockfish-Engine: $e');
      rethrow;
    }
  }

  /// Setzt die Schwierigkeit der KI
  void setDifficulty(String difficulty) {
    if (!_difficultyLevels.containsKey(difficulty)) {
      throw ArgumentError('Ungültige Schwierigkeit: $difficulty');
    }

    _currentDifficulty = difficulty;
    _currentSkillLevel = _difficultyLevels[difficulty]!;

    if (_isInitialized) {
      _stockfish.stdin = 'setoption name Skill Level value $_currentSkillLevel';
    }
  }

  /// Aktiviert oder deaktiviert die adaptive Schwierigkeitsanpassung
  void setAdaptiveDifficulty(bool enabled) {
    _adaptiveDifficultyEnabled = enabled;
  }

  /// Setzt den Spielstil der KI
  void setPlayStyle(String playStyle) {
    if (!_playStyles.containsKey(playStyle)) {
      throw ArgumentError('Ungültiger Spielstil: $playStyle');
    }

    _playStyle = playStyle;
  }

  /// Berechnet den besten Zug für die aktuelle Spielposition
  Future<Move?> calculateBestMove(ChessBoard board,
      {int thinkingTimeMs = 1000}) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Konvertiere das Brett in FEN-Notation
      final fen = _boardToFen(board);

      // Prüfe, ob wir in der Eröffnungsphase sind und einen gespeicherten Zug haben
      if (board.moveHistory.length < 10) {
        final openingMove = _getOpeningMove(fen);
        if (openingMove != null) {
          return openingMove;
        }
      }

      // Passe die Schwierigkeit basierend auf der Spielerleistung an
      if (_adaptiveDifficultyEnabled) {
        _adjustDifficultyBasedOnPerformance();
      }

      // Konfiguriere die Engine für den aktuellen Spielstil
      _configureEngineForPlayStyle();

      // Setze die Position
      _stockfish.stdin = 'position fen $fen';

      // Berechne den besten Zug mit begrenzter Denkzeit
      _stockfish.stdin = 'go movetime $thinkingTimeMs';

      // Warte auf die Antwort
      String? bestMoveString;
      final completer = Completer<String?>();

      final subscription = _stockfish.stdout.listen((line) {
        if (line.startsWith('bestmove')) {
          final parts = line.split(' ');
          if (parts.length >= 2) {
            bestMoveString = parts[1];
            if (!completer.isCompleted) {
              completer.complete(bestMoveString);
            }
          }
        }
      });

      // Warte auf das Ergebnis oder Timeout
      bestMoveString = await completer.future.timeout(
        Duration(milliseconds: thinkingTimeMs + 500),
        onTimeout: () {
          print('Timeout bei der Berechnung des besten Zugs');
          return null;
        },
      );

      subscription.cancel();

      if (bestMoveString == null || bestMoveString == '(none)') {
        return null;
      }

      // Konvertiere den Zug-String in ein Move-Objekt
      final move = _moveFromString(bestMoveString!, board);

      // Speichere den Zug für zukünftige Referenz
      if (board.moveHistory.length < 10) {
        _storeOpeningMove(fen, move);
      }

      return move;
    } catch (e) {
      print('Fehler bei der Berechnung des besten Zugs: $e');
      return null;
    }
  }

  /// Passt die Schwierigkeit basierend auf der Spielerleistung an
  void _adjustDifficultyBasedOnPerformance() {
    if (_playerPerformanceHistory.isEmpty) return;

    // Berechne die durchschnittliche Leistung der letzten Spiele
    final avgPerformance = _playerPerformanceHistory
            .sublist(max(0, _playerPerformanceHistory.length - 5))
            .reduce((a, b) => a + b) /
        min(5, _playerPerformanceHistory.length);

    // Passe die Spielerbewertung an
    if (avgPerformance > 0) {
      _playerRating += _adaptiveAdjustmentFactor;
    } else if (avgPerformance < 0) {
      _playerRating -= _adaptiveAdjustmentFactor;
    }

    // Passe die KI-Bewertung an, um eine Herausforderung zu bieten
    // Ziel: Die KI sollte leicht über dem Spieler sein
    final targetRating = _playerRating + 100;

    // Berechne den neuen Skill-Level basierend auf der Ziel-Bewertung
    // Skill Level 0 = ca. 800, Skill Level 20 = ca. 2800
    int newSkillLevel = ((targetRating - 800) / 100).round();
    newSkillLevel = newSkillLevel.clamp(0, 20);

    // Aktualisiere den Skill-Level
    if (newSkillLevel != _currentSkillLevel) {
      _currentSkillLevel = newSkillLevel;
      _stockfish.stdin = 'setoption name Skill Level value $_currentSkillLevel';

      // Aktualisiere auch die aktuelle Schwierigkeit
      for (final entry in _difficultyLevels.entries) {
        if (entry.value == _currentSkillLevel) {
          _currentDifficulty = entry.key;
          break;
        }
      }
    }
  }

  /// Konfiguriert die Engine für den aktuellen Spielstil
  void _configureEngineForPlayStyle() {
    final style = _playStyles[_playStyle]!;

    // Aggressivität: Beeinflusst, wie sehr die Engine Material für Initiative opfert
    final aggressiveness = style['aggressiveness'] as double;
    _stockfish.stdin =
        'setoption name Aggressiveness value ${(aggressiveness * 100).round()}';

    // Kreativität: Beeinflusst die Variabilität der Züge
    final creativity = style['creativity'] as double;
    _stockfish.stdin =
        'setoption name Contempt value ${((creativity - 0.5) * 100).round()}';

    // Positionelles Spiel vs. Taktisches Spiel
    final positionality = style['positionality'] as double;
    _stockfish.stdin =
        'setoption name Positional value ${(positionality * 100).round()}';
  }

  /// Aktualisiert die Spielerleistung nach einem Spiel
  void updatePlayerPerformance(
      bool playerWon, int moveCount, int capturedPieces) {
    // Positive Werte bedeuten, dass der Spieler gut gespielt hat
    int performanceScore = 0;

    if (playerWon) {
      performanceScore += 100;
    } else {
      performanceScore -= 50;
    }

    // Berücksichtige die Spiellänge (kürzere Siege sind beeindruckender)
    if (playerWon && moveCount < 30) {
      performanceScore += 50;
    }

    // Berücksichtige die Anzahl der geschlagenen Figuren
    performanceScore += (capturedPieces - 8) * 5; // 8 ist durchschnittlich

    _playerPerformanceHistory.add(performanceScore);

    // Begrenze die Historie auf die letzten 20 Spiele
    if (_playerPerformanceHistory.length > 20) {
      _playerPerformanceHistory.removeAt(0);
    }

    // Passe die Schwierigkeit an
    if (_adaptiveDifficultyEnabled) {
      _adjustDifficultyBasedOnPerformance();
    }
  }

  /// Analysiert die Spielweise des Spielers
  void analyzePlayerStyle(List<Move> playerMoves, ChessBoard board) {
    if (playerMoves.isEmpty) return;

    // Analysiere die Antworten des Spielers auf bestimmte Positionen
    for (int i = 0; i < playerMoves.length; i++) {
      final move = playerMoves[i];
      final fen = _boardToFen(board);

      if (!_playerResponsePatterns.containsKey(fen)) {
        _playerResponsePatterns[fen] = {};
      }

      final moveStr = _moveToString(move);
      _playerResponsePatterns[fen][moveStr] =
          (_playerResponsePatterns[fen][moveStr] ?? 0) + 1;
    }
  }

  /// Holt einen gespeicherten Eröffnungszug
  Move? _getOpeningMove(String fen) {
    if (_openingMoves.containsKey(fen)) {
      final moves = _openingMoves[fen]!;
      if (moves.isNotEmpty) {
        // Wähle einen zufälligen Zug aus den gespeicherten Zügen
        final random = Random();
        return moves[random.nextInt(moves.length)];
      }
    }
    return null;
  }

  /// Speichert einen Eröffnungszug
  void _storeOpeningMove(String fen, Move move) {
    if (!_openingMoves.containsKey(fen)) {
      _openingMoves[fen] = [];
    }

    // Prüfe, ob der Zug bereits gespeichert ist
    bool moveExists = false;
    for (final m in _openingMoves[fen]!) {
      if (m.from == move.from && m.to == move.to) {
        moveExists = true;
        break;
      }
    }

    if (!moveExists) {
      _openingMoves[fen]!.add(move);
    }
  }

  /// Konvertiert ein Schachbrett in FEN-Notation
  String _boardToFen(ChessBoard board) {
    // Implementierung der FEN-Konvertierung
    // Dies ist eine vereinfachte Version
    String fen = '';

    // Brett
    for (int rank = 7; rank >= 0; rank--) {
      int emptyCount = 0;

      for (int file = 0; file < 8; file++) {
        final position = Position(file: file, rank: rank);
        final piece = board.getPiece(position);

        if (piece == null) {
          emptyCount++;
        } else {
          if (emptyCount > 0) {
            fen += emptyCount.toString();
            emptyCount = 0;
          }

          String pieceChar = '';
          switch (piece.type) {
            case PieceType.pawn:
              pieceChar = 'p';
              break;
            case PieceType.knight:
              pieceChar = 'n';
              break;
            case PieceType.bishop:
              pieceChar = 'b';
              break;
            case PieceType.rook:
              pieceChar = 'r';
              break;
            case PieceType.queen:
              pieceChar = 'q';
              break;
            case PieceType.king:
              pieceChar = 'k';
              break;
          }

          if (piece.color == PieceColor.white) {
            pieceChar = pieceChar.toUpperCase();
          }

          fen += pieceChar;
        }
      }

      if (emptyCount > 0) {
        fen += emptyCount.toString();
      }

      if (rank > 0) {
        fen += '/';
      }
    }

    // Aktiver Spieler
    fen += ' ${board.currentTurn == PieceColor.white ? 'w' : 'b'} ';

    // Rochade-Möglichkeiten (vereinfacht)
    fen += 'KQkq ';

    // En passant (vereinfacht)
    fen += '- ';

    // Halbzug-Uhr und Vollzug-Nummer (vereinfacht)
    fen += '0 1';

    return fen;
  }

  /// Konvertiert einen Zug-String in ein Move-Objekt
  Move _moveFromString(String moveStr, ChessBoard board) {
    final fromFile = moveStr.codeUnitAt(0) - 'a'.codeUnitAt(0);
    final fromRank = int.parse(moveStr[1]) - 1;
    final toFile = moveStr.codeUnitAt(2) - 'a'.codeUnitAt(0);
    final toRank = int.parse(moveStr[3]) - 1;

    final from = Position(file: fromFile, rank: fromRank);
    final to = Position(file: toFile, rank: toRank);

    // Prüfe auf Beförderung
    String? promotion;
    if (moveStr.length > 4) {
      promotion = moveStr[4];
    }

    return Move(from: from, to: to, promotion: promotion);
  }

  /// Konvertiert ein Move-Objekt in einen String
  String _moveToString(Move move) {
    final fromFile = String.fromCharCode('a'.codeUnitAt(0) + move.from.file);
    final fromRank = (move.from.rank + 1).toString();
    final toFile = String.fromCharCode('a'.codeUnitAt(0) + move.to.file);
    final toRank = (move.to.rank + 1).toString();

    String moveStr = '$fromFile$fromRank$toFile$toRank';

    if (move.promotion != null) {
      moveStr += move.promotion!;
    }

    return moveStr;
  }

  /// Gibt die aktuelle Schwierigkeit zurück
  String getCurrentDifficulty() {
    return _currentDifficulty;
  }

  /// Gibt den aktuellen Skill-Level zurück
  int getCurrentSkillLevel() {
    return _currentSkillLevel;
  }

  /// Gibt zurück, ob die adaptive Schwierigkeitsanpassung aktiviert ist
  bool isAdaptiveDifficultyEnabled() {
    return _adaptiveDifficultyEnabled;
  }

  /// Gibt den aktuellen Spielstil zurück
  String getCurrentPlayStyle() {
    return _playStyle;
  }

  /// Gibt die verfügbaren Spielstile zurück
  List<String> getAvailablePlayStyles() {
    return _playStyles.keys.toList();
  }

  /// Gibt die verfügbaren Schwierigkeitsgrade zurück
  List<String> getAvailableDifficulties() {
    return _difficultyLevels.keys.toList();
  }

  /// Gibt die aktuelle Spielerbewertung zurück
  int getPlayerRating() {
    return _playerRating;
  }

  /// Gibt die aktuelle KI-Bewertung zurück
  int getAIRating() {
    return _aiRating;
  }

  /// Bereinigt Ressourcen
  void dispose() {
    if (_isInitialized) {
      _stockfish.stdin = 'quit';
      _isInitialized = false;
    }
  }
}
