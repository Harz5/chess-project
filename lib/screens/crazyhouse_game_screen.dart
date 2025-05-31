import 'package:flutter/material.dart';
import '../models/crazyhouse_board.dart';
import '../models/chess_piece.dart';
import '../models/position.dart';
import '../widgets/chess_board_widget.dart';
import '../services/crazyhouse_service.dart';

class CrazyhouseGameScreen extends StatefulWidget {
  const CrazyhouseGameScreen({super.key});

  @override
  State<CrazyhouseGameScreen> createState() => _CrazyhouseGameScreenState();
}

class _CrazyhouseGameScreenState extends State<CrazyhouseGameScreen> {
  late CrazyhouseBoard _board;
  final CrazyhouseService _crazyhouseService = CrazyhouseService();
  List<String> _moveHistory = [];
  bool _gameOver = false;
  String _statusMessage = '';

  // Aktuell ausgewählte Figur zum Einsetzen
  PieceType? _selectedPieceType;

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    setState(() {
      _board = CrazyhouseBoard();
      _moveHistory = [];
      _gameOver = false;
      _statusMessage = 'Weiß ist am Zug';
      _selectedPieceType = null;
    });
  }

  void _handleMove(Position from, Position to) {
    if (_gameOver) return;

    final piece = _board.getPiece(from);
    if (piece == null) return;

    // Erstelle einen Move-Objekt für den ausgewählten Zug
    final validMoves = _board.getValidMovesForPiece(from);
    final move = validMoves.firstWhere(
      (m) => m.from == from && m.to == to,
      orElse: () => Move(from: from, to: to),
    );

    // Führe den Zug aus
    final success = _board.makeMove(move);
    if (success) {
      setState(() {
        // Füge den Zug zur Historie hinzu
        String moveNotation =
            '${piece.color == PieceColor.white ? 'W' : 'S'}: ${from.toAlgebraic()} → ${to.toAlgebraic()}';
        _moveHistory.add(moveNotation);

        // Aktualisiere den Spielstatus
        _updateGameStatus();
      });
    }
  }

  void _handlePieceDrop(Position position) {
    if (_gameOver || _selectedPieceType == null) return;

    // Führe das Einsetzen durch
    final success = _board.dropPiece(
      _selectedPieceType!,
      position,
      _board.currentTurn,
    );

    if (success) {
      setState(() {
        // Füge den Zug zur Historie hinzu
        String moveNotation =
            '${_board.currentTurn == PieceColor.white ? 'S' : 'W'}: ${_selectedPieceType.toString().split('.').last} auf ${position.toAlgebraic()}';
        _moveHistory.add(moveNotation);

        // Aktualisiere den Spielstatus
        _updateGameStatus();

        // Zurücksetzen der ausgewählten Figur
        _selectedPieceType = null;
      });
    }
  }

  void _updateGameStatus() {
    if (_board.gameOver) {
      _gameOver = true;
      if (_board.winner != null) {
        _statusMessage = _board.winner == PieceColor.white
            ? 'Schachmatt - Weiß gewinnt!'
            : 'Schachmatt - Schwarz gewinnt!';
      } else {
        _statusMessage = 'Patt - Unentschieden!';
      }
    } else {
      _statusMessage = _board.currentTurn == PieceColor.white
          ? 'Weiß ist am Zug'
          : 'Schwarz ist am Zug';

      if (_board.isCheck) {
        _statusMessage += ' (Schach)';
      }
    }
  }

  void _selectPieceToPlace(PieceType type) {
    setState(() {
      _selectedPieceType = type;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crazyhouse'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetGame,
            tooltip: 'Neues Spiel',
          ),
        ],
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return orientation == Orientation.portrait
              ? _buildPortraitLayout()
              : _buildLandscapeLayout();
        },
      ),
    );
  }

  Widget _buildPortraitLayout() {
    return Column(
      children: [
        // Statusanzeige
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            _statusMessage,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),

        // Geschlagene Figuren des aktuellen Spielers
        _buildCapturedPiecesRow(_board.currentTurn),

        // Schachbrett
        Expanded(
          child: GestureDetector(
            onTapUp: _selectedPieceType != null
                ? (details) {
                    // Berechne die Position auf dem Brett
                    final RenderBox box =
                        context.findRenderObject() as RenderBox;
                    final localPosition =
                        box.globalToLocal(details.globalPosition);
                    final boardSize = box.size.width;
                    final squareSize = boardSize / 8;

                    final col = (localPosition.dx / squareSize).floor();
                    final row = (localPosition.dy / squareSize).floor();

                    if (row >= 0 && row < 8 && col >= 0 && col < 8) {
                      _handlePieceDrop(Position(row: row, col: col));
                    }
                  }
                : null,
            child: Center(
              child: ChessBoardWidget(
                board: _board,
                onMove: _handleMove,
              ),
            ),
          ),
        ),

        // Zughistorie
        if (_moveHistory.isNotEmpty)
          Container(
            height: 100,
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Zughistorie:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _moveHistory.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Chip(
                          label: Text(_moveHistory[index]),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildLandscapeLayout() {
    return Row(
      children: [
        // Schachbrett
        Expanded(
          child: GestureDetector(
            onTapUp: _selectedPieceType != null
                ? (details) {
                    // Berechne die Position auf dem Brett
                    final RenderBox box =
                        context.findRenderObject() as RenderBox;
                    final localPosition =
                        box.globalToLocal(details.globalPosition);
                    final boardSize = box.size.height;
                    final squareSize = boardSize / 8;

                    final col = (localPosition.dx / squareSize).floor();
                    final row = (localPosition.dy / squareSize).floor();

                    if (row >= 0 && row < 8 && col >= 0 && col < 8) {
                      _handlePieceDrop(Position(row: row, col: col));
                    }
                  }
                : null,
            child: Center(
              child: ChessBoardWidget(
                board: _board,
                onMove: _handleMove,
              ),
            ),
          ),
        ),

        // Seitenleiste
        SizedBox(
          width: 200,
          child: Column(
            children: [
              // Statusanzeige
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _statusMessage,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),

              // Geschlagene Figuren des aktuellen Spielers
              _buildCapturedPiecesColumn(_board.currentTurn),

              // Zughistorie
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Zughistorie:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _moveHistory.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 2.0),
                              child: Text(_moveHistory[index]),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCapturedPiecesRow(PieceColor color) {
    final capturedPieces = _board.getCapturedPieces(color);

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Verfügbare Figuren: '),
          ...PieceType.values
              .where((type) =>
                  type !=
                  PieceType.king) // Könige können nicht eingesetzt werden
              .map((type) {
            final count = capturedPieces[type] ?? 0;
            if (count <= 0) return const SizedBox.shrink();

            return GestureDetector(
              onTap: () => _selectPieceToPlace(type),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _selectedPieceType == type
                        ? Colors.blue
                        : Colors.transparent,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  children: [
                    Text(
                      _getPieceSymbol(type),
                      style: const TextStyle(fontSize: 20),
                    ),
                    Text('$count', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            );
          }).where((widget) => widget != const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildCapturedPiecesColumn(PieceColor color) {
    final capturedPieces = _board.getCapturedPieces(color);

    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Verfügbare Figuren:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: PieceType.values
                .where((type) =>
                    type !=
                    PieceType.king) // Könige können nicht eingesetzt werden
                .map((type) {
                  final count = capturedPieces[type] ?? 0;
                  if (count <= 0) return const SizedBox.shrink();

                  return GestureDetector(
                    onTap: () => _selectPieceToPlace(type),
                    child: Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedPieceType == type
                              ? Colors.blue
                              : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _getPieceSymbol(type),
                            style: const TextStyle(fontSize: 20),
                          ),
                          Text('$count', style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  );
                })
                .where((widget) => widget != const SizedBox.shrink())
                .toList(),
          ),
        ],
      ),
    );
  }

  String _getPieceSymbol(PieceType type) {
    switch (type) {
      case PieceType.pawn:
        return '♙';
      case PieceType.knight:
        return '♘';
      case PieceType.bishop:
        return '♗';
      case PieceType.rook:
        return '♖';
      case PieceType.queen:
        return '♕';
      case PieceType.king:
        return '♔';
    }
  }
}
