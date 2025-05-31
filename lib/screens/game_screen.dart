import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../providers/ai_provider.dart';
import '../models/position.dart';
import '../widgets/chess_board_widget.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
    // Initialisiere die KI, wenn es ein KI-Spiel ist
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final aiProvider = Provider.of<AIProvider>(context, listen: false);
      final gameProvider = Provider.of<GameProvider>(context, listen: false);

      if (gameProvider.isAIGame && !aiProvider.isInitialized) {
        aiProvider.initialize();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);
    final aiProvider = Provider.of<AIProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(gameProvider.gameName),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              gameProvider.newGame();
            },
            tooltip: 'Neues Spiel',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigiere zu den Einstellungen
              Navigator.pushNamed(context, '/settings');
            },
            tooltip: 'Einstellungen',
          ),
        ],
      ),
      body: Column(
        children: [
          // Spielinformationen
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Am Zug: ${gameProvider.currentTurn == PieceColor.white ? 'Weiß' : 'Schwarz'}',
                  style: const TextStyle(fontSize: 18),
                ),
                if (gameProvider.isAIGame)
                  Text(
                    'KI-Schwierigkeit: ${gameProvider.difficulty}',
                    style: const TextStyle(fontSize: 18),
                  ),
              ],
            ),
          ),

          // Schachbrett
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: ChessBoardWidget(
                  board: gameProvider.board,
                  onPieceMoved: (from, to) async {
                    // Führe den Spielerzug aus
                    final moveSuccess = gameProvider.movePiece(from, to);

                    // Wenn es ein KI-Spiel ist und der Zug erfolgreich war, lasse die KI ziehen
                    if (moveSuccess &&
                        gameProvider.isAIGame &&
                        !gameProvider.gameOver &&
                        aiProvider.isReady) {
                      // Warte kurz, damit der Spieler den eigenen Zug sehen kann
                      await Future.delayed(const Duration(milliseconds: 500));

                      // Berechne den KI-Zug
                      final aiMove = await aiProvider.calculateBestMove(
                        gameProvider.board,
                        thinkingTimeMs: 1000,
                      );

                      // Führe den KI-Zug aus, wenn einer gefunden wurde
                      if (aiMove != null) {
                        gameProvider.makeMove(aiMove);
                      }
                    }
                  },
                ),
              ),
            ),
          ),

          // Spielstatus
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (gameProvider.gameOver)
                  Text(
                    gameProvider.winner == null
                        ? 'Unentschieden!'
                        : 'Gewinner: ${gameProvider.winner == PieceColor.white ? 'Weiß' : 'Schwarz'}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (gameProvider.isInCheck() && !gameProvider.gameOver)
                  Text(
                    '${gameProvider.currentTurn == PieceColor.white ? 'Weiß' : 'Schwarz'} steht im Schach!',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigiere zur Analyse
          Navigator.pushNamed(context, '/analysis');
        },
        tooltip: 'Analyse',
        child: const Icon(Icons.analytics),
      ),
    );
  }
}
