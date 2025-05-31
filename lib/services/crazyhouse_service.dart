import '../models/chess_piece.dart';
import '../models/position.dart';

/// Klasse für die Verwaltung der Crazyhouse-Variante
class CrazyhouseService {
  // Singleton-Instanz
  static final CrazyhouseService _instance = CrazyhouseService._internal();

  factory CrazyhouseService() {
    return _instance;
  }

  CrazyhouseService._internal();

  /// Überprüft, ob ein Einsetzen einer Figur in Crazyhouse gültig ist
  ///
  /// In Crazyhouse gelten spezielle Regeln für das Einsetzen:
  /// - Figuren können nur auf leere Felder eingesetzt werden
  /// - Bauern können nicht auf der ersten oder letzten Reihe eingesetzt werden
  /// - Eingesetzte Figuren können nicht direkt Schach bieten
  bool isValidDrop(
    List<List<ChessPiece?>> board,
    PieceType pieceType,
    Position position,
    PieceColor color,
  ) {
    // Überprüfe, ob das Zielfeld leer ist
    if (board[position.row][position.col] != null) {
      return false;
    }

    // Bauern können nicht auf der ersten oder letzten Reihe eingesetzt werden
    if (pieceType == PieceType.pawn) {
      if (position.row == 0 || position.row == 7) {
        return false;
      }
    }

    // Hier könnte man noch überprüfen, ob das Einsetzen direktes Schach bietet
    // Dies würde jedoch eine vollständige Schachlogik erfordern

    return true;
  }

  /// Führt das Einsetzen einer Figur in Crazyhouse durch
  ///
  /// Gibt die neue Figur zurück, die auf das Brett gesetzt wurde
  ChessPiece performDrop(
    PieceType pieceType,
    Position position,
    PieceColor color,
  ) {
    return ChessPiece(
      type: pieceType,
      color: color,
      hasMoved: true, // Eingesetzte Figuren gelten als bewegt
    );
  }
}
