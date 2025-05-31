import '../models/chess_board.dart';
import '../models/chess_piece.dart';
import '../models/position.dart';

/// Klasse für die Verwaltung der Racing Kings-Variante
class RacingKingsService {
  // Singleton-Instanz
  static final RacingKingsService _instance = RacingKingsService._internal();
  
  factory RacingKingsService() {
    return _instance;
  }
  
  RacingKingsService._internal();
  
  /// Überprüft, ob ein König die letzte Reihe erreicht hat
  bool isKingOnLastRank(List<List<ChessPiece?>> board, PieceColor kingColor) {
    // Die letzte Reihe ist Reihe 0 (aus Sicht von Schwarz)
    const lastRank = 0;
    
    // Überprüfe, ob der König auf der letzten Reihe steht
    for (int col = 0; col < 8; col++) {
      final piece = board[lastRank][col];
      if (piece != null && piece.type == PieceType.king && piece.color == kingColor) {
        return true;
      }
    }
    
    return false;
  }
  
  /// Überprüft, ob das Spiel beendet ist (König auf der letzten Reihe)
  bool isGameOver(List<List<ChessPiece?>> board) {
    // Überprüfe, ob ein König die letzte Reihe erreicht hat
    if (isKingOnLastRank(board, PieceColor.white) || isKingOnLastRank(board, PieceColor.black)) {
      return true;
    }
    
    return false;
  }
  
  /// Ermittelt den Gewinner
  PieceColor? getWinner(List<List<ChessPiece?>> board, PieceColor currentTurn) {
    // Wenn der weiße König die letzte Reihe erreicht hat
    if (isKingOnLastRank(board, PieceColor.white)) {
      // Wenn der schwarze König auch die letzte Reihe erreicht hat, gewinnt der Spieler, der nicht am Zug ist
      if (isKingOnLastRank(board, PieceColor.black)) {
        return currentTurn == PieceColor.white ? PieceColor.black : PieceColor.white;
      }
      return PieceColor.white;
    }
    
    // Wenn nur der schwarze König die letzte Reihe erreicht hat
    if (isKingOnLastRank(board, PieceColor.black)) {
      return PieceColor.black;
    }
    
    // Kein Gewinner
    return null;
  }
  
  /// Erstellt die Startposition für Racing Kings
  List<List<ChessPiece?>> createInitialBoard() {
    // Erstelle ein leeres Brett
    List<List<ChessPiece?>> board = List.generate(
      8, (_) => List.generate(8, (_) => null)
    );
    
    // Setze die Figuren für Racing Kings
    // Weiße Figuren
    board[7][0] = ChessPiece(type: PieceType.rook, color: PieceColor.white);
    board[7][1] = ChessPiece(type: PieceType.knight, color: PieceColor.white);
    board[7][2] = ChessPiece(type: PieceType.bishop, color: PieceColor.white);
    board[7][3] = ChessPiece(type: PieceType.queen, color: PieceColor.white);
    board[7][4] = ChessPiece(type: PieceType.king, color: PieceColor.white);
    board[7][5] = ChessPiece(type: PieceType.bishop, color: PieceColor.white);
    board[7][6] = ChessPiece(type: PieceType.knight, color: PieceColor.white);
    board[7][7] = ChessPiece(type: PieceType.rook, color: PieceColor.white);
    
    // Schwarze Figuren
    board[6][0] = ChessPiece(type: PieceType.rook, color: PieceColor.black);
    board[6][1] = ChessPiece(type: PieceType.knight, color: PieceColor.black);
    board[6][2] = ChessPiece(type: PieceType.bishop, color: PieceColor.black);
    board[6][3] = ChessPiece(type: PieceType.queen, color: PieceColor.black);
    board[6][4] = ChessPiece(type: PieceType.king, color: PieceColor.black);
    board[6][5] = ChessPiece(type: PieceType.bishop, color: PieceColor.black);
    board[6][6] = ChessPiece(type: PieceType.knight, color: PieceColor.black);
    board[6][7] = ChessPiece(type: PieceType.rook, color: PieceColor.black);
    
    return board;
  }
  
  /// Überprüft, ob ein Zug einen König in Schach setzen würde
  bool wouldMoveResultInCheck(List<List<ChessPiece?>> board, Move move) {
    // Kopiere das Brett für die Simulation
    List<List<ChessPiece?>> tempBoard = List.generate(
      8, (row) => List.generate(8, (col) => board[row][col])
    );
    
    // Führe den Zug auf dem temporären Brett aus
    final piece = tempBoard[move.from.row][move.from.col];
    tempBoard[move.to.row][move.to.col] = piece;
    tempBoard[move.from.row][move.from.col] = null;
    
    // Überprüfe, ob ein König im Schach steht
    return isAnyKingInCheck(tempBoard);
  }
  
