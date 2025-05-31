import 'package:flutter/material.dart';
import '../models/racing_kings_board.dart';
import '../models/chess_piece.dart';
import '../models/position.dart';
import '../widgets/chess_board_widget.dart';
import '../services/racing_kings_service.dart';

class RacingKingsGameScreen extends StatefulWidget {
  const RacingKingsGameScreen({super.key});

  @override
  State<RacingKingsGameScreen> createState() => _RacingKingsGameScreenState();
}

class _RacingKingsGameScreenState extends State<RacingKingsGameScreen> {
  late RacingKingsBoard _board;
  final RacingKingsService _racingKingsService = RacingKingsService();
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
      _board = RacingKingsBoard();
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

        // Füge Information hinzu, ob der König die letzte Reihe erreicht hat
        if (piece.type == PieceType.king && to.row == 0) {
          moveNotation += ' (Ziel erreicht!)';
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
            ? 'Weiß gewinnt! (König im Ziel)'
            : 'Schwarz gewinnt! (König im Ziel)';
      } else {
        _statusMessage = 'Unentschieden!';
      }
    } else {
      _statusMessage = _board.currentTurn == PieceColor.white
          ? 'Weiß ist am Zug'
          : 'Schwarz ist am Zug';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Racing Kings'),
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
          child: Stack(
            children: [
              Center(
                child: ChessBoardWidget(
                  board: _board,
                  onMove: _handleMove,
                ),
              ),
              // Overlay für die Ziellinie
              Center(
                child: _buildFinishLineOverlay(),
              ),
            ],
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
          child: Stack(
            children: [
              Center(
                child: ChessBoardWidget(
                  board: _board,
                  onMove: _handleMove,
                ),
              ),
              // Overlay für die Ziellinie
              Center(
                child: _buildFinishLineOverlay(),
              ),
            ],
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

  Widget _buildFinishLineOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boardSize = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;
        final squareSize = boardSize / 8;

        return SizedBox(
          width: boardSize,
          height: boardSize,
          child: CustomPaint(
            painter: FinishLinePainter(squareSize),
          ),
        );
      },
    );
  }

  Color _getStatusColor() {
    if (_gameOver) {
      return Colors.blue.withOpacity(0.3);
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
        title: const Text('Racing Kings Regeln'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  'Racing Kings ist eine Schachvariante, bei der beide Spieler versuchen, ihren König als erster auf die letzte Reihe zu bringen.'),
              SizedBox(height: 8),
              Text('• Alle Figuren starten auf den letzten beiden Reihen.'),
              Text('• Es gibt keine Bauern in dieser Variante.'),
              Text(
                  '• Ein Spieler gewinnt, wenn er seinen König auf die letzte Reihe (aus Sicht von Schwarz) bringt.'),
              Text(
                  '• Wenn beide Könige in einem Zug die letzte Reihe erreichen, gewinnt der Spieler, der nicht am Zug ist.'),
              Text(
                  '• Es ist nicht erlaubt, Züge zu machen, die einen König in Schach setzen würden.'),
              Text('• Es gibt kein Schachmatt in dieser Variante.'),
              Text('• Die Ziellinie ist auf dem Brett markiert.'),
              SizedBox(height: 8),
              Text('Strategie:'),
              Text(
                  '• Versuche, deinen König schnell zur Ziellinie zu bringen.'),
              Text('• Blockiere den gegnerischen König mit deinen Figuren.'),
              Text(
                  '• Nutze deine Figuren, um Wege für deinen König zu öffnen.'),
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

class FinishLinePainter extends CustomPainter {
  final double squareSize;

  FinishLinePainter(this.squareSize);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // Zeichne die Ziellinie (erste Reihe)
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, squareSize),
      paint,
    );

    // Zeichne ein Zielfahnen-Symbol
    final flagPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Position für die Flagge (Mitte der ersten Reihe)
    final flagX = size.width / 2;
    final flagY = squareSize / 2;

    // Zeichne den Fahnenmast
    canvas.drawLine(
      Offset(flagX, flagY - squareSize / 4),
      Offset(flagX, flagY + squareSize / 4),
      flagPaint,
    );

    // Zeichne die Fahne
    final flagPath = Path()
      ..moveTo(flagX, flagY - squareSize / 4)
      ..lineTo(flagX + squareSize / 4, flagY - squareSize / 8)
      ..lineTo(flagX, flagY);

    canvas.drawPath(flagPath, flagPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
