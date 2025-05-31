import 'package:flutter/material.dart';
import '../models/chess_board.dart';
import '../models/chess_piece.dart';
import '../models/position.dart';

/// Provider für die Verwaltung des Spielzustands
class GameProvider extends ChangeNotifier {
  ChessBoard _board = ChessBoard();
  String _gameName = "Neue Partie";
  bool _isAIGame = false;
  String _difficulty = "Mittel";
  bool _isOnlineGame = false;
  String _timeControl = "Standard";
  
  // Getter
  ChessBoard get board => _board;
  String get gameName => _gameName;
  bool get isAIGame => _isAIGame;
  String get difficulty => _difficulty;
  bool get isOnlineGame => _isOnlineGame;
  String get timeControl => _timeControl;
  PieceColor get currentTurn => _board.currentTurn;
  bool get gameOver => _board.gameOver;
  PieceColor? get winner => _board.winner;
  List<Move> get moveHistory => _board.moveHistory;
  
  // Methoden zur Spielsteuerung
  
  /// Setzt das Spielbrett zurück und startet eine neue Partie
  void newGame() {
    _board = ChessBoard();
    notifyListeners();
  }
  
  /// Setzt den Namen der aktuellen Partie
  void setGameName(String name) {
    _gameName = name;
    notifyListeners();
  }
  
  /// Konfiguriert ein Spiel gegen die KI
  void setupAIGame(bool enabled, {String difficulty = "Mittel"}) {
    _isAIGame = enabled;
    _difficulty = difficulty;
    notifyListeners();
  }
  
  /// Konfiguriert ein Online-Spiel
  void setupOnlineGame(bool enabled) {
    _isOnlineGame = enabled;
    notifyListeners();
  }
  
  /// Setzt die Zeitkontrolle für die Partie
  void setTimeControl(String timeControl) {
    _timeControl = timeControl;
    notifyListeners();
  }
  
  /// Führt einen Zug aus
  bool makeMove(Move move) {
    final result = _board.makeMove(move);
    if (result) {
      notifyListeners();
    }
    return result;
  }
  
  /// Führt einen Zug von einer Position zu einer anderen aus
  bool movePiece(Position from, Position to) {
    final piece = _board.getPiece(from);
    if (piece == null) return false;
    
    // Überprüfe, ob der Zug gültig ist
    final validMoves = _board.getValidMovesForPiece(from);
    final targetMove = validMoves.firstWhere(
      (move) => move.from == from && move.to == to,
      orElse: () => Move(from: from, to: to), // Ungültiger Zug
    );
    
    return makeMove(targetMove);
  }
  
  /// Gibt alle gültigen Züge für eine Figur zurück
  List<Move> getValidMovesForPiece(Position position) {
    return _board.getValidMovesForPiece(position);
  }
  
  /// Gibt die Figur an einer bestimmten Position zurück
  ChessPiece? getPiece(Position position) {
    return _board.getPiece(position);
  }
  
  /// Überprüft, ob eine Position von einer Figur der gegnerischen Farbe angegriffen wird
  bool isPositionUnderAttack(Position position, PieceColor color) {
    return _board.isPositionUnderAttack(position, color);
  }
  
  /// Gibt zurück, ob der aktuelle Spieler im Schach steht
  bool isInCheck() {
    final kingPosition = currentTurn == PieceColor.white 
        ? _board.whiteKingPosition 
        : _board.blackKingPosition;
    
    if (kingPosition == null) return false;
    
    return _board.isPositionUnderAttack(kingPosition, currentTurn);
  }
}
