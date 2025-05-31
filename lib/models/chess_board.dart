import 'dart:collection';

import 'chess_piece.dart';
import 'position.dart';
import '../services/performance_optimization_service.dart';

/// Repräsentiert einen Schachzug.
class Move {
  final Position from;
  final Position to;
  final ChessPiece? capturedPiece;
  final bool isPromotion;
  final PieceType? promotionType;
  final bool isCastling;
  final bool isEnPassant;

  Move({
    required this.from,
    required this.to,
    this.capturedPiece,
    this.isPromotion = false,
    this.promotionType,
    this.isCastling = false,
    this.isEnPassant = false,
  });

  @override
  String toString() {
    return 'Move: ${from.toAlgebraic()} -> ${to.toAlgebraic()}';
  }
}

/// Repräsentiert den Zustand eines Schachspiels.
class ChessBoard {
  // 8x8 Schachbrett, null bedeutet leeres Feld
  final List<List<ChessPiece?>> _board = List.generate(
    8,
    (_) => List.generate(8, (_) => null),
  );

  PieceColor currentTurn = PieceColor.white;
  final List<Move> moveHistory = [];
  bool gameOver = false;
  PieceColor? winner;

  // Speichert die Position der Könige für schnellen Zugriff
  Position? whiteKingPosition;
  Position? blackKingPosition;

  /// Erstellt ein neues Schachbrett mit der Standardaufstellung.
  ChessBoard() {
    setupStandardBoard();
  }

  /// Erstellt ein neues Schachbrett mit einer benutzerdefinierten Aufstellung.
  ChessBoard.custom();

  /// Richtet das Schachbrett mit der Standardaufstellung ein.
  void setupStandardBoard() {
    // Bauern
    for (int col = 0; col < 8; col++) {
      setPiece(Position(1, col), ChessPiece(PieceColor.black, PieceType.pawn));
      setPiece(Position(6, col), ChessPiece(PieceColor.white, PieceType.pawn));
    }

    // Türme
    setPiece(
        const Position(0, 0), ChessPiece(PieceColor.black, PieceType.rook));
    setPiece(
        const Position(0, 7), ChessPiece(PieceColor.black, PieceType.rook));
    setPiece(
        const Position(7, 0), ChessPiece(PieceColor.white, PieceType.rook));
    setPiece(
        const Position(7, 7), ChessPiece(PieceColor.white, PieceType.rook));

    // Springer
    setPiece(
        const Position(0, 1), ChessPiece(PieceColor.black, PieceType.knight));
    setPiece(
        const Position(0, 6), ChessPiece(PieceColor.black, PieceType.knight));
    setPiece(
        const Position(7, 1), ChessPiece(PieceColor.white, PieceType.knight));
    setPiece(
        const Position(7, 6), ChessPiece(PieceColor.white, PieceType.knight));

    // Läufer
    setPiece(
        const Position(0, 2), ChessPiece(PieceColor.black, PieceType.bishop));
    setPiece(
        const Position(0, 5), ChessPiece(PieceColor.black, PieceType.bishop));
    setPiece(
        const Position(7, 2), ChessPiece(PieceColor.white, PieceType.bishop));
    setPiece(
        const Position(7, 5), ChessPiece(PieceColor.white, PieceType.bishop));

    // Damen
    setPiece(
        const Position(0, 3), ChessPiece(PieceColor.black, PieceType.queen));
    setPiece(
        const Position(7, 3), ChessPiece(PieceColor.white, PieceType.queen));

    // Könige
    setPiece(
        const Position(0, 4), ChessPiece(PieceColor.black, PieceType.king));
    setPiece(
        const Position(7, 4), ChessPiece(PieceColor.white, PieceType.king));

    // Speichere die Positionen der Könige
    blackKingPosition = const Position(0, 4);
    whiteKingPosition = const Position(7, 4);
  }

