import 'package:flutter/material.dart';
import '../models/chess_board.dart';
import '../models/chess_piece.dart';
import '../models/position.dart';
import '../services/ai_service.dart';
import '../widgets/chess_board_widget.dart';

class AIGameScreen extends StatefulWidget {
  const AIGameScreen({super.key});

  @override
  State<AIGameScreen> createState() => _AIGameScreenState();
}

class _AIGameScreenState extends State<AIGameScreen> {
  late ChessBoard _board;
  final AIService _aiService = AIService();
  String _statusMessage = 'Initialisiere KI...';
  List<String> _moveHistory = [];
  String _selectedDifficulty = 'Mittel';
  bool _isPlayerTurn = true;
  bool _isAIThinking = false;
  bool _gameOver = false;

  @override
  void initState() {
    super.initState();
    _resetGame();
    _initializeAI();
  }

  @override
  void dispose() {
    _aiService.dispose();
    super.dispose();
  }

  Future<void> _initializeAI() async {
    await _aiService.initialize();
    _aiService.setDifficulty(_selectedDifficulty);

    setState(() {
      _statusMessage = 'Du bist am Zug (Weiß)';
    });
  }

  void _resetGame() {
    setState(() {
      _board = ChessBoard();
      _moveHistory = [];
      _isPlayerTurn = true;
      _isAIThinking = false;
      _gameOver = false;
      _statusMessage = 'Du bist am Zug (Weiß)';
    });
  }

  void _handleMove(Position from, Position to) async {
    if (!_isPlayerTurn || _isAIThinking || _gameOver) return;

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
        _moveHistory.add('Du: ${from.toAlgebraic()} → ${to.toAlgebraic()}');

        // Überprüfe, ob das Spiel beendet ist
        if (_board.gameOver) {
          _gameOver = true;
          if (_board.winner != null) {
            _statusMessage = 'Du gewinnst!';
          } else {
            _statusMessage = 'Unentschieden!';
          }
          return;
        }

        // KI ist am Zug
        _isPlayerTurn = false;
        _isAIThinking = true;
        _statusMessage = 'KI denkt...';
      });

      // Lasse die KI einen Zug machen
      await _makeAIMove();
    }
  }

  Future<void> _makeAIMove() async {
    if (!_aiService.isReady) {
      await _initializeAI();
    }

    // Berechne den besten Zug
    final aiMove = await _aiService.calculateBestMove(
      _board,
      thinkingTimeMs: _getDifficultyThinkingTime(_selectedDifficulty),
    );

    if (aiMove != null) {
      // Führe den KI-Zug aus
      final success = _board.makeMove(aiMove);

      setState(() {
        _isAIThinking = false;

        if (success) {
          // Füge den Zug zur Historie hinzu
          _moveHistory.add(
              'KI: ${aiMove.from.toAlgebraic()} → ${aiMove.to.toAlgebraic()}');

          // Überprüfe, ob das Spiel beendet ist
          if (_board.gameOver) {
            _gameOver = true;
            if (_board.winner != null) {
              _statusMessage = 'KI gewinnt!';
            } else {
              _statusMessage = 'Unentschieden!';
            }
          } else {
            _isPlayerTurn = true;
            _statusMessage = 'Du bist am Zug (Weiß)';
          }
        } else {
          // Fehler beim Ausführen des KI-Zugs
          _isPlayerTurn = true;
          _statusMessage = 'Fehler beim KI-Zug. Du bist am Zug.';
        }
      });
    } else {
      // Fehler bei der Berechnung des KI-Zugs
      setState(() {
        _isAIThinking = false;
        _isPlayerTurn = true;
        _statusMessage = 'KI konnte keinen Zug finden. Du bist am Zug.';
      });
    }
  }

  int _getDifficultyThinkingTime(String difficulty) {
    // Denkzeit in Millisekunden je nach Schwierigkeitsgrad
    switch (difficulty) {
      case 'Anfänger':
        return 500;
      case 'Leicht':
        return 1000;
      case 'Mittel':
        return 2000;
      case 'Fortgeschritten':
        return 3000;
      case 'Experte':
        return 4000;
      case 'Meister':
        return 5000;
      default:
        return 2000;
    }
  }

  void _changeDifficulty(String? newDifficulty) {
    if (newDifficulty != null && newDifficulty != _selectedDifficulty) {
      setState(() {
        _selectedDifficulty = newDifficulty;
      });

      if (_aiService.isReady) {
        _aiService.setDifficulty(_selectedDifficulty);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gegen KI spielen'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings),
            tooltip: 'Schwierigkeit',
            onSelected: _changeDifficulty,
            itemBuilder: (context) =>
                AIService.difficultyLevels.keys.map((level) {
              return PopupMenuItem<String>(
                value: level,
                child: Row(
                  children: [
                    Text(level),
                    const SizedBox(width: 8),
                    if (_selectedDifficulty == level)
                      const Icon(Icons.check, color: Colors.green),
                  ],
                ),
              );
            }).toList(),
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
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            _statusMessage,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Center(
            child: ChessBoardWidget(
              board: _board,
              onMove: _handleMove,
            ),
          ),
        ),
        _buildMoveHistory(),
      ],
    );
  }

  Widget _buildLandscapeLayout() {
    return Row(
      children: [
        Expanded(
          child: Center(
            child: ChessBoardWidget(
              board: _board,
              onMove: _handleMove,
            ),
          ),
        ),
        SizedBox(
          width: 200,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _statusMessage,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    const Text('Schwierigkeit: '),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedDifficulty,
                        isExpanded: true,
                        onChanged: _changeDifficulty,
                        items: AIService.difficultyLevels.keys.map((level) {
                          return DropdownMenuItem<String>(
                            value: level,
                            child: Text(level),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: _buildMoveHistory()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMoveHistory() {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Zughistorie',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _moveHistory.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 2.0),
                  child: Text(_moveHistory[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
