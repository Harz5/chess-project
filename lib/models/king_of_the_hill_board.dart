import '../models/chess_board.dart';
import '../models/chess_piece.dart';
import '../models/position.dart';
import '../services/king_of_the_hill_service.dart';

class KingOfTheHillBoard extends ChessBoard {
  // Service für die King of the Hill-spezifische Logik
  final KingOfTheHillService _kingOfTheHillService = KingOfTheHillService();
  
  KingOfTheHillBoard({String? initialFen}) : super(initialFen: initialFen);

  // Erstellt ein King of the Hill-Brett aus einer FEN-Notation
  factory KingOfTheHillBoard.fromFen(String fen) {
    return KingOfTheHillBoard(initialFen: fen);
  }

  @override
  void _checkGameOver() {
    // Überprüfe, ob das Spiel beendet ist
    final isWhiteKingInCheck = isKingInCheck(PieceColor.white);
    final isBlackKingInCheck = isKingInCheck(PieceColor.black);
    final hasWhiteValidMoves = hasValidMove(PieceColor.white);
    final hasBlackValidMoves = hasValidMove(PieceColor.black);
    
    if (_kingOfTheHillService.isGameOver(_board, isWhiteKingInCheck, isBlackKingInCheck, 
                                        hasWhiteValidMoves, hasBlackValidMoves)) {
      _gameOver = true;
      _winner = _kingOfTheHillService.getWinner(_board, isWhiteKingInCheck, isBlackKingInCheck,
                                              hasWhiteValidMoves, hasBlackValidMoves);
    }
  }
  
  // Überprüft, ob ein König im Zentrum steht
  bool isKingInCenter(PieceColor color) {
    return _kingOfTheHillService.isKingInCenter(_board, color);
  }
  
  // Überprüft, ob eine Position im Zentrum liegt
  bool isPositionInCenter(Position position) {
    return _kingOfTheHillService.isPositionInCenter(position);
  }
}
