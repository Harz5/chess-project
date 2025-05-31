import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chess_board.dart';
import '../models/position.dart';
import '../services/online_game_service.dart';
import '../widgets/chess_board_widget.dart';

class OnlineGameScreen extends StatefulWidget {
  final String gameId;
  final bool isCreator;

  const OnlineGameScreen({
    super.key,
    required this.gameId,
    required this.isCreator,
  });

  @override
  State<OnlineGameScreen> createState() => _OnlineGameScreenState();
}

class _OnlineGameScreenState extends State<OnlineGameScreen> {
  final OnlineGameService _gameService = OnlineGameService();
  ChessBoard? _board;
  bool _isPlayerTurn = false;
  String _statusMessage = 'Warte auf Gegner...';
  List<String> _moveHistory = [];
  bool _gameOver = false;
  String? _winner;

  @override
  void initState() {
    super.initState();
    _setupGame();
  }

  void _setupGame() {
    // Höre auf Änderungen im Spiel
    _gameService.listenToGame(widget.gameId).listen((snapshot) {
      if (!snapshot.exists) {
        setState(() {
          _statusMessage = 'Spiel nicht gefunden';
        });
        return;
      }

      final gameData = snapshot.data() as Map<String, dynamic>;

      // Überprüfe den Spielstatus
      final status = gameData['status'];
      if (status == 'waiting') {
        setState(() {
          _statusMessage = 'Warte auf Gegner...';
          _isPlayerTurn = false;
        });
        return;
      }

      // Deserialisiere das Spielbrett
      final board = _deserializeBoard(gameData);

      // Überprüfe, ob der Spieler am Zug ist
      final isWhiteTurn = gameData['currentTurn'] == 'white';
      final isPlayerWhite = widget.isCreator; // Ersteller ist immer Weiß
      _isPlayerTurn = isWhiteTurn == isPlayerWhite;

      // Aktualisiere die Zughistorie
      final moves = gameData['moves'] as List<dynamic>;
      final moveHistory = <String>[];
      for (final move in moves) {
        final from = move['from'];
        final to = move['to'];
        final player = move['player'] == 'white' ? 'Weiß' : 'Schwarz';
        moveHistory.add('$player: $from → $to');
      }

      // Überprüfe, ob das Spiel beendet ist
      final gameOver = gameData['status'] == 'completed';
      String? winner;
      if (gameOver) {
        if (gameData['winner'] == 'white') {
          winner = 'Weiß';
        } else if (gameData['winner'] == 'black') {
          winner = 'Schwarz';
        } else {
          winner = 'Unentschieden';
        }
      }

      setState(() {
        _board = board;
        _moveHistory = moveHistory;
        _gameOver = gameOver;
        _winner = winner;

        if (_gameOver) {
          _statusMessage = 'Spiel beendet - $_winner gewinnt!';
          if (_winner == 'Unentschieden') {
            _statusMessage = 'Spiel beendet - Unentschieden!';
          }
        } else {
          _statusMessage = _isPlayerTurn
              ? 'Du bist am Zug (${isPlayerWhite ? 'Weiß' : 'Schwarz'})'
              : 'Gegner ist am Zug (${!isPlayerWhite ? 'Weiß' : 'Schwarz'})';
        }
      });
    });
  }

  ChessBoard _deserializeBoard(Map<String, dynamic> gameData) {
    return _gameService._deserializeBoard(gameData['board']);
  }

  void _handleMove(Position from, Position to) {
    if (!_isPlayerTurn || _gameOver) return;

    _gameService.makeMove(widget.gameId, from, to).then((success) {
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ungültiger Zug')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Online Schachspiel - ${widget.gameId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.content_copy),
            onPressed: () {
              // Kopiere die Spiel-ID in die Zwischenablage
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Spiel-ID kopiert')),
              );
            },
            tooltip: 'Spiel-ID kopieren',
          ),
        ],
      ),
      body: _board == null
          ? const Center(child: CircularProgressIndicator())
          : OrientationBuilder(
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
              board: _board!,
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
              board: _board!,
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
