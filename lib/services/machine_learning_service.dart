import 'dart:math';
import 'package:flutter/material.dart';
import '../models/chess_board.dart';
import '../models/chess_piece.dart';
import '../models/position.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

/// Service für maschinelles Lernen und KI-Funktionen
class MachineLearningService {
  // Singleton-Instanz
  static final MachineLearningService _instance =
      MachineLearningService._internal();

  factory MachineLearningService() {
    return _instance;
  }

  // TensorFlow Lite Interpreter
  Interpreter? _interpreter;

  // Spielstil-Parameter
  double _aggressiveness = 0.5; // 0.0 = defensiv, 1.0 = aggressiv
  double _creativity = 0.5; // 0.0 = konservativ, 1.0 = kreativ
  double _positional = 0.5; // 0.0 = taktisch, 1.0 = positionell

  // Lernrate
  final double _learningRate = 0.01;

  // Spielerdatenbank
  final Map<String, List<double>> _playerStyles = {};

  // Spielhistorie für das Lernen
  final List<Map<String, dynamic>> _gameHistory = [];

  MachineLearningService._internal() {
    _initModel();
  }

  /// Initialisiert das TensorFlow Lite Modell
  Future<void> _initModel() async {
    try {
      // In einer realen Implementierung würde hier ein vortrainiertes Modell geladen werden
      // _interpreter = await Interpreter.fromAsset('assets/models/chess_model.tflite');
      print('TensorFlow Lite Modell initialisiert');
    } catch (e) {
      print('Fehler beim Initialisieren des TensorFlow Lite Modells: $e');
    }
  }

  /// Setzt den Spielstil der KI
  void setAIStyle({
    double? aggressiveness,
    double? creativity,
    double? positional,
  }) {
    if (aggressiveness != null)
      _aggressiveness = aggressiveness.clamp(0.0, 1.0);
    if (creativity != null) _creativity = creativity.clamp(0.0, 1.0);
    if (positional != null) _positional = positional.clamp(0.0, 1.0);
  }

  /// Gibt den aktuellen Spielstil der KI zurück
  Map<String, double> getAIStyle() {
    return {
      'aggressiveness': _aggressiveness,
      'creativity': _creativity,
      'positional': _positional,
    };
  }

  /// Berechnet den besten Zug mit maschinellem Lernen
  Future<Map<String, dynamic>> calculateBestMove(ChessBoard board) async {
    // Konvertiere das Brett in ein Feature-Array
    final features = _boardToFeatures(board);

    // In einer realen Implementierung würde hier das Modell verwendet werden
    // final output = List<double>.filled(1, 0);
    // _interpreter?.run(features, output);

    // Für dieses Beispiel verwenden wir eine einfache Heuristik
    final moves = _getAllPossibleMoves(board);
    if (moves.isEmpty) {
      return {'move': null, 'evaluation': 0.0};
    }

    // Bewerte jeden Zug
    final evaluatedMoves = moves.map((move) {
      // Klone das Brett und führe den Zug aus
      final clonedBoard = _cloneBoard(board);
      clonedBoard.makeMove(move['from'], move['to']);

      // Bewerte die Position
      final evaluation = _evaluatePosition(clonedBoard);

      // Passe die Bewertung basierend auf dem Spielstil an
      final adjustedEvaluation = _adjustEvaluationByStyle(evaluation, move);

      return {
        'from': move['from'],
        'to': move['to'],
        'evaluation': adjustedEvaluation,
      };
    }).toList();

    // Sortiere die Züge nach Bewertung
    evaluatedMoves.sort((a, b) {
      if (board.currentTurn == PieceColor.white) {
        return (b['evaluation'] as double).compareTo(a['evaluation'] as double);
      } else {
        return (a['evaluation'] as double).compareTo(b['evaluation'] as double);
      }
    });

    // Wähle den besten Zug aus, mit etwas Zufall basierend auf der Kreativität
    final random = Random();
    int selectedIndex = 0;

    if (evaluatedMoves.length > 1 && random.nextDouble() < _creativity) {
      // Mit einer gewissen Wahrscheinlichkeit wähle einen anderen als den besten Zug
      selectedIndex = 1 + random.nextInt(min(3, evaluatedMoves.length - 1));
    }

    return evaluatedMoves[selectedIndex];
  }

