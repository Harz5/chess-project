import '../models/chess_board.dart';
import '../models/chess_piece.dart';
import '../models/position.dart';
import '../services/crazyhouse_service.dart';

class CrazyhouseBoard extends ChessBoard {
  // Speichert die geschlagenen Figuren, die wieder eingesetzt werden können
  final Map<PieceColor, Map<PieceType, int>> _capturedPieces = {
    PieceColor.white: {
      PieceType.pawn: 0,
      PieceType.knight: 0,
      PieceType.bishop: 0,
      PieceType.rook: 0,
      PieceType.queen: 0,
    },
    PieceColor.black: {
      PieceType.pawn: 0,
      PieceType.knight: 0,
      PieceType.bishop: 0,
      PieceType.rook: 0,
      PieceType.queen: 0,
    },
  };

  // Service für die Crazyhouse-spezifische Logik
  final CrazyhouseService _crazyhouseService = CrazyhouseService();

  CrazyhouseBoard({String? initialFen}) : super(initialFen: initialFen);

  // Erstellt ein Crazyhouse-Brett aus einer FEN-Notation
  factory CrazyhouseBoard.fromFen(String fen) {
    return CrazyhouseBoard(initialFen: fen);
  }

  // Gibt die Anzahl der geschlagenen Figuren eines bestimmten Typs und einer bestimmten Farbe zurück
  int getCapturedPieceCount(PieceColor color, PieceType type) {
    return _capturedPieces[color]![type]!;
  }

  // Gibt alle geschlagenen Figuren einer bestimmten Farbe zurück
  Map<PieceType, int> getCapturedPieces(PieceColor color) {
    return Map.from(_capturedPieces[color]!);
  }

  // Setzt eine geschlagene Figur auf das Brett
  bool dropPiece(PieceType type, Position position, PieceColor color) {
    // Überprüfe, ob der Spieler eine Figur dieses Typs zur Verfügung hat
    if (_capturedPieces[color]![type]! <= 0) {
      return false;
    }

    // Überprüfe, ob das Einsetzen gültig ist
    if (!_crazyhouseService.isValidDrop(_board, type, position, color)) {
      return false;
    }

    // Führe das Einsetzen durch
    _board[position.row][position.col] = _crazyhouseService.performDrop(type, position, color);
    
    // Reduziere die Anzahl der verfügbaren Figuren
    _capturedPieces[color]![type] = _capturedPieces[color]![type]! - 1;
    
    // Wechsle den Spieler
    _currentTurn = _currentTurn == PieceColor.white ? PieceColor.black : PieceColor.white;
    
    // Überprüfe, ob der Gegner im Schach steht
    _isCheck = isKingInCheck(_currentTurn);
    
    // Überprüfe, ob das Spiel beendet ist
    _checkGameOver();
    
    return true;
  }

  @override
  bool makeMove(Move move) {
    // Speichere die Figur, die möglicherweise geschlagen wird
    final capturedPiece = _board[move.to.row][move.to.col];
    
    // Führe den Zug mit der Standard-Logik aus
    final success = super.makeMove(move);
    
    if (success && capturedPiece != null) {
      // In Crazyhouse werden geschlagene Figuren dem Gegner hinzugefügt
      final captureColor = capturedPiece.color == PieceColor.white ? PieceColor.black : PieceColor.white;
      
      // Könige können nicht geschlagen werden, daher keine Überprüfung notwendig
      if (capturedPiece.type != PieceType.king) {
        _capturedPieces[captureColor]![capturedPiece.type] = _capturedPieces[captureColor]![capturedPiece.type]! + 1;
      }
    }
    
    return success;
  }

  // Überprüft, ob ein Spieler einen gültigen Zug hat, einschließlich des Einsetzens von Figuren
  @override
  bool hasValidMove(PieceColor color) {
    // Überprüfe zuerst, ob der Spieler einen gültigen Zug mit seinen Figuren auf dem Brett hat
    if (super.hasValidMove(color)) {
      return true;
    }
    
    // Überprüfe dann, ob der Spieler eine Figur einsetzen kann
    for (final entry in _capturedPieces[color]!.entries) {
      final pieceType = entry.key;
      final count = entry.value;
      
      if (count > 0) {
        // Überprüfe alle leeren Felder auf dem Brett
        for (int row = 0; row < 8; row++) {
          for (int col = 0; col < 8; col++) {
            final position = Position(row: row, col: col);
            
            // Überprüfe, ob das Einsetzen gültig ist
            if (_crazyhouseService.isValidDrop(_board, pieceType, position, color)) {
              return true;
            }
          }
        }
      }
    }
    
    return false;
  }
}
