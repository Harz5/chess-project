import 'package:flutter/material.dart';
import '../models/optimized_chess_board.dart';
import '../widgets/chess_board_widget.dart';
import '../models/chess_piece.dart';
import '../models/position.dart';

/// Ein optimiertes Dashboard für alle Schachvarianten
class EnhancedGameDashboard extends StatefulWidget {
  final OptimizedChessBoard board;
  final String variantName;
  final Widget? customStatusWidget;
  final Widget? customControlsWidget;

  const EnhancedGameDashboard({
    super.key,
    required this.board,
    required this.variantName,
    this.customStatusWidget,
    this.customControlsWidget,
  });

  @override
  State<EnhancedGameDashboard> createState() => _EnhancedGameDashboardState();
}

class _EnhancedGameDashboardState extends State<EnhancedGameDashboard> {
  List<String> _moveHistory = [];
  bool _gameOver = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _updateGameStatus();
  }

  @override
  void dispose() {
    // Ressourcen freigeben
    widget.board.dispose();
    super.dispose();
  }

  void _handleMove(Position from, Position to) {
    if (_gameOver) return;

    final piece = widget.board.getPiece(from);
    if (piece == null) return;

    // Erstelle einen Move-Objekt für den ausgewählten Zug
    final validMoves = widget.board.getValidMovesForPiece(from);
    final move = validMoves.firstWhere(
      (m) => m.from == from && m.to == to,
      orElse: () => Move(from: from, to: to),
    );

    // Führe den Zug aus
    final success = widget.board.makeMove(move);
    if (success) {
      setState(() {
        // Füge den Zug zur Historie hinzu
        String moveNotation =
            '${piece.color == PieceColor.white ? 'W' : 'S'}: ${from.toAlgebraic()} → ${to.toAlgebraic()}';

        // Füge Information hinzu, wenn eine Figur geschlagen wurde
        if (move.capturedPiece != null) {
          moveNotation +=
              ' (${_getPieceSymbol(move.capturedPiece!)} geschlagen)';
        }

        // Füge Information hinzu, wenn es eine Bauernumwandlung war
        if (move.isPromotion && move.promotionType != null) {
          moveNotation +=
              ' (Umwandlung zu ${_getPieceSymbol(ChessPiece(PieceColor.white, move.promotionType!))})';
        }

        _moveHistory.add(moveNotation);

        // Aktualisiere den Spielstatus
        _updateGameStatus();
      });
    }
  }

  void _updateGameStatus() {
    setState(() {
      _gameOver = widget.board.gameOver;

      if (_gameOver) {
        if (widget.board.winner != null) {
          _statusMessage = widget.board.winner == PieceColor.white
              ? 'Weiß gewinnt!'
              : 'Schwarz gewinnt!';
        } else {
          _statusMessage = 'Unentschieden!';
        }
      } else {
        _statusMessage = widget.board.currentTurn == PieceColor.white
            ? 'Weiß ist am Zug'
            : 'Schwarz ist am Zug';
      }
    });
  }

  String _getPieceSymbol(ChessPiece piece) {
    switch (piece.type) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.variantName),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _statusMessage,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              if (widget.customStatusWidget != null) ...[
                const SizedBox(width: 8),
                widget.customStatusWidget!,
              ],
            ],
          ),
        ),

        // Schachbrett
        Expanded(
          child: Center(
            child: ChessBoardWidget(
              board: widget.board,
              onMove: _handleMove,
            ),
          ),
        ),

        // Benutzerdefinierte Steuerelemente
        if (widget.customControlsWidget != null) widget.customControlsWidget!,

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
              board: widget.board,
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
                child: Column(
                  children: [
                    Text(
                      _statusMessage,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    if (widget.customStatusWidget != null)
                      widget.customStatusWidget!,
                  ],
                ),
              ),

              // Benutzerdefinierte Steuerelemente
              if (widget.customControlsWidget != null)
                widget.customControlsWidget!,

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
    } else {
      return widget.board.currentTurn == PieceColor.white
          ? Colors.white.withOpacity(0.3)
          : Colors.grey.withOpacity(0.3);
    }
  }

  void _resetGame() {
    // Implementiere die Logik zum Zurücksetzen des Spiels
    // Dies muss je nach Schachvariante angepasst werden
    setState(() {
      _moveHistory = [];
      _gameOver = false;
      _statusMessage = 'Weiß ist am Zug';
    });
  }

  void _showRules() {
    // Zeige die Regeln für die aktuelle Schachvariante an
    // Dies muss je nach Schachvariante angepasst werden
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${widget.variantName} Regeln'),
        content: const SingleChildScrollView(
          child: Text(
              'Hier werden die Regeln für die ausgewählte Schachvariante angezeigt.'),
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