  /// Gibt die Figur an der angegebenen Position zurück.
  ChessPiece? getPiece(Position position) {
    if (!position.isValid()) return null;
    return _board[position.row][position.col];
  }

  /// Setzt eine Figur an die angegebene Position.
  void setPiece(Position position, ChessPiece? piece) {
    if (!position.isValid()) return;

    // Aktualisiere die Königspositionen, wenn ein König gesetzt wird
    if (piece != null && piece.type == PieceType.king) {
      if (piece.color == PieceColor.white) {
        whiteKingPosition = position;
      } else {
        blackKingPosition = position;
      }
    }

    _board[position.row][position.col] = piece;
  }

  /// Führt einen Zug aus und aktualisiert den Spielzustand.
  bool makeMove(Move move) {
    if (gameOver) return false;

    final piece = getPiece(move.from);
    if (piece == null) return false;
    if (piece.color != currentTurn) return false;

    // Überprüfe, ob der Zug gültig ist
    final validMoves = getValidMovesForPiece(move.from);
    if (!validMoves.any((m) => m.from == move.from && m.to == move.to)) {
      return false;
    }

    // Führe den Zug aus
    _executeMove(move);

    // Wechsle den Spieler
    currentTurn =
        currentTurn == PieceColor.white ? PieceColor.black : PieceColor.white;

    // Überprüfe auf Schachmatt oder Patt
    checkGameEndConditions();

    return true;
  }

  /// Führt einen Zug aus, ohne die Gültigkeit zu überprüfen.
  void _executeMove(Move move) {
    final piece = getPiece(move.from)!;

    // Markiere die Figur als bewegt
    piece.hasMoved = true;

    // Spezialfall: Rochade
    if (move.isCastling) {
      _executeCastling(move);
      moveHistory.add(move);
      return;
    }

    // Spezialfall: En Passant
    if (move.isEnPassant) {
      _executeEnPassant(move);
      moveHistory.add(move);
      return;
    }

    // Normale Bewegung oder Schlagen
    setPiece(move.to, piece);
    setPiece(move.from, null);

    // Spezialfall: Bauernumwandlung
    if (move.isPromotion && move.promotionType != null) {
      setPiece(move.to, ChessPiece(piece.color, move.promotionType!));
    }

    moveHistory.add(move);
  }

  /// Führt eine Rochade aus.
  void _executeCastling(Move move) {
    final king = getPiece(move.from)!;

    // Setze den König auf die neue Position
    setPiece(move.to, king);
    setPiece(move.from, null);

    // Bewege den Turm
    if (move.to.col > move.from.col) {
      // Königsflügel-Rochade
      final rookPos = Position(move.from.row, 7);
      final rook = getPiece(rookPos)!;
      setPiece(Position(move.from.row, move.to.col - 1), rook);
      setPiece(rookPos, null);
    } else {
      // Damenflügel-Rochade
      final rookPos = Position(move.from.row, 0);
      final rook = getPiece(rookPos)!;
      setPiece(Position(move.from.row, move.to.col + 1), rook);
      setPiece(rookPos, null);
    }
  }

  /// Führt einen En-Passant-Zug aus.
  void _executeEnPassant(Move move) {
    final piece = getPiece(move.from)!;

    // Setze den Bauern auf die neue Position
    setPiece(move.to, piece);
    setPiece(move.from, null);

    // Entferne den geschlagenen Bauern
    final capturedPawnPos = Position(move.from.row, move.to.col);
    setPiece(capturedPawnPos, null);
  }

