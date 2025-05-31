import '../models/chess_board.dart';
import '../models/chess_piece.dart';
import '../models/position.dart';
import '../services/chess960_service.dart';

class Chess960Board extends ChessBoard {
  // Speichert die ursprünglichen Positionen der Türme für die Rochade
  final Map<PieceColor, List<Position>> _originalRookPositions = {
    PieceColor.white: [],
    PieceColor.black: [],
  };

  // Speichert die ursprüngliche Position des Königs für die Rochade
  final Map<PieceColor, Position> _originalKingPositions = {};

  Chess960Board({String? initialFen}) : super() {
    if (initialFen != null) {
      _loadFromFen(initialFen);
    } else {
      // Generiere eine zufällige Chess960-Startposition
      final chess960Service = Chess960Service();
      final fen = chess960Service.generateStartPosition();
      _loadFromFen(fen);
    }
    
    // Speichere die ursprünglichen Positionen der Türme und des Königs
    _storeOriginalPositions();
  }

  // Erstellt ein Chess960-Brett aus einer FEN-Notation
  factory Chess960Board.fromFen(String fen) {
    return Chess960Board(initialFen: fen);
  }

  // Speichert die ursprünglichen Positionen der Türme und des Königs
  void _storeOriginalPositions() {
    // Speichere die Positionen der weißen Figuren
    for (int col = 0; col < 8; col++) {
      final piece = _board[7][col];
      if (piece != null) {
        if (piece.type == PieceType.rook && piece.color == PieceColor.white) {
          _originalRookPositions[PieceColor.white]!.add(Position(row: 7, col: col));
        } else if (piece.type == PieceType.king && piece.color == PieceColor.white) {
          _originalKingPositions[PieceColor.white] = Position(row: 7, col: col);
        }
      }
    }
    
    // Speichere die Positionen der schwarzen Figuren
    for (int col = 0; col < 8; col++) {
      final piece = _board[0][col];
      if (piece != null) {
        if (piece.type == PieceType.rook && piece.color == PieceColor.black) {
          _originalRookPositions[PieceColor.black]!.add(Position(row: 0, col: col));
        } else if (piece.type == PieceType.king && piece.color == PieceColor.black) {
          _originalKingPositions[PieceColor.black] = Position(row: 0, col: col);
        }
      }
    }
  }

  @override
  List<Move> getValidMovesForPiece(Position position) {
    final piece = getPiece(position);
    if (piece == null) return [];
    
    // Für alle Figuren außer dem König verwenden wir die Standard-Logik
    if (piece.type != PieceType.king) {
      return super.getValidMovesForPiece(position);
    }
    
    // Für den König müssen wir die speziellen Rochade-Regeln für Chess960 berücksichtigen
    List<Move> moves = super.getValidMovesForPiece(position);
    
    // Überprüfe, ob der König noch nicht bewegt wurde
    if (!piece.hasMoved) {
      final originalKingPos = _originalKingPositions[piece.color];
      if (originalKingPos != null && originalKingPos == position) {
        // Überprüfe die Rochade-Möglichkeiten
        final rookPositions = _originalRookPositions[piece.color]!;
        final chess960Service = Chess960Service();
        
        for (final rookPos in rookPositions) {
          final rook = getPiece(rookPos);
          if (rook != null && !rook.hasMoved) {
            // Bestimme, ob es sich um eine Königsseiten- oder Damenseiten-Rochade handelt
            final isKingSideCastling = rookPos.col > position.col;
            
            // Überprüfe, ob die Rochade gültig ist
            if (chess960Service.isValidCastling(
              _board,
              position,
              rookPos,
              isKingSideCastling,
            )) {
              // Füge den Rochade-Zug hinzu
              final castlingResult = chess960Service.performCastling(
                position,
                rookPos,
                isKingSideCastling,
              );
              
              moves.add(Move(
                from: position,
                to: castlingResult['king']!,
                isCastling: true,
                castlingRookFrom: rookPos,
                castlingRookTo: castlingResult['rook']!,
              ));
            }
          }
        }
      }
    }
    
    return moves;
  }

  @override
  bool makeMove(Move move) {
    // Für normale Züge verwenden wir die Standard-Logik
    if (!move.isCastling) {
      return super.makeMove(move);
    }
    
    // Für Rochade-Züge müssen wir die speziellen Chess960-Regeln anwenden
    final king = getPiece(move.from);
    if (king == null || king.type != PieceType.king) return false;
    
    final rookFrom = move.castlingRookFrom;
    final rookTo = move.castlingRookTo;
    
    if (rookFrom == null || rookTo == null) return false;
    
    final rook = getPiece(rookFrom);
    if (rook == null || rook.type != PieceType.rook) return false;
    
    // Führe den Rochade-Zug aus
    _board[move.to.row][move.to.col] = king.copyWith(hasMoved: true);
    _board[move.from.row][move.from.col] = null;
    
    _board[rookTo.row][rookTo.col] = rook.copyWith(hasMoved: true);
    _board[rookFrom.row][rookFrom.col] = null;
    
    // Aktualisiere den Spielzustand
    _currentTurn = _currentTurn == PieceColor.white ? PieceColor.black : PieceColor.white;
    _moveHistory.add(move);
    
    // Überprüfe, ob der Gegner im Schach steht
    _isCheck = isKingInCheck(_currentTurn);
    
    // Überprüfe, ob das Spiel beendet ist
    _checkGameOver();
    
    return true;
  }
}
