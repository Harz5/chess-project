import '../models/chess_board.dart';
import '../models/chess_piece.dart';
import '../models/position.dart';
import '../services/three_check_service.dart';

class ThreeCheckBoard extends ChessBoard {
  // Service für die Three-Check-spezifische Logik
  final ThreeCheckService _threeCheckService = ThreeCheckService();
  
  // Zählt die Anzahl der Schachs für jeden Spieler
  int _whiteChecks = 0;
  int _blackChecks = 0;
  
  // Getter für die Anzahl der Schachs
  int get whiteChecks => _whiteChecks;
  int get blackChecks => _blackChecks;
  
  ThreeCheckBoard({String? initialFen}) : super(initialFen: initialFen);

  // Erstellt ein Three-Check-Brett aus einer FEN-Notation
  factory ThreeCheckBoard.fromFen(String fen) {
    return ThreeCheckBoard(initialFen: fen);
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
    
    // Speichere den aktuellen Zustand, um zu überprüfen, ob der Zug ein Schach verursacht
    final wasInCheck = isKingInCheck(_currentTurn == PieceColor.white ? PieceColor.black : PieceColor.white);
    
    // Führe den Zug mit der Standard-Logik aus
    final success = super.makeMove(move);
    
    if (success) {
      // Überprüfe, ob der Zug ein Schach verursacht hat
      final isNowInCheck = isKingInCheck(_currentTurn);
      
      // Wenn der Gegner jetzt im Schach steht und vorher nicht im Schach stand,
      // erhöhe den Schach-Zähler für den Spieler, der den Zug gemacht hat
      if (isNowInCheck && !wasInCheck) {
        if (_currentTurn == PieceColor.black) {
          _whiteChecks++;
        } else {
          _blackChecks++;
        }
        
        // Überprüfe, ob das Spiel durch drei Schachs beendet ist
        if (_threeCheckService.isGameOver(_whiteChecks, _blackChecks)) {
          _gameOver = true;
          _winner = _threeCheckService.getWinner(_whiteChecks, _blackChecks);
        }
      }
    }
    
    return success;
  }

  @override
  bool isKingInCheck(PieceColor color) {
    return _threeCheckService.isKingInCheck(_board, color);
  }
  
  // Gibt eine Textdarstellung der aktuellen Schach-Zähler zurück
  String getChecksDisplay() {
    return "Weiß: $_whiteChecks Schachs | Schwarz: $_blackChecks Schachs";
  }
}