  /// Überprüft, ob das Spiel beendet ist (Schachmatt oder Patt).
  void checkGameEndConditions() {
    final kingPosition =
        currentTurn == PieceColor.white ? whiteKingPosition : blackKingPosition;
    if (kingPosition == null) return;

    // Überprüfe, ob der aktuelle Spieler im Schach steht
    final inCheck = isPositionUnderAttack(kingPosition, currentTurn);

    // Überprüfe, ob der aktuelle Spieler noch gültige Züge hat
    bool hasValidMoves = false;
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final pos = Position(row, col);
        final piece = getPiece(pos);
        if (piece != null && piece.color == currentTurn) {
          final moves = getValidMovesForPiece(pos);
          if (moves.isNotEmpty) {
            hasValidMoves = true;
            break;
          }
        }
      }
      if (hasValidMoves) break;
    }

    if (!hasValidMoves) {
      gameOver = true;
      if (inCheck) {
        // Schachmatt
        winner = currentTurn == PieceColor.white
            ? PieceColor.black
            : PieceColor.white;
      } else {
        // Patt
        winner = null;
      }
    }
  }

  /// Gibt alle gültigen Züge für eine Figur an der angegebenen Position zurück.
  List<Move> getValidMovesForPiece(Position position) {
    final piece = getPiece(position);
    if (piece == null) return [];

    List<Move> potentialMoves = [];

    switch (piece.type) {
      case PieceType.pawn:
        potentialMoves.addAll(_getPawnMoves(position, piece));
        break;
      case PieceType.knight:
        potentialMoves.addAll(_getKnightMoves(position, piece));
        break;
      case PieceType.bishop:
        potentialMoves.addAll(_getBishopMoves(position, piece));
        break;
      case PieceType.rook:
        potentialMoves.addAll(_getRookMoves(position, piece));
        break;
      case PieceType.queen:
        potentialMoves.addAll(_getQueenMoves(position, piece));
        break;
      case PieceType.king:
        potentialMoves.addAll(_getKingMoves(position, piece));
        break;
    }

    // Filtere Züge, die den eigenen König im Schach lassen würden
    return potentialMoves.where((move) {
      // Simuliere den Zug
      final tempBoard = _createBoardCopy();
      _executeMove(move);

      // Überprüfe, ob der eigene König im Schach steht
      final kingPos = piece.color == PieceColor.white
          ? whiteKingPosition
          : blackKingPosition;
      final inCheck =
          kingPos != null && isPositionUnderAttack(kingPos, piece.color);

      // Stelle den ursprünglichen Zustand wieder her
      _restoreBoardFromCopy(tempBoard);

      return !inCheck;
    }).toList();
  }

  /// Erstellt eine Kopie des aktuellen Spielbretts.
  List<List<ChessPiece?>> _createBoardCopy() {
    final copy = List.generate(
      8,
      (row) => List.generate(
        8,
        (col) {
          final piece = _board[row][col];
          return piece?.copy();
        },
      ),
    );
    return copy;
  }

  /// Stellt das Spielbrett aus einer Kopie wieder her.
  void _restoreBoardFromCopy(List<List<ChessPiece?>> boardCopy) {
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        _board[row][col] = boardCopy[row][col];
      }
    }
  }

  /// Überprüft, ob eine Position von einer Figur der gegnerischen Farbe angegriffen wird.
  bool isPositionUnderAttack(Position position, PieceColor color) {
    // Überprüfe Angriffe von Bauern
    final pawnDirections = color == PieceColor.white
        ? [
            [-1, -1],
            [-1, 1]
          ] // Schwarze Bauern greifen nach unten-links und unten-rechts an
        : [
            [1, -1],
            [1, 1]
          ]; // Weiße Bauern greifen nach oben-links und oben-rechts an

    for (final dir in pawnDirections) {
      final attackPos = Position(position.row + dir[0], position.col + dir[1]);
      if (attackPos.isValid()) {
        final attacker = getPiece(attackPos);
        if (attacker != null &&
            attacker.color != color &&
            attacker.type == PieceType.pawn) {
          return true;
        }
      }
    }

    // Überprüfe Angriffe von Springern
    final knightOffsets = [
      [-2, -1],
      [-2, 1],
      [-1, -2],
      [-1, 2],
      [1, -2],
      [1, 2],
      [2, -1],
      [2, 1]
    ];

    for (final offset in knightOffsets) {
      final attackPos =
          Position(position.row + offset[0], position.col + offset[1]);
      if (attackPos.isValid()) {
        final attacker = getPiece(attackPos);
        if (attacker != null &&
            attacker.color != color &&
            attacker.type == PieceType.knight) {
          return true;
        }
      }
    }

    // Überprüfe Angriffe von Läufern, Türmen und Damen
    final directions = [
      [-1, -1],
      [-1, 0],
      [-1, 1],
      [0, -1],
      [0, 1],
      [1, -1],
      [1, 0],
      [1, 1]
    ];

    for (final dir in directions) {
      int distance = 1;
      while (true) {
        final attackPos = Position(
          position.row + dir[0] * distance,
          position.col + dir[1] * distance,
        );

        if (!attackPos.isValid()) break;

        final attacker = getPiece(attackPos);
        if (attacker != null) {
          if (attacker.color != color) {
            // Überprüfe, ob die Figur in diese Richtung angreifen kann
            final isDiagonal = dir[0] != 0 && dir[1] != 0;
            final isStraight = dir[0] == 0 || dir[1] == 0;

            if ((isDiagonal &&
                    (attacker.type == PieceType.bishop ||
                        attacker.type == PieceType.queen)) ||
                (isStraight &&
                    (attacker.type == PieceType.rook ||
                        attacker.type == PieceType.queen)) ||
                (distance == 1 && attacker.type == PieceType.king)) {
              return true;
            }
          }
          break; // Blockiert durch eine Figur
        }

        distance++;
      }
    }

    return false;
  }

  /// Gibt alle möglichen Züge für einen Bauern zurück.
  List<Move> _getPawnMoves(Position position, ChessPiece pawn) {
    final List<Move> moves = [];
    final direction = pawn.color == PieceColor.white ? -1 : 1;

    // Ein Feld vorwärts
    final oneStep = Position(position.row + direction, position.col);
    if (oneStep.isValid() && getPiece(oneStep) == null) {
      // Überprüfe auf Bauernumwandlung
      if ((pawn.color == PieceColor.white && oneStep.row == 0) ||
          (pawn.color == PieceColor.black && oneStep.row == 7)) {
        // Bauernumwandlung
        for (final promotionType in [
          PieceType.queen,
          PieceType.rook,
          PieceType.bishop,
          PieceType.knight
        ]) {
          moves.add(Move(
            from: position,
            to: oneStep,
            isPromotion: true,
            promotionType: promotionType,
          ));
        }
      } else {
        moves.add(Move(from: position, to: oneStep));
      }

      // Zwei Felder vorwärts (nur vom Startfeld aus)
      if (!pawn.hasMoved) {
        final twoStep = Position(position.row + 2 * direction, position.col);
        if (twoStep.isValid() && getPiece(twoStep) == null) {
          moves.add(Move(from: position, to: twoStep));
        }
      }
    }

    // Schlagen diagonal
    for (final colOffset in [-1, 1]) {
      final capturePos =
          Position(position.row + direction, position.col + colOffset);
      if (capturePos.isValid()) {
        final targetPiece = getPiece(capturePos);
        if (targetPiece != null && targetPiece.color != pawn.color) {
          // Überprüfe auf Bauernumwandlung
          if ((pawn.color == PieceColor.white && capturePos.row == 0) ||
              (pawn.color == PieceColor.black && capturePos.row == 7)) {
            // Bauernumwandlung
            for (final promotionType in [
              PieceType.queen,
              PieceType.rook,
              PieceType.bishop,
              PieceType.knight
            ]) {
              moves.add(Move(
                from: position,
                to: capturePos,
                capturedPiece: targetPiece,
                isPromotion: true,
                promotionType: promotionType,
              ));
            }
          } else {
            moves.add(Move(
              from: position,
              to: capturePos,
              capturedPiece: targetPiece,
            ));
          }
        }
      }
    }

    // En Passant
    if (moveHistory.isNotEmpty) {
      final lastMove = moveHistory.last;
      final lastPiece = getPiece(lastMove.to);

      if (lastPiece != null &&
          lastPiece.type == PieceType.pawn &&
          lastPiece.color != pawn.color &&
          (lastMove.from.row - lastMove.to.row).abs() == 2 &&
          lastMove.to.row == position.row &&
          (lastMove.to.col - position.col).abs() == 1) {
        final enPassantPos = Position(
          position.row + direction,
          lastMove.to.col,
        );

        moves.add(Move(
          from: position,
          to: enPassantPos,
          capturedPiece: lastPiece,
          isEnPassant: true,
        ));
      }
    }

    return moves;
  }

  /// Gibt alle möglichen Züge für einen Springer zurück.
  List<Move> _getKnightMoves(Position position, ChessPiece knight) {
    final List<Move> moves = [];
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
      final targetPos =
          Position(position.row + offset[0], position.col + offset[1]);
      if (targetPos.isValid()) {
        final targetPiece = getPiece(targetPos);
        if (targetPiece == null) {
          // Leeres Feld
          moves.add(Move(from: position, to: targetPos));
        } else if (targetPiece.color != knight.color) {
          // Gegnerische Figur schlagen
          moves.add(Move(
            from: position,
            to: targetPos,
            capturedPiece: targetPiece,
          ));
        }
      }
    }

    return moves;
  }

  /// Gibt alle möglichen Züge für einen Läufer zurück.
  List<Move> _getBishopMoves(Position position, ChessPiece bishop) {
    final List<Move> moves = [];
    final directions = [
      [-1, -1],
      [-1, 1],
      [1, -1],
      [1, 1]
    ];

    for (final dir in directions) {
      int distance = 1;
      while (true) {
        final targetPos = Position(
          position.row + dir[0] * distance,
          position.col + dir[1] * distance,
        );

        if (!targetPos.isValid()) break;

        final targetPiece = getPiece(targetPos);
        if (targetPiece == null) {
          // Leeres Feld
          moves.add(Move(from: position, to: targetPos));
        } else {
          if (targetPiece.color != bishop.color) {
            // Gegnerische Figur schlagen
            moves.add(Move(
              from: position,
              to: targetPos,
              capturedPiece: targetPiece,
            ));
          }
          break; // Blockiert durch eine Figur
        }

        distance++;
      }
    }

    return moves;
  }

  /// Gibt alle möglichen Züge für einen Turm zurück.
  List<Move> _getRookMoves(Position position, ChessPiece rook) {
    final List<Move> moves = [];
    final directions = [
      [-1, 0],
      [0, -1],
      [0, 1],
      [1, 0]
    ];

    for (final dir in directions) {
      int distance = 1;
      while (true) {
        final targetPos = Position(
          position.row + dir[0] * distance,
          position.col + dir[1] * distance,
        );

        if (!targetPos.isValid()) break;

        final targetPiece = getPiece(targetPos);
        if (targetPiece == null) {
          // Leeres Feld
          moves.add(Move(from: position, to: targetPos));
        } else {
          if (targetPiece.color != rook.color) {
            // Gegnerische Figur schlagen
            moves.add(Move(
              from: position,
              to: targetPos,
              capturedPiece: targetPiece,
            ));
          }
          break; // Blockiert durch eine Figur
        }

        distance++;
      }
    }

    return moves;
  }

  /// Gibt alle möglichen Züge für eine Dame zurück.
  List<Move> _getQueenMoves(Position position, ChessPiece queen) {
    final List<Move> moves = [];

    // Die Dame bewegt sich wie ein Läufer und ein Turm kombiniert
    moves.addAll(_getBishopMoves(position, queen));
    moves.addAll(_getRookMoves(position, queen));

    return moves;
  }

  /// Gibt alle möglichen Züge für einen König zurück.
  List<Move> _getKingMoves(Position position, ChessPiece king) {
    final List<Move> moves = [];
    final directions = [
      [-1, -1],
      [-1, 0],
      [-1, 1],
      [0, -1],
      [0, 1],
      [1, -1],
      [1, 0],
      [1, 1]
    ];

    // Normale Königszüge
    for (final dir in directions) {
      final targetPos = Position(position.row + dir[0], position.col + dir[1]);
      if (targetPos.isValid()) {
        final targetPiece = getPiece(targetPos);
        if (targetPiece == null) {
          // Leeres Feld
          moves.add(Move(from: position, to: targetPos));
        } else if (targetPiece.color != king.color) {
          // Gegnerische Figur schlagen
          moves.add(Move(
            from: position,
            to: targetPos,
            capturedPiece: targetPiece,
          ));
        }
      }
    }

    // Rochade
    if (!king.hasMoved && !isPositionUnderAttack(position, king.color)) {
      // Königsflügel-Rochade
      final kingSideRookPos = Position(position.row, 7);
      final kingSideRook = getPiece(kingSideRookPos);
      if (kingSideRook != null &&
          kingSideRook.type == PieceType.rook &&
          kingSideRook.color == king.color &&
          !kingSideRook.hasMoved) {
        bool pathClear = true;
        for (int col = position.col + 1; col < 7; col++) {
          if (getPiece(Position(position.row, col)) != null) {
            pathClear = false;
            break;
          }
        }

        if (pathClear) {
          // Überprüfe, ob die Felder, über die der König zieht, nicht im Schach stehen
          bool fieldsNotAttacked = true;
          for (int col = position.col + 1; col <= position.col + 2; col++) {
            if (isPositionUnderAttack(
                Position(position.row, col), king.color)) {
              fieldsNotAttacked = false;
              break;
            }
          }

          if (fieldsNotAttacked) {
            moves.add(Move(
              from: position,
              to: Position(position.row, position.col + 2),
              isCastling: true,
            ));
          }
        }
      }

      // Damenflügel-Rochade
      final queenSideRookPos = Position(position.row, 0);
      final queenSideRook = getPiece(queenSideRookPos);
      if (queenSideRook != null &&
          queenSideRook.type == PieceType.rook &&
          queenSideRook.color == king.color &&
          !queenSideRook.hasMoved) {
        bool pathClear = true;
        for (int col = position.col - 1; col > 0; col--) {
          if (getPiece(Position(position.row, col)) != null) {
            pathClear = false;
            break;
          }
        }

        if (pathClear) {
          // Überprüfe, ob die Felder, über die der König zieht, nicht im Schach stehen
          bool fieldsNotAttacked = true;
          for (int col = position.col - 1; col >= position.col - 2; col--) {
            if (isPositionUnderAttack(
                Position(position.row, col), king.color)) {
              fieldsNotAttacked = false;
              break;
            }
          }

          if (fieldsNotAttacked) {
            moves.add(Move(
              from: position,
              to: Position(position.row, position.col - 2),
              isCastling: true,
            ));
          }
        }
      }
    }

    return moves;
  }

  /// Gibt eine String-Repräsentation des Schachbretts zurück.
  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('  a b c d e f g h');
    buffer.writeln(' +-----------------+');

    for (int row = 0; row < 8; row++) {
      buffer.write('${8 - row}|');
      for (int col = 0; col < 8; col++) {
        final piece = _board[row][col];
        if (piece == null) {
          buffer.write(' ');
        } else {
          buffer.write(piece.symbol);
        }
        buffer.write('|');
      }
      buffer.writeln(' ${8 - row}');
      buffer.writeln(' +-----------------+');
    }

    buffer.writeln('  a b c d e f g h');
    buffer.writeln('Current turn: $currentTurn');

    return buffer.toString();
  }
}
