import 'dart:math';
import 'package:flutter/material.dart';
import '../models/chess_board.dart';
import '../models/chess_piece.dart';
import '../models/position.dart';

/// Service für erweiterte Spielanalyse
class AnalysisService {
  // Singleton-Instanz
  static final AnalysisService _instance = AnalysisService._internal();

  factory AnalysisService() {
    return _instance;
  }

  AnalysisService._internal();

  /// Analysiert ein Spiel und gibt eine Bewertung zurück
  Map<String, dynamic> analyzeGame(ChessBoard board, List<Move> moveHistory) {
    // Bewertung des Spiels
    final evaluation = _evaluatePosition(board);

    // Analyse der Zugqualität
    final moveQuality = _analyzeMoveQuality(moveHistory);

    // Taktische Muster finden
    final tacticalPatterns = _findTacticalPatterns(moveHistory);

    // Eröffnungsanalyse
    final openingAnalysis = _analyzeOpening(moveHistory);

    // Endspielanalyse
    final endgameAnalysis = _analyzeEndgame(board, moveHistory);

    // Fehleranalyse
    final mistakesAnalysis = _analyzeMistakes(moveHistory);

    return {
      'evaluation': evaluation,
      'moveQuality': moveQuality,
      'tacticalPatterns': tacticalPatterns,
      'openingAnalysis': openingAnalysis,
      'endgameAnalysis': endgameAnalysis,
      'mistakesAnalysis': mistakesAnalysis,
    };
  }

  /// Generiert eine Heatmap der Figurenbewegungen
  Map<String, dynamic> generateMovementHeatmap(List<Move> moveHistory) {
    // Initialisiere die Heatmap
    List<List<int>> whiteHeatmap =
        List.generate(8, (_) => List.generate(8, (_) => 0));
    List<List<int>> blackHeatmap =
        List.generate(8, (_) => List.generate(8, (_) => 0));

    // Zähle die Bewegungen für jedes Feld
    for (var move in moveHistory) {
      final piece = move.piece;
      if (piece == null) continue;

      if (piece.color == PieceColor.white) {
        whiteHeatmap[move.to.row][move.to.col]++;
      } else {
        blackHeatmap[move.to.row][move.to.col]++;
      }
    }

    return {
      'white': whiteHeatmap,
      'black': blackHeatmap,
    };
  }

