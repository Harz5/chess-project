import '../models/chess_piece.dart';
import '../models/position.dart';

/// Klasse für die Verwaltung der Three-Check-Variante
class ThreeCheckService {
  // Singleton-Instanz
  static final ThreeCheckService _instance = ThreeCheckService._internal();

  factory ThreeCheckService() {
    return _instance;
  }

  ThreeCheckService._internal();

  /// Überprüft, ob ein Spieler den gegnerischen König in Schach gesetzt hat
  bool isKingInCheck(List<List<ChessPiece?>> board, PieceColor kingColor) {
    // Finde die Position des Königs
    Position? kingPosition;
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece != null &&
            piece.type == PieceType.king &&
            piece.color == kingColor) {
          kingPosition = Position(row: row, col: col);
          break;
        }
      }
      if (kingPosition != null) break;
    }

    if (kingPosition == null) return false;

    // Überprüfe, ob eine gegnerische Figur den König bedroht
    final opponentColor =
        kingColor == PieceColor.white ? PieceColor.black : PieceColor.white;

    // Überprüfe Bedrohungen durch Bauern
    if (_isPawnThreatening(board, kingPosition, opponentColor)) return true;

    // Überprüfe Bedrohungen durch Springer
    if (_isKnightThreatening(board, kingPosition, opponentColor)) return true;

    // Überprüfe Bedrohungen durch Läufer, Türme und Damen
    if (_isSlidingPieceThreatening(board, kingPosition, opponentColor))
      return true;

    // Überprüfe Bedrohungen durch den gegnerischen König
    if (_isKingThreatening(board, kingPosition, opponentColor)) return true;

    return false;
  }

  /// Überprüft, ob das Spiel beendet ist (drei Schachs)
  bool isGameOver(int whiteChecks, int blackChecks) {
    return whiteChecks >= 3 || blackChecks >= 3;
  }

  /// Ermittelt den Gewinner basierend auf der Anzahl der Schachs
  PieceColor? getWinner(int whiteChecks, int blackChecks) {
    if (whiteChecks >= 3) return PieceColor.white;
    if (blackChecks >= 3) return PieceColor.black;
    return null;
  }

  // Private Hilfsmethoden zur Überprüfung von Bedrohungen

  bool _isPawnThreatening(List<List<ChessPiece?>> board, Position kingPosition,
      PieceColor opponentColor) {
    final direction = opponentColor == PieceColor.white ? 1 : -1;

    // Überprüfe die beiden diagonalen Felder vor dem König
    for (final colOffset in [-1, 1]) {
      final row = kingPosition.row - direction;
      final col = kingPosition.col + colOffset;

      if (_isValidPosition(row, col)) {
        final piece = board[row][col];
        if (piece != null &&
            piece.type == PieceType.pawn &&
            piece.color == opponentColor) {
          return true;
        }
      }
    }

    return false;
  }

  bool _isKnightThreatening(List<List<ChessPiece?>> board,
      Position kingPosition, PieceColor opponentColor) {
    final offsets = [
      [-2, -1],
      [-2, 1],
      [-1, -2],
      [-1, 2],
      [1, -2],
      [1, 2],
      [2, -1],
      [2, 1]
    ];

    for (final offset in offsets) {
      final row = kingPosition.row + offset[0];
      final col = kingPosition.col + offset[1];

      if (_isValidPosition(row, col)) {
        final piece = board[row][col];
        if (piece != null &&
            piece.type == PieceType.knight &&
            piece.color == opponentColor) {
          return true;
        }
      }
    }

    return false;
  }

  bool _isSlidingPieceThreatening(List<List<ChessPiece?>> board,
      Position kingPosition, PieceColor opponentColor) {
    // Überprüfe Bedrohungen durch Läufer und Damen (diagonale Richtungen)
    final diagonalDirections = [
      [-1, -1],
      [-1, 1],
      [1, -1],
      [1, 1]
    ];
    for (final direction in diagonalDirections) {
      int i = 1;
      while (true) {
        final row = kingPosition.row + i * direction[0];
        final col = kingPosition.col + i * direction[1];

        if (!_isValidPosition(row, col)) break;

        final piece = board[row][col];
        if (piece != null) {
          if (piece.color == opponentColor &&
              (piece.type == PieceType.bishop ||
                  piece.type == PieceType.queen)) {
            return true;
          }
          break;
        }

        i++;
      }
    }

    // Überprüfe Bedrohungen durch Türme und Damen (horizontale und vertikale Richtungen)
    final straightDirections = [
      [-1, 0],
      [0, -1],
      [0, 1],
      [1, 0]
    ];
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

  bool _isKingThreatening(List<List<ChessPiece?>> board, Position kingPosition,
      PieceColor opponentColor) {
    for (int rowOffset = -1; rowOffset <= 1; rowOffset++) {
      for (int colOffset = -1; colOffset <= 1; colOffset++) {
        if (rowOffset == 0 && colOffset == 0) continue;

        final row = kingPosition.row + rowOffset;
        final col = kingPosition.col + colOffset;

        if (_isValidPosition(row, col)) {
          final piece = board[row][col];
          if (piece != null &&
              piece.type == PieceType.king &&
              piece.color == opponentColor) {
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
