import '../models/chess_board.dart';
import '../models/chess_piece.dart';
import '../models/position.dart';
import '../services/racing_kings_service.dart';

class RacingKingsBoard extends ChessBoard {
  // Service für die Racing Kings-spezifische Logik
  final RacingKingsService _racingKingsService = RacingKingsService();
  
  RacingKingsBoard() {
    // Initialisiere das Brett mit der Racing Kings-Startposition
    _board = _racingKingsService.createInitialBoard();
    _currentTurn = PieceColor.white;
    _gameOver = false;
    _winner = null;
    _isCheck = false;
  }

  @override
  List<Move> getValidMovesForPiece(Position position) {
    final piece = getPiece(position);
    if (piece == null || piece.color != _currentTurn) {
      return [];
    }
    
    List<Move> moves = [];
    
    // Berechne die grundlegenden Züge basierend auf dem Figurentyp
    switch (piece.type) {
      case PieceType.pawn:
        // In Racing Kings gibt es keine Bauern
        break;
      case PieceType.knight:
        moves = _getKnightMoves(position);
        break;
      case PieceType.bishop:
        moves = _getBishopMoves(position);
        break;
      case PieceType.rook:
        moves = _getRookMoves(position);
        break;
      case PieceType.queen:
        moves = _getQueenMoves(position);
        break;
      case PieceType.king:
        moves = _getKingMoves(position);
        break;
    }
    
    // Filtere Züge, die einen König in Schach setzen würden
    moves = moves.where((move) => !_racingKingsService.wouldMoveResultInCheck(_board, move)).toList();
    
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
    _board[move.to.row][move.to.col] = piece;
    _board[move.from.row][move.from.col] = null;
    
    // Wechsle den Spieler
    _currentTurn = _currentTurn == PieceColor.white ? PieceColor.black : PieceColor.white;
    
    // Überprüfe, ob das Spiel beendet ist
    _checkGameOver();
    
    return true;
  }

  @override
  void _checkGameOver() {
    // Überprüfe, ob das Spiel beendet ist
    if (_racingKingsService.isGameOver(_board)) {
      _gameOver = true;
      _winner = _racingKingsService.getWinner(_board, _currentTurn);
    }
  }
  
  // Überprüft, ob ein König die letzte Reihe erreicht hat
  bool isKingOnLastRank(PieceColor color) {
    return _racingKingsService.isKingOnLastRank(_board, color);
  }
}
