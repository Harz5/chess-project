import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/online_game_service.dart';
import 'online_game_screen.dart';

class OnlineLobbyScreen extends StatefulWidget {
  const OnlineLobbyScreen({super.key});

  @override
  State<OnlineLobbyScreen> createState() => _OnlineLobbyScreenState();
}

class _OnlineLobbyScreenState extends State<OnlineLobbyScreen> {
  final OnlineGameService _gameService = OnlineGameService();
  final TextEditingController _gameIdController = TextEditingController();
  bool _isCreatingGame = false;
  bool _isJoiningGame = false;
  String? _errorMessage;

  @override
  void dispose() {
    _gameIdController.dispose();
    super.dispose();
  }

  Future<void> _createGame() async {
    setState(() {
      _isCreatingGame = true;
      _errorMessage = null;
    });

    try {
      final gameId = await _gameService.createGame();
      if (!mounted) return;

      // Navigiere zum Spielbildschirm
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OnlineGameScreen(
            gameId: gameId,
            isCreator: true,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Fehler beim Erstellen des Spiels: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingGame = false;
        });
      }
    }
  }

  Future<void> _joinGame() async {
    final gameId = _gameIdController.text.trim();
    if (gameId.isEmpty) {
      setState(() {
        _errorMessage = 'Bitte gib eine Spiel-ID ein';
      });
      return;
    }

    setState(() {
      _isJoiningGame = true;
      _errorMessage = null;
    });

    try {
      final success = await _gameService.joinGame(gameId);
      if (!mounted) return;

      if (success) {
        // Navigiere zum Spielbildschirm
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OnlineGameScreen(
              gameId: gameId,
              isCreator: false,
            ),
          ),
        );
      } else {
        setState(() {
          _errorMessage =
              'Konnte dem Spiel nicht beitreten. Überprüfe die Spiel-ID.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Fehler beim Beitreten des Spiels: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isJoiningGame = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Online Schachspiel'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.wifi,
                size: 80,
                color: Colors.brown,
              ),
              const SizedBox(height: 20),
              const Text(
                'Online Schachspiel',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isCreatingGame ? null : _createGame,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  minimumSize: const Size(250, 50),
                ),
                child: _isCreatingGame
                    ? const CircularProgressIndicator()
                    : const Text('Neues Spiel erstellen',
                        style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 30),
              const Text(
                'Oder tritt einem existierenden Spiel bei:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 250,
                child: TextField(
                  controller: _gameIdController,
                  decoration: const InputDecoration(
                    labelText: 'Spiel-ID',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _isJoiningGame ? null : _joinGame,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  minimumSize: const Size(250, 50),
                ),
                child: _isJoiningGame
                    ? const CircularProgressIndicator()
                    : const Text('Spiel beitreten',
                        style: TextStyle(fontSize: 18)),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 20),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
