import 'package:flutter/material.dart';
import '../models/chess_piece.dart';
import '../models/position.dart';

/// Widget zur Darstellung einer einzelnen Schachfigur.
class ChessPieceWidget extends StatelessWidget {
  final ChessPiece piece;
  final double size;

  const ChessPieceWidget({
    super.key,
    required this.piece,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        piece.symbol,
        style: TextStyle(
          fontSize: size * 0.7,
          color: piece.color == PieceColor.white ? Colors.white : Colors.black,
          shadows: [
            Shadow(
              blurRadius: 2,
              color: piece.color == PieceColor.white
                  ? Colors.black54
                  : Colors.white54,
              offset: const Offset(1, 1),
            ),
          ],
        ),
      ),
    );
  }
}