  /// Überprüft, ob ein König im Schach steht
  bool isAnyKingInCheck(List<List<ChessPiece?>> board) {
    // Finde die Positionen der Könige
    Position? whiteKingPosition;
    Position? blackKingPosition;
    
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece != null && piece.type == PieceType.king) {
          if (piece.color == PieceColor.white) {
            whiteKingPosition = Position(row: row, col: col);
          } else {
            blackKingPosition = Position(row: row, col: col);
          }
        }
      }
    }
    
    // Überprüfe, ob ein König im Schach steht
    if (whiteKingPosition != null && isKingInCheck(board, whiteKingPosition, PieceColor.white)) {
      return true;
    }
    
    if (blackKingPosition != null && isKingInCheck(board, blackKingPosition, PieceColor.black)) {
      return true;
    }
    
    return false;
  }
  
  /// Überprüft, ob ein König im Schach steht
  bool isKingInCheck(List<List<ChessPiece?>> board, Position kingPosition, PieceColor kingColor) {
    final opponentColor = kingColor == PieceColor.white ? PieceColor.black : PieceColor.white;
    
    // Überprüfe Bedrohungen durch Springer
    if (_isKnightThreatening(board, kingPosition, opponentColor)) return true;
    
    // Überprüfe Bedrohungen durch Läufer, Türme und Damen
    if (_isSlidingPieceThreatening(board, kingPosition, opponentColor)) return true;
    
    // Überprüfe Bedrohungen durch den gegnerischen König
    if (_isKingThreatening(board, kingPosition, opponentColor)) return true;
    
    return false;
  }
  
  // Private Hilfsmethoden zur Überprüfung von Bedrohungen
  
  bool _isKnightThreatening(List<List<ChessPiece?>> board, Position kingPosition, PieceColor opponentColor) {
    final offsets = [
      [-2, -1], [-2, 1], [-1, -2], [-1, 2],
      [1, -2], [1, 2], [2, -1], [2, 1]
    ];
    
    for (final offset in offsets) {
      final row = kingPosition.row + offset[0];
      final col = kingPosition.col + offset[1];
      
      if (_isValidPosition(row, col)) {
        final piece = board[row][col];
        if (piece != null && piece.type == PieceType.knight && piece.color == opponentColor) {
          return true;
        }
      }
    }
    
    return false;
  }
  
  bool _isSlidingPieceThreatening(List<List<ChessPiece?>> board, Position kingPosition, PieceColor opponentColor) {
    // Überprüfe Bedrohungen durch Läufer und Damen (diagonale Richtungen)
    final diagonalDirections = [[-1, -1], [-1, 1], [1, -1], [1, 1]];
    for (final direction in diagonalDirections) {
      int i = 1;
      while (true) {
        final row = kingPosition.row + i * direction[0];
        final col = kingPosition.col + i * direction[1];
        
        if (!_isValidPosition(row, col)) break;
        
        final piece = board[row][col];
        if (piece != null) {
          if (piece.color == opponentColor && 
              (piece.type == PieceType.bishop || piece.type == PieceType.queen)) {
            return true;
          }
          break;
        }
        
        i++;
      }
    }
    
    // Überprüfe Bedrohungen durch Türme und Damen (horizontale und vertikale Richtungen)
    final straightDirections = [[-1, 0], [0, -1], [0, 1], [1, 0]];
    for (final direction in straightDirections) {
      int i = 1;
      while (true) {
        final row = kingPosition.row + i * direction[0];
        final col = kingPosition.col + i * direction[1];
        
        if (!_isValidPosition(row, col)) break;
        
        final piece = board[row][col];
        if (piece != null) {
          if (piece.color == opponentColor && 
              (piece.type == PieceType.rook || piece.type == PieceType.queen)) {
            return true;
          }
          break;
        }
        
        i++;
      }
    }
    
    return false;
  }
  
  bool _isKingThreatening(List<List<ChessPiece?>> board, Position kingPosition, PieceColor opponentColor) {
    for (int rowOffset = -1; rowOffset <= 1; rowOffset++) {
      for (int colOffset = -1; colOffset <= 1; colOffset++) {
        if (rowOffset == 0 && colOffset == 0) continue;
        
        final row = kingPosition.row + rowOffset;
        final col = kingPosition.col + colOffset;
        
        if (_isValidPosition(row, col)) {
          final piece = board[row][col];
          if (piece != null && piece.type == PieceType.king && piece.color == opponentColor) {
            return true;
          }
        }
      }
    }
    
    return false;
  }
  
  bool _isValidPosition(int row, int col) {
    return row >= 0 && row < 8 && col >= 0 && col < 8;
  }
}
