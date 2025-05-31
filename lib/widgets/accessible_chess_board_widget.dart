import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import '../models/chess_piece.dart';
import '../models/position.dart';
import '../services/accessibility_service.dart';

/// Ein barrierefreies Schachbrett-Widget
class AccessibleChessBoardWidget extends StatefulWidget {
  final dynamic board;
  final Function(Position, Position) onMove;
  final bool colorBlindMode;
  final bool highContrastMode;

  const AccessibleChessBoardWidget({
    super.key,
    required this.board,
    required this.onMove,
    this.colorBlindMode = false,
    this.highContrastMode = false,
  });

  @override
  State<AccessibleChessBoardWidget> createState() =>
      _AccessibleChessBoardWidgetState();
}

class _AccessibleChessBoardWidgetState
    extends State<AccessibleChessBoardWidget> {
  Position? _selectedPosition;
  List<Position> _validMovePositions = [];
  final AccessibilityService _accessibilityService = AccessibilityService();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boardSize = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;
        final squareSize = boardSize / 8;

        return SizedBox(
          width: boardSize,
          height: boardSize,
          child: Stack(
            children: [
              // Schachbrett
              _buildBoard(squareSize),

              // Hervorhebung des ausgewählten Feldes
              if (_selectedPosition != null)
                Positioned(
                  left: _selectedPosition!.col * squareSize,
                  top: _selectedPosition!.row * squareSize,
                  child: Container(
                    width: squareSize,
                    height: squareSize,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.blue,
                        width: 3.0,
                      ),
                    ),
                  ),
                ),

              // Hervorhebung der gültigen Züge
              ..._validMovePositions.map((position) {
                return Positioned(
                  left: position.col * squareSize,
                  top: position.row * squareSize,
                  child: Container(
                    width: squareSize,
                    height: squareSize,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.3),
                      border: Border.all(
                        color: Colors.green,
                        width: 2.0,
                      ),
                    ),
                  ),
                );
              }),

              // Figuren
              for (int row = 0; row < 8; row++)
                for (int col = 0; col < 8; col++)
                  _buildPiece(row, col, squareSize),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBoard(double squareSize) {
    return Column(
      children: List.generate(8, (row) {
        return Row(
          children: List.generate(8, (col) {
            final isLightSquare = (row + col) % 2 == 0;

            // Farben basierend auf Barrierefreiheitseinstellungen anpassen
            Color squareColor;
            if (widget.highContrastMode) {
              squareColor = isLightSquare ? Colors.white : Colors.black;
            } else if (widget.colorBlindMode) {
              squareColor =
                  isLightSquare ? Colors.lightBlue[100]! : Colors.indigo[700]!;
            } else {
              squareColor = isLightSquare ? Colors.white : Colors.brown[600]!;
            }

            return GestureDetector(
              onTap: () => _handleSquareTap(row, col),
              child: Semantics(
                label: _getSquareSemanticsLabel(row, col),
                child: Container(
                  width: squareSize,
                  height: squareSize,
                  color: squareColor,
                  child: _buildCoordinateLabel(
                      row, col, squareSize, isLightSquare),
                ),
              ),
            );
          }),
        );
      }),
    );
  }

  Widget _buildCoordinateLabel(
      int row, int col, double squareSize, bool isLightSquare) {
    // Zeige Koordinaten am Rand des Bretts an
    if (row == 7 || col == 0) {
      final textColor = widget.highContrastMode
          ? (isLightSquare ? Colors.black : Colors.white)
          : (isLightSquare ? Colors.brown[600] : Colors.white);

      String label = '';
      TextAlign alignment = TextAlign.center;

      if (row == 7 && col == 0) {
        // Ecke links unten: a1
        label = 'a1';
        alignment = TextAlign.left;
      } else if (row == 7) {
        // Untere Reihe: Buchstaben (a-h)
        label = String.fromCharCode('a'.codeUnitAt(0) + col);
        alignment = TextAlign.center;
      } else if (col == 0) {
        // Linke Spalte: Zahlen (1-8)
        label = (8 - row).toString();
        alignment = TextAlign.left;
      }

      return Padding(
        padding: const EdgeInsets.all(2.0),
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: squareSize / 6,
            fontWeight: FontWeight.bold,
          ),
          textAlign: alignment,
        ),
      );
    }

    return Container();
  }

  Widget _buildPiece(int row, int col, double squareSize) {
    final piece = widget.board.getPiece(Position(row: row, col: col));
    if (piece == null) return Container();

    // Pfad zum Bild der Figur
    String imagePath = _getPieceImagePath(piece, widget.colorBlindMode);

    return Positioned(
      left: col * squareSize,
      top: row * squareSize,
      child: Semantics(
        label: _getPieceSemanticsLabel(piece, row, col),
        child: GestureDetector(
          onTap: () => _handleSquareTap(row, col),
          child: SizedBox(
            width: squareSize,
            height: squareSize,
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  String _getPieceImagePath(ChessPiece piece, bool colorBlindMode) {
    final colorStr = piece.color == PieceColor.white ? 'white' : 'black';
    final typeStr = piece.type.toString().split('.').last;

    if (colorBlindMode) {
      // Verwende spezielle Bilder für den Farbenblindheitsmodus
      return 'assets/images/pieces/colorblind/${colorStr}_$typeStr.png';
    } else {
      return 'assets/images/pieces/${colorStr}_$typeStr.png';
    }
  }

  String _getSquareSemanticsLabel(int row, int col) {
    final squareName = _accessibilityService.getSquareDescription(row, col);
    final piece = widget.board.getPiece(Position(row: row, col: col));

    if (piece != null) {
      final pieceDescription = _accessibilityService.getPieceDescription(
        piece.type.toString().split('.').last,
        piece.color == PieceColor.white ? 'white' : 'black',
      );
      return '$squareName mit $pieceDescription';
    } else {
      return '$squareName, leeres Feld';
    }
  }

  String _getPieceSemanticsLabel(ChessPiece piece, int row, int col) {
    final squareName = _accessibilityService.getSquareDescription(row, col);
    final pieceDescription = _accessibilityService.getPieceDescription(
      piece.type.toString().split('.').last,
      piece.color == PieceColor.white ? 'white' : 'black',
    );

    return '$pieceDescription auf $squareName';
  }

  void _handleSquareTap(int row, int col) {
    final position = Position(row: row, col: col);
    final piece = widget.board.getPiece(position);

    if (_selectedPosition == null) {
      // Wenn keine Figur ausgewählt ist und das Feld eine Figur enthält
      if (piece != null && piece.color == widget.board.currentTurn) {
        setState(() {
          _selectedPosition = position;
          _validMovePositions = widget.board
              .getValidMovesForPiece(position)
              .map((move) => move.to)
              .toList();
        });
      }
    } else {
      // Wenn bereits eine Figur ausgewählt ist
      if (_selectedPosition == position) {
        // Wenn das gleiche Feld erneut angeklickt wird, Auswahl aufheben
        setState(() {
          _selectedPosition = null;
          _validMovePositions = [];
        });
      } else if (piece != null && piece.color == widget.board.currentTurn) {
        // Wenn eine andere eigene Figur angeklickt wird, diese auswählen
        setState(() {
          _selectedPosition = position;
          _validMovePositions = widget.board
              .getValidMovesForPiece(position)
              .map((move) => move.to)
              .toList();
        });
      } else if (_validMovePositions.any((pos) => pos == position)) {
        // Wenn ein gültiges Zielfeld angeklickt wird, Zug ausführen
        widget.onMove(_selectedPosition!, position);
        setState(() {
          _selectedPosition = null;
          _validMovePositions = [];
        });
      } else {
        // Wenn ein ungültiges Feld angeklickt wird, Auswahl aufheben
        setState(() {
          _selectedPosition = null;
          _validMovePositions = [];
        });
      }
    }
  }
}
