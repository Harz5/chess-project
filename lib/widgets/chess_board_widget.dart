import 'package:flutter/material.dart';
import '../models/chess_board.dart';
import '../models/chess_piece.dart';
import '../models/position.dart';
import 'chess_piece_widget.dart';

/// Widget zur Darstellung des Schachbretts.
class ChessBoardWidget extends StatefulWidget {
  final ChessBoard board;
  final Function(Position, Position) onMove;

  const ChessBoardWidget({
    super.key,
    required this.board,
    required this.onMove,
  });

  @override
  State<ChessBoardWidget> createState() => _ChessBoardWidgetState();
}

class _ChessBoardWidgetState extends State<ChessBoardWidget> {
  Position? selectedPosition;
  List<Position> validMovePositions = [];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.shortestSide;
    final squareSize = size / 8;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Schachbrett-Hintergrund
          _buildBoard(squareSize),
          
          // Hervorhebung des ausgewählten Feldes
          if (selectedPosition != null)
            Positioned(
              left: selectedPosition!.col * squareSize,
              top: selectedPosition!.row * squareSize,
              child: Container(
                width: squareSize,
                height: squareSize,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 3),
                  color: Colors.blue.withOpacity(0.3),
                ),
              ),
            ),
          
          // Hervorhebung der gültigen Zugfelder
          ...validMovePositions.map((position) => Positioned(
            left: position.col * squareSize,
            top: position.row * squareSize,
            child: Container(
              width: squareSize,
              height: squareSize,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.3),
                border: Border.all(color: Colors.green, width: 2),
              ),
            ),
          )),
          
          // Schachfiguren
          for (int row = 0; row < 8; row++)
            for (int col = 0; col < 8; col++)
              if (widget.board.getPiece(Position(row, col)) != null)
                Positioned(
                  left: col * squareSize,
                  top: row * squareSize,
                  child: GestureDetector(
                    onTap: () => _handleTap(Position(row, col)),
                    child: SizedBox(
                      width: squareSize,
                      height: squareSize,
                      child: ChessPieceWidget(
                        piece: widget.board.getPiece(Position(row, col))!,
                        size: squareSize,
                      ),
                    ),
                  ),
                ),
          
          // Leere Felder (für Tap-Erkennung)
          for (int row = 0; row < 8; row++)
            for (int col = 0; col < 8; col++)
              if (widget.board.getPiece(Position(row, col)) == null)
                Positioned(
                  left: col * squareSize,
                  top: row * squareSize,
                  child: GestureDetector(
                    onTap: () => _handleTap(Position(row, col)),
                    child: Container(
                      width: squareSize,
                      height: squareSize,
                      color: Colors.transparent,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  /// Erstellt das Schachbrett-Hintergrundmuster.
  Widget _buildBoard(double squareSize) {
    return Column(
      children: List.generate(8, (row) {
        return Row(
          children: List.generate(8, (col) {
            final isLightSquare = (row + col) % 2 == 0;
            return Container(
              width: squareSize,
              height: squareSize,
              color: isLightSquare ? Colors.white : Colors.brown[600],
              child: _buildCoordinateLabel(row, col, squareSize, isLightSquare),
            );
          }),
        );
      }),
    );
  }

  /// Erstellt die Koordinatenbeschriftungen am Rand des Schachbretts.
  Widget _buildCoordinateLabel(int row, int col, double squareSize, bool isLightSquare) {
    final textColor = isLightSquare ? Colors.brown[600] : Colors.white;
    
    if (row == 7 && col == 0) {
      // Linke untere Ecke: Beide Labels
      return Stack(
        children: [
          Positioned(
            left: 2,
            bottom: 2,
            child: Text(
              'a',
              style: TextStyle(
                color: textColor,
                fontSize: squareSize * 0.2,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            left: 2,
            bottom: 2,
            child: Text(
              '8',
              style: TextStyle(
                color: textColor,
                fontSize: squareSize * 0.2,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    } else if (row == 7) {
      // Untere Reihe: Buchstaben
      return Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 2),
          child: Text(
            String.fromCharCode('a'.codeUnitAt(0) + col),
            style: TextStyle(
              color: textColor,
              fontSize: squareSize * 0.2,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    } else if (col == 0) {
      // Linke Spalte: Zahlen
      return Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 2, top: 2),
          child: Text(
            '${8 - row}',
            style: TextStyle(
              color: textColor,
              fontSize: squareSize * 0.2,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
    
    return const SizedBox.shrink();
  }

  /// Behandelt Tap-Ereignisse auf dem Schachbrett.
  void _handleTap(Position position) {
    if (selectedPosition == null) {
      // Erste Auswahl: Figur auswählen
      final piece = widget.board.getPiece(position);
      if (piece != null && piece.color == widget.board.currentTurn) {
        setState(() {
          selectedPosition = position;
          validMovePositions = widget.board
              .getValidMovesForPiece(position)
              .map((move) => move.to)
              .toList();
        });
      }
    } else {
      // Zweite Auswahl: Zielfeld auswählen
      if (validMovePositions.contains(position)) {
        // Gültiger Zug
        widget.onMove(selectedPosition!, position);
      }
      
      // Auswahl zurücksetzen
      setState(() {
        selectedPosition = null;
        validMovePositions = [];
      });
    }
  }
}
