import '../models/chess_board.dart';
import '../models/chess_piece.dart';
import '../models/position.dart';
import '../services/antichess_service.dart';

class AntichessBoard extends ChessBoard {
  // Service für die Antichess-spezifische Logik
  final AntichessService _antichessService = AntichessService();
  
  // Speichert den Gewinner (in Antichess gewinnt man, wenn man alle Figuren verliert)
  PieceColor? _winner;
  
  AntichessBoard({String? initialFen}) : super(initialFen: initialFen);

  // Erstellt ein Antichess-Brett aus einer FEN-Notation
  factory AntichessBoard.fromFen(String fen) {
    return AntichessBoard(initialFen: fen);
  }

  @override
  PieceColor? get winner => _winner;

  @override
  List<Move> getValidMovesForPiece(Position position) {
    final piece = getPiece(position);
    if (piece == null || piece.color != _currentTurn) return [];
    
    // Verwende den AntichessService, um die gültigen Züge zu ermitteln
    List<Move> moves = _antichessService.getValidMovesForPiece(_board, position);
    
    // Überprüfe, ob Schlagzwang besteht
    if (_antichessService.mustCapture(_board, _currentTurn)) {
      // Filtere die Züge, um nur Schlagzüge zu behalten
      moves = moves.where((move) => _board[move.to.row][move.to.col] != null).toList();
    }
    
    return moves;
  }

  @override
  bool makeMove(Move move) {
    final piece = getPiece(move.from);
    if (piece == null) return false;
    
    // Überprüfe, ob der Zug gültig ist
    final validMoves = getValidMovesForPiece(move.from);
    if (!validMoves.any((m) => m.from == move.from && m.to == move.to)) {
      return false;
    }
    
    // Führe den Zug aus
    final targetPiece = _board[move.to.row][move.to.col];
    _board[move.to.row][move.to.col] = piece.copyWith(hasMoved: true);
    _board[move.from.row][move.from.col] = null;
    
    // Bauernumwandlung
    if (piece.type == PieceType.pawn) {
      if ((piece.color == PieceColor.white && move.to.row == 0) ||
          (piece.color == PieceColor.black && move.to.row == 7)) {
        // In Antichess wandelt man Bauern normalerweise in Könige um, da diese am leichtesten zu verlieren sind
        // Aber wir verwenden hier Damen, um die bestehende Logik zu nutzen
        _board[move.to.row][move.to.col] = piece.copyWith(
          type: move.promotion ?? PieceType.queen,
          hasMoved: true,
        );
      }
    }
    
    // Wechsle den Spieler
    _currentTurn = _currentTurn == PieceColor.white ? PieceColor.black : PieceColor.white;
    
    // Füge den Zug zur Historie hinzu
    _moveHistory.add(move);
    
    // In Antichess gibt es kein Schach
    _isCheck = false;
    
    // Überprüfe, ob das Spiel beendet ist
    _checkGameOver();
    
    return true;
  }

  @override
  void _checkGameOver() {
    // Überprüfe, ob das Spiel beendet ist
    if (_antichessService.isGameOver(_board, _currentTurn)) {
      _gameOver = true;
      
      // In Antichess gewinnt der Spieler, der alle seine Figuren verloren hat
      // oder keinen gültigen Zug mehr machen kann
      _winner = _currentTurn == PieceColor.white ? PieceColor.black : PieceColor.white;
    }
  }

  @override
  bool hasValidMove(PieceColor color) {
    // Überprüfe, ob der Spieler noch Figuren hat
    bool hasOwnPieces = false;
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = _board[row][col];
        if (piece != null && piece.color == color) {
          hasOwnPieces = true;
          
          // Überprüfe, ob die Figur einen gültigen Zug hat
          final position = Position(row: row, col: col);
          final moves = getValidMovesForPiece(position);
          if (moves.isNotEmpty) {
            return true;
          }
        }
      }
    }
    
    // Wenn der Spieler keine Figuren mehr hat, hat er gewonnen (in Antichess)
    return hasOwnPieces;
  }

  @override
  bool isKingInCheck(PieceColor color) {
    // In Antichess gibt es kein Schach
    return false;
  }
}
