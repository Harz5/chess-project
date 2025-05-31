/// Repräsentiert die Farbe einer Schachfigur.
enum PieceColor { white, black }

/// Repräsentiert den Typ einer Schachfigur.
enum PieceType { pawn, knight, bishop, rook, queen, king }

/// Repräsentiert eine Schachfigur.
class ChessPiece {
  final PieceColor color;
  final PieceType type;
  bool hasMoved = false;

  ChessPiece(this.color, this.type);

  /// Gibt das Symbol der Figur zurück (Unicode-Schachsymbole).
  String get symbol {
    switch (type) {
      case PieceType.pawn:
        return color == PieceColor.white ? '♙' : '♟';
      case PieceType.knight:
        return color == PieceColor.white ? '♘' : '♞';
      case PieceType.bishop:
        return color == PieceColor.white ? '♗' : '♝';
      case PieceType.rook:
        return color == PieceColor.white ? '♖' : '♜';
      case PieceType.queen:
        return color == PieceColor.white ? '♕' : '♛';
      case PieceType.king:
        return color == PieceColor.white ? '♔' : '♚';
    }
  }

  /// Gibt den Wert der Figur zurück (für Bewertungszwecke).
  int get value {
    switch (type) {
      case PieceType.pawn:
        return 1;
      case PieceType.knight:
        return 3;
      case PieceType.bishop:
        return 3;
      case PieceType.rook:
        return 5;
      case PieceType.queen:
        return 9;
      case PieceType.king:
        return 0; // Der König hat keinen endlichen Wert
    }
  }

  /// Erstellt eine Kopie der Figur.
  ChessPiece copy() {
    final piece = ChessPiece(color, type);
    piece.hasMoved = hasMoved;
    return piece;
  }

  @override
  String toString() => '$color $type';
}
