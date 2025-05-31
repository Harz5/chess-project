import 'package:flutter/material.dart';
import '../services/time_control_service.dart';
import '../models/chess_board.dart';
import '../models/chess_piece.dart';
import '../models/position.dart';
import '../widgets/chess_board_widget.dart';

class TimeControlGameScreen extends StatefulWidget {
  final String timeControlMode;
  final int? customTimeMinutes;
  final int? customIncrementSeconds;

  const TimeControlGameScreen({
    super.key,
    required this.timeControlMode,
    this.customTimeMinutes,
    this.customIncrementSeconds,
  });

  @override
  State<TimeControlGameScreen> createState() => _TimeControlGameScreenState();
}

class _TimeControlGameScreenState extends State<TimeControlGameScreen> {
  late ChessBoard _board;
  final TimeControlService _timeControlService = TimeControlService();

  int _whiteTimeMs = 0;
  int _blackTimeMs = 0;
  List<String> _moveHistory = [];
  bool _gameOver = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _resetGame();
  }

  @override
  void dispose() {
    _timeControlService.dispose();
    super.dispose();
  }

  void _resetGame() {
    setState(() {
      _board = ChessBoard();
      _moveHistory = [];
      _gameOver = false;
      _statusMessage = 'Weiß ist am Zug';
    });

    // Initialisiere die Zeitkontrolle
    _timeControlService.initialize(
      timeControlMode: widget.timeControlMode,
      customTimeMinutes: widget.customTimeMinutes,
      customIncrementSeconds: widget.customIncrementSeconds,
      onTimerUpdate: (whiteTimeMs, blackTimeMs) {
        setState(() {
          _whiteTimeMs = whiteTimeMs;
          _blackTimeMs = blackTimeMs;
        });
      },
      onTimeOut: (color) {
        _handleTimeOut(color);
      },
    );

    // Setze die initialen Zeiten
    _whiteTimeMs = _timeControlService.getWhiteTimeMs();
    _blackTimeMs = _timeControlService.getBlackTimeMs();

    // Starte die Zeitkontrolle, wenn sie aktiv ist
    if (widget.timeControlMode != 'none') {
      _timeControlService.start();
    }
  }

  void _handleTimeOut(PieceColor color) {
    setState(() {
      _gameOver = true;
      _statusMessage = color == PieceColor.white
          ? 'Zeit abgelaufen - Schwarz gewinnt!'
          : 'Zeit abgelaufen - Weiß gewinnt!';
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
      // Aktualisiere die Zeitkontrolle
      _timeControlService.onMoveMade(piece.color);

      setState(() {
        // Füge den Zug zur Historie hinzu
        _moveHistory.add(
            '${piece.color == PieceColor.white ? 'W' : 'S'}: ${from.toAlgebraic()} → ${to.toAlgebraic()}');

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
          _timeControlService.stop();
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

  void _togglePause() {
    if (_timeControlService.isPaused()) {
      _timeControlService.resume();
    } else {
      _timeControlService.pause();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            TimeControlService.timeControlModes[widget.timeControlMode] ??
                'Schach'),
        actions: [
          if (widget.timeControlMode != 'none')
            IconButton(
              icon: Icon(_timeControlService.isPaused()
                  ? Icons.play_arrow
                  : Icons.pause),
              onPressed: _togglePause,
              tooltip:
                  _timeControlService.isPaused() ? 'Fortsetzen' : 'Pausieren',
            ),
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
        // Spieler-Uhren
        if (widget.timeControlMode != 'none')
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildPlayerClock(
                    label: 'Schwarz',
                    timeMs: _blackTimeMs,
                    isActive:
                        _board.currentTurn == PieceColor.black && !_gameOver,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPlayerClock(
                    label: 'Weiß',
                    timeMs: _whiteTimeMs,
                    isActive:
                        _board.currentTurn == PieceColor.white && !_gameOver,
                  ),
                ),
              ],
            ),
          ),

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
              // Spieler-Uhren
              if (widget.timeControlMode != 'none') ...[
                _buildPlayerClock(
                  label: 'Schwarz',
                  timeMs: _blackTimeMs,
                  isActive:
                      _board.currentTurn == PieceColor.black && !_gameOver,
                ),
                const SizedBox(height: 8),
                _buildPlayerClock(
                  label: 'Weiß',
                  timeMs: _whiteTimeMs,
                  isActive:
                      _board.currentTurn == PieceColor.white && !_gameOver,
                ),
                const SizedBox(height: 16),
              ],

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

  Widget _buildPlayerClock({
    required String label,
    required int timeMs,
    required bool isActive,
  }) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.blue.withOpacity(0.2)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: isActive ? Colors.blue : Colors.grey,
          width: 2.0,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            TimeControlService.formatTime(timeMs),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: timeMs < 30000
                  ? Colors.red
                  : null, // Rot bei weniger als 30 Sekunden
            ),
          ),
        ],
      ),
    );
  }
}
