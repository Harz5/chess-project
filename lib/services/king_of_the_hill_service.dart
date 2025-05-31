import '../models/chess_board.dart';
import '../models/chess_piece.dart';
import '../models/position.dart';

/// Klasse für die Verwaltung der King of the Hill-Variante
class KingOfTheHillService {
  // Singleton-Instanz
  static final KingOfTheHillService _instance =
      KingOfTheHillService._internal();

  factory KingOfTheHillService() {
    return _instance;
  }

  KingOfTheHillService._internal();

  /// Überprüft, ob ein König im Zentrum des Bretts steht
  ///
  /// Das Zentrum des Bretts besteht aus den Feldern d4, d5, e4 und e5
  bool isKingInCenter(List<List<ChessPiece?>> board, PieceColor kingColor) {
    // Definiere die Zentrumsfelder
    final centerPositions = [
      const Position(row: 3, col: 3), // d4
      const Position(row: 3, col: 4), // e4
      const Position(row: 4, col: 3), // d5
      const Position(row: 4, col: 4), // e5
    ];

    // Überprüfe, ob der König auf einem der Zentrumsfelder steht
    for (final position in centerPositions) {
      final piece = board[position.row][position.col];
      if (piece != null &&
          piece.type == PieceType.king &&
          piece.color == kingColor) {
        return true;
      }
    }

    return false;
  }

  /// Überprüft, ob das Spiel beendet ist (König im Zentrum oder Schachmatt)
  bool isGameOver(
      List<List<ChessPiece?>> board,
      bool isWhiteKingInCheck,
      bool isBlackKingInCheck,
      bool hasWhiteValidMoves,
      bool hasBlackValidMoves) {
    // Überprüfe, ob ein König im Zentrum steht
    if (isKingInCenter(board, PieceColor.white) ||
        isKingInCenter(board, PieceColor.black)) {
      return true;
    }

    // Überprüfe auf Schachmatt
    if ((isWhiteKingInCheck && !hasWhiteValidMoves) ||
        (isBlackKingInCheck && !hasBlackValidMoves)) {
      return true;
    }

    // Überprüfe auf Patt
    if ((!isWhiteKingInCheck && !hasWhiteValidMoves) ||
        (!isBlackKingInCheck && !hasBlackValidMoves)) {
      return true;
    }

    return false;
  }

  /// Ermittelt den Gewinner
  PieceColor? getWinner(
      List<List<ChessPiece?>> board,
      bool isWhiteKingInCheck,
      bool isBlackKingInCheck,
      bool hasWhiteValidMoves,
      bool hasBlackValidMoves) {
    // Wenn ein König im Zentrum steht, gewinnt dieser Spieler
    if (isKingInCenter(board, PieceColor.white)) {
      return PieceColor.white;
    }

    if (isKingInCenter(board, PieceColor.black)) {
      return PieceColor.black;
    }

    // Wenn ein König schachmatt ist, gewinnt der andere Spieler
    if (isWhiteKingInCheck && !hasWhiteValidMoves) {
      return PieceColor.black;
    }

    if (isBlackKingInCheck && !hasBlackValidMoves) {
      return PieceColor.white;
    }

    // Bei Patt gibt es keinen Gewinner
    return null;
  }

  /// Überprüft, ob ein Feld im Zentrum des Bretts liegt
  bool isPositionInCenter(Position position) {
    return (position.row == 3 || position.row == 4) &&
        (position.col == 3 || position.col == 4);
  }
}
