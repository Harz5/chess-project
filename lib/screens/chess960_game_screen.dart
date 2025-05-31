import 'package:flutter/material.dart';
import '../models/chess960_board.dart';
import '../models/chess_piece.dart';
import '../models/position.dart';
import '../widgets/chess_board_widget.dart';
import '../services/chess960_service.dart';

class Chess960GameScreen extends StatefulWidget {
  const Chess960GameScreen({super.key});

  @override
  State<Chess960GameScreen> createState() => _Chess960GameScreenState();
}

class _Chess960GameScreenState extends State<Chess960GameScreen> {
  late Chess960Board _board;
  final Chess960Service _chess960Service = Chess960Service();
  List<String> _moveHistory = [];
  bool _gameOver = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  void _resetGame() {
    setState(() {
      // Generiere eine neue zufällige Chess960-Startposition
      _board = Chess960Board();
      _moveHistory = [];
      _gameOver = false;
      _statusMessage = 'Weiß ist am Zug';
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
        if (move.isCastling) {
          moveNotation += ' (Rochade)';
        }
        _moveHistory.add(moveNotation);

        // Überprüfe, ob das Spiel beendet ist
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chess960 (Fischer Random)'),
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

        // Schachbrett
        Expanded(
          child: Center(
            child: ChessBoardWidget(
              board: _board,
              onMove: _handleMove,
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
          child: Center(
            child: ChessBoardWidget(
              board: _board,
              onMove: _handleMove,
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
}
