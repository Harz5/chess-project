import '../models/chess_board.dart';
import '../models/chess_piece.dart';
import '../models/position.dart';

/// Klasse für die Verwaltung der Antichess-Variante (auch bekannt als Räuberschach)
class AntichessService {
  // Singleton-Instanz
  static final AntichessService _instance = AntichessService._internal();
  
  factory AntichessService() {
    return _instance;
  }
  
  AntichessService._internal();
  
  /// Überprüft, ob ein Spieler einen Schlagzug machen muss
  /// 
  /// In Antichess gilt Schlagzwang: Wenn ein Spieler schlagen kann, muss er es tun
  bool mustCapture(List<List<ChessPiece?>> board, PieceColor currentTurn) {
    // Überprüfe alle Figuren des aktuellen Spielers
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece != null && piece.color == currentTurn) {
          // Überprüfe, ob diese Figur einen Schlagzug machen kann
          final position = Position(row: row, col: col);
          final moves = getValidMovesForPiece(board, position);
          
          // Wenn es mindestens einen Schlagzug gibt, muss der Spieler schlagen
          if (moves.any((move) => board[move.to.row][move.to.col] != null)) {
            return true;
          }
        }
      }
    }
    
    return false;
  }
  
  /// Gibt alle gültigen Züge für eine Figur in Antichess zurück
  /// 
  /// In Antichess gelten spezielle Regeln:
  /// - Der König hat keinen besonderen Status und kann geschlagen werden
  /// - Es gibt keine Rochade
  /// - Wenn ein Spieler schlagen kann, muss er es tun
  List<Move> getValidMovesForPiece(List<List<ChessPiece?>> board, Position position) {
    final piece = board[position.row][position.col];
    if (piece == null) return [];
    
    // Ermittle alle möglichen Züge nach den normalen Schachregeln
    // (ohne Berücksichtigung von Schach, da es in Antichess kein Schach gibt)
    List<Move> possibleMoves = [];
    
    switch (piece.type) {
      case PieceType.pawn:
        possibleMoves = _getPawnMoves(board, position, piece.color);
        break;
      case PieceType.knight:
        possibleMoves = _getKnightMoves(board, position, piece.color);
        break;
      case PieceType.bishop:
        possibleMoves = _getBishopMoves(board, position, piece.color);
        break;
      case PieceType.rook:
        possibleMoves = _getRookMoves(board, position, piece.color);
        break;
      case PieceType.queen:
        possibleMoves = _getQueenMoves(board, position, piece.color);
        break;
      case PieceType.king:
        possibleMoves = _getKingMoves(board, position, piece.color);
        break;
    }
    
    // Überprüfe, ob es Schlagzüge gibt
    final captureMoves = possibleMoves.where((move) => board[move.to.row][move.to.col] != null).toList();
    
    // Wenn es Schlagzüge gibt, sind nur diese erlaubt
    if (captureMoves.isNotEmpty) {
      return captureMoves;
    }
    
    return possibleMoves;
  }
  
  /// Überprüft, ob das Spiel beendet ist
  /// 
  /// In Antichess gewinnt ein Spieler, wenn:
  /// - Er alle seine Figuren verloren hat
  /// - Er keinen gültigen Zug mehr machen kann
  bool isGameOver(List<List<ChessPiece?>> board, PieceColor currentTurn) {
    // Überprüfe, ob der aktuelle Spieler noch Figuren hat
    bool hasOwnPieces = false;
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece != null && piece.color == currentTurn) {
          hasOwnPieces = true;
          break;
        }
      }
      if (hasOwnPieces) break;
    }
    
    // Wenn der Spieler keine Figuren mehr hat, hat er gewonnen
    if (!hasOwnPieces) {
      return true;
    }
    
    // Überprüfe, ob der aktuelle Spieler einen gültigen Zug machen kann
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece != null && piece.color == currentTurn) {
          final position = Position(row: row, col: col);
          final moves = getValidMovesForPiece(board, position);
          if (moves.isNotEmpty) {
            return false; // Spieler kann noch ziehen, Spiel ist nicht vorbei
          }
        }
      }
    }
    
    // Spieler kann nicht ziehen, hat also gewonnen
    return true;
  }
  
  // Private Hilfsmethoden zur Ermittlung der möglichen Züge für jede Figurenart
  
  List<Move> _getPawnMoves(List<List<ChessPiece?>> board, Position position, PieceColor color) {
    List<Move> moves = [];
    final direction = color == PieceColor.white ? -1 : 1;
    final startRow = color == PieceColor.white ? 6 : 1;
    
    // Vorwärtszug (ein Feld)
    if (_isValidPosition(position.row + direction, position.col) && 
        board[position.row + direction][position.col] == null) {
      moves.add(Move(
        from: position,
        to: Position(row: position.row + direction, col: position.col),
      ));
      
      // Vorwärtszug (zwei Felder) von der Startposition
      if (position.row == startRow && 
          _isValidPosition(position.row + 2 * direction, position.col) &&
          board[position.row + 2 * direction][position.col] == null) {
        moves.add(Move(
          from: position,
          to: Position(row: position.row + 2 * direction, col: position.col),
        ));
      }
    }
    
    // Schlagzüge
    for (final colOffset in [-1, 1]) {
      if (_isValidPosition(position.row + direction, position.col + colOffset)) {
        final targetPiece = board[position.row + direction][position.col + colOffset];
        if (targetPiece != null && targetPiece.color != color) {
          moves.add(Move(
            from: position,
            to: Position(row: position.row + direction, col: position.col + colOffset),
          ));
        }
      }
    }
    
    // Bauernumwandlung
    final lastRow = color == PieceColor.white ? 0 : 7;
    moves = moves.map((move) {
      if (move.to.row == lastRow) {
        return move.copyWith(promotion: PieceType.queen);
      }
      return move;
    }).toList();
    
    return moves;
  }
  
  List<Move> _getKnightMoves(List<List<ChessPiece?>> board, Position position, PieceColor color) {
    List<Move> moves = [];
    final offsets = [
      [-2, -1], [-2, 1], [-1, -2], [-1, 2],
      [1, -2], [1, 2], [2, -1], [2, 1]
    ];
    
    for (final offset in offsets) {
      final newRow = position.row + offset[0];
      final newCol = position.col + offset[1];
      
      if (_isValidPosition(newRow, newCol)) {
        final targetPiece = board[newRow][newCol];
        if (targetPiece == null || targetPiece.color != color) {
          moves.add(Move(
            from: position,
            to: Position(row: newRow, col: newCol),
          ));
        }
      }
    }
    
    return moves;
  }
  
  List<Move> _getBishopMoves(List<List<ChessPiece?>> board, Position position, PieceColor color) {
    List<Move> moves = [];
    final directions = [[-1, -1], [-1, 1], [1, -1], [1, 1]];
    
    for (final direction in directions) {
      int i = 1;
      while (true) {
        final newRow = position.row + i * direction[0];
        final newCol = position.col + i * direction[1];
        
        if (!_isValidPosition(newRow, newCol)) break;
        
        final targetPiece = board[newRow][newCol];
        if (targetPiece == null) {
          moves.add(Move(
            from: position,
            to: Position(row: newRow, col: newCol),
          ));
        } else {
          if (targetPiece.color != color) {
            moves.add(Move(
              from: position,
              to: Position(row: newRow, col: newCol),
            ));
          }
          break;
        }
        
        i++;
      }
    }
    
    return moves;
  }
  
  List<Move> _getRookMoves(List<List<ChessPiece?>> board, Position position, PieceColor color) {
    List<Move> moves = [];
    final directions = [[-1, 0], [0, -1], [0, 1], [1, 0]];
    
    for (final direction in directions) {
      int i = 1;
      while (true) {
        final newRow = position.row + i * direction[0];
        final newCol = position.col + i * direction[1];
        
        if (!_isValidPosition(newRow, newCol)) break;
        
        final targetPiece = board[newRow][newCol];
        if (targetPiece == null) {
          moves.add(Move(
            from: position,
            to: Position(row: newRow, col: newCol),
          ));
        } else {
          if (targetPiece.color != color) {
            moves.add(Move(
              from: position,
              to: Position(row: newRow, col: newCol),
            ));
          }
          break;
        }
        
        i++;
      }
    }
    
    return moves;
  }
  
  List<Move> _getQueenMoves(List<List<ChessPiece?>> board, Position position, PieceColor color) {
    return [
      ..._getBishopMoves(board, position, color),
      ..._getRookMoves(board, position, color),
    ];
  }
  
  List<Move> _getKingMoves(List<List<ChessPiece?>> board, Position position, PieceColor color) {
    List<Move> moves = [];
    for (int rowOffset = -1; rowOffset <= 1; rowOffset++) {
      for (int colOffset = -1; colOffset <= 1; colOffset++) {
        if (rowOffset == 0 && colOffset == 0) continue;
        
        final newRow = position.row + rowOffset;
        final newCol = position.col + colOffset;
        
        if (_isValidPosition(newRow, newCol)) {
          final targetPiece = board[newRow][newCol];
          if (targetPiece == null || targetPiece.color != color) {
            moves.add(Move(
              from: position,
              to: Position(row: newRow, col: newCol),
            ));
          }
        }
      }
    }
    
    // In Antichess gibt es keine Rochade
    
    return moves;
  }
  
  bool _isValidPosition(int row, int col) {
    return row >= 0 && row < 8 && col >= 0 && col < 8;
  }
}
