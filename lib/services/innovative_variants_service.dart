import 'package:flutter/material.dart';
import '../models/chess_board.dart';
import '../models/chess_piece.dart';
import '../models/position.dart';
import 'dart:math';

/// Service für innovative Schachvarianten
class InnovativeVariantsService {
  // Singleton-Instanz
  static final InnovativeVariantsService _instance =
      InnovativeVariantsService._internal();

  factory InnovativeVariantsService() {
    return _instance;
  }

  InnovativeVariantsService._internal();

  /// Erstellt ein 4-Spieler-Schachbrett
  ChessBoard createFourPlayerBoard() {
    // In einer realen Implementierung würde hier ein spezielles 4-Spieler-Brett erstellt werden
    // Für dieses Beispiel verwenden wir ein normales Brett
    final board = ChessBoard();

    // Setze die Figuren für vier Spieler
    _setupFourPlayerPieces(board);

    return board;
  }

  /// Erstellt ein Fog of War Schachbrett
  ChessBoard createFogOfWarBoard() {
    final board = ChessBoard();

    // Setze die normalen Figuren
    board.resetBoard();

    // Markiere alle Felder als im Nebel
    _setupFogOfWar(board);

    return board;
  }

  /// Erstellt ein Progressive Schachbrett
  ChessBoard createProgressiveBoard() {
    final board = ChessBoard();

    // Setze die normalen Figuren
    board.resetBoard();

    // Setze die Anzahl der Züge pro Runde
    board.setProperty('movesPerTurn', 1);

    return board;
  }

  /// Erstellt ein Quantum Schachbrett
  ChessBoard createQuantumBoard() {
    final board = ChessBoard();

    // Setze die normalen Figuren
    board.resetBoard();

    // Initialisiere die Quantenzustände
    _setupQuantumStates(board);

    return board;
  }

  /// Aktualisiert die sichtbaren Felder im Fog of War Modus
  void updateFogOfWarVisibility(ChessBoard board, PieceColor currentPlayer) {
    // Markiere alle Felder als im Nebel
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final position = Position(row: row, col: col);
        board.setProperty('fog_${row}_$col', true);
      }
    }

    // Mache eigene Figuren und angrenzende Felder sichtbar
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final position = Position(row: row, col: col);
        final piece = board.getPiece(position);

        if (piece != null && piece.color == currentPlayer) {
          // Eigene Figur ist sichtbar
          board.setProperty('fog_${row}_$col', false);

          // Mache angrenzende Felder sichtbar
          _makeAdjacentFieldsVisible(board, position);

          // Mache Felder sichtbar, die von dieser Figur angegriffen werden
          final validMoves = board.getValidMovesForPiece(position);
          for (var move in validMoves) {
            final targetRow = move.to.row;
            final targetCol = move.to.col;
            board.setProperty('fog_${targetRow}_$targetCol', false);
          }
        }
      }
    }
  }

  /// Führt einen Zug im Progressive Schach aus
  bool makeProgressiveMove(ChessBoard board, Position from, Position to) {
    // Führe den Zug aus
    final success = board.makeMove(from, to);

    if (success) {
      // Erhöhe die Anzahl der Züge für die nächste Runde, wenn der Spieler wechselt
      final currentMovesPerTurn = board.getProperty('movesPerTurn') as int;
      final currentMoveCount =
          board.getProperty('currentMoveCount') as int? ?? 0;

      if (currentMoveCount + 1 >= currentMovesPerTurn) {
        // Spielerwechsel
        board.setProperty('currentMoveCount', 0);
        board.setProperty('movesPerTurn', currentMovesPerTurn + 1);
      } else {
        // Gleicher Spieler ist noch am Zug
        board.setProperty('currentMoveCount', currentMoveCount + 1);
        // Setze den Spieler zurück, da makeMove ihn gewechselt hat
        board.currentTurn = board.currentTurn == PieceColor.white
            ? PieceColor.black
            : PieceColor.white;
      }
    }

    return success;
  }

  /// Führt einen Zug im Quantum Schach aus
  bool makeQuantumMove(ChessBoard board, Position from, Position to) {
    // In einer realen Implementierung würde hier die Quantenmechanik simuliert werden
    // Für dieses Beispiel führen wir einen normalen Zug aus

    // Prüfe, ob die Figur in einem Überlagerungszustand ist
    final isInSuperposition =
        board.getProperty('quantum_${from.row}_${from.col}') as bool? ?? false;

    if (isInSuperposition) {
      // Bei einer Figur in Überlagerung gibt es eine Chance, dass der Zug fehlschlägt
      final random = Random();
      if (random.nextDouble() < 0.5) {
        // Der Zug schlägt fehl, die Überlagerung kollabiert
        board.setProperty('quantum_${from.row}_${from.col}', false);
        return false;
      }
    }

    // Führe den Zug aus
    final success = board.makeMove(from, to);

    if (success) {
      // Es besteht eine Chance, dass die Figur in einen Überlagerungszustand übergeht
      final random = Random();
      if (random.nextDouble() < 0.3) {
        board.setProperty('quantum_${to.row}_${to.col}', true);
      }
    }

    return success;
  }

  /// Gibt zurück, ob ein Feld im Fog of War sichtbar ist
  bool isFieldVisible(ChessBoard board, Position position) {
    return !(board.getProperty('fog_${position.row}_${position.col}')
            as bool? ??
        true);
  }

  /// Gibt zurück, ob eine Figur in einem Quantenüberlagerungszustand ist
  bool isInQuantumSuperposition(ChessBoard board, Position position) {
    return board.getProperty('quantum_${position.row}_${position.col}')
            as bool? ??
        false;
  }

  // Private Hilfsmethoden

  void _setupFourPlayerPieces(ChessBoard board) {
    // In einer realen Implementierung würde hier ein spezielles 4-Spieler-Brett mit
    // Figuren in allen vier Ecken erstellt werden

    // Für dieses Beispiel setzen wir einfach die normalen Figuren
    board.resetBoard();
  }

  void _setupFogOfWar(ChessBoard board) {
    // Markiere alle Felder als im Nebel
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        board.setProperty('fog_${row}_$col', true);
      }
    }
  }

  void _setupQuantumStates(ChessBoard board) {
    // Initialisiere alle Figuren als nicht in Überlagerung
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        board.setProperty('quantum_${row}_$col', false);
      }
    }
  }

  void _makeAdjacentFieldsVisible(ChessBoard board, Position position) {
    final row = position.row;
    final col = position.col;

    // Alle 8 angrenzenden Felder
    final adjacentPositions = [
      Position(row: row - 1, col: col - 1),
      Position(row: row - 1, col: col),
      Position(row: row - 1, col: col + 1),
      Position(row: row, col: col - 1),
      Position(row: row, col: col + 1),
      Position(row: row + 1, col: col - 1),
      Position(row: row + 1, col: col),
      Position(row: row + 1, col: col + 1),
    ];

    for (var pos in adjacentPositions) {
      if (pos.row >= 0 && pos.row < 8 && pos.col >= 0 && pos.col < 8) {
        board.setProperty('fog_${pos.row}_${pos.col}', false);
      }
    }
  }
}