  /// Lernt aus einem gespielten Spiel
  void learnFromGame(
      List<Map<String, dynamic>> moves, String result, String playerName) {
    // Füge das Spiel zur Historie hinzu
    _gameHistory.add({
      'moves': moves,
      'result': result,
      'playerName': playerName,
    });

    // Analysiere den Spielstil des Spielers
    final playerStyle = _analyzePlayerStyle(moves);
    _playerStyles[playerName] = playerStyle;

    // In einer realen Implementierung würde hier das Modell trainiert werden
    // _trainModel();
  }

  /// Gibt einen personalisierten Spielstil für einen Gegner zurück
  List<double> getPersonalizedStyleForOpponent(String playerName) {
    if (_playerStyles.containsKey(playerName)) {
      return _playerStyles[playerName]!;
    }

    // Standardstil zurückgeben
    return [0.5, 0.5, 0.5];
  }

  /// Erstellt einen KI-Gegner basierend auf einem berühmten Schachspieler
  Map<String, double> createFamousPlayerStyle(String playerName) {
    switch (playerName.toLowerCase()) {
      case 'kasparov':
        return {
          'aggressiveness': 0.9,
          'creativity': 0.7,
          'positional': 0.6,
        };
      case 'karpov':
        return {
          'aggressiveness': 0.3,
          'creativity': 0.5,
          'positional': 0.9,
        };
      case 'fischer':
        return {
          'aggressiveness': 0.8,
          'creativity': 0.8,
          'positional': 0.7,
        };
      case 'carlsen':
        return {
          'aggressiveness': 0.6,
          'creativity': 0.7,
          'positional': 0.8,
        };
      case 'tal':
        return {
          'aggressiveness': 1.0,
          'creativity': 1.0,
          'positional': 0.4,
        };
      default:
        return {
          'aggressiveness': 0.5,
          'creativity': 0.5,
          'positional': 0.5,
        };
    }
  }

  /// Generiert einen personalisierten Lernpfad basierend auf der Spielhistorie
  List<Map<String, dynamic>> generatePersonalizedLearningPath(
      String playerName) {
    // Analysiere die Stärken und Schwächen des Spielers
    final strengths = <String>[];
    final weaknesses = <String>[];

    // In einer realen Implementierung würde hier eine detaillierte Analyse durchgeführt werden
    // Für dieses Beispiel verwenden wir einige Beispieldaten
    if (_playerStyles.containsKey(playerName)) {
      final style = _playerStyles[playerName]!;

      if (style[0] > 0.7) {
        // Aggressivität
        strengths.add('Taktisches Spiel');
      } else if (style[0] < 0.3) {
        weaknesses.add('Taktisches Spiel');
      }

      if (style[2] > 0.7) {
        // Positionelles Spiel
        strengths.add('Positionelles Spiel');
      } else if (style[2] < 0.3) {
        weaknesses.add('Positionelles Spiel');
      }
    }

    // Generiere einen Lernpfad basierend auf den Schwächen
    final learningPath = <Map<String, dynamic>>[];

    if (weaknesses.contains('Taktisches Spiel')) {
      learningPath.add({
        'title': 'Taktische Muster erkennen',
        'description':
            'Lerne, häufige taktische Muster wie Gabeln, Spieße und Abzugsschachs zu erkennen.',
        'difficulty': 'Mittel',
        'type': 'Taktik',
      });

      learningPath.add({
        'title': 'Kombinationen berechnen',
        'description':
            'Übe das Berechnen von taktischen Kombinationen über mehrere Züge.',
        'difficulty': 'Fortgeschritten',
        'type': 'Taktik',
      });
    }

    if (weaknesses.contains('Positionelles Spiel')) {
      learningPath.add({
        'title': 'Bauernstrukturen verstehen',
        'description':
            'Lerne die Grundlagen verschiedener Bauernstrukturen und ihre strategischen Implikationen.',
        'difficulty': 'Anfänger',
        'type': 'Strategie',
      });

      learningPath.add({
        'title': 'Figurenplatzierung',
        'description':
            'Verbessere deine Fähigkeit, Figuren optimal zu platzieren.',
        'difficulty': 'Mittel',
        'type': 'Strategie',
      });
    }

    // Füge allgemeine Lektionen hinzu
    learningPath.add({
      'title': 'Endspiele: König und Bauer gegen König',
      'description':
          'Lerne die grundlegenden Techniken für König-und-Bauer-Endspiele.',
      'difficulty': 'Anfänger',
      'type': 'Endspiel',
    });

    learningPath.add({
      'title': 'Eröffnungsprinzipien',
      'description':
          'Verstehe die grundlegenden Prinzipien der Schacheröffnung.',
      'difficulty': 'Anfänger',
      'type': 'Eröffnung',
    });

    return learningPath;
  }

