import 'package:flutter/material.dart';
import '../models/antichess_board.dart';
import '../models/chess_piece.dart';
import '../models/position.dart';
import '../widgets/chess_board_widget.dart';
import '../services/antichess_service.dart';

class AntichessGameScreen extends StatefulWidget {
  const AntichessGameScreen({super.key});

  @override
  State<AntichessGameScreen> createState() => _AntichessGameScreenState();
}

class _AntichessGameScreenState extends State<AntichessGameScreen> {
  late AntichessBoard _board;
  final AntichessService _antichessService = AntichessService();
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
      _board = AntichessBoard();
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

        // Füge Information hinzu, ob eine Figur geschlagen wurde
        final targetPiece = _board.getPiece(to);
        if (targetPiece != null && targetPiece != piece) {
          moveNotation += ' (schlägt ${_getPieceSymbol(targetPiece.type)})';
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
        // In Antichess gewinnt der Spieler, der alle seine Figuren verliert
        _statusMessage = _board.winner == PieceColor.white
            ? 'Weiß gewinnt! (Alle Figuren verloren oder Schwarz kann nicht ziehen)'
            : 'Schwarz gewinnt! (Alle Figuren verloren oder Weiß kann nicht ziehen)';
      } else {
        _statusMessage = 'Unentschieden!';
      }
    } else {
      _statusMessage = _board.currentTurn == PieceColor.white
          ? 'Weiß ist am Zug'
          : 'Schwarz ist am Zug';

      // Zeige an, wenn Schlagzwang besteht
      if (_antichessService.mustCapture(
          _board.getBoardState(), _board.currentTurn)) {
        _statusMessage += ' (Schlagzwang!)';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Antichess (Räuberschach)'),
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

  Color _getStatusColor() {
    if (_gameOver) {
      return Colors.blue.withOpacity(0.3);
    } else if (_antichessService.mustCapture(
        _board.getBoardState(), _board.currentTurn)) {
      return Colors.orange.withOpacity(0.3);
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
        title: const Text('Antichess Regeln'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  'Antichess (auch bekannt als Räuberschach) ist eine Schachvariante mit umgekehrtem Ziel:'),
              SizedBox(height: 8),
              Text(
                  '• Ziel ist es, alle eigenen Figuren zu verlieren oder in eine Position zu geraten, in der man nicht ziehen kann.'),
              Text(
                  '• Wenn ein Spieler schlagen kann, muss er es tun (Schlagzwang).'),
              Text(
                  '• Der König hat keinen besonderen Status und kann geschlagen werden.'),
              Text('• Es gibt keine Rochade.'),
              Text('• Es gibt kein Schach oder Schachmatt.'),
              SizedBox(height: 8),
              Text('Gewinnen kann man durch:'),
              Text('• Verlust aller eigenen Figuren'),
              Text(
                  '• Erreichen einer Position, in der man keinen gültigen Zug mehr machen kann'),
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

  String _getPieceSymbol(PieceType type) {
    switch (type) {
      case PieceType.pawn:
        return 'Bauer';
      case PieceType.knight:
        return 'Springer';
      case PieceType.bishop:
        return 'Läufer';
      case PieceType.rook:
        return 'Turm';
      case PieceType.queen:
        return 'Dame';
      case PieceType.king:
        return 'König';
    }
  }
}