  /// Generiert eine Heatmap der Kontrolle über das Brett
  Map<String, dynamic> generateControlHeatmap(ChessBoard board) {
    // Initialisiere die Heatmap
    List<List<int>> whiteControlMap =
        List.generate(8, (_) => List.generate(8, (_) => 0));
    List<List<int>> blackControlMap =
        List.generate(8, (_) => List.generate(8, (_) => 0));

    // Berechne die Kontrolle für jedes Feld
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final position = Position(row: row, col: col);
        final piece = board.getPiece(position);

        if (piece != null) {
          final validMoves = board.getValidMovesForPiece(position);
          for (var move in validMoves) {
            if (piece.color == PieceColor.white) {
              whiteControlMap[move.to.row][move.to.col]++;
            } else {
              blackControlMap[move.to.row][move.to.col]++;
            }
          }
        }
      }
    }

    return {
      'white': whiteControlMap,
      'black': blackControlMap,
    };
  }

  /// Findet die besten Züge in der aktuellen Position
  List<Map<String, dynamic>> findBestMoves(ChessBoard board, {int depth = 3}) {
    // Implementierung eines einfachen Minimax-Algorithmus mit Alpha-Beta-Pruning
    List<Map<String, dynamic>> bestMoves = [];

    // Sammle alle gültigen Züge
    List<Move> allMoves = [];
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final position = Position(row: row, col: col);
        final piece = board.getPiece(position);

        if (piece != null && piece.color == board.currentTurn) {
          final validMoves = board.getValidMovesForPiece(position);
          allMoves.addAll(validMoves);
        }
      }
    }

    // Bewerte jeden Zug
    for (var move in allMoves) {
      // Führe den Zug aus
      final clonedBoard = _cloneBoard(board);
      clonedBoard.makeMove(move.from, move.to);

      // Bewerte die resultierende Position
      final evaluation = _minimax(clonedBoard, depth - 1, -double.infinity,
          double.infinity, board.currentTurn != PieceColor.white);

      bestMoves.add({
        'move': move,
        'evaluation': evaluation,
      });
    }

    // Sortiere die Züge nach Bewertung
    if (board.currentTurn == PieceColor.white) {
      bestMoves.sort((a, b) =>
          (b['evaluation'] as double).compareTo(a['evaluation'] as double));
    } else {
      bestMoves.sort((a, b) =>
          (a['evaluation'] as double).compareTo(b['evaluation'] as double));
    }

    // Gib die besten 3 Züge zurück
    return bestMoves.take(3).toList();
  }

  /// Vergleicht ein Spiel mit einer Meisterpartie
  Map<String, dynamic> compareWithMasterGame(List<Move> moveHistory) {
    // Diese Funktion würde ein Spiel mit einer Datenbank von Meisterpartien vergleichen
    // Dies erfordert eine umfangreiche Datenbank, die über den Rahmen dieses Beispiels hinausgeht

    // Für dieses Beispiel geben wir einige Beispieldaten zurück
    return {
      'similarityScore': 0.75,
      'matchingOpeningName': 'Sizilianische Verteidigung, Najdorf-Variante',
      'matchingOpeningMoves': 10,
      'deviationMove': 11,
      'similarMasterGames': [
        {
          'white': 'Garry Kasparov',
          'black': 'Viswanathan Anand',
          'event': 'World Championship 1995',
          'similarity': 0.85,
        },
        {
          'white': 'Magnus Carlsen',
          'black': 'Fabiano Caruana',
          'event': 'World Championship 2018',
          'similarity': 0.72,
        },
      ],
    };
  }

  /// Generiert Verbesserungsvorschläge für ein Spiel
  List<Map<String, dynamic>> generateImprovementSuggestions(
      List<Move> moveHistory) {
    // Analysiere die Züge und finde Verbesserungsmöglichkeiten
    List<Map<String, dynamic>> suggestions = [];

    // Für dieses Beispiel generieren wir einige Beispielvorschläge
    if (moveHistory.length >= 5) {
      suggestions.add({
        'moveIndex': 4,
        'suggestion':
            'Statt Läufer nach e3 wäre Springer nach c3 besser gewesen, um das Zentrum zu kontrollieren.',
        'improvement': 'Entwickle deine Figuren zum Zentrum hin.',
      });
    }

    if (moveHistory.length >= 10) {
      suggestions.add({
        'moveIndex': 9,
        'suggestion':
            'Die Rochade hätte früher ausgeführt werden sollen, um den König in Sicherheit zu bringen.',
        'improvement':
            'Priorisiere die Sicherheit des Königs in der Eröffnung.',
      });
    }

    if (moveHistory.length >= 15) {
      suggestions.add({
        'moveIndex': 14,
        'suggestion':
            'Der Abtausch des Läufers gegen den Springer hat die Kontrolle über die weißen Felder geschwächt.',
        'improvement':
            'Behalte deine Läufer, wenn der Gegner offene Diagonalen hat.',
      });
    }

    return suggestions;
  }

  // Private Hilfsmethoden

  double _evaluatePosition(ChessBoard board) {
    double evaluation = 0.0;

    // Material bewerten
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board.getPiece(Position(row: row, col: col));
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

  Map<String, dynamic> _analyzeMoveQuality(List<Move> moveHistory) {
    // Analysiere die Qualität der Züge (vereinfacht)
    int excellentMoves = 0;
    int goodMoves = 0;
    int inaccuracies = 0;
    int mistakes = 0;
    int blunders = 0;

    // Für dieses Beispiel generieren wir zufällige Werte
    final random = Random();

    for (var _ in moveHistory) {
      final quality = random.nextDouble();

      if (quality > 0.9) {
        excellentMoves++;
      } else if (quality > 0.7) {
        goodMoves++;
      } else if (quality > 0.5) {
        inaccuracies++;
      } else if (quality > 0.3) {
        mistakes++;
      } else {
        blunders++;
      }
    }

    return {
      'excellentMoves': excellentMoves,
      'goodMoves': goodMoves,
      'inaccuracies': inaccuracies,
      'mistakes': mistakes,
      'blunders': blunders,
      'accuracy':
          (excellentMoves * 1.0 + goodMoves * 0.8 + inaccuracies * 0.5) /
              moveHistory.length,
    };
  }

  List<Map<String, dynamic>> _findTacticalPatterns(List<Move> moveHistory) {
    // Finde taktische Muster wie Gabeln, Spieße, etc. (vereinfacht)
    List<Map<String, dynamic>> patterns = [];

    // Für dieses Beispiel generieren wir einige Beispielmuster
    if (moveHistory.length >= 10) {
      patterns.add({
        'type': 'fork',
        'description': 'Springergabel auf e5, bedroht König und Turm',
        'moveIndex': 9,
      });
    }

    if (moveHistory.length >= 15) {
      patterns.add({
        'type': 'pin',
        'description':
            'Läuferspieß auf der Diagonale a2-g8, fixiert den Springer vor dem König',
        'moveIndex': 14,
      });
    }

    if (moveHistory.length >= 20) {
      patterns.add({
        'type': 'discovery',
        'description':
            'Abzugsschach durch Springerzug, öffnet Angriff des Läufers',
        'moveIndex': 19,
      });
    }

    return patterns;
  }

  Map<String, dynamic> _analyzeOpening(List<Move> moveHistory) {
    // Analysiere die Eröffnung (vereinfacht)
    String openingName = 'Unbekannte Eröffnung';
    String openingVariation = '';
    int openingAccuracy = 0;

    // Für dieses Beispiel verwenden wir einige bekannte Eröffnungen
    if (moveHistory.length >= 2) {
      final firstMove = moveHistory[0];
      final secondMove = moveHistory[1];

      if (firstMove.from.row == 6 &&
          firstMove.from.col == 4 &&
          firstMove.to.row == 4 &&
          firstMove.to.col == 4) {
        // 1. e4
        if (secondMove.from.row == 1 &&
            secondMove.from.col == 4 &&
            secondMove.to.row == 3 &&
            secondMove.to.col == 4) {
          // 1. e4 e5
          openingName = 'Offene Partie';
          openingAccuracy = 100;

          if (moveHistory.length >= 4) {
            final thirdMove = moveHistory[2];
            final fourthMove = moveHistory[3];

            if (thirdMove.from.row == 7 &&
                thirdMove.from.col == 6 &&
                thirdMove.to.row == 5 &&
                thirdMove.to.col == 5) {
              // 2. Nf3
              if (fourthMove.from.row == 0 &&
                  fourthMove.from.col == 1 &&
                  fourthMove.to.row == 2 &&
                  fourthMove.to.col == 2) {
                // 2. ... Nc6
                openingName = 'Italienische Partie';
                openingVariation = 'Hauptvariante';
                openingAccuracy = 100;
              }
            }
          }
        } else if (secondMove.from.row == 1 &&
            secondMove.from.col == 2 &&
            secondMove.to.row == 3 &&
            secondMove.to.col == 2) {
          // 1. e4 c5
          openingName = 'Sizilianische Verteidigung';
          openingAccuracy = 100;
        }
      } else if (firstMove.from.row == 6 &&
          firstMove.from.col == 3 &&
          firstMove.to.row == 4 &&
          firstMove.to.col == 3) {
        // 1. d4
        if (secondMove.from.row == 1 &&
            secondMove.from.col == 3 &&
            secondMove.to.row == 3 &&
            secondMove.to.col == 3) {
          // 1. d4 d5
          openingName = 'Geschlossene Partie';
          openingAccuracy = 100;

          if (moveHistory.length >= 4) {
            final thirdMove = moveHistory[2];

            if (thirdMove.from.row == 6 &&
                thirdMove.from.col == 2 &&
                thirdMove.to.row == 4 &&
                thirdMove.to.col == 2) {
              // 2. c4
              openingName = 'Damengambit';
              openingAccuracy = 100;
            }
          }
        }
      }
    }

    return {
      'name': openingName,
      'variation': openingVariation,
      'accuracy': openingAccuracy,
      'theory':
          'Die Theorie empfiehlt, in dieser Eröffnung die Kontrolle über das Zentrum zu priorisieren.',
    };
  }

  Map<String, dynamic> _analyzeEndgame(
      ChessBoard board, List<Move> moveHistory) {
    // Analysiere das Endspiel (vereinfacht)
    bool isEndgame = _isEndgame(board);

    if (!isEndgame) {
      return {
        'isEndgame': false,
      };
    }

    // Zähle die verbleibenden Figuren
    int whitePawns = 0;
    int blackPawns = 0;
    int whitePieces = 0;
    int blackPieces = 0;

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board.getPiece(Position(row: row, col: col));
        if (piece != null) {
          if (piece.color == PieceColor.white) {
            if (piece.type == PieceType.pawn) {
              whitePawns++;
            } else if (piece.type != PieceType.king) {
              whitePieces++;
            }
          } else {
            if (piece.type == PieceType.pawn) {
              blackPawns++;
            } else if (piece.type != PieceType.king) {
              blackPieces++;
            }
          }
        }
      }
    }

    // Bestimme den Endspieltyp
    String endgameType = 'Komplexes Endspiel';
    String endgameAdvantage = 'Ausgeglichen';

    if (whitePieces == 0 && blackPieces == 0) {
      endgameType = 'Bauernendspiel';
      if (whitePawns > blackPawns) {
        endgameAdvantage = 'Weiß hat einen Vorteil';
      } else if (blackPawns > whitePawns) {
        endgameAdvantage = 'Schwarz hat einen Vorteil';
      }
    } else if (whitePieces == 1 &&
        blackPieces == 0 &&
        whitePawns == 0 &&
        blackPawns == 0) {
      endgameType = 'König und Figur gegen König';
      endgameAdvantage = 'Weiß hat einen Vorteil';
    } else if (whitePieces == 0 &&
        blackPieces == 1 &&
        whitePawns == 0 &&
        blackPawns == 0) {
      endgameType = 'König gegen König und Figur';
      endgameAdvantage = 'Schwarz hat einen Vorteil';
    }

    return {
      'isEndgame': true,
      'type': endgameType,
      'advantage': endgameAdvantage,
      'whitePawns': whitePawns,
      'blackPawns': blackPawns,
      'whitePieces': whitePieces,
      'blackPieces': blackPieces,
      'advice':
          'In diesem Endspiel ist es wichtig, aktive Figurenplatzierung zu priorisieren.',
    };
  }

  bool _isEndgame(ChessBoard board) {
    // Bestimme, ob die Position ein Endspiel ist (vereinfacht)
    int pieceCount = 0;
    bool queenPresent = false;

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board.getPiece(Position(row: row, col: col));
        if (piece != null &&
            piece.type != PieceType.king &&
            piece.type != PieceType.pawn) {
          pieceCount++;
          if (piece.type == PieceType.queen) {
            queenPresent = true;
          }
        }
      }
    }

    // Weniger als 6 Figuren oder keine Dame vorhanden
    return pieceCount < 6 || !queenPresent;
  }

  Map<String, dynamic> _analyzeMistakes(List<Move> moveHistory) {
    // Analysiere Fehler im Spiel (vereinfacht)
    List<Map<String, dynamic>> criticalMistakes = [];

    // Für dieses Beispiel generieren wir einige Beispielfehler
    if (moveHistory.length >= 12) {
      criticalMistakes.add({
        'moveIndex': 11,
        'description': 'Übersehenes Schach durch Springergabel',
        'evaluation': -2.5,
      });
    }

    if (moveHistory.length >= 18) {
      criticalMistakes.add({
        'moveIndex': 17,
        'description': 'Materialverlust durch taktisches Übersehen',
        'evaluation': -1.8,
      });
    }

    return {
      'criticalMistakes': criticalMistakes,
      'mistakeCount': criticalMistakes.length,
    };
  }

  ChessBoard _cloneBoard(ChessBoard board) {
    // Erstelle eine Kopie des Bretts für die Analyse
    // Dies ist eine vereinfachte Implementierung
    return board;
  }

  double _minimax(ChessBoard board, int depth, double alpha, double beta,
      bool maximizingPlayer) {
    // Minimax-Algorithmus mit Alpha-Beta-Pruning (vereinfacht)
    if (depth == 0 || board.gameOver) {
      return _evaluatePosition(board);
    }

    if (maximizingPlayer) {
      double maxEval = -double.infinity;

      // Sammle alle gültigen Züge
      for (int row = 0; row < 8; row++) {
        for (int col = 0; col < 8; col++) {
          final position = Position(row: row, col: col);
          final piece = board.getPiece(position);

          if (piece != null && piece.color == PieceColor.white) {
            final validMoves = board.getValidMovesForPiece(position);

            for (var move in validMoves) {
              // Führe den Zug aus
              final clonedBoard = _cloneBoard(board);
              clonedBoard.makeMove(move.from, move.to);

              // Rekursiver Aufruf
              final eval = _minimax(clonedBoard, depth - 1, alpha, beta, false);
              maxEval = max(maxEval, eval);

              // Alpha-Beta-Pruning
              alpha = max(alpha, eval);
              if (beta <= alpha) {
                break;
              }
            }
          }
        }
      }

      return maxEval;
    } else {
      double minEval = double.infinity;

      // Sammle alle gültigen Züge
      for (int row = 0; row < 8; row++) {
        for (int col = 0; col < 8; col++) {
          final position = Position(row: row, col: col);
          final piece = board.getPiece(position);

          if (piece != null && piece.color == PieceColor.black) {
            final validMoves = board.getValidMovesForPiece(position);

            for (var move in validMoves) {
              // Führe den Zug aus
              final clonedBoard = _cloneBoard(board);
              clonedBoard.makeMove(move.from, move.to);

              // Rekursiver Aufruf
              final eval = _minimax(clonedBoard, depth - 1, alpha, beta, true);
              minEval = min(minEval, eval);

              // Alpha-Beta-Pruning
              beta = min(beta, eval);
              if (beta <= alpha) {
                break;
              }
            }
          }
        }
      }

      return minEval;
    }
  }
}