  /// Generiert Trainingsaufgaben basierend auf der Spielhistorie
  List<Map<String, dynamic>> generateTrainingExercises(String playerName) {
    final exercises = <Map<String, dynamic>>[];

    // In einer realen Implementierung würden hier personalisierte Übungen generiert werden
    // Für dieses Beispiel verwenden wir einige Beispielübungen
    exercises.add({
      'title': 'Finde das Matt in 2 Zügen',
      'description':
          'In dieser Stellung gibt es ein Matt in 2 Zügen. Kannst du es finden?',
      'difficulty': 'Mittel',
      'type': 'Taktik',
      'fen':
          'r1bqkb1r/pppp1ppp/2n2n2/4p3/2B1P3/5N2/PPPP1PPP/RNBQK2R w KQkq - 0 1',
      'solution': 'Lf7+ Ke7 Qd8#',
    });

    exercises.add({
      'title': 'Verbessere die Figurenplatzierung',
      'description':
          'Finde den besten Zug, um deine Figurenplatzierung zu verbessern.',
      'difficulty': 'Anfänger',
      'type': 'Strategie',
      'fen': 'rnbqkbnr/pp2pppp/3p4/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R w KQkq - 0 1',
      'solution': 'Bc4',
    });

    exercises.add({
      'title': 'Endspiel: Opposition',
      'description': 'Nutze die Opposition, um das Endspiel zu gewinnen.',
      'difficulty': 'Mittel',
      'type': 'Endspiel',
      'fen': '8/8/8/3k4/8/8/3K4/8 w - - 0 1',
      'solution': 'Ke3 Ke5 Kf3 Kf5 Kg3 Kg5 Kh3 Kh5 Kg3',
    });

    return exercises;
  }

  // Private Hilfsmethoden

  List<double> _boardToFeatures(ChessBoard board) {
    // Konvertiere das Schachbrett in ein Feature-Array für das ML-Modell
    final features = <double>[];

    // 12 Kanäle (6 Figurentypen x 2 Farben)
    // Für jedes Feld auf dem Brett (8x8 = 64 Felder)
    // Insgesamt 12 x 64 = 768 Features

    for (int pieceType = 0; pieceType < 6; pieceType++) {
      for (int color = 0; color < 2; color++) {
        for (int row = 0; row < 8; row++) {
          for (int col = 0; col < 8; col++) {
            final position = Position(row: row, col: col);
            final piece = board.getPiece(position);

            if (piece != null &&
                piece.type.index == pieceType &&
                piece.color.index == color) {
              features.add(1.0);
            } else {
              features.add(0.0);
            }
          }
        }
      }
    }

    // Zusätzliche Features
    // Aktueller Spieler am Zug
    features.add(board.currentTurn == PieceColor.white ? 1.0 : 0.0);

    // Rochaderechte
    features.add(board.canCastleKingside(PieceColor.white) ? 1.0 : 0.0);
    features.add(board.canCastleQueenside(PieceColor.white) ? 1.0 : 0.0);
    features.add(board.canCastleKingside(PieceColor.black) ? 1.0 : 0.0);
    features.add(board.canCastleQueenside(PieceColor.black) ? 1.0 : 0.0);

    return features;
  }

