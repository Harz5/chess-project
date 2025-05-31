import 'package:flutter/material.dart';
import '../models/king_of_the_hill_board.dart';
import '../models/chess_piece.dart';
import '../models/position.dart';
import '../widgets/chess_board_widget.dart';
import '../services/king_of_the_hill_service.dart';

class KingOfTheHillGameScreen extends StatefulWidget {
  const KingOfTheHillGameScreen({super.key});

  @override
  State<KingOfTheHillGameScreen> createState() =>
      _KingOfTheHillGameScreenState();
}

class _KingOfTheHillGameScreenState extends State<KingOfTheHillGameScreen> {
  late KingOfTheHillBoard _board;
  final KingOfTheHillService _kingOfTheHillService = KingOfTheHillService();
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
      _board = KingOfTheHillBoard();
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

        // Füge Information hinzu, ob der König im Zentrum steht
        if (piece.type == PieceType.king && _board.isPositionInCenter(to)) {
          moveNotation += ' (Zentrum!)';
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
        if (_board.isKingInCenter(_board.winner!)) {
          _statusMessage = _board.winner == PieceColor.white
              ? 'Weiß gewinnt! (König im Zentrum)'
              : 'Schwarz gewinnt! (König im Zentrum)';
        } else {
          _statusMessage = _board.winner == PieceColor.white
              ? 'Weiß gewinnt! (Schachmatt)'
              : 'Schwarz gewinnt! (Schachmatt)';
        }
      } else {
        _statusMessage = 'Patt - Unentschieden!';
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
        title: const Text('King of the Hill'),
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
              // Overlay für das Zentrum
              Center(
                child: _buildCenterOverlay(),
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
              // Overlay für das Zentrum
              Center(
                child: _buildCenterOverlay(),
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

  Widget _buildCenterOverlay() {
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
            painter: CenterSquaresPainter(squareSize),
          ),
        );
      },
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
        title: const Text('King of the Hill Regeln'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  'King of the Hill ist eine Schachvariante, bei der ein Spieler gewinnt, wenn er seinen König ins Zentrum des Bretts bringt.'),
              SizedBox(height: 8),
              Text('• Alle normalen Schachregeln gelten.'),
              Text(
                  '• Ein Spieler gewinnt, wenn er seinen König auf eines der vier Zentrumsfelder (d4, d5, e4, e5) bringt.'),
              Text(
                  '• Ein Spieler gewinnt auch, wenn er den gegnerischen König schachmatt setzt.'),
              Text('• Die Zentrumsfelder sind auf dem Brett markiert.'),
              SizedBox(height: 8),
              Text('Strategie:'),
              Text(
                  '• Versuche, deinen König ins Zentrum zu bringen, während du den gegnerischen König davon abhältst.'),
              Text(
                  '• Manchmal ist es besser, Material zu opfern, um den König ins Zentrum zu bringen.'),
              Text(
                  '• Achte auf deine Königssicherheit, da der Gegner versuchen wird, dich schachmatt zu setzen.'),
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

class CenterSquaresPainter extends CustomPainter {
  final double squareSize;

  CenterSquaresPainter(this.squareSize);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellow.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // Zeichne die vier Zentrumsfelder (d4, d5, e4, e5)
    // Die Indizes sind 0-basiert, daher sind die Zentrumsfelder (3,3), (3,4), (4,3), (4,4)
    canvas.drawRect(
      Rect.fromLTWH(3 * squareSize, 3 * squareSize, squareSize, squareSize),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(4 * squareSize, 3 * squareSize, squareSize, squareSize),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(3 * squareSize, 4 * squareSize, squareSize, squareSize),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(4 * squareSize, 4 * squareSize, squareSize, squareSize),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
