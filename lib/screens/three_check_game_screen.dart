import 'package:flutter/material.dart';
import '../models/three_check_board.dart';
import '../models/chess_piece.dart';
import '../models/position.dart';
import '../widgets/chess_board_widget.dart';
import '../services/three_check_service.dart';

class ThreeCheckGameScreen extends StatefulWidget {
  const ThreeCheckGameScreen({super.key});

  @override
  State<ThreeCheckGameScreen> createState() => _ThreeCheckGameScreenState();
}

class _ThreeCheckGameScreenState extends State<ThreeCheckGameScreen> {
  late ThreeCheckBoard _board;
  final ThreeCheckService _threeCheckService = ThreeCheckService();
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
      _board = ThreeCheckBoard();
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

        // Füge Information hinzu, ob der Zug ein Schach verursacht hat
        if (_board.isCheck) {
          moveNotation += ' +';
        }

        _moveHistory.add(moveNotation);

        // Aktualisiere den Spielstatus
        _updateGameStatus();
      });
    }
  }

  void _updateGameStatus() {
    if (_board.gameOver) {
      _gameOver = true;
      if (_board.winner != null) {
        _statusMessage = _board.winner == PieceColor.white
            ? 'Weiß gewinnt! (Drei Schachs)'
            : 'Schwarz gewinnt! (Drei Schachs)';
      } else {
        _statusMessage = 'Unentschieden!';
      }
    } else {
      _statusMessage = _board.currentTurn == PieceColor.white
          ? 'Weiß ist am Zug'
          : 'Schwarz ist am Zug';

      if (_board.isCheck) {
        _statusMessage += ' (Schach!)';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Three-Check'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetGame,
            tooltip: 'Neues Spiel',
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showRules,
            tooltip: 'Regeln',
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
        Container(
          padding: const EdgeInsets.all(8.0),
          color: _getStatusColor(),
          width: double.infinity,
          child: Text(
            _statusMessage,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),

        // Schach-Zähler
        Container(
          padding: const EdgeInsets.all(8.0),
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCheckCounter(PieceColor.white),
              _buildCheckCounter(PieceColor.black),
            ],
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
              Container(
                padding: const EdgeInsets.all(8.0),
                color: _getStatusColor(),
                width: double.infinity,
                child: Text(
                  _statusMessage,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),

              // Schach-Zähler
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCheckCounter(PieceColor.white),
                    _buildCheckCounter(PieceColor.black),
                  ],
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

  Widget _buildCheckCounter(PieceColor color) {
    final checks =
        color == PieceColor.white ? _board.whiteChecks : _board.blackChecks;
    final colorName = color == PieceColor.white ? 'Weiß' : 'Schwarz';

    return Column(
      children: [
        Text(
          colorName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            for (int i = 0; i < 3; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: Icon(
                  i < checks ? Icons.check_circle : Icons.check_circle_outline,
                  color: i < checks ? Colors.red : Colors.grey,
                  size: 20,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Color _getStatusColor() {
    if (_gameOver) {
      return Colors.blue.withOpacity(0.3);
    } else if (_board.isCheck) {
      return Colors.red.withOpacity(0.3);
    } else {
      return _board.currentTurn == PieceColor.white
          ? Colors.white.withOpacity(0.3)
          : Colors.grey.withOpacity(0.3);
    }
  }

  void _showRules() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Three-Check Regeln'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  'Three-Check ist eine Schachvariante, bei der ein Spieler gewinnt, wenn er den gegnerischen König dreimal in Schach setzt.'),
              SizedBox(height: 8),
              Text('• Alle normalen Schachregeln gelten.'),
              Text(
                  '• Ein Spieler gewinnt, wenn er den gegnerischen König dreimal in Schach setzt.'),
              Text(
                  '• Ein Spieler gewinnt auch, wenn er den gegnerischen König schachmatt setzt.'),
              Text(
                  '• Die Anzahl der Schachs wird für jeden Spieler angezeigt.'),
              SizedBox(height: 8),
              Text('Strategie:'),
              Text(
                  '• Manchmal ist es besser, den Gegner in Schach zu setzen, als Material zu gewinnen.'),
              Text(
                  '• Achte auf deine eigene Königssicherheit, da der Gegner ebenfalls versuchen wird, dich in Schach zu setzen.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Verstanden'),
          ),
        ],
      ),
    );
  }
}