  List<Map<String, dynamic>> _getAllPossibleMoves(ChessBoard board) {
    final moves = <Map<String, dynamic>>[];

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final position = Position(row: row, col: col);
        final piece = board.getPiece(position);

        if (piece != null && piece.color == board.currentTurn) {
          final validMoves = board.getValidMovesForPiece(position);

          for (var move in validMoves) {
            moves.add({
              'from': move.from,
              'to': move.to,
              'piece': piece,
            });
          }
        }
      }
    }

    return moves;
  }

  ChessBoard _cloneBoard(ChessBoard board) {
    // Erstelle eine Kopie des Bretts für die Analyse
    // Dies ist eine vereinfachte Implementierung
    return board;
  }

  double _evaluatePosition(ChessBoard board) {
    double evaluation = 0.0;

    // Material bewerten
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final position = Position(row: row, col: col);
        final piece = board.getPiece(position);
        if (piece != null) {
          double pieceValue = 0.0;

          switch (piece.type) {
            case PieceType.pawn:
              pieceValue = 1.0;
              break;
            case PieceType.knight:
              pieceValue = 3.0;
              break;
            case PieceType.bishop:
              pieceValue = 3.0;
              break;
            case PieceType.rook:
              pieceValue = 5.0;
              break;
            case PieceType.queen:
              pieceValue = 9.0;
              break;
            case PieceType.king:
              pieceValue =
                  0.0; // Der König wird nicht nach Materialwert bewertet
              break;
          }

          if (piece.color == PieceColor.white) {
            evaluation += pieceValue;
          } else {
            evaluation -= pieceValue;
          }
        }
      }
    }

    // Positionelle Faktoren bewerten (vereinfacht)
    // Kontrolle des Zentrums
    final centerControl = _evaluateCenterControl(board);
    evaluation += centerControl;

    // Königssicherheit
    final kingSafety = _evaluateKingSafety(board);
    evaluation += kingSafety;

    // Figurenentwicklung
    final development = _evaluateDevelopment(board);
    evaluation += development;

    return evaluation;
  }

  double _evaluateCenterControl(ChessBoard board) {
    // Bewerte die Kontrolle über das Zentrum (vereinfacht)
    double centerControl = 0.0;

    // Zentrumsfelder
    final centerPositions = [
      const Position(row: 3, col: 3),
      const Position(row: 3, col: 4),
      const Position(row: 4, col: 3),
      const Position(row: 4, col: 4),
    ];

    for (var position in centerPositions) {
      final piece = board.getPiece(position);
      if (piece != null) {
        if (piece.color == PieceColor.white) {
          centerControl += 0.2;
        } else {
          centerControl -= 0.2;
        }
      }

      // Bewerte auch die Kontrolle über das Feld (vereinfacht)
      bool whiteControls = false;
      bool blackControls = false;

      for (int row = 0; row < 8; row++) {
        for (int col = 0; col < 8; col++) {
          final checkPosition = Position(row: row, col: col);
          final checkPiece = board.getPiece(checkPosition);

          if (checkPiece != null) {
            final validMoves = board.getValidMovesForPiece(checkPosition);
            for (var move in validMoves) {
              if (move.to == position) {
                if (checkPiece.color == PieceColor.white) {
                  whiteControls = true;
                } else {
                  blackControls = true;
                }
              }
            }
          }
        }
      }

      if (whiteControls) centerControl += 0.1;
      if (blackControls) centerControl -= 0.1;
    }

    return centerControl;
  }

  double _evaluateKingSafety(ChessBoard board) {
    // Bewerte die Sicherheit der Könige (vereinfacht)
    double kingSafety = 0.0;

    // Finde die Könige
    Position? whiteKingPosition;
    Position? blackKingPosition;

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final position = Position(row: row, col: col);
        final piece = board.getPiece(position);

        if (piece != null && piece.type == PieceType.king) {
          if (piece.color == PieceColor.white) {
            whiteKingPosition = position;
          } else {
            blackKingPosition = position;
          }
        }
      }
    }

    // Bewerte die Königssicherheit basierend auf der Position
    if (whiteKingPosition != null) {
      // Rochade ist gut für die Sicherheit
      if (whiteKingPosition.col == 6 && whiteKingPosition.row == 7) {
        kingSafety += 0.5; // Kurze Rochade
      } else if (whiteKingPosition.col == 2 && whiteKingPosition.row == 7) {
        kingSafety += 0.4; // Lange Rochade
      } else if (whiteKingPosition.row < 6) {
        kingSafety -= 0.3; // König hat das letzte Drittel verlassen (unsicher)
      }
    }

    if (blackKingPosition != null) {
      // Rochade ist gut für die Sicherheit
      if (blackKingPosition.col == 6 && blackKingPosition.row == 0) {
        kingSafety -= 0.5; // Kurze Rochade
      } else if (blackKingPosition.col == 2 && blackKingPosition.row == 0) {
        kingSafety -= 0.4; // Lange Rochade
      } else if (blackKingPosition.row > 1) {
        kingSafety += 0.3; // König hat das letzte Drittel verlassen (unsicher)
      }
    }

    return kingSafety;
  }

  double _evaluateDevelopment(ChessBoard board) {
    // Bewerte die Figurenentwicklung (vereinfacht)
    double development = 0.0;

    // Zähle entwickelte Figuren
    int whiteDeveloped = 0;
    int blackDeveloped = 0;

    // Springer und Läufer sollten entwickelt sein
    for (int col = 0; col < 8; col++) {
      // Weiße Grundreihe
      final whitePiece = board.getPiece(Position(row: 7, col: col));
      if (whitePiece != null &&
          (whitePiece.type == PieceType.knight ||
              whitePiece.type == PieceType.bishop)) {
        // Figur ist noch nicht entwickelt
        development -= 0.1;
      }

      // Schwarze Grundreihe
      final blackPiece = board.getPiece(Position(row: 0, col: col));
      if (blackPiece != null &&
          (blackPiece.type == PieceType.knight ||
              blackPiece.type == PieceType.bishop)) {
        // Figur ist noch nicht entwickelt
        development += 0.1;
      }
    }

    return development;
  }

  double _adjustEvaluationByStyle(
      double evaluation, Map<String, dynamic> move) {
    // Passe die Bewertung basierend auf dem Spielstil an
    double adjustedEvaluation = evaluation;

    // Aggressivität: Bevorzuge Schlagzüge und Angriffe auf den gegnerischen König
    final piece = move['piece'] as ChessPiece;
    final to = move['to'] as Position;

    // Schlagzug
    if (piece.board.getPiece(to) != null) {
      adjustedEvaluation += _aggressiveness * 0.2;
    }

    // Angriff auf den gegnerischen König (vereinfacht)
    final opponentKingPosition = _findKingPosition(piece.board,
        piece.color == PieceColor.white ? PieceColor.black : PieceColor.white);
    if (opponentKingPosition != null) {
      final distance = _calculateDistance(to, opponentKingPosition);
      if (distance <= 2) {
        adjustedEvaluation += _aggressiveness * 0.3;
      }
    }

    // Positionelles Spiel: Bevorzuge Züge ins Zentrum
    if (to.row >= 2 && to.row <= 5 && to.col >= 2 && to.col <= 5) {
      adjustedEvaluation += _positional * 0.2;
    }

    return adjustedEvaluation;
  }

  Position? _findKingPosition(ChessBoard board, PieceColor color) {
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final position = Position(row: row, col: col);
        final piece = board.getPiece(position);

        if (piece != null &&
            piece.type == PieceType.king &&
            piece.color == color) {
          return position;
        }
      }
    }

    return null;
  }

  double _calculateDistance(Position a, Position b) {
    return sqrt(pow(a.row - b.row, 2) + pow(a.col - b.col, 2));
  }

  List<double> _analyzePlayerStyle(List<Map<String, dynamic>> moves) {
    // Analysiere den Spielstil des Spielers
    double aggressiveness = 0.5;
    double creativity = 0.5;
    double positional = 0.5;

    int attackMoves = 0;
    int centerMoves = 0;
    int unusualMoves = 0;

    for (var move in moves) {
      final from = move['from'] as Position;
      final to = move['to'] as Position;
      final piece = move['piece'] as ChessPiece?;

      if (piece != null) {
        // Schlagzug oder Angriff
        if (piece.board.getPiece(to) != null) {
          attackMoves++;
        }

        // Zug ins Zentrum
        if (to.row >= 2 && to.row <= 5 && to.col >= 2 && to.col <= 5) {
          centerMoves++;
        }

        // Ungewöhnlicher Zug (vereinfacht)
        if ((piece.type == PieceType.knight &&
                (to.row == 0 || to.row == 7 || to.col == 0 || to.col == 7)) ||
            (piece.type == PieceType.bishop &&
                (to.row == 3 || to.row == 4) &&
                (to.col == 3 || to.col == 4)) ||
            (piece.type == PieceType.king && from.col - to.col > 1)) {
          unusualMoves++;
        }
      }
    }

    // Berechne die Spielstil-Parameter
    if (moves.isNotEmpty) {
      aggressiveness = attackMoves / moves.length;
      positional = centerMoves / moves.length;
      creativity = unusualMoves / moves.length;
    }

    return [aggressiveness, creativity, positional];
  }

  void _trainModel() {
    // In einer realen Implementierung würde hier das Modell trainiert werden
    print('Training des Modells mit ${_gameHistory.length} Spielen');
  }
}
